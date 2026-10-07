package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.util.Log;
import com.esmertec.android.jbed.JbedFileLog;
import com.esmertec.android.jbed.JbedSettings;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.jar.Attributes;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;
import java.util.jar.Manifest;

/**
 * Installs a MIDlet suite into the Jbed storage without going through the
 * proprietary VM installer.
 *
 * The recovered libjbedvm.so runs its own Java AMS, but that AMS is *ahead of
 * time compiled* inside the library (its Java string constants are stored as
 * UCS-2 in the ROM image next to literals such as "suite.jar", "suite.utf" and
 * "selector.utf"). Its installer overflows the host thread stack on Android 11
 * ("StackOverflowError: stack size 65MB" as soon as a local install event is
 * consumed), so the suite is registered here instead:
 *
 *   <basedir><prefix>suite.jar          the MIDlet JAR
 *   <basedir><prefix>.jar               the same JAR under the object-style name
 *   <basedir><prefix>suite.utf          JAD attributes in Java .properties form
 *   <basedir><prefix>info_suite.utf     the same attributes in the binary
 *                                       key/value form JbedSelectorData reads
 *   <basedir><prefix>info_<no>.icn      the MIDlet icon
 *   <basedir>selector.utf               appended suite entry (DataOutput UTF)
 *
 * The list the user sees is built by the Java side (JbedSelector reads
 * selector.utf), so the suite appears as soon as this returns. Whether the VM
 * itself can launch it depends on the JAR/JAD naming above, which is why the
 * first launch of this build also dumps the current storage layout.
 */
public final class LocalSuiteInstaller {
    public static final String TAG = "LocalSuiteInstaller";

    private static final String DISABLE_MARKER =
            "/storage/emulated/0/jbedfix/disable-local-sidecar-install.patch";
    private static final String SHIM_DIR = "/storage/emulated/0/jbedfix";
    private static final String SELECTOR_FILE_NAME = "selector.utf";
    private static final String LINE_SEPARATOR = "\n";
    private static final long HEDGE_COPY_LIMIT = 24L * 1024L * 1024L;

    private static boolean sLayoutChecked = false;

    private LocalSuiteInstaller() {
    }

    public static boolean isEnabled() {
        try {
            return !new File(DISABLE_MARKER).exists();
        } catch (Throwable throwable) {
            return true;
        }
    }

    /** A MIDlet declared by the suite manifest. */
    private static final class MidletEntry {
        String name;
        String iconPath;
        String className;
    }

    private static final class SuiteInfo {
        String name;
        String version;
        String vendor;
        String profile;
        String configuration;
        final List<MidletEntry> midlets = new ArrayList<>();
    }

    /**
     * @return null when the suite was written, otherwise a message describing
     *         why it could not be installed.
     */
    public static String install(Context context, String path) {
        if (path == null || path.length() == 0) {
            return "empty file path";
        }
        File jar = new File(path);
        if (!jar.isFile()) {
            return "not a file: " + path;
        }
        File baseDir = new File(JbedSettings.getInstance(context).getBaseDir());
        if (!baseDir.isDirectory() && !baseDir.mkdirs()) {
            return "cannot use Jbed storage " + baseDir;
        }
        dumpLayoutOnce(baseDir);
        try {
            SuiteInfo suite = readSuite(jar);
            if (suite.name == null || suite.midlets.isEmpty()) {
                return "no MIDlet-Name/MIDlet-1 attribute in the manifest";
            }
            String prefix = allocatePrefix(baseDir);
            String jarName = prefix + "suite.jar";
            File target = new File(baseDir, jarName);
            if (!copyFile(jar, target)) {
                return "cannot copy the JAR into " + baseDir;
            }
            if (jar.length() <= HEDGE_COPY_LIMIT) {
                // The AMS is AOT compiled and its file naming could not be read
                // out of the ROM image, so the JAR is also written under the
                // per-suite object name used by the Java side ("<prefix>.obj"
                // is the precompiled artefact, so "<prefix>.jar" is the plain
                // one).
                copyFile(jar, new File(baseDir, prefix + ".jar"));
            }
            String jadText = buildJad(suite, jarName, jar.length());
            writeText(new File(baseDir, prefix + "suite.utf"), jadText);
            writeText(new File(baseDir, prefix + ".jad"), jadText);
            writeInfoSuite(new File(baseDir, prefix + "info_suite.utf"), suite, jadText);
            extractIcons(baseDir, prefix, jar, suite);
            if (!appendSelectorEntry(baseDir, suite, prefix)) {
                return "cannot update " + SELECTOR_FILE_NAME;
            }
            String verify = verifyEntry(baseDir, prefix);
            JbedFileLog.info(TAG, "installed " + suite.name + " root=" + prefix + " jar="
                    + jarName + " midlets=" + suite.midlets.size() + " (" + verify + ")");
            Log.i(TAG, "installed " + suite.name + " as " + prefix + ": " + verify);
            return null;
        } catch (Throwable throwable) {
            JbedFileLog.error(TAG, "failed to install " + path, throwable);
            return "install failed: " + throwable;
        }
    }

