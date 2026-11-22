package com.esmertec.android.jbed.ams;

import android.app.AlertDialog;
import android.app.ListActivity;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.ContextMenu;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import com.esmertec.android.jbed.JbedApp;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.app.JbedAppActivity;
import com.google.android.collect.Lists;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class RunningMidletManagerActivity extends ListActivity implements AmsConstants {
    private static final String TAG = "RunningActivity";
    private LayoutInflater mInflater;
    private int mFocusPosition = -1;
    private boolean isContextItemSelected = false;
    int selectedStopItem = -1;
    int selectedResumeItem = -1;
    private Handler mHandler = new Handler() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.1
        @Override // android.os.Handler
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case 10000:
                    Intent jbedIntent = new Intent(RunningMidletManagerActivity.this, (Class<?>) JbedAppActivity.class);
                    jbedIntent.setFlags(67108864);
                    boolean isFullScreen = ((Boolean) msg.obj).booleanValue();
                    jbedIntent.putExtra(AmsConstants.FULL_SCREEN_FLAG, isFullScreen);
                    RunningMidletManagerActivity.this.startActivity(jbedIntent);
                    RunningMidletManagerActivity.this.finish();
                    break;
                case 10015:
                case JbedApp.EVENT_SERVICE_CONNECTED /* 99001 */:
                    AmsClient amsClient = RunningMidletManagerActivity.this.getAmsClient();
                    if (amsClient != null) {
                        List<JbedSelectorData> runningMidletList = amsClient.getRunningMidletList();
                        if (runningMidletList.size() == 0) {
                            RunningMidletManagerActivity.this.setResult(2);
                        }
                        RunningMidletManagerActivity.this.refreshList(runningMidletList);
                    }
                    break;
                case JbedApp.EVENT_SERVICE_DISCONNECTED /* 99002 */:
                    if (Log.isLoggable(RunningMidletManagerActivity.TAG, 5)) {
                        Log.w(RunningMidletManagerActivity.TAG, "WARNING: receive EVENT_SERVICE_DISCONNECTED event");
                    }
                    break;
                default:
                    if (Log.isLoggable(RunningMidletManagerActivity.TAG, 6)) {
                        Log.e(RunningMidletManagerActivity.TAG, "RunningManagerHandler received un-recognized message ");
                    }
                    break;
            }
        }
    };

    private JbedApp getApp() {
        return (JbedApp) getApplication();
    }

    /* JADX INFO: Access modifiers changed from: private */
    public AmsClient getAmsClient() {
        return getApp().getAmsClient(this.mHandler);
    }

    @Override // android.app.Activity
    protected void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        setContentView(R.layout.task_manager_view);
        this.mInflater = (LayoutInflater) getSystemService("layout_inflater");
        View v = (TextView) this.mInflater.inflate(android.R.layout.simple_gallery_item, (ViewGroup) null);
        addContentView(v, new ViewGroup.LayoutParams(-1, -1));
        TextView emptyText = (TextView) v.findViewById(android.R.id.text1);
        emptyText.setText(R.string.PRJ_EMPTY_AMS_LIST);
        emptyText.setGravity(49);
        getListView().setEmptyView(emptyText);
        getListView().setOnItemClickListener(new AdapterView.OnItemClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.2
            @Override // android.widget.AdapterView.OnItemClickListener
            public void onItemClick(AdapterView parent, View v2, int position, long id) {
                JbedSelectorData midlet = (JbedSelectorData) parent.getAdapter().getItem(position);
                RunningMidletManagerActivity.this.getAmsClient().requestRunEvent(midlet.mRoot, midlet.mNo);
            }
        });
        getListView().setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.3
            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onItemSelected(AdapterView<?> arg0, View arg1, int position, long id) {
                RunningMidletManagerActivity.this.mFocusPosition = RunningMidletManagerActivity.this.getListView().getSelectedItemPosition();
            }

            @Override // android.widget.AdapterView.OnItemSelectedListener
            public void onNothingSelected(AdapterView<?> arg0) {
                LogTag.amsDebug(RunningMidletManagerActivity.TAG, "onNothingSelected have nothing to selected!! ");
                RunningMidletManagerActivity.this.mFocusPosition = -1;
            }
        });
        if (JbedConfig.Menu.isReconfigEnable()) {
            getListView().setOnCreateContextMenuListener(new View.OnCreateContextMenuListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.4
                @Override // android.view.View.OnCreateContextMenuListener
                public void onCreateContextMenu(ContextMenu menu, View v2, ContextMenu.ContextMenuInfo menuInfo) {
                    RunningMidletManagerActivity.this.getMenuInflater().inflate(R.menu.running_midlet_manager_menu, menu);
                    AdapterView.AdapterContextMenuInfo info = (AdapterView.AdapterContextMenuInfo) menuInfo;
                    RunningMidletManagerActivity.this.mFocusPosition = info.position;
                    menu.setGroupVisible(R.id.screen_menu, false);
                }
            });
        }
    }

    @Override // android.app.ListActivity, android.app.Activity
    protected void onDestroy() {
        super.onDestroy();
        LogTag.appDebug(TAG, "LIFECYCLE Task Manager onDestroy");
    }

    @Override // android.app.Activity
    protected void onStop() {
        LogTag.appDebug(TAG, "LIFECYCLE Task Manager onStop");
        super.onStop();
    }

    @Override // android.app.Activity
    protected void onResume() {
        LogTag.appDebug(TAG, "LIFECYCLE Task Manager onResume");
        getApp().startService(this, this.mHandler, 2L);
        super.onResume();
    }

    @Override // android.app.Activity
    protected void onPause() {
        LogTag.appDebug(TAG, "LIFECYCLE Task Manager onPause");
        getApp().stopService(this.mHandler);
        super.onPause();
    }

    @Override // android.app.Activity
    public boolean onContextItemSelected(MenuItem item) {
        this.isContextItemSelected = true;
        onOptionsItemSelected(item);
        return super.onContextItemSelected(item);
    }

    @Override // android.app.Activity
    public boolean onCreateOptionsMenu(Menu menu) {
        LogTag.appDebug(TAG, "Ams onCreateOptionsMenu");
        getMenuInflater().inflate(R.menu.running_midlet_manager_menu, menu);
        if (JbedConfig.Menu.isReconfigEnable()) {
            menu.findItem(R.id.bring_midlet_foreground_item).setIcon((Drawable) null);
            menu.findItem(R.id.stop_midlet_item).setIcon((Drawable) null);
            menu.findItem(R.id.back_to_ams_item).setIcon((Drawable) null);
            return true;
        }
        return true;
    }

    @Override // android.app.Activity
    public boolean onPrepareOptionsMenu(Menu menu) {
        super.onPrepareOptionsMenu(menu);
        menu.setGroupEnabled(R.id.screen_menu, true);
        boolean isItemAvailable = this.mFocusPosition != -1;
        menu.setGroupEnabled(R.id.item_menu, isItemAvailable);
        return true;
    }

    @Override // android.app.Activity
    public boolean onOptionsItemSelected(MenuItem item) {
        boolean isHandled = true;
        JbedSelectorData midlet = null;
        if (-1 != this.mFocusPosition) {
            midlet = (JbedSelectorData) getListView().getAdapter().getItem(this.mFocusPosition);
        }
        switch (item.getItemId()) {
            case R.id.bring_midlet_foreground_item /* 2131230801 */:
                if (JbedConfig.Menu.isReconfigEnable()) {
                    if (this.isContextItemSelected) {
                        getListView().performItemClick(getListView(), this.mFocusPosition, 0L);
                        this.isContextItemSelected = false;
                    } else {
                        List<String> runningMidletNameList = Lists.newArrayList();
                        List<JbedSelectorData> runningMidletList = getAmsClient().getRunningMidletList();
                        for (JbedSelectorData runningMidlet : runningMidletList) {
                            JbedSelectorData resumeMidlet = getAmsClient().findMidlet(runningMidlet.mRoot, runningMidlet.mNo);
                            runningMidletNameList.add(resumeMidlet.mName);
                        }
                        final JbedSelectorData.SelectorCharSequence[] suites = getAmsClient().getSelector().toMidletCharSequences(runningMidletList);
                        this.selectedResumeItem = -1;
                        new AlertDialog.Builder(this).setTitle(R.string.PRJ_RESUME_ONE_MIDLET).setSingleChoiceItems(suites, -1, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.7
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int which) {
                                RunningMidletManagerActivity.this.selectedResumeItem = which;
                            }
                        }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.6
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int whichButton) {
                                if (RunningMidletManagerActivity.this.selectedResumeItem != -1) {
                                    RunningMidletManagerActivity.this.getAmsClient().requestRunEvent(suites[RunningMidletManagerActivity.this.selectedResumeItem].mData.mRoot, suites[RunningMidletManagerActivity.this.selectedResumeItem].mData.mNo);
                                }
                            }
                        }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.5
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).show();
                        return true;
                    }
                } else {
                    getListView().performItemClick(getListView(), this.mFocusPosition, 0L);
                }
                break;
            case R.id.stop_midlet_item /* 2131230802 */:
                if (JbedConfig.Menu.isReconfigEnable()) {
                    if (this.isContextItemSelected) {
                        showStopConfirmDialog(getAmsClient().findMidlet(midlet.mRoot, midlet.mNo));
                        this.isContextItemSelected = false;
                    } else {
                        final JbedSelectorData.SelectorCharSequence[] suites2 = getAmsClient().getSelector().toMidletCharSequences(getAmsClient().getRunningMidletList());
                        this.selectedStopItem = -1;
                        new AlertDialog.Builder(this).setTitle(R.string.AMS_STOP_COMMAND).setSingleChoiceItems(suites2, -1, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.10
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int which) {
                                RunningMidletManagerActivity.this.selectedStopItem = which;
                            }
                        }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.9
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int whichButton) {
                                if (RunningMidletManagerActivity.this.selectedStopItem != -1) {
                                    RunningMidletManagerActivity.this.showStopConfirmDialog(RunningMidletManagerActivity.this.getAmsClient().findMidlet(suites2[RunningMidletManagerActivity.this.selectedStopItem].mData.mRoot, suites2[RunningMidletManagerActivity.this.selectedStopItem].mData.mNo));
                                }
                            }
                        }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.8
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        }).show();
                        return true;
                    }
                } else {
                    getAmsClient().requestDestroyEvent(midlet.mRoot, midlet.mNo);
                }
                break;
            case R.id.back_to_ams_item /* 2131230803 */:
                Intent jbedIntent = new Intent(this, (Class<?>) AmsActivity.class);
                jbedIntent.setFlags(67108864);
                startActivity(jbedIntent);
                finish();
                break;
            default:
                isHandled = false;
                break;
        }
        this.mFocusPosition = -1;
        return isHandled;
    }

    @Override // android.app.Activity, android.view.Window.Callback
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            getListView().setSelection(this.mFocusPosition);
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void refreshList(List<JbedSelectorData> midlets) {
        setListAdapter(new ListAdapter(midlets));
        if (getListView().getCount() > 0) {
            this.mFocusPosition = 0;
        } else {
            this.mFocusPosition = -1;
        }
        getListView().requestFocusFromTouch();
        getListView().setSelection(this.mFocusPosition);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void showStopConfirmDialog(final JbedSelectorData midlet) {
        String msg = getString(R.string.PRJ_STOP_MIDLET);
        AlertDialog confirmDialog = new AlertDialog.Builder(this).setTitle(getString(R.string.PRJ_STOP)).setMessage(midlet.mName + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + msg + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.12
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialog, int whichButton) {
                RunningMidletManagerActivity.this.getAmsClient().requestDestroyEvent(midlet.mRoot, midlet.mNo);
            }
        }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.RunningMidletManagerActivity.11
            @Override // android.content.DialogInterface.OnClickListener
            public void onClick(DialogInterface dialog, int whichButton) {
                dialog.dismiss();
            }
        }).create();
        confirmDialog.show();
    }

    class ListAdapter extends ArrayAdapter<JbedSelectorData> {
        public ListAdapter(List<JbedSelectorData> list) {
            super(RunningMidletManagerActivity.this, -1, list);
        }

        @Override // android.widget.ArrayAdapter, android.widget.Adapter
        public View getView(int position, View convertView, ViewGroup parent) {
            JbedSelectorData midletProxy = getItem(position);
            AmsClient amsClient = RunningMidletManagerActivity.this.getAmsClient();
            if (amsClient == null) {
                return new FrameLayout(RunningMidletManagerActivity.this);
            }
            JbedSelectorData midlet = amsClient.findMidlet(midletProxy.mRoot, midletProxy.mNo);
            midlet.mIsPaused = midletProxy.mIsPaused;
            if (JbedConfig.Ams.isUsingSpecialIcon() && midlet.isDrmProtected()) {
                midlet.mIsExpired = amsClient.checkExpiredMidlet(midletProxy.mRoot);
                midlet.mDrmMethodType = amsClient.getDrmMethodType(midletProxy.mRoot);
            }
            LinearLayout layout = (LinearLayout) RunningMidletManagerActivity.this.mInflater.inflate(R.layout.list_selector_item, parent, false);
            layout.findViewById(R.id.progress_small).setVisibility(0);
            TextView text = (TextView) layout.findViewById(R.id.list_item_text);
            ImageView icon = (ImageView) layout.findViewById(R.id.list_item_icon);
            if (JbedConfig.Menu.isReconfigEnable() && RunningMidletManagerActivity.this.getResources().getConfiguration().orientation == 2) {
                text.setMaxWidth(AmsActivity.LANDSCAPE_MAX_WIDTH);
            }
            text.setText(midlet.mName);
            Drawable midletIcon = midlet.getIcon(RunningMidletManagerActivity.this);
            if (midletIcon != null) {
                icon.setImageDrawable(midletIcon);
            } else {
                icon.setBackgroundResource(R.drawable.default_midlet);
            }
            if (JbedConfig.Menu.isReconfigEnable()) {
                TextView size = (TextView) layout.findViewById(R.id.size_text);
                size.setText(midlet.getSizeText(RunningMidletManagerActivity.this));
                if (midlet.isDrmPending()) {
                    if (!JbedConfig.Ams.isUsingSpecialIcon()) {
                        layout.findViewById(R.id.drm_pending_icon).setVisibility(0);
                    }
                } else if (midlet.isDrmProtected() && !JbedConfig.Ams.isUsingSpecialIcon()) {
                    layout.findViewById(R.id.drm_protect_icon).setVisibility(0);
                }
            }
            return layout;
        }

        private boolean showDrmNormalIcon(JbedSelectorData data) {
            boolean isFLDrm = data.mDrmMethodType == 1;
            boolean result = true;
            if (isFLDrm) {
                String[] excludedOpCodeforFLIcon = {"VDF", "H3G", "ORG", "TME", "TNR", "TIM", "TMO"};
                for (String str : excludedOpCodeforFLIcon) {
                    if ("ORG".equals(str)) {
                        result = false;
                    }
                }
            }
            return result;
        }
    }
}
