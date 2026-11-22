package com.esmertec.android.jbed;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class BootCompleteReceiver extends BroadcastReceiver {
    private static final String TAG = "BootCompleteReceiver";

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        Log.i(TAG, "onReceive receive action " + action);
        if (action.equals("android.intent.action.BOOT_COMPLETED")) {
            Log.i(TAG, "start PushJbedAlarmManager");
            PushJbedAlarmManager.checkAndstartAlarm(context);
        }
    }
}
