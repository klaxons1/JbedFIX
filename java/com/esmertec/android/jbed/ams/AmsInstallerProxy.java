package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;
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
        Log.d(TAG, "AmsInstallerProxy()1 mMimeType = " + this.mMimeType + ",mLocalUri.getPath() = " + this.mLocalUri.getPath());
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
        this.mLocalJadUri = Uri.parse(this.mLocalJadUri.toString().replaceFirst("//@", "//"));
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
        try {
            if (this.mMimeType.equals(JAD_MIMIE_TYPE)) {
                if (this.mLocalJadUri != null) {
                    destInstallUri = this.mLocalJadUri;
                }
            } else if (this.mMimeType.equals(JAR_MIMIE_TYPE) && destInstallUri.getScheme().trim().equals("content")) {
                Cursor c = this.mContext.getContentResolver().query(destInstallUri, this.MIDLET_PROJECTION, null, null, JbedCalendarTodo.Tasks.ID);
                if (c == null) {
                    Log.w(TAG, "ERROR: requestInstall() failed to query drm uri");
                    if (c != null) {
                        c.close();
                    }
                } else {
                    try {
                        if (c.moveToFirst()) {
                            String uriString = c.getString(1);
                            destInstallUri = Uri.parse("file:///" + uriString);
                        } else {
                            Log.w(TAG, "ERROR: requestInstall() failed to query drm uri");
                        }
                        if (c != null) {
                            c.close();
                        }
                    } catch (Throwable th) {
                        if (c != null) {
                            c.close();
                        }
                        throw th;
                    }
                }
            }
            LogTag.amsDebug(TAG, "requestInstall  " + destInstallUri.toString() + " mMimeType=" + this.mMimeType);
            this.mClient.requestInstallEvent(convertIntoJbedInstallPath(destInstallUri.toString()));
        } catch (Exception e) {
            this.mClient.requestShowError(this.mContext.getString(R.string.AMS_INTERNAL_INSTALLER_ERROR, destInstallUri.toString()));
            Log.e(TAG, " faile to install " + destInstallUri.toString(), e);
        }
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
