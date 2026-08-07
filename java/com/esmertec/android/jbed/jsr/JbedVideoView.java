package com.esmertec.android.jbed.jsr;

import android.R;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.hardware.Camera;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Handler;
import android.os.RemoteException;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.View;
import android.widget.MediaController;
import android.widget.Toast;
import com.esmertec.android.jbed.app.IJbedVideoClientListener;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

/* JADX INFO: loaded from: classes.dex */
public class JbedVideoView extends SurfaceView implements MediaController.MediaPlayerControl {
    public static final int CAMERA_DEFAULT_HEIGHT = 220;
    public static final int CAMERA_DEFAULT_WIDTH = 176;
    private static final boolean DEBUG = false;
    private static final String FLAG = "JbedVideoView";
    private static final int MAX_RESUME_TRY = 10;
    private static final int MODULE_PROJECT = 6;
    private static final int STRING_ID = 21;
    public static Rect mDefaultLocation = new Rect(0, 0, 1, 1);
    private MediaPlayer.OnBufferingUpdateListener mBufferingUpdateListener;
    private Camera mCamera;
    private byte[] mCameraData;
    private final byte[] mCameraMutex;
    private MediaPlayer.OnCompletionListener mCompletionListener;
    private int mCurrentBufferPercentage;
    private String mDataSource;
    private int mDuration;
    private MediaPlayer.OnErrorListener mErrorListener;
    private View mFrameParent;
    private Handler mHandler;
    private boolean mIsPrepared;
    private JpegPictureCallback mJpegPictureCallback;
    private IJbedVideoClientListener mListener;
    private MediaController mMediaController;
    private MediaPlayer mMediaPlayer;
    private MediaPlayer.OnCompletionListener mOnCompletionListener;
    private MediaPlayer.OnErrorListener mOnErrorListener;
    private MediaPlayer.OnPreparedListener mOnPreparedListener;
    MediaPlayer.OnPreparedListener mPreparedListener;
    private RawPictureCallback mRawPictureCallback;
    private MediaRecorder mRecorder;
    SurfaceHolder.Callback mSHCallback;
    private int mSeekWhenPrepared;
    private TestShutterCallback mShutterCallback;
    MediaPlayer.OnVideoSizeChangedListener mSizeChangedListener;
    private boolean mSnapshotInProgress;
    private boolean mStartWhenPrepared;
    private int mSurfaceHeight;
    private SurfaceHolder mSurfaceHolder;
    private int mSurfaceWidth;
    private int mVideoHeight;
    private View mVideoParent;
    private String mVideoRecordPath;
    private boolean mVideoSizeReady;
    private int mVideoWidth;
    private Object mutex;
    private int resumeTried;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public JbedVideoView(Context context) {
        super(context);
        this.mVideoSizeReady = false;
        this.mutex = new Object();
        this.mSurfaceHolder = null;
        this.mMediaPlayer = null;
        this.mShutterCallback = new TestShutterCallback();
        this.mRawPictureCallback = new RawPictureCallback();
        this.mJpegPictureCallback = new JpegPictureCallback();
        this.mCameraMutex = new byte[0];
        this.mHandler = new Handler();
        this.resumeTried = 0;
        this.mSizeChangedListener = new MediaPlayer.OnVideoSizeChangedListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.2
            @Override // android.media.MediaPlayer.OnVideoSizeChangedListener
            public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                JbedVideoView.this.mVideoWidth = mp.getVideoWidth();
                JbedVideoView.this.mVideoHeight = mp.getVideoHeight();
                if (JbedVideoView.this.mVideoWidth != 0 && JbedVideoView.this.mVideoHeight != 0) {
                    JbedVideoView.this.getHolder().setFixedSize(JbedVideoView.this.mVideoWidth, JbedVideoView.this.mVideoHeight);
                    if (JbedVideoView.this.isPlaying()) {
                        JbedVideoView.this.setVisibility(0);
                        JbedVideoView.this.mVideoParent.setVisibility(0);
                        JbedVideoView.this.mFrameParent.invalidate();
                    }
                    JbedVideoView.this.mVideoSizeReady = true;
                    synchronized (JbedVideoView.this.mutex) {
                        try {
                            JbedVideoView.this.mutex.notifyAll();
                        } catch (Exception e) {
                        }
                    }
                }
            }
        };
        this.mPreparedListener = new MediaPlayer.OnPreparedListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.3
            @Override // android.media.MediaPlayer.OnPreparedListener
            public void onPrepared(MediaPlayer mp) {
                JbedVideoView.this.mIsPrepared = true;
                if (JbedVideoView.this.mOnPreparedListener != null) {
                    JbedVideoView.this.mOnPreparedListener.onPrepared(JbedVideoView.this.mMediaPlayer);
                }
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.setEnabled(true);
                }
                JbedVideoView.this.mVideoWidth = mp.getVideoWidth();
                JbedVideoView.this.mVideoHeight = mp.getVideoHeight();
                if (JbedVideoView.this.mVideoWidth == 0 || JbedVideoView.this.mVideoHeight == 0) {
                    if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                        JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                        JbedVideoView.this.mSeekWhenPrepared = 0;
                    }
                    if (JbedVideoView.this.mStartWhenPrepared) {
                        JbedVideoView.this.mMediaPlayer.start();
                        JbedVideoView.this.mStartWhenPrepared = false;
                        return;
                    }
                    return;
                }
                JbedVideoView.this.getHolder().setFixedSize(JbedVideoView.this.mVideoWidth, JbedVideoView.this.mVideoHeight);
                if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                    JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                    JbedVideoView.this.mSeekWhenPrepared = 0;
                }
                if (JbedVideoView.this.mStartWhenPrepared) {
                    JbedVideoView.this.mMediaPlayer.start();
                    JbedVideoView.this.mStartWhenPrepared = false;
                    if (JbedVideoView.this.mMediaController != null) {
                        JbedVideoView.this.mMediaController.show();
                    }
                } else if (!JbedVideoView.this.isPlaying() && ((JbedVideoView.this.mSeekWhenPrepared != 0 || JbedVideoView.this.getCurrentPosition() > 0) && JbedVideoView.this.mMediaController != null)) {
                    JbedVideoView.this.mMediaController.show(0);
                }
                JbedVideoView.this.mVideoSizeReady = true;
                synchronized (JbedVideoView.this.mutex) {
                    try {
                        JbedVideoView.this.mutex.notifyAll();
                    } catch (Exception e) {
                    }
                }
            }
        };
        this.mCompletionListener = new MediaPlayer.OnCompletionListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.4
            @Override // android.media.MediaPlayer.OnCompletionListener
            public void onCompletion(MediaPlayer mp) {
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mOnCompletionListener != null) {
                    JbedVideoView.this.mOnCompletionListener.onCompletion(JbedVideoView.this.mMediaPlayer);
                }
                try {
                    if (JbedVideoView.this.mListener != null) {
                        JbedVideoView.this.mListener.onCompletion();
                    }
                } catch (RemoteException e) {
                }
            }
        };
        this.mErrorListener = new MediaPlayer.OnErrorListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.5
            @Override // android.media.MediaPlayer.OnErrorListener
            public boolean onError(MediaPlayer mp, int a, int b) {
                int messageId;
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mOnErrorListener != null && JbedVideoView.this.mOnErrorListener.onError(JbedVideoView.this.mMediaPlayer, a, b)) {
                    return true;
                }
                if (JbedVideoView.this.getWindowToken() != null) {
                    JbedVideoView.this.mContext.getResources();
                    if (a == 200) {
                        messageId = R.string.VideoView_error_text_invalid_progressive_playback;
                    } else {
                        messageId = R.string.VideoView_error_text_unknown;
                    }
                    new AlertDialog.Builder(JbedVideoView.this.mContext).setTitle(R.string.VideoView_error_title).setMessage(messageId).setPositiveButton(R.string.VideoView_error_button, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.5.1
                        @Override // android.content.DialogInterface.OnClickListener
                        public void onClick(DialogInterface dialog, int whichButton) {
                            if (JbedVideoView.this.mOnCompletionListener != null) {
                                JbedVideoView.this.mOnCompletionListener.onCompletion(JbedVideoView.this.mMediaPlayer);
                            }
                        }
                    }).setCancelable(false).show();
                }
                return true;
            }
        };
        this.mBufferingUpdateListener = new MediaPlayer.OnBufferingUpdateListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.6
            @Override // android.media.MediaPlayer.OnBufferingUpdateListener
            public void onBufferingUpdate(MediaPlayer mp, int percent) {
                JbedVideoView.this.mCurrentBufferPercentage = percent;
            }
        };
        this.mSHCallback = new SurfaceHolder.Callback() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.7
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
                JbedVideoView.this.mSurfaceWidth = w;
                JbedVideoView.this.mSurfaceHeight = h;
                if (JbedVideoView.this.mMediaPlayer != null && JbedVideoView.this.mIsPrepared && JbedVideoView.this.mVideoWidth == w && JbedVideoView.this.mVideoHeight == h) {
                    if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                        JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                        JbedVideoView.this.mSeekWhenPrepared = 0;
                    }
                    if (JbedVideoView.this.mMediaController != null) {
                        JbedVideoView.this.mMediaController.show();
                    }
                }
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder holder) {
                JbedVideoView.this.mSurfaceHolder = holder;
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder holder) {
                JbedVideoView.this.mSurfaceHolder = null;
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mMediaPlayer != null) {
                    JbedVideoView.this.mMediaPlayer.reset();
                    JbedVideoView.this.mMediaPlayer.release();
                    JbedVideoView.this.mMediaPlayer = null;
                }
            }
        };
        initVideoView();
    }

    public JbedVideoView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
        initVideoView();
    }

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public JbedVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.mVideoSizeReady = false;
        this.mutex = new Object();
        this.mSurfaceHolder = null;
        this.mMediaPlayer = null;
        this.mShutterCallback = new TestShutterCallback();
        this.mRawPictureCallback = new RawPictureCallback();
        this.mJpegPictureCallback = new JpegPictureCallback();
        this.mCameraMutex = new byte[0];
        this.mHandler = new Handler();
        this.resumeTried = 0;
        this.mSizeChangedListener = new MediaPlayer.OnVideoSizeChangedListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.2
            @Override // android.media.MediaPlayer.OnVideoSizeChangedListener
            public void onVideoSizeChanged(MediaPlayer mp, int width, int height) {
                JbedVideoView.this.mVideoWidth = mp.getVideoWidth();
                JbedVideoView.this.mVideoHeight = mp.getVideoHeight();
                if (JbedVideoView.this.mVideoWidth != 0 && JbedVideoView.this.mVideoHeight != 0) {
                    JbedVideoView.this.getHolder().setFixedSize(JbedVideoView.this.mVideoWidth, JbedVideoView.this.mVideoHeight);
                    if (JbedVideoView.this.isPlaying()) {
                        JbedVideoView.this.setVisibility(0);
                        JbedVideoView.this.mVideoParent.setVisibility(0);
                        JbedVideoView.this.mFrameParent.invalidate();
                    }
                    JbedVideoView.this.mVideoSizeReady = true;
                    synchronized (JbedVideoView.this.mutex) {
                        try {
                            JbedVideoView.this.mutex.notifyAll();
                        } catch (Exception e) {
                        }
                    }
                }
            }
        };
        this.mPreparedListener = new MediaPlayer.OnPreparedListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.3
            @Override // android.media.MediaPlayer.OnPreparedListener
            public void onPrepared(MediaPlayer mp) {
                JbedVideoView.this.mIsPrepared = true;
                if (JbedVideoView.this.mOnPreparedListener != null) {
                    JbedVideoView.this.mOnPreparedListener.onPrepared(JbedVideoView.this.mMediaPlayer);
                }
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.setEnabled(true);
                }
                JbedVideoView.this.mVideoWidth = mp.getVideoWidth();
                JbedVideoView.this.mVideoHeight = mp.getVideoHeight();
                if (JbedVideoView.this.mVideoWidth == 0 || JbedVideoView.this.mVideoHeight == 0) {
                    if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                        JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                        JbedVideoView.this.mSeekWhenPrepared = 0;
                    }
                    if (JbedVideoView.this.mStartWhenPrepared) {
                        JbedVideoView.this.mMediaPlayer.start();
                        JbedVideoView.this.mStartWhenPrepared = false;
                        return;
                    }
                    return;
                }
                JbedVideoView.this.getHolder().setFixedSize(JbedVideoView.this.mVideoWidth, JbedVideoView.this.mVideoHeight);
                if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                    JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                    JbedVideoView.this.mSeekWhenPrepared = 0;
                }
                if (JbedVideoView.this.mStartWhenPrepared) {
                    JbedVideoView.this.mMediaPlayer.start();
                    JbedVideoView.this.mStartWhenPrepared = false;
                    if (JbedVideoView.this.mMediaController != null) {
                        JbedVideoView.this.mMediaController.show();
                    }
                } else if (!JbedVideoView.this.isPlaying() && ((JbedVideoView.this.mSeekWhenPrepared != 0 || JbedVideoView.this.getCurrentPosition() > 0) && JbedVideoView.this.mMediaController != null)) {
                    JbedVideoView.this.mMediaController.show(0);
                }
                JbedVideoView.this.mVideoSizeReady = true;
                synchronized (JbedVideoView.this.mutex) {
                    try {
                        JbedVideoView.this.mutex.notifyAll();
                    } catch (Exception e) {
                    }
                }
            }
        };
        this.mCompletionListener = new MediaPlayer.OnCompletionListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.4
            @Override // android.media.MediaPlayer.OnCompletionListener
            public void onCompletion(MediaPlayer mp) {
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mOnCompletionListener != null) {
                    JbedVideoView.this.mOnCompletionListener.onCompletion(JbedVideoView.this.mMediaPlayer);
                }
                try {
                    if (JbedVideoView.this.mListener != null) {
                        JbedVideoView.this.mListener.onCompletion();
                    }
                } catch (RemoteException e) {
                }
            }
        };
        this.mErrorListener = new MediaPlayer.OnErrorListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.5
            @Override // android.media.MediaPlayer.OnErrorListener
            public boolean onError(MediaPlayer mp, int a, int b) {
                int messageId;
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mOnErrorListener != null && JbedVideoView.this.mOnErrorListener.onError(JbedVideoView.this.mMediaPlayer, a, b)) {
                    return true;
                }
                if (JbedVideoView.this.getWindowToken() != null) {
                    JbedVideoView.this.mContext.getResources();
                    if (a == 200) {
                        messageId = R.string.VideoView_error_text_invalid_progressive_playback;
                    } else {
                        messageId = R.string.VideoView_error_text_unknown;
                    }
                    new AlertDialog.Builder(JbedVideoView.this.mContext).setTitle(R.string.VideoView_error_title).setMessage(messageId).setPositiveButton(R.string.VideoView_error_button, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.5.1
                        @Override // android.content.DialogInterface.OnClickListener
                        public void onClick(DialogInterface dialog, int whichButton) {
                            if (JbedVideoView.this.mOnCompletionListener != null) {
                                JbedVideoView.this.mOnCompletionListener.onCompletion(JbedVideoView.this.mMediaPlayer);
                            }
                        }
                    }).setCancelable(false).show();
                }
                return true;
            }
        };
        this.mBufferingUpdateListener = new MediaPlayer.OnBufferingUpdateListener() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.6
            @Override // android.media.MediaPlayer.OnBufferingUpdateListener
            public void onBufferingUpdate(MediaPlayer mp, int percent) {
                JbedVideoView.this.mCurrentBufferPercentage = percent;
            }
        };
        this.mSHCallback = new SurfaceHolder.Callback() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.7
            @Override // android.view.SurfaceHolder.Callback
            public void surfaceChanged(SurfaceHolder holder, int format, int w, int h) {
                JbedVideoView.this.mSurfaceWidth = w;
                JbedVideoView.this.mSurfaceHeight = h;
                if (JbedVideoView.this.mMediaPlayer != null && JbedVideoView.this.mIsPrepared && JbedVideoView.this.mVideoWidth == w && JbedVideoView.this.mVideoHeight == h) {
                    if (JbedVideoView.this.mSeekWhenPrepared != 0) {
                        JbedVideoView.this.mMediaPlayer.seekTo(JbedVideoView.this.mSeekWhenPrepared);
                        JbedVideoView.this.mSeekWhenPrepared = 0;
                    }
                    if (JbedVideoView.this.mMediaController != null) {
                        JbedVideoView.this.mMediaController.show();
                    }
                }
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceCreated(SurfaceHolder holder) {
                JbedVideoView.this.mSurfaceHolder = holder;
            }

            @Override // android.view.SurfaceHolder.Callback
            public void surfaceDestroyed(SurfaceHolder holder) {
                JbedVideoView.this.mSurfaceHolder = null;
                if (JbedVideoView.this.mMediaController != null) {
                    JbedVideoView.this.mMediaController.hide();
                }
                if (JbedVideoView.this.mMediaPlayer != null) {
                    JbedVideoView.this.mMediaPlayer.reset();
                    JbedVideoView.this.mMediaPlayer.release();
                    JbedVideoView.this.mMediaPlayer = null;
                }
            }
        };
        initVideoView();
    }

    public int getVideoWidth() {
        if (!this.mVideoSizeReady || (this.mVideoSizeReady && this.mVideoWidth == 0)) {
            synchronized (this.mutex) {
                try {
                    this.mutex.wait();
                } catch (Exception e) {
                }
            }
        }
        return this.mVideoWidth;
    }

    public int getVideoHeight() {
        if (!this.mVideoSizeReady || (this.mVideoSizeReady && this.mVideoHeight == 0)) {
            synchronized (this.mutex) {
                try {
                    this.mutex.wait();
                } catch (Exception e) {
                }
            }
        }
        return this.mVideoHeight;
    }

    @Override // android.view.SurfaceView, android.view.View
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = getDefaultSize(this.mVideoWidth, widthMeasureSpec);
        int height = getDefaultSize(this.mVideoHeight, heightMeasureSpec);
        setMeasuredDimension(width, height);
    }

    public int resolveAdjustedSize(int desiredSize, int measureSpec) {
        int specMode = View.MeasureSpec.getMode(measureSpec);
        int specSize = View.MeasureSpec.getSize(measureSpec);
        switch (specMode) {
            case Integer.MIN_VALUE:
                int result = Math.min(desiredSize, specSize);
                return result;
            case 0:
                return desiredSize;
            case 1073741824:
                return specSize;
            default:
                return desiredSize;
        }
    }

    private void initVideoView() {
        this.mVideoWidth = 0;
        this.mVideoHeight = 0;
        getHolder().addCallback(this.mSHCallback);
        getHolder().setType(3);
        setFocusable(true);
        setFocusableInTouchMode(true);
        requestFocus();
    }

    public void setVideoPath(String path) throws Exception {
        this.mDataSource = path;
        this.mStartWhenPrepared = false;
        this.mSeekWhenPrepared = 0;
        openVideo();
    }

    public void setParentView(View videoParent, View frameParent) {
        this.mVideoParent = videoParent;
        this.mFrameParent = frameParent;
    }

    public void resumeVideoPlay(String path, int position, boolean isPlay) throws Exception {
        try {
            setVideoPath(path);
        } catch (Exception e) {
            if (Log.isLoggable(FLAG, 6)) {
                Log.e(FLAG, "failed to setVideoPath(" + path + ")");
            }
            this.mMediaPlayer.release();
            this.mMediaPlayer = null;
        }
        if (this.mMediaPlayer != null) {
            this.mMediaPlayer.seekTo(position);
            if (isPlay) {
                start();
            }
        }
    }

    public void callRequestLayout() {
        requestLayout();
        invalidate();
    }

    public void stopPlayback() {
        if (this.mMediaPlayer != null) {
            this.mMediaPlayer.stop();
            this.mMediaPlayer.release();
            this.mMediaPlayer = null;
        }
    }

    public void resume(final JbedVideoPlayerState state) {
        int i = this.resumeTried + 1;
        this.resumeTried = i;
        if (i > 10) {
            String s = JbedMidpManager.getString(6, 21);
            Toast.makeText(this.mContext, s, 1).show();
            this.resumeTried = 0;
        } else {
            int delay = this.mSurfaceHolder != null ? 0 : 1000;
            this.mHandler.postDelayed(new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedVideoView.1
                @Override // java.lang.Runnable
                public void run() {
                    try {
                        try {
                            if (JbedVideoView.this.mSurfaceHolder == null) {
                                if (Log.isLoggable(JbedVideoView.FLAG, 5)) {
                                    Log.w(JbedVideoView.FLAG, "mSurfaceHolder still is not avaialbe!wait a while");
                                }
                                JbedVideoView.this.resume(state);
                                JbedVideoView.this.resumeTried = 0;
                                return;
                            }
                            if (state.isCapture) {
                                String recordpath = state.dataSource.toLowerCase();
                                if (recordpath.startsWith("capture://video")) {
                                    JbedVideoView.this.mVideoRecordPath = recordpath.substring(15);
                                } else if (Log.isLoggable(JbedVideoView.FLAG, 5)) {
                                    Log.w(JbedVideoView.FLAG, "record path is invalid, can not be resumed!");
                                }
                                JbedVideoView.this.closeCamera();
                                JbedVideoView.this.openCamera();
                                synchronized (JbedVideoView.this.mCameraMutex) {
                                    JbedVideoView.this.mCameraMutex.notify();
                                }
                            } else {
                                JbedVideoView.this.resumeVideoPlay(state.dataSource, state.position, state.isPlaying);
                            }
                            JbedVideoView.this.resumeTried = 0;
                        } catch (Exception e) {
                            if (Log.isLoggable(JbedVideoView.FLAG, 5)) {
                                Log.w(JbedVideoView.FLAG, "Exception is thrown when restorePlayer():" + e, e);
                            }
                            String s2 = JbedMidpManager.getString(6, 21);
                            Toast.makeText(JbedVideoView.this.mContext, s2, 1).show();
                            JbedVideoView.this.resumeTried = 0;
                        }
                    } catch (Throwable th) {
                        JbedVideoView.this.resumeTried = 0;
                        throw th;
                    }
                }
            }, delay);
        }
    }

    private void openVideo() throws Exception {
        if (this.mDataSource != null) {
            Intent i = new Intent("com.android.music.musicservicecommand");
            i.putExtra("command", "pause");
            this.mContext.sendBroadcast(i);
            stopPlayback();
            this.mMediaPlayer = new MediaPlayer();
            this.mMediaPlayer.reset();
            this.mMediaPlayer.setOnPreparedListener(this.mPreparedListener);
            this.mMediaPlayer.setOnVideoSizeChangedListener(this.mSizeChangedListener);
            this.mIsPrepared = false;
            this.mMediaPlayer.setOnCompletionListener(this.mCompletionListener);
            this.mMediaPlayer.setOnErrorListener(this.mErrorListener);
            this.mMediaPlayer.setOnBufferingUpdateListener(this.mBufferingUpdateListener);
            this.mCurrentBufferPercentage = 0;
            this.mMediaPlayer.setDataSource(this.mDataSource);
            this.mMediaPlayer.setDisplay(this.mSurfaceHolder);
            this.mMediaPlayer.setAudioStreamType(3);
            this.mMediaPlayer.setScreenOnWhilePlaying(true);
            this.mMediaPlayer.prepare();
            attachMediaController();
        }
    }

    public void setMediaController(MediaController controller) {
        if (this.mMediaController != null) {
            this.mMediaController.hide();
        }
        this.mMediaController = controller;
        attachMediaController();
    }

    private void attachMediaController() {
        if (this.mMediaPlayer != null && this.mMediaController != null) {
            this.mMediaController.setMediaPlayer(this);
            View anchorView = getParent() instanceof View ? (View) getParent() : this;
            this.mMediaController.setAnchorView(anchorView);
            this.mMediaController.setEnabled(this.mIsPrepared);
        }
    }

    public void setOnPreparedListener(MediaPlayer.OnPreparedListener l) {
        this.mOnPreparedListener = l;
    }

    public void setOnCompletionListener(MediaPlayer.OnCompletionListener l) {
        this.mOnCompletionListener = l;
    }

    public void setOnErrorListener(MediaPlayer.OnErrorListener l) {
        this.mOnErrorListener = l;
    }

    @Override // android.view.View
    public boolean onTouchEvent(MotionEvent ev) {
        if (this.mIsPrepared && this.mMediaPlayer != null && this.mMediaController != null) {
            toggleMediaControlsVisiblity();
            return false;
        }
        return false;
    }

    @Override // android.view.View
    public boolean onTrackballEvent(MotionEvent ev) {
        if (this.mIsPrepared && this.mMediaPlayer != null && this.mMediaController != null) {
            toggleMediaControlsVisiblity();
            return false;
        }
        return false;
    }

    private void toggleMediaControlsVisiblity() {
        if (this.mMediaController.isShowing()) {
            this.mMediaController.hide();
        } else {
            this.mMediaController.show();
        }
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public void start() {
        if (this.mMediaPlayer != null && this.mIsPrepared) {
            this.mMediaPlayer.start();
            this.mStartWhenPrepared = false;
        } else {
            this.mStartWhenPrepared = true;
        }
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public void pause() {
        if (this.mMediaPlayer != null && this.mIsPrepared && this.mMediaPlayer.isPlaying()) {
            this.mMediaPlayer.pause();
        }
        this.mStartWhenPrepared = false;
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public int getDuration() {
        if (this.mMediaPlayer != null && this.mIsPrepared) {
            if (this.mDuration > 0) {
                return this.mDuration;
            }
            this.mDuration = this.mMediaPlayer.getDuration();
            return this.mDuration;
        }
        this.mDuration = -1;
        return this.mDuration;
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public int getCurrentPosition() {
        if (this.mMediaPlayer == null || !this.mIsPrepared) {
            return 0;
        }
        return this.mMediaPlayer.getCurrentPosition();
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public void seekTo(int msec) {
        if (this.mMediaPlayer != null && this.mIsPrepared) {
            this.mMediaPlayer.seekTo(msec);
        } else {
            this.mSeekWhenPrepared = msec;
        }
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public boolean isPlaying() {
        if (this.mMediaPlayer == null || !this.mIsPrepared) {
            return false;
        }
        return this.mMediaPlayer.isPlaying();
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public int getBufferPercentage() {
        if (this.mMediaPlayer != null) {
            return this.mCurrentBufferPercentage;
        }
        return 0;
    }

    public Bitmap getFrameAt(int pos) {
        return this.mMediaPlayer.getFrameAt(pos);
    }

    public boolean openCamera() {
        try {
            this.mCamera = Camera.open();
            Camera.Parameters parameters = this.mCamera.getParameters();
            parameters.set("jpeg-quality", 85);
            parameters.setPictureSize(320, 240);
            parameters.setPreviewSize(CAMERA_DEFAULT_WIDTH, CAMERA_DEFAULT_HEIGHT);
            this.mCamera.setParameters(parameters);
            this.mCamera.setPreviewDisplay(this.mSurfaceHolder);
            this.mCamera.startPreview();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void closeCamera() {
        if (this.mCamera != null) {
            this.mCamera.release();
            this.mCamera = null;
        }
        if (this.mRecorder != null) {
            this.mRecorder.release();
            this.mRecorder = null;
        }
    }

    public byte[] takePicture() {
        try {
            this.mCameraData = null;
            if (this.mCamera == null) {
                try {
                    if (this.mListener != null) {
                        this.mListener.restoreState();
                    }
                } catch (RemoteException e) {
                }
            }
            synchronized (this.mCameraMutex) {
                while (this.mCamera == null) {
                    try {
                        this.mCameraMutex.wait(1000L);
                    } catch (InterruptedException e2) {
                    }
                }
            }
            this.mCamera.takePicture(this.mShutterCallback, this.mRawPictureCallback, this.mJpegPictureCallback);
        } catch (Throwable t) {
            if (Log.isLoggable(FLAG, 6)) {
                Log.e(FLAG, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>" + t.getMessage(), t);
            }
        }
        synchronized (this.mCameraMutex) {
            while (this.mCameraData == null) {
                try {
                    this.mCameraMutex.wait(1000L);
                } catch (InterruptedException e3) {
                }
            }
        }
        return this.mCameraData;
    }

    private final class TestShutterCallback implements Camera.ShutterCallback {
        private TestShutterCallback() {
        }

        @Override // android.hardware.Camera.ShutterCallback
        public void onShutter() {
        }
    }

    private final class RawPictureCallback implements Camera.PictureCallback {
        private RawPictureCallback() {
        }

        @Override // android.hardware.Camera.PictureCallback
        public void onPictureTaken(byte[] rawData, Camera camera) {
        }
    }

    private final class JpegPictureCallback implements Camera.PictureCallback {
        private JpegPictureCallback() {
        }

        @Override // android.hardware.Camera.PictureCallback
        public void onPictureTaken(byte[] rawData, Camera camera) {
            try {
                JbedVideoView.this.mCameraData = rawData;
                synchronized (JbedVideoView.this.mCameraMutex) {
                    JbedVideoView.this.mCameraMutex.notify();
                }
            } catch (Exception e) {
            }
        }
    }

    private int storeImage(byte[] data, String filename) throws Throwable {
        File file = new File(filename);
        if (data == null) {
            return -1;
        }
        OutputStream stream = null;
        try {
            try {
                OutputStream stream2 = new FileOutputStream(file);
                try {
                    stream2.write(data, 0, data.length);
                    if (stream2 != null) {
                        try {
                            stream2.close();
                        } catch (IOException e) {
                        }
                    }
                    return (int) file.length();
                } catch (Exception e2) {
                    stream = stream2;
                    if (Log.isLoggable(FLAG, 6)) {
                        Log.e(FLAG, "getSnapshot, fails to write bitmap file : " + filename);
                    }
                    if (stream != null) {
                        try {
                            stream.close();
                        } catch (IOException e3) {
                        }
                    }
                    return -1;
                } catch (Throwable th) {
                    th = th;
                    stream = stream2;
                    if (stream != null) {
                        try {
                            stream.close();
                        } catch (IOException e4) {
                        }
                    }
                    throw th;
                }
            } catch (Throwable th2) {
                th = th2;
            }
        } catch (Exception e5) {
        }
    }

    public void setVideoRecordPath(String dataSource) {
        this.mVideoRecordPath = dataSource;
    }

    public void initRecorder() {
        try {
            if (this.mRecorder == null) {
                this.mRecorder = new MediaRecorder();
            }
            resetMediaRecorder();
            this.mRecorder.setAudioSource(1);
            this.mRecorder.setVideoSource(1);
            this.mRecorder.setOutputFormat(1);
            this.mRecorder.setOutputFile(this.mVideoRecordPath);
            this.mRecorder.setVideoFrameRate(20);
            this.mRecorder.setVideoSize(CAMERA_DEFAULT_WIDTH, 144);
            this.mRecorder.setVideoEncoder(1);
            this.mRecorder.setAudioEncoder(1);
            this.mRecorder.setPreviewDisplay(this.mSurfaceHolder.getSurface());
            this.mRecorder.prepare();
        } catch (IOException e) {
        }
    }

    public void startRecord() {
        this.mCamera.release();
        initRecorder();
        this.mRecorder.start();
    }

    public void stopRecord() {
        this.mRecorder.stop();
        this.mRecorder.release();
        openCamera();
    }

    private void resetMediaRecorder() {
        if (this.mRecorder != null) {
            this.mRecorder.reset();
        }
    }

    public void setListener(IJbedVideoClientListener listener) {
        if (this.mListener != listener) {
            this.mListener = listener;
        }
    }

    public String getDataSource() {
        return this.mDataSource;
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public boolean canSeekBackward() {
        return true;
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public boolean canSeekForward() {
        return true;
    }

    @Override // android.widget.MediaController.MediaPlayerControl
    public boolean canPause() {
        return true;
    }
}
