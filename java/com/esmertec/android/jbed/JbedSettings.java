package com.esmertec.android.jbed;

import android.content.Context;
import android.database.Cursor;
import android.text.TextUtils;
import android.util.Log;
import com.esmertec.android.jbed.ams.BasicEventHandler;
import com.esmertec.android.jbed.jsr.JbedMidpManager;
import com.esmertec.android.jbed.util.FileUtil;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.security.KeyStore;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.List;
import javax.net.ssl.TrustManager;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.X509TrustManager;

/* JADX INFO: loaded from: classes.dex */
public class JbedSettings {
    public static final String ANDROID_TRUSTSTORE_FILE_SIZE = "jbed.android.cert.size";
    static final String CERT_FILE_PREFIX = "android";
    private static JbedSettings INSTANCE = null;
    public static final String IS_ALLOWED_HIDDEN_MENU_PROPERTY = "is_allowed_hidden_menu";
    public static final String IS_RUNTCK_PROPERTY = "is_runtck";
    public static final String SETTINGS_NAME = "settings";
    private static final String TAG = "JbedSettings";
    public static final String TCK_URL_PROPERTY = "tck_url";
    private String mBaseDir;
    private String mCertsRootDir;
    private Context mContext;
    private String mExtraCommandLine;
    private String mLocalinstallDir;
    private String mRootDir;
    long mSyncCertsDate;
    long mSyncCertsSize;
    private String mTckUrl;
    private boolean mIsNativeAms = false;
    private boolean mIsRunTck = false;
    private boolean mIsAllowedHiddenMenu = false;
    private boolean mIsAMSListLaunch = false;

    public static JbedSettings getInstance(Context context) {
        if (INSTANCE == null) {
            INSTANCE = new JbedSettings(context, true);
        }
        return INSTANCE;
    }

    public static JbedSettings getInstanceWithoutSyncCert(Context context) {
        if (INSTANCE == null) {
            INSTANCE = new JbedSettings(context, false);
        }
        return INSTANCE;
    }

    /* JADX WARN: Type inference failed for: r0v5, types: [com.esmertec.android.jbed.JbedSettings$1] */
    private JbedSettings(Context context, boolean isSyncCert) {
        this.mContext = context;
        loadSettinData();
        if (isSyncCert) {
            new Thread() { // from class: com.esmertec.android.jbed.JbedSettings.1
                @Override // java.lang.Thread, java.lang.Runnable
                public void run() {
                    JbedSettings.this.syncCerts(JbedSettings.this.getCertDeviceDir());
                }
            }.start();
        }
        extractAssetFiles("LocalInstall", getLocalInstallDir());
        extractAssetFiles("Installed", getBaseDir());
        extractAssetFiles("certs", getCertsRootDir() + "DEVICE/");
        JbedConfig.init(this.mContext);
    }

    public String getRootDir() {
        return this.mRootDir;
    }

    public String getCertDeviceDir() {
        return getCertsRootDir() + "SIM/DF/trustedCertificates/";
    }

    public String getLocalInstallDir() {
        return this.mLocalinstallDir;
    }

    public String getBaseDir() {
        return this.mBaseDir;
    }

    public String getCertsRootDir() {
        return this.mCertsRootDir;
    }

    public boolean isNativeAms() {
        return this.mIsNativeAms;
    }

    public boolean isRunTck() {
        return this.mIsRunTck;
    }

    public boolean isAllowedHiddenMenu() {
        return this.mIsAllowedHiddenMenu;
    }

    public boolean isAMSListLaunch() {
        return this.mIsAMSListLaunch;
    }

