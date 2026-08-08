package com.esmertec.android.jbed.service;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Point;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;
import android.widget.Toast;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.jsr.JbedMidpManager;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.LinkedBlockingQueue;

/* JADX INFO: loaded from: classes.dex */
public class JbedEngine implements JbedConstants {
    private static final int AIOC_POOL_INTERVAL = 500;
    private static final String TAG = "JbedEngine";
    static Map<Integer, Integer> VMCHANGE_ALLOW_MAPS = new HashMap(8);
    private JbedService.ClientProxy mClient;
    private Context mContext;
    Handler mHandler;
    public boolean mIsRotating;
    public boolean mIsRunFromHome;
    private JbedThread mJbedThread;
    private boolean mEventPending = false;
    private boolean mShutdownVM = false;
    private boolean mRestartVM = false;
    int mVmChangeReason = 1;
    final JbedService.LifecycleListener mLifecycleListener = new JbedService.LifecycleListener() { // from class: com.esmertec.android.jbed.service.JbedEngine.2
        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onCreate(Context context) {
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onDestroy(Context context) {
            JbedEngine.this.stopVmAndWait();
        }
    };
    final JbedService.ClientChangedListener mClientChangedListener = new JbedService.ClientChangedListener() { // from class: com.esmertec.android.jbed.service.JbedEngine.3
        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientAttached(JbedService.ClientProxy client) {
            JbedEngine.this.mClient = client;
            JbedEngine.this.mHandler.obtainMessage(7, 4, 0).sendToTarget();
        }

        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientDetached() {
            JbedEngine.this.mClient = null;
            JbedEngine.this.mHandler.obtainMessage(8, 8, 0).sendToTarget();
        }
    };

    /* JADX INFO: Access modifiers changed from: private */
    public native int nativeAiocPoll();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeFinalizeSubsystems();

    private native void nativeInitializePush();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeInitializeSubsystems(String[] strArr, int i);

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeJbedDoRawEvent(int i);

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeJbedInitVmLifeCycle();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeJbedRequestState(int i);

    /* JADX INFO: Access modifiers changed from: private */
    public native int nativeJbedRun();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeOnEnterRestartVMLoop();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeOnExitRestartVMLoop();

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeScreenSizeChanged(int i, int i2, int i3, int i4, int i5, int i6);

    public native void nativeUpdateSystemTime();

    /** Installs the ART JNI local-reference lifetime workaround for libjbedvm. */
    private static native void nativeInstallJniLifetimeHook();

    /** Releases the global JNI reference created by the compatibility hook. */
    private static native void nativeReleaseJniLifetimeHook();

    /** Lowers the VM scheduler quantum after NativeAms has reached foreground. */
    private static native void nativeEnableLowSchedulerQuantum();

    /** Resets legacy VM native-call flags after ART reports StackOverflowError. */
    private static native void nativeRecoverAfterStackOverflow();

    static {
        VMCHANGE_ALLOW_MAPS.put(2, 22);
        VMCHANGE_ALLOW_MAPS.put(1, 31);
        VMCHANGE_ALLOW_MAPS.put(4, 31);
        VMCHANGE_ALLOW_MAPS.put(8, 31);
        VMCHANGE_ALLOW_MAPS.put(16, 31);
    }

    public JbedEngine(final Service s) {
        this.mContext = s;
        this.mHandler = new Handler() { // from class: com.esmertec.android.jbed.service.JbedEngine.1
            @Override // android.os.Handler
            public void handleMessage(Message msg) {
                switch (msg.what) {
                    case 1:
                        LogTag.serviceDebug(JbedEngine.TAG, "FINISH SERVICE");
                        removeMessages(2);
                        JbedEngine.this.mJbedThread = null;
                        if (JbedEngine.this.mClient != null) {
                            JbedEngine.this.mClient.finish();
                        }
                        s.stopSelf();
                        return;
                    case 2:
                        int ret = JbedEngine.this.nativeAiocPoll();
                        if (ret > 0) {
                            JbedEngine.this.wakeUp();
                        }
                        Message pollNetworkMsg = obtainMessage(2);
                        if (!sendMessageDelayed(pollNetworkMsg, 500L)) {
                            Log.e(JbedEngine.TAG, "failed to put the JBED_EVT_POLL_NETWORK to queue.");
                            return;
                        }
                        return;
                    case 3:
                        if (msg.obj == null) {
                            throw new AssertionError();
                        }
                        ((Runnable) msg.obj).run();
                        JbedEngine.this.wakeUp();
                        return;
                    case 4:
                    default:
                        LogTag.serviceDebug(JbedEngine.TAG, "Unhandled message received. WHAT: " + msg.what);
                        return;
                    case 5:
                        JbedEngine.this.nativeJbedDoRawEvent(msg.arg1);
                        JbedEngine.this.wakeUp();
                        return;
                    case 6:
                        LogTag.serviceDebug(JbedEngine.TAG, " request vm to IDLE. priority=" + msg.arg1 + " oldReason=" + JbedEngine.this.mVmChangeReason);
                        JbedEngine.this.requestVmState(1, msg.arg1);
                        return;
                    case 7:
                        LogTag.serviceDebug(JbedEngine.TAG, " request vm to foreground. priority=" + msg.arg1 + " oldReason=" + JbedEngine.this.mVmChangeReason);
                        JbedEngine.this.requestVmState(3, msg.arg1);
                        return;
                    case 8:
                        LogTag.serviceDebug(JbedEngine.TAG, " request vm to background. priority=" + msg.arg1 + " oldReason=" + JbedEngine.this.mVmChangeReason);
                        JbedEngine.this.requestVmState(2, msg.arg1);
                        return;
                    case 9:
                        new ToastVmBlocker(JbedEngine.this).run();
                        return;
                    case 10:
                        if (msg.obj instanceof Runnable && JbedEngine.this.mJbedThread != null) {
                            JbedEngine.this.mJbedThread.mPendingEventQueue.add((Runnable) msg.obj);
                            JbedEngine.this.wakeUp();
                        }
                        return;
                }
            }
        };
    }

    private static class ToastVmBlocker {
        private static final int DURATION_SECOND = 3;
        private static final int INTERVAL_MILSECOND = 1000;
        private static final int MODULE_PROJECT = 6;
        private static final int STRING_ID = 22;
        private static final int VM_BLOCK_MILSECOND = 3500;
        private int mDurationSecond;
        private JbedEngine mEngine;

        static /* synthetic */ int access$810(ToastVmBlocker x0) {
            int i = x0.mDurationSecond;
            x0.mDurationSecond = i - 1;
            return i;
        }

        private ToastVmBlocker(JbedEngine engine) {
            this.mDurationSecond = 3;
            this.mEngine = engine;
        }

        public void run() {
            showMessage();
            requestBlockVm();
        }

        /* JADX WARN: Type inference failed for: r1v2, types: [com.esmertec.android.jbed.service.JbedEngine$ToastVmBlocker$1] */
        private void showMessage() {
            final Toast toast = Toast.makeText(this.mEngine.mContext, "", 1);
            toast.show();
            new Thread() { // from class: com.esmertec.android.jbed.service.JbedEngine.ToastVmBlocker.1
                @Override // java.lang.Thread, java.lang.Runnable
                public void run() {
                    while (ToastVmBlocker.this.mDurationSecond > 0) {
                        ToastVmBlocker.this.mEngine.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.service.JbedEngine.ToastVmBlocker.1.1
                            @Override // java.lang.Runnable
                            public void run() {
                                String text = JbedMidpManager.getString(6, 22);
                                toast.setText(text.replaceAll("%1", "" + ToastVmBlocker.this.mDurationSecond));
                            }
                        });
                        try {
                            Thread.sleep(1000L);
                        } catch (InterruptedException e) {
                        }
                        ToastVmBlocker.access$810(ToastVmBlocker.this);
                    }
                }
            }.start();
        }

