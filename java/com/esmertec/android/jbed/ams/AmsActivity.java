package com.esmertec.android.jbed.ams;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ListActivity;
import android.app.ProgressDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.graphics.PixelFormat;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.os.StatFs;
import android.text.TextUtils;
import android.view.ContextMenu;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.TextView;
import com.esmertec.android.jbed.JbedApp;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.app.JbedAppActivity;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.esmertec.android.jbed.jsr.TransactionService;
import com.esmertec.android.jbed.util.I18N;
import com.google.android.collect.Lists;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/* JADX INFO: loaded from: classes.dex */
public class AmsActivity extends ListActivity implements AmsConstants {
    private static final int AMS_MAIN_SCREEN_TITLE = 92;
    private static final int AMS_MODULE_ID = 4;
    private static final String CURRENT_STORAGE_NAME = "current.storage";
    public static final int DIALOG_INSTALL = 0;
    public static final int DIALOG_WAIT = 1;
    public static final int EXTERNAL_STORAGE_INDEX = 1;
    public static final int HORIZOTAL_DIALOG = 2;
    public static final int INTERNAL_STORAGE_INDEX = 0;
    public static final int IS_CONTEXT_ITEM_SELECTED = 1;
    public static final int IS_NOT_CONTEXT_ITEM_SELECTED = 0;
    public static final int LANDSCAPE_MAX_WIDTH = 370;
    private static final String LIST_ORDER_NAME = "list.order";
    private static final int MINIMUM_MEMORY_SIZE = 10240000;
    static final String TAG = "AmsActivity";
    private AmsListAdapter mListAdapter;
    private Menu mOptionMenu;
    private static Map<Integer, Comparator<JbedSelectorData>> sListOrderMap = new HashMap();
    private static boolean hasInitAmsClient = false;
    private static boolean mJbedExiting = false;
    private ProgressDialog mInstallDialog = null;
    private Handler mHandler = new AmsHandler();
    private ArrayList<Message> mPendingQueue = Lists.newArrayList();
    private boolean mIsServiceConnected = false;
    private final String mDevKeys = "123";
    private StringBuffer mInputDevKeys = new StringBuffer();
    JbedSelectorData mCurSelectedItem = null;
    JbedSelectorData mCurFolder = null;
    private boolean isContextItemSelected = false;
    private BroadcastReceiver mRefreshReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.ams.AmsActivity.1
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            AmsActivity.this.mHandler.obtainMessage(10002).sendToTarget();
        }
    };

    static {
        sListOrderMap.put(Integer.valueOf(R.id.sort_by_name_menu_item), JbedSelectorData.NAME_ORDER);
        sListOrderMap.put(Integer.valueOf(R.id.sort_by_reverse_name_menu_item), JbedSelectorData.NAME_REVERSE_ORDER);
        sListOrderMap.put(Integer.valueOf(R.id.sort_by_size_menu_item), JbedSelectorData.SIZE_ORDER);
        sListOrderMap.put(Integer.valueOf(R.id.sort_by_time_menu_item), JbedSelectorData.INSTALLTIME_ORDER);
    }

    public static void initAmsClient(AmsClient client) {
        if (client == null) {
            LogTag.amsDebug(TAG, "initAmsClient() client is null!");
        } else if (!hasInitAmsClient) {
            client.requestInstallCancelEvent();
            client.releaseInstallLock();
            hasInitAmsClient = true;
        }
    }

    @Override // android.app.Activity
    public boolean onContextItemSelected(MenuItem item) {
        this.isContextItemSelected = true;
        onOptionsItemSelected(item);
        return super.onContextItemSelected(item);
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            getListView().requestFocusFromTouch();
            if (this.mListAdapter.mList.size() > 0) {
                if (this.mCurSelectedItem == null) {
                    this.mCurSelectedItem = this.mListAdapter.mList.get(0);
                }
                int index = this.mListAdapter.mList.indexOf(this.mCurSelectedItem);
                if (index == -1) {
                    index = 0;
                }
                getListView().setSelection(index);
                this.mCurSelectedItem = this.mListAdapter.mList.get(index);
            }
        }
    }

    @Override // android.app.Activity
    protected void onCreate(Bundle icicle) {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onCreate");
        super.onCreate(icicle);
        setContentView(R.layout.ams_list);
        this.mListAdapter = new AmsListAdapter(this);
        this.mListAdapter.mList = new ArrayList(0);
        setListAdapter(this.mListAdapter);
        getListView().setEmptyView(findViewById(R.id.empty));
        getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() { // from class: com.esmertec.android.jbed.ams.AmsActivity.2
            @Override // android.widget.AdapterView.OnItemClickListener
            public void onItemClick(AdapterView<?> parent, View arg1, int position, long id) {
                if (!AmsActivity.mJbedExiting) {
                    AmsActivity.this.mCurSelectedItem = (JbedSelectorData) parent.getAdapter().getItem(position);
                    AmsActivity.this.getListView().setSelection(position);
                    AmsClient client = AmsActivity.this.getAmsClient();
                    if (client != null) {
                        if (AmsActivity.this.mCurSelectedItem.isDrmPending()) {
                            client.requestDrmInstallEvent(AmsActivity.this.mCurSelectedItem.mRoot);
                            return;
                        }
                        if (AmsActivity.this.mCurSelectedItem.isMidlet()) {
                            if (AmsActivity.hasEnoughFreeMemory()) {
                                AmsActivity.this.getAmsClient().requestRunEvent(AmsActivity.this.mCurSelectedItem.mRoot, AmsActivity.this.mCurSelectedItem.mNo);
                                return;
                            } else {
                                AmsActivity.this.showWarningDialog(AmsActivity.this.getString(R.string.AMS_WARNING), AmsActivity.this.getString(R.string.AMS_NO_ENOUGH_MEMORY));
                                return;
                            }
                        }
                        if (!JbedConfig.Menu.isReconfigEnable() || !AmsActivity.this.mCurSelectedItem.isFolder() || AmsActivity.this.mCurSelectedItem.mModifiableContent) {
                            AmsActivity.this.refreshList(AmsActivity.this.loadListOrderId(), AmsActivity.this.mCurSelectedItem);
                        } else {
                            FolderNameI18N folderNameI18N = new FolderNameI18N(AmsActivity.this);
                            client.requestLaunchBrowser(folderNameI18N.getFolderUrl());
                        }
                    }
                }
            }
        });
        getListView().setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // from class: com.esmertec.android.jbed.ams.AmsActivity.3
            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onItemSelected(AdapterView<?> adapterView, View layout, int position, long id) {
                for (int i = 0; i < AmsActivity.this.getListView().getAdapter().getCount(); i++) {
                    if (AmsActivity.this.getListView().getAdapter().getItem(i) == AmsActivity.this.mCurSelectedItem) {
                        if (AmsActivity.this.getListView().getChildAt(i) == null) {
                            break;
                        }
                        TextView lastTextView = (TextView) AmsActivity.this.getListView().getChildAt(i).findViewById(R.id.list_item_text);
                        lastTextView.setEllipsize(TextUtils.TruncateAt.END);
                        break;
                    }
                }
                AmsActivity.this.mCurSelectedItem = (JbedSelectorData) AmsActivity.this.getListView().getItemAtPosition(position);
                if (layout == null || layout.findViewById(R.id.list_item_text) == null) {
                    LogTag.amsDebug(AmsActivity.TAG, "onItemSelected curTextView is not set");
                } else {
                    TextView curTextView = (TextView) layout.findViewById(R.id.list_item_text);
                    curTextView.setEllipsize(TextUtils.TruncateAt.MARQUEE);
                }
                LogTag.amsDebug(AmsActivity.TAG, "onItemSelected selected " + AmsActivity.this.mCurSelectedItem);
            }

            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onNothingSelected(AdapterView<?> adapterView) {
                LogTag.amsDebug(AmsActivity.TAG, "onNothingSelected have nothing to selected!! ");
            }
        });
        getListView().setOnCreateContextMenuListener(new View.OnCreateContextMenuListener() { // from class: com.esmertec.android.jbed.ams.AmsActivity.4
            @Override // android.view.View.OnCreateContextMenuListener
            public void onCreateContextMenu(ContextMenu menu, View v, ContextMenu.ContextMenuInfo menuInfo) {
                AmsActivity.this.getMenuInflater().inflate(R.menu.ams_menu, menu);
                AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo) menuInfo;
                AmsActivity.this.mCurSelectedItem = (JbedSelectorData) AmsActivity.this.getListView().getItemAtPosition(info.position);
                AmsActivity.this.getListView().setSelection(info.position);
                MenuStateSetter.reset(menu);
                menu.setGroupVisible(R.id.screen_menu, false);
                menu.setGroupVisible(R.id.screen_no_empty_menu, false);
                MenuStateSetter.setState(AmsActivity.this.getAmsClient(), menu, AmsActivity.this.mCurFolder, AmsActivity.this.mCurSelectedItem, true);
            }
        });
        getListView().setOnKeyListener(new View.OnKeyListener() { // from class: com.esmertec.android.jbed.ams.AmsActivity.5
            @Override // android.view.View.OnKeyListener
            public boolean onKey(View v, int keyCode, KeyEvent event) {
                if (JbedConfig.Menu.isReconfigForAdamEnable() && AmsActivity.this.isInRoot() && event.getAction() == 0 && (keyCode == 27 || keyCode == 66)) {
                    AmsActivity.this.mInputDevKeys.append("123");
                    AmsActivity.this.openOptionsMenu();
                } else if (JbedConfig.Menu.isReconfigEnable() && AmsActivity.this.isInRoot() && event.getAction() == 0) {
                    switch (keyCode) {
                        case 7:
                        case 8:
                        case 9:
                        case 10:
                        case 11:
                        case 12:
                        case 13:
                        case 14:
                        case 15:
                        case 16:
                            AmsActivity.this.mInputDevKeys.append(keyCode - 7);
                            break;
                    }
                    if (AmsActivity.this.mInputDevKeys.toString().equals("123")) {
                        AmsActivity.this.openOptionsMenu();
                        return true;
                    }
                }
                return false;
            }
        });
        this.mPendingQueue.add(Message.obtain(this.mHandler, new Runnable() { // from class: com.esmertec.android.jbed.ams.AmsActivity.6
            @Override // java.lang.Runnable
            public void run() {
                AmsActivity.this.processIntent();
            }
        }));
        registerReceiver(this.mRefreshReceiver, new IntentFilter("android.intent.action.SYNC"));
        Message msg = this.mHandler.obtainMessage(10012);
        this.mHandler.sendMessage(msg);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public JbedApp getApp() {
        return (JbedApp) getApplication();
    }

    private void connect() {
        getApp().startService(this, this.mHandler, 1L);
        getApp().notifyAmsForeground();
    }

    /* JADX INFO: Access modifiers changed from: private */
    /* JADX WARN: Type inference failed for: r0v0, types: [com.esmertec.android.jbed.ams.AmsActivity$7] */
    public void onServiceConnected() {
        new Thread() { // from class: com.esmertec.android.jbed.ams.AmsActivity.7
            @Override // java.lang.Thread, java.lang.Runnable
            public void run() {
                PixelFormat pixFormat = new PixelFormat();
                PixelFormat.getPixelFormatInfo(4, pixFormat);
                try {
                    AmsActivity.this.getApp().mJbedService.startVm(AmsActivity.this.getWindowManager().getDefaultDisplay().getWidth(), AmsActivity.this.getWindowManager().getDefaultDisplay().getHeight(), pixFormat.bytesPerPixel, AmsActivity.this.getWindowManager().getDefaultDisplay().getWidth(), AmsActivity.this.getWindowManager().getDefaultDisplay().getHeight(), false, false);
                    AmsActivity.this.mIsServiceConnected = true;
                    AmsActivity.this.mHandler.obtainMessage(10002).sendToTarget();
                    AmsActivity.this.mHandler.obtainMessage(10013).sendToTarget();
                    for (Message message : AmsActivity.this.mPendingQueue) {
                        message.sendToTarget();
                    }
                    AmsActivity.this.mPendingQueue.clear();
                } catch (RemoteException e) {
                    throw new RuntimeException("failed to call mJbedService.startVm()");
                }
            }
        }.start();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void disconnect() {
        this.mIsServiceConnected = false;
        getApp().stopService(this.mHandler);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public AmsClient getAmsClient() {
        return getApp().getAmsClient(this.mHandler);
    }

    @Override // android.app.ListActivity, android.app.Activity
    protected void onDestroy() {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onDestroy");
        hasInitAmsClient = false;
        unregisterReceiver(this.mRefreshReceiver);
        super.onDestroy();
    }

    @Override // android.app.Activity
    protected void onStart() {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onStart");
        super.onStart();
    }

    @Override // android.app.Activity
    protected void onStop() {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onStop");
        super.onStop();
    }

    @Override // android.app.Activity
    protected void onResume() {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onResume");
        connect();
        super.onResume();
    }

    @Override // android.app.Activity
    protected void onPause() {
        LogTag.appDebug(TAG, "LIFECYCLE Ams onPause");
        disconnect();
        super.onPause();
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        LogTag.appDebug(TAG, "Ams onCreateOptionsMenu");
        getMenuInflater().inflate(R.menu.ams_menu, menu);
        return true;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public boolean isInRoot() {
        return this.mCurFolder == null || this.mCurFolder.mParent == null;
    }

    @Override // android.app.Activity
    public boolean onPrepareOptionsMenu(Menu menu) {
        super.onPrepareOptionsMenu(menu);
        this.mOptionMenu = menu;
        boolean isEmpty = getListView().getAdapter() == null || getListView().getAdapter().getCount() == 0;
        boolean isItemAvailable = (isEmpty || getListView().getSelectedItemPosition() == -1) ? false : true;
        MenuStateSetter.reset(menu);
        menu.setGroupEnabled(R.id.screen_menu, this.mIsServiceConnected);
        menu.setGroupEnabled(R.id.screen_no_empty_menu, (!isEmpty) & this.mIsServiceConnected);
        if (JbedFileManager.isExternalStorageReady()) {
            menu.findItem(R.id.local_install_menu_item).setEnabled(true);
        } else {
            menu.findItem(R.id.local_install_menu_item).setEnabled(false);
        }
        if (JbedConfig.Menu.isReconfigEnable() && !this.mInputDevKeys.toString().equals("123")) {
            menu.findItem(R.id.local_install_menu_item).setEnabled(false);
            menu.findItem(R.id.local_install_menu_item).setVisible(false);
        }
        menu.setGroupEnabled(R.id.item_menu, this.mIsServiceConnected & isItemAvailable);
        MenuStateSetter.setState(getAmsClient(), menu, this.mCurFolder, this.mCurSelectedItem, false);
        MenuItem itemRotate = menu.findItem(R.id.rotate_menu_item);
        itemRotate.setVisible(itemRotate.isVisible() && JbedConfig.Menu.isRotationEnabled());
        this.mInputDevKeys.delete(0, this.mInputDevKeys.length());
        return true;
    }

    /* JADX WARN: Type inference failed for: r6v59, types: [com.esmertec.android.jbed.ams.AmsActivity$8] */
    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem item) {
        boolean isHandled = true;
        if (mJbedExiting) {
            return true;
        }
        switch (item.getItemId()) {
            case R.id.up_folder_item /* 2131230773 */:
                refreshList(loadListOrderId(), this.mCurFolder.mParent);
                break;
            case R.id.local_install_menu_item /* 2131230774 */:
                getAmsClient().requestListLocalInstall(false);
                break;
            case R.id.install_menu_item /* 2131230775 */:
                getAmsClient().requestLaunchBrowser(null);
                break;
            case R.id.tasks_menu_item /* 2131230776 */:
                getAmsClient().requestStartRunningMidletManager();
                break;
            case R.id.remove_multiple_menu_item /* 2131230777 */:
                if (this.isContextItemSelected) {
                    getAmsClient().requestRemoveMultipleConfirmEvent(this.mCurSelectedItem, this.isContextItemSelected);
                } else {
                    getAmsClient().requestRemoveMultipleConfirmEvent(this.mCurFolder, this.isContextItemSelected);
                }
                this.isContextItemSelected = false;
                break;
            case R.id.create_folder_item /* 2131230778 */:
                getAmsClient().requestInputFolderName(this.mCurFolder);
                break;
            case R.id.list_certificates_item /* 2131230779 */:
                getAmsClient().requestListCertificatesEvent();
                break;
            case R.id.apn_menu_item /* 2131230780 */:
                Intent apnIntent = new Intent();
                apnIntent.setClassName("com.android.settings", "com.android.settings.ApnSettings");
                startActivity(apnIntent);
                break;
            case R.id.rotate_menu_item /* 2131230781 */:
                rotateScreen();
                break;
            case R.id.storage_setting_item /* 2131230782 */:
                getAmsClient().requestStorageSetting(getPreferences(0).getInt(CURRENT_STORAGE_NAME, 0));
                break;
            case R.id.about_menu_item /* 2131230783 */:
                getAmsClient().requestShowAboutEvent();
                break;
            case R.id.exit_menu_item /* 2131230784 */:
                new Thread() { // from class: com.esmertec.android.jbed.ams.AmsActivity.8
                    @Override // java.lang.Thread, java.lang.Runnable
                    public void run() {
                        boolean unused = AmsActivity.mJbedExiting = true;
                        if (AmsActivity.this.getApp().mJbedService != null) {
                            try {
                                AmsActivity.this.getApp().mJbedService.shutdownVm();
                                AmsActivity.this.getApp().onTerminate();
                            } catch (RemoteException e) {
                                throw new RuntimeException("failed to call mJbedService.shutdownVm");
                            }
                        }
                        AmsActivity.this.finish();
                        boolean unused2 = AmsActivity.mJbedExiting = false;
                    }
                }.start();
                break;
            case R.id.screen_no_empty_menu /* 2131230785 */:
            case R.id.sort_menu_item /* 2131230787 */:
            case R.id.sort_by_reverse_name_menu_item /* 2131230789 */:
            case R.id.item_menu /* 2131230792 */:
            default:
                isHandled = false;
                break;
            case R.id.remove_all_menu_item /* 2131230786 */:
                getAmsClient().requestRemoveAllConfirmEvent();
                break;
            case R.id.sort_by_name_menu_item /* 2131230788 */:
            case R.id.sort_by_size_menu_item /* 2131230790 */:
            case R.id.sort_by_time_menu_item /* 2131230791 */:
                refreshList(item.getItemId(), this.mCurFolder);
                break;
            case R.id.rename_item /* 2131230793 */:
                getAmsClient().requsetInputName(this.mCurSelectedItem);
                break;
            case R.id.move_to_folder_item /* 2131230794 */:
                if (this.isContextItemSelected) {
                    getAmsClient().requestMoveMultipleSelectEvent(this.mCurSelectedItem, this.isContextItemSelected);
                } else {
                    getAmsClient().requestMoveMultipleSelectEvent(this.mCurFolder, this.isContextItemSelected);
                }
                this.isContextItemSelected = false;
                break;
            case R.id.run_menu_item /* 2131230795 */:
                if (hasEnoughFreeMemory()) {
                    getAmsClient().requestRunEvent(this.mCurSelectedItem.mRoot, this.mCurSelectedItem.mNo);
                } else {
                    showWarningDialog(getString(R.string.AMS_WARNING), getString(R.string.AMS_NO_ENOUGH_MEMORY));
                }
                break;
            case R.id.remove_menu_item /* 2131230796 */:
                if (this.mCurSelectedItem.isFolder()) {
                    getAmsClient().requestRemoveFolderConfirmEvent(this.mCurSelectedItem);
                } else {
                    getAmsClient().requestRemoveConfirmEvent(this.mCurSelectedItem);
                }
                break;
            case R.id.info_menu_item /* 2131230797 */:
                getAmsClient().requestInfoEvent(this.mCurSelectedItem.mRoot);
                break;
            case R.id.permission_menu_item /* 2131230798 */:
                getAmsClient().requestPermission(this.mCurSelectedItem.mRoot);
                break;
            case R.id.update_menu_item /* 2131230799 */:
                getAmsClient().requestUpdateEvent(this.mCurSelectedItem.mRoot);
                break;
            case R.id.send_info_menu_item /* 2131230800 */:
                if (this.mCurSelectedItem != null && (this.mCurSelectedItem.isSuite() || this.mCurSelectedItem.isMidlet())) {
                    String msg = ((("Name : " + this.mCurSelectedItem.getNameText() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER) + "Vendor : " + this.mCurSelectedItem.getVendorText() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER) + "Version : " + this.mCurSelectedItem.getVersionText() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER) + "Size : " + this.mCurSelectedItem.getSizeText(null) + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    String s = this.mCurSelectedItem.getDescription();
                    if (s != null) {
                        msg = msg + "Description : " + s + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    }
                    String s2 = this.mCurSelectedItem.getInfoUrl();
                    if (s2 != null) {
                        msg = msg + "Info URL : " + s2 + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    }
                    if (this.mCurSelectedItem.isSuite()) {
                        for (int i = 0; i < this.mCurSelectedItem.getChildCount(); i++) {
                            msg = msg + "MIDlet-" + (i + 1) + " : " + this.mCurSelectedItem.getChildren(i).getNameText() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                        }
                    }
                    Intent smsIntent = new Intent();
                    smsIntent.setClassName(TransactionService.APP_PACKAGE_NAME, "com.android.mms.ui.ComposeMessageActivity");
                    smsIntent.putExtra("exit_on_sent", true);
                    smsIntent.putExtra("forwarded_message", true);
                    smsIntent.putExtra("sms_body", msg);
                    startActivity(smsIntent);
                }
                break;
        }
        return isHandled;
    }

    private void rotateScreen() {
        switch (getResources().getConfiguration().orientation) {
            case 1:
                setRequestedOrientation(0);
                break;
            case 2:
                setRequestedOrientation(1);
                break;
            default:
                LogTag.amsDebug(TAG, "rotateScreen() get a un-recognize orientation");
                break;
        }
    }

    /* JADX WARN: Can't fix incorrect switch cases order, some code will duplicate */
    @Override // android.app.Activity
    protected Dialog onCreateDialog(int id) {
        ProgressDialog dialog = new ProgressDialog(this);
        switch (id) {
            case 0:
                dialog.setMax(100);
                dialog.setProgressStyle(1);
                dialog.setMessage(getString(R.string.AMS_WAIT));
                dialog.setCancelable(true);
                dialog.setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.AmsActivity.9
                    @Override // android.content.DialogInterface.OnCancelListener
                    public void onCancel(DialogInterface dialog2) {
                        AmsActivity.this.getAmsClient().requestInstallCancelEvent();
                    }
                });
                this.mInstallDialog = dialog;
                return dialog;
            case 1:
                dialog.setIndeterminate(true);
                dialog.setMessage(getString(R.string.AMS_WAIT));
                dialog.setCancelable(false);
                return dialog;
            default:
                return dialog;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public int loadListOrderId() {
        return getPreferences(0).getInt(LIST_ORDER_NAME, R.id.sort_by_name_menu_item);
    }

    private void storeListOrderId(int orderId) {
        SharedPreferences.Editor editor = getPreferences(0).edit();
        editor.putInt(LIST_ORDER_NAME, orderId);
        editor.commit();
    }

    /* JADX WARN: Type inference failed for: r0v6, types: [com.esmertec.android.jbed.ams.AmsActivity$10] */
    @Override // android.app.Activity, android.view.KeyEvent.Callback
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == 4) {
            if (!isInRoot()) {
                refreshList(loadListOrderId(), this.mCurFolder.mParent);
                return true;
            }
            if (getAmsClient().getRunningMidletList().isEmpty()) {
                new Thread() { // from class: com.esmertec.android.jbed.ams.AmsActivity.10
                    @Override // java.lang.Thread, java.lang.Runnable
                    public void run() {
                        boolean unused = AmsActivity.mJbedExiting = true;
                        if (AmsActivity.this.getApp().mJbedService != null) {
                            try {
                                AmsActivity.this.getApp().mJbedService.shutdownVm();
                                AmsActivity.this.getApp().onTerminate();
                            } catch (RemoteException e) {
                                throw new RuntimeException("failed to call mJbedService.shutdownVm");
                            }
                        }
                        AmsActivity.this.finish();
                        boolean unused2 = AmsActivity.mJbedExiting = false;
                    }
                }.start();
            }
        }
        return super.onKeyDown(keyCode, event);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void refreshList(int listOrderId, JbedSelectorData folder) {
        if (getAmsClient() != null) {
            this.mCurFolder = folder;
            List<JbedSelectorData> mildets = getAmsClient().getMergedChildren(folder);
            for (JbedSelectorData data : mildets) {
                if (this.mIsServiceConnected && data.isDrmProtected()) {
                    data.mIsExpired = getAmsClient().checkExpiredMidlet(data.mRoot);
                }
                data.clearState();
            }
            if (folder != null) {
                LogTag.amsDebug(TAG, "folderName=" + folder.mName + " midlets.size = " + mildets.size());
            }
            if (JbedConfig.Menu.isReconfigEnable()) {
                if (isInRoot()) {
                    Integer resourceId = Integer.valueOf(I18N.getStringID(4, AMS_MAIN_SCREEN_TITLE));
                    setTitle(getListView().getContext().getResources().getString(resourceId.intValue()));
                } else {
                    setTitle(folder.mName);
                }
            }
            Comparator<JbedSelectorData> comparator = sListOrderMap.get(Integer.valueOf(listOrderId));
            if (comparator == null) {
                listOrderId = R.id.sort_by_name_menu_item;
                comparator = JbedSelectorData.NAME_ORDER;
            }
            if (JbedConfig.Menu.isReconfigEnable() && isInRoot()) {
                comparator = JbedSelectorData.NAME_REVERSE_ORDER;
            }
            Collections.sort(mildets, comparator);
            storeListOrderId(listOrderId);
            List<JbedSelectorData> runningMidlets = getAmsClient().getRunningMidletList();
            for (JbedSelectorData runningMidlet : runningMidlets) {
                getAmsClient().findMidlet(runningMidlet.mRoot, runningMidlet.mNo).mIsRunning = true;
                getAmsClient().findMidlet(runningMidlet.mRoot, runningMidlet.mNo).mIsPaused = runningMidlet.mIsPaused;
            }
            FolderNameI18N folderNameI18N = new FolderNameI18N(this);
            for (JbedSelectorData mildet : mildets) {
                if (mildet.mName.equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_GAMES) && (folderNameI18N.getI18NStrings(1) == null || folderNameI18N.getI18NStrings(1).length() == 0)) {
                    mildets.remove(mildet);
                    break;
                } else if (mildet.mName.equals(FolderNameI18N.FOLDER_NAME_DOWNLOAD_APPLICATIONS) && (folderNameI18N.getI18NStrings(2) == null || folderNameI18N.getI18NStrings(2).length() == 0)) {
                    mildets.remove(mildet);
                    break;
                }
            }
            this.mListAdapter.mList = mildets;
            this.mListAdapter.notifyDataSetChanged();
            onWindowFocusChanged(true);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void processIntent() {
        String uriJad;
        Intent intent = getIntent();
        String action = intent.getAction();
        Bundle bundle = intent.getExtras();
        if (bundle == null) {
            uriJad = null;
        } else {
            String chapi_URL = bundle.getString("chapiURL");
            String chapi_contentType = bundle.getString("contentType");
            String chapi_action = bundle.getString("action");
            String chapi_appName = bundle.getString("appName");
            if (chapi_URL != null && chapi_contentType != null && chapi_action != null && chapi_appName != null) {
                LogTag.amsDebug(TAG, "onCreate() chapiURL = " + chapi_URL);
                LogTag.amsDebug(TAG, "onCreate() contentType = " + chapi_contentType);
                LogTag.amsDebug(TAG, "onCreate() action = " + chapi_action);
                LogTag.amsDebug(TAG, "onCreate() appName = " + chapi_appName);
                getAmsClient().requestChapiEvent(chapi_URL, chapi_contentType, chapi_action, chapi_appName);
                return;
            }
            uriJad = bundle.getString("uri");
        }
        LogTag.amsDebug(TAG, "processIntent() uriJad = " + uriJad);
        if (action != null && action.equals("android.intent.action.VIEW")) {
            if (uriJad == null) {
                AmsInstallerProxy installer = new AmsInstallerProxy(this, getAmsClient(), intent.getData(), intent.getType());
                installer.requestInstall();
            } else {
                AmsInstallerProxy installer2 = new AmsInstallerProxy(this, getAmsClient(), intent.getData(), intent.getType(), Uri.parse(uriJad));
                installer2.requestInstall();
            }
        }
    }

    class AmsHandler extends Handler {
        AmsHandler() {
        }

        @Override // android.os.Handler
        public void handleMessage(Message msg) {
            int index;
            LogTag.amsDebug(AmsActivity.TAG, "AmsHandler.handleMessage() msg=" + msg.what);
            switch (msg.what) {
                case 10000:
                    Intent jbedIntent = new Intent(AmsActivity.this, (Class<?>) JbedAppActivity.class);
                    jbedIntent.setFlags(67108864);
                    boolean isFullString = ((Boolean) msg.obj).booleanValue();
                    jbedIntent.putExtra(AmsConstants.FULL_SCREEN_FLAG, isFullString);
                    AmsActivity.this.startActivity(jbedIntent);
                    break;
                case 10001:
                    AmsActivity.this.disconnect();
                    AmsActivity.this.finish();
                    break;
                case 10002:
                    if (AmsActivity.this.mIsServiceConnected && AmsActivity.this.getAmsClient() != null) {
                        AmsActivity.this.getAmsClient().refreshSelector();
                        JbedSelectorData curFolder = AmsActivity.this.mCurFolder == null ? null : AmsActivity.this.getAmsClient().getMildetByHierarchyNames(AmsActivity.this.mCurFolder.getHierarchyNames());
                        AmsActivity.this.refreshList(AmsActivity.this.loadListOrderId(), curFolder);
                    } else {
                        LogTag.amsDebug(AmsActivity.TAG, "handleMessage HANDLE_REFRESH_LIST but have no connection!!");
                    }
                    break;
                case 10003:
                    AmsActivity.this.showDialog(0);
                    if (AmsActivity.this.mInstallDialog != null && msg.obj != null && ((Boolean) msg.obj).booleanValue()) {
                        AmsActivity.this.mInstallDialog.setCancelable(false);
                    }
                    break;
                case 10004:
                    if (AmsActivity.this.mInstallDialog != null) {
                        AmsActivity.this.mInstallDialog.setProgress(msg.arg1);
                    }
                    break;
                case 10005:
                    AmsActivity.this.removeDialog(0);
                    break;
                case 10006:
                    if (AmsActivity.this.mInstallDialog != null) {
                        AmsActivity.this.mInstallDialog.setCancelable(false);
                    }
                    break;
                case 10007:
                    if (AmsActivity.this.mInstallDialog != null) {
                        AmsActivity.this.mInstallDialog.setCancelable(false);
                        AmsActivity.this.mInstallDialog.setMessage(AmsActivity.this.getText(R.string.AMS_INSTALLATION_CANCELLING));
                    }
                    break;
                case 10009:
                    if (AmsActivity.this.mInstallDialog != null && msg.obj != null) {
                        AmsActivity.this.mInstallDialog.setMessage(((String) msg.obj) + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + AmsActivity.this.getString(R.string.PRJ_INSTALL_CANCEL));
                    }
                    break;
                case 10010:
                case 10012:
                    AmsActivity.this.showDialog(1);
                    break;
                case 10011:
                case 10013:
                    AmsActivity.this.removeDialog(1);
                    break;
                case 10015:
                    if (msg.arg1 == 17 && (index = AmsActivity.this.mListAdapter.mList.indexOf(new JbedSelectorData((String) msg.obj, msg.arg2))) >= 0) {
                        AmsActivity.this.mListAdapter.mList.get(index).mIsPaused = true;
                        AmsActivity.this.mListAdapter.notifyDataSetChanged();
                    }
                    break;
                case 10017:
                    JbedSelectorData suite = (JbedSelectorData) msg.obj;
                    AmsActivity.this.refreshList(AmsActivity.this.loadListOrderId(), suite);
                    break;
                case AmsConstants.HANDLE_SHOW_CREATE_FOLDER_DIALOG /* 10018 */:
                    AmsActivity.this.getAmsClient().requestInputFolderName(AmsActivity.this.mCurFolder);
                    break;
                case AmsConstants.HANDLE_SHOW_RENAME_FOLDER_DIALOG /* 10019 */:
                    AmsActivity.this.getAmsClient().requsetInputName(AmsActivity.this.mCurSelectedItem);
                    break;
                case AmsConstants.HANDLE_MIDLET_STARTUP_ERROR /* 10020 */:
                    AmsActivity.this.getAmsClient().requestHandleMideltStartupError(AmsActivity.this.mCurSelectedItem.mRoot, (String) msg.obj);
                    break;
                case AmsConstants.HANDLE_STORAGE_SETTING /* 10021 */:
                    SharedPreferences.Editor editor = AmsActivity.this.getPreferences(0).edit();
                    editor.putInt(AmsActivity.CURRENT_STORAGE_NAME, msg.arg1);
                    editor.commit();
                    break;
                case AmsConstants.HANDLE_GET_INSTALLED_STORAGE /* 10022 */:
                    int storage = AmsActivity.this.getPreferences(0).getInt(AmsActivity.CURRENT_STORAGE_NAME, 0);
                    AmsActivity.this.getAmsClient().requestHandleSelectStorage(storage == 0);
                    break;
                case AmsConstants.HANDLE_SDCARD_EVENT /* 10025 */:
                    if (Integer.parseInt(msg.obj.toString()) == 1) {
                        if (AmsActivity.this.mOptionMenu != null) {
                            AmsActivity.this.mOptionMenu.findItem(R.id.local_install_menu_item).setEnabled(true);
                        }
                    } else if (AmsActivity.this.mOptionMenu != null) {
                        AmsActivity.this.mOptionMenu.findItem(R.id.local_install_menu_item).setEnabled(false);
                    }
                    break;
                case JbedApp.EVENT_SERVICE_CONNECTED /* 99001 */:
                    AmsActivity.this.onServiceConnected();
                    break;
                case JbedApp.EVENT_SERVICE_DISCONNECTED /* 99002 */:
                    LogTag.amsDebug(AmsActivity.TAG, "WARNING: receive EVENT_SERVICE_DISCONNECTED event");
                    break;
            }
            super.handleMessage(msg);
        }
    }

    public static boolean hasEnoughFreeMemory() {
        StatFs fileStats = new StatFs("/data");
        long blkSize = fileStats.getBlockSize();
        long availBlkNum = fileStats.getAvailableBlocks();
        long freeMem = availBlkNum * blkSize;
        return freeMem >= 10240000;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void showWarningDialog(String title, String msg) {
        new AlertDialog.Builder(this).setTitle(title).setMessage(msg).setPositiveButton(android.R.string.yes, (DialogInterface.OnClickListener) null).show();
    }

    private static class MenuStateSetter {
        private static final int ALL = 1552;
        private static final int DISABLE_IF_IS_RUNNING = 32768;
        private static final int DISABLE_IF_NONE_SUITES = 1048576;
        private static final int ENABLE_ALL = 16;
        private static final int ENABLE_FOLDER = 4;
        private static final int ENABLE_MIDLET = 2;
        private static final int ENABLE_REMOVABLE_ONLY = 32;
        private static final int ENABLE_SUITE = 8;
        private static final int INVISIBLE_IF_CANT_REMOVE_ON_CONTEXTMENU = 4096;
        private static final int INVISIBLE_IF_IS_MIDLET_IN_SUITE = 16384;
        private static final int INVISIBLE_IF_IS_RUNNING_ON_CONTEXTMENU = 8192;
        private static final int TOP_ALL = 528;
        private static final int VISIBLE_ALL_LEVEL = 1536;
        private static final int VISIBLE_SUB_LEVEL_ONLY = 1024;
        private static final int VISIBLE_SUB_LEVEL_ON_CONTEXTMENU_ONLY = 2048;
        private static final int VISIBLE_TOP_LEVEL_ONLY = 512;
        private static Map<Integer, Integer> menuItemFlagMap = new HashMap();

        private MenuStateSetter() {
        }

        static {
            menuItemFlagMap.put(Integer.valueOf(R.id.up_folder_item), 1040);
            menuItemFlagMap.put(Integer.valueOf(R.id.rename_item), 1580);
            menuItemFlagMap.put(Integer.valueOf(R.id.remove_menu_item), 1580);
            menuItemFlagMap.put(Integer.valueOf(R.id.local_install_menu_item), Integer.valueOf(ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.install_menu_item), Integer.valueOf(ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.create_folder_item), Integer.valueOf(TOP_ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.rotate_menu_item), Integer.valueOf(TOP_ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.apn_menu_item), Integer.valueOf(TOP_ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.about_menu_item), Integer.valueOf(TOP_ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.remove_all_menu_item), 1049104);
            if (JbedConfig.Menu.isReconfigEnable()) {
                menuItemFlagMap.put(Integer.valueOf(R.id.move_to_folder_item), 1078288);
                menuItemFlagMap.put(Integer.valueOf(R.id.remove_multiple_menu_item), 1078288);
                menuItemFlagMap.put(Integer.valueOf(R.id.info_menu_item), 18440);
                menuItemFlagMap.put(Integer.valueOf(R.id.update_menu_item), 1032);
                menuItemFlagMap.put(Integer.valueOf(R.id.permission_menu_item), 22536);
                menuItemFlagMap.put(Integer.valueOf(R.id.run_menu_item), 18434);
                menuItemFlagMap.put(Integer.valueOf(R.id.exit_menu_item), 1040);
                menuItemFlagMap.put(Integer.valueOf(R.id.sort_menu_item), 17424);
                menuItemFlagMap.put(Integer.valueOf(R.id.send_info_menu_item), 18448);
                menuItemFlagMap.put(Integer.valueOf(R.id.list_certificates_item), 17936);
                menuItemFlagMap.put(Integer.valueOf(R.id.storage_setting_item), 17936);
                menuItemFlagMap.put(Integer.valueOf(R.id.tasks_menu_item), 17936);
            } else {
            menuItemFlagMap.put(Integer.valueOf(R.id.move_to_folder_item), 1050128);
            menuItemFlagMap.put(Integer.valueOf(R.id.remove_multiple_menu_item), 1050128);
            menuItemFlagMap.put(Integer.valueOf(R.id.info_menu_item), 1544);
            menuItemFlagMap.put(Integer.valueOf(R.id.update_menu_item), 1544);
            menuItemFlagMap.put(Integer.valueOf(R.id.permission_menu_item), 1544);
            menuItemFlagMap.put(Integer.valueOf(R.id.run_menu_item), 34306);
            menuItemFlagMap.put(Integer.valueOf(R.id.exit_menu_item), Integer.valueOf(ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.sort_menu_item), Integer.valueOf(ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.list_certificates_item), Integer.valueOf(TOP_ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.storage_setting_item), Integer.valueOf(ALL));
            menuItemFlagMap.put(Integer.valueOf(R.id.tasks_menu_item), Integer.valueOf(ALL));
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public static void reset(Menu menu) {
            for (Map.Entry<Integer, Integer> menuItemFlag : menuItemFlagMap.entrySet()) {
                MenuItem item = menu.findItem(menuItemFlag.getKey().intValue());
                item.setEnabled(true);
                item.setVisible(true);
            }
        }

        private static boolean isEnabled(AmsClient amsClient, int itemFlag, JbedSelectorData curParent, JbedSelectorData selectedItem) {
            if ((itemFlag & 32) != 0 && (selectedItem == null || !selectedItem.isRemovable())) {
                return false;
            }
            if ((1048576 & itemFlag) != 0 && amsClient.getAllSuites(null, false, false).size() == 0) {
                return false;
            }
            if ((DISABLE_IF_IS_RUNNING & itemFlag) != 0 && selectedItem.mIsRunning) {
                return false;
            }
            if ((itemFlag & 16) != 0) {
                return true;
            }
            if ((itemFlag & 2) != 0 && selectedItem != null && selectedItem.isMidlet()) {
                return true;
            }
            JbedSelectorData data = selectedItem;
            if (data != null && data.isMidlet() && data.mParent.getChildCount() == 1) {
                data = data.mParent;
            }
            if ((itemFlag & 4) == 0 || data == null || !data.isFolder()) {
                return ((itemFlag & 8) == 0 || data == null || !data.isSuite()) ? false : true;
            }
            return true;
        }

        private static boolean isVisibleFromConfig(int itemKey) {
            if (itemKey == R.id.move_to_folder_item && JbedConfig.Menu.isMoveDisabled()) {
                return false;
            }
            if (itemKey == R.id.sort_menu_item && JbedConfig.Menu.isSortDisabled()) {
                return false;
            }
            if (itemKey == R.id.rename_item && JbedConfig.Menu.isRenameDisabled()) {
                return false;
            }
            if (itemKey == R.id.remove_multiple_menu_item && !JbedConfig.Menu.isRemoveMultiEnabled()) {
                return false;
            }
            if (itemKey == R.id.create_folder_item && JbedConfig.Menu.isCreateFolderDisabled()) {
                return false;
            }
            if (itemKey == R.id.storage_setting_item && !JbedConfig.Menu.isStorateSettingEnable()) {
                return false;
            }
            if (itemKey == R.id.install_menu_item && JbedConfig.Menu.isInstallDisabled()) {
                return false;
            }
            if (itemKey == R.id.apn_menu_item && JbedConfig.Menu.isApnDisabled()) {
                return false;
            }
            if (itemKey == R.id.about_menu_item && JbedConfig.Menu.isAboutDisabled()) {
                return false;
            }
            if (itemKey == R.id.remove_menu_item && JbedConfig.Menu.isRemoveDisabled()) {
                return false;
            }
            if (itemKey == R.id.remove_all_menu_item && JbedConfig.Menu.isRemoveAllDisabled()) {
                return false;
            }
            if (itemKey == R.id.up_folder_item && JbedConfig.Menu.isUpFolderDisabled()) {
                return false;
            }
            if (itemKey == R.id.update_menu_item && JbedConfig.Menu.isUpdateDisabled()) {
                return false;
            }
            return (itemKey == R.id.exit_menu_item && JbedConfig.Menu.isExitDisabled()) ? false : true;
        }

        private static boolean isVisibled(int itemKey, int itemFlag, JbedSelectorData curParent, JbedSelectorData selectedItem, boolean isContextMenu) {
            if (!isVisibleFromConfig(itemKey)) {
                return false;
            }
            if ((itemFlag & INVISIBLE_IF_CANT_REMOVE_ON_CONTEXTMENU) != 0 && curParent != null && curParent.mParent != null && !selectedItem.isRemovable() && isContextMenu) {
                return false;
            }
            if ((itemFlag & INVISIBLE_IF_IS_RUNNING_ON_CONTEXTMENU) != 0 && curParent != null && curParent.mParent != null && selectedItem.mIsRunning && isContextMenu) {
                return false;
            }
            if ((itemFlag & INVISIBLE_IF_IS_MIDLET_IN_SUITE) != 0 && curParent != null && curParent.mParent != null && curParent.isSuite() && selectedItem.isMidlet()) {
                return false;
            }
            if ((itemFlag & VISIBLE_TOP_LEVEL_ONLY) != 0 && (curParent == null || curParent.mParent == null)) {
                return true;
            }
            if ((itemFlag & VISIBLE_SUB_LEVEL_ONLY) == 0 || curParent == null || curParent.mParent == null) {
                return ((itemFlag & VISIBLE_SUB_LEVEL_ON_CONTEXTMENU_ONLY) == 0 || curParent == null || curParent.mParent == null || !isContextMenu) ? false : true;
            }
            return true;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public static void setState(AmsClient amsClient, Menu menu, JbedSelectorData curParent, JbedSelectorData selectedItem, boolean isContextMenu) {
            for (Map.Entry<Integer, Integer> menuItemFlag : menuItemFlagMap.entrySet()) {
                MenuItem item = menu.findItem(menuItemFlag.getKey().intValue());
                int itemFlag = menuItemFlag.getValue().intValue();
                item.setEnabled(item.isEnabled() && amsClient != null && isEnabled(amsClient, itemFlag, curParent, selectedItem));
                item.setVisible(item.isVisible() && isVisibled(menuItemFlag.getKey().intValue(), itemFlag, curParent, selectedItem, isContextMenu));
            }
        }
    }
}
