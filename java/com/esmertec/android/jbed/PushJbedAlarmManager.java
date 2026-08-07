package com.esmertec.android.jbed;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.IBinder;
import android.os.SystemClock;
import com.esmertec.android.jbed.service.JbedService;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.Scanner;
import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes.dex */
public class PushJbedAlarmManager extends BroadcastReceiver implements JbedService.LifecycleListener {
    private static final boolean DEBUG = false;
    private static PushJbedAlarmManager INSTANCE = null;
    private static final String SCHEMA_ALARM = "alarm";
    static final String TAG = "PushJbedAlarmManager";
    private static Context mContext;
    private int mPort;

    public PushJbedAlarmManager() {
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        INSTANCE = null;
        checkAndstartAlarm(context);
    }

    public static void startAlarm(String mAlarmParam1) {
        AlarmManager alarmManager = (AlarmManager) mContext.getSystemService("alarm");
        Intent intent = new Intent(JbedConstants.ACTION_JBED_PUSH_ALARM);
        PendingIntent sender = PendingIntent.getBroadcast(mContext, 0, intent, 0);
        long launchTime = Long.parseLong(mAlarmParam1, 16);
        long delayMillis = launchTime - System.currentTimeMillis();
        if (delayMillis < 0) {
            delayMillis = 0;
        }
        long wakeupTime = SystemClock.elapsedRealtime() + delayMillis;
        alarmManager.set(3, wakeupTime, sender);
    }

    public static void checkAndstartAlarm(Context context) {
        mContext = context;
        checkPushSchemaAndPorts("alarm", null, null);
    }

    private static String getPushListText() {
        File file = new File("/data/data/com.esmertec.android.jbed/Installed/pushlist.txt");
        if (file.exists()) {
            byte[] data = new byte[(int) file.length()];
            try {
                new FileInputStream(file).read(data);
                return new String(data);
            } catch (IOException e) {
            }
        }
        LogTag.serviceDebug(TAG, "Have no push information at /data/data/com.esmertec.android.jbed/Installed/pushlist.txt");
        return "";
    }

    public static boolean checkPushSchemaAndPorts(String schema, String port, String param1) {
        boolean isMatch = false;
        Scanner s = new Scanner(getPushListText());
        Pattern p = Pattern.compile("P(\\w+)://:?([\\d|\\w]*),(.*?),.*");
        while (s.hasNext(p)) {
            s.next(p);
            String mSchema = s.match().group(1);
            s.match().group(2);
            String mParam1 = s.match().group(3);
            if (schema.equals(mSchema)) {
                isMatch = true;
                startAlarm(mParam1);
            }
        }
        return isMatch;
    }

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action.equals(JbedConstants.ACTION_JBED_PUSH_ALARM)) {
            Intent serviceIntent = new Intent();
            serviceIntent.setClassName(context.getPackageName(), context.getPackageName() + ".service.JbedService");
            IBinder binder = peekService(context, serviceIntent);
            LogTag.appDebug(TAG, "binder=" + binder);
            if (binder == null) {
                Intent jbedIntent = new Intent();
                jbedIntent.setClassName("com.esmertec.android.jbed", "com.esmertec.android.jbed.app.JbedAppActivity");
                jbedIntent.setFlags(268435456);
                context.startActivity(jbedIntent);
            }
        }
    }
}
