package com.esmertec.android.jbed.jsr;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.ams.JbedSelector;
import com.esmertec.android.jbed.service.JbedService;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedFileManager implements JbedService.LifecycleListener {
    static final /* synthetic */ boolean $assertionsDisabled;
    public static final String EXTERNAL_STORAGE_NAME;
    private static JbedFileManager INSTANCE = null;
    public static final String ROOT_STORAGE_DIR = "data";
    public static final String SDCARD_FOLDER_NAME = "sdcard";
    public static final String SDCARD_FOLDER_PATH = "/mnt/sdcard";
    private static final String TAG = "JbedFileManager";
    public static final String[] rootNames;
    public static final String[] rootPaths;
    private Context mContext;
    private Handler mHandler;
    List<RootChangeListener> mListeners;
    private BroadcastReceiver rootChangeReceiver;

    public interface RootChangeListener {
        void onRootChanged(String str, String str2, boolean z);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifyRootChanged(String str, String str2, boolean z);

    static {
        $assertionsDisabled = !JbedFileManager.class.desiredAssertionStatus();
        EXTERNAL_STORAGE_NAME = SDCARD_FOLDER_NAME + File.separator;
        rootNames = new String[]{EXTERNAL_STORAGE_NAME};
        rootPaths = new String[]{SDCARD_FOLDER_PATH};
    }

    public JbedFileManager(Handler handler) {
        this(null, handler);
    }

    public JbedFileManager(Context context, Handler handler) {
        this.mListeners = new ArrayList();
        this.rootChangeReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.jsr.JbedFileManager.1
            @Override // android.content.BroadcastReceiver
            public void onReceive(Context context2, final Intent intent) {
                if (JbedFileManager.this.mHandler != null) {
                    Message msg = JbedFileManager.this.mHandler.obtainMessage(3);
                    msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedFileManager.1.1
                        @Override // java.lang.Runnable
                        public void run() {
                            if (intent.getData() == null) {
                                throw new AssertionError();
                            }
                            Uri uri = intent.getData();
                            String externalStoragePath = Environment.getExternalStorageDirectory().getPath();
                            if (uri.getScheme().equals("file") && externalStoragePath.equals(uri.getPath().substring(0, 11))) {
                                boolean isAdded = false;
                                if (intent.getAction().equals("android.intent.action.MEDIA_MOUNTED")) {
                                    isAdded = true;
                                    Log.i(JbedFileManager.TAG, " mouted sdcard at " + externalStoragePath);
                                } else {
                                    Log.i(JbedFileManager.TAG, " unmounted sdcard from " + externalStoragePath);
                                }
                                for (RootChangeListener listener : JbedFileManager.this.mListeners) {
                                    listener.onRootChanged(JbedFileManager.convertFilePath(JbedFileManager.EXTERNAL_STORAGE_NAME), JbedFileManager.convertFilePath(externalStoragePath), isAdded);
                                }
                                JbedSelector selector = new JbedSelector(JbedSettings.getInstance(JbedFileManager.this.mContext).getBaseDir());
                                selector.touch();
                            }
                        }
                    };
                    msg.sendToTarget();
                }
            }
        };
        this.mContext = context;
        this.mHandler = handler;
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
        IntentFilter externalStorageFilter = new IntentFilter();
        externalStorageFilter.addAction("android.intent.action.MEDIA_MOUNTED");
        externalStorageFilter.addAction("android.intent.action.MEDIA_UNMOUNTED");
        externalStorageFilter.addAction("android.intent.action.MEDIA_REMOVED");
        externalStorageFilter.addAction("android.intent.action.MEDIA_BAD_REMOVAL");
        externalStorageFilter.addAction("android.intent.action.MEDIA_EJECT");
        externalStorageFilter.addDataScheme("file");
        context.registerReceiver(this.rootChangeReceiver, externalStorageFilter);
        this.mListeners.add(new RootChangeListener() { // from class: com.esmertec.android.jbed.jsr.JbedFileManager.2
            @Override // com.esmertec.android.jbed.jsr.JbedFileManager.RootChangeListener
            public void onRootChanged(String rootName, String rootPath, boolean isAdded) {
                JbedFileManager.nativeNotifyRootChanged(rootName, rootPath, isAdded);
            }
        });
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        context.unregisterReceiver(this.rootChangeReceiver);
        this.mListeners.clear();
        INSTANCE = null;
    }

    public static boolean isExternalStorageReady() {
        String state = Environment.getExternalStorageState();
        return state.equals("mounted") || state.equals("mounted_ro");
    }

    private static int getRootCount() {
        return isExternalStorageReady() ? rootNames.length : rootNames.length - 1;
    }

    static String convertFilePath(String path) {
        if (!$assertionsDisabled && path == null) {
            throw new AssertionError();
        }
        if (path.charAt(path.length() - 1) != File.separatorChar) {
            return path + File.separatorChar;
        }
        return path;
    }

    static byte[] getRootNames() {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        for (int i = 0; i < rootNames.length; i++) {
            try {
                if (!rootNames[i].equals(EXTERNAL_STORAGE_NAME) || isExternalStorageReady()) {
                    out.write(convertFilePath(rootNames[i]).getBytes("utf-8"));
                    out.writeByte(0);
                }
            } catch (Exception e) {
                throw new IllegalArgumentException("incrroect root name definition");
            }
        }
        return bo.toByteArray();
    }

    static byte[] getRootPaths() {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            List<String> roots = INSTANCE.getRootPathList();
            for (String path : roots) {
                out.write(convertFilePath(path).getBytes("utf-8"));
                out.writeByte(0);
            }
            return bo.toByteArray();
        } catch (Exception e) {
            throw new IllegalArgumentException("incrroect root name definition");
        }
    }

    public List<String> getRootPathList() {
        List<String> result = new ArrayList<>();
        String[] arr$ = rootPaths;
        for (String path : arr$) {
            // The 2011 build compared the physical path with "sdcard/", so
            // this branch could never run. /mnt/sdcard is not a usable app
            // storage root on current Android; provide the platform's actual
            // legacy external-storage path to the native FileConnection VM.
            if (SDCARD_FOLDER_PATH.equals(path)) {
                if (isExternalStorageReady()) {
                    result.add(Environment.getExternalStorageDirectory().getPath());
                }
            } else {
                result.add(path);
            }
        }
        return result;
    }

    static byte[] getRoots() {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            out.writeByte(getRootCount());
            byte[] names = getRootNames();
            out.writeShort(names.length);
            out.write(names);
            byte[] paths = getRootPaths();
            out.writeShort(paths.length);
            out.write(paths);
            Log.i(TAG, "native root payload: state=" + Environment.getExternalStorageState()
                    + " count=" + getRootCount() + " namesBytes=" + names.length
                    + " pathsBytes=" + paths.length);
            return bo.toByteArray();
        } catch (IOException e) {
            Log.e(TAG, "failed to serialize J2ME file roots", e);
            throw new IllegalArgumentException("failed to get the roots.", e);
        } catch (Throwable e2) {
            // This method is called through the legacy VM's JNI bridge. Keep
            // the original failure contract, but retain the Java cause in
            // logcat instead of making the native RuntimeException opaque.
            Log.e(TAG, "failed to build J2ME file roots", e2);
            throw new IllegalArgumentException("failed to get the roots.", e2);
        }
    }
}
