package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.content.Intent;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.RemoteException;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.service.JbedService;
import com.google.android.collect.Lists;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public class AmsConnection extends IJbedAmsConnection.Stub implements AmsConstants, JbedService.LifecycleListener {
    private static AmsConnection INSTANCE = null;
    private static final String TAG = "AmsConnection";
    private static final int WAIT_JBED_CLEINT_MAX_COUNT = 10;
    private IJbedAmsClient mAmsClient;
    private Context mContext;
    private Handler mHandler;
    private JbedService.ClientProxy mJbedClient;
    private List<JbedSelectorData> mPowerOnMidlets;
    private BlockingQueue<AmsEvent> mEventQueue = new LinkedBlockingQueue();
    private BlockingQueue<AmsEvent> mPendingEventQueue = new LinkedBlockingQueue();
    private BlockingQueue<AmsEvent> mPendingRequestEventQueue = new LinkedBlockingQueue();
    private Object mAmsClientMutx = new Object();
    private Object mJbedClientMutx = new Object();
    private TokenHolder tokenHolder = TokenHolder.NONE;
    private boolean mPendingDrmConsraintRequest = false;
    private List<JbedSelectorData> mRunningMidletList = Lists.newArrayList();
    private HashMap<Integer, AmsEventFilter> mAmsEventFilters = new HashMap<>(8);
    public final JbedService.ClientChangedListener mClientChangedListener = new JbedService.ClientChangedListener() { // from class: com.esmertec.android.jbed.ams.AmsConnection.1
        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientAttached(JbedService.ClientProxy client) {
            LogTag.amsDebug(AmsConnection.TAG, "onClientAttached");
            synchronized (AmsConnection.this.mJbedClientMutx) {
                AmsConnection.this.mJbedClient = client;
                if (AmsConnection.this.tokenHolder == TokenHolder.EVENT_RUN) {
                    AmsConnection.this.tokenHolder = TokenHolder.NONE;
                }
                AmsConnection.this.mJbedClientMutx.notify();
            }
        }

        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientDetached() {
            LogTag.amsDebug(AmsConnection.TAG, "onClientDetached");
            synchronized (AmsConnection.this.mJbedClientMutx) {
                AmsConnection.this.mJbedClient = null;
            }
        }
    };
    private AmsEventFilter mDefaultFilter = new AmsEventFilter() { // from class: com.esmertec.android.jbed.ams.AmsConnection.2
        @Override // com.esmertec.android.jbed.ams.AmsConnection.AmsEventFilter
        public boolean onEvent(int eventId, int result, byte[] data) {
            synchronized (AmsConnection.this.mAmsClientMutx) {
                if (AmsConnection.this.mAmsClient == null) {
                    AmsConnection.this.mPendingEventQueue.add(new AmsEvent(eventId, result, data));
                }
            }
            return false;
        }
    };
    private AmsEventFilter mLifeCycleFilter = new AmsEventFilter() { // from class: com.esmertec.android.jbed.ams.AmsConnection.3
        @Override // com.esmertec.android.jbed.ams.AmsConnection.AmsEventFilter
        public boolean onEvent(int eventId, int result, byte[] data) {
            if (eventId == 18 || eventId == 11 || eventId == 17) {
                AmsConnection.this.handleMidletLifecycleEvent(eventId, result, data);
            }
            if (eventId == 11 && !AmsConnection.this.isBackgroundMode()) {
                try {
                    if (AmsConnection.this.mAmsClient != null && AmsConnection.this.mAmsClient.getId() != 0) {
                        return false;
                    }
                } catch (RemoteException e) {
                }
                if (AmsConnection.this.mJbedClient == null) {
                    LogTag.amsDebug(AmsConnection.TAG, "mLifeCycleFilter onEvent() EVENT_DESTROYED it's special case");
                    return false;
                }
                synchronized (AmsConnection.this.mJbedClientMutx) {
                    while (AmsConnection.this.mJbedClient == null) {
                        LogTag.amsWarning(AmsConnection.TAG, "want to finish jbed app activity, but it's unavailable! wait for a while! ");
                        try {
                            AmsConnection.this.mJbedClientMutx.wait();
                        } catch (InterruptedException e2) {
                        }
                    }
                    AmsConnection.this.mJbedClient.finish();
                }
            }
            return false;
        }
    };
    private AmsEventFilter mRunFilter = new AmsEventFilter() { // from class: com.esmertec.android.jbed.ams.AmsConnection.4
        @Override // com.esmertec.android.jbed.ams.AmsConnection.AmsEventFilter
        public boolean onEvent(int eventId, int result, byte[] data) {
            if (result != 1) {
                if (AmsConnection.this.tokenHolder == TokenHolder.EVENT_RUN) {
                    AmsConnection.this.tokenHolder = TokenHolder.NONE;
                }
                return false;
            }
            if (AmsConnection.this.getAmsClientAndWait() != null) {
                try {
                    AmsConnection.this.mAmsClient.handleEvent(eventId, result, data);
                } catch (RemoteException e) {
                    Log.e(AmsConnection.TAG, " faile to handle the ams event " + eventId, e);
                }
                synchronized (AmsConnection.this.mJbedClientMutx) {
                    if (AmsConnection.this.mJbedClient == null) {
                        try {
                            LogTag.amsDebug(AmsConnection.TAG, "mRunFilter(): block vm to wait the jbedclient ready!");
                            AmsConnection.this.mJbedClientMutx.wait();
                            LogTag.amsDebug(AmsConnection.TAG, "mRunFilter(): wakeup vm since jbedclient is ready!");
                        } catch (Exception e2) {
                        }
                    }
                }
            } else {
                JbedSelectorData midlet = new JbedSelectorData(new String(data).trim(), 1);
                if ((AmsConnection.this.mPowerOnMidlets == null || !AmsConnection.this.mPowerOnMidlets.remove(midlet)) && result == 1) {
                    AmsConnection.this.startJbedClientAndWait();
                }
            }
            return true;
        }
    };
    private AmsEventFilter mRequestPermissionFilter = new AmsEventFilter() { // from class: com.esmertec.android.jbed.ams.AmsConnection.5
        @Override // com.esmertec.android.jbed.ams.AmsConnection.AmsEventFilter
        public boolean onEvent(int eventId, int result, byte[] data) {
            synchronized (AmsConnection.this.mJbedClientMutx) {
                if (AmsConnection.this.mJbedClient == null) {
                    LogTag.amsDebug(AmsConnection.TAG, "mRequestPermissionFilter(): guess the jbed client is on the way. ! wait 2's!");
                    try {
                        AmsConnection.this.mJbedClientMutx.wait(2000L);
                    } catch (Exception e) {
                    }
                }
                if (AmsConnection.this.mJbedClient != null) {
                    return false;
                }
                AmsConnection.this.mPendingEventQueue.add(new AmsEvent(eventId, result, data));
                String root = null;
                if (JbedConfig.isSupportSoftKeyboard()) {
                    try {
                        DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
                        if (in.readBoolean()) {
                            root = in.readUTF();
                        }
                        in.close();
                    } catch (IOException e2) {
                        throw new RuntimeException("readJbedString IOException");
                    }
                }
                JbedSelectorData selectorData = new JbedSelectorData(root, -1);
                AmsConnection amsConnection = AmsConnection.this;
                boolean z = false;
                if (root != null) {
                    try {
                        z = !selectorData.isFullScreen();
                    } catch (Throwable e) {
                        Log.w(AmsConnection.TAG, "Unable to read MIDlet display settings", e);
                    }
                }
                amsConnection.startJbedClientAndWait(z);
                return true;
            }
        }
    };
    private AmsEventFilter mRequestPushFilter = new AmsEventFilter() { // from class: com.esmertec.android.jbed.ams.AmsConnection.6
        @Override // com.esmertec.android.jbed.ams.AmsConnection.AmsEventFilter
        public boolean onEvent(int eventId, int result, byte[] data) {
            AmsEvent event = new AmsEvent(eventId, result, data);
            if (AmsConnection.this.getAmsClientAndWait() == null) {
                AmsConnection.this.mPendingEventQueue.add(event);
                AmsConnection.this.startJbedClientAndWait();
                return true;
            }
            synchronized (AmsConnection.this.mJbedClientMutx) {
                try {
                    LogTag.amsDebug(AmsConnection.TAG, "mRequestPushFilter jbedclient=" + AmsConnection.this.mJbedClient + "  mRunEventProcessing=" + AmsConnection.this.tokenHolder);
                    if (AmsConnection.this.mJbedClient == null && AmsConnection.this.tokenHolder == TokenHolder.EVENT_RUN && AmsConnection.this.mAmsClient != null && AmsConnection.this.mAmsClient.getId() != 0) {
                        AmsConnection.this.mPendingEventQueue.add(event);
                        return true;
                    }
                } catch (RemoteException e) {
                    Log.e(AmsConnection.TAG, "fail to call getId");
                }
                AmsConnection.this.tokenHolder = TokenHolder.PUSH_REQUEST;
                return false;
            }
        }
    };

    private interface AmsEventFilter {
        boolean onEvent(int i, int i2, byte[] bArr);
    }

    private enum TokenHolder {
        NONE,
        PUSH_REQUEST,
        EVENT_RUN
    }

    private static native boolean nativeRequestLocalInstall(String url);

    public AmsConnection(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
        this.mAmsEventFilters.put(18, this.mLifeCycleFilter);
        this.mAmsEventFilters.put(11, this.mLifeCycleFilter);
        this.mAmsEventFilters.put(17, this.mLifeCycleFilter);
        this.mAmsEventFilters.put(2, this.mRunFilter);
        this.mAmsEventFilters.put(51, this.mRequestPermissionFilter);
        this.mAmsEventFilters.put(43, this.mRequestPushFilter);
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        this.mEventQueue.clear();
    }

    private static AmsEvent fetchEvent() {
        AmsEvent e = INSTANCE.mEventQueue.poll();
        if (e != null) {
            Log.i(TAG, "fetchAmsEvent() " + e.toString());
        } else {
            LogTag.amsWarning(TAG, "There is no any event, who call the fetchAmsEvent()?");
        }
        return e;
    }

    private static void handleEventEx(int eventId, int result, byte[] data) {
        INSTANCE.handleEvent(eventId, result, data);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void startJbedClientAndWait(boolean hasSoftKeyboard) {
        synchronized (this.mJbedClientMutx) {
            if (this.mJbedClient == null) {
                Intent jbedIntent = new Intent();
                jbedIntent.setClassName(this.mContext.getPackageName(), this.mContext.getPackageName() + ".app.JbedAppActivity");
                jbedIntent.setFlags(268435456);
                jbedIntent.putExtra(AmsConstants.FULL_SCREEN_FLAG, !hasSoftKeyboard);
                this.mContext.startActivity(jbedIntent);
                LogTag.amsDebug(TAG, "startJbedClientAndWait(): block vm to wait the jbedclient ready!");
                try {
                    this.mJbedClientMutx.wait();
                    LogTag.amsDebug(TAG, "startJbedClientAndWait(): wakeup vm to since jbedclient is ready!");
                } catch (Exception e) {
                }
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void startJbedClientAndWait() {
        startJbedClientAndWait(JbedConfig.isSupportSoftKeyboard());
    }

    /* JADX INFO: Access modifiers changed from: private */
    public IJbedAmsClient getAmsClientAndWait() {
        synchronized (this.mAmsClientMutx) {
            if (this.mAmsClient == null) {
                LogTag.amsDebug(TAG, "getAmsClientAndWait() amsClient is null! wait 2's");
                try {
                    this.mAmsClientMutx.wait(2000L);
                } catch (Exception e) {
                }
            }
        }
        return this.mAmsClient;
    }

    @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
    public void setPowerOnMidlets(List<JbedSelectorData> midlets) {
        this.mPowerOnMidlets = midlets;
    }

    @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
    public void requestEvent(int eventId, int result, byte[] data) throws DeadObjectException {
        if (eventId == 2) {
            if (this.tokenHolder == TokenHolder.NONE) {
                this.tokenHolder = TokenHolder.EVENT_RUN;
            } else if (this.tokenHolder == TokenHolder.PUSH_REQUEST) {
                try {
                    this.mAmsClient.handleEvent(2, 10000, new byte[]{AmsConstants.PERM_ANSWER_ALWAYS});
                } catch (RemoteException e) {
                    Log.e(TAG, " faile to handle the ams event " + eventId, e);
                }
                LogTag.amsWarning(TAG, "ingore EVENT_RUN since PUSH_REQUEST_HOLD get the token");
                return;
            }
        }
        if (eventId == 43 && this.tokenHolder == TokenHolder.PUSH_REQUEST) {
            this.tokenHolder = TokenHolder.NONE;
        }
        if (eventId == 67 && this.mPendingDrmConsraintRequest) {
            this.mPendingRequestEventQueue.add(new AmsEvent(eventId, result, data));
            return;
        }
        AmsEvent e2 = new AmsEvent(eventId, result, data);
        Log.i(TAG, "deliverEventToJbedVm() " + e2.toString());
        this.mEventQueue.add(e2);
        if (eventId == 5 && data != null) {
            String installUrl = new String(data).trim();
            try {
                if (nativeRequestLocalInstall(installUrl)) {
                    Log.i(TAG, "direct native local-install upcall queued for " + installUrl);
                } else {
                    Log.w(TAG, "direct native local-install upcall was not queued for " + installUrl);
                }
            } catch (Throwable t) {
                Log.w(TAG, "direct native local-install upcall failed for " + installUrl, t);
            }
        }
        this.mHandler.obtainMessage(5, 41, 0).sendToTarget();
    }

    public void handleEvent(int eventId, int result, byte[] data) {
        LogTag.amsDebug(TAG, "handleEvent() " + new AmsEvent(eventId, result, data).toString() + " mAmsClient=" + this.mAmsClient);
        AmsEventFilter filter = this.mAmsEventFilters.get(Integer.valueOf(eventId));
        if (filter == null) {
            filter = this.mDefaultFilter;
        }
        if (!filter.onEvent(eventId, result, data) && this.mAmsClient != null) {
            try {
                this.mAmsClient.handleEvent(eventId, result, data);
            } catch (RemoteException e) {
                Log.e(TAG, " faile to handle the ams event " + eventId, e);
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void handleMidletLifecycleEvent(int eventId, int result, byte[] data) {
        if (data == null) {
            throw new IllegalArgumentException(" data is empty for lifecycle event!!");
        }
        JbedSelectorData midlet = new JbedSelectorData(new String(data).trim(), result);
        if (eventId == 17) {
            midlet.mIsPaused = true;
            this.mRunningMidletList.remove(midlet);
            this.mRunningMidletList.add(midlet);
        }
        if (eventId == 18) {
            if (!this.mRunningMidletList.contains(midlet)) {
                this.mRunningMidletList.add(midlet);
                return;
            }
            midlet.mIsPaused = false;
            this.mRunningMidletList.remove(midlet);
            this.mRunningMidletList.add(midlet);
            return;
        }
        if (eventId == 11) {
            if (midlet.isSuite()) {
                for (JbedSelectorData tmp : this.mRunningMidletList) {
                    if (midlet.mRoot.equals(tmp.mRoot)) {
                        this.mRunningMidletList.remove(tmp);
                    }
                }
            } else {
                this.mRunningMidletList.remove(midlet);
            }
            this.mPendingDrmConsraintRequest = true;
        }
    }

    @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
    public void onClientConnected(IJbedAmsClient client) throws RemoteException {
        if (client == null) {
            throw new IllegalArgumentException("onClientConnected() pass a invalid client !!");
        }
        synchronized (this.mAmsClientMutx) {
            this.mAmsClient = client;
            this.mAmsClientMutx.notify();
        }
        while (true) {
            AmsEvent event = this.mPendingEventQueue.poll();
            if (event == null) {
                break;
            } else {
                this.mAmsClient.handleEvent(event.mId, event.mResult, event.mData);
            }
        }
        if (isBackgroundMode()) {
            this.mAmsClient.requestBackground();
            this.mAmsClient.finish();
        }
    }

    @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
    public void onClientDisconnected(IJbedAmsClient client) throws RemoteException {
        if (this.mAmsClient != null) {
            if (this.mAmsClient.getId() == client.getId()) {
                this.mAmsClient = null;
            } else {
                LogTag.amsDebug(TAG, " WARNNING : The connection has been connect to other client! so do nothing!");
            }
        }
        if (this.mPendingDrmConsraintRequest) {
            this.mPendingDrmConsraintRequest = false;
            while (true) {
                AmsEvent event = this.mPendingRequestEventQueue.poll();
                if (event != null) {
                    requestEvent(event.mId, event.mResult, event.mData);
                } else {
                    return;
                }
            }
        }
    }

    @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
    public List<JbedSelectorData> getRunningMidletList() {
        return this.mRunningMidletList;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public boolean isBackgroundMode() {
        JbedSettings settings = JbedSettings.getInstance(this.mContext);
        return !settings.isNativeAms() || settings.isRunTck();
    }
}