    /* JADX WARN: Bottom block not found for handler: all -> 0x002d */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    private void extractAssetFile(java.lang.String r8, java.lang.String r9) {
        /*
            r7 = this;
            r2 = 0
            android.content.Context r5 = r7.mContext     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            android.content.res.AssetManager r5 = r5.getAssets()     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            java.io.InputStream r2 = r5.open(r8)     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            java.io.FileOutputStream r3 = new java.io.FileOutputStream     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            r3.<init>(r9)     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            int r4 = r2.available()     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            byte[] r0 = new byte[r4]     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            r2.read(r0)     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            r3.write(r0)     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            r3.close()     // Catch: java.io.IOException -> L25 java.lang.Throwable -> L2d
            if (r2 == 0) goto L24
            r2.close()     // Catch: java.io.IOException -> L34
        L24:
            return
        L25:
            r5 = move-exception
            r1 = r5
            java.lang.RuntimeException r5 = new java.lang.RuntimeException     // Catch: java.lang.Throwable -> L2d
            r5.<init>(r1)     // Catch: java.lang.Throwable -> L2d
            throw r5     // Catch: java.lang.Throwable -> L2d
        L2d:
            r5 = move-exception
            if (r2 == 0) goto L33
            r2.close()     // Catch: java.io.IOException -> L36
        L33:
            throw r5
        L34:
            r5 = move-exception
            goto L24
        L36:
            r6 = move-exception
            goto L33
        */
        throw new UnsupportedOperationException("Method not decompiled: com.esmertec.android.jbed.JbedSettings.extractAssetFile(java.lang.String, java.lang.String):void");
    }

    private void extractAssetFiles(String srcFolder, String destFolder) {
        try {
            String[] assets = this.mContext.getAssets().list(srcFolder);
            for (String asset : assets) {
                File destFile = new File(destFolder + asset);
                if (!destFile.exists()) {
                    LogTag.serviceDebug(TAG, " extract file " + asset + " to " + destFile.getPath());
                    extractAssetFile(srcFolder + File.separator + asset, destFile.getPath());
                }
            }
        } catch (IOException e) {
        }
    }

    void syncCerts(String certDir) {
        String trustStoreName = System.getProperty("javax.net.ssl.trustStore");
        File storeFile = new File(trustStoreName);
        if (!storeFile.exists()) {
            LogTag.serviceDebug(TAG, "WARNING: " + trustStoreName + " is not exit! do nothing! ");
            return;
        }
        LogTag.serviceDebug(TAG, "storeFileSize=" + storeFile.length() + " oldStoreFileSize=" + this.mSyncCertsSize);
        LogTag.serviceDebug(TAG, "lastModified =" + storeFile.lastModified() + " oldlastModified=" + this.mSyncCertsDate);
        if (storeFile.length() != this.mSyncCertsSize || storeFile.lastModified() != this.mSyncCertsDate) {
            FileUtil.cleanFiles(certDir, CERT_FILE_PREFIX);
            X509TrustManager mDefaultTrustManager = null;
            try {
                TrustManagerFactory tmf = TrustManagerFactory.getInstance("X509");
                tmf.init((KeyStore) null);
                TrustManager[] tms = tmf.getTrustManagers();
                if (tms != null) {
                    for (TrustManager tm : tms) {
                        if (tm instanceof X509TrustManager) {
                            mDefaultTrustManager = (X509TrustManager) tm;
                            break;
                        }
                    }
                }
                X509Certificate[] roots = mDefaultTrustManager.getAcceptedIssuers();
                for (int i = 0; i < roots.length; i++) {
                    byte[] certData = roots[i].getEncoded();
                    FileOutputStream out = new FileOutputStream(certDir + CERT_FILE_PREFIX + i + ".cer");
                    out.write(certData);
                    out.close();
                }
                updateSyncCertsInfo(storeFile.length(), storeFile.lastModified());
            } catch (Exception e) {
                Log.e(TAG, "Fail to syncRootCerts!!", e);
            }
        }
    }

