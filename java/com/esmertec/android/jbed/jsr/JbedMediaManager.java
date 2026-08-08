package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.graphics.Bitmap;
import android.media.AudioManager;
import android.media.MediaMetadataRetriever;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;
import com.esmertec.android.jbed.ams.JbedSelector;
import com.esmertec.android.jbed.app.IJbedVideoClient;
import com.esmertec.android.jbed.app.IJbedVideoClientListener;
import com.esmertec.android.jbed.service.JbedService;
import com.esmertec.android.jbed.util.SimpleEntry;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedMediaManager implements JbedService.LifecycleListener {
    public static int ANDRIOD_MAX_MUSIC_STREM_VOLUME = 0;
    private static final String AUDIO_RECORD_PROTOCOL = "capture://audio";
    public static final boolean DEBUG = false;
    private static JbedMediaManager INSTANCE = null;
    private static final int OP_SET_VISIBLE = 406;
    private static final String TAG = "JbedMediaManager";
    private static AudioManager mAudioManager;
    private static final HashMap<Integer, String> mMetaKeyMap;
    static HashMap<Integer, Playable> playerMap = new HashMap<>();
    private static int residue;
    private JbedService.ClientProxy mClient;
    private Context mContext;
    private Handler mHandler;
    public final JbedService.ClientChangedListener mClientChangedListener = new JbedService.ClientChangedListener() { // from class: com.esmertec.android.jbed.jsr.JbedMediaManager.1
        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientAttached(JbedService.ClientProxy client) {
            synchronized (JbedMediaManager.INSTANCE) {
                JbedMediaManager.this.mClient = client;
                for (Playable player : JbedMediaManager.playerMap.values()) {
                    if (player instanceof VideoPlayerProxy) {
                        VideoPlayerProxy proxy = (VideoPlayerProxy) player;
                        if (proxy.mState.isVisible) {
                            proxy.updateVideoClient(JbedMediaManager.this.mClient.getVideoClient());
                        }
                        if (proxy.needRestoreState) {
                            proxy.restoreState();
                            break;
                        }
                    }
                }
                JbedMediaManager.INSTANCE.notifyAll();
            }
        }

        @Override // com.esmertec.android.jbed.service.JbedService.ClientChangedListener
        public void onClientDetached() {
            synchronized (JbedMediaManager.INSTANCE) {
                JbedMediaManager.this.mClient = null;
                for (Playable player : JbedMediaManager.playerMap.values()) {
                    if (player instanceof VideoPlayerProxy) {
                        VideoPlayerProxy proxy = (VideoPlayerProxy) player;
                        if (proxy.mState.suspend == JbedVideoPlayerState.Suspend.DOING) {
                            proxy.mState.suspend = JbedVideoPlayerState.Suspend.DONE;
                        }
                    }
                }
            }
        }
    };
    List<MediaEventListener> mMediaEventListeners = new ArrayList(2);

    public interface MediaEventListener {
        void onCompletion(Playable playable);

        void onPrepared(Playable playable);
    }

    public interface Playable {
        String getDataSource();

        int getNativeContext();

        int getPrepareDataMethod();

        int operation(int i, int i2, int i3, int i4, int i5);

        void prepareData() throws IOException;
    }

    private static native void nativeInitialization();

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifyMediaCreatePlayer(int i);

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifyMediaFinishPlay(int i);

    static {
        nativeInitialization();
        mMetaKeyMap = new HashMap<>(16);
        mMetaKeyMap.put(0, "cd track number");
        mMetaKeyMap.put(1, "album");
        mMetaKeyMap.put(2, "artist");
        mMetaKeyMap.put(3, "author");
        mMetaKeyMap.put(4, "composer");
        mMetaKeyMap.put(5, "date");
        mMetaKeyMap.put(6, "genre");
        mMetaKeyMap.put(7, JbedCalendarTodo.Tasks.TITLE);
        mMetaKeyMap.put(8, "year");
        mMetaKeyMap.put(9, "duration");
        mMetaKeyMap.put(10, "num tracks");
        mMetaKeyMap.put(11, "writer");
        mMetaKeyMap.put(12, "mimetype");
        mMetaKeyMap.put(13, "albumartist");
        mMetaKeyMap.put(14, "disc number");
        mMetaKeyMap.put(15, "compilation");
    }

    public JbedMediaManager(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
        if (mAudioManager == null) {
            mAudioManager = (AudioManager) this.mContext.getSystemService("audio");
            ANDRIOD_MAX_MUSIC_STREM_VOLUME = mAudioManager.getStreamMaxVolume(3);
        }
        this.mMediaEventListeners.add(new MediaEventListener() { // from class: com.esmertec.android.jbed.jsr.JbedMediaManager.2
            @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.MediaEventListener
            public void onCompletion(final Playable mp) {
                if (mp.getNativeContext() > 0) {
                    Message msg = JbedMediaManager.this.mHandler.obtainMessage(3);
                    msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedMediaManager.2.1
                        @Override // java.lang.Runnable
                        public void run() {
                            JbedMediaManager.nativeNotifyMediaFinishPlay(mp.getNativeContext());
                        }
                    };
                    msg.sendToTarget();
                }
            }

            @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.MediaEventListener
            public void onPrepared(final Playable mp) {
                if (mp.getNativeContext() > 0) {
                    Message msg = JbedMediaManager.this.mHandler.obtainMessage(3);
                    msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedMediaManager.2.2
                        @Override // java.lang.Runnable
                        public void run() {
                            JbedMediaManager.nativeNotifyMediaCreatePlayer(mp.getNativeContext());
                        }
                    };
                    msg.sendToTarget();
                }
            }
        });
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        playerMap.clear();
        this.mMediaEventListeners.clear();
        INSTANCE = null;
    }

    public static int createPlayer(int nativeContext, String url) {
        String urlfixed;
        Playable player;
        String mediaUrl = url;
        if (mediaUrl.startsWith(JbedSelector.ROOT_FOLDER_NAME)) {
            mediaUrl = "file://" + mediaUrl;
        }
        Uri uri = Uri.parse(mediaUrl);
        String mediaUrl2 = uri.getScheme();
        if (mediaUrl2.equals("file")) {
            String scheme = uri.getPath();
            urlfixed = scheme;
        } else if (mediaUrl2.equals("http") || mediaUrl2.equals("rtsp") || mediaUrl2.equals("capture")) {
            String urlfixed2 = uri.toString();
            urlfixed = urlfixed2;
        } else {
            throw new IllegalArgumentException("unknown uri " + uri.toString());
        }
        try {
            if (JbedMediaPlayer.isVideoUrl(url)) {
                if (INSTANCE.mClient == null) {
                    if (Log.isLoggable(TAG, 5)) {
                        Log.w(TAG, "WARNING: try to play a video without any jbed client connecting");
                    }
                    synchronized (INSTANCE) {
                        try {
                            INSTANCE.wait();
                        } catch (InterruptedException e) {
                            if (Log.isLoggable(TAG, 5)) {
                                Log.w(TAG, "InterruptedException");
                            }
                        }
                    }
                } else {
                    INSTANCE.mClient.getVideoClient();
                }
                player = new VideoPlayerProxy(nativeContext, urlfixed, INSTANCE.mClient.getVideoClient());
            } else if (JbedMediaPlayer.isAudioRecord(url)) {
                int len = AUDIO_RECORD_PROTOCOL.length();
                player = new AudioRecordPlayer(nativeContext, urlfixed.substring(len, urlfixed.length()), INSTANCE.mHandler);
            } else {
                player = new AudioPlayer(nativeContext, urlfixed, INSTANCE.mHandler);
            }
            playerMap.put(Integer.valueOf(nativeContext), player);
            player.prepareData();
            Playable player2 = playerMap.get(Integer.valueOf(nativeContext));
            if (player2 == null) {
                return -1;
            }
            return player2.getPrepareDataMethod();
        } catch (Exception e2) {
            if (Log.isLoggable(TAG, 5)) {
                Log.w(TAG, "failed to create player " + nativeContext + " " + url, e2);
            }
            return -1;
        }
    }

    public static int openStreamDev(int nativeContext, int mediaType) {
        playerMap.get(Integer.valueOf(nativeContext));
        return nativeContext;
    }

    public static int operation(int nativeContext, int mediaType, int opId, int param1, int param2, int param3) {
        Playable player = playerMap.get(Integer.valueOf(nativeContext));
        if (player == null) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, "failed to get player accroding to contextid " + nativeContext + " opId=" + opId);
            }
            return -1;
        }
        if (opId == 2) {
            playerMap.remove(Integer.valueOf(nativeContext));
        }
        if (opId == 9 || opId == 10) {
            return handleVolume(nativeContext, opId, param1);
        }
        return player.operation(nativeContext, opId, param1, param2, param3);
    }

    private static int handleVolume(int context, int opId, int param1) {
        return opId == 9 ? getVolume() : setVolume(param1);
    }

    public void notifyCompletion(Playable mp) {
        for (MediaEventListener listener : this.mMediaEventListeners) {
            listener.onCompletion(mp);
        }
    }

    public void notifyPrepared(Playable mp) {
        if (mp.getPrepareDataMethod() == 0) {
            if (Log.isLoggable(TAG, 4)) {
                Log.i(TAG, " the player is prepared with sync! ignore the prepare event!");
            }
        } else {
            for (MediaEventListener listener : this.mMediaEventListeners) {
                listener.onPrepared(mp);
            }
        }
    }

    public void notifyError(Playable mp, int arg1, int arg2) {
        synchronized (playerMap) {
            playerMap.notifyAll();
        }
    }

    private static int getSnapshot(int nativeContext, String filename) {
        Playable tmp = playerMap.get(Integer.valueOf(nativeContext));
        if (tmp == null) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, "can't find this video player with " + nativeContext);
            }
            return -1;
        }
        if (!(tmp instanceof VideoPlayerProxy)) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, "the player " + nativeContext + " isn't a video player");
            }
            return -1;
        }
        VideoPlayerProxy player = (VideoPlayerProxy) tmp;
        if (player.operation(0, 1001, 0, 0, 0) == 0) {
            if (!Log.isLoggable(TAG, 6)) {
                return 0;
            }
            Log.e(TAG, "video is not palying when get snapshot");
            return 0;
        }
        if (player.isCameraPlaying()) {
            byte[] jpegData = null;
            try {
                jpegData = player.getSnapshotFromCamera();
            } catch (Throwable t) {
                if (Log.isLoggable(TAG, 6)) {
                    Log.e(TAG, t.getMessage(), t);
                }
            }
            player.reconnectCamera();
            return storeImage(jpegData, filename);
        }
        Bitmap bitmap = player.getSnapshotFromMedia();
        return storeImage(bitmap, filename);
    }

    private static int storeImage(Bitmap data, String filename) {
        if (data == null) return -1;
        try (OutputStream stream = new FileOutputStream(new File(filename))) {
            data.compress(Bitmap.CompressFormat.JPEG, 100, stream);
            return (int) new File(filename).length();
        } catch (IOException e) {
            Log.e(TAG, "getSnapshot, failed to write bitmap file: " + filename, e);
            return -1;
        }
    }

    private static int storeImage(byte[] data, String filename) {
        if (data == null) return -1;
        try (OutputStream stream = new FileOutputStream(new File(filename))) {
            stream.write(data);
            return (int) new File(filename).length();
        } catch (IOException e) {
            Log.e(TAG, "getSnapshot, failed to write image file: " + filename, e);
            return -1;
        }
    }

    private static byte[] getMetaData(int nativeContext) {
        try {
            List<SimpleEntry<String, String>> metaList = getMetaList(nativeContext);
            ByteArrayOutputStream bo = new ByteArrayOutputStream();
            DataOutputStream out = new DataOutputStream(bo);
            out.writeByte(metaList.size());
            for (int i = 0; i < metaList.size(); i++) {
                out.write(metaList.get(i).getKey().getBytes("utf-8"));
                out.write(0);
                out.write(metaList.get(i).getValue().getBytes("utf-8"));
                out.write(0);
            }
            return bo.toByteArray();
        } catch (IOException e) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, "getMetaData throw IOException");
            }
            return null;
        }
    }

    private static List<SimpleEntry<String, String>> getMetaList(int nativeContext) {
        Playable player = playerMap.get(Integer.valueOf(nativeContext));
        List<SimpleEntry<String, String>> result = new ArrayList<>();
        MediaMetadataRetriever metadataRetriever = new MediaMetadataRetriever();
        try {
            metadataRetriever.setDataSource(player.getDataSource());
            for (int i = 0; i < mMetaKeyMap.size(); i++) {
                String value = metadataRetriever.extractMetadata(i);
                if (value != null) {
                    result.add(new SimpleEntry<>(mMetaKeyMap.get(Integer.valueOf(i)), value));
                }
            }
        } catch (RuntimeException re) {
            if (Log.isLoggable(TAG, 5)) {
                Log.w(TAG, "getMetaList catch RuntimeException : " + re);
            }
        }
        return result;
    }

    public static synchronized int convertSW2HWVolume(int inSwVolume) {
        int adjustedVol;
        adjustedVol = (ANDRIOD_MAX_MUSIC_STREM_VOLUME * inSwVolume) / 100;
        residue = (ANDRIOD_MAX_MUSIC_STREM_VOLUME * inSwVolume) % 100;
        return adjustedVol;
    }

    public static synchronized int convertHW2SWVolume(int inSwVolume) {
        int adjustedVol;
        adjustedVol = ((inSwVolume * 100) + residue) / ANDRIOD_MAX_MUSIC_STREM_VOLUME;
        return adjustedVol;
    }

    public static synchronized int getVolume() {
        int ret;
        ret = -1;
        if (mAudioManager != null) {
            int ret2 = mAudioManager.getStreamVolume(3);
            ret = convertHW2SWVolume(ret2);
        }
        return ret;
    }

    public static synchronized int setVolume(int inVol) {
        int ret;
        ret = -1;
        if (mAudioManager != null) {
            int ret2 = convertSW2HWVolume(inVol);
            mAudioManager.setStreamVolume(3, ret2, 0);
            ret = inVol;
        }
        return ret;
    }

    static class VideoPlayerProxy extends IJbedVideoClientListener.Stub implements Playable {
        private static final String FLAG = "VideoPlayerProxy";
        private static final int OP_SET_DISPLAY_LOCATION = 404;
        private static final int OP_SET_DISPLAY_SIZE = 405;
        private static final int OP_SET_VIDEOREGION_LOCATION = 402;
        private static final int OP_SET_VIDEOREGION_SIZE = 403;
        private String mDataSource;
        private int mNativeContext;
        private IJbedVideoClient mVideoClient;
        private boolean needRestoreState = false;
        private JbedVideoPlayerState mState = new JbedVideoPlayerState();

        public VideoPlayerProxy(int naiveContext, String url, IJbedVideoClient videoClient) {
            this.mNativeContext = naiveContext;
            this.mDataSource = url;
            this.mVideoClient = videoClient;
            this.mState.dataSource = this.mDataSource;
            try {
                this.mVideoClient.setListener(this);
            } catch (DeadObjectException e) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.setListener(), DeadObjectException");
            } catch (RemoteException e2) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.setListener(), RemoteException");
            }
        }

        public void updateVideoClient(IJbedVideoClient videoClient) {
            if (this.mVideoClient != videoClient) {
                this.mVideoClient = videoClient;
                try {
                    this.mVideoClient.setListener(this);
                } catch (RemoteException re) {
                    Log.w(JbedMediaManager.TAG, "updateLinstener failed RemoteException : " + re);
                }
            }
        }

        public boolean isCameraPlaying() {
            return this.mDataSource.startsWith("capture://video");
        }

        public Bitmap getSnapshotFromMedia() {
            try {
                return this.mVideoClient.getSnapshotFromMedia();
            } catch (DeadObjectException e) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.getFrameAt(), DeadObjectException");
            } catch (RemoteException e2) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.getFrameAt(), RemoteException");
            }
        }

        public byte[] getSnapshotFromCamera() {
            try {
                synchronized (JbedMediaManager.INSTANCE) {
                    if (JbedMediaManager.INSTANCE.mClient != null) {
                        updateVideoClient(JbedMediaManager.INSTANCE.mClient.getVideoClient());
                    }
                }
                return this.mVideoClient.getSnapshotFromCamera();
            } catch (DeadObjectException e) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.getSnapshotFromCamera(), DeadObjectException");
            } catch (RemoteException e2) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.getSnapshotFromCamera(), RemoteException");
            }
        }

        public void reconnectCamera() {
            try {
                synchronized (JbedMediaManager.INSTANCE) {
                    if (JbedMediaManager.INSTANCE.mClient != null) {
                        updateVideoClient(JbedMediaManager.INSTANCE.mClient.getVideoClient());
                    }
                }
                this.mVideoClient.reconnectCamera();
            } catch (RemoteException e) {
                if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                    Log.w(JbedMediaManager.TAG, "reconnect Camera failed !!!");
                }
            } catch (NullPointerException e2) {
                if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                    Log.w(JbedMediaManager.TAG, "reconnect Camera failed !!!, NullPointerException");
                }
            }
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
            switch (opId) {
                case 2:
                    this.mState.isPlaying = false;
                    if (this.mVideoClient != null) {
                        try {
                            this.mVideoClient.setListener(null);
                        } catch (RemoteException re) {
                            if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                                Log.w(JbedMediaManager.TAG, "updateLinstener failed RemoteException : " + re);
                            }
                        }
                    }
                    break;
                case 3:
                    this.mState.isPlaying = true;
                    break;
                case 4:
                case 5:
                    this.mState.isPlaying = false;
                    break;
                case 8:
                    this.mState.position = param1;
                    break;
                case OP_SET_VIDEOREGION_LOCATION /* 402 */:
                    this.mState.updateRegionViewRect(true, param1, param2);
                    if (this.mVideoClient != null) {
                        try {
                            this.mVideoClient.updateRegionRect(this.mState.regionViewRect);
                        } catch (RemoteException e) {
                            throw new RuntimeException("failed to call mVideoClient.updateRegionRect()!");
                        }
                    }
                    break;
                case OP_SET_VIDEOREGION_SIZE /* 403 */:
                    this.mState.updateRegionViewRect(false, param1, param2);
                    if (this.mVideoClient != null) {
                        try {
                            this.mVideoClient.updateRegionRect(this.mState.regionViewRect);
                        } catch (RemoteException e2) {
                            throw new RuntimeException("failed to call mVideoClient.updateRegionRect()!");
                        }
                    }
                    break;
                case OP_SET_DISPLAY_LOCATION /* 404 */:
                    this.mState.updateDisplayViewRect(true, param1, param2);
                    if (this.mVideoClient != null) {
                        try {
                            this.mVideoClient.updateDisplayRect(this.mState.displayViewRect);
                        } catch (RemoteException e3) {
                            throw new RuntimeException("failed to call mVideoClient.updateDisplayRect()!");
                        }
                    }
                    break;
                case OP_SET_DISPLAY_SIZE /* 405 */:
                    this.mState.updateDisplayViewRect(false, param1, param2);
                    if (this.mVideoClient != null) {
                        try {
                            this.mVideoClient.updateDisplayRect(this.mState.displayViewRect);
                        } catch (RemoteException e4) {
                            throw new RuntimeException("failed to call mVideoClient.updateDisplayRect()!");
                        }
                    }
                    break;
                case JbedMediaManager.OP_SET_VISIBLE /* 406 */:
                    this.mState.isVisible = param1 == 1;
                    if (this.mState.isVisible) {
                        synchronized (JbedMediaManager.INSTANCE) {
                            if (JbedMediaManager.INSTANCE.mClient != null) {
                                updateVideoClient(JbedMediaManager.INSTANCE.mClient.getVideoClient());
                            }
                            if (this.mState.suspend == JbedVideoPlayerState.Suspend.DONE) {
                                if (JbedMediaManager.INSTANCE.mClient != null) {
                                    restoreState();
                                } else {
                                    if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                                        Log.w(JbedMediaManager.TAG, "need restore State, but mVideoClient is null! Restore state after client is attached!");
                                    }
                                    this.needRestoreState = true;
                                }
                            }
                        }
                    }
                    break;
                case 1001:
                    if (this.mVideoClient == null) {
                        return this.mState.isPlaying ? 1 : 0;
                    }
                    break;
            }
            try {
                if (this.mVideoClient != null) {
                    return this.mVideoClient.operation(playerId, opId, param1, param2, param3);
                }
                if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                    Log.w(JbedMediaManager.TAG, "mVideoClient is null! ingore operation: " + opId + "," + param1 + "," + param2 + "," + param3);
                }
                return 0;
            } catch (DeadObjectException e5) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.operation() ");
            } catch (RemoteException e6) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.operation(), RemoteException");
            } catch (Exception e7) {
                if (Log.isLoggable(JbedMediaManager.TAG, 5)) {
                    Log.w(JbedMediaManager.TAG, "operation throw exception : " + e7);
                }
                return -2;
            }
        }

        @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
        public void restoreState() {
            try {
                updateVideoClient(JbedMediaManager.INSTANCE.mClient.getVideoClient());
                this.mVideoClient.restorePlayerState(this.mState);
                this.mState.suspend = JbedVideoPlayerState.Suspend.NONE;
                this.needRestoreState = false;
            } catch (RemoteException e) {
                throw new RuntimeException("failed to call jbedVideoPlayer.restorePlayer(), RemoteException");
            }
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
        public void prepareData() throws IOException {
            try {
                if (-1 == this.mVideoClient.prepareData(this.mDataSource)) {
                    throw new RuntimeException("Open Camera failed!");
                }
            } catch (DeadObjectException e) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.prepareData() ");
            } catch (RemoteException e2) {
                throw new RuntimeException(" failed to call jbedVideoPlayer.prepareData(), RemoteException");
            }
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
        public String getDataSource() {
            return this.mDataSource;
        }

        @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
        public void onCompletion() throws DeadObjectException {
            JbedMediaManager.INSTANCE.notifyCompletion(this);
        }

        @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
        public void onError(int arg1, int arg2) throws DeadObjectException {
            JbedMediaManager.INSTANCE.notifyError(this, arg1, arg2);
        }

        @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
        public void onPrepared() throws DeadObjectException {
            JbedMediaManager.INSTANCE.notifyPrepared(this);
        }

        @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
        public void onSuspend(JbedVideoPlayerState state) {
            synchronized (JbedMediaManager.INSTANCE) {
                if (this.mState.suspend == JbedVideoPlayerState.Suspend.NONE) {
                    this.mState = state;
                    this.mVideoClient = null;
                } else {
                    this.needRestoreState = true;
                }
            }
        }

        public String toString() {
            return "[VIDEO]0x" + Integer.toHexString(this.mNativeContext) + " " + this.mDataSource + " ASYNC_PREPAR_DATA";
        }
    }

    static class AudioPlayer extends JbedMediaPlayer implements Playable, MediaPlayer.OnCompletionListener, MediaPlayer.OnPreparedListener, MediaPlayer.OnErrorListener {
        private int mNativeContext;

        public AudioPlayer(int nativeContext, String url, Handler handler) throws IOException {
            super(url, handler);
            this.mNativeContext = nativeContext;
        }

        public String toString() {
            return "[AUDIO]0x" + Integer.toHexString(this.mNativeContext) + " " + this.mDataSource + " " + getPrepareDataMethod();
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaManager.Playable
        public int getNativeContext() {
            return this.mNativeContext;
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaPlayer, android.media.MediaPlayer.OnCompletionListener
        public void onCompletion(MediaPlayer mp) {
            JbedMediaManager.INSTANCE.notifyCompletion(this);
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaPlayer, android.media.MediaPlayer.OnPreparedListener
        public void onPrepared(MediaPlayer mp) {
            JbedMediaManager.INSTANCE.notifyPrepared(this);
        }

        @Override // com.esmertec.android.jbed.jsr.JbedMediaPlayer, android.media.MediaPlayer.OnErrorListener
        public boolean onError(MediaPlayer mp, int arg1, int arg2) {
            JbedMediaManager.INSTANCE.notifyError(this, arg1, arg2);
            return super.onError(mp, arg1, arg2);
        }
    }
}
