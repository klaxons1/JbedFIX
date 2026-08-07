package com.esmertec.android.jbed.ams;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteException;
import android.os.FileObserver;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.esmertec.android.jbed.service.JbedService;
import com.google.android.collect.Lists;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Stack;

/* JADX INFO: loaded from: classes.dex */
public class JbedSelector {
    public static final String FOLDER_TYPE_NAME = "FOLDER";
    private static final String HAS_SHORT_CUT = "hasShortCut";
    private static final String KET_MODIFIABLE_CONTENT = "modifiableContent";
    private static final String KEY_DISPLAY_INFO = "displaySizeInfo";
    private static final String KEY_DOMAIN = "domain";
    private static final String KEY_ENTRY_CLASS = "class";
    private static final String KEY_FILEROOT = "fileRoot";
    private static final String KEY_FOLDER_BEGIN = "folder";
    private static final String KEY_FOLDER_END = "endfolder";
    private static final String KEY_INSTALL_TIME = "install_time";
    private static final String KEY_IS_DRMPENDING = "drmPending";
    private static final String KEY_IS_DRMPROTECTED = "drmProtected";
    private static final String KEY_IS_DRM_INTERVAL_EVER_LAUNCHED = "drmIntervalEverLaunched";
    private static final String KEY_LAUNCHPOWERON = "launchPowerOn";
    private static final String KEY_MIDLET = "midlet";
    private static final String KEY_PREINSTALLED = "preinstalled";
    private static final String KEY_REMOVABLE = "removable";
    private static final String KEY_ROOT = "root";
    private static final String KEY_SUITE = "suite";
    private static final String KEY_VENDOR = "vendor";
    private static final String PROTECT_EXT = "protectExt";
    static final String REMOVABLE_MEDIA_DIRECTORY_NAME = "java";
    public static final String ROOT_FOLDER_NAME = "/";
    private static final String SELECTOR_FILE_NAME = "selector.utf";
    public static final String TAG = "JbedSelector";
    private static TelephonyManager telMgr;
    String mBaseDir;
    List<JbedSelectorData> mDataList = Lists.newArrayList();
    private long mLastModified = -1;

    public static class SelectorObserverManager implements JbedService.LifecycleListener {
        private static final int REFRESH_DATA_MESSAGE = 0;
        private Context mContext;
        private Handler mHandler = new Handler() { // from class: com.esmertec.android.jbed.ams.JbedSelector.SelectorObserverManager.1
            /* JADX WARN: Type inference failed for: r1v3, types: [com.esmertec.android.jbed.ams.JbedSelector$SelectorObserverManager$1$1] */
            @Override // android.os.Handler
            public void handleMessage(Message msg) {
                Intent intent = new Intent("android.intent.action.SYNC");
                SelectorObserverManager.this.mContext.sendBroadcast(intent);
                new Thread() { // from class: com.esmertec.android.jbed.ams.JbedSelector.SelectorObserverManager.1.1
                    @Override // java.lang.Thread, java.lang.Runnable
                    public void run() {
                        LogTag.amsDebug(JbedSelector.TAG, "start to parse selector files and save them to db!!!");
                        JbedSelector selector = new JbedSelector(JbedSettings.getInstance(SelectorObserverManager.this.mContext).getBaseDir());
                        selector.loadFromFiles();
                        selector.storeToDb(SelectorObserverManager.this.mContext);
                    }
                }.start();
            }
        };
        private SelectorObserver mObserver;

        class SelectorObserver extends FileObserver {
            private String mInstalledPath;

            public SelectorObserver(String installedPath) {
                super(installedPath, 132);
                this.mInstalledPath = installedPath;
                LogTag.amsDebug(JbedSelector.TAG, "SelectorObserverManager observing path=" + installedPath);
            }

            @Override // android.os.FileObserver
            public void onEvent(int event, String path) {
                LogTag.amsDebug(JbedSelector.TAG, "SelectorObserver onEvent event=" + event + " path=" + this.mInstalledPath + path);
                if (path != null && path.endsWith(JbedSelector.SELECTOR_FILE_NAME)) {
                    SelectorObserverManager.this.mHandler.removeMessages(0);
                    Message msg = SelectorObserverManager.this.mHandler.obtainMessage(0);
                    SelectorObserverManager.this.mHandler.sendMessageDelayed(msg, 500L);
                }
            }
        }