    public String[] getCommands() {
        List<String> commandList = new ArrayList<>();
        commandList.add("-rootdir");
        commandList.add(!TextUtils.isEmpty(this.mRootDir) ? this.mRootDir : JbedProvider.Settings.DEFAULT_ROOT_DIR);
        commandList.add("-basedir");
        commandList.add(getBaseDir());
        commandList.add("-localInstall");
        commandList.add(getLocalInstallDir());
        String heapsizeString = JbedConfig.getHeapSizeString().trim();
        if (!heapsizeString.equals("")) {
            commandList.add("-heapsize");
            commandList.add(heapsizeString);
        }
        if (this.mIsNativeAms) {
            commandList.add("-native-ams");
        }
        if (this.mIsRunTck && !TextUtils.isEmpty(this.mTckUrl)) {
            commandList.add("-tck");
            commandList.add(this.mTckUrl);
        }
        if (!TextUtils.isEmpty(this.mExtraCommandLine)) {
            String[] extraCommands = TextUtils.split(this.mExtraCommandLine, " ");
            for (String command : extraCommands) {
                commandList.add(command);
            }
        }
        File selectorFile = new File("/data/data/com.esmertec.android.jbed/Installed/selector.utf");
        File preInstallFolder = new File(JbedProvider.Settings.DEFAULT_PREINSTALL_DIR);
        if (!selectorFile.exists() && preInstallFolder.exists()) {
            LogTag.serviceDebug(TAG, "need to do preinstall");
            commandList.add("-preinstall");
            commandList.add(JbedProvider.Settings.DEFAULT_PREINSTALL_DIR);
        }
        commandList.add("-DLandmarkStore.dir=/data/data/com.esmertec.android.jbed/location/");
        commandList.add("-Dfileconn.dir.photos=file:///sdcard/");
        commandList.add("-Dfileconn.dir.videos=file:///sdcard/");
        commandList.add("-Dfileconn.dir.graphics=file:///sdcard/");
        commandList.add("-Dfileconn.dir.tones=file:///sdcard/");
        commandList.add("-Dfileconn.dir.music=file:///sdcard/");
        commandList.add("-Dfileconn.dir.recordings=file:///sdcard/");
        commandList.add("-Dfileconn.dir.memorycard=file:///sdcard/");
        commandList.add("-Dfileconn.dir.private=file:///sdcard/");
        commandList.add("-Dfileconn.dir.photos.name=Photos");
        commandList.add("-Dfileconn.dir.videos.name=Videos");
        commandList.add("-Dfileconn.dir.graphics.name=Graphics");
        commandList.add("-Dfileconn.dir.tones.name=Tones");
        commandList.add("-Dfileconn.dir.music.name=Music");
        commandList.add("-Dfileconn.dir.recordings.name=Recording");
        commandList.add("-Dfileconn.dir.private.name=Private");
        commandList.add("-Dmicroedition.commports=USB1");
        commandList.add("-Dmicroedition.locale=" + JbedMidpManager.getLocaleString());
        String[] commands = (String[]) commandList.toArray(new String[commandList.size()]);
        return commands;
    }

