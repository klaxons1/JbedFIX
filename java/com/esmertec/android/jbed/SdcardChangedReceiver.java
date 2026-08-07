package com.esmertec.android.jbed;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.os.IBinder;
import android.util.Log;
import com.esmertec.android.jbed.ams.JbedSelector;

/* JADX INFO: loaded from: classes.dex */
public class SdcardChangedReceiver extends BroadcastReceiver {
    private static final boolean DEBUG = true;
    static final String TAG = "SdcardChangedReceiver";

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        Uri uri = intent.getData();
        String externalStoragePath = Environment.getExternalStorageDirectory().getPath();
        if (uri.getScheme().equals("file") && externalStoragePath.equals(uri.getPath())) {
            LogTag.serviceDebug(TAG, "SdcardChangedReceiver start to parse selector files and save them to db!!!");
            JbedSelector selector = new JbedSelector(JbedSettings.getInstance(context).getBaseDir());
            Intent serviceIntent = new Intent();
            serviceIntent.setClassName(context.getPackageName(), context.getPackageName() + ".service.JbedService");
            IBinder binder = peekService(context, serviceIntent);
            Log.i(TAG, "binder=" + binder);
            if (binder != null) {
                selector.touch();
            } else {
                selector.loadFromFiles();
                selector.storeToDb(context);
            }
        }
    }
}
