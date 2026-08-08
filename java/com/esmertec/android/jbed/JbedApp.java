package com.esmertec.android.jbed;

import android.app.Activity;
import android.app.Application;
import android.content.ComponentName;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;
import android.widget.Toast;
import com.esmertec.android.jbed.ams.AmsClient;
import com.esmertec.android.jbed.ams.IJbedAmsConnection;
import com.esmertec.android.jbed.ams.JbedSelectorData;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;
import com.esmertec.android.jbed.service.IJbedConnection;
import com.esmertec.android.jbed.service.IJbedService;
import com.esmertec.android.jbed.service.JbedService;
import java.util.HashMap;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class JbedApp extends Application {
    private static JbedApp sInstance;
    private static final int EVENT_APP_BASE = 99000;
    public static final int EVENT_SERVICE_CONNECTED = 99001;
    public static final int EVENT_SERVICE_DISCONNECTED = 99002;
    public static final String TAG = "JbedApp";
    private Map<Handler, AmsClient> amsClientMap = new HashMap();
    private Map<Handler, Integer> handlerCountMap = new HashMap();
    private IJbedAmsConnection mAmsConn;
    public IJbedConnection mJbedConn;
    public IJbedService mJbedService;
    public IJbedTextFieldConnection mJbedTextFieldConnection;
    private ServiceConnection mServiceConn;

    public JbedApp() {
        LogTag.queryLoggingLevel();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void clearOnServiceDisconnect() {
        Handler[] handlers = (Handler[]) this.amsClientMap.keySet().toArray(new Handler[this.amsClientMap.size()]);
        for (int i = handlers.length - 1; i >= 0; i--) {
            handlers[i].obtainMessage(EVENT_SERVICE_DISCONNECTED).sendToTarget();
            stopService(handlers[i]);
        }
        this.amsClientMap.clear();
        this.handlerCountMap.clear();
        this.mJbedService = null;
        this.mJbedConn = null;
        this.mAmsConn = null;
        this.mServiceConn = null;
    }

    @Override // android.app.Application
    public void onCreate() {
        super.onCreate();
        sInstance = this;
        JbedSettings.getInstance(this);
        LogTag.appDebug(TAG, "onCreate");
    }

    public static JbedApp getInstance() {
        return sInstance;
    }

    @Override // android.app.Application
    public void onTerminate() {
        LogTag.appDebug(TAG, "onTerminate");
        try {
            if (this.mJbedService != null) {
                unbindService(this.mServiceConn);
            }
        } catch (IllegalArgumentException e) {
            LogTag.appDebug(TAG, "mJbedService may not registered, ignore");
        }
        clearOnServiceDisconnect();
        super.onTerminate();
    }

    public void disconnet(Handler handler) {
        if (this.mJbedService != null) {
            try {
                this.mJbedConn.setJbedClient(null);
                stopService(handler);
            } catch (RemoteException e) {
                throw new RuntimeException(" failed to call disconnect");
            }
        }
    }

    public synchronized void startService(final Activity activity, final Handler handler, final long id) {
        if (!this.handlerCountMap.containsKey(handler)) {
            this.handlerCountMap.put(handler, 1);
        } else if (this.amsClientMap.containsKey(handler)) {
            int count = this.handlerCountMap.remove(handler).intValue();
            this.handlerCountMap.put(handler, Integer.valueOf(count + 1));
            Log.e(TAG, "WARNING :startService() been called twice from the same Activity");
        }
        LogTag.appDebug(TAG, "startService handler = " + handler);
        if (this.mJbedService == null) {
            this.mServiceConn = new ServiceConnection() { // from class: com.esmertec.android.jbed.JbedApp.1
                @Override // android.content.ServiceConnection
                public void onServiceConnected(ComponentName className, IBinder service) {
                    LogTag.appDebug(JbedApp.TAG, "Connecte Service successfully");
                    JbedApp.this.mJbedService = IJbedService.Stub.asInterface(service);
                    try {
                        JbedApp.this.mJbedConn = JbedApp.this.mJbedService.openConnection();
                        JbedApp.this.mAmsConn = JbedApp.this.mJbedService.openAmsConnection();
                        JbedApp.this.mJbedTextFieldConnection = JbedApp.this.mJbedService.openTextFieldConnection();
                        JbedApp.this.notifyServiceConntected(activity, handler, id);
                    } catch (RemoteException e) {
                        throw new RuntimeException("failed to call mJbedService.openConnection() ");
                    }
                }

                @Override // android.content.ServiceConnection
                public void onServiceDisconnected(ComponentName className) {
                    Log.w(JbedApp.TAG, "WARNING: diconnect from Service!");
                    Toast.makeText(activity, R.string.PRJ_SDCARD_ERROR_MESSAGE, 0).show();
                    JbedApp.this.clearOnServiceDisconnect();
                }
            };
            Intent serviceIntent = new Intent(this, (Class<?>) JbedService.class);
            startService(serviceIntent);
            bindService(serviceIntent, this.mServiceConn, 1);
        } else {
            notifyServiceConntected(activity, handler, id);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public synchronized void notifyServiceConntected(Activity activity, Handler handler, long id) {
        AmsClient amsClient = new AmsClient(activity, handler, this.mAmsConn, id);
        this.amsClientMap.put(handler, amsClient);
        try {
            this.mAmsConn.onClientConnected(amsClient.mStub);
        } catch (RemoteException e) {
            Log.e(TAG, " failed to onClientConnected !!");
        }
        Message.obtain(handler, EVENT_SERVICE_CONNECTED).sendToTarget();
    }

    public synchronized void stopService(Handler handler) {
        if (!this.handlerCountMap.containsKey(handler)) {
            Log.w(TAG, "stopService handlerCountMap doesn't contain handler " + handler);
        } else {
            int count = this.handlerCountMap.remove(handler).intValue() - 1;
            if (count == 0) {
                AmsClient amsClient = this.amsClientMap.remove(handler);
                LogTag.appDebug(TAG, "stopService handler = " + handler + " amsclient=" + (amsClient == null ? JbedSelectorData.EXT_NULL : amsClient.toString()));
                if (amsClient == null) {
                    LogTag.appDebug(TAG, "stopService() failed to remove the amslcient with handler " + handler + "! stopService on this handler has been called before.");
                } else {
                    try {
                        this.mAmsConn.onClientDisconnected(amsClient.mStub);
                        amsClient.mStub.release();
                    } catch (RemoteException e) {
                        Log.e(TAG, " failed to onClientDisconnected !!");
                    }
                }
            } else {
                this.handlerCountMap.put(handler, Integer.valueOf(count));
            }
        }
    }

    public AmsClient getAmsClient(Handler handler) {
        return this.amsClientMap.get(handler);
    }

    public void notifyAmsForeground() {
        setVmState(2, 16);
    }

    public void notifyActivityBackground() {
        setVmState(2, 8);
    }

    public void notifyActivityForeground() {
        setVmState(3, 4);
    }

    private void setVmState(int state, int reason) {
        if (this.mJbedService != null) {
            try {
                this.mJbedService.setVmState(state, reason);
            } catch (RemoteException e) {
                throw new RuntimeException("failed to call setVmState !!");
            }
        }
    }
}
