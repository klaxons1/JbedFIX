package com.esmertec.android.jbed.app;

import android.content.Context;
import android.graphics.PixelFormat;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.os.RemoteException;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.widget.AbsoluteLayout;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.ams.AmsClientBase;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;
import com.esmertec.android.jbed.nativeui.JbedTextFieldClient;
import com.esmertec.android.jbed.service.IJbedConnection;
import com.esmertec.android.jbed.service.IJbedService;
import com.esmertec.android.jbed.service.IJbedUiListener;
import com.google.android.collect.Lists;
import java.io.File;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class JbedView extends SurfaceView {
    public static final boolean DEBUG_PAINT = false;
    public static final int EVENT_ON_MIDLET_ERROR = 120004;
    public static final int EVENT_ON_MIDLET_STATE_CHANGED = 120005;
    public static final int EVENT_ON_SERVICE_DISCONNECTED = 120006;
    public static final int EVENT_ON_SERVICE_REQUEST_FINISH = 120002;
    public static final int EVENT_ON_SOFTBUTTON_CHANGED = 120007;
    public static final int EVENT_ON_SURFACE_CREATED = 120000;
    public static final int EVENT_ON_SURFACE_DESTROYED = 120001;
    public static final int EVENT_ON_VM_READY = 120003;
    public static final int JBED_VIEW_EVENT_BASE = 120000;
    private static final String TAG = "JbedView";
    public static boolean isMidletStarting = false;
    private boolean isVmStarted;
    private int mVirtualWidth;
    private int mVirtualHeight;
    private int mRequestedWidth;
    private int mRequestedHeight;
    private volatile MidletSizeInfo mFramebufferInfo;
    private ServiceConnector mConnector;
    private Handler mEventListenHandler;
    private IJbedUiListener mJbedUiListener;
    private AbsoluteLayout mNativeWidgetContainer;
    private JbedPainter mPainter;
    SurfaceHolder.Callback mSufaceCallback;
    IJbedVideoClient mVideoClient;

    public interface Callback {
        void onMidletStarted();

        void onServiceConnected();
    }

    public interface ServiceConnector {
        void connect(Callback callback);

        void disconnect();

        AmsClientBase getAmsClient();

        IJbedConnection getJbedConn();

        IJbedService getJbedService();

        IJbedTextFieldConnection getTextFieldConn();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeFinalizeAppView(Surface surface);

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeInitializeAppView(Surface surface);

    /* JADX INFO: Access modifiers changed from: private */
    public native void nativeRepaint(int i, int i2, int i3, int i4, int i5, int i6, float f, float f2);

    static {
        try {
            System.loadLibrary(JbedConstants.JBED_NATIVE_LIB);
        } catch (UnsatisfiedLinkError ule) {
            Log.e(TAG, "WARNING: Could not load jbed native lib jbedvm", ule);
        }
    }

    public void setRotateHappen(boolean b) {
        IJbedService s;
        if (this.mConnector != null && (s = this.mConnector.getJbedService()) != null) {
            try {
                s.setRotateHappen(b);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void requestVmBackground() {
        IJbedService s;
        if (this.mConnector != null && (s = this.mConnector.getJbedService()) != null) {
            try {
                s.requestVmBackground();
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public void setStartWay(boolean b) {
        IJbedService s;
        if (this.mConnector != null && (s = this.mConnector.getJbedService()) != null) {
            try {
                s.setStartWay(b);
            } catch (RemoteException e) {
                e.printStackTrace();
            }
        }
    }

    public JbedView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.isVmStarted = false;
        this.mSufaceCallback = new SurfaceHolder.Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "surfaceCreated...");
                JbedGraphics.attach(holder.getSurface(), new File(getContext().getApplicationInfo().dataDir, "tmp/jbed_gfx_shm").getPath(), getWidth(), getHeight());
                JbedView.this.mPainter = JbedView.this.new JbedPainter();
                JbedView.this.mConnector.connect(new Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1.1
                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onServiceConnected() {
                        JbedView.this.startVm();
                        try {
                            JbedView.this.mConnector.getJbedConn().setJbedClient(JbedView.this.new JbedClientImpl());
                            JbedView.this.mJbedUiListener = JbedView.this.mConnector.getJbedConn().getUiListener();
                            JbedTextFieldClient.create(JbedView.this.mJbedUiListener, JbedView.this.getContext(), JbedView.this.mNativeWidgetContainer, JbedView.this.mConnector.getTextFieldConn(), JbedView.this.getWidth());
                            Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_VM_READY).sendToTarget();
                        } catch (RemoteException e) {
                            throw new RuntimeException("failed to connect to jbed service!");
                        }
                    }

                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onMidletStarted() {
                        JbedView.this.mPainter.runPendingMessages();
                    }
                });
                Message.obtain(JbedView.this.mEventListenHandler, 120000).sendToTarget();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder holder, int f, int w, int h) {
                LogTag.appDebug(JbedView.TAG, "surfaceChanged...");
                JbedView.this.startVm();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "disconnect from service...");
                JbedTextFieldClient.dispose();
                JbedView.this.mConnector.disconnect();
                JbedView.this.isVmStarted = false;
                LogTag.appDebug(JbedView.TAG, "repaint workthread is quiting...");
                JbedView.this.mPainter.quit();
                try {
                    JbedView.this.mPainter.join();
                } catch (InterruptedException e) {
                }
                LogTag.appDebug(JbedView.TAG, "finalize the native app view....");
                JbedGraphics.detach();
                LogTag.appDebug(JbedView.TAG, "Surface destroyed");
                Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_SURFACE_DESTROYED);
            }
        };
        setup();
    }

    public JbedView(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.isVmStarted = false;
        this.mSufaceCallback = new SurfaceHolder.Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "surfaceCreated...");
                JbedGraphics.attach(holder.getSurface(), new File(getContext().getApplicationInfo().dataDir, "tmp/jbed_gfx_shm").getPath(), getWidth(), getHeight());
                JbedView.this.mPainter = JbedView.this.new JbedPainter();
                JbedView.this.mConnector.connect(new Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1.1
                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onServiceConnected() {
                        JbedView.this.startVm();
                        try {
                            JbedView.this.mConnector.getJbedConn().setJbedClient(JbedView.this.new JbedClientImpl());
                            JbedView.this.mJbedUiListener = JbedView.this.mConnector.getJbedConn().getUiListener();
                            JbedTextFieldClient.create(JbedView.this.mJbedUiListener, JbedView.this.getContext(), JbedView.this.mNativeWidgetContainer, JbedView.this.mConnector.getTextFieldConn(), JbedView.this.getWidth());
                            Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_VM_READY).sendToTarget();
                        } catch (RemoteException e) {
                            throw new RuntimeException("failed to connect to jbed service!");
                        }
                    }

                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onMidletStarted() {
                        JbedView.this.mPainter.runPendingMessages();
                    }
                });
                Message.obtain(JbedView.this.mEventListenHandler, 120000).sendToTarget();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder holder, int f, int w, int h) {
                LogTag.appDebug(JbedView.TAG, "surfaceChanged...");
                JbedView.this.startVm();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "disconnect from service...");
                JbedTextFieldClient.dispose();
                JbedView.this.mConnector.disconnect();
                JbedView.this.isVmStarted = false;
                LogTag.appDebug(JbedView.TAG, "repaint workthread is quiting...");
                JbedView.this.mPainter.quit();
                try {
                    JbedView.this.mPainter.join();
                } catch (InterruptedException e) {
                }
                LogTag.appDebug(JbedView.TAG, "finalize the native app view....");
                JbedGraphics.detach();
                LogTag.appDebug(JbedView.TAG, "Surface destroyed");
                Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_SURFACE_DESTROYED);
            }
        };
        setup();
    }

    public JbedView(Context context) {
        super(context);
        this.isVmStarted = false;
        this.mSufaceCallback = new SurfaceHolder.Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "surfaceCreated...");
                JbedGraphics.attach(holder.getSurface(), new File(getContext().getApplicationInfo().dataDir, "tmp/jbed_gfx_shm").getPath(), getWidth(), getHeight());
                JbedView.this.mPainter = JbedView.this.new JbedPainter();
                JbedView.this.mConnector.connect(new Callback() { // from class: com.esmertec.android.jbed.app.JbedView.1.1
                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onServiceConnected() {
                        JbedView.this.startVm();
                        try {
                            JbedView.this.mConnector.getJbedConn().setJbedClient(JbedView.this.new JbedClientImpl());
                            JbedView.this.mJbedUiListener = JbedView.this.mConnector.getJbedConn().getUiListener();
                            JbedTextFieldClient.create(JbedView.this.mJbedUiListener, JbedView.this.getContext(), JbedView.this.mNativeWidgetContainer, JbedView.this.mConnector.getTextFieldConn(), JbedView.this.getWidth());
                            Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_VM_READY).sendToTarget();
                        } catch (RemoteException e) {
                            throw new RuntimeException("failed to connect to jbed service!");
                        }
                    }

                    @Override // com.esmertec.android.jbed.app.JbedView.Callback
                    public void onMidletStarted() {
                        JbedView.this.mPainter.runPendingMessages();
                    }
                });
                Message.obtain(JbedView.this.mEventListenHandler, 120000).sendToTarget();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder holder, int f, int w, int h) {
                LogTag.appDebug(JbedView.TAG, "surfaceChanged...");
                JbedView.this.startVm();
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder holder) {
                LogTag.appDebug(JbedView.TAG, "disconnect from service...");
                JbedTextFieldClient.dispose();
                JbedView.this.mConnector.disconnect();
                JbedView.this.isVmStarted = false;
                LogTag.appDebug(JbedView.TAG, "repaint workthread is quiting...");
                JbedView.this.mPainter.quit();
                try {
                    JbedView.this.mPainter.join();
                } catch (InterruptedException e) {
                }
                LogTag.appDebug(JbedView.TAG, "finalize the native app view....");
                JbedGraphics.detach();
                LogTag.appDebug(JbedView.TAG, "Surface destroyed");
                Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_SURFACE_DESTROYED);
            }
        };
        setup();
    }

    private void setup() {
        JbedGraphics.initialize();
        getHolder().addCallback(this.mSufaceCallback);
    }

    /** Sets the MIDP canvas size; zero in both dimensions uses the view size. */
    public void setVirtualSize(int width, int height) {
        if (width < 0 || height < 0 || (width == 0) != (height == 0))
            throw new IllegalArgumentException("Both virtual dimensions must be positive or zero");
        if (mVirtualWidth == width && mVirtualHeight == height) return;
        mVirtualWidth = width;
        mVirtualHeight = height;
        requestLayout();
        if (isVmStarted) startVm();
    }

    public void setup(Handler eventListenHandler, ServiceConnector connector) {
        if (eventListenHandler == null) {
            throw new IllegalArgumentException("connector doesn't allow to be null!");
        }
        this.mEventListenHandler = eventListenHandler;
        this.mConnector = connector;
        if (this.mConnector == null) {
            this.mConnector = new SimpleServiceConnectorImpl(getContext(), this.mEventListenHandler);
        }
    }

    private boolean onKey(KeyEvent keyEvent) {
        LogTag.appVerbose(TAG, "notifyOnKey keyCode=" + keyEvent.getKeyCode());
        try {
            if (this.mJbedUiListener != null) {
                return this.mJbedUiListener.notifyOnKey(keyEvent);
            }
            return true;
        } catch (RemoteException e) {
            throw new RuntimeException("JbedView failed to call onKey()");
        }
    }

    public boolean dispatchGameKey(KeyEvent event) {
        return onKey(event);
    }

    @Override // android.view.View, android.view.KeyEvent.Callback
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (isMidletStarting && keyCode == 4) {
            return true;
        }
        boolean isConsumed = onKey(event);
        if (isConsumed) {
            return true;
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override // android.view.View, android.view.KeyEvent.Callback
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (isMidletStarting && keyCode == 4) {
            return true;
        }
        boolean isConsumed = onKey(event);
        if (isConsumed) {
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override // android.view.View
    public boolean onTouchEvent(MotionEvent motionEvent) {
        try {
            int action = motionEvent.getActionMasked();
            if (action == MotionEvent.ACTION_POINTER_DOWN || action == MotionEvent.ACTION_POINTER_UP)
                return true;
            if (action == MotionEvent.ACTION_CANCEL) action = MotionEvent.ACTION_UP;
            MidletSizeInfo frame = mFramebufferInfo;
            int width = frame != null ? frame.width : mVirtualWidth;
            int height = frame != null ? frame.height : mVirtualHeight;
            if (width <= 0) width = getWidth();
            if (height <= 0) height = getHeight();
            int x = (int) (motionEvent.getX() * width / Math.max(1, getWidth()));
            int y = (int) (motionEvent.getY() * height / Math.max(1, getHeight()));
            x = Math.max(0, Math.min(x, width - 1));
            y = Math.max(0, Math.min(y, height - 1));
            LogTag.appVerbose(TAG, "notifyOnTouchEvent x=" + x + " y=" + y);
            requestFocusFromTouch();
            if (this.mJbedUiListener != null) {
                return this.mJbedUiListener.notifyOnTouchEvent(x, y, action);
            }
            return true;
        } catch (RemoteException e) {
            throw new RuntimeException(" failed to call notifyOnTouchEvent");
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void startVm() {
        try {
            int width = mVirtualWidth > 0 ? mVirtualWidth : getWidth();
            int height = mVirtualHeight > 0 ? mVirtualHeight : getHeight();
            if (mConnector != null && mConnector.getJbedService() != null && width > 0 && height > 0
                    && (!isVmStarted || width != mRequestedWidth || height != mRequestedHeight)) {
                PixelFormat pixFormat = new PixelFormat();
                PixelFormat.getPixelFormatInfo(4, pixFormat);
                this.mConnector.getJbedService().startVm(width, height, pixFormat.bytesPerPixel,
                        width, height, true, !isVmStarted);
                mRequestedWidth = width;
                mRequestedHeight = height;
                this.isVmStarted = true;
            }
        } catch (RemoteException e) {
            Log.e(TAG, "failed to connect to jbed service!");
        }
    }

    class JbedPainter extends HandlerThread {
        public Handler mHandler;
        private boolean mIsAlive;
        private volatile boolean mIsShutDown;
        private ArrayList<Message> mPendingQueue;

        public JbedPainter() {
            super("[JbedPainter]");
            this.mIsAlive = true;
            this.mPendingQueue = Lists.newArrayList();
            start();
            this.mHandler = new Handler(getLooper()) { // from class: com.esmertec.android.jbed.app.JbedView.JbedPainter.1
                @Override // android.os.Handler
                public void handleMessage(Message msg) {
                    MidletSizeInfo msi = (MidletSizeInfo) msg.obj;
                    mFramebufferInfo = msi;
                    JbedGraphics.repaint(msi.width, msi.height, msi.stride);
                    if (JbedView.isMidletStarting) {
                        JbedView.isMidletStarting = false;
                    }
                }
            };
        }

        @Override
        public synchronized boolean quit() {
            this.mIsAlive = false;
            this.mPendingQueue = null;
            return super.quit();
        }

        public synchronized void runPendingMessages() {
            if (this.mPendingQueue != null) {
                for (Message message : this.mPendingQueue) {
                    message.sendToTarget();
                }
                this.mPendingQueue.clear();
                this.mPendingQueue = null;
            }
        }

        public synchronized void handleOrEnqueue(Message message) {
            if (!this.mIsShutDown) {
                if (this.mPendingQueue != null) {
                    this.mPendingQueue.add(message);
                } else if (this.mIsAlive) {
                    message.sendToTarget();
                }
            }
        }
    }

    class MidletSizeInfo {
        final int width;
        final int height;
        final int stride;

        MidletSizeInfo(int width, int height, int stride) {
            this.width = width;
            this.height = height;
            this.stride = stride;
        }
    }

    class JbedClientImpl extends IJbedClient.Stub {
        private Handler mHandler = new Handler();


        JbedClientImpl() {
        }

        @Override // com.esmertec.android.jbed.app.IJbedClient
        public void finish() throws DeadObjectException {
            JbedView.this.mPainter.mIsShutDown = true;
            Message.obtain(JbedView.this.mEventListenHandler, JbedView.EVENT_ON_SERVICE_REQUEST_FINISH).sendToTarget();
        }

        @Override // com.esmertec.android.jbed.app.IJbedClient
        public void repaint(int clipLeft, int clipTop, int clipRight, int clipBottom, int width, int height, int stride) throws DeadObjectException {
            if (JbedView.this.mPainter.mHandler == null) {
                throw new AssertionError();
            }
            JbedView.this.mPainter.mHandler.removeMessages(4);
            Message msg = JbedView.this.mPainter.mHandler.obtainMessage(4);
            msg.arg1 = ((clipLeft & JbedConstants.JBED_CONSTRAINT_CONSTRAINT_MASK) << 16) | (clipTop & JbedConstants.JBED_CONSTRAINT_CONSTRAINT_MASK);
            msg.arg2 = ((clipRight & JbedConstants.JBED_CONSTRAINT_CONSTRAINT_MASK) << 16) | (clipBottom & JbedConstants.JBED_CONSTRAINT_CONSTRAINT_MASK);
            MidletSizeInfo msi = JbedView.this.new MidletSizeInfo(width, height, stride);
            msg.obj = msi;
            JbedView.this.mPainter.handleOrEnqueue(msg);
        }

        @Override // com.esmertec.android.jbed.app.IJbedClient
        public IJbedVideoClient getVideoClient() throws RemoteException {
            return JbedView.this.mVideoClient;
        }

        @Override // com.esmertec.android.jbed.app.IJbedClient
        public void onSoftButtonChanged(String leftButton, String rightButton) {
            String[] buttonText = {leftButton, rightButton};
            JbedView.this.mEventListenHandler.obtainMessage(JbedView.EVENT_ON_SOFTBUTTON_CHANGED, buttonText).sendToTarget();
        }
    }

    public void runMidlet(String root, int no) {
        if (this.mConnector == null || this.mConnector.getAmsClient() == null) {
            throw new IllegalStateException("please set connector first");
        }
        this.mConnector.getAmsClient().requestRunEvent(root, no);
    }

    public void runMidlet(String name) {
        if (this.mConnector == null || this.mConnector.getAmsClient() == null) {
            throw new IllegalStateException("please set connector first");
        }
        this.mConnector.getAmsClient().requestRunEvent(name);
    }

    public void destroyMidlet(String root, int no) {
        if (this.mConnector == null || this.mConnector.getAmsClient() == null) {
            throw new IllegalStateException("please set connector first");
        }
        this.mConnector.getAmsClient().requestDestroyEvent(root, no);
    }

    public void destroyMidlet(String name) {
        if (this.mConnector == null || this.mConnector.getAmsClient() == null) {
            throw new IllegalStateException("please set connector first");
        }
        this.mConnector.getAmsClient().destroyMidlet(name);
    }

    public void pauseMidlet(String root, int no) {
    }

    public void setOverlayView(AbsoluteLayout nativeWidgetView) {
        this.mNativeWidgetContainer = nativeWidgetView;
    }
}