        public SelectorObserverManager(Context context) {
            this.mContext = context;
            this.mObserver = new SelectorObserver(JbedSettings.getInstance(context).getBaseDir());
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onCreate(Context context) {
            this.mObserver.startWatching();
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onDestroy(Context context) {
            this.mObserver.stopWatching();
        }
    }

    public JbedSelector(String baseDir) {
        this.mBaseDir = null;
        this.mBaseDir = baseDir;
    }

    public List<JbedSelectorData> getMidlets() {
        return this.mDataList;
    }

    public List<JbedSelectorData> getAllOnlyMidlets() {
        List<JbedSelectorData> midlets = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isMidlet()) {
                midlets.add(data);
            }
        }
        return midlets;
    }

    public List<JbedSelectorData> getOnlySuites() {
        List<JbedSelectorData> midlets = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isSuite()) {
                midlets.add(data);
            }
        }
        return midlets;
    }

    public List<JbedSelectorData> getAllSyslockedMidlets() {
        List<JbedSelectorData> midlets = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isMidlet() && data.mParent.isSystemLock()) {
                midlets.add(data);
            }
        }
        return midlets;
    }

    private JbedSelectorData createRoot() {
        JbedSelectorData result = new JbedSelectorData(this.mBaseDir, ROOT_FOLDER_NAME);
        result.mNo = -1;
        result.mRoot = FOLDER_TYPE_NAME;
        return result;
    }

    private JbedSelectorData createExternalRoot(JbedSelectorData root, String name, String storagePath) {
        JbedSelectorData result = new JbedSelectorData(storagePath, name);
        result.mNo = -1;
        result.mRoot = FOLDER_TYPE_NAME;
        result.mRemovable = "N";
        this.mDataList.add(result);
        root.addChild(result);
        return result;
    }

    void parse(JbedSelectorData root, String selector, String storagePath) {
        Stack<JbedSelectorData> folderStack = new Stack<>();
        folderStack.push(root);
        String[] lines = selector.replaceAll("\\\\,", ",").replaceAll("\\\\\\\\", "\\\\").split(BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER);
        for (int i = 0; i < lines.length; i++) {
            String line = lines[i].trim();
            if (line.length() != 0) {
                int separtorPos = lines[i].indexOf(61);
                String token = lines[i].substring(0, separtorPos).trim();
                String value = lines[i].substring(separtorPos + 1);
                if (value.length() == 0) {
                    if (token.equals(KEY_FOLDER_END)) {
                        folderStack.pop();
                    }
                } else {
                    if (value.endsWith(", \\")) {
                        value = value.substring(0, value.length() - 3);
                    }
                    if (token.equals(KEY_FOLDER_BEGIN)) {
                        JbedSelectorData folder = new JbedSelectorData(storagePath, value);
                        if (value.equals(JbedFileManager.SDCARD_FOLDER_NAME) && !JbedFileManager.isExternalStorageReady()) {
                            folder.mIsHidden = true;
                        }
                        folder.mNo = -1;
                        folder.mRoot = FOLDER_TYPE_NAME;
                        this.mDataList.add(folder);
                        JbedSelectorData parent = folderStack.peek();
                        parent.addChild(folder);
                        if (parent.isHidden()) {
                            folder.mIsHidden = true;
                        }
                        folderStack.push(folder);
                    } else if (token.equals(KEY_SUITE)) {
                        JbedSelectorData suite = new JbedSelectorData(storagePath, value);
                        suite.mNo = 0;
                        this.mDataList.add(suite);
                        folderStack.peek().addChild(suite);
                    } else if (token.equals(KEY_MIDLET)) {
                        JbedSelectorData midlet = new JbedSelectorData(storagePath, value);
                        midlet.mNo = lastSelectorData().mNo + 1;
                        midlet.mRoot = lastSelectorData().mRoot;
                        midlet.mRemovable = lastSelectorData().mRemovable;
                        midlet.mDrmProtected = lastSelectorData().mDrmProtected;
                        midlet.mDrmPending = lastSelectorData().mDrmPending;
                        midlet.mFileRoot = lastSelectorData().mFileRoot;
                        midlet.mLaunchPowerOn = lastSelectorData().mLaunchPowerOn;
                        midlet.mIsHidden = lastSelectorData().mIsHidden;
                        midlet.mIsPreInstall = lastSelectorData().mIsPreInstall;
                        this.mDataList.add(midlet);
                        findSuite(midlet.mRoot).addChild(midlet);
                    } else if (token.equals("root")) {
                        lastSelectorData().mRoot = value;
                        lastSelectorData().calculateSize(false);
                    } else if (token.equals("domain")) {
                        lastSelectorData().mDomain = value;
                    } else if (token.equals("vendor")) {
                        lastSelectorData().mVendor = value;
                    } else if (token.equals(KEY_PREINSTALLED)) {
                        lastSelectorData().mIsPreInstall = value.equals("Y");
                    } else if (token.equals("install_time")) {
                        lastSelectorData().mInstallTime = Long.parseLong(value);
                    } else if (token.equals("removable")) {
                        lastSelectorData().mRemovable = value;
                    } else if (token.equals(KEY_IS_DRMPROTECTED)) {
                        lastSelectorData().mDrmProtected = value;
                    } else if (token.equals(KEY_IS_DRMPENDING)) {
                        lastSelectorData().mDrmPending = value;
                    } else if (token.equals(KEY_IS_DRM_INTERVAL_EVER_LAUNCHED)) {
                        lastSelectorData().mDrmIntervalEverLaunched = value;
                    } else if (token.equals(KEY_FILEROOT)) {
                        lastSelectorData().mFileRoot = value;
                        if (value.equals(JbedFileManager.EXTERNAL_STORAGE_NAME) && !JbedFileManager.isExternalStorageReady()) {
                            lastSelectorData().mIsHidden = true;
                        }
                    } else if (token.equals(KEY_LAUNCHPOWERON)) {
                        lastSelectorData().mLaunchPowerOn = value.equals("Y");
                    } else if (token.equals(KET_MODIFIABLE_CONTENT)) {
                        lastSelectorData().mModifiableContent = value.equals("Y");
                    } else if (token.equals(KEY_ENTRY_CLASS)) {
                        lastSelectorData().mEntryClass = value;
                    } else if (token.equals(PROTECT_EXT)) {
                        lastSelectorData().mProtectExt = value;
                    } else if (token.equals(HAS_SHORT_CUT)) {
                        lastSelectorData().mHasShortCut = value.equals("Y");
                    } else if (token.equals(KEY_DISPLAY_INFO)) {
                        lastSelectorData().mDisplayInfo = value;
                    }
                }
            }
        }
        if (folderStack.peek() != root) {
            throw new IllegalArgumentException(storagePath + "selector.utf has been corrupted!");
        }
    }

    private JbedSelectorData lastSelectorData() {
        return this.mDataList.get(this.mDataList.size() - 1);
    }

    public synchronized void loadFromFiles() {
        IOException e;
        FileNotFoundException e2;
        JbedSelectorData root = createRoot();
        File selector = new File(root.mStoragePath + SELECTOR_FILE_NAME);
        if (selector.exists() && this.mLastModified != selector.lastModified()) {
            LogTag.amsDebug(TAG, "loadFromFiles since the selector.utf has been changed!!");
            this.mDataList.clear();
            this.mDataList.add(root);
            DataInputStream in = null;
            try {
                try {
                    DataInputStream in2 = new DataInputStream(new FileInputStream(selector));
                    try {
                        parse(root, in2.readUTF(), selector.getParent());
                        this.mLastModified = selector.lastModified();
                        try {
                            in2.close();
                        } catch (IOException e3) {
                        }
                    } catch (FileNotFoundException e4) {
                        e2 = e4;
                        Log.e(TAG, " selectorFile.toString() isn't exist ", e2);
                        throw new IllegalStateException(selector.toString() + " isn't exist");
                    } catch (IOException e5) {
                        e = e5;
                        in = in2;
                        Log.e(TAG, " failed to read selector file", e);
                        try {
                            in.close();
                        } catch (IOException e6) {
                        }
                    } catch (Throwable th) {
                        th = th;
                        in = in2;
                        try {
                            in.close();
                        } catch (IOException e7) {
                        }
                        throw th;
                    }
                } catch (FileNotFoundException e8) {
                    e2 = e8;
                } catch (IOException e9) {
                    e = e9;
                }
            } catch (Throwable th2) {
                th = th2;
            }
        }
    }

    public void storeToDb(Context context) {
        try {
            ContentResolver resolver = context.getContentResolver();
            if (telMgr == null) {
                telMgr = (TelephonyManager) context.getSystemService("phone");
            }
            resolver.delete(JbedProvider.Midlets.CONTENT_URI, null, null);
            List<JbedSelectorData> mildets = getMidlets();
            for (JbedSelectorData midlet : mildets) {
                ContentValues values = new ContentValues();
                values.put(JbedProvider.Midlets.NAME, midlet.mName);
                values.put(JbedProvider.Midlets.STORAGE_PATH, midlet.mStoragePath);
                values.put(JbedProvider.Midlets.FILE_ROOT, midlet.mFileRoot);
                values.put(JbedProvider.Midlets.NO, Integer.valueOf(midlet.mNo));
                values.put("root", midlet.mRoot);
                values.put(JbedProvider.Midlets.PARENT_UID, midlet.getParentUid());
                values.put(JbedProvider.Midlets.UID, midlet.mUid);
                values.put(JbedProvider.Midlets.ICON_PATH, midlet.getIconPath());
                values.put("vendor", midlet.mVendor);
                values.put("install_time", Long.valueOf(midlet.mInstallTime));
                values.put("domain", midlet.mDomain);
                values.put(JbedProvider.Midlets.SIZE, Integer.valueOf(midlet.mSize));
                values.put("removable", midlet.mRemovable);
                values.put(JbedProvider.Midlets.DRM_PROTECTED, midlet.mDrmProtected);
                values.put(JbedProvider.Midlets.DRM_PENDING, midlet.mDrmPending);
                values.put(JbedProvider.Midlets.HIDDEN, Integer.valueOf(midlet.isHidden() ? 1 : 0));
                midlet.mHasShortCut = false;
                values.put(JbedProvider.Midlets.HAS_SHORT_CUT, Integer.valueOf(midlet.mHasShortCut ? 1 : 0));
                values.put(JbedProvider.Midlets.DISPLAY_INFO, midlet.mDisplayInfo);
                resolver.insert(JbedProvider.Midlets.CONTENT_URI, values);
            }
            resolver.notifyChange(JbedProvider.Midlets.CONTENT_URI, null);
        } catch (SQLiteException se) {
            Log.e(TAG, " failed to store MIDlet info to db", se);
        }
    }

    @Deprecated
    void loadFromDb(Context context) {
        ContentResolver resolver = context.getContentResolver();
        Cursor c = resolver.query(JbedProvider.Midlets.CONTENT_URI, null, null, null, "_ID asc");
        try {
            this.mDataList.clear();
            while (c != null && c.moveToNext()) {
                String name = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.NAME));
                String storagePath = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.STORAGE_PATH));
                JbedSelectorData data = new JbedSelectorData(storagePath, name);
                data.mFileRoot = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.FILE_ROOT));
                data.mNo = c.getInt(c.getColumnIndexOrThrow(JbedProvider.Midlets.NO));
                data.mRoot = c.getString(c.getColumnIndexOrThrow("root"));
                data.mUid = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.UID));
                data.mVendor = c.getString(c.getColumnIndexOrThrow("vendor"));
                data.mInstallTime = c.getLong(c.getColumnIndexOrThrow("install_time"));
                data.mDomain = c.getString(c.getColumnIndexOrThrow("domain"));
                data.mSize = c.getInt(c.getColumnIndexOrThrow(JbedProvider.Midlets.SIZE));
                data.mRemovable = c.getString(c.getColumnIndexOrThrow("removable"));
                data.mDrmProtected = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.DRM_PROTECTED));
                data.mDrmPending = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.DRM_PENDING));
                int hidden = c.getInt(c.getColumnIndexOrThrow(JbedProvider.Midlets.HIDDEN));
                data.mIsHidden = hidden == 1;
                this.mDataList.add(data);
                String parentUid = c.getString(c.getColumnIndexOrThrow(JbedProvider.Midlets.PARENT_UID));
                if (parentUid != null) {
                    findByUid(parentUid).addChild(data);
                }
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

    public void touch() {
        File selectorFile = new File(this.mBaseDir + SELECTOR_FILE_NAME);
        if (selectorFile.exists()) {
            LogTag.amsDebug(TAG, " touch() the selector.utf to make refesh the content");
            selectorFile.setLastModified(new Date().getTime());
        }
    }

    public String toString() {
        StringBuffer b = new StringBuffer();
        for (JbedSelectorData data : this.mDataList) {
            b.append(data.toString());
            b.append(BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER);
        }
        return b.toString();
    }

    public JbedSelectorData findMidlet(String root, int no) {
        for (JbedSelectorData data : this.mDataList) {
            if (data.mRoot.equals(root) && data.mNo == no && no != -1) {
                return data;
            }
        }
        return null;
    }

    public JbedSelectorData getFolderByMidlet(String root, int no) {
        JbedSelectorData data = findMidlet(root, no);
        if (data == null) {
            return null;
        }
        while (!data.isFolder()) {
            data = data.mParent;
        }
        return data;
    }

    public JbedSelectorData findByUid(String uuid) {
        for (JbedSelectorData data : this.mDataList) {
            if (data.mUid.equals(uuid)) {
                return data;
            }
        }
        return null;
    }

    public JbedSelectorData findMidletByName(String name) {
        for (JbedSelectorData data : this.mDataList) {
            if (data.isMidlet() && data.mName.equals(name)) {
                return data;
            }
        }
        return null;
    }

    public JbedSelectorData findSuite(String root) {
        return findMidlet(root, 0);
    }

    private JbedSelectorData getRoot() {
        if (this.mDataList.size() != 0) {
            return this.mDataList.get(0);
        }
        JbedSelectorData result = createRoot();
        this.mDataList.add(result);
        return result;
    }

    public JbedSelectorData findByHierarchyNames(String[] names) {
        List<JbedSelectorData> list = this.mDataList;
        JbedSelectorData result = null;
        for (String str : names) {
            result = null;
            for (int i = 0; i < list.size(); i++) {
                if (!list.get(i).isMidlet() && list.get(i).mName.equals(str)) {
                    if (list.get(i).mIsHidden) {
                        return null;
                    }
                    JbedSelectorData result2 = list.get(i);
                    result = result2;
                    list = result.mChildren;
                    break;
                }
            }
            if (result == null) {
                break;
            }
        }
        return result;
    }

    List<JbedSelectorData> getChildren(JbedSelectorData parent) {
        if (parent == null) {
            parent = getRoot();
        }
        return parent.mChildren;
    }

    public List<JbedSelectorData> getMergedChildren(JbedSelectorData parent) {
        List<JbedSelectorData> result = Lists.newArrayList();
        for (JbedSelectorData data : getChildren(parent)) {
            if (!data.isHidden()) {
                if (data.isFolder() || data.isMidlet()) {
                    result.add(data);
                } else if (data.getChildCount() == 1 && !data.isDrmPending()) {
                    result.add(data.getChildren(0));
                } else {
                    result.add(data);
                }
            }
        }
        return result;
    }

    public List<JbedSelectorData> getAllFolders(boolean includeHidden, boolean includeReadonly, boolean includeRoot) {
        List<JbedSelectorData> folders = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isFolder()) {
                boolean included = true;
                if (data.isHidden()) {
                    included = true & includeHidden;
                }
                if (!data.mModifiableContent) {
                    included &= includeReadonly;
                }
                if (data.mParent == null) {
                    included &= includeRoot;
                }
                if (included) {
                    folders.add(data);
                }
            }
        }
        if (JbedConfig.Menu.isReconfigEnable()) {
            Collections.sort(folders, JbedSelectorData.NAME_REVERSE_ORDER);
        }
        return folders;
    }

    public List<JbedSelectorData> getAllFolders(boolean includeHidden, boolean includeReadonly, boolean includeRoot, boolean sdcardSelected) {
        List<JbedSelectorData> folders = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isFolder()) {
                boolean included = true;
                if (sdcardSelected) {
                    if (data.mName.equals(JbedFileManager.SDCARD_FOLDER_NAME)) {
                        folders.add(data);
                        break;
                    }
                } else {
                    if (data.isHidden()) {
                        included = true & includeHidden;
                    }
                    if (!data.mModifiableContent) {
                        included &= includeReadonly;
                    }
                    if (data.mParent == null) {
                        included &= includeRoot;
                    }
                    if (data.mName.equals(JbedFileManager.SDCARD_FOLDER_NAME)) {
                        included = false;
                    }
                    if (included) {
                        folders.add(data);
                    }
                }
            }
        }
        if (JbedConfig.Menu.isReconfigEnable()) {
            Collections.sort(folders, JbedSelectorData.NAME_REVERSE_ORDER);
        }
        return folders;
    }

    public List<JbedSelectorData> getAllSuites(JbedSelectorData folder, boolean includeHidden, boolean includeReadonly) {
        List<JbedSelectorData> suites = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isSuite()) {
                boolean included = true;
                if (data.isHidden() || data.mParent.isHidden()) {
                    included = true & includeHidden;
                }
                if (!data.mModifiableContent || !data.mParent.mModifiableContent) {
                    included &= includeReadonly;
                }
                if (folder != null) {
                    included &= folder.equals(data.mParent);
                }
                if (included) {
                    suites.add(data);
                }
            }
        }
        return suites;
    }

    public List<JbedSelectorData> getPowerOnMidlets() {
        List<JbedSelectorData> midlets = Lists.newArrayList();
        for (JbedSelectorData data : this.mDataList) {
            if (data.isFirstMidletInSuite() && data.mLaunchPowerOn) {
                midlets.add(data);
            }
        }
        return midlets;
    }

    public JbedSelectorData.SelectorCharSequence[] toFolderCharSequences(List<JbedSelectorData> folders) {
        JbedSelectorData.SelectorCharSequence[] result = new JbedSelectorData.SelectorCharSequence[folders.size()];
        for (int i = 0; i < result.length; i++) {
            JbedSelectorData folder = folders.get(i);
            if (!folder.isFolder()) {
                throw new IllegalArgumentException(" object " + folder + " is not folder type");
            }
            if (JbedConfig.getCustomerName().equals("TW")) {
                StringBuffer fullPath = new StringBuffer();
                fullPath.append(folder.getFullPath());
                fullPath.deleteCharAt(fullPath.length() - 1);
                result[i] = new JbedSelectorData.SelectorCharSequence(fullPath.toString(), folder);
            } else {
                result[i] = new JbedSelectorData.SelectorCharSequence(folder.getFormatedLevelName(), folder);
            }
        }
        return result;
    }

    public JbedSelectorData.SelectorCharSequence[] toSuiteCharSequences(List<JbedSelectorData> suites) {
        JbedSelectorData.SelectorCharSequence[] result = new JbedSelectorData.SelectorCharSequence[suites.size()];
        for (int i = 0; i < result.length; i++) {
            JbedSelectorData suite = suites.get(i);
            if (!suite.isSuite()) {
                throw new IllegalArgumentException(" object " + suite + " is not suite type");
            }
            result[i] = new JbedSelectorData.SelectorCharSequence(suite.mName, suite);
        }
        return result;
    }

    public JbedSelectorData.SelectorCharSequence[] toMidletCharSequences(List<JbedSelectorData> suites) {
        JbedSelectorData.SelectorCharSequence[] result = new JbedSelectorData.SelectorCharSequence[suites.size()];
        for (int i = 0; i < result.length; i++) {
            JbedSelectorData suite = suites.get(i);
            if (!suite.isMidlet()) {
                throw new IllegalArgumentException(" object " + suite + " is not suite type");
            }
            result[i] = new JbedSelectorData.SelectorCharSequence(findMidlet(suite.mRoot, suite.mNo).mName, suite);
        }
        return result;
    }

    public int getPreMIDletWithSameClass(String root, int no, Context context) {
        JbedSelectorData s = findSuite(root);
        if (s != null) {
            JbedSelectorData m = s.getChildren(no - 1);
            for (int i = 1; i < no && i <= s.getChildCount(); i++) {
                if (m != null && m.mEntryClass != null && m.mEntryClass.equals(s.getChildren(i - 1).mEntryClass)) {
                    return i;
                }
            }
            return no;
        }
        return no;
    }
}
