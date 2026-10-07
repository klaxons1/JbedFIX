package com.esmertec.android.jbed;

import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class LogTag {
    private static final String AMSTAG = "jbedams";
    private static final String APPTAG = "jbedapp";
    public static final boolean DEBUG_AMS = false;
    public static final boolean DEBUG_APP = false;
    public static final boolean DEBUG_SERVICE = false;
    private static final String SEVICETAG = "jbedservice";
    private static boolean sAmsDebug = false;
    private static boolean sAmsVerbose = false;
    private static boolean sAmsError = true;
    private static boolean sAmsWarning = true;
    private static boolean sAppDebug = false;
    private static boolean sAppVerbose = false;
    private static boolean sAppWarning = true;
    private static boolean sServiceDebug = true;

    public static void queryLoggingLevel() {
        sAmsDebug = Log.isLoggable(AMSTAG, 3);
        sAmsVerbose = Log.isLoggable(AMSTAG, 2);
        sAmsError = Log.isLoggable(AMSTAG, 6);
        sAmsWarning = Log.isLoggable(AMSTAG, 5);
        sAppDebug = Log.isLoggable(APPTAG, 3);
        sAppVerbose = Log.isLoggable(APPTAG, 2);
        sAppWarning = Log.isLoggable(APPTAG, 5);
        sServiceDebug = Log.isLoggable("jbedservice", 3);
    }

    public static void amsDebug(String tag, String msg) {
        JbedFileLog.info(tag, "AMS " + msg);
        if (sAmsDebug) {
            Log.d(tag, msg);
        }
    }

    public static void amsVerbose(String tag, String msg) {
        JbedFileLog.info(tag, "AMS " + msg);
        if (sAmsVerbose) {
            Log.v(tag, msg);
        }
    }

    public static void amsError(String tag, String msg) {
        JbedFileLog.error(tag, "AMS " + msg, null);
        if (sAmsError) {
            Log.e(tag, msg);
        }
    }

    public static void amsWarning(String tag, String msg) {
        JbedFileLog.warn(tag, "AMS " + msg);
        if (sAmsWarning) {
            Log.w(tag, msg);
        }
    }

    public static void appDebug(String tag, String msg) {
        JbedFileLog.info(tag, "APP " + msg);
        if (sAppDebug) {
            Log.d(tag, msg);
        }
    }

    public static void appVerbose(String tag, String msg) {
        JbedFileLog.info(tag, "APP " + msg);
        if (sAppVerbose) {
            Log.v(tag, msg);
        }
    }

    public static void appWarning(String tag, String msg) {
        JbedFileLog.warn(tag, "APP " + msg);
        if (sAppWarning) {
            Log.w(tag, msg);
        }
    }

    public static void serviceDebug(String tag, String msg) {
        JbedFileLog.info(tag, "SERVICE " + msg);
        if (sServiceDebug) {
            Log.d(tag, msg);
        }
    }
}
