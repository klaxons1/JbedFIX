package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextUtils;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.esmertec.android.jbed.util.FileUtil;
import com.google.android.collect.Lists;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

/* JADX INFO: loaded from: classes.dex */
public class JbedSelectorData implements Parcelable {
    public static final String EXT_NULL = "null";
    public static final String EXT_PROTECT = "protected";
    public static final String EXT_SYSLOCK = "syslocked";
    public static final int FOLDER_NO = -1;
    private static final String FULL_SCREEN_LANDSCAPE_HEIGHT = "320";
    private static final String FULL_SCREEN_LANDSCAPE_WIDTH = "480";
    private static final String FULL_SCREEN_PORTRAIT_HEIGHT = "480";
    private static final String FULL_SCREEN_PORTRAIT_WIDTH = "320";
    private static final String ICON_FILENAME = ".icn";
    private static final String INFO_STORE_PREFIX = "info_";
    private static final String KEY_3G_MIDLET_AFTER_OTA_INSTALL_START = "3G-MIDlet-After-OTA-Install-Start";
    private static final String KEY_ATT_BG_MODE_RUN = "ATT-MIDlet-BG-Mode-Run";
    public static final String KEY_CLDC = "MicroEdition-Configuration";
    private static final String KEY_DISPLAY_NAV_KEYPAD = "LGE-MIDlet-Display-Nav-Keypad";
    private static final String KEY_FULL_SCREEN = "MIDlet-Touch-Support";
    private static final String KEY_LGE_MIDLET_AUTOLANCH_AFTER_INSTALL = "LGE-MIDlet-autolaunch-after-install";
    private static final String KEY_LGE_MIDLET_HEIGHT = "LGE-MIDlet-Height";
    private static final String KEY_LGE_MIDLET_TARGETLCD_HEIGHT = "LGE-MIDlet-TargetLCD-Height";
    private static final String KEY_LGE_MIDLET_TARGETLCD_WIDTH = "LGE-MIDlet-TargetLCD-Width";
    private static final String KEY_LGE_MIDLET_WIDTH = "LGE-MIDlet-Width";
    public static final String KEY_MDIP = "MicroEdition-Profile";
    private static final String KEY_MGR_USER_DENIED = "LGE-MIDlet-Mgr-User-Denied";
    public static final String KEY_MIDLET_DELETE_CONFIRM = "MIDlet-Delete-Confirm";
    public static final String KEY_MIDLET_DESCRIPT = "MIDlet-Description";
    private static final String KEY_MIDLET_FULLSCREEN = "MIDlet-fullscreen";
    public static final String KEY_MIDLET_INFO_URL = "MIDlet-Info-URL";
    public static final String KEY_MIDLET_JAR_URL = "MIDlet-Jar-URL";
    public static final String KEY_MIDLET_NAME = "MIDlet-Name";
    public static final String KEY_MIDLET_VENDOR = "MIDlet-Vendor";
    public static final String KEY_MIDLET_VERSION = "MIDlet-Version";
    private static final String KEY_MVM_PAUSE_BG = "MVM-Pause-Background";
    private static final String KEY_SCALE_UP = "MIDlet-Scaleup-Support";
    public static final String KEY_STORAGE_PHONE_NAME = "Phone";
    private static final String PROPERTIES_FILENAME = "suite.utf";
    public static final int SUITE_NO = 0;
    static final String TAG = "JbedSelectorData";
    private Drawable icon;
    public boolean mAllowRunBackground;
    List<JbedSelectorData> mChildren;
    public String mDisplayInfo;
    public String mDomain;
    public String mDrmIntervalEverLaunched;
    public int mDrmMethodType;
    String mDrmPending;
    String mDrmProtected;
    public String mEntryClass;
    String mFileRoot;
    public boolean mHasShortCut;
    public long mInstallTime;
    public boolean mIsExpired;
    public boolean mIsHidden;
    public boolean mIsPaused;
    public boolean mIsPreInstall;
    public boolean mIsRunning;
    public boolean mLaunchPowerOn;
    public boolean mModifiableContent;
    public final String mName;
    public int mNo;
    JbedSelectorData mParent;
    public String mProtectExt;
    public String mRemovable;
    public String mRoot;
    public int mSize;
    public final String mStoragePath;
    public String mUid;
    public String mVendor;
    public static Comparator<JbedSelectorData> NAME_ORDER = new Comparator<JbedSelectorData>() { // from class: com.esmertec.android.jbed.ams.JbedSelectorData.1
        @Override // java.util.Comparator
        public int compare(JbedSelectorData m1, JbedSelectorData m2) {
            int ret = JbedSelectorData.sortFolderToTop(m1, m2);
            return ret == 0 ? m1.mName.compareToIgnoreCase(m2.mName) : ret;
        }
    };
    public static Comparator<JbedSelectorData> NAME_REVERSE_ORDER = new Comparator<JbedSelectorData>() { // from class: com.esmertec.android.jbed.ams.JbedSelectorData.2
        @Override // java.util.Comparator
        public int compare(JbedSelectorData m1, JbedSelectorData m2) {
            int ret = JbedSelectorData.sortFolderToTop(m2, m1);
            return ret == 0 ? m1.mName.compareToIgnoreCase(m2.mName) : ret;
        }
    };
    public static Comparator<JbedSelectorData> INSTALLTIME_ORDER = new Comparator<JbedSelectorData>() { // from class: com.esmertec.android.jbed.ams.JbedSelectorData.3
        @Override // java.util.Comparator
        public int compare(JbedSelectorData m1, JbedSelectorData m2) {
            int ret = JbedSelectorData.sortFolderToTop(m1, m2);
            return ret == 0 ? (int) (m1.mInstallTime - m2.mInstallTime) : ret;
        }
    };
    public static Comparator<JbedSelectorData> SIZE_ORDER = new Comparator<JbedSelectorData>() { // from class: com.esmertec.android.jbed.ams.JbedSelectorData.4
        @Override // java.util.Comparator
        public int compare(JbedSelectorData m1, JbedSelectorData m2) {
            int ret = JbedSelectorData.sortFolderToTop(m1, m2);
            if (ret == 0) {
                return (m1.isMidlet() ? m1.mParent.mSize : m1.mSize) - (m2.isMidlet() ? m2.mParent.mSize : m2.mSize);
            }
            return ret;
        }
    };
    private static final HashMap<String, Integer> mCachedSizeMap = new HashMap<>();
    public static final Parcelable.Creator<JbedSelectorData> CREATOR = new Parcelable.Creator<JbedSelectorData>() { // from class: com.esmertec.android.jbed.ams.JbedSelectorData.5
        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public JbedSelectorData createFromParcel(Parcel source) {
            return new JbedSelectorData(source);
        }

        /* JADX WARN: Can't rename method to resolve collision */
        @Override // android.os.Parcelable.Creator
        public JbedSelectorData[] newArray(int size) {
            return new JbedSelectorData[size];
        }
    };

