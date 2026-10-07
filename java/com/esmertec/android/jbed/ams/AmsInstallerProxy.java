package com.esmertec.android.jbed.ams;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.provider.OpenableColumns;
import android.text.TextUtils;
import android.util.Log;
import com.esmertec.android.jbed.JbedFileLog;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.jsr.JbedCalendarTodo;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URI;

/* JADX INFO: loaded from: classes.dex */
public class AmsInstallerProxy implements AmsConstants {
    private static final Uri DOWNLOADS_CONTENT_URI = Uri.parse("content://downloads/download");
    private static String FILENAME_COLUMN_NAME = JbedProvider.Midlets.ICON_PATH;
    public static final String JAD_MIMIE_TYPE = "text/vnd.sun.j2me.app-descriptor";
    public static final String JAR_MIMIE_TYPE = "application/java-archive";
    private static final String TAG = "AmsDownloads";
    private final String DRM_DATA;
    private final String DRM_ID;
    private final String[] MIDLET_PROJECTION;
    private AmsClient mClient;
    private Context mContext;
    private Uri mLocalJadUri;
    private Uri mLocalUri;
    private String mMimeType;

    public AmsInstallerProxy(Context context, AmsClient client, Uri localUri, String mimeType) {
        this.DRM_ID = JbedCalendarTodo.Tasks.ID;
        this.DRM_DATA = JbedProvider.Midlets.ICON_PATH;
        this.MIDLET_PROJECTION = new String[]{JbedCalendarTodo.Tasks.ID, JbedProvider.Midlets.ICON_PATH};
        this.mContext = context;
        this.mClient = client;
        this.mLocalUri = localUri;
        this.mMimeType = mimeType;
        this.mLocalJadUri = null;
        JbedFileLog.info(TAG, "AmsInstallerProxy localUri=" + this.mLocalUri
                + " mime=" + this.mMimeType);
        Log.d(TAG, "AmsInstallerProxy()1 mMimeType = " + this.mMimeType
                + ",mLocalUri=" + this.mLocalUri);
    }

    public AmsInstallerProxy(Context context, AmsClient client, Uri localUri, String mimeType, Uri localJadUri) {
        this.DRM_ID = JbedCalendarTodo.Tasks.ID;
        this.DRM_DATA = JbedProvider.Midlets.ICON_PATH;
        this.MIDLET_PROJECTION = new String[]{JbedCalendarTodo.Tasks.ID, JbedProvider.Midlets.ICON_PATH};
        this.mContext = context;
        this.mClient = client;
        this.mLocalUri = localUri;
        this.mMimeType = mimeType;
        this.mLocalJadUri = localJadUri;
        if (this.mLocalJadUri != null) {
            this.mLocalJadUri = Uri.parse(this.mLocalJadUri.toString().replaceFirst("//@", "//"));
        }
        JbedFileLog.info(TAG, "AmsInstallerProxy localUri=" + this.mLocalUri
                + " jadUri=" + this.mLocalJadUri + " mime=" + this.mMimeType);
    }

    /* JADX WARN: Code duplicated, block: B:10:0x007e A[Catch: all -> 0x009d, TRY_ENTER, TRY_LEAVE, TryCatch #0 {all -> 0x009d, blocks: (B:4:0x0064, B:6:0x006a, B:10:0x007e), top: B:19:0x0064 }] */
    /* JADX WARN: Code duplicated, block: B:12:0x0098  */
    private Uri getSourceJadUri(Uri jadLocalUri) {
        Uri uri;
        String where = "(" + FILENAME_COLUMN_NAME + "=? AND status=?)";
        LogTag.amsDebug(TAG, "getSourceJadUri() where = " + where);
        Cursor c = this.mContext.getContentResolver().query(DOWNLOADS_CONTENT_URI, null, where, new String[]{jadLocalUri.getPath(), Integer.toString(200)}, null);
        if (c == null) {
            Log.w(TAG, "ERROR: getSourceJadUri() failed to query download.uri. where= " + where);
            if (c != null) {
                c.close();
            }
            uri = null;
        } else {
            try {
                if (c.moveToFirst()) {
                    String uri2 = c.getString(c.getColumnIndexOrThrow("uri"));
                    uri = Uri.parse(uri2);
                    if (c != null) {
                        c.close();
                    }
                } else {
                    Log.w(TAG, "ERROR: getSourceJadUri() failed to query download.uri. where= " + where);
                    if (c != null) {
                        c.close();
                    }
                    uri = null;
                }
            } catch (Throwable th) {
                if (c != null) {
                    c.close();
                }
                throw th;
            }
        }
        return uri;
    }

