package com.esmertec.android.jbed.jsr;

import android.media.MediaPlayer;
import android.os.Handler;
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
    protected boolean isValid = true;
    private Seeker seeker = new Seeker();

    public abstract void onCompletion(MediaPlayer mediaPlayer);

    public abstract void onPrepared(MediaPlayer mediaPlayer);

    public JbedMediaPlayer(String url, Handler handler) {
        this.mDataSource = url;
        this.mHandler = handler;
    }

    public void prepareData() throws IOException {
        setDataSource(this.mDataSource);
        setAudioStreamType(3);
        if (getPrepareDataMethod() == 0) {
            prepare();
        } else {
            prepareAsync();
        }
        setOnPreparedListener(this);
        setOnCompletionListener(this);
        setOnErrorListener(this);
        setOnSeekCompleteListener(this.seeker);
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
        } catch (Exception e) {
            Log.w(TAG, "getPosition() There's a excpetion ");
            return 0;
        }
    }

    class Seeker implements MediaPlayer.OnSeekCompleteListener {
        boolean mHasSeekFinished;

        Seeker() {
        }

        public int seekAndWait(int position) {
            if (JbedMediaPlayer.this.getPosition() == position) {
                return 0;
            }
            this.mHasSeekFinished = false;
            try {
                if (JbedMediaPlayer.DEBUG) {
                    Log.w(JbedMediaPlayer.TAG, " start to seek to " + position);
                }
                JbedMediaPlayer.this.seekTo(position);
                synchronized (this) {
                    if (!this.mHasSeekFinished) {
                        try {
                            wait(300000L);
                        } catch (Exception e) {
                        }
                        if (!this.mHasSeekFinished) {
                            Log.w(JbedMediaPlayer.TAG, "------------WARNING timeout when seek to " + position);
                            return -1;
                        }
                    }
                    return 0;
                }
            } catch (Exception e2) {
                return -1;
            }
        }

        @Override // android.media.MediaPlayer.OnSeekCompleteListener
        public void onSeekComplete(MediaPlayer mp) {
            if (JbedMediaPlayer.DEBUG) {
                Log.d(JbedMediaPlayer.TAG, " get onSeekComplete at " + mp.toString());
            }
            synchronized (this) {
                this.mHasSeekFinished = true;
                notify();
            }
        }

        public void seekError() {
            synchronized (this) {
                this.mHasSeekFinished = false;
                notify();
            }
        }
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
                this.seeker.seekAndWait(0);
                break;
            case 2:
                try {
                    if (isPlaying()) {
                        stop();
                    }
                    break;
                } catch (Exception e) {
                }
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
        if (this.seeker != null) {
            this.seeker.seekError();
        }
        this.isValid = false;
        return false;
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
