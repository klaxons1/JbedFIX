package com.esmertec.android.jbed.jsr;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.database.ContentObserver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.os.Vibrator;
import android.provider.Telephony;
import android.telephony.TelephonyManager;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.service.JbedService;
import java.lang.reflect.Method;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public class JbedMidpManager implements JbedService.LifecycleListener, JbedConstants {
    static final /* synthetic */ boolean $assertionsDisabled;
    private static final String ACTION_PHONE_STATE_CHANGED = "android.intent.action.PHONE_STATE";
    private static final boolean DEBUG = false;
    private static Method I18N_GETSTRINGID = null;
    private static JbedMidpManager INSTANCE = null;
    private static final String JBED_HTTP_PASSWORD = "com.sun.midp.io.http.proxy.password";
    private static final String JBED_HTTP_PROXY = "com.sun.midp.io.http.proxy";
    private static final String JBED_HTTP_USER = "com.sun.midp.io.http.proxy.login";
    private static final String JBED_USER_AGENT = "microedition.ua.default";
    private static final String TAG = "JbedMidpManager";
    static final String UNKNOWN_STRING = "<unknown>";
    private ContentObserver apnObserver;
    private JbedService.ClientProxy mClient;
    private Context mContext;
    private Handler mHandler;
    private Vibrator mVibrator;
    private BroadcastReceiver mVmStartedReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.jsr.JbedMidpManager.2
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            JbedMidpManager.this.setJbedHttpProxy();
            JbedMidpManager.this.setJbedUserAgent();
        }
    };
    public final JbedService.ClientChangedListener mClientChangedListener = new JbedService.ClientChangedListener() { // from class: com.esmertec.android.jbed.jsr.JbedMidpManager.3
        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientAttached(JbedService.ClientProxy client) {
            JbedMidpManager.this.mClient = client;
        }

        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientDetached() {
            JbedMidpManager.this.mClient = null;
        }
    };
    private BroadcastReceiver mIncomingCallReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.jsr.JbedMidpManager.4
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            Message msg;
            if (intent.getAction().equals(JbedMidpManager.ACTION_PHONE_STATE_CHANGED)) {
                String phoneState = intent.getStringExtra(TransactionService.STATE);
                if (TelephonyManager.EXTRA_STATE_RINGING.equals(phoneState) || TelephonyManager.EXTRA_STATE_OFFHOOK.equals(phoneState)) {
                    msg = JbedMidpManager.this.mHandler.obtainMessage(6, 2, 0);
                } else if (TelephonyManager.EXTRA_STATE_IDLE.equals(phoneState)) {
                    if (JbedConfig.isBlockVMAfterPhoneHangup() && !((JbedService) JbedMidpManager.this.mContext).mAmsConnection.getRunningMidletList().isEmpty()) {
                        JbedMidpManager.this.mHandler.obtainMessage(9).sendToTarget();
                    }
                    msg = JbedMidpManager.this.mHandler.obtainMessage(8, 2, 0);
                } else {
                    throw new IllegalArgumentException("incrroect phone state");
                }
                msg.sendToTarget();
            }
        }
    };

    private static native void nativeInitialization();

    public native void nativeSetJbedProperty(String str, String str2);

    static {
        $assertionsDisabled = !JbedMidpManager.class.desiredAssertionStatus();
        nativeInitialization();
    }

    public JbedMidpManager(Handler handler) {
        this.apnObserver = new ContentObserver(this.mHandler) { // from class: com.esmertec.android.jbed.jsr.JbedMidpManager.1
            @Override // android.database.ContentObserver
            public void onChange(boolean selfChange) {
                JbedMidpManager.this.setJbedHttpProxy();
            }
        };
        this.mHandler = handler;
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
        IntentFilter incomingCallFilter = new IntentFilter(ACTION_PHONE_STATE_CHANGED);
        context.registerReceiver(this.mIncomingCallReceiver, incomingCallFilter);
        IntentFilter vmStartFilter = new IntentFilter(JbedConstants.ACTION_JBED_VM_STARTED);
        context.registerReceiver(this.mVmStartedReceiver, vmStartFilter);
        try {
            context.getContentResolver().registerContentObserver(Telephony.Carriers.CONTENT_URI, true, this.apnObserver);
        } catch (RuntimeException e) {
            Log.w(TAG, "APN observer unavailable on this Android release; continuing without APN proxy updates", e);
        }
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        INSTANCE = null;
        context.unregisterReceiver(this.mIncomingCallReceiver);
        context.unregisterReceiver(this.mVmStartedReceiver);
        context.getContentResolver().unregisterContentObserver(this.apnObserver);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void setJbedUserAgent() {
        String agentStr = JbedConfig.getUserAgent();
        if (agentStr != null) {
            nativeSetJbedProperty(JBED_USER_AGENT, agentStr);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void setJbedHttpProxy() {
        Uri PREFERAPN_URI = Uri.parse("content://telephony/carriers/preferapn");
        String simOperator = "";
        TelephonyManager tm = (TelephonyManager) this.mContext.getSystemService(Context.TELEPHONY_SERVICE);
        if (tm != null && tm.getSimOperator() != null) {
            simOperator = tm.getSimOperator();
        }
        String where = "numeric=\"" + simOperator + "\"";
        Cursor cursor = null;
        try {
            cursor = this.mContext.getContentResolver().query(PREFERAPN_URI, null, where, null, "name ASC");
            if (cursor == null) {
                Log.w(TAG, "setJbedHttpProxy: APN provider returned no cursor; continuing without proxy");
                nativeSetJbedProperty(JBED_HTTP_PROXY, "");
                return;
            }
            cursor.moveToFirst();
            if (!cursor.isAfterLast()) {
                cursor.getString(cursor.getColumnIndexOrThrow(JbedProvider.Midlets.NAME));
                cursor.getString(cursor.getColumnIndexOrThrow("apn"));
                String proxy = cursor.getString(cursor.getColumnIndexOrThrow("proxy"));
                String port = cursor.getString(cursor.getColumnIndexOrThrow("port"));
                cursor.getString(cursor.getColumnIndexOrThrow(TransactionService.TRANSACTION_TYPE));
                String user = cursor.getString(cursor.getColumnIndexOrThrow("user"));
                String password = cursor.getString(cursor.getColumnIndexOrThrow("password"));
                String proxyAndPort = "";
                if (proxy != null && proxy.trim().length() != 0) {
                    proxyAndPort = proxy + ":" + port;
                }
                nativeSetJbedProperty(JBED_HTTP_PROXY, proxyAndPort);
                if (user != null) {
                    nativeSetJbedProperty(JBED_HTTP_USER, user);
                }
                if (password != null) {
                    nativeSetJbedProperty(JBED_HTTP_PASSWORD, password);
                }
            }
        } catch (RuntimeException e) {
            // Android 11 protects APN settings from ordinary apps. The original
            // Android 2.x integration used APN data only to configure an HTTP
            // proxy, so continue with no proxy instead of crashing the remote VM
            // process after ACTION_JBED_VM_STARTED.
            Log.w(TAG, "setJbedHttpProxy: APN access unavailable; continuing without proxy", e);
            nativeSetJbedProperty(JBED_HTTP_PROXY, "");
        } finally {
            if (cursor != null) {
                cursor.close();
            }
        }
    }

    static String getIntentActionByUrl(String url) {
        if (!$assertionsDisabled && url == null) {
            throw new AssertionError();
        }
        try {
            Uri uri = Uri.parse(url);
            String intentAction = null;
            String scheme = uri.getScheme();
            if ("http".equals(scheme) || "https".equals(scheme)) {
                intentAction = "android.intent.action.VIEW";
            } else if ("tel".equals(scheme)) {
                intentAction = "android.intent.action.CALL";
            }
            return intentAction;
        } catch (Exception e) {
            Log.w(TAG, "Throw exception when call parse(). url = " + url);
            return null;
        }
    }

    private static int platformRequest(String url) {
        String intentAction = getIntentActionByUrl(url);
        if (intentAction != null) {
            Intent intent = new Intent(intentAction, Uri.parse(url));
            intent.setFlags(268435456);
            INSTANCE.mContext.startActivity(intent);
            return 0;
        }
        Log.w(TAG, "ERROR: fail to call platformRequest(). url = " + url);
        return -1;
    }

    static void setVibrate(boolean isVibrate) {
        Vibrator vibrator = INSTANCE.mVibrator;
        if (vibrator == null) {
            vibrator = (Vibrator) INSTANCE.mContext.getSystemService(Context.VIBRATOR_SERVICE);
            INSTANCE.mVibrator = vibrator;
        }
        if (vibrator == null) {
            return;
        }
        if (isVibrate) {
            vibrator.vibrate(31536000000L);
        } else {
            vibrator.cancel();
        }
    }

    public static String getString(int mouduleId, int jbedId) {
        try {
            if (I18N_GETSTRINGID == null) {
                I18N_GETSTRINGID = Class.forName("com.esmertec.android.jbed.util.I18N").getDeclaredMethod("getStringID", Integer.TYPE, Integer.TYPE);
            }
            Integer retIDObj = (Integer) I18N_GETSTRINGID.invoke(null, Integer.valueOf(mouduleId), Integer.valueOf(jbedId));
            int retId = retIDObj != null ? retIDObj.intValue() : -1;
            if (retId == -1 || INSTANCE == null || INSTANCE.mContext == null) {
                Log.w(TAG, "i18n lookup unavailable: module=" + mouduleId + " id=" + jbedId);
                return UNKNOWN_STRING;
            }
            String value = INSTANCE.mContext.getResources().getString(retId).replace("$s", "");
            Log.i(TAG, "native i18n lookup: module=" + mouduleId + " id=" + jbedId + " resource=" + retId + " value=" + value);
            return value;
        } catch (Throwable e) {
            // Native libjbedvm calls strlen() on this JNI result. Never allow
            // a Java exception or null result to cross that boundary.
            Log.e(TAG, "i18n lookup failed: module=" + mouduleId + " id=" + jbedId, e);
            return UNKNOWN_STRING;
        }
    }

    public static String getLocaleString() {
        Locale defLocale = Locale.getDefault();
        return defLocale.getLanguage() + "-" + defLocale.getCountry();
    }

    public static void updateLocale() {
        String localStr = getLocaleString();
        if (localStr != null) {
            INSTANCE.nativeSetJbedProperty("microedition.locale", localStr);
        }
    }
}
