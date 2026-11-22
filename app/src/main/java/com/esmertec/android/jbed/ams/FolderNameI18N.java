package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.telephony.TelephonyManager;

/* JADX INFO: compiled from: AmsActivity.java */
/* JADX INFO: loaded from: classes.dex */
class FolderNameI18N {
    public static final String FOLDER_NAME_DOWNLOAD_APPLICATIONS = "Download Applications";
    public static final String FOLDER_NAME_DOWNLOAD_GAMES = "Download Games";
    public static final int FOLDER_NUMBERS = 2;
    public static final int REQUEST_FOLDER_DOWNLOAD_APPS = 2;
    public static final int REQUEST_FOLDER_DOWNLOAD_GAMES = 1;
    public static final String URL_KR = "http://wap.lge.com";
    private Context mContext;
    private TelephonyManager telMgr;

    public FolderNameI18N(Context context) {
        this.mContext = context;
        this.telMgr = (TelephonyManager) this.mContext.getSystemService("phone");
    }

    public String getI18NStrings(int whichfolder) {
        if (this.telMgr == null) {
            return whichfolder == 1 ? FOLDER_NAME_DOWNLOAD_GAMES : FOLDER_NAME_DOWNLOAD_APPLICATIONS;
        }
        String imsi = this.telMgr.getSubscriberId();
        if (imsi == null) {
            return whichfolder == 1 ? FOLDER_NAME_DOWNLOAD_GAMES : FOLDER_NAME_DOWNLOAD_APPLICATIONS;
        }
        String mcc = imsi.substring(0, 3);
        if (mcc == null) {
            return whichfolder == 1 ? FOLDER_NAME_DOWNLOAD_GAMES : FOLDER_NAME_DOWNLOAD_APPLICATIONS;
        }
        if (mcc.equals("206")) {
            if (whichfolder == 1) {
                return "Games";
            }
            return null;
        }
        if (mcc.equals("228")) {
            if (whichfolder == 1) {
                return "Games";
            }
            return null;
        }
        if (mcc.equals("214")) {
            return whichfolder == 1 ? null : null;
        }
        if (mcc.equals("208")) {
            if (whichfolder == 1) {
                return "Plus de jeux";
            }
            return null;
        }
        if (mcc.equals("450")) {
            return whichfolder == 1 ? FOLDER_NAME_DOWNLOAD_GAMES : FOLDER_NAME_DOWNLOAD_APPLICATIONS;
        }
        return whichfolder == 1 ? FOLDER_NAME_DOWNLOAD_GAMES : FOLDER_NAME_DOWNLOAD_APPLICATIONS;
    }

    public String getFolderUrl() {
        String imsi;
        String mcc;
        if (this.telMgr != null && (imsi = this.telMgr.getSubscriberId()) != null && (mcc = imsi.substring(0, 3)) != null) {
            if (!mcc.equals("206") && !mcc.equals("228")) {
                if (mcc.equals("214")) {
                    return null;
                }
                if (mcc.equals("208")) {
                    return "http://jeux2.mob2.orange.fr";
                }
                return mcc.equals("450") ? URL_KR : URL_KR;
            }
            return "http://mobile.orange.ch/games";
        }
        return URL_KR;
    }
}
