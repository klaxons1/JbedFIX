package com.esmertec.android.jbed;

import android.content.Context;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/* JADX INFO: loaded from: classes.dex */
public class JbedConfig {
    private static final String CONFIG_PROPERTIES_FILE = "config.properties";
    private static JbedConfig INSTANCE = null;
    private static final String TAG = "JbedConfig";
    private static Context mContext;
    private Properties mConfigProperties;

    public static void init(Context context) {
        INSTANCE = new JbedConfig();
        JbedConfig jbedConfig = INSTANCE;
        mContext = context;
    }

    private Properties getProperties(String fileName) {
        Properties result = new Properties();
        InputStream in = null;
        try {
            in = mContext.getAssets().open(fileName);
            result.load(in);
        } catch (IOException e) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, "ERROR: fail to open asset build file " + fileName);
            }
        } finally {
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e2) {
                }
            }
        }
        return result;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static Properties getProperties(File file) {
        Properties result = new Properties();
        try (InputStream in = new FileInputStream(file)) {
            result.load(in);
        } catch (IOException e) {
            if (Log.isLoggable(TAG, Log.WARN)) {
                Log.w(TAG, "Failed to read config file " + file.getName(), e);
            }
        }
        return result;
    }

    private Properties getConfigProperties() {
        if (this.mConfigProperties == null) {
            this.mConfigProperties = getProperties(CONFIG_PROPERTIES_FILE);
        }
        return this.mConfigProperties;
    }

    public static String getBuildP4No() {
        return "195487";
    }

    public static String getBuildDate() {
        return "20110713";
    }

    public static String getBuildVersion() {
        return getBuildDate() + "-" + getBuildP4No();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static String getString(String name) {
        if (INSTANCE == null) {
            if (Log.isLoggable(TAG, 3)) {
                Log.w(TAG, "WARNING:getString, INSTANCE is null");
            }
            return "";
        }
        String result = INSTANCE.getConfigProperties().getProperty(name);
        if (result != null) {
            return removeQuotation(result);
        }
        if (Log.isLoggable(TAG, 3)) {
            Log.w(TAG, "WARNING:getString, property:" + name + " is null");
        }
        return "";
    }

    private static String removeQuotation(String value) {
        if (value.startsWith("\"") && value.endsWith("\"")) {
            return value.substring(1, value.length() - 1);
        }
        return value;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static boolean getBoolean(String name) {
        String value = getString(name);
        return value != null && value.equalsIgnoreCase("true");
    }

    private static int getInteger(String name) {
        String value = getString(name);
        if (value.equals("")) {
            return 0;
        }
        return Integer.parseInt(value);
    }

    public static String getUserAgent() {
        try {
            Uri UADATA_TABLE_URI = Uri.parse("content://customization_settings/SettingTable/force_change_J2ME");
            Bundle uaDataBundle = JbedCustomizationUtils.loadCustomizationData(mContext, UADATA_TABLE_URI, null);
            return JbedCustomizationUtils.getUaData(uaDataBundle, "ua_string");
        } catch (RuntimeException e) {
            String userAgentStr = null;
            StringBuilder sb = new StringBuilder();
            JbedConfig jbedConfig = INSTANCE;
            File configFile = new File(sb.append(JbedSettings.getInstance(mContext).getRootDir()).append(CONFIG_PROPERTIES_FILE).toString());
            if (configFile.exists()) {
                userAgentStr = getProperties(configFile).getProperty("USER.AGENT");
            }
            return userAgentStr != null ? userAgentStr : getString("USER.AGENT");
        }
    }

    private static boolean isDebugSample1() {
        return getBoolean("DEBUG");
    }

    private static boolean isDebugSample2() {
        return false;
    }

    public static String getHeapSizeString() {
        return getString("HEAPSIZE");
    }

    public static int getFontSize() {
        return getInteger("DISPLAY.FONT.SIZE.SMALL") + (getInteger("DISPLAY.FONT.SIZE.NORMAL") << 8) + (getInteger("DISPLAY.FONT.SIZE.LARGE") << 16);
    }

    public static boolean isSupportSoftKeyboard() {
        return getBoolean("SOFT.KEYBOARD.SUPPORT");
    }

    public static int getToggleSoftInputDelay() {
        return getInteger("TOGGLE.SOFTINPUT.DELAY");
    }

    public static int getDisplayPortraitWidth() {
        return getInteger("DISPLAY.PORTRAIT.WIDTH");
    }

    public static int getDisplayPortraitHeight() {
        return getInteger("DISPLAY.PORTRAIT.HEIGHT");
    }

    public static int getDisplayLandscapeWidth() {
        return getInteger("DISPLAY.LANDSCAPE.WIDTH");
    }

    public static int getDisplayLandscapeHeight() {
        return getInteger("DISPLAY.LANDSCAPE.HEIGHT");
    }

    public static boolean launchPowerOn() {
        return getBoolean("LAUNCH.POWER.ON");
    }

    public static boolean isBlockVMAfterPhoneHangup() {
        return getBoolean("BLOCKVM.AFTER.PHONE.HANGUP.ENABLE");
    }

    public static String getCustomerName() {
        return getString("CUSTOMER.NAME");
    }

    public static boolean isCustomiseNetworkErrorNotify() {
        return "HTC".equals(getCustomerName());
    }

    public static String getExcludeSearchFolder() {
        return getString("SEARCHFOLDER.EXCLUDE");
    }

    public static class Ams {
        public static boolean isGenApk() {
            return JbedConfig.getBoolean("AMS.GENAPK");
        }

        public static boolean isMidletInFolderOnly() {
            return JbedConfig.getBoolean("AMS.MIDLET.IN.FOLDER.ONLY");
        }

        public static boolean unlimitMidletInDefaultFolder() {
            return JbedConfig.getBoolean("AMS.UNLIMIT.MIDLET.IN.DEFAULTFOLDER");
        }

        public static boolean isUsingSpecialIcon() {
            return JbedConfig.getBoolean("AMS.USING.SPECIAL.ICONS");
        }

        public static boolean isShowToastEnabled() {
            return JbedConfig.getBoolean("SHOW.TOAST.AFTER.REMOVE");
        }

        public static boolean isCustomIconEnable() {
            return JbedConfig.getBoolean("AMS.CUSTOMICON.ENABLE");
        }

        public static boolean isNotifyDrmConstraintEnable() {
            return JbedConfig.getBoolean("AMS.CONSTRAINT.NOTIFY");
        }
    }

    public static class Menu {
        public static boolean isRotationEnabled() {
            return JbedConfig.getBoolean("MENU.ROTATION.ENABLE");
        }

        public static boolean isMoveDisabled() {
            return JbedConfig.getBoolean("MENU.MOVE.DISABLE");
        }

        public static boolean isSortDisabled() {
            return JbedConfig.getBoolean("MENU.SORT.DISABLE");
        }

        public static boolean isRemoveMultiEnabled() {
            return JbedConfig.getBoolean("MENU.REMOVE_MULTI.ENABLE");
        }

        public static boolean isRenameDisabled() {
            return JbedConfig.getBoolean("MENU.RENAME.DISABLE");
        }

        public static boolean isCreateFolderDisabled() {
            return JbedConfig.getBoolean("MENU.CREATE_FOLDER.DISABLE");
        }

        public static boolean isInstallDisabled() {
            String propString = "";
            if (Log.isLoggable(JbedConfig.TAG, 3)) {
                StringBuilder sbAppend = new StringBuilder().append("String=");
                JbedConfig unused = JbedConfig.INSTANCE;
                Log.d(JbedConfig.TAG, sbAppend.append(JbedSettings.getInstance(JbedConfig.mContext).getRootDir()).append(JbedConfig.CONFIG_PROPERTIES_FILE).toString());
            }
            StringBuilder sb = new StringBuilder();
            JbedConfig unused2 = JbedConfig.INSTANCE;
            File configFile = new File(sb.append(JbedSettings.getInstance(JbedConfig.mContext).getRootDir()).append(JbedConfig.CONFIG_PROPERTIES_FILE).toString());
            if (configFile.exists()) {
                propString = JbedConfig.getProperties(configFile).getProperty("MENU.INSTALL.DISABLE");
                if (Log.isLoggable(JbedConfig.TAG, 3)) {
                    Log.d(JbedConfig.TAG, "propString d1=" + propString);
                }
            }
            if (propString == null || "".equals(propString)) {
                propString = JbedConfig.getString("MENU.INSTALL.DISABLE");
            }
            if (Log.isLoggable(JbedConfig.TAG, 3)) {
                Log.d(JbedConfig.TAG, "propString=" + propString);
            }
            if (propString == null || "".equals(propString)) {
                return false;
            }
            return propString.equalsIgnoreCase("true");
        }

        public static boolean isApnDisabled() {
            return JbedConfig.getBoolean("MENU.APN.DISABLE");
        }

        public static boolean isAboutDisabled() {
            return JbedConfig.getBoolean("MENU.ABOUT.DISABLE");
        }

        public static boolean isRemoveDisabled() {
            return JbedConfig.getBoolean("MENU.REMOVE.DISABLE");
        }

        public static boolean isRemoveAllDisabled() {
            return JbedConfig.getBoolean("MENU.REMOVEALL.DISABLE");
        }

        public static boolean isUpFolderDisabled() {
            return JbedConfig.getBoolean("MENU.UPFOLDER.DISABLE");
        }

        public static boolean isUpdateDisabled() {
            return JbedConfig.getBoolean("MENU.UPDATE.DISABLE");
        }

        public static boolean isExitDisabled() {
            return JbedConfig.getBoolean("MENU.EXIT.DISABLE");
        }

        public static boolean isStorateSettingEnable() {
            return JbedConfig.getBoolean("MENU.STORAGE_SETTING.ENABLE");
        }

        public static boolean isReconfigEnable() {
            return JbedConfig.getBoolean("MENU.RECONFIGURATION");
        }

        public static boolean isReconfigForAdamEnable() {
            return JbedConfig.getBoolean("MENU.RECONFIGURATION.FOR.ADAM");
        }

        public static boolean isAllowedHiddenMenu() {
            JbedConfig unused = JbedConfig.INSTANCE;
            return JbedSettings.getInstance(JbedConfig.mContext).isAllowedHiddenMenu();
        }

        public static boolean isAMSListLaunch() {
            JbedConfig unused = JbedConfig.INSTANCE;
            return JbedSettings.getInstance(JbedConfig.mContext).isAMSListLaunch();
        }

        public static boolean isTasksDisabled() {
            return JbedConfig.getBoolean("MENU.TASKS.DISABLE");
        }
    }

    public static class ListItem {
        public static boolean isDateDisabled() {
            return JbedConfig.getBoolean("LISTITEM.DATE.DISABLE");
        }

        public static boolean isSizeDisabled() {
            return JbedConfig.getBoolean("LISTITEM.SIZE.DISABLE");
        }

        public static boolean isVendorDisabled() {
            return JbedConfig.getBoolean("LISTITEM.VENDOR.DISABLE");
        }
    }

    public static boolean isJadShowNecessary() {
        return getBoolean("JADINFO.SHOWNECESSARY");
    }
}