    /* ------------------------------------------------------------------ */
    /* manifest                                                           */
    /* ------------------------------------------------------------------ */

    private static SuiteInfo readSuite(File jarFile) throws IOException {
        JarFile jar = new JarFile(jarFile);
        try {
            Manifest manifest = jar.getManifest();
            if (manifest == null) {
                throw new IOException("the JAR has no META-INF/MANIFEST.MF");
            }
            Attributes attributes = manifest.getMainAttributes();
            SuiteInfo suite = new SuiteInfo();
            suite.name = attributes.getValue("MIDlet-Name");
            suite.version = attributes.getValue("MIDlet-Version");
            suite.vendor = attributes.getValue("MIDlet-Vendor");
            suite.profile = attributes.getValue("MicroEdition-Profile");
            suite.configuration = attributes.getValue("MicroEdition-Configuration");
            if (suite.name == null) {
                suite.name = jarFile.getName();
                if (suite.name.endsWith(".jar")) {
                    suite.name = suite.name.substring(0, suite.name.length() - 4);
                }
            }
            for (int index = 1; index <= 32; index++) {
                String value = attributes.getValue("MIDlet-" + index);
                if (value == null) {
                    continue;
                }
                // MIDlet-<n>: <name>, <icon>, <class>
                String[] parts = value.split(",");
                MidletEntry entry = new MidletEntry();
                entry.name = parts.length > 0 ? parts[0].trim() : suite.name;
                entry.iconPath = parts.length > 1 ? parts[1].trim() : null;
                entry.className = parts.length > 2 ? parts[2].trim() : null;
                if (entry.className == null || entry.className.length() == 0) {
                    continue;
                }
                suite.midlets.add(entry);
            }
            return suite;
        } finally {
            try {
                jar.close();
            } catch (IOException ignored) {
            }
        }
    }

    private static String buildJad(SuiteInfo suite, String jarName, long jarSize) {
        StringBuilder text = new StringBuilder();
        text.append("MIDlet-Name: ").append(suite.name).append(LINE_SEPARATOR);
        if (suite.version != null) {
            text.append("MIDlet-Version: ").append(suite.version).append(LINE_SEPARATOR);
        }
        if (suite.vendor != null) {
            text.append("MIDlet-Vendor: ").append(suite.vendor).append(LINE_SEPARATOR);
        }
        if (suite.profile != null) {
            text.append("MicroEdition-Profile: ").append(suite.profile).append(LINE_SEPARATOR);
        }
        if (suite.configuration != null) {
            text.append("MicroEdition-Configuration: ").append(suite.configuration)
                    .append(LINE_SEPARATOR);
        }
        for (int index = 0; index < suite.midlets.size(); index++) {
            MidletEntry entry = suite.midlets.get(index);
            text.append("MIDlet-").append(index + 1).append(": ").append(entry.name).append(", ");
            if (entry.iconPath != null && entry.iconPath.length() > 0) {
                text.append(entry.iconPath);
            }
            text.append(", ").append(entry.className).append(LINE_SEPARATOR);
        }
        text.append("MIDlet-Jar-URL: ").append(jarName).append(LINE_SEPARATOR);
        text.append("MIDlet-Jar-Size: ").append(jarSize).append(LINE_SEPARATOR);
        return text.toString();
    }

    /* ------------------------------------------------------------------ */
    /* storage                                                            */
    /* ------------------------------------------------------------------ */

    /** "s0_", "s1_", ... like the preinstalled theme artefact "t0_.jar". */
    private static String allocatePrefix(File baseDir) {
        for (int index = 0; index < 100; index++) {
            String candidate = "s" + index + "_";
            boolean used = false;
            String[] names = baseDir.list();
            if (names != null) {
                for (String name : names) {
                    if (name.startsWith(candidate)) {
                        used = true;
                        break;
                    }
                }
            }
            if (!used) {
                return candidate;
            }
        }
        return "s" + System.currentTimeMillis() + "_";
    }

