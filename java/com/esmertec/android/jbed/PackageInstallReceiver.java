package com.esmertec.android.jbed;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import java.io.File;

/* JADX INFO: loaded from: classes.dex */
public class PackageInstallReceiver extends BroadcastReceiver {
    private static final boolean DEBUG = true;
    private static final String TAG = "PackageInstallReceiver";
    private final String genDir = "/sdcard/tmpForGenApk/";

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.d(TAG, "onReceive receive action " + action);
        if (action.equals("android.intent.action.PACKAGE_ADDED")) {
            Log.d(TAG, "add package:" + intent.getDataString());
            String tmp = intent.getDataString();
            if (tmp.indexOf("com.myriad.jbed.android.midlet") != -1) {
                File tmpGenDir = new File("/sdcard/tmpForGenApk/");
                if (tmpGenDir.exists()) {
                    Log.d(TAG, "tmpGenDir.exists()");
                    File[] tmpFiles = tmpGenDir.listFiles();
                    for (File tmpFile : tmpFiles) {
                        Log.d(TAG, "delete" + tmpFile.getName());
                        tmpFile.delete();
                    }
                }
            }
        }
    }
}