    public static int sortFolderToTop(JbedSelectorData m1, JbedSelectorData m2) {
        if (m1.isFolder() && !m2.isFolder()) {
            return -1;
        }
        if (m2.isFolder() && !m1.isFolder()) {
            return 1;
        }
        if (m1.isFolder() && m2.isFolder()) {
            return m1.mName.compareToIgnoreCase(m2.mName);
        }
        return 0;
    }

    public JbedSelectorData(String root, int no) {
        this.mNo = -1;
        this.mChildren = Lists.newArrayList();
        this.mModifiableContent = true;
        this.mProtectExt = null;
        this.mHasShortCut = false;
        this.mAllowRunBackground = false;
        this.mDisplayInfo = null;
        this.mStoragePath = null;
        this.mName = null;
        this.mRoot = root;
        this.mNo = no;
        this.mUid = UUID.randomUUID().toString();
    }

    public JbedSelectorData(String storagePath, String name) {
        this.mNo = -1;
        this.mChildren = Lists.newArrayList();
        this.mModifiableContent = true;
        this.mProtectExt = null;
        this.mHasShortCut = false;
        this.mAllowRunBackground = false;
        this.mDisplayInfo = null;
        this.mStoragePath = storagePath.charAt(storagePath.length() - 1) != File.separatorChar ? storagePath + File.separatorChar : storagePath;
        this.mName = name;
        this.mUid = UUID.randomUUID().toString();
    }

