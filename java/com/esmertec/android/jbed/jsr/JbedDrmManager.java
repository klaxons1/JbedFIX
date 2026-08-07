package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.os.Handler;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.service.JbedService;

/* JADX INFO: loaded from: classes.dex */
public class JbedDrmManager implements JbedService.LifecycleListener {
    private static final int CPL_DRM_CONSTRAINT_COUNT = 1;
    private static final int CPL_DRM_CONSTRAINT_DATETIME_END = 4;
    private static final int CPL_DRM_CONSTRAINT_DATETIME_START = 2;
    private static final int CPL_DRM_CONSTRAINT_INTERVAL = 8;
    private static final int CPL_DRM_EOF = -2;
    private static final int CPL_DRM_FAILURE = -1;
    private static final int CPL_DRM_SUCCESS = 0;
    private static final boolean DEBUG = false;
    public static final String DM_FILENAME = ".dm";
    public static final String DRM_FILENAME = ".drm";
    public static final int JBED_DRM_METHOD_TYPE_CD = 2;
    public static final int JBED_DRM_METHOD_TYPE_FL = 1;
    public static final int JBED_DRM_METHOD_TYPE_SD = 3;
    private static final int JBED_DRM_MIMETYPE_CONTENT = 2;
    private static final int JBED_DRM_MIMETYPE_MESSAGE = 1;
    private static final int JBED_DRM_MIMETYPE_RIGHTS_WBXML = 4;
    private static final int JBED_DRM_MIMETYPE_RIGHTS_XML = 3;
    public static final int JBED_DRM_PERMISSION_DISPLAY = 2;
    public static final int JBED_DRM_PERMISSION_EXECUTE = 3;
    public static final int JBED_DRM_PERMISSION_PLAY = 1;
    public static final int JBED_DRM_PERMISSION_PRINT = 4;
    private static final String TAG = "JbedDrmManager";
    private static Context mContext;

    private static native void nativeInitialization(String str);

    static {
        nativeInitialization(JbedProvider.Settings.DEFAULT_PENDINGINSTALL_DIR);
    }

    public JbedDrmManager(Handler handler) {
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        mContext = context;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
    }

    public static int getDrmMethodType(String drmFilename) {
        return 0;
    }
}
