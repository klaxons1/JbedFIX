package com.esmertec.android.jbed.jsr;

import android.media.MediaPlayer;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;
import android.view.SurfaceHolder;
import com.esmertec.android.jbed.ams.JbedSelector;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public abstract class JbedMediaPlayer extends MediaPlayer implements MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener, MediaPlayer.OnErrorListener, SurfaceHolder.Callback {
    public static final int ASYNC_PREPAR_DATA = 1;
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
    public static final int OP_ISPLAYING = 1001;
    public static final int OP_PAUSE = 4;
    public static final int OP_PAUSERECORD = 23;
    public static final int OP_PLAY = 3;
    public static final int OP_RELEASEDEVICE = 15;
    public static final int OP_RESET = 1;
    public static final int OP_SETDATASIZE = 14;
    public static final int OP_SETPOSITION = 8;
    public static final int OP_SETVOLUME = 10;
    public static final int OP_STARTRECORD = 22;
    public static final int OP_STOP = 5;
    public static final int OP_STOPRECORD = 24;
    public static final int RC_ERROR_COMMAND_IGNORED = -2;
    public static final int RC_ERROR_OPERATION_FAILED = -1;
    public static final int RC_OK = 0;
    public static final int SYNC_PREPAR_DATA = 0;
    public static final String TAG = "JbedMediaPlayer";
    protected String mDataSource;
    private Handler mHandler;
    public static boolean DEBUG = false;
    private static String[] VIDEO_EXT_NAMES = {".mp4", ".3gp", ".3g2"};
    protected volatile boolean isValid = true;
    private boolean released;
    private final Seeker seeker = new Seeker();

    public abstract void onCompletion(MediaPlayer mediaPlayer);

    public abstract void onPrepared(MediaPlayer mediaPlayer);

    public JbedMediaPlayer(String url, Handler handler) {
        this.mDataSource = url;
        this.mHandler = handler;
    }

    public void prepareData() throws IOException {
        setOnPreparedListener(this);
        setOnCompletionListener(this);
        setOnErrorListener(this);
        setOnSeekCompleteListener(this.seeker);
        setDataSource(this.mDataSource);
        setAudioStreamType(3);
        if (getPrepareDataMethod() == 0) {
            prepare();
        } else {
            prepareAsync();
        }
    }

    public int getPrepareDataMethod() {
        return this.mDataSource.startsWith(JbedSelector.ROOT_FOLDER_NAME) ? 0 : 1;
    }

    public String getDataSource() {
        return this.mDataSource;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public int getPosition() {
        try {
            return getCurrentPosition();
        } catch (IllegalStateException e) {
            return RC_ERROR_OPERATION_FAILED;
        }
    }

    class Seeker implements MediaPlayer.OnSeekCompleteListener {
        private static final long TIMEOUT_MS = 10000L;
        private boolean pending;
        private int result;

        Seeker() {
        }

        public synchronized int seekAndWait(int position) {
            if (JbedMediaPlayer.this.getPosition() == position) {
                return 0;
            }
            pending = true;
            result = RC_ERROR_OPERATION_FAILED;
            try {
                JbedMediaPlayer.this.seekTo(position);
                long deadline = SystemClock.uptimeMillis() + TIMEOUT_MS;
                while (pending) {
                    long remaining = deadline - SystemClock.uptimeMillis();
                    if (remaining <= 0) break;
                    wait(remaining);
                }
                return result;
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return RC_ERROR_OPERATION_FAILED;
            } catch (IllegalStateException e) {
                return RC_ERROR_OPERATION_FAILED;
            } finally {
                pending = false;
            }
        }

        @Override // android.media.MediaPlayer.OnSeekCompleteListener
        public synchronized void onSeekComplete(MediaPlayer mp) {
            if (pending) {
                result = RC_OK;
                pending = false;
                notifyAll();
            }
        }

        public synchronized void seekError() {
            result = RC_ERROR_OPERATION_FAILED;
            pending = false;
            notifyAll();
        }
    }

    @Override
    public synchronized void release() {
        if (released) return;
        released = true;
        isValid = false;
        seeker.seekError();
        setOnPreparedListener(null);
        setOnCompletionListener(null);
        setOnErrorListener(null);
        setOnSeekCompleteListener(null);
        super.release();
    }

    public int operation(int playerId, int opId, int param1, int param2, int param3) {
        int ret = 0;
        if (!this.isValid) {
            switch (opId) {
                case 1:
                case 3:
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                    Log.w(TAG, "WARNING: try to operate a invalid media, opId=" + opId);
                    return -1;
            }
        }
        switch (opId) {
            case 1:
                ret = this.seeker.seekAndWait(0);
                break;
            case 2:
                release();
                break;
            case 3:
                if (isPlaying()) {
                    Log.w(TAG, "WARNING: try to start a playing player");
                }
                start();
                break;
            case 4:
                if (!isPlaying()) {
                    Log.w(TAG, "WARNING: try to pause a unplayed player");
                } else {
                    pause();
                }
                break;
            case 5:
                if (!isPlaying()) {
                    Log.w(TAG, "WARNING: try to stop a unplaying player");
                }
                pause();
                break;
            case 6:
                ret = getDuration();
                break;
            case 7:
                ret = getPosition();
                break;
            case 8:
                ret = this.seeker.seekAndWait(param1);
                if (ret == 0) {
                    ret = getPosition();
                }
                break;
            case 15:
                try {
                    if (isPlaying()) {
                        stop();
                    }
                } catch (Exception e2) {
                }
                break;
            case 1001:
                ret = !isPlaying() ? 0 : 1;
                break;
            default:
                ret = -1;
                break;
        }
        return ret;
    }

    static boolean isVideoUrl(String url) {
        String url2 = url.toLowerCase();
        if (url2.startsWith("capture://video")) {
            return true;
        }
        String[] arr$ = VIDEO_EXT_NAMES;
        for (String ext : arr$) {
            if (url2.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    static boolean isAudioRecord(String url) {
        return url.startsWith("capture://audio");
    }

    public boolean onError(MediaPlayer mp, int arg1, int arg2) {
        this.isValid = false;
        this.seeker.seekError();
        return true;
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceChanged(SurfaceHolder surfaceholder, int i, int j, int k) {
        Log.d(TAG, "surfaceChanged called");
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceDestroyed(SurfaceHolder surfaceholder) {
        Log.d(TAG, "surfaceDestroyed called");
    }

    @Override // android.view.SurfaceHolder.Callback
    public void surfaceCreated(SurfaceHolder holder) {
        Log.d(TAG, "surfaceCreated called");
    }
}