    public JbedSelectorData(Parcel source) {
        this.mNo = -1;
        this.mChildren = Lists.newArrayList();
        this.mModifiableContent = true;
        this.mProtectExt = null;
        this.mHasShortCut = false;
        this.mAllowRunBackground = false;
        this.mDisplayInfo = null;
        this.mRoot = source.readString();
        this.mNo = source.readInt();
        this.mName = source.readString();
        this.mStoragePath = source.readString();
        this.mFileRoot = source.readString();
        this.mVendor = source.readString();
        this.mInstallTime = source.readLong();
        this.mSize = source.readInt();
        this.mDomain = source.readString();
        this.mRemovable = source.readString();
        this.mDrmProtected = source.readString();
        this.mDrmPending = source.readString();
        this.mDrmIntervalEverLaunched = source.readString();
        int hidden = source.readInt();
        this.mIsHidden = hidden == 1;
        int pause = source.readInt();
        this.mIsPaused = pause == 1;
        ArrayList<JbedSelectorData> arrayListNewArrayList = Lists.newArrayList();
        source.readTypedList(arrayListNewArrayList, CREATOR);
        for (JbedSelectorData midlet : arrayListNewArrayList) {
            addChild(midlet);
        }
        this.mUid = UUID.randomUUID().toString();
    }

    public boolean isSuite() {
        return this.mNo == 0;
    }

    public boolean isFolder() {
        return this.mNo == -1;
    }

    public boolean isMidlet() {
        return this.mNo > 0;
    }

    public boolean isFirstMidletInSuite() {
        return this.mNo == 1;
    }

    public int getChildCount() {
        return this.mChildren.size();
    }

    public List<JbedSelectorData> getAllChildren() {
        return this.mChildren;
    }

    String[] getHierarchyNames() {
        List<String> names = Lists.newArrayList();
        names.add(this.mName);
        for (JbedSelectorData parent = this.mParent; parent != null; parent = parent.mParent) {
            names.add(parent.mName);
        }
        String[] result = new String[names.size()];
        int i = result.length - 1;
        int level = 0;
        while (i >= 0) {
            result[level] = names.get(i);
            i--;
            level++;
        }
        return result;
    }

    public boolean isRemovable() {
        return this.mRemovable == null || !this.mRemovable.equals("N");
    }

    public boolean isDrmProtected() {
        return this.mDrmProtected != null && this.mDrmProtected.equals("Y");
    }

    public boolean isHidden() {
        return this.mIsHidden;
    }

    public boolean isDrmPending() {
        return this.mDrmPending != null && this.mDrmPending.equals("Y");
    }

    public boolean isDrmIntervalEverLaunched() {
        return this.mDrmIntervalEverLaunched != null && this.mDrmIntervalEverLaunched.equals("Y");
    }

    private String getProperty(String key) throws Throwable {
        File suiteUtfFile = new File(getInfoStoreRoot() + PROPERTIES_FILENAME);
        DataInputStream in = null;
        String res = null;
        try {
            DataInputStream in2 = new DataInputStream(new FileInputStream(suiteUtfFile));
            try {
                int size = in2.readInt();
                for (int i = 0; i < size; i++) {
                    String k = in2.readUTF();
                    String v = in2.readUTF();
                    if (k.equals(key)) {
                        res = v;
                        break;
                    }
                }
                try {
                    in2.close();
                } catch (IOException e) {
                }
            } catch (IOException e2) {
                in = in2;
                try {
                    in.close();
                } catch (IOException e3) {
                }
            } catch (Throwable th) {
                th = th;
                in = in2;
                try {
                    in.close();
                } catch (IOException e4) {
                }
                throw th;
            }
        } catch (IOException e5) {
        } catch (Throwable th2) {
            // Preserve the original best-effort failure behavior.
        }
        return res;
    }

    public boolean isAllowRunBackground() throws Throwable {
        String value = getProperty(KEY_ATT_BG_MODE_RUN);
        this.mAllowRunBackground = value != null && value.toLowerCase().equals("yes");
        return this.mAllowRunBackground;
    }

    private String getInfoStoreRoot() {
        return this.mStoragePath + this.mRoot + INFO_STORE_PREFIX;
    }

    public String getIconPath() {
        String path = getInfoStoreRoot() + this.mNo + ICON_FILENAME;
        String alterPath = getInfoStoreRoot() + "0" + ICON_FILENAME;
        if (new File(path).exists()) {
            return path;
        }
        return new File(alterPath).exists() ? alterPath : "";
    }

