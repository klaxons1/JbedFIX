package com.esmertec.android.jbed;

import android.content.Context;
import android.content.ContentValues;
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

    /** Copies one bundled asset exactly once during the initial Jbed setup. */
    private void extractAssetFile(String srcFile, String destFile) {
        try (java.io.InputStream in = this.mContext.getAssets().open(srcFile);
             FileOutputStream out = new FileOutputStream(destFile)) {
            byte[] buffer = new byte[8192];
            int count;
            while ((count = in.read(buffer)) != -1) {
                out.write(buffer, 0, count);
            }
        } catch (IOException e) {
            throw new RuntimeException("Unable to extract asset " + srcFile, e);
        }
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
        ContentValues values = new ContentValues();
        if (!TextUtils.isEmpty(tckUrl)) values.put(JbedProvider.Settings.TCK_URL_COLUMN, tckUrl);
        values.put(JbedProvider.Settings.IS_RUNTCK_COLUMN, isRunTck ? 1 : 0);
        this.mContext.getContentResolver().update(JbedProvider.Settings.CONTENT_URI, values, null, null);
        loadSettinData();
    }

    public void updateSyncCertsInfo(long certsFileSize, long certsFileDate) {
        ContentValues values = new ContentValues();
        values.put(JbedProvider.Settings.SYNC_CERTS_SIZE_COLUMN, certsFileSize);
        values.put(JbedProvider.Settings.SYNC_CERTS_DATE_COLUMN, certsFileDate);
        this.mContext.getContentResolver().update(JbedProvider.Settings.CONTENT_URI, values, null, null);
        loadSettinData();
    }

    public void updateDirsInfo(String rootDir, String baseDir, String localInstallDir, String certsRootDir) {
        ContentValues values = new ContentValues();
        values.put(JbedProvider.Settings.ROOT_DIR_COLUMN, rootDir);
        values.put(JbedProvider.Settings.BASE_DIR_COLUMN, baseDir);
        values.put(JbedProvider.Settings.LOCALINSTALL_DIR_COLUMN, localInstallDir);
        values.put(JbedProvider.Settings.CERTS_ROOT_DIR_COLUMN, certsRootDir);
        this.mContext.getContentResolver().update(JbedProvider.Settings.CONTENT_URI, values, null, null);
        loadSettinData();
    }

    public String toString() {
        return "rootdir=" + this.mRootDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "basedir=" + this.mBaseDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "localInstall=" + this.mLocalinstallDir + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "native-ams=" + this.mIsNativeAms + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "isRunTck=" + this.mIsRunTck + " tckurl=[" + this.mTckUrl + "]\nmExtraCommandLine=" + this.mExtraCommandLine + "\n SyncCertsSize=[" + this.mSyncCertsSize + "] mSyncCertsDate=[" + this.mSyncCertsDate + "]\nbuildversion=" + JbedConfig.getBuildVersion();
    }
}