    private static boolean copyFile(File source, File target) {
        InputStream in = null;
        OutputStream out = null;
        try {
            in = new FileInputStream(source);
            out = new FileOutputStream(target);
            byte[] buffer = new byte[64 * 1024];
            int read;
            while ((read = in.read(buffer)) > 0) {
                out.write(buffer, 0, read);
            }
            out.flush();
            return true;
        } catch (IOException exception) {
            Log.w(TAG, "cannot copy " + source + " to " + target, exception);
            return false;
        } finally {
            closeQuietly(in);
            closeQuietly(out);
        }
    }

    private static void writeText(File target, String text) {
        OutputStream out = null;
        try {
            out = new FileOutputStream(target);
            out.write(text.getBytes("UTF-8"));
            out.flush();
        } catch (IOException exception) {
            Log.w(TAG, "cannot write " + target, exception);
        } finally {
            closeQuietly(out);
        }
    }

    private static void writeInfoSuite(File target, SuiteInfo suite, String jadText) {
        DataOutputStream out = null;
        try {
            ByteArrayOutputStream buffer = new ByteArrayOutputStream();
            out = new DataOutputStream(buffer);
            // JbedSelectorData.getInfoSuiteValue reads: an int pair count,
            // then that many readUTF key/value pairs.
            String[] keys = {"MIDlet-Name", "MIDlet-Version", "MIDlet-Vendor",
                    "MicroEdition-Profile", "MicroEdition-Configuration", "MIDlet-Jar-Size",
                    "MIDlet-Jar-URL", "suite.utf"};
            List<String> values = new ArrayList<>();
            values.add(suite.name);
            values.add(suite.version == null ? "" : suite.version);
            values.add(suite.vendor == null ? "" : suite.vendor);
            values.add(suite.profile == null ? "" : suite.profile);
            values.add(suite.configuration == null ? "" : suite.configuration);
            values.add(attributeOf(jadText, "MIDlet-Jar-Size"));
            values.add(attributeOf(jadText, "MIDlet-Jar-URL"));
            values.add("");
            out.writeInt(keys.length);
            for (int index = 0; index < keys.length; index++) {
                out.writeUTF(keys[index]);
                out.writeUTF(values.get(index));
            }
            out.flush();
            OutputStream file = new FileOutputStream(target);
            try {
                file.write(buffer.toByteArray());
                file.flush();
            } finally {
                closeQuietly(file);
            }
        } catch (IOException exception) {
            Log.w(TAG, "cannot write " + target, exception);
        } finally {
            closeQuietly(out);
        }
    }

    private static String attributeOf(String jadText, String key) {
        String prefix = key + ":";
        for (String line : jadText.split("\n")) {
            if (line.startsWith(prefix)) {
                return line.substring(prefix.length()).trim();
            }
        }
        return "";
    }

    private static void extractIcons(File baseDir, String prefix, File jarFile, SuiteInfo suite) {
        JarFile jar;
        try {
            jar = new JarFile(jarFile);
        } catch (IOException exception) {
            return;
        }
        try {
            for (int index = 0; index < suite.midlets.size(); index++) {
                String iconPath = suite.midlets.get(index).iconPath;
                if (iconPath == null || iconPath.length() == 0) {
                    continue;
                }
                String entryName = iconPath.startsWith("/") ? iconPath.substring(1) : iconPath;
                JarEntry entry = jar.getJarEntry(entryName);
                if (entry == null) {
                    continue;
                }
                InputStream in = jar.getInputStream(entry);
                try {
                    // <prefix>info_<no>.icn is where JbedSelectorData looks for
                    // the icon of MIDlet <no>; the format is detected from the
                    // content, so the raw bytes are enough.
                    File target = new File(baseDir, prefix + "info_" + (index + 1) + ".icn");
                    OutputStream out = new FileOutputStream(target);
                    try {
                        byte[] buffer = new byte[16 * 1024];
                        int read;
                        while ((read = in.read(buffer)) > 0) {
                            out.write(buffer, 0, read);
                        }
                        out.flush();
                    } finally {
                        closeQuietly(out);
                    }
                } finally {
                    closeQuietly(in);
                }
            }
        } catch (Throwable throwable) {
            Log.w(TAG, "cannot extract the MIDlet icon", throwable);
        } finally {
            try {
                jar.close();
            } catch (IOException ignored) {
            }
        }
    }