    public Drawable getIcon(Context context) {
        if (this.icon == null) {
            String path = getIconPath();
            if (TextUtils.isEmpty(path)) {
                if (JbedConfig.Ams.isCustomIconEnable()) {
                    return null;
                }
                this.icon = context.getPackageManager().getDefaultActivityIcon();
            } else {
                this.icon = BitmapDrawable.createFromPath(path);
            }
        }
        return this.icon;
    }

    public JbedSelectorData getChildren(int index) {
        return this.mChildren.get(index);
    }

    public void addChild(JbedSelectorData midlet) {
        midlet.mParent = this;
        this.mChildren.add(midlet);
    }

    public String getInstallTimeText() {
        if (isMidlet()) {
            return this.mParent.getInstallTimeText();
        }
        if (isSuite()) {
            Date date = new Date(this.mInstallTime);
            DateFormat dateFormat = DateFormat.getDateInstance(3);
            return dateFormat.format(date);
        }
        return "";
    }

    public String getSizeText(Context context) {
        if (isMidlet()) {
            return this.mParent.getSizeText(context);
        }
        if (isSuite()) {
            return getSizeStr(this.mSize);
        }
        return "";
    }

    private String getSizeStr(long size) {
        if (size < 1024) {
            return String.valueOf(size) + "B";
        }
        long size2 = size * 10;
        long kb = size2 >> 10;
        long rem = size2 - (kb << 10);
        if (kb < 1024) {
            if (rem > 512) {
                kb++;
            }
            float fResult = kb / 10.0f;
            String retStr = "" + String.valueOf(fResult) + "KB";
            return retStr;
        }
        long mb = kb >> 10;
        long rem2 = size2 - (mb << 20);
        if (rem2 >= 512) {
            mb++;
        }
        float fResult2 = mb / 10.0f;
        String retStr2 = "" + String.valueOf(fResult2) + "MB";
        return retStr2;
    }

    public String getVendorText() {
        if (isMidlet()) {
            return this.mParent.getVendorText();
        }
        return this.mVendor == null ? "" : this.mVendor;
    }

    private String getTextByKey(String key) {
        if (isMidlet()) return this.mParent.getTextByKey(key);
        File suiteUtfFile = new File(getInfoStoreRoot() + PROPERTIES_FILENAME);
        try (DataInputStream in = new DataInputStream(new FileInputStream(suiteUtfFile))) {
            for (int i = in.readInt(); i > 0; i--) {
                String property = in.readUTF();
                String value = in.readUTF();
                if (key.equals(property)) return value;
            }
        } catch (IOException e) {
            Log.w(TAG, "Unable to read MIDlet properties", e);
        }
        return null;
    }

    public String getDeleteConfirmText() {
        return getTextByKey(KEY_MIDLET_DELETE_CONFIRM);
    }

    public String getMgrUserDenied() {
        return getTextByKey(KEY_MGR_USER_DENIED);
    }

    public String getVersionText() {
        return getTextByKey(KEY_MIDLET_VERSION);
    }

    public String getDescription() {
        return getTextByKey(KEY_MIDLET_DESCRIPT);
    }

    public String getInfoUrl() {
        return getTextByKey(KEY_MIDLET_INFO_URL);
    }

    public String getNameText() {
        String nameText = this.mName;
        if (isSuite()) {
            return nameText + "(" + this.mChildren.size() + ")";
        }
        return nameText;
    }

    public String getSimpleStorageName() {
        return (this.mStoragePath.startsWith(new StringBuilder().append(File.separator).append(JbedFileManager.EXTERNAL_STORAGE_NAME).toString()) || JbedFileManager.EXTERNAL_STORAGE_NAME.equals(this.mFileRoot)) ? JbedFileManager.EXTERNAL_STORAGE_NAME : KEY_STORAGE_PHONE_NAME;
    }

    public String getParentUid() {
        if (this.mParent != null) {
            return this.mParent.mUid;
        }
        return null;
    }

    public int getLevel() {
        int result = 0;
        for (JbedSelectorData parent = this.mParent; parent != null; parent = parent.mParent) {
            result++;
        }
        return result;
    }

    public String getFormatedLevelName() {
        StringBuffer result = new StringBuffer();
        int level = getLevel();
        for (int i = 1; i < level; i++) {
            result.insert(0, "/..");
        }
        if (level > 0) {
            result.append(JbedSelector.ROOT_FOLDER_NAME);
        }
        result.append(this.mName);
        return result.toString();
    }