    String getAbsoluteJarUrl(String jadUrl, String jarUrl) throws Exception {
        int lastSlashPos;
        LogTag.amsDebug(TAG, "getAbsoluteJarUrl() jadUrl = " + jadUrl + "   jarUrl = " + jarUrl);
        Uri jarUri = Uri.parse(jarUrl);
        if (!jarUri.isRelative() || (lastSlashPos = jadUrl.lastIndexOf(JbedSelector.ROOT_FOLDER_NAME)) == -1) {
            return jarUrl;
        }
        URI uri = URI.create(jadUrl.substring(0, lastSlashPos + 1) + jarUrl).normalize();
        return uri.toString();
    }

    byte[] fixRelativeJarUrl(String jadUrl, InputStream jadStream) throws Exception {
        int delimiter;
        ByteArrayOutputStream result = new ByteArrayOutputStream();
        BufferedReader reader = new BufferedReader(new InputStreamReader(jadStream, "utf-8"));
        BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(result, "utf-8"));
        while (true) {
            try {
                String line = reader.readLine();
                if (line != null) {
                    if (line.startsWith(JbedSelectorData.KEY_MIDLET_JAR_URL) && (delimiter = line.indexOf(58)) != -1) {
                        String jarUrl = line.substring(delimiter + 1).trim();
                        if (jarUrl.length() != 0) {
                            line = "MIDlet-Jar-URL: " + getAbsoluteJarUrl(jadUrl, jarUrl);
                        }
                    }
                    writer.write(line);
                    writer.write(10);
                } else {
                    reader.close();
                    writer.close();
                    return result.toByteArray();
                }
            } catch (Throwable th) {
                reader.close();
                writer.close();
                throw th;
            }
        }
    }

    byte[] fixRelativeJarUrl(String jadUrl, Uri jadLocalUri) throws Exception {
        return fixRelativeJarUrl(jadUrl, new FileInputStream(new File(jadLocalUri.getPath())));
    }

    private String convertIntoJbedInstallPath(String url) {
        String lowerCasePath = url.toLowerCase();
        if (!lowerCasePath.startsWith("file:////") && lowerCasePath.startsWith("file:///")) {
            String subStr = url.substring(8);
            if (!subStr.startsWith(JbedSelector.ROOT_FOLDER_NAME)) {
                return new String(url.substring(0, 8) + JbedSelector.ROOT_FOLDER_NAME + subStr);
            }
        }
        return url;
    }

    /* JADX WARN: Code duplicated, block: B:20:0x009b A[Catch: Exception -> 0x00a0, TRY_ENTER, TRY_LEAVE, TryCatch #0 {Exception -> 0x00a0, blocks: (B:3:0x0005, B:5:0x000f, B:7:0x0013, B:8:0x0015, B:10:0x004b, B:12:0x0055, B:14:0x0065, B:20:0x009b, B:28:0x00e2, B:29:0x00e5, B:16:0x0077, B:18:0x007d, B:24:0x00d7), top: B:30:0x0005, inners: #1 }] */
    /* JADX WARN: Code duplicated, block: B:24:0x00d7 A[Catch: all -> 0x00df, TRY_ENTER, TRY_LEAVE, TryCatch #1 {all -> 0x00df, blocks: (B:16:0x0077, B:18:0x007d, B:24:0x00d7), top: B:31:0x0077, outer: #0 }] */
    public void requestInstall() {
        Uri destInstallUri = this.mLocalUri;
        String displayUri = String.valueOf(destInstallUri);
        try {
            if (destInstallUri == null) {
                throw new IOException("external VIEW intent did not contain a URI");
            }
            String path = destInstallUri.getPath();
            String lowerPath = path == null ? "" : path.toLowerCase(java.util.Locale.US);
            boolean isJad = JAD_MIMIE_TYPE.equals(this.mMimeType) || lowerPath.endsWith(".jad");
            boolean isJar = JAR_MIMIE_TYPE.equals(this.mMimeType)
                    || "application/x-java-archive".equals(this.mMimeType)
                    || "application/x-jar".equals(this.mMimeType)
                    || "application/zip".equals(this.mMimeType)
                    || "application/octet-stream".equals(this.mMimeType)
                    || lowerPath.endsWith(".jar");
            if ("content".equalsIgnoreCase(destInstallUri.getScheme()) && !isJad && !isJar) {
                String displayName = queryDisplayName(this.mContext.getContentResolver(), destInstallUri);
                String lowerName = displayName == null ? "" : displayName.toLowerCase(java.util.Locale.US);
                isJad = lowerName.endsWith(".jad");
                isJar = lowerName.endsWith(".jar");
            }

            if (isJad && this.mLocalJadUri != null) {
                destInstallUri = this.mLocalJadUri;
            }
            if (isJar || isJad) {
                destInstallUri = makeAppReadableUri(destInstallUri, isJar ? ".jar" : ".jad");
            }
            if (destInstallUri == null) {
                throw new IOException("unable to resolve install URI");
            }
            displayUri = destInstallUri.toString();
            String installUrl = convertIntoJbedInstallPath(displayUri);
            JbedFileLog.info(TAG, "requestInstall source=" + this.mLocalUri
                    + " resolved=" + displayUri + " mime=" + this.mMimeType
                    + " isJar=" + isJar + " isJad=" + isJad
                    + " installUrl=" + installUrl);
            LogTag.amsDebug(TAG, "requestInstall " + installUrl + " mMimeType=" + this.mMimeType);
            this.mClient.requestInstallEvent(installUrl);
        } catch (Exception e) {
            JbedFileLog.error(TAG, "external install failed for " + displayUri, e);
            if (this.mClient != null) {
                this.mClient.requestShowError(this.mContext.getString(
                        R.string.AMS_INTERNAL_INSTALLER_ERROR, displayUri));
            }
            Log.e(TAG, "failed to install " + displayUri, e);
        }
    }

    /**
     * A content URI is only readable while the file manager's grant is alive;
     * the native installer cannot open content:// itself. Copy it to the app's
     * cache and pass a file:// URI to the legacy Jbed VM. The cache is retained
     * until a later run because installation is asynchronous.
     */
    private Uri makeAppReadableUri(Uri source, String extension) throws IOException {
        if (source == null || !"content".equalsIgnoreCase(source.getScheme())) {
            return source;
        }
        ContentResolver resolver = this.mContext.getContentResolver();
        String name = queryDisplayName(resolver, source);
        if (TextUtils.isEmpty(name)) {
            name = "jbed-import" + extension;
        }
        name = sanitizeFileName(name);
        if (!name.toLowerCase(java.util.Locale.US).endsWith(extension)) {
            name = name + extension;
        }
        File importDir = new File(this.mContext.getCacheDir(), "jbed-import");
        if (!importDir.exists() && !importDir.mkdirs()) {
            throw new IOException("cannot create " + importDir);
        }
        File destination = File.createTempFile("jbed-", "-" + name, importDir);
        InputStream input = resolver.openInputStream(source);
        if (input == null) {
            destination.delete();
            throw new IOException("content resolver returned no stream for " + source);
        }
        try {
            FileOutputStream output = new FileOutputStream(destination);
            try {
                byte[] buffer = new byte[8192];
                int read;
                while ((read = input.read(buffer)) != -1) {
                    output.write(buffer, 0, read);
                }
                output.flush();
            } finally {
                output.close();
            }
        } finally {
            input.close();
        }
        JbedFileLog.info(TAG, "copied content URI " + source + " to " + destination
                + " bytes=" + destination.length());
        return Uri.fromFile(destination);
    }

    private String queryDisplayName(ContentResolver resolver, Uri source) {
        Cursor cursor = null;
        try {
            cursor = resolver.query(source, new String[]{OpenableColumns.DISPLAY_NAME}, null, null, null);
            if (cursor != null && cursor.moveToFirst()) {
                return cursor.getString(0);
            }
        } catch (Throwable throwable) {
            JbedFileLog.warn(TAG, "unable to query content display name: " + throwable);
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
        return source.getLastPathSegment();
    }

    private String sanitizeFileName(String name) {
        String sanitized = name.replaceAll("[^A-Za-z0-9._-]", "_");
        return TextUtils.isEmpty(sanitized) ? "jbed-import" : sanitized;
    }

    public Uri copyFileTo(String srcFullName, String fileName) {
        String destFullName = System.getProperty("java.io.tmpdir", JbedProvider.Settings.DEFAULT_ROOT_DIR) + JbedSelector.ROOT_FOLDER_NAME + fileName;
        File destFile = new File(destFullName);
        try {
            copyFile(new File(srcFullName), destFile);
        } catch (IOException e) {
            Log.e(TAG, "failed to copy file to " + destFullName, e);
        }
        return Uri.fromFile(destFile);
    }

    private static void copyFile(File src, File dst) throws IOException {
        InputStream in = new FileInputStream(src);
        try {
            FileOutputStream out = new FileOutputStream(dst);
            try {
                byte[] buffer = new byte[8192];
                while (true) {
                    int read = in.read(buffer);
                    if (read == -1) {
                        break;
                    }
                    out.write(buffer, 0, read);
                }
                out.flush();
            } finally {
                out.close();
            }
        } finally {
            in.close();
        }
    }
}
