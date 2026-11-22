package com.esmertec.android.jbed;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.IBinder;
import android.util.Log;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Scanner;
import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes.dex */
public class PushSmsReceiver extends BroadcastReceiver {
    private static final boolean DEBUG = true;
    static final String TAG = "PushSmsReceiver";

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        Log.i(TAG, "onReceive :" + intent);
        Uri uri = intent.getData();
        Log.i(TAG, "onReceive,uri :" + uri);
        String scheme = uri.getScheme();
        String portString = Integer.toString(uri.getPort());
        Log.i(TAG, "onReceive,uri --scheme:" + scheme + ";portString;" + portString + ";port:" + uri.getPort());
        Intent serviceIntent = new Intent();
        serviceIntent.setClassName(context.getPackageName(), context.getPackageName() + ".service.JbedService");
        IBinder binder = peekService(context, serviceIntent);
        Log.i(TAG, "binder=" + binder);
        if (binder != null) {
            Log.i(TAG, "push sms---->should not start jbed.");
            if (intent != null) {
                Log.i(TAG, "sendBroadcast(SmsIntent)");
                Intent pushSmsIntent = new Intent();
                pushSmsIntent.setAction(JbedConstants.ACTION_JBED_PUSH_SMS);
                pushSmsIntent.putExtra(JbedConstants.ACTION_JBED_PUSH_SMS, intent);
                context.sendBroadcast(pushSmsIntent);
                return;
            }
            return;
        }
        if (checkPushSchemaAndPorts(scheme, portString)) {
            Log.i(TAG, "push sms--start Jbed-->:");
            Intent jbedIntent = new Intent();
            jbedIntent.setClassName("com.esmertec.android.jbed", "com.esmertec.android.jbed.app.JbedAppActivity");
            jbedIntent.setFlags(268435456);
            jbedIntent.putExtra(JbedConstants.ACTION_JBED_PUSH_SMS, intent);
            context.startActivity(jbedIntent);
        }
    }

    private String getPushListText() {
        File file = new File("/data/data/com.esmertec.android.jbed/Installed/pushlist.txt");
        if (file.exists()) {
            Log.i(TAG, "getPushListText---->exists");
            byte[] data = new byte[(int) file.length()];
            try {
                new FileInputStream(file).read(data);
                return new String(data);
            } catch (IOException e) {
                Log.i(TAG, " failed to read the content of /data/data/com.esmertec.android.jbed/Installed/pushlist.txt");
            }
        }
        Log.i(TAG, "Have no push information at /data/data/com.esmertec.android.jbed/Installed/pushlist.txt");
        return "";
    }

    public boolean checkPushSchemaAndPorts(String schema, String port) {
        Log.i(TAG, "getPushPorts---->");
        Scanner s = new Scanner(getPushListText());
        Pattern p = Pattern.compile("P(\\w+)://:?([\\d|\\w]*),(.*?),.*");
        while (s.hasNext(p)) {
            s.next(p);
            String mSchema = s.match().group(1);
            String mPort = s.match().group(2);
            Log.i(TAG, " getPushPorts:schema " + schema + ";port: " + port);
            Log.i(TAG, " getPushPorts: mschema " + mSchema + ";mport: " + mPort);
            if (schema.equals(mSchema) && port.equals(mPort)) {
                return DEBUG;
            }
        }
        return false;
    }
}
