package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.os.DeadObjectException;
import android.os.Handler;
import android.util.Log;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.service.IJbedUiListener;
import com.esmertec.android.jbed.service.JbedService;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class JbedLcduiManager implements JbedService.LifecycleListener, JbedConstants {
    private static final boolean DEBUG = false;
    private static JbedLcduiManager INSTANCE = null;
    private static HashMap<Integer, Integer> JbedLcduiKeyMap = null;
    private static final String TAG = "JbedLcduiManager";
    private static boolean mIsPreviousKeyAtl = false;
    private static boolean mIsPreviousKeyShift = false;
    private JbedService.ClientProxy mClient;
    private Context mContext;
    private Handler mHandler;
    private boolean mIsPendingRepaint;
    private SoftBar mSoftBar = new SoftBar();
    public final IJbedUiListener mUiEventListener = new IJbedUiListener.Stub() { // from class: com.esmertec.android.jbed.jsr.JbedLcduiManager.1
        private void sendRawEvent(int event) {
            JbedLcduiManager.this.mHandler.obtainMessage(5, event, 0).sendToTarget();
        }

        @Override // com.esmertec.android.jbed.service.IJbedUiListener
        public boolean notifyOnKey(KeyEvent keyEvent) throws DeadObjectException {
            int keyCode = keyEvent.getKeyCode();
            int keyAction = keyEvent.getAction();
            KeyEvent event = keyEvent;
            if (keyCode == -100) {
                JbedLcduiManager.this.mHandler.obtainMessage(3, new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedLcduiManager.1.1
                    @Override // java.lang.Runnable
                    public void run() {
                        JbedLcduiManager.this.nativeMvmSwitchMideltList();
                    }
                }).sendToTarget();
                return true;
            }
            if (!JbedLcduiManager.mIsPreviousKeyAtl || !keyEvent.isPrintingKey() || keyCode == 29 || keyCode == 32 || keyCode == 33 || keyCode == 42 || keyCode == 41 || keyCode == 51 || keyCode == 47 || keyCode == 54) {
                if (JbedLcduiManager.mIsPreviousKeyShift && keyEvent.isPrintingKey() && ((keyCode < 7 || keyCode > 16) && keyCode != 56)) {
                    event = new KeyEvent(0L, 0L, keyAction, keyCode, 0, 1);
                }
            } else {
                event = new KeyEvent(0L, 0L, keyAction, keyCode, 0, 2);
            }
            if (keyAction == 1) {
                boolean unused = JbedLcduiManager.mIsPreviousKeyAtl = keyCode == 57;
                boolean unused2 = JbedLcduiManager.mIsPreviousKeyShift = keyCode == 59;
            }
            if (keyCode == 1 || keyCode == 4 || keyCode == 24 || keyCode == 25 || keyCode == 5 || keyCode == 82 || keyCode == 60 || keyCode == 58 || keyCode == 63) {
                return false;
            }
            switch (keyAction) {
                case 0:
                case 1:
                    int lcduiAction = keyAction == 1 ? 4 : 3;
                    Integer lcduiKeyObj = (Integer) JbedLcduiManager.JbedLcduiKeyMap.get(Integer.valueOf(keyCode));
                    KeyCharacterMap kmap = KeyCharacterMap.load(event.getKeyboardDevice());
                    int lcduiKey = lcduiKeyObj == null ? kmap.get(keyCode, event.getMetaState()) : lcduiKeyObj.intValue();
                    sendRawEvent((lcduiKey << 4) | lcduiAction);
                    return true;
                default:
                    return false;
            }
        }

        @Override // com.esmertec.android.jbed.service.IJbedUiListener
        public boolean notifyOnTouchEvent(int x, int y, int motionEvent) throws DeadObjectException {
            int lcduiEvent;
            switch (motionEvent) {
                case 0:
                    int i = (0 & 3) << 4;
                    lcduiEvent = ((x & 8191) << 19) | 1 | ((y & 8191) << 6) | 0;
                    break;
                case 1:
                    int i2 = (0 & 3) << 4;
                    lcduiEvent = ((x & 8191) << 19) | 2 | ((y & 8191) << 6) | 0;
                    break;
                case 2:
                    lcduiEvent = ((x & 8191) << 19) | 0 | ((y & 8191) << 6);
                    break;
                default:
                    return false;
            }
            sendRawEvent(lcduiEvent);
            return true;
        }
    };
    public final JbedService.ClientChangedListener mClientChangedListener = new JbedService.ClientChangedListener() { // from class: com.esmertec.android.jbed.jsr.JbedLcduiManager.2
        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientAttached(JbedService.ClientProxy client) {
            JbedLcduiManager.this.mClient = client;
            if (JbedLcduiManager.this.mIsPendingRepaint) {
                JbedLcduiManager.this.mClient.repaintAll();
                JbedLcduiManager.this.mIsPendingRepaint = false;
            }
            JbedLcduiManager.this.mSoftBar.onSoftButtonChanged();
        }

        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientDetached() {
            JbedLcduiManager.this.mClient = null;
            JbedLcduiManager.this.mSoftBar.reset();
        }
    };

    private static native void nativeInitialization();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeMvmSwitchMideltList();

    static {
        nativeInitialization();
        JbedLcduiKeyMap = new HashMap<>(10);
        JbedLcduiKeyMap.put(19, -1);
        JbedLcduiKeyMap.put(20, -2);
        JbedLcduiKeyMap.put(22, -4);
        JbedLcduiKeyMap.put(21, -3);
        JbedLcduiKeyMap.put(23, -5);
        JbedLcduiKeyMap.put(66, -5);
        JbedLcduiKeyMap.put(67, -8);
        JbedLcduiKeyMap.put(-6, -6);
        JbedLcduiKeyMap.put(-7, -7);
    }

    private class SoftBar {
        private String mLeft;
        private String mRight;

        private SoftBar() {
            this.mLeft = null;
            this.mRight = null;
        }

        void onSoftButtonChanged(String left, String right) {
            this.mLeft = left;
            this.mRight = right;
            if (JbedLcduiManager.this.mClient != null) {
                JbedLcduiManager.this.mClient.onSoftButtonChanged(this.mLeft, this.mRight);
            }
        }

        void onSoftButtonChanged() {
            if (JbedLcduiManager.this.mClient != null && JbedConfig.isSupportSoftKeyboard()) {
                JbedLcduiManager.this.mClient.onSoftButtonChanged(this.mLeft, this.mRight);
            }
        }

        void reset() {
            this.mLeft = null;
            this.mRight = null;
        }
    }

    public JbedLcduiManager(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        INSTANCE = null;
    }

    private static void repaint(int clipLeft, int clipTop, int clipRight, int clipBottom, int width, int height, float pScale, float lScale) {
        if (INSTANCE.mClient == null) {
            INSTANCE.mIsPendingRepaint = true;
        } else {
            INSTANCE.mClient.repaint(clipLeft, clipTop, clipRight, clipBottom, width, height, pScale, lScale);
        }
    }

    private static void onSoftButtonChanged(String left, String right) {
        JbedService.ClientProxy clientProxy = INSTANCE.mClient;
        synchronized (JbedService.ClientProxy.mSBUpdateMutex) {
            try {
                JbedService.ClientProxy clientProxy2 = INSTANCE.mClient;
                if (JbedService.ClientProxy.requestSoftButtonUpdate) {
                    JbedService.ClientProxy clientProxy3 = INSTANCE.mClient;
                    JbedService.ClientProxy.mSBUpdateMutex.wait();
                }
                JbedService.ClientProxy clientProxy4 = INSTANCE.mClient;
                JbedService.ClientProxy.requestSoftButtonUpdate = false;
                INSTANCE.mSoftBar.onSoftButtonChanged(left, right);
            } catch (InterruptedException ie) {
                Log.w(TAG, "onSoftButtonChanged throw InterruptedException : " + ie);
            }
        }
    }

    private static int getFontSize() {
        return JbedConfig.getFontSize();
    }
}