        private void requestBlockVm() {
            if (this.mEngine.mJbedThread == null) {
                return;
            }
            this.mEngine.mJbedThread.mPendingEventQueue.add(new Runnable() { // from class: com.esmertec.android.jbed.service.JbedEngine.ToastVmBlocker.2
                @Override // java.lang.Runnable
                public void run() {
                    try {
                        synchronized (ToastVmBlocker.this.mEngine) {
                            Thread.sleep(3500L);
                        }
                    } catch (InterruptedException e) {
                    }
                }
            });
        }
    }

    public boolean startVm(int viewWidth, int viewHeight, int bytesPerPixel, int viewFullScreenWidth, int viewFullScreenHeight, boolean isRefreshViewSize, boolean forceSizeChanged) {
        if (this.mJbedThread == null) {
            this.mJbedThread = new JbedThread();
            if (JbedConfig.getDisplayPortraitWidth() != 0) {
                int orientation = this.mContext.getResources().getConfiguration().orientation;
                if (orientation == 2 && !this.mIsRunFromHome) {
                    viewWidth = JbedService.DisplayInfo.mLandscapeViewWidth;
                    viewHeight = JbedService.DisplayInfo.mLandscapeViewHeight;
                } else if (orientation == 1 && !this.mIsRunFromHome) {
                    viewWidth = JbedService.DisplayInfo.mPortraitViewWidth;
                    viewHeight = JbedService.DisplayInfo.mPortraitViewHeight;
                }
                viewFullScreenWidth = viewWidth;
                viewFullScreenHeight = viewHeight;
                this.mIsRunFromHome = false;
            }
            this.mJbedThread.setScreenInfo(viewWidth, viewHeight, bytesPerPixel, viewFullScreenWidth, viewFullScreenHeight, false, forceSizeChanged);
            this.mJbedThread.startAndWait();
            broadcastVmState(true);
            return true;
        }
        if (isRefreshViewSize) {
            this.mJbedThread.setScreenInfo(viewWidth, viewHeight, bytesPerPixel, viewFullScreenWidth, viewFullScreenHeight, true, forceSizeChanged);
            LogTag.serviceDebug(TAG, " the vm is running! just to change the screen size!");
        }
        return false;
    }

    void changeScreenifVmBackground(int viewWidth, int viewHeight, int bytesPerPixel, int viewFullScreenWidth, int viewFullScreenHeight) {
        if (this.mClient != null) {
            return;
        }
        try {
            this.mJbedThread.setScreenInfo(viewWidth, viewHeight, bytesPerPixel, viewFullScreenWidth, viewFullScreenHeight, true, false);
        } catch (Exception e) {
            LogTag.serviceDebug(TAG, " Catched Exception!! changeScreenifVmBackground ");
        }
    }

    void stopVmAndWait() {
        LogTag.serviceDebug(TAG, " requestVmDown mJbedThread=" + this.mJbedThread);
        if (this.mJbedThread != null) {
            requestVmState(0, -1);
            try {
                this.mJbedThread.join();
            } catch (Exception e) {
            }
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void wakeUp() {
        this.mEventPending = true;
        if (this.mJbedThread != null) {
            synchronized (this.mJbedThread) {
                this.mJbedThread.notify();
            }
        }
    }

    public void requestVmBackground() {
        requestVmState(2, 8);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void requestVmState(int newState, int newReason) {
        boolean isRotating = this.mIsRotating;
        this.mIsRotating = false;
        if (this.mJbedThread != null) {
            if ((VMCHANGE_ALLOW_MAPS.get(Integer.valueOf(this.mVmChangeReason)).intValue() & newReason) != 0) {
                if (!isRotating || newReason != 8) {
                    this.mVmChangeReason = newReason;
                    LogTag.serviceDebug(TAG, "requestVmState newState = " + newState + ",  newReason =" + newReason);
                    nativeJbedRequestState(newState);
                    wakeUp();
                    return;
                }
                return;
            }
            LogTag.serviceDebug(TAG, "ignore vm change request due to newReason " + newReason + " is not defined as subsequence of " + this.mVmChangeReason);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public String[] getCommandLine() {
        JbedSettings settings = JbedSettings.getInstance(this.mContext);
        String[] cmdLine = settings.getCommands();
        LogTag.serviceDebug(TAG, "jbed.settings=" + settings.toString());
        return cmdLine;
    }

    private void sizeChangingDone() {
        LogTag.serviceDebug(TAG, " sizeChanged has done!");
        synchronized (this.mJbedThread) {
            this.mJbedThread.notifyAll();
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void broadcastVmState(boolean isStarted) {
        String action = isStarted ? JbedConstants.ACTION_JBED_VM_STARTED : JbedConstants.ACTION_JBED_VM_STOPPED;
        Intent intent = new Intent(action);
        this.mContext.sendBroadcast(intent);
    }

    private class JbedThread extends Thread {
        private int mBytesPerPixel;
        boolean mIsVmInitialized;
        private BlockingQueue<Runnable> mPendingEventQueue;
        private int mViewFullScreenHeight;
        private int mViewFullScreenWidth;
        private int mViewHeight;
        private int mViewWidth;

        public JbedThread() {
            // Diagnostic headroom for the legacy native VM while libjbedcompat
            // lowers the scheduler quantum and assertion guard to reduce stack pressure.
            super(null, null, "JbedThread", 16L * 1024L * 1024L);
            this.mViewWidth = -1;
            this.mViewHeight = -1;
            this.mBytesPerPixel = -1;
            this.mViewFullScreenWidth = -1;
            this.mViewFullScreenHeight = -1;
            this.mIsVmInitialized = false;
            this.mPendingEventQueue = new LinkedBlockingQueue();
        }

        void startAndWait() {
            this.mIsVmInitialized = false;
            start();
            synchronized (this) {
                try {
                    if (!this.mIsVmInitialized) {
                        wait();
                    }
                } catch (Exception e) {
                }
            }
        }

        private void unblockStartupWaiterAfterNativeOverflow() {
            synchronized (this) {
                if (!this.mIsVmInitialized) {
                    Log.w(JbedEngine.TAG, "nativeJbedRun overflowed after foreground transition; unblocking AMS startup wait");
                    this.mIsVmInitialized = true;
                    notifyAll();
                }
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void setScreenInfo(int viewWidth, int viewHeight, int bytesPerPixel, int viewFullScreenWidth, int viewFullScreenHeight, boolean isVmRunning, boolean forceSizeChanged) {
            WindowManager windowManager = (WindowManager) JbedEngine.this.mContext.getSystemService("window");
            Display display = windowManager.getDefaultDisplay();
            Point displaySize = new Point();
            display.getSize(displaySize);
            int screenHeight = displaySize.y;
            int screenWidth = displaySize.x;
            final int maxSquareLength = Math.max(screenHeight, screenWidth);
            if (viewWidth <= 0 || viewHeight <= 0 || viewFullScreenWidth <= 0 || viewFullScreenHeight <= 0) {
                throw new IllegalArgumentException("setScreenInfo() invalid screen size!!!!");
            }
            boolean sizeChanged = (this.mViewWidth == viewWidth && this.mViewHeight == viewHeight && this.mViewFullScreenWidth == viewFullScreenWidth && this.mViewFullScreenHeight == viewFullScreenHeight) ? false : true;
            this.mViewWidth = viewWidth;
            this.mViewHeight = viewHeight;
            this.mBytesPerPixel = bytesPerPixel;
            this.mViewFullScreenWidth = viewFullScreenWidth;
            this.mViewFullScreenHeight = viewFullScreenHeight;
            if (sizeChanged || forceSizeChanged) {
                LogTag.serviceDebug(JbedEngine.TAG, "setScreenInfo(): Size changed!!");
                if (!isVmRunning) {
                    JbedEngine.this.nativeScreenSizeChanged(viewWidth, viewHeight, this.mBytesPerPixel, viewFullScreenWidth, viewFullScreenHeight, maxSquareLength);
                    return;
                }
                LogTag.serviceDebug(JbedEngine.TAG, "Pending screen size change");
                this.mPendingEventQueue.add(new Runnable() { // from class: com.esmertec.android.jbed.service.JbedEngine.JbedThread.1
                    @Override // java.lang.Runnable
                    public void run() {
                        JbedEngine.this.nativeScreenSizeChanged(JbedThread.this.mViewWidth, JbedThread.this.mViewHeight, JbedThread.this.mBytesPerPixel, JbedThread.this.mViewFullScreenWidth, JbedThread.this.mViewFullScreenHeight, maxSquareLength);
                    }
                });
                JbedEngine.this.wakeUp();
            }
        }

        @Override // java.lang.Thread, java.lang.Runnable
        public void run() {
            LogTag.serviceDebug(JbedEngine.TAG, "Jbed Thread Started");
            nativeInstallJniLifetimeHook();
            JbedEngine.this.nativeInitializeSubsystems(JbedEngine.this.getCommandLine(), 50);
            JbedEngine.this.mHandler.obtainMessage(2).sendToTarget();
            do {
                JbedEngine.this.nativeOnEnterRestartVMLoop();
                JbedEngine.this.nativeJbedInitVmLifeCycle();
                JbedEngine.this.nativeJbedRequestState(3);
                while (!JbedEngine.this.mShutdownVM) {
                    JbedEngine.this.mEventPending = false;
                    int delay;
                    try {
                        delay = JbedEngine.this.nativeJbedRun();
                    } catch (StackOverflowError e) {
                        Log.e(JbedEngine.TAG, "StackOverflow in nativeJbedRun, recovering native scheduler state and using delay fallback 100ms", e);
                        try {
                            nativeRecoverAfterStackOverflow();
                            nativeEnableLowSchedulerQuantum();
                        } catch (Throwable hookError) {
                            Log.w(JbedEngine.TAG, "unable to recover native scheduler state after nativeJbedRun overflow", hookError);
                        }
                        unblockStartupWaiterAfterNativeOverflow();
                        delay = 100;
                    }
                    if (delay >= 10 && !JbedEngine.this.mShutdownVM) {
                        synchronized (this) {
                            if (!JbedEngine.this.mEventPending) {
                                try {
                                    wait(delay, 0);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    }
                    Runnable r = this.mPendingEventQueue.poll();
                    if (r != null) {
                        r.run();
                    }
                }
                JbedEngine.this.mShutdownVM = false;
                JbedEngine.this.nativeOnExitRestartVMLoop();
            } while (JbedEngine.this.mRestartVM);
            LogTag.serviceDebug(JbedEngine.TAG, "--------- JBED SHUT DOWN ---------");
            JbedEngine.this.nativeFinalizeSubsystems();
            nativeReleaseJniLifetimeHook();
            JbedEngine.this.mHandler.obtainMessage(1).sendToTarget();
            JbedEngine.this.broadcastVmState(false);
        }
    }

    public void updateSystemTime() {
        nativeUpdateSystemTime();
    }

    private boolean vmStateChange(boolean commit, int oldState, int newState, int arg) {
        boolean res = false;
        if (commit) {
            LogTag.serviceDebug(TAG, "Finished transition from state " + oldState + " to newstate " + newState + "  reason " + arg);
            if (newState == 0) {
                res = true;
                this.mShutdownVM = true;
                switch (arg) {
                    case 0:
                        this.mShutdownVM = false;
                        break;
                    case 1:
                    case 2:
                    case 5:
                        this.mRestartVM = true;
                        break;
                    case 3:
                    case 4:
                    default:
                        this.mRestartVM = false;
                        break;
                }
            }
            synchronized (this.mJbedThread) {
                if (newState == 3) {
                    if (!this.mJbedThread.mIsVmInitialized) {
                        LogTag.serviceDebug(TAG, "wakeup main thread after vm has been started totally!!");
                        nativeEnableLowSchedulerQuantum();
                        this.mJbedThread.mIsVmInitialized = true;
                        this.mJbedThread.notify();
                        nativeInitializePush();
                    }
                }
            }
        } else {
            LogTag.serviceDebug(TAG, "Starting transition from state " + oldState + " state " + newState);
        }
        return res;
    }
}
