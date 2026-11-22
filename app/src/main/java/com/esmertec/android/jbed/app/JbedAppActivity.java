package com.esmertec.android.jbed.app;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Gravity;
import android.view.Surface;
import android.view.View;
import android.widget.AbsoluteLayout;
import android.widget.FrameLayout;
import android.widget.Toast;
import com.esmertec.android.jbed.JbedApp;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedLog;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.ams.AmsActivity;
import com.esmertec.android.jbed.ams.AmsClientBase;
import com.esmertec.android.jbed.ams.AmsConstants;
import com.esmertec.android.jbed.ams.JbedSelectorData;
import com.esmertec.android.jbed.jsr.JbedVideoView;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;
import com.esmertec.android.jbed.service.IJbedConnection;
import com.esmertec.android.jbed.service.IJbedService;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedAppActivity extends Activity implements JbedConstants {
    private static final String INTENT_EXTRA_NO = "no";
    private static final String INTENT_EXTRA_ROOT = "root";
    public static final int RESULT_NO_RUNNING_MIDLET = 2;
    private static Intent SmsIntent = null;
    private static final String TAG = "JbedAppActivity";
    private boolean isInitialized;
    private boolean mIsFullScreen;
    private boolean mIsPendingSoftButtonChanged;
    private boolean mIsRotating;
    private JbedView mJbedView;
    private JbedControls mControls;
    private FrameLayout mGameViewport;
    private FrameLayout mGameFrame;
    private int mVirtualWidth;
    private int mVirtualHeight;
    private AlertDialog mGameMenu;
    private AlertDialog mExitDialog;
    private boolean mExitRequested;
    private String mCurrentRoot;
    private int mCurrentNo;
    private String mExitRoot;
    private int mExitNo;
    private JbedView.Callback mJbedViewCallback;
    private String mLeftButton;
    private boolean mPaused;
    private String mRightButton;
    private JbedVideoClientImpl mVideoClient;
    private Handler mHandler = new Handler() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.1
        @Override // android.os.Handler
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case AmsConstants.HANDLE_MIDLET_STATE_CHANGED:
                    onMidletStateChanged(msg.arg1, msg.arg2, (String) msg.obj);
                    return;
                case 10013:
                    break;
                case AmsConstants.HANDLE_GET_INSTALLED_STORAGE /* 10022 */:
                    Intent jbedIntent = new Intent(JbedAppActivity.this, (Class<?>) AmsActivity.class);
                    jbedIntent.setFlags(AmsConstants.HANDLE_GET_INSTALLED_STORAGE);
                    JbedAppActivity.this.startActivity(jbedIntent);
                    JbedAppActivity.this.finish();
                    return;
                case AmsConstants.HANDLE_INITIALIZE_JBED /* 10023 */:
                    JbedAppActivity.this.initialize(true);
                    return;
                case JbedApp.EVENT_SERVICE_CONNECTED /* 99001 */:
                    LogTag.appDebug(JbedAppActivity.TAG, "get EVENT_SERVICE_CONNECTED from JbedApp");
                    if (JbedAppActivity.this.mJbedViewCallback != null) {
                        if (JbedAppActivity.this.mIsFullScreen) {
                            LogTag.appDebug(JbedAppActivity.TAG, "......setStartWay......from home and fullscreen");
                            JbedAppActivity.this.mJbedView.setStartWay(true);
                        }
                        JbedAppActivity.this.mJbedViewCallback.onServiceConnected();
                        return;
                    }
                    Log.w(JbedAppActivity.TAG, "WARNING: mJbedViewCallback is null! failed to calback onConnected");
                    return;
                case JbedApp.EVENT_SERVICE_DISCONNECTED /* 99002 */:
                    Log.w(JbedAppActivity.TAG, "WARNING: get EVENT_SERVICE_DISCONNECTED from JbedApp");
                    JbedAppActivity.this.finish();
                    break;
                case 120000:
                    LogTag.appDebug(JbedAppActivity.TAG, "get EVENT_SURFACE_CREATED from JbedView");
                    return;
                case JbedView.EVENT_ON_SURFACE_DESTROYED /* 120001 */:
                    LogTag.appDebug(JbedAppActivity.TAG, "get EVENT_SURFACE_DESTROYED from JbedView");
                    return;
                case JbedView.EVENT_ON_SERVICE_REQUEST_FINISH /* 120002 */:
                    LogTag.appDebug(JbedAppActivity.TAG, "get EVENT_ON_SERVICE_REQUEST_FINISH from JbedView");
                    if (mExitRequested) returnToSelector();
                    else JbedAppActivity.this.finish();
                    return;
                case JbedView.EVENT_ON_SOFTBUTTON_CHANGED:
                    String[] labels = (String[]) msg.obj;
                    mLeftButton = labels[0];
                    mRightButton = labels[1];
                    if (mControls != null) mControls.setSoftKeys(mLeftButton, mRightButton);
                    return;
                case JbedView.EVENT_ON_VM_READY /* 120003 */:
                    LogTag.appDebug(JbedAppActivity.TAG, "get EVENT_ON_VM_READY from JbedView");
                    Intent homeIntent = JbedAppActivity.this.getIntent();
                    if (homeIntent.hasExtra("root") && homeIntent.hasExtra("no")) {
                        JbedAppActivity.this.mJbedView.runMidlet(homeIntent.getStringExtra("root"), homeIntent.getIntExtra("no", 0));
                        return;
                    } else {
                        postDelayed(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.1.2
                            @Override // java.lang.Runnable
                            public void run() {
                                if (JbedAppActivity.this.mJbedViewCallback != null) {
                                    JbedAppActivity.this.mJbedViewCallback.onMidletStarted();
                                } else {
                                    Log.w(JbedAppActivity.TAG, "WARNING: mJbedViewCallback is null! failed to callback onMidletStarted");
                                }
                            }
                        }, 400L);
                        return;
                    }
                default:
                    Log.w(JbedAppActivity.TAG, "WARNING: unhandled event " + msg.what);
                    return;
            }
            postDelayed(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.1.1
                @Override // java.lang.Runnable
                public void run() {
                    if (JbedAppActivity.this.mJbedViewCallback != null) {
                        JbedAppActivity.this.mJbedViewCallback.onMidletStarted();
                    } else {
                        Log.w(JbedAppActivity.TAG, "WARNING: mJbedViewCallback is null! failed to callback onMidletStarted");
                    }
                }
            }, 400L);
        }
    };
    private BroadcastReceiver mVmStateReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.2
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(JbedConstants.ACTION_JBED_VM_STARTED)) {
                LogTag.serviceDebug(JbedAppActivity.TAG, "get ACTION_JBED_VM_STARTED SmsIntent=" + JbedAppActivity.SmsIntent);
                if (JbedAppActivity.SmsIntent != null) {
                    LogTag.appDebug(JbedAppActivity.TAG, "sendBroadcast(SmsIntent)");
                    Intent pushSmsIntent = new Intent();
                    pushSmsIntent.setAction(JbedConstants.ACTION_JBED_PUSH_SMS);
                    pushSmsIntent.putExtra(JbedConstants.ACTION_JBED_PUSH_SMS, JbedAppActivity.SmsIntent);
                    JbedAppActivity.this.sendBroadcast(pushSmsIntent);
                }
            }
        }
    };
    private JbedView.ServiceConnector mConnector = new JbedView.ServiceConnector() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.3
        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public void connect(JbedView.Callback callback) {
            JbedAppActivity.this.getApp().startService(JbedAppActivity.this, JbedAppActivity.this.mHandler, 0L);
            JbedAppActivity.this.mJbedViewCallback = callback;
        }

        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public void disconnect() {
            LogTag.appDebug(JbedAppActivity.TAG, "disconnect from service ");
            JbedAppActivity.this.getApp().disconnet(JbedAppActivity.this.mHandler);
        }

        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public AmsClientBase getAmsClient() {
            return JbedAppActivity.this.getApp().getAmsClient(JbedAppActivity.this.mHandler);
        }

        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public IJbedConnection getJbedConn() {
            return JbedAppActivity.this.getApp().mJbedConn;
        }

        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public IJbedService getJbedService() {
            return JbedAppActivity.this.getApp().mJbedService;
        }

        @Override // com.esmertec.android.jbed.app.JbedView.ServiceConnector
        public IJbedTextFieldConnection getTextFieldConn() {
            return JbedAppActivity.this.getApp().mJbedTextFieldConnection;
        }
    };
    private int mOrientation = 0;

    /* JADX INFO: Access modifiers changed from: private */
    public JbedApp getApp() {
        return (JbedApp) getApplication();
    }

    @Override // android.app.Activity, android.content.ComponentCallbacks
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        LogTag.appDebug(TAG, "onConfigurationChanged():" + this.mOrientation + "->" + getResources().getConfiguration().orientation);
        if (this.mOrientation != getResources().getConfiguration().orientation) {
            this.mOrientation = getResources().getConfiguration().orientation;
            if (this.mJbedView != null) {
                if (!this.mPaused) {
                    this.mJbedView.setRotateHappen(true);
                    this.mIsRotating = true;
                } else {
                    return;
                }
            }
            reserveVideoPlayer();
            Message message = this.mHandler.obtainMessage(AmsConstants.HANDLE_INITIALIZE_JBED);
            this.mHandler.removeMessages(AmsConstants.HANDLE_INITIALIZE_JBED);
            this.mHandler.sendMessageDelayed(message, 1200L);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void initialize(boolean force) {
        if (!this.isInitialized || force) {
            LogTag.appDebug(TAG, "initialize()===================");
            setContentView(R.layout.jbed);
            View frameParent = findViewById(R.id.frameParent);
            View videoParent = findViewById(R.id.videoParent);
            AbsoluteLayout videoRegionLayout = (AbsoluteLayout) findViewById(R.id.videoRegionView);
            JbedVideoView vView = (JbedVideoView) findViewById(R.id.jbedVideoView);
            vView.setZOrderMediaOverlay(true);
            vView.setParentView(videoParent, frameParent);
            if (this.mVideoClient == null) {
                this.mVideoClient = new JbedVideoClientImpl(this.mHandler, videoRegionLayout, vView, videoParent, frameParent);
            } else {
                this.mVideoClient.updateView(videoRegionLayout, vView, videoParent, frameParent);
            }
            this.mJbedView = (JbedView) findViewById(R.id.jbedView);
            setupControls();
            this.mJbedView.mVideoClient = this.mVideoClient;
            restoreVideoPlayer();
            this.mJbedView.setup(this.mHandler, this.mConnector);
            this.mJbedView.requestFocus();
            getWindow().setFormat(-3);
            videoRegionLayout.setLayoutParams(new AbsoluteLayout.LayoutParams(JbedVideoView.mDefaultLocation.width(), JbedVideoView.mDefaultLocation.height(), JbedVideoView.mDefaultLocation.left, JbedVideoView.mDefaultLocation.top));
            AbsoluteLayout nativeWidgetView = (AbsoluteLayout) findViewById(R.id.nativeWidgetView);
            this.mJbedView.setOverlayView(nativeWidgetView);
            this.isInitialized = true;
            return;
        }
        LogTag.appDebug(TAG, "initialize()========ingore it ===========");
    }

    private void setupControls() {
        SharedPreferences preferences = getSharedPreferences(JbedControls.PREFERENCES, MODE_PRIVATE);
        mVirtualWidth = preferences.getInt("width", 240);
        mVirtualHeight = preferences.getInt("height", 320);
        mJbedView.setVirtualSize(mVirtualWidth, mVirtualHeight);
        mGameViewport = (FrameLayout) findViewById(R.id.gameViewport);
        mGameFrame = (FrameLayout) findViewById(R.id.frameParent);
        mGameViewport.addOnLayoutChangeListener((view, left, top, right, bottom,
                oldLeft, oldTop, oldRight, oldBottom) -> fitGameFrame());
        mControls = (JbedControls) findViewById(R.id.gameControls);
        mControls.setSoftKeys(mLeftButton, mRightButton);
        mControls.setCallback(new JbedControls.Callback() {
            @Override
            public void onKey(KeyEvent event) {
                mJbedView.dispatchGameKey(event);
            }

            @Override
            public void onOpenMenu() {
                showGameMenu();
            }
        });
    }

    private void fitGameFrame() {
        int width = mGameViewport.getWidth();
        int height = mGameViewport.getHeight();
        if (width == 0 || height == 0) return;
        if (mVirtualWidth > 0 && mVirtualHeight > 0) {
            if ((long) width * mVirtualHeight > (long) height * mVirtualWidth) {
                width = Math.max(1, height * mVirtualWidth / mVirtualHeight);
            } else {
                height = Math.max(1, width * mVirtualHeight / mVirtualWidth);
            }
        }
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mGameFrame.getLayoutParams();
        if (params.width != width || params.height != height) {
            params.width = width;
            params.height = height;
            params.gravity = Gravity.CENTER;
            mGameFrame.setLayoutParams(params);
        }
    }

    private void chooseScreenSize() {
        final int[][] sizes = {{0, 0}, {128, 128}, {128, 160}, {176, 208}, {240, 320}, {320, 240}, {320, 480}, {480, 320}};
        String[] labels = {getString(R.string.GAME_DEVICE_SIZE), "128 × 128", "128 × 160", "176 × 208", "240 × 320",
                "320 × 240", "320 × 480", "480 × 320"};
        int selected = 0;
        for (int i = 0; i < sizes.length; i++) {
            if (sizes[i][0] == mVirtualWidth && sizes[i][1] == mVirtualHeight) selected = i;
        }
        new AlertDialog.Builder(this).setTitle(R.string.GAME_SCREEN_SIZE)
                .setSingleChoiceItems(labels, selected, (dialog, which) -> {
                    mVirtualWidth = sizes[which][0];
                    mVirtualHeight = sizes[which][1];
                    getSharedPreferences(JbedControls.PREFERENCES, MODE_PRIVATE).edit()
                            .putInt("width", mVirtualWidth).putInt("height", mVirtualHeight).apply();
                    mJbedView.setVirtualSize(mVirtualWidth, mVirtualHeight);
                    fitGameFrame();
                    dialog.dismiss();
                }).setNegativeButton(android.R.string.cancel, null).show();
    }

    private void showGameMenu() {
        if (isFinishing() || isDestroyed()) return;
        if (mControls != null) mControls.releaseKeys();
        if (mExitRequested) {
            showExitProgress();
            return;
        }
        if (mGameMenu != null && mGameMenu.isShowing()) return;
        String[] items = {getString(R.string.GAME_RESUME), getString(R.string.GAME_CONTROLS),
                getString(R.string.GAME_SCREEN_SIZE), getString(R.string.GAME_EXIT)};
        mGameMenu = new AlertDialog.Builder(this).setTitle(R.string.GAME_MENU)
                .setItems(items, (dialog, which) -> {
                    if (which == 1) mControls.chooseLayout();
                    else if (which == 2) chooseScreenSize();
                    else if (which == 3) exitGame();
                }).create();
        mGameMenu.show();
    }

    private void showExitProgress() {
        if (mExitDialog != null && mExitDialog.isShowing()) return;
        mExitDialog = new AlertDialog.Builder(this).setTitle(R.string.GAME_EXIT)
                .setMessage(R.string.GAME_EXITING)
                .setNegativeButton(R.string.GAME_DISMISS, null).show();
    }

    private void exitGame() {
        final AmsClientBase client = getApp().getAmsClient(mHandler);
        if (client == null) {
            Toast.makeText(this, R.string.GAME_EXIT_UNAVAILABLE, Toast.LENGTH_LONG).show();
            return;
        }
        mExitRequested = true;
        showExitProgress();
        final String currentRoot = mCurrentRoot;
        final int currentNo = mCurrentNo;
        new Thread(() -> {
            try {
                List<JbedSelectorData> running = client.getRunningMidletList();
                JbedSelectorData target = null;
                for (JbedSelectorData midlet : running) {
                    if (midlet.mRoot.equals(currentRoot)
                            && (currentNo == 0 || midlet.mNo == currentNo)) {
                        target = midlet;
                        break;
                    }
                    // AMS moves the most recently resumed MIDlet to the end.
                    if (target == null || !midlet.mIsPaused) target = midlet;
                }
                final JbedSelectorData selected = target;
                mHandler.post(() -> {
                    if (isFinishing() || isDestroyed()) return;
                    if (selected == null) {
                        returnToSelector();
                        return;
                    }
                    mExitRoot = selected.mRoot;
                    mExitNo = selected.mNo;
                    new Thread(() -> {
                        try {
                            client.requestDestroyEvent(selected.mRoot, selected.mNo);
                        } catch (RuntimeException e) {
                            reportExitFailure(e);
                        }
                    }, "JbedExitRequest").start();
                });
            } catch (RuntimeException e) {
                reportExitFailure(e);
            }
        }, "JbedExitLookup").start();
    }

    private void reportExitFailure(RuntimeException error) {
        Log.w(TAG, "Unable to request MIDlet exit", error);
        mHandler.post(() -> {
            if (isFinishing() || isDestroyed()) return;
            mExitRequested = false;
            mExitRoot = null;
            if (mExitDialog != null) mExitDialog.dismiss();
            Toast.makeText(this, R.string.GAME_EXIT_UNAVAILABLE, Toast.LENGTH_LONG).show();
        });
    }

    private void onMidletStateChanged(int event, int no, String root) {
        if (root == null) return;
        if (event == AmsConstants.EVENT_RUNNING) {
            mCurrentRoot = root.trim();
            mCurrentNo = no;
        } else if (event == AmsConstants.EVENT_DESTROYED && mExitRequested
                && mExitRoot != null && mExitRoot.equals(root.trim())
                && (no == 0 || no == mExitNo)) {
            returnToSelector();
        }
    }

    private void returnToSelector() {
        if (isFinishing() || isDestroyed()) return;
        if (mExitDialog != null) mExitDialog.dismiss();
        Intent selector = new Intent(this, AmsActivity.class);
        selector.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        startActivity(selector);
        finish();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void reserveVideoPlayer() {
        if (this.mJbedView.mVideoClient != null) {
            ((JbedVideoClientImpl) this.mJbedView.mVideoClient).savePlayerState();
        }
        this.mJbedView.dispatchWindowVisibilityChanged(4);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void restoreVideoPlayer() {
        this.mJbedView.dispatchWindowVisibilityChanged(0);
    }

    @Override // android.app.Activity
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        JbedLog.intent(TAG, "JbedAppActivity.onCreate", getIntent());
        Intent intent = getIntent();
        mCurrentRoot = intent.getStringExtra(INTENT_EXTRA_ROOT);
        mCurrentNo = intent.getIntExtra(INTENT_EXTRA_NO, 0);
        SmsIntent = (Intent) intent.getParcelableExtra(JbedConstants.ACTION_JBED_PUSH_SMS);
        this.mIsFullScreen = intent.getBooleanExtra(AmsConstants.FULL_SCREEN_FLAG, false);
        LogTag.appDebug(TAG, "JbedActivity onCreate ");
        getWindow().setFormat(-3);
        requestWindowFeature(1);
        initialize(true);
        updateTCKInfoIfNeed(getIntent(), this);
        IntentFilter filter = new IntentFilter();
        filter.addAction(JbedConstants.ACTION_JBED_VM_STARTED);
        registerReceiver(this.mVmStateReceiver, filter);
        JbedView.isMidletStarting = true;
    }

    @Override // android.app.Activity
    protected void onResume() {
        LogTag.appDebug(TAG, "JbedActivity onResume");
        this.mPaused = false;
        initialize(false);
        this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.4
            @Override // java.lang.Runnable
            public void run() {
                JbedAppActivity.this.restoreVideoPlayer();
            }
        });
        super.onResume();
    }

    @Override // android.app.Activity
    protected void onPause() {
        LogTag.appDebug(TAG, "JbedActivity onPause");
        if (mControls != null) mControls.releaseKeys();
        this.mPaused = true;
        if (this.mJbedView != null && this.mIsRotating) {
            this.mJbedView.setRotateHappen(false);
            this.mJbedView.requestVmBackground();
            this.mIsRotating = false;
        }
        this.isInitialized = false;
        this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.app.JbedAppActivity.5
            @Override // java.lang.Runnable
            public void run() {
                JbedAppActivity.this.reserveVideoPlayer();
            }
        });
        super.onPause();
    }

    @Override // android.app.Activity
    protected void onStop() {
        LogTag.appDebug(TAG, "JbedActivity onStop");
        super.onStop();
    }

    @Override // android.app.Activity
    protected void onDestroy() {
        LogTag.appDebug(TAG, "JbedActivity onDestroy");
        if (mGameMenu != null) mGameMenu.dismiss();
        if (mExitDialog != null) mExitDialog.dismiss();
        unregisterReceiver(this.mVmStateReceiver);
        super.onDestroy();
    }

    @Override // android.app.Activity
    protected void onActivityResult(int requestCode, int resultCode, Intent extras) {
        super.onActivityResult(requestCode, resultCode, extras);
        if (resultCode == 2) {
            finish();
        }
    }

    @Override // android.app.Activity, android.view.KeyEvent.Callback
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) return super.onKeyDown(keyCode, event);
        boolean isConsumed = this.mJbedView.dispatchKeyEvent(event);
        if (isConsumed) {
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override // android.app.Activity, android.view.KeyEvent.Callback
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK) return super.onKeyUp(keyCode, event);
        boolean isConsumed = this.mJbedView.dispatchKeyEvent(event);
        if (isConsumed) {
            return true;
        }
        return super.onKeyUp(keyCode, event);
    }

    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if (event.getKeyCode() == KeyEvent.KEYCODE_BACK
                || event.getKeyCode() == KeyEvent.KEYCODE_MENU) {
            // IME pre-dispatch handles keyboard dismissal before this callback.
            if (event.getAction() == KeyEvent.ACTION_UP && !event.isCanceled()) showGameMenu();
            return true;
        }
        return super.dispatchKeyEvent(event);
    }

    @Override
    public void onBackPressed() {
        showGameMenu();
    }

    private void updateTCKInfoIfNeed(Intent mIntent, Context context) {
        Bundle b = mIntent.getExtras();
        if (b != null && b.containsKey("tck_enable")) {
            JbedSettings.getInstance(context).updateTckInfo(b.getString("tck_url"), true);
            LogTag.appDebug(TAG, "Updated tck info: tck_enabled");
        }
    }
}