    private static String readSelectorText(File selector) {
        if (!selector.isFile()) {
            return "";
        }
        DataInputStream in = null;
        try {
            in = new DataInputStream(new FileInputStream(selector));
            return in.readUTF();
        } catch (Throwable throwable) {
            Log.w(TAG, "cannot read " + selector, throwable);
            return null;
        } finally {
            closeQuietly(in);
        }
    }

    private static boolean appendSelectorEntry(File baseDir, SuiteInfo suite, String prefix) {
        File selector = new File(baseDir, SELECTOR_FILE_NAME);
        String text = readSelectorText(selector);
        if (text == null) {
            return false;
        }
        StringBuilder block = new StringBuilder();
        if (text.length() > 0 && !text.endsWith(LINE_SEPARATOR)) {
            block.append(LINE_SEPARATOR);
        }
        block.append("suite=").append(suite.name).append(LINE_SEPARATOR);
        block.append("root=").append(prefix).append(LINE_SEPARATOR);
        if (suite.vendor != null) {
            block.append("vendor=").append(suite.vendor).append(LINE_SEPARATOR);
        }
        block.append("domain=untrusted").append(LINE_SEPARATOR);
        block.append("install_time=").append(System.currentTimeMillis()).append(LINE_SEPARATOR);
        block.append("removable=N").append(LINE_SEPARATOR);
        block.append("preinstalled=N").append(LINE_SEPARATOR);
        for (MidletEntry entry : suite.midlets) {
            block.append("midlet=").append(entry.name).append(LINE_SEPARATOR);
            block.append("class=").append(entry.className).append(LINE_SEPARATOR);
        }
        String updated = text + block;
        if (updated.length() > 30000) {
            // writeUTF stores a 16-bit length; never truncate the file the VM
            // owns, hand the request back to the original installer instead.
            Log.w(TAG, "selector.utf would exceed the writeUTF limit; not touching it");
            return false;
        }
        DataOutputStream out = null;
        try {
            out = new DataOutputStream(new FileOutputStream(selector));
            out.writeUTF(updated);
            out.flush();
            return true;
        } catch (IOException exception) {
            Log.w(TAG, "cannot write " + selector, exception);
            return false;
        } finally {
            closeQuietly(out);
        }
    }

    private static String verifyEntry(File baseDir, String prefix) {
        try {
            // JbedSelector concatenates the storage path and the file name, so
            // the path has to keep its trailing separator.
            JbedSelector selector = new JbedSelector(baseDir.getPath() + File.separator);
            selector.loadFromFiles();
            for (JbedSelectorData data : selector.getMidlets()) {
                if (prefix.equals(data.mRoot)) {
                    return "selector=" + SELECTOR_FILE_NAME + " name=" + data.mName + " no="
                            + data.mNo + " class=" + data.mEntryClass;
                }
            }
            return "not found after reload";
        } catch (Throwable throwable) {
            return "reload failed: " + throwable;
        }
    }

    /**
     * One-time dump of the storage the AMS manages: the file naming of an
     * installed suite and the selector format cannot be read out of the AOT
     * image, so the first launch of this build records them next to the logs.
     */
    private static void dumpLayoutOnce(File baseDir) {
        if (sLayoutChecked) {
            return;
        }
        sLayoutChecked = true;
        try {
            StringBuilder listing = new StringBuilder();
            String[] names = baseDir.list();
            if (names != null) {
                java.util.Arrays.sort(names);
                for (String name : names) {
                    File file = new File(baseDir, name);
                    listing.append(name).append(' ').append(file.length())
                            .append(file.isDirectory() ? " dir" : "").append(LINE_SEPARATOR);
                }
            }
            File selector = new File(baseDir, SELECTOR_FILE_NAME);
            String text = readSelectorText(selector);
            JbedFileLog.info(TAG, "storage layout of " + baseDir + " (" + (names == null ? 0
                    : names.length) + " entries):" + LINE_SEPARATOR + listing);
            JbedFileLog.info(TAG, SELECTOR_FILE_NAME + " content:");
            JbedFileLog.info(TAG, text == null ? "<unreadable>" : text);
            writeText(new File(SHIM_DIR, "installed-layout.txt"),
                    "basedir=" + baseDir + LINE_SEPARATOR + listing + LINE_SEPARATOR
                            + SELECTOR_FILE_NAME + ":" + LINE_SEPARATOR + text);
        } catch (Throwable throwable) {
            Log.w(TAG, "layout dump failed", throwable);
        }
    }

    private static void closeQuietly(java.io.Closeable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (IOException ignored) {
            }
        }
    }
}
