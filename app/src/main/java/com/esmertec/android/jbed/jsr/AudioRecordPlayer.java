package com.esmertec.android.jbed.jsr;

import android.media.MediaRecorder;
import android.os.Handler;
import android.util.Log;
import com.esmertec.android.jbed.JbedConfig;
import java.io.IOException;

/* JADX INFO: compiled from: JbedMediaPlayer.java */
/* JADX INFO: loaded from: classes.dex */
class AudioRecordPlayer implements JbedMediaManager.Playable {
    static final String TAG = "AudioRecordPlayer";
    private String mDataSource;
    private Handler mHandler;
    private MediaRecorder mMediaRecorder;
    private int mNativeContext;

    public AudioRecordPlayer(int nativeContext, String url, Handler handler) throws IOException {
        this.mNativeContext = nativeContext;
        this.mDataSource = url;
        this.mHandler = handler;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
    public int getNativeContext() {
        return this.mNativeContext;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
    public int getPrepareDataMethod() {
        return 0;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
    public int operation(int playerId, int opId, int param1, int param2, int param3) {
        Log.d(TAG, "AudioRecordPlayer operation (" + opId + "," + param1 + "," + param2 + "," + param3 + ")");
        int ret = 0;
        switch (opId) {
            case 2:
                this.mMediaRecorder.release();
                break;
            case 3:
            case 5:
                break;
            case 9:
                ret = JbedConfig.getCustomerName().equals("LGE") ? JbedMediaManager.getVolume() : JbedVolumn.getVol();
                break;
            case 10:
                ret = JbedConfig.getCustomerName().equals("LGE") ? JbedMediaManager.setVolume(param1) : JbedVolumn.setVol(param1);
                break;
            case 22:
                try {
                    this.mMediaRecorder.setAudioSource(1);
                    this.mMediaRecorder.setOutputFormat(1);
                    this.mMediaRecorder.setAudioEncoder(1);
                    this.mMediaRecorder.setOutputFile(this.mDataSource);
                    this.mMediaRecorder.prepare();
                    this.mMediaRecorder.start();
                } catch (IOException ioe) {
                    Log.d(TAG, "mMediaRecorder.prepare() throw IOException: " + ioe.getMessage());
                    return -1;
                } catch (IllegalStateException ise) {
                    Log.d(TAG, "mMediaRecorder.prepare() throw IllegalStateException:" + ise.getMessage());
                    return -1;
                }
                break;
            case 23:
                this.mMediaRecorder.stop();
                this.mMediaRecorder.reset();
                prepareData();
                break;
            case 24:
                throw new IllegalArgumentException("AudioRecordPlayer : OP_STOPRECORD should not sent to Android");
            default:
                ret = -2;
                break;
        }
        return ret;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
    public void prepareData() {
        if (this.mMediaRecorder == null) {
            this.mMediaRecorder = new MediaRecorder();
        }
    }

    @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
    public String getDataSource() {
        throw new UnsupportedOperationException("Audio record doesn't suport MetaDataControl");
    }

    public String toString() {
        return "[AUDIO]0x" + Integer.toHexString(this.mNativeContext) + " " + this.mDataSource + " SYNC_PREPAR_DATA ";
    }
}
