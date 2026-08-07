package com.esmertec.android.jbed.app;

import android.graphics.Bitmap;
import android.graphics.Rect;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.RemoteException;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import android.view.View;
import android.widget.AbsoluteLayout;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.jsr.JbedVideoPlayerState;
import com.esmertec.android.jbed.jsr.JbedVideoView;
import java.io.OutputStream;

/* JADX INFO: loaded from: classes.dex */
public class JbedVideoClientImpl extends IJbedVideoClient.Stub {
    static final /* synthetic */ boolean $assertionsDisabled;
    private static final boolean DEBUG = false;
    public static final int OP_CLOSE = 2;
    public static final int OP_DRAIN = 12;
    public static final int OP_GETCHUNKSIZE = 11;
    public static final int OP_GETDURATION = 6;
    public static final int OP_GETMEDIATYPE = 16;
    public static final int OP_GETMETADATA = 18;
    public static final int OP_GETPOSITION = 7;
    public static final int OP_GETRECSIZE = 13;
    public static final int OP_GETSUPPORTEDCONTROLS = 17;
    public static final int OP_GETVOLUME = 9;
    private static final int OP_GET_SOURCE_HEIGHT = 400;
    private static final int OP_GET_SOURCE_WIDTH = 401;
    public static final int OP_ISPLAYING = 1001;
    public static final int OP_PAUSE = 4;
    public static final int OP_PAUSERECORD = 23;
    public static final int OP_PLAY = 3;
    public static final int OP_RELEASEDEVICE = 15;
    public static final int OP_RESET = 1;
    public static final int OP_SETDATASIZE = 14;
    public static final int OP_SETPOSITION = 8;
    public static final int OP_SETVOLUME = 10;
    private static final int OP_SET_DISPLAY_LOCATION = 404;
    private static final int OP_SET_DISPLAY_SIZE = 405;
    private static final int OP_SET_VIDEOREGION_LOCATION = 402;
    private static final int OP_SET_VIDEOREGION_SIZE = 403;
    private static final int OP_SET_VISIBLE = 406;
    public static final int OP_STARTRECORD = 22;
    public static final int OP_STOP = 5;
    public static final int OP_STOPRECORD = 24;
    public static final int RC_ERROR_COMMAND_IGNORED = -2;
    public static final int RC_ERROR_OPERATION_FAILED = -1;
    public static final int RC_OK = 0;
    private static final String TAG = "JbedVideoClientImpl";
    private static final String VIDEO_RECORD_PROTOCOL = "capture://video";
    private OutputStream mCaptureDataStream;
    private View mFrameParent;
    private Handler mHandler;
    private IJbedVideoClientListener mListener;
    private JbedVideoPlayerState mState;
    private Surface mSurface;
    private SurfaceHolder mVideoHolder;
    private View mVideoParent;
    private AbsoluteLayout mVideoRegionView;
    private JbedVideoView mVideoView;

    static {
        $assertionsDisabled = !JbedVideoClientImpl.class.desiredAssertionStatus();
    }

    class RectUpdater implements Runnable {
        private static final boolean DEBUG = false;
        private static final String TAG = "RectUpdater";
        private Handler mHandler;
        private int mHeight;
        private int mLeft;
        private int mTop;
        private View mView;
        private int mWidth;

        public RectUpdater(View v, Handler hd, int x, int y, int w, int h) {
            this.mView = v;
            this.mHandler = hd;
            this.mLeft = x;
            this.mTop = y;
            this.mWidth = w;
            this.mHeight = h;
        }

        @Override // java.lang.Runnable
        public void run() {
            this.mView.setLayoutParams(new AbsoluteLayout.LayoutParams(this.mWidth, this.mHeight, this.mLeft, this.mTop));
            this.mView.setVisibility(0);
            JbedVideoClientImpl.this.mVideoParent.setVisibility(0);
            JbedVideoClientImpl.this.mFrameParent.postInvalidate();
        }

        public void update() {
            this.mHandler.post(this);
        }
    }

