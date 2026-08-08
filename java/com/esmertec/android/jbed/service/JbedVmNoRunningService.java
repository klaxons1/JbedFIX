package com.esmertec.android.jbed.service;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.ServiceConnection;
import android.graphics.PixelFormat;
import android.graphics.Point;
import android.net.Uri;
import android.os.Environment;
import android.os.IBinder;
import android.os.RemoteException;
import android.util.Log;
import android.view.Display;
import android.view.WindowManager;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.ams.IJbedAmsConnection;
import com.esmertec.android.jbed.ams.JbedSelector;
import com.esmertec.android.jbed.ams.JbedSelectorData;
import com.esmertec.android.jbed.jsr.JbedMmsManager;
import com.esmertec.android.jbed.util.SimpleEntry;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.regex.Pattern;

/* JADX INFO: loaded from: classes.dex */
public class JbedVmNoRunningService extends Service {
    public static final String TAG = "JbedVmNoRunningService";
    private List<JbedService.LifecycleListener> mLifecycleListeners = new ArrayList();
    private List<VmStateListener> mVmStateListeners = new ArrayList();
    private BroadcastReceiver mVmStateReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.2
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(JbedConstants.ACTION_JBED_VM_STARTED)) {
                LogTag.serviceDebug(JbedVmNoRunningService.TAG, "get ACTION_JBED_VM_STARTED");
                for (VmStateListener l : JbedVmNoRunningService.this.mVmStateListeners) {
                    l.onStarted();
                }
                return;
            }
            if (intent.getAction().equals(JbedConstants.ACTION_JBED_VM_STOPPED)) {
                LogTag.serviceDebug(JbedVmNoRunningService.TAG, "get ACTION_JBED_VM_STOPPED");
                for (VmStateListener l2 : JbedVmNoRunningService.this.mVmStateListeners) {
                    l2.onStopped();
                }
                return;
            }
            throw new UnsupportedOperationException("unsupport action " + intent.getAction());
        }
    };

    private interface VmStateListener {
        void onStarted();

        void onStopped();
    }

    @Override // android.app.Service
    public IBinder onBind(Intent arg0) {
        LogTag.serviceDebug(TAG, "JbedVmNoRunningService onBind");
        return null;
    }

    /* JADX WARN: Type inference failed for: r0v1, types: [com.esmertec.android.jbed.service.JbedVmNoRunningService$1] */
    @Override // android.app.Service
    public void onCreate() {
        LogTag.serviceDebug(TAG, "JbedVmNoRunningService onCreate()");
        new Thread() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.1
            @Override // java.lang.Thread, java.lang.Runnable
            public void run() {
                LogTag.serviceDebug(JbedVmNoRunningService.TAG, "JbedVmNoRunningService Run()");
                JbedVmNoRunningService.this.onInit();
            }
        }.start();
    }

    public void onInit() {
        LogTag.serviceDebug(TAG, "JbedVmNoRunningService onInit()");
        SdcardService ss = new SdcardService();
        this.mLifecycleListeners.add(ss);
        this.mVmStateListeners.add(ss.mVmStatelistener);
        PushRegistryService ps = new PushRegistryService();
        this.mLifecycleListeners.add(ps);
        this.mVmStateListeners.add(ps.mVmStatelistener);
        for (JbedService.LifecycleListener l : this.mLifecycleListeners) {
            l.onCreate(this);
        }
        IntentFilter filter = new IntentFilter();
        filter.addAction(JbedConstants.ACTION_JBED_VM_STARTED);
        filter.addAction(JbedConstants.ACTION_JBED_VM_STOPPED);
        registerReceiver(this.mVmStateReceiver, filter);
    }

    @Override // android.app.Service
    public void onStart(Intent intent, int startId) {
        LogTag.serviceDebug(TAG, "JbedVmNoRunningService onStart()");
    }

    @Override // android.app.Service
    public void onDestroy() {
        LogTag.serviceDebug(TAG, "JbedVmNoRunningService onDestroy()");
        unregisterReceiver(this.mVmStateReceiver);
        for (JbedService.LifecycleListener l : this.mLifecycleListeners) {
            l.onDestroy(this);
        }
        this.mVmStateListeners.clear();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void launchPowerOnMidlets(JbedSelector selector) {
        final List<JbedSelectorData> powerOnMidlets = selector.getPowerOnMidlets();
        if (!powerOnMidlets.isEmpty()) {
            ServiceConnection connection = new ServiceConnection() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.3
                @Override // android.content.ServiceConnection
                public void onServiceConnected(ComponentName name, IBinder service) {
                    IJbedService jbedService = IJbedService.Stub.asInterface(service);
                    try {
                        try {
                            PixelFormat pixFormat = new PixelFormat();
                            PixelFormat.getPixelFormatInfo(4, pixFormat);
                            Display d = ((WindowManager) JbedVmNoRunningService.this.getSystemService("window")).getDefaultDisplay();
                            Point displaySize = new Point();
                            d.getSize(displaySize);
                            jbedService.startVm(displaySize.x, displaySize.y, pixFormat.bytesPerPixel, displaySize.x, displaySize.y, false, false);
                            IJbedAmsConnection amsConn = jbedService.openAmsConnection();
                            amsConn.setPowerOnMidlets(powerOnMidlets);
                            for (JbedSelectorData m : powerOnMidlets) {
                                amsConn.requestEvent(2, m.mNo, m.mRoot.getBytes());
                            }
                            JbedVmNoRunningService.this.unbindService(this);
                        } catch (RemoteException e) {
                            throw new RuntimeException("failed to call requestEvent: " + e);
                        }
                    } catch (Throwable th) {
                        JbedVmNoRunningService.this.unbindService(this);
                        throw th;
                    }
                }

                @Override // android.content.ServiceConnection
                public void onServiceDisconnected(ComponentName name) {
                }
            };
            Intent serviceIntent = new Intent(this, (Class<?>) JbedService.class);
            startService(serviceIntent);
            bindService(serviceIntent, connection, 1);
        }
    }

    static class SdcardService implements JbedService.LifecycleListener {
        private boolean mIsVmStarted = false;
        private BroadcastReceiver SdcardChangedReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.SdcardService.1
            @Override // android.content.BroadcastReceiver
            public void onReceive(Context context, Intent intent) {
                Uri uri = intent.getData();
                String externalStoragePath = Environment.getExternalStorageDirectory().getPath();
                if (uri.getScheme().equals("file") && externalStoragePath.equals(uri.getPath())) {
                    LogTag.serviceDebug(JbedVmNoRunningService.TAG, "rootChangeReceiver start to parse selector files and save them to db!!!");
                    JbedSelector selector = new JbedSelector(JbedSettings.getInstance(context).getBaseDir());
                    if (SdcardService.this.mIsVmStarted) {
                        selector.touch();
                    } else {
                        selector.loadFromFiles();
                        selector.storeToDb(context);
                    }
                }
            }
        };
        private VmStateListener mVmStatelistener = new VmStateListener() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.SdcardService.2
            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.VmStateListener
            public void onStarted() {
                SdcardService.this.mIsVmStarted = true;
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.VmStateListener
            public void onStopped() {
                SdcardService.this.mIsVmStarted = false;
            }
        };

        SdcardService() {
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onCreate(Context context) {
            LogTag.serviceDebug(JbedVmNoRunningService.TAG, "SdcardService onCreate");
            IntentFilter externalStorageFilter = new IntentFilter();
            externalStorageFilter.addAction("android.intent.action.MEDIA_MOUNTED");
            externalStorageFilter.addAction("android.intent.action.MEDIA_UNMOUNTED");
            externalStorageFilter.addAction("android.intent.action.MEDIA_REMOVED");
            externalStorageFilter.addAction("android.intent.action.MEDIA_BAD_REMOVAL");
            externalStorageFilter.addDataScheme("file");
            context.registerReceiver(this.SdcardChangedReceiver, externalStorageFilter);
            LogTag.serviceDebug(JbedVmNoRunningService.TAG, "onCreate start to parse selector files and save them to db!!!");
            JbedSelector selector = new JbedSelector(JbedSettings.getInstance(context).getBaseDir());
            selector.loadFromFiles();
            selector.storeToDb(context);
            if (JbedConfig.launchPowerOn()) {
                ((JbedVmNoRunningService) context).launchPowerOnMidlets(selector);
            }
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onDestroy(Context context) {
            context.unregisterReceiver(this.SdcardChangedReceiver);
        }
    }

    private static class PushRegistryService implements JbedService.LifecycleListener {
        private static final String SCHEMA_ALARM = "alarm";
        private static final String SCHEMA_MMS = "mms";
        private static final String SCHEMA_SMS = "sms";
        private static String TAG = "PushRegistryService";
        private ArrayBlockingQueue<Intent> mCachedPushIntentQueue;
        private Context mContext;
        private PushEntry mMmsPushEntry;
        private List<PushEntry> mPushEntries;
        private VmState mVmState;
        private VmStateListener mVmStatelistener;

        private interface PushEntry {
            void register(String str, String str2);

            void unregister();
        }

        private enum VmState {
            STOPED,
            STARTING,
            STARTED
        }

        private PushRegistryService() {
            this.mVmState = VmState.STOPED;
            this.mCachedPushIntentQueue = new ArrayBlockingQueue<>(10);
            this.mPushEntries = new ArrayList(8);
            this.mVmStatelistener = new VmStateListener() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.1
                @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.VmStateListener
                public void onStarted() {
                    PushRegistryService.this.mVmState = VmState.STARTED;
                    PushRegistryService.this.unregisterAllPushPorts();
                    while (true) {
                        Intent pushIntent = (Intent) PushRegistryService.this.mCachedPushIntentQueue.poll();
                        if (pushIntent != null) {
                            PushRegistryService.this.mContext.sendBroadcast(pushIntent);
                        } else {
                            return;
                        }
                    }
                }

                @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.VmStateListener
                public void onStopped() {
                    PushRegistryService.this.mVmState = VmState.STOPED;
                    PushRegistryService.this.unregisterAllPushPorts();
                    PushRegistryService.this.registerAllPushPorts();
                }
            };
        }

        private class SmsPushEntry implements PushEntry {
            private BroadcastReceiver mReceiver;

            private SmsPushEntry() {
                this.mReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.SmsPushEntry.1
                    @Override // android.content.BroadcastReceiver
                    public void onReceive(Context context, Intent intent) {
                        PushRegistryService.this.cachePushIntent(intent);
                    }
                };
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void register(String port, String param1) {
                LogTag.serviceDebug(PushRegistryService.TAG, "register port" + port);
                IntentFilter filter = new IntentFilter();
                filter.addAction("android.intent.action.DATA_SMS_RECEIVED");
                filter.addDataScheme(PushRegistryService.SCHEMA_SMS);
                filter.addDataAuthority("localhost", String.valueOf(port));
                PushRegistryService.this.mContext.registerReceiver(this.mReceiver, filter);
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void unregister() {
                PushRegistryService.this.mContext.unregisterReceiver(this.mReceiver);
            }
        }

        private class AlarmPushEntry implements PushEntry {
            private Timer mTimer;

            private AlarmPushEntry() {
                this.mTimer = new Timer();
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void register(String port, String param1) {
                long launchTime = Long.parseLong(param1, 16);
                long delayMillis = launchTime - System.currentTimeMillis();
                if (delayMillis < 0) {
                    delayMillis = 0;
                }
                this.mTimer.schedule(new TimerTask() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.AlarmPushEntry.1
                    @Override // java.util.TimerTask, java.lang.Runnable
                    public void run() {
                        PushRegistryService.this.startVmIfNeed();
                    }
                }, delayMillis);
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void unregister() {
                this.mTimer.cancel();
            }
        }

        private class MmsPushEntry implements PushEntry {
            private static final String STATE = "state";
            private static final int SUCCESS = 1;
            private static final String TRANSACTION_COMPLETED_ACTION = "android.intent.action.TRANSACTION_COMPLETED_ACTION";
            private BroadcastReceiver mReceiver;
            private List<String> mRegisteredAppIds;

            private MmsPushEntry() {
                this.mReceiver = null;
                this.mRegisteredAppIds = new ArrayList();
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void register(String port, String param1) {
                if (this.mReceiver == null) {
                    this.mReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.MmsPushEntry.1
                        @Override // android.content.BroadcastReceiver
                        public void onReceive(Context context, Intent intent) {
                            SimpleEntry<String, Integer> info = JbedMmsManager.getMmsAppIdAndType(context, intent);
                            String appId = info.getKey();
                            if (appId == null || MmsPushEntry.this.mRegisteredAppIds.indexOf(appId) == -1) {
                                Log.w(PushRegistryService.TAG, "get a mms which is not belong to registered appId");
                                return;
                            }
                            int messageType = info.getValue().intValue();
                            int state = intent.getIntExtra("state", 0);
                            if (messageType == 132 && state == 1) {
                                PushRegistryService.this.cachePushIntent(intent);
                            }
                        }
                    };
                    IntentFilter filter = new IntentFilter();
                    filter.addAction("android.intent.action.TRANSACTION_COMPLETED_ACTION");
                    PushRegistryService.this.mContext.registerReceiver(this.mReceiver, filter);
                }
                this.mRegisteredAppIds.add(port);
            }

            @Override // com.esmertec.android.jbed.service.JbedVmNoRunningService.PushRegistryService.PushEntry
            public void unregister() {
                if (this.mReceiver != null) {
                    PushRegistryService.this.mContext.unregisterReceiver(this.mReceiver);
                }
                this.mReceiver = null;
                this.mRegisteredAppIds.clear();
            }
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onCreate(Context context) {
            this.mContext = context;
            registerAllPushPorts();
        }

        @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
        public void onDestroy(Context context) {
            unregisterAllPushPorts();
        }

        private PushEntry buildPushEntry(String schema) {
            if (schema.equals(SCHEMA_SMS)) {
                return new SmsPushEntry();
            }
            if (schema.equals(SCHEMA_MMS)) {
                if (this.mMmsPushEntry == null) {
                    this.mMmsPushEntry = new MmsPushEntry();
                }
                return this.mMmsPushEntry;
            }
            if (schema.equals("alarm")) {
                return new AlarmPushEntry();
            }
            throw new RuntimeException("unsupport schema " + schema + " at push entry");
        }

        private String getPushListText() {
            String fileName = JbedSettings.getInstance(this.mContext).getBaseDir() + "pushlist.txt";
            File file = new File(fileName);
            if (file.exists()) {
                byte[] data = new byte[(int) file.length()];
                try {
                    new FileInputStream(file).read(data);
                    return new String(data);
                } catch (IOException e) {
                    Log.w(TAG, " failed to read the content of " + fileName);
                }
            }
            LogTag.serviceDebug(TAG, "Have no push information at " + fileName);
            return "";
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void registerAllPushPorts() {
            Scanner s = new Scanner(getPushListText());
            Pattern p = Pattern.compile("P(\\w+)://:?([\\d|\\w]*),(.*?),.*");
            while (s.hasNext(p)) {
                s.next(p);
                String schema = s.match().group(1);
                String port = s.match().group(2);
                String param1 = s.match().group(3);
                LogTag.serviceDebug(TAG, " register " + schema + ": " + port);
                PushEntry entry = buildPushEntry(schema);
                if (entry != null) {
                    entry.register(port, param1);
                    if (this.mPushEntries.indexOf(entry) == -1) {
                        this.mPushEntries.add(entry);
                    }
                }
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void unregisterAllPushPorts() {
            for (PushEntry entry : this.mPushEntries) {
                entry.unregister();
            }
            this.mPushEntries.clear();
            this.mCachedPushIntentQueue.clear();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void cachePushIntent(Intent intent) {
            if (this.mVmState == VmState.STARTED) {
                Log.w(TAG, "WARNING: Get the sms message while jbedvm is started!!!");
                return;
            }
            if (this.mCachedPushIntentQueue.isEmpty()) {
                LogTag.serviceDebug(TAG, " get the push sms and launch the vm");
                startVmIfNeed();
            }
            this.mCachedPushIntentQueue.add(intent);
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void startVmIfNeed() {
            if (this.mVmState == VmState.STOPED) {
                this.mVmState = VmState.STARTING;
                Intent jbedIntent = new Intent();
                jbedIntent.setClassName(this.mContext.getPackageName(), this.mContext.getPackageName() + ".app.JbedAppActivity");
                jbedIntent.setFlags(268435456);
                this.mContext.startActivity(jbedIntent);
            }
        }
    }
}
