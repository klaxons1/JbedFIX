package com.esmertec.android.jbed.app;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.os.Handler;
import android.os.IBinder;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;
import com.esmertec.android.jbed.ams.AmsClientBase;
import com.esmertec.android.jbed.ams.IJbedAmsConnection;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;
import com.esmertec.android.jbed.service.IJbedConnection;
import com.esmertec.android.jbed.service.IJbedService;
import com.esmertec.android.jbed.service.JbedService;

/* JADX INFO: compiled from: JbedView.java */
/* JADX INFO: loaded from: classes.dex */
class SimpleServiceConnectorImpl implements JbedView.ServiceConnector {
    public static final String TAG = "SimpleConnector";
    private AmsClientBase mAmsClient;
    private IJbedAmsConnection mAmsConn;
    private JbedView.Callback mCallback;
    private Context mContext;
    Handler mEventhListenHandler;
    private IJbedConnection mJbedConn;
    private IJbedService mJbedService;
    Handler mAmsHandler = new Handler() { // from class: com.esmertec.android.jbed.app.SimpleServiceConnectorImpl.1
        @Override // android.os.Handler
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 10013:
                    postDelayed(new Runnable() { // from class: com.esmertec.android.jbed.app.SimpleServiceConnectorImpl.1.1
                        @Override // java.lang.Runnable
                        public void run() {
                            if (SimpleServiceConnectorImpl.this.mCallback != null) {
                                SimpleServiceConnectorImpl.this.mCallback.onMidletStarted();
                            } else {
                                Log.w(SimpleServiceConnectorImpl.TAG, "WARNING: mConnectListener is null! failed to callback onMidletStarted");
                            }
                        }
                    }, 400L);
                    break;
                case 10014:
                default:
                    Log.w(SimpleServiceConnectorImpl.TAG, " Unsupport event " + msg.what);
                    break;
                case 10015:
                    Message.obtain(SimpleServiceConnectorImpl.this.mEventhListenHandler, JbedView.EVENT_ON_MIDLET_STATE_CHANGED, msg.arg1, msg.arg2, msg.obj).sendToTarget();
                    break;
                case 10016:
                    Log.e(SimpleServiceConnectorImpl.TAG, " get HANDLE_ERROR " + msg.obj);
                    Message.obtain(SimpleServiceConnectorImpl.this.mEventhListenHandler, JbedView.EVENT_ON_MIDLET_ERROR, msg.arg1, msg.arg2, msg.obj).sendToTarget();
                    break;
            }
        }
    };
    private ServiceConnection mServiceConn = new ServiceConnection() { // from class: com.esmertec.android.jbed.app.SimpleServiceConnectorImpl.2
        @Override // android.content.ServiceConnection
        public void onServiceConnected(ComponentName className, IBinder service) {
            SimpleServiceConnectorImpl.this.mJbedService = IJbedService.Stub.asInterface(service);
            try {
                SimpleServiceConnectorImpl.this.mJbedConn = SimpleServiceConnectorImpl.this.mJbedService.openConnection();
                SimpleServiceConnectorImpl.this.mAmsConn = SimpleServiceConnectorImpl.this.mJbedService.openAmsConnection();
                SimpleServiceConnectorImpl.this.mAmsClient = new AmsClientBase((Activity) SimpleServiceConnectorImpl.this.mContext, SimpleServiceConnectorImpl.this.mAmsHandler, SimpleServiceConnectorImpl.this.mAmsConn, 0L, new SimpleAmsEventHandlerFactoryImpl());
                SimpleServiceConnectorImpl.this.mAmsConn.onClientConnected(SimpleServiceConnectorImpl.this.mAmsClient.mStub);
                SimpleServiceConnectorImpl.this.mCallback.onServiceConnected();
            } catch (RemoteException e) {
                throw new RuntimeException("failed to onClientConnected !!");
            }
        }

        @Override // android.content.ServiceConnection
        public void onServiceDisconnected(ComponentName className) {
            Log.w("", "WARNING: diconnect from Service!");
            SimpleServiceConnectorImpl.this.mJbedService = null;
            SimpleServiceConnectorImpl.this.mJbedConn = null;
            SimpleServiceConnectorImpl.this.mAmsConn = null;
            Message.obtain(SimpleServiceConnectorImpl.this.mEventhListenHandler, JbedView.EVENT_ON_SERVICE_DISCONNECTED).sendToTarget();
        }
    };

    public SimpleServiceConnectorImpl(Context context, Handler eventListenHandler) {
        this.mContext = context;
        this.mEventhListenHandler = eventListenHandler;
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public IJbedService getJbedService() {
        return this.mJbedService;
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public IJbedConnection getJbedConn() {
        return this.mJbedConn;
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public IJbedTextFieldConnection getTextFieldConn() {
        try {
            return this.mJbedService.openTextFieldConnection();
        } catch (RemoteException e) {
            throw new RuntimeException("fail to call openTextFieldConnection");
        }
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public AmsClientBase getAmsClient() {
        return this.mAmsClient;
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public void connect(JbedView.Callback callback) {
        Intent serviceIntent = new Intent();
        serviceIntent.setClassName("com.esmertec.android.jbed", JbedService.class.getName());
        this.mContext.startService(serviceIntent);
        this.mContext.bindService(serviceIntent, this.mServiceConn, 1);
        this.mCallback = callback;
    }

    @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
    public void disconnect() {
        if (this.mJbedService != null) {
            try {
                this.mAmsConn.onClientDisconnected(this.mAmsClient.mStub);
                this.mAmsClient.mStub.release();
            } catch (RemoteException e) {
                Log.e(TAG, " failed to onClientDisconnected !!");
            }
            this.mContext.unbindService(this.mServiceConn);
        }
    }
}