    public String getATTBGModeRun() {
        return getTextByKey(KEY_ATT_BG_MODE_RUN);
    }

    public String getFullPath() {
        if (isMidlet()) {
            throw new UnsupportedOperationException("Midlet type can't support full path");
        }
        StringBuffer result = new StringBuffer();
        result.append(this.mName);
        for (JbedSelectorData parent = this.mParent; parent != null; parent = parent.mParent) {
            if (!parent.mName.endsWith(File.separator)) {
                result.insert(0, File.separatorChar);
            }
            result.insert(0, parent.mName);
        }
        if (result.charAt(0) != File.separatorChar) {
            result.insert(0, File.separatorChar);
        }
        if (result.charAt(result.length() - 1) != File.separatorChar) {
            result.append(File.separatorChar);
        }
        return result.toString();
    }

    public boolean isOnSdcard() {
        return this.mFileRoot != null && this.mFileRoot.equals(JbedFileManager.EXTERNAL_STORAGE_NAME);
    }

    public String toString() {
        String prefix = "  +--Midlet ";
        if (isSuite()) {
            prefix = "Suite  ";
        }
        return prefix + "[" + this.mName + "] num=" + this.mNo + " storage=" + this.mStoragePath + " fileRoot=" + this.mFileRoot + " uid=" + this.mUid;
    }

    public boolean equals(Object oMidlet) {
        if (oMidlet == null || !(oMidlet instanceof JbedSelectorData)) {
            return false;
        }
        JbedSelectorData other = (JbedSelectorData) oMidlet;
        if (other == this || other.mUid.equals(this.mUid)) {
            return true;
        }
        if (other.isFolder() && isFolder()) {
            return other.mName.equals(this.mName);
        }
        return other.mRoot.equals(this.mRoot) && other.mNo == this.mNo;
    }

    public void calculateSize(boolean isforced) {
        if (mCachedSizeMap.containsKey(this.mRoot) && !isforced) {
            this.mSize = mCachedSizeMap.get(this.mRoot).intValue();
            return;
        }
        this.mSize = FileUtil.getFilesSizeWithPrefix(this.mStoragePath, this.mRoot);
        if (this.mParent != null && this.mParent.mFileRoot != null) {
            this.mSize += FileUtil.getFilesSizeWithPrefix(this.mParent.mFileRoot + "java" + File.separator + "Installed" + File.separator, this.mRoot);
        }
        mCachedSizeMap.put(this.mRoot, Integer.valueOf(this.mSize));
    }

