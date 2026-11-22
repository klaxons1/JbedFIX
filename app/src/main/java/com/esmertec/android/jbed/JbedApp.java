package com.esmertec.android.jbed;

import android.app.Activity;
import android.app.Application;
import android.content.ComponentName;
import android.content.Context;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
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
    private final Map<Handler, ClientRequest> pendingClients = new LinkedHashMap<>();

    private static final class ClientRequest {
        final Activity activity;
        final Handler handler;
        final long id;

        ClientRequest(Activity activity, Handler handler, long id) {
            this.activity = activity;
            this.handler = handler;
            this.id = id;
        }
    }

    public JbedApp() {
        LogTag.queryLoggingLevel();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public synchronized void clearOnServiceDisconnect() {
        ServiceConnection connection = mServiceConn;
        mServiceConn = null;
        mJbedService = null;
        mJbedConn = null;
        mAmsConn = null;
        mJbedTextFieldConnection = null;
        if (connection != null) {
            try {
                unbindService(connection);
            } catch (IllegalArgumentException e) {
                // A failed bind has no registration to remove.
            }
        }
        for (AmsClient client : amsClientMap.values()) client.mStub.release();
        for (Handler handler : handlerCountMap.keySet()) {
            handler.obtainMessage(EVENT_SERVICE_DISCONNECTED).sendToTarget();
        }
        amsClientMap.clear();
        handlerCountMap.clear();
        pendingClients.clear();
        stopService(new Intent(this, JbedService.class));
    }

    @Override // android.app.Application
    public void onCreate() {
        super.onCreate();
        sInstance = this;
        JbedLog.info(TAG, "Application.onCreate package=" + getPackageName()
                + " process=" + android.os.Process.myPid());
        try {
            JbedSettings.getInstance(this);
        } catch (RuntimeException exception) {
            JbedLog.error(TAG, "JbedSettings initialization failed", exception);
            throw exception;
        } catch (Error error) {
            JbedLog.error(TAG, "JbedSettings initialization failed", error);
            throw error;
        }
        LogTag.appDebug(TAG, "onCreate");
    }

    public static JbedApp getInstance() {
        return sInstance;
    }

    @Override // android.app.Application
    public void onTerminate() {
        LogTag.appDebug(TAG, "onTerminate");
        clearOnServiceDisconnect();
        super.onTerminate();
    }

    public void disconnet(Handler handler) {
        try {
            if (mJbedConn != null) mJbedConn.setJbedClient(null);
        } catch (RemoteException e) {
            Log.d(TAG, "VM disconnected while detaching its view");
        } finally {
            stopService(handler);
        }
    }

    public synchronized void startService(Activity activity, Handler handler, long id) {
        if (!handlerCountMap.containsKey(handler)) {
            handlerCountMap.put(handler, 1);
        } else if (amsClientMap.containsKey(handler)) {
            handlerCountMap.put(handler, handlerCountMap.get(handler) + 1);
        }
        if (mJbedService != null) {
            notifyServiceConntected(activity, handler, id);
            return;
        }
        pendingClients.put(handler, new ClientRequest(activity, handler, id));
        if (mServiceConn != null) return;
        mServiceConn = new ServiceConnection() {
            @Override
            public void onServiceConnected(ComponentName name, IBinder binder) {
                synchronized (JbedApp.this) {
                    if (mServiceConn != this) return;
                    mJbedService = IJbedService.Stub.asInterface(binder);
                    try {
                        mJbedConn = mJbedService.openConnection();
                        mAmsConn = mJbedService.openAmsConnection();
                        mJbedTextFieldConnection = mJbedService.openTextFieldConnection();
                        ArrayList<ClientRequest> clients = new ArrayList<>(pendingClients.values());
                        pendingClients.clear();
                        for (ClientRequest client : clients) {
                            if (mServiceConn != this) return;
                            if (handlerCountMap.containsKey(client.handler)) {
                                notifyServiceConntected(client.activity, client.handler, client.id);
                            }
                        }
                    } catch (RemoteException e) {
                        Log.e(TAG, "VM disconnected while opening its connections", e);
                        Toast.makeText(JbedApp.this, R.string.PRJ_JBED_SERVICE_ERROR, Toast.LENGTH_LONG).show();
                        clearOnServiceDisconnect();
                    }
                }
            }

            @Override
            public void onServiceDisconnected(ComponentName name) {
                synchronized (JbedApp.this) {
                    if (mServiceConn != this) return;
                    Toast.makeText(JbedApp.this, R.string.PRJ_JBED_SERVICE_ERROR, Toast.LENGTH_LONG).show();
                    clearOnServiceDisconnect();
                }
            }
        };
        Intent intent = new Intent(this, JbedService.class);
        startService(intent);
        if (!bindService(intent, mServiceConn, Context.BIND_AUTO_CREATE)) {
            Toast.makeText(this, R.string.PRJ_JBED_SERVICE_ERROR, Toast.LENGTH_LONG).show();
            clearOnServiceDisconnect();
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public synchronized void notifyServiceConntected(Activity activity, Handler handler, long id) {
        AmsClient amsClient = new AmsClient(activity, handler, this.mAmsConn, id);
        this.amsClientMap.put(handler, amsClient);
        try {
            this.mAmsConn.onClientConnected(amsClient.mStub);
        } catch (RemoteException e) {
            Log.e(TAG, "VM disconnected while registering its client", e);
            Toast.makeText(this, R.string.PRJ_JBED_SERVICE_ERROR, Toast.LENGTH_LONG).show();
            clearOnServiceDisconnect();
            return;
        }
        Message.obtain(handler, EVENT_SERVICE_CONNECTED).sendToTarget();
    }

    public synchronized void stopService(Handler handler) {
        if (!this.handlerCountMap.containsKey(handler)) {
            Log.w(TAG, "stopService handlerCountMap doesn't contain handler " + handler);
        } else {
            int count = this.handlerCountMap.remove(handler).intValue() - 1;
            if (count == 0) {
                pendingClients.remove(handler);
                AmsClient amsClient = this.amsClientMap.remove(handler);
                LogTag.appDebug(TAG, "stopService handler = " + handler + " amsclient=" + (amsClient == null ? JbedSelectorData.EXT_NULL : amsClient.toString()));
                if (amsClient == null) {
                    LogTag.appDebug(TAG, "stopService() failed to remove the amslcient with handler " + handler + "! stopService on this handler has been called before.");
                } else {
                    try {
                        if (this.mAmsConn != null) this.mAmsConn.onClientDisconnected(amsClient.mStub);
                    } catch (RemoteException e) {
                        Log.d(TAG, "VM disconnected while releasing its client");
                    } finally {
                        amsClient.mStub.release();
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
                Log.d(TAG, "VM disconnected during a lifecycle transition");
            }
        }
    }
}