    public JbedVideoClientImpl(Handler handler, AbsoluteLayout videoRegionView, JbedVideoView videoView, View videoParent, View frameParent) {
        this.mHandler = handler;
        this.mVideoView = videoView;
        this.mVideoRegionView = videoRegionView;
        this.mVideoParent = videoParent;
        this.mFrameParent = frameParent;
        this.mSurface = this.mVideoView.getHolder().getSurface();
        Surface.openTransaction();
        this.mSurface.setLayer(JbedConstants.VIDEO_VIEW_SURFACE_LAYER);
        Surface.closeTransaction();
        this.mState = new JbedVideoPlayerState();
    }

    void updateView(AbsoluteLayout videoRegionView, JbedVideoView videoView, View videoParent, View frameParent) {
        this.mVideoRegionView = videoRegionView;
        this.mVideoView = videoView;
        this.mVideoParent = videoParent;
        this.mFrameParent = frameParent;
    }

    private synchronized void setVisible(boolean isVisible) {
        if (!$assertionsDisabled && this.mSurface == null) {
            throw new AssertionError();
        }
        if (isVisible) {
            updateViewRect(this.mVideoRegionView);
            updateViewRect(this.mVideoView);
        } else {
            this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedVideoClientImpl.1
                @Override // java.lang.Runnable
                public void run() {
                    AbsoluteLayout absoluteLayout = JbedVideoClientImpl.this.mVideoRegionView;
                    JbedVideoView unused = JbedVideoClientImpl.this.mVideoView;
                    int iWidth = JbedVideoView.mDefaultLocation.width();
                    JbedVideoView unused2 = JbedVideoClientImpl.this.mVideoView;
                    int iHeight = JbedVideoView.mDefaultLocation.height();
                    JbedVideoView unused3 = JbedVideoClientImpl.this.mVideoView;
                    int i = JbedVideoView.mDefaultLocation.left;
                    JbedVideoView unused4 = JbedVideoClientImpl.this.mVideoView;
                    absoluteLayout.setLayoutParams(new AbsoluteLayout.LayoutParams(iWidth, iHeight, i, JbedVideoView.mDefaultLocation.top));
                    JbedVideoView jbedVideoView = JbedVideoClientImpl.this.mVideoView;
                    JbedVideoView unused5 = JbedVideoClientImpl.this.mVideoView;
                    int iWidth2 = JbedVideoView.mDefaultLocation.width();
                    JbedVideoView unused6 = JbedVideoClientImpl.this.mVideoView;
                    jbedVideoView.setLayoutParams(new AbsoluteLayout.LayoutParams(iWidth2, JbedVideoView.mDefaultLocation.height(), -2147483647, -2147483647));
                }
            });
        }
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public int prepareData(String dataSource) throws DeadObjectException {
        this.mState.dataSource = dataSource;
        if (dataSource.startsWith(VIDEO_RECORD_PROTOCOL)) {
            this.mState.isCapture = true;
            if (!this.mVideoView.openCamera()) {
                return -1;
            }
            String subDataSource = dataSource.substring(VIDEO_RECORD_PROTOCOL.length(), dataSource.length());
            this.mVideoView.setVideoRecordPath(subDataSource);
            return 0;
        }
        this.mState.isCapture = false;
        try {
            this.mVideoView.setVideoPath(dataSource);
            this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedVideoClientImpl.2
                @Override // java.lang.Runnable
                public void run() {
                    JbedVideoClientImpl.this.mVideoView.callRequestLayout();
                }
            });
            return 1;
        } catch (Exception e) {
            Log.e(TAG, "failed to setVideoPath(" + dataSource + ")");
            return -1;
        }
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public void setListener(IJbedVideoClientListener listener) throws DeadObjectException {
        this.mListener = listener;
        this.mVideoView.setListener(listener);
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public int operation(int playerId, int opId, int param1, int param2, int param3) {
        switch (opId) {
            case 1:
                this.mVideoView.seekTo(0);
                return 0;
            case 2:
                this.mState.isPlaying = false;
                if (this.mState.isCapture) {
                    this.mVideoView.closeCamera();
                } else {
                    this.mVideoView.stopPlayback();
                }
                setVisible(false);
                return 0;
            case 3:
                this.mState.isPlaying = true;
                if (this.mState.isCapture) {
                    return 0;
                }
                this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedVideoClientImpl.3
                    @Override // java.lang.Runnable
                    public void run() {
                        JbedVideoClientImpl.this.mVideoView.start();
                    }
                });
                return 0;
            case 4:
                this.mState.isPlaying = false;
                this.mVideoView.pause();
                return 0;
            case 5:
                this.mState.isPlaying = false;
                this.mVideoView.pause();
                this.mVideoView.seekTo(0);
                return 0;
            case 6:
                int ret = this.mVideoView.getDuration();
                return ret;
            case 7:
                int ret2 = this.mVideoView.getCurrentPosition();
                this.mState.position = ret2;
                return ret2;
            case 8:
                this.mVideoView.seekTo(param1);
                int ret3 = this.mVideoView.getCurrentPosition();
                return ret3;
            case 15:
            case OP_SET_VIDEOREGION_LOCATION /* 402 */:
            case OP_SET_VIDEOREGION_SIZE /* 403 */:
            case OP_SET_DISPLAY_LOCATION /* 404 */:
            case OP_SET_DISPLAY_SIZE /* 405 */:
                return 0;
            case 22:
                this.mVideoView.startRecord();
                return 0;
            case 23:
                this.mVideoView.stopRecord();
                return 0;
            case 24:
                this.mVideoView.stopRecord();
                return 0;
            case OP_GET_SOURCE_HEIGHT /* 400 */:
                if (this.mState.isCapture) {
                    return JbedVideoView.CAMERA_DEFAULT_HEIGHT;
                }
                int ret4 = this.mVideoView.getVideoHeight();
                return ret4;
            case OP_GET_SOURCE_WIDTH /* 401 */:
                if (this.mState.isCapture) {
                    return JbedVideoView.CAMERA_DEFAULT_WIDTH;
                }
                int ret5 = this.mVideoView.getVideoWidth();
                return ret5;
            case OP_SET_VISIBLE /* 406 */:
                this.mState.isVisible = param1 != 0;
                setVisible(this.mState.isVisible);
                return 0;
            case 1001:
                if (!this.mState.isCapture && !this.mVideoView.isPlaying()) {
                    return 0;
                }
                return 1;
            default:
                return -1;
        }
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public byte[] getSnapshotFromCamera() throws DeadObjectException {
        return this.mVideoView.takePicture();
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public Bitmap getSnapshotFromMedia() throws DeadObjectException {
        int currentPos = this.mVideoView.getCurrentPosition();
        Bitmap bitmap = this.mVideoView.getFrameAt(currentPos);
        return bitmap;
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public void reconnectCamera() {
        this.mVideoView.closeCamera();
        this.mVideoView.openCamera();
    }

    public void savePlayerState() {
        if (this.mVideoView != null && this.mListener != null && this.mState.dataSource != null) {
            this.mState.position = this.mVideoView.getCurrentPosition();
            this.mState.suspend = JbedVideoPlayerState.Suspend.DOING;
            try {
                this.mListener.onSuspend(this.mState);
                setVisible(false);
                if (this.mState.isCapture) {
                    this.mVideoView.closeCamera();
                } else {
                    this.mVideoView.stopPlayback();
                }
            } catch (RemoteException e) {
                throw new RuntimeException("failed to call jbedVideoListener.onSuspend(), RemoteException");
            }
        }
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public void restorePlayerState(JbedVideoPlayerState state) {
        this.mState = state;
        setVisible(this.mState.isVisible);
        this.mVideoView.resume(this.mState);
    }

    private void updateViewRect(View v) {
        if (v == null) {
            throw new IllegalArgumentException("view is null");
        }
        if (v instanceof JbedVideoView) {
            if (this.mState.displayViewRect != null) {
                new RectUpdater(v, this.mHandler, this.mState.displayViewRect.left, this.mState.displayViewRect.top, this.mState.displayViewRect.width(), this.mState.displayViewRect.height()).update();
            }
        } else if (this.mState.regionViewRect != null) {
            new RectUpdater(v, this.mHandler, this.mState.regionViewRect.left, this.mState.regionViewRect.top, this.mState.regionViewRect.width(), this.mState.regionViewRect.height()).update();
        }
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public void updateDisplayRect(Rect rect) {
        this.mState.displayViewRect.set(rect);
        updateViewRect(this.mVideoView);
    }

    @Override // com.esmertec.android.jbed.app.IJbedVideoClient
    public void updateRegionRect(Rect rect) {
        this.mState.regionViewRect.set(rect);
        updateViewRect(this.mVideoRegionView);
    }
}