    private void loadSettinData() {
        Cursor cursor = this.mContext.getContentResolver().query(JbedProvider.Settings.CONTENT_URI, null, null, null, null);
        if (cursor == null) {
            LogTag.serviceDebug(TAG, "SettingsProvider.query: failed");
        } else {
            try {
                if (cursor.moveToFirst()) {
                    this.mRootDir = cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.ROOT_DIR_COLUMN));
                    this.mBaseDir = cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.BASE_DIR_COLUMN));
                    this.mLocalinstallDir = cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.LOCALINSTALL_DIR_COLUMN));
                    this.mCertsRootDir = cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.CERTS_ROOT_DIR_COLUMN));
                    this.mIsNativeAms = cursor.getInt(cursor.getColumnIndexOrThrow(JbedProvider.Settings.IS_NATIVEAMS_COLUMN)) != 0;
                    this.mIsRunTck = cursor.getInt(cursor.getColumnIndexOrThrow("is_runtck")) != 0;
                    this.mTckUrl = cursor.getString(cursor.getColumnIndexOrThrow("tck_url"));
                    this.mIsAllowedHiddenMenu = cursor.getInt(cursor.getColumnIndexOrThrow("is_allowed_hidden_menu")) != 0;
                    this.mIsAMSListLaunch = cursor.getInt(cursor.getColumnIndexOrThrow(JbedProvider.Settings.IS_LAUNCH_AMS_LIST_COLUMN)) != 0;
                    this.mExtraCommandLine = cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.EXTRA_COMMAND_LINE_COLUMN));
                    this.mSyncCertsSize = cursor.getLong(cursor.getColumnIndexOrThrow(JbedProvider.Settings.SYNC_CERTS_SIZE_COLUMN));
                    this.mSyncCertsDate = cursor.getLong(cursor.getColumnIndexOrThrow(JbedProvider.Settings.SYNC_CERTS_DATE_COLUMN));
                }
                cursor.close();
            } catch (Throwable th) {
                cursor.close();
                throw th;
            }
        }
        if (TextUtils.isEmpty(this.mRootDir) || TextUtils.isEmpty(this.mBaseDir) || TextUtils.isEmpty(this.mLocalinstallDir)) {
            new IllegalStateException("miss some important information at " + JbedProvider.Settings.CONTENT_URI);
        }
    }

    public void updateTckInfo(String tckUrl, boolean isRunTck) {
        Cursor cursor = this.mContext.getContentResolver().query(JbedProvider.Settings.CONTENT_URI, null, null, null, null);
        if (cursor == null) {
            new IllegalStateException(JbedProvider.Settings.CONTENT_URI + " is invalid");
        }
        try {
            if (cursor.moveToFirst()) {
                if (!TextUtils.isEmpty(tckUrl)) {
                    cursor.updateString(cursor.getColumnIndexOrThrow("tck_url"), tckUrl);
                }
                cursor.updateInt(cursor.getColumnIndexOrThrow("is_runtck"), isRunTck ? 1 : 0);
                cursor.commitUpdates();
            }
            cursor.close();
            loadSettinData();
        } catch (Throwable th) {
            cursor.close();
            throw th;
        }
    }

    public void updateSyncCertsInfo(long certsFileSize, long certsFileDate) {
        Cursor cursor = this.mContext.getContentResolver().query(JbedProvider.Settings.CONTENT_URI, null, null, null, null);
        if (cursor == null) {
            new IllegalStateException(JbedProvider.Settings.CONTENT_URI + " is invalid");
        }
        try {
            if (cursor.moveToFirst()) {
                cursor.updateLong(cursor.getColumnIndexOrThrow(JbedProvider.Settings.SYNC_CERTS_SIZE_COLUMN), certsFileSize);
                cursor.updateLong(cursor.getColumnIndexOrThrow(JbedProvider.Settings.SYNC_CERTS_DATE_COLUMN), certsFileDate);
                cursor.commitUpdates();
            }
            cursor.close();
            loadSettinData();
        } catch (Throwable th) {
            cursor.close();
            throw th;
        }
    }

    public void updateDirsInfo(String rootDir, String baseDir, String localInstallDir, String certsRootDir) {
        Cursor cursor = this.mContext.getContentResolver().query(JbedProvider.Settings.CONTENT_URI, null, null, null, null);
        if (cursor == null) {
            new IllegalStateException(JbedProvider.Settings.CONTENT_URI + " is invalid");
        }
        try {
            if (cursor.moveToFirst()) {
                cursor.updateString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.ROOT_DIR_COLUMN), rootDir);
                cursor.updateString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.BASE_DIR_COLUMN), baseDir);
                cursor.updateString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.LOCALINSTALL_DIR_COLUMN), localInstallDir);
                cursor.updateString(cursor.getColumnIndexOrThrow(JbedProvider.Settings.CERTS_ROOT_DIR_COLUMN), certsRootDir);
                cursor.commitUpdates();
            }
            cursor.close();
            loadSettinData();
        } catch (Throwable th) {
            cursor.close();
            throw th;
        }
    }

    public String toString() {
        return "rootdir=" + this.mRootDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "basedir=" + this.mBaseDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "localInstall=" + this.mLocalinstallDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "native-ams=" + this.mIsNativeAms + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "isRunTck=" + this.mIsRunTck + " tckurl=[" + this.mTckUrl + "]\nmExtraCommandLine=" + this.mExtraCommandLine + "\n SyncCertsSize=[" + this.mSyncCertsSize + "] mSyncCertsDate=[" + this.mSyncCertsDate + "]\nbuildversion=" + JbedConfig.getBuildVersion();
    }
}
