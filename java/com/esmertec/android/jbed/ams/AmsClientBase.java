package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.os.Handler;
import android.os.RemoteException;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.jsr.JbedDrmManager;
import com.google.android.collect.Lists;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class AmsClientBase implements AmsConstants {
    private static final String TAG = "AmsClient";
    protected static SerialEventProxy mSerialEventProxy;
    private static long sIdCounter = 0;
    private IJbedAmsConnection mAmsConn;
    protected Context mContext;
    private AmsEventHandler.Factory mFactory;
    private Handler mHandler;
    private int mId;
    private JbedSelector mSelector;
    public StubImpl mStub;

    public static class StubImpl extends IJbedAmsClient.Stub {
        private AmsClientBase mOwner;

        private StubImpl(AmsClientBase owner) {
            this.mOwner = owner;
        }

        @Override // com.esmertec.android.jbed.ams.IJbedAmsClient
        public synchronized void finish() throws RemoteException {
            if (this.mOwner != null) {
                this.mOwner.finish();
            }
        }

        @Override // com.esmertec.android.jbed.ams.IJbedAmsClient
        public synchronized long getId() throws RemoteException {
            return this.mOwner != null ? this.mOwner.getId() : -1L;
        }

        @Override // com.esmertec.android.jbed.ams.IJbedAmsClient
        public synchronized void handleEvent(int eventId, int result, byte[] data) throws RemoteException {
            if (this.mOwner != null) {
                this.mOwner.handleEvent(eventId, result, data);
            }
        }

        @Override // com.esmertec.android.jbed.ams.IJbedAmsClient
        public synchronized void requestBackground() throws RemoteException {
            if (this.mOwner != null) {
                this.mOwner.requestBackground();
            }
        }

        public synchronized void release() {
            this.mOwner = null;
        }
    }

    public AmsClientBase(Context context, Handler handler, IJbedAmsConnection conn, long id, AmsEventHandler.Factory factory) {
        this.mStub = null;
        this.mContext = context;
        this.mAmsConn = conn;
        this.mHandler = handler;
        this.mFactory = factory;
        this.mId = (int) id;
        this.mStub = new StubImpl();
    }

    private boolean processSerialEvent(int eventId, int result, byte[] data) {
        if (mSerialEventProxy == null) {
            return false;
        }
        log(Thread.currentThread().getName() + " processSerialEvent " + getEventName(eventId));
        if (!mSerialEventProxy.isExpectedEvent(eventId)) {
            Log.w(TAG, "WARNING: mSerialEventProxy get a unexptected event " + getEventName(eventId));
            return false;
        }
        try {
            mSerialEventProxy.onResponseReceived(eventId, result, data);
            synchronized (mSerialEventProxy) {
                mSerialEventProxy.mIsFinish = true;
                mSerialEventProxy.notifyAll();
            }
            return true;
        } catch (IOException e) {
            throw new IllegalArgumentException("Failed to setResponseRawData() " + getEventName(eventId));
        }
    }

    protected void handleEventInternal(int eventId, int result, byte[] data, Object obj) {
        AmsEventHandler eventHandler = this.mFactory.buildAmsHandler(eventId);
        if (eventHandler != null) {
            eventHandler.mEvent = new AmsEvent(eventId, result, data);
            eventHandler.mEvent.mObj = obj;
            eventHandler.mContext = this.mContext;
            eventHandler.mHandler = this.mHandler;
            eventHandler.mClient = this;
            try {
                eventHandler.parseData(eventHandler.mEvent.mData);
                this.mHandler.post(eventHandler);
            } catch (IOException e1) {
                Log.e(TAG, "ERROR: failed to " + eventHandler.toString() + ".parseData()", e1);
                throw new IllegalArgumentException("Failed to parseData() " + eventHandler.mEvent.mData.toString());
            }
        }
    }

    public void handleEvent(int eventId, int result, byte[] data) {
        String drmRoot;
        JbedSelectorData midlet;
        log("handleEvent : event = " + getEventName(eventId) + "   result = " + result);
        if (!processSerialEvent(eventId, result, data)) {
            handleEventInternal(eventId, result, data, null);
            if (eventId == 11 && JbedConfig.getCustomerName().equals("LGE") && (midlet = getSelector().findMidlet((drmRoot = new String(data).trim()), result)) != null && midlet.isDrmProtected()) {
                requestDrmConstraint(drmRoot, result);
            }
        }
    }

    public void requestBackground() {
        bringMidletToForeground(false);
    }

    public void finish() {
        this.mHandler.obtainMessage(10001).sendToTarget();
    }

    public long getId() {
        return this.mId;
    }

    protected void requestEvent(int eventId, int result, byte[] data) {
        log("requestEvent : event = " + getEventName(eventId) + "   result = " + result);
        try {
            this.mAmsConn.requestEvent(eventId, result, data);
        } catch (RemoteException e) {
            Log.e(TAG, "failed to call requestEvent");
        }
    }

    protected void requestEvent(int eventId) {
        requestEvent(eventId, 0, (byte[]) null);
    }

    protected void requestEvent(int eventId, int result) {
        requestEvent(eventId, result, (byte[]) null);
    }

    protected void requestEvent(int eventId, int result, String strData) {
        byte[] data = null;
        if (strData != null) {
            try {
                data = strData.getBytes("UTF-8");
            } catch (UnsupportedEncodingException e) {
                Log.e(TAG, "Failed to decode [" + strData + "] to utf-8");
            }
        }
        requestEvent(eventId, result, data);
    }

    public void requestRunEvent(String root, int no) {
        if (JbedConfig.Ams.isNotifyDrmConstraintEnable()) {
            JbedSelectorData midlet = findMidlet(root, no);
            if (midlet.isDrmProtected()) {
                if (JbedConfig.getCustomerName().equals("LGE")) {
                    if (!isRuningMidlet(root, no)) {
                        midlet.mIsExpired = checkExpiredMidlet(root);
                        if (midlet.mIsExpired) {
                            if (getDrmMethodType(midlet) == 3) {
                                requestDrmPurchaseRoConfirmEvent(2, midlet);
                                return;
                            } else {
                                handleEventInternal(10001, 7, midlet.mRoot.getBytes(), midlet);
                                return;
                            }
                        }
                    }
                } else if (JbedConfig.getCustomerName().equals("TW")) {
                    if (!isRuningMidlet(root, no)) {
                        midlet.mIsExpired = checkExpiredMidlet(root);
                        if (midlet.mIsExpired) {
                            if (getDrmMethodType(midlet) == 3) {
                                if (midlet.isDrmPending()) {
                                    requestDrmPurchaseRoConfirmEvent(3, midlet);
                                    return;
                                } else {
                                    requestDrmPurchaseRoConfirmEvent(2, midlet);
                                    return;
                                }
                            }
                            handleEventInternal(10001, 7, midlet.mRoot.getBytes(), midlet);
                            return;
                        }
                    }
                } else {
                    requestDrmConstraint(root, no);
                }
            }
        }
        this.mHandler.sendMessageAtFrontOfQueue(this.mHandler.obtainMessage(10012));
        int no2 = getSelector().getPreMIDletWithSameClass(root, no, this.mContext);
        requestEvent(2, no2, root.getBytes());
        if (isRuningMidlet(root, no2)) {
            handleEventInternal(2, 1, root.getBytes(), null);
        }
    }

    public void requestRunEvent(String name) {
        JbedSelectorData midlet = getSelector().findMidletByName(name);
        if (midlet == null) {
            throw new IllegalArgumentException("Midlet" + name + "not found");
        }
        requestRunEvent(midlet.mRoot, midlet.mNo);
    }

    public void requestDrmConstraint(String root, int no) {
        requestEvent(67, no, root.getBytes());
    }

    public void requestDestroyEvent(String root, int no) {
        requestEvent(10, no, root);
    }

    public void destroyMidlet(String name) {
        JbedSelectorData midlet = getSelector().findMidletByName(name);
        if (midlet == null) {
            throw new IllegalArgumentException("Midlet" + name + "not found");
        }
        requestDestroyEvent(midlet.mRoot, midlet.mNo);
    }

    public static String getEventName(int eventId) {
        return eventId < 10000 ? eventNames[eventId] : eventAndroidNames[eventId - 10000];
    }

    public void bringMidletToForeground(boolean isFullScreen) {
        this.mHandler.obtainMessage(10000, Boolean.valueOf(isFullScreen)).sendToTarget();
    }

    public void requestDrmPurchaseRoConfirmEvent(int event, JbedSelectorData midlet) {
        handleEventInternal(10014, event, midlet.mRoot.getBytes(), midlet);
    }

    public void requestPlatformRequestAnswer(int result) {
        requestEvent(74, result);
    }

    protected boolean isRuningMidlet(String root, int no) {
        List<JbedSelectorData> runningMidletList = getRunningMidletList();
        for (JbedSelectorData midlet : runningMidletList) {
            if (midlet.mRoot.equals(root) && (midlet.mNo == no || no == 0)) {
                return true;
            }
        }
        return false;
    }

    public boolean isRuningSuite(String root) {
        return isRuningMidlet(root, 0);
    }

    public List<JbedSelectorData> getRunningMidletList() {
        Lists.newArrayList();
        try {
            List<JbedSelectorData> runningMidletList = this.mAmsConn.getRunningMidletList();
            return runningMidletList;
        } catch (RemoteException e) {
            throw new RuntimeException("failed to call getRunningMidletList");
        }
    }

    public String toString() {
        return "amsclient-" + JbedConstants.JBED_ACTIVITY_NAMES[this.mId];
    }

    void log(String msg) {
        LogTag.amsDebug(TAG, toString() + " " + msg);
    }

    abstract class SerialEventProxy {
        private int[] mExpectedResponseEventIds;
        boolean mIsFinish;

        abstract Object getResponse();

        abstract void onResponseReceived(int i, int i2, byte[] bArr) throws IOException;

        SerialEventProxy(int[] expectedResponseEventIds) {
            this.mExpectedResponseEventIds = expectedResponseEventIds;
        }

        boolean isExpectedEvent(int actualEventId) {
            int[] arr$ = this.mExpectedResponseEventIds;
            for (int eventId : arr$) {
                if (eventId == actualEventId) {
                    return true;
                }
            }
            return false;
        }

        void requestEvent(int eventId, int result, byte[] data) {
            AmsClientBase.this.requestEvent(eventId, result, data);
            synchronized (this) {
                try {
                    if (!this.mIsFinish) {
                        wait(3000L);
                    } else {
                        LogTag.amsDebug(AmsClientBase.TAG, " requestSerialEvent() " + AmsClientBase.getEventName(eventId) + " has done before this! doesn't wait");
                    }
                } catch (InterruptedException e) {
                }
            }
        }
    }

    boolean checkExpiredMidlet(String root) {
        Log.d(TAG, "checkExpiredMidlet root:" + root);
        mSerialEventProxy = new SerialEventProxy(new int[]{66}) { // from class: com.esmertec.android.jbed.ams.AmsClientBase.1
            boolean mResult;

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            void onResponseReceived(int eventId, int result, byte[] data) throws IOException {
                this.mResult = result != 1;
            }

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            Object getResponse() {
                return new boolean[]{this.mResult};
            }
        };
        mSerialEventProxy.requestEvent(66, 0, root.getBytes());
        boolean result = ((boolean[]) mSerialEventProxy.getResponse())[0];
        mSerialEventProxy = null;
        return result;
    }

    public int getDrmMethodType(String filePath) {
        Log.d(TAG, "getDrmMethodType filePath:" + filePath);
        mSerialEventProxy = new SerialEventProxy(new int[]{68}) { // from class: com.esmertec.android.jbed.ams.AmsClientBase.2
            int mResult;

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            void onResponseReceived(int eventId, int result, byte[] data) throws IOException {
                this.mResult = result;
            }

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            Object getResponse() {
                return new Integer(this.mResult);
            }
        };
        mSerialEventProxy.requestEvent(68, 0, filePath.getBytes());
        int result = ((Integer) mSerialEventProxy.getResponse()).intValue();
        mSerialEventProxy = null;
        return result;
    }

    public int getDrmMethodType(JbedSelectorData midlet) {
        if (midlet.mDrmMethodType == 0 && midlet.isDrmProtected()) {
            String drmFileName = midlet.mStoragePath + midlet.mRoot + JbedDrmManager.DRM_FILENAME;
            midlet.mDrmMethodType = JbedDrmManager.getDrmMethodType(drmFileName);
        }
        log("getDrmMethodType : mDrmMethodType = " + midlet.mDrmMethodType);
        return midlet.mDrmMethodType;
    }

    protected JbedSelector getSelector() {
        if (this.mSelector == null) {
            this.mSelector = new JbedSelector(JbedSettings.getInstance(this.mContext.getApplicationContext()).getBaseDir());
        }
        this.mSelector.loadFromFiles();
        return this.mSelector;
    }

    public void refreshSelector() {
        getSelector().loadFromFiles();
    }

    public JbedSelectorData getMildetByHierarchyNames(String[] names) {
        return getSelector().findByHierarchyNames(names);
    }

    public List<JbedSelectorData> getMergedChildren(JbedSelectorData parent) {
        return getSelector().getMergedChildren(parent);
    }

    public List<JbedSelectorData> getAllFolders(boolean includeHidden, boolean includeReadonly, boolean includeRoot) {
        return getSelector().getAllFolders(includeHidden, includeReadonly, includeRoot);
    }

    public List<JbedSelectorData> getAllFolders(boolean includeHidden, boolean includeReadonly, boolean includeRoot, boolean sdcardSelected) {
        return getSelector().getAllFolders(includeHidden, includeReadonly, includeRoot, sdcardSelected);
    }

    public List<JbedSelectorData> getAllSuites(JbedSelectorData folder, boolean includeHidden, boolean includeReadonly) {
        return getSelector().getAllSuites(folder, includeHidden, includeReadonly);
    }

    JbedSelectorData findMidlet(String root, int no) {
        return getSelector().findMidlet(root, no);
    }

    JbedSelectorData getFolderByMidlet(String root, int no) {
        return getSelector().getFolderByMidlet(root, no);
    }

    JbedSelectorData findSuite(String root) {
        return getSelector().findSuite(root);
    }
}
