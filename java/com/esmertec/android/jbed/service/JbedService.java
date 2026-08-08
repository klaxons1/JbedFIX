package com.esmertec.android.jbed.service;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.PixelFormat;
import android.os.DeadObjectException;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.DisplayMetrics;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.PushJbedAlarmManager;
import com.esmertec.android.jbed.ams.AmsConnection;
import com.esmertec.android.jbed.ams.IJbedAmsConnection;
import com.esmertec.android.jbed.ams.JbedSelector;
import com.esmertec.android.jbed.app.IJbedClient;
import com.esmertec.android.jbed.app.IJbedVideoClient;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.esmertec.android.jbed.jsr.JbedLapiManager;
import com.esmertec.android.jbed.jsr.JbedLcduiManager;
import com.esmertec.android.jbed.jsr.JbedMediaManager;
import com.esmertec.android.jbed.jsr.JbedMidpManager;
import com.esmertec.android.jbed.jsr.JbedMmsManager;
import com.esmertec.android.jbed.jsr.JbedPimManager;
import com.esmertec.android.jbed.jsr.JbedSmsManager;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;
import com.esmertec.android.jbed.nativeui.JbedTextFieldConnection;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedService extends Service implements JbedConstants {
    public static final String TAG = "jbedservice";

    public AmsConnection mAmsConnection;
    private JbedEngine mJbedEngine;
    private IJbedUiListener mUiEventListener;
    private List<LifecycleListener> mLifecycleListeners = new ArrayList();
    private List<ClientChangedListener> mClientChangedListeners = new ArrayList();
    private int mOrientation = 0;
    private final IJbedService.Stub mBinder = new IJbedService.Stub() { // from class: com.esmertec.android.jbed.service.JbedService.1
        @Override // com.esmertec.android.jbed.service.IJbedService
        public void startVm(int viewWidth, int viewHeight, int bytesPerPixel, int viewFullScreenWidth, int viewFullScreenHeight, boolean isRefresh, boolean forceSizeChanged) throws DeadObjectException {
            LogTag.serviceDebug(JbedService.TAG, " startVm \n>> viewWidth=" + viewWidth + "\n>> viewHeight=" + viewHeight + "\n>> bytesPerPixel=" + bytesPerPixel + "\n>> viewFullScreenWidth=" + viewFullScreenWidth + "\n>> viewFullScreenHeight=" + viewFullScreenHeight + "\n>> isRefresh=" + isRefresh + "\n>> mUiEventListener" + JbedService.this.mUiEventListener);
            JbedService.this.mJbedEngine.startVm(viewWidth, viewHeight, bytesPerPixel, viewFullScreenWidth, viewFullScreenHeight, isRefresh, forceSizeChanged);
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public void shutdownVm() throws DeadObjectException {
            if (JbedService.this.mJbedEngine != null) {
                JbedService.this.mJbedEngine.stopVmAndWait();
            }
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public IJbedConnection openConnection() throws DeadObjectException {
            return new IJbedConnection.Stub() { // from class: com.esmertec.android.jbed.service.JbedService.1.1
                @Override // com.esmertec.android.jbed.service.IJbedConnection
                public IJbedUiListener getUiListener() throws DeadObjectException {
                    return JbedService.this.mUiEventListener;
                }

                @Override // com.esmertec.android.jbed.service.IJbedConnection
                public void setJbedClient(IJbedClient client) throws DeadObjectException {
                    ClientProxy clientProxy = client == null ? null : new ClientProxy(client);
                    for (ClientChangedListener l : JbedService.this.mClientChangedListeners) {
                        if (clientProxy != null) {
                            l.onClientAttached(clientProxy);
                        } else {
                            l.onClientDetached();
                        }
                    }
                }
            };
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public IJbedAmsConnection openAmsConnection() throws DeadObjectException {
            return JbedService.this.mAmsConnection;
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public IJbedTextFieldConnection openTextFieldConnection() throws DeadObjectException {
            JbedTextFieldConnection textFieldConnection = new JbedTextFieldConnection(JbedService.this.mJbedEngine.mHandler);
            return textFieldConnection.mConnection;
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public void setRotateHappen(boolean b) {
            JbedService.this.mJbedEngine.mIsRotating = b;
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public void requestVmBackground() {
            JbedService.this.mJbedEngine.requestVmBackground();
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public void setStartWay(boolean b) {
            JbedService.this.mJbedEngine.mIsRunFromHome = b;
        }

        @Override // com.esmertec.android.jbed.service.IJbedService
        public void setVmState(int state, int reason) {
            int event;
            switch (state) {
                case 2:
                    event = 8;
                    break;
                case 3:
                    event = 7;
                    break;
                default:
                    throw new RuntimeException("jbedservice setVmState recieve an un-recognize state");
            }
            JbedService.this.mJbedEngine.mHandler.obtainMessage(event, reason, 0).sendToTarget();
        }
    };
    private BroadcastReceiver mIntentReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.service.JbedService.2
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            JbedService.this.mJbedEngine.updateSystemTime();
        }
    };

    public interface ClientChangedListener {
        void onClientAttached(ClientProxy clientProxy);

        void onClientDetached();
    }

    public static class DisplayInfo {
        public static int mDensityDpi;
        public static int mLandscapeViewHeight;
        public static int mLandscapeViewWidth;
        public static int mPortraitViewHeight;
        public static int mPortraitViewWidth;
    }

    public interface LifecycleListener {
        void onCreate(Context context);

        void onDestroy(Context context);
    }

    static {
        LogTag.serviceDebug(TAG, "JNI search path is " + System.getProperty("java.library.path"));
        LogTag.serviceDebug(TAG, "jbedvm becomes '" + System.mapLibraryName(JbedConstants.JBED_NATIVE_LIB));
        try {
            // libpng is brought into the VM's linker dependency group through
            // the packaged libcutils compatibility shim.
            System.loadLibrary(JbedConstants.JBED_NATIVE_LIB);
            System.loadLibrary("jbedcompat");
        } catch (UnsatisfiedLinkError ule) {
            Log.e(TAG, "WARNING: Could not load jbed native lib jbedvm", ule);
        }
    }

    @Override // android.app.Service, android.content.ComponentCallbacks
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        if (this.mOrientation != getResources().getConfiguration().orientation) {
            this.mOrientation = getResources().getConfiguration().orientation;
            if (JbedConfig.getDisplayPortraitWidth() != 0) {
                int viewWidth = 0;
                int viewHeight = 0;
                if (this.mOrientation == 2) {
                    viewWidth = DisplayInfo.mLandscapeViewWidth;
                    viewHeight = DisplayInfo.mLandscapeViewHeight;
                } else if (this.mOrientation == 1) {
                    viewWidth = DisplayInfo.mPortraitViewWidth;
                    viewHeight = DisplayInfo.mPortraitViewHeight;
                }
                PixelFormat pixFormat = new PixelFormat();
                PixelFormat.getPixelFormatInfo(4, pixFormat);
                this.mJbedEngine.changeScreenifVmBackground(viewWidth, viewHeight, pixFormat.bytesPerPixel, viewWidth, viewHeight);
            }
        }
        JbedMidpManager.updateLocale();
    }

    @Override // android.app.Service
    public void onCreate() {
        super.onCreate();
        this.mJbedEngine = new JbedEngine(this);
        this.mLifecycleListeners.add(this.mJbedEngine.mLifecycleListener);
        this.mLifecycleListeners.add(new JbedSmsManager(this.mJbedEngine.mHandler));
        this.mLifecycleListeners.add(new JbedMmsManager(this.mJbedEngine.mHandler));
        JbedMediaManager mediaManager = new JbedMediaManager(this.mJbedEngine.mHandler);
        this.mLifecycleListeners.add(mediaManager);
        this.mLifecycleListeners.add(new JbedFileManager(this.mJbedEngine.mHandler));
        this.mLifecycleListeners.add(new JbedPimManager());
        this.mLifecycleListeners.add(new PushJbedAlarmManager());
        this.mLifecycleListeners.add(new JbedLapiManager(this.mJbedEngine.mHandler));
        JbedMidpManager midpManager = new JbedMidpManager(this.mJbedEngine.mHandler);
        this.mLifecycleListeners.add(midpManager);
        JbedLcduiManager lcduiManager = new JbedLcduiManager(this.mJbedEngine.mHandler);
        this.mLifecycleListeners.add(lcduiManager);
        JbedSettings settings = JbedSettings.getInstance(this);
        if (settings.isNativeAms()) {
            this.mLifecycleListeners.add(new JbedSelector.SelectorObserverManager(this));
        }
        this.mAmsConnection = new AmsConnection(this.mJbedEngine.mHandler);
        this.mLifecycleListeners.add(this.mAmsConnection);
        this.mClientChangedListeners.add(this.mJbedEngine.mClientChangedListener);
        this.mClientChangedListeners.add(lcduiManager.mClientChangedListener);
        this.mClientChangedListeners.add(mediaManager.mClientChangedListener);
        this.mClientChangedListeners.add(this.mAmsConnection.mClientChangedListener);
        this.mClientChangedListeners.add(midpManager.mClientChangedListener);
        this.mUiEventListener = lcduiManager.mUiEventListener;
        for (LifecycleListener l : this.mLifecycleListeners) {
            l.onCreate(this);
        }
        IntentFilter filter = new IntentFilter();
        filter.addAction("android.intent.action.TIME_SET");
        registerReceiver(this.mIntentReceiver, filter, null, null);
        initDisplayInfo();
    }

    private void initDisplayInfo() {
        Resources res = getResources();
        res.getConfiguration();
        new DisplayMetrics();
        this.mOrientation = res.getConfiguration().orientation;
        DisplayMetrics metrics = res.getDisplayMetrics();
        DisplayInfo.mDensityDpi = metrics.densityDpi;
        LogTag.serviceDebug(TAG, "initDisplayMetrics() Metrics : W ,H, D = " + metrics.widthPixels + "," + metrics.heightPixels + "," + metrics.densityDpi);
        DisplayInfo.mLandscapeViewWidth = JbedConfig.getDisplayLandscapeWidth();
        DisplayInfo.mLandscapeViewHeight = JbedConfig.getDisplayLandscapeHeight();
        DisplayInfo.mPortraitViewWidth = JbedConfig.getDisplayPortraitWidth();
        DisplayInfo.mPortraitViewHeight = JbedConfig.getDisplayPortraitHeight();
        LogTag.serviceDebug(TAG, "initDisplayMetrics() : Land : " + DisplayInfo.mLandscapeViewWidth + "," + DisplayInfo.mLandscapeViewHeight + ", Portrait : " + DisplayInfo.mPortraitViewWidth + "," + DisplayInfo.mPortraitViewHeight);
    }

    @Override // android.app.Service
    public void onDestroy() {
        for (LifecycleListener l : this.mLifecycleListeners) {
            l.onDestroy(this);
        }
        unregisterReceiver(this.mIntentReceiver);
        this.mLifecycleListeners.clear();
        super.onDestroy();
    }

    @Override // android.app.Service
    public IBinder onBind(Intent intent) {
        return this.mBinder;
    }

    public static class ClientProxy {
        public static Object mSBUpdateMutex = new Object();
        public static boolean requestSoftButtonUpdate = false;
        private IJbedClient mJbedClient;

        ClientProxy(IJbedClient jbedClient) {
            this.mJbedClient = jbedClient;
        }

        public void finish() {
            LogTag.serviceDebug(JbedService.TAG, " notify client to finish()");
            if (this.mJbedClient != null) {
                try {
                    this.mJbedClient.finish();
                } catch (RemoteException e) {
                    throw new RuntimeException("failed to call finish()");
                }
            }
        }

        public void repaint(int clipLeft, int clipTop, int clipRight, int clipBottom, int width, int height, float pScale, float lScale) {
            if (this.mJbedClient != null) {
                try {
                    this.mJbedClient.repaint(clipLeft, clipTop, clipRight, clipBottom, width, height, pScale, lScale);
                } catch (RemoteException e) {
                    throw new RuntimeException("failed to call repaint()");
                }
            }
        }

        public void repaintAll() {
            repaint(0, 0, 16383, 16383, -1, -1, 0.0f, 0.0f);
        }

        public IJbedVideoClient getVideoClient() {
            if (this.mJbedClient != null) {
                try {
                    return this.mJbedClient.getVideoClient();
                } catch (RemoteException e) {
                    throw new RuntimeException("failed to call getVideoClient()");
                }
            }
            return null;
        }

        public void onSoftButtonChanged(String leftButton, String rightButton) {
            synchronized (mSBUpdateMutex) {
                requestSoftButtonUpdate = true;
                if (this.mJbedClient != null) {
                    try {
                        this.mJbedClient.onSoftButtonChanged(leftButton, rightButton);
                    } catch (RemoteException e) {
                        throw new RuntimeException("failed to call onSoftButtonChanged()");
                    }
                }
                requestSoftButtonUpdate = false;
                mSBUpdateMutex.notify();
            }
        }
    }
}