    @Override // android.os.Parcelable
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.mRoot);
        dest.writeInt(this.mNo);
        dest.writeString(this.mName);
        dest.writeString(this.mStoragePath);
        dest.writeString(this.mFileRoot);
        dest.writeString(this.mVendor);
        dest.writeLong(this.mInstallTime);
        dest.writeInt(this.mSize);
        dest.writeString(this.mDomain);
        dest.writeString(this.mRemovable);
        dest.writeString(this.mDrmProtected);
        dest.writeString(this.mDrmPending);
        dest.writeString(this.mDrmIntervalEverLaunched);
        int hidden = this.mIsHidden ? 1 : 0;
        dest.writeInt(hidden);
        int pause = this.mIsPaused ? 1 : 0;
        dest.writeInt(pause);
        dest.writeTypedList(this.mChildren);
    }

    @Override // android.os.Parcelable
    public int describeContents() {
        return 0;
    }

    public boolean isDamaged() {
        String fullPath;
        if (this.mFileRoot != null && this.mFileRoot.equals(JbedFileManager.EXTERNAL_STORAGE_NAME)) {
            fullPath = JbedFileManager.EXTERNAL_STORAGE_NAME + "java" + File.separatorChar + "Installed" + File.separatorChar + this.mRoot + ".obj";
        } else {
            fullPath = JbedProvider.Settings.DEFAULT_BASE_DIR + this.mRoot + ".obj";
        }
        return !new File(fullPath).exists();
    }

    private String getInfoSuiteValue(String wantedKey) {
        File infoFile = new File(JbedProvider.Settings.DEFAULT_BASE_DIR + this.mRoot + "info_suite.utf");
        try (DataInputStream in = new DataInputStream(new FileInputStream(infoFile))) {
            for (int i = in.readInt(); i > 0; i--) {
                String key = in.readUTF();
                String value = in.readUTF();
                if (wantedKey.equals(key)) return value;
            }
        } catch (IOException e) {
            Log.w(TAG, "Unable to read MIDlet display settings", e);
        }
        return null;
    }

    public boolean isFullScreen() {
        String value;
        if ("TW".equals(JbedConfig.getCustomerName())) {
            value = getInfoSuiteValue(KEY_FULL_SCREEN);
            return "true".equalsIgnoreCase(value);
        }
        if ("PK".equals(JbedConfig.getCustomerName())) {
            value = getInfoSuiteValue(KEY_MIDLET_FULLSCREEN);
            return "true".equalsIgnoreCase(value);
        }
        value = getInfoSuiteValue(KEY_DISPLAY_NAV_KEYPAD);
        if (value != null) return JbedProvider.Midlets.NO.equalsIgnoreCase(value);
        String width = getInfoSuiteValue(KEY_LGE_MIDLET_WIDTH);
        String height = getInfoSuiteValue(KEY_LGE_MIDLET_HEIGHT);
        String targetWidth = getInfoSuiteValue(KEY_LGE_MIDLET_TARGETLCD_WIDTH);
        String targetHeight = getInfoSuiteValue(KEY_LGE_MIDLET_TARGETLCD_HEIGHT);
        return ("480".equals(width) && "320".equals(height))
                || ("480".equals(targetWidth) && "320".equals(targetHeight))
                || ("320".equals(width) && "480".equals(height))
                || ("320".equals(targetWidth) && "480".equals(targetHeight));
    }

    public boolean isAutoRun() {
        String value = getInfoSuiteValue(KEY_LGE_MIDLET_AUTOLANCH_AFTER_INSTALL);
        if (value == null) value = getInfoSuiteValue(KEY_3G_MIDLET_AFTER_OTA_INSTALL_START);
        return "YES".equalsIgnoreCase(value);
    }

    public void clearState() {
        if (isMidlet()) {
            this.mIsPaused = false;
            this.mIsRunning = false;
        } else if (isSuite()) {
            for (JbedSelectorData children : this.mChildren) {
                children.clearState();
            }
        }
    }

    public static class SelectorCharSequence implements CharSequence {
        public JbedSelectorData mData;
        private String mDisplayText;

        public SelectorCharSequence(String displayText, JbedSelectorData data) {
            this.mDisplayText = displayText;
            this.mData = data;
        }

        @Override // java.lang.CharSequence
        public char charAt(int index) {
            return this.mDisplayText.charAt(index);
        }

        @Override // java.lang.CharSequence
        public int length() {
            return this.mDisplayText.length();
        }

        @Override // java.lang.CharSequence
        public CharSequence subSequence(int start, int end) {
            return this.mDisplayText.subSequence(start, end);
        }

        @Override // java.lang.CharSequence
        public String toString() {
            return this.mDisplayText;
        }
    }

    public boolean isSuiteContainRunningMidlet() {
        if (!isSuite()) {
            return false;
        }
        for (JbedSelectorData midlet : this.mChildren) {
            if (midlet.mIsRunning) {
                return true;
            }
        }
        return false;
    }

    public boolean isFolderContainRunningMidlet() {
        if (!isFolder()) {
            return false;
        }
        for (JbedSelectorData suite : this.mChildren) {
            if (suite.isSuiteContainRunningMidlet()) {
                return true;
            }
        }
        return false;
    }

    public boolean isProtected() {
        return EXT_PROTECT.equals(this.mProtectExt);
    }

    public boolean isSystemLock() {
        return EXT_SYSLOCK.equals(this.mProtectExt);
    }

    public boolean isFolderContainProtectedSuite() {
        if (!isFolder()) {
            return false;
        }
        for (JbedSelectorData suite : this.mChildren) {
            if (suite.isProtected()) {
                return true;
            }
        }
        return false;
    }

    public boolean isFolderContainSystemLockedSuite() {
        if (!isFolder()) {
            return false;
        }
        for (JbedSelectorData suite : this.mChildren) {
            if (suite.isSystemLock()) {
                return true;
            }
        }
        return false;
    }

    public String getScaleProperty() {
        return getInfoSuiteValue(KEY_SCALE_UP);
    }

}
