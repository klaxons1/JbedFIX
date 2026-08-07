package com.esmertec.android.jbed.ams;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.google.android.collect.Lists;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/* JADX INFO: loaded from: classes.dex */
public class FolderEventHandler {

    public static class AndroidRemoveFolderConfirmEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            JbedSelectorData data = (JbedSelectorData) this.mEvent.mObj;
            String msg = this.mContext.getString(R.string.AMS_CONFIRM_REMOVE, data.getNameText());
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidRemoveFolderConfirmEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) AndroidRemoveFolderConfirmEventHandler.this.mClient).requestRemoveFolderEvent(((JbedSelectorData) AndroidRemoveFolderConfirmEventHandler.this.mEvent.mObj).getFullPath());
                    AndroidRemoveFolderConfirmEventHandler.this.mHandler.obtainMessage(10010).sendToTarget();
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
        }
    }

    public static class FolderNameInputEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LayoutInflater mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
            View v = mInflater.inflate(R.layout.name_input_dialog, (ViewGroup) null);
            final EditText edtText = (EditText) v.findViewById(R.id.edtName);
            if (this.mEvent.mResult == 62) {
                edtText.setText(((JbedSelectorData) this.mEvent.mObj).mName);
            }
            new AlertDialog.Builder(getContext()).setTitle(R.string.AMS_NEW_FOLDER_NAME).setView(v).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderNameInputEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    String newName = edtText.getText().toString().trim();
                    String folderPath = JbedSelector.ROOT_FOLDER_NAME;
                    if (FolderNameInputEventHandler.this.mEvent.mObj != null) {
                        folderPath = ((JbedSelectorData) FolderNameInputEventHandler.this.mEvent.mObj).getFullPath();
                    }
                    if (FolderNameInputEventHandler.this.mEvent.mResult == 60) {
                        ((AmsClient) FolderNameInputEventHandler.this.mClient).requestCreateFolder(folderPath, newName);
                    } else if (FolderNameInputEventHandler.this.mEvent.mObj != null && !newName.equals(((JbedSelectorData) FolderNameInputEventHandler.this.mEvent.mObj).mName)) {
                        ((AmsClient) FolderNameInputEventHandler.this.mClient).requestRenameFolder(folderPath, newName);
                    }
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
            if (JbedConfig.getToggleSoftInputDelay() != 0) {
                Timer timer = new Timer();
                timer.schedule(new TimerTask() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderNameInputEventHandler.2
                    @Override // java.util.TimerTask, java.lang.Runnable
                    public void run() {
                        InputMethodManager imm = (InputMethodManager) FolderNameInputEventHandler.this.mContext.getSystemService("input_method");
                        imm.toggleSoftInput(0, 2);
                    }
                }, JbedConfig.getToggleSoftInputDelay());
            }
        }
    }

    public static class FolderOperationResultEventHandler extends AmsEventHandler {
        String mErrorInfo = null;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data != null) {
                this.mErrorInfo = new String(data);
            }
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            DialogInterface.OnClickListener listener;
            this.mHandler.obtainMessage(10011).sendToTarget();
            if (this.mEvent.mResult != 1) {
                switch (this.mEvent.mId) {
                    case AmsConstants.EVENT_CREATE_FOLDER /* 60 */:
                    case AmsConstants.EVENT_RENAME_FOLDER /* 62 */:
                        listener = new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderOperationResultEventHandler.1
                            @Override // android.content.DialogInterface.OnClickListener
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.dismiss();
                            }
                        };
                        break;
                    case AmsConstants.EVENT_MOVE_FOLDER /* 61 */:
                    default:
                        listener = null;
                        break;
                }
                showError(this.mErrorInfo, listener);
                return;
            }
            if (this.mEvent.mId == 63) {
                showInfo(this.mContext.getString(R.string.AMS_REMOVE_SUCCESS));
            }
        }
    }

    public static class FolderListEventHandler extends AmsEventHandler {
        private static final String TAG = "FolderListEventHandler";
        private static AlertDialog folderListDialog = null;

        /* JADX INFO: Access modifiers changed from: private */
        public void showMoveResult(int result) {
            String msg;
            switch (result) {
                case 1:
                    msg = this.mContext.getString(R.string.AMS_SUCCESS);
                    break;
                case 8:
                    msg = this.mContext.getString(R.string.AMS_INVALID_FILE_NAME);
                    break;
                case 15:
                    msg = this.mEvent.getDataAsUtf8();
                    break;
                default:
                    throw new IllegalStateException("RemoveEventHandler unknown result value");
            }
            showToast(msg);
        }

        public static void dismissDialog() {
            try {
                if (folderListDialog != null) {
                    folderListDialog.dismiss();
                }
            } catch (Exception e) {
                Log.w(TAG, "ignore exception in dismissDialog()", e);
            }
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            boolean includeRoot = !JbedConfig.Ams.isMidletInFolderOnly();
            final JbedSelectorData.SelectorCharSequence[] folders = this.mClient.getSelector().toFolderCharSequences(this.mClient.getAllFolders(false, false, includeRoot));
            for (int i = 0; i < folders.length; i++) {
                if (folders[i].toString().equals("/Applications")) {
                    folders[i] = new JbedSelectorData.SelectorCharSequence(JbedSelector.ROOT_FOLDER_NAME + this.mContext.getString(R.string.PRJ_APPLICATIONS), folders[i].mData);
                } else if (folders[i].toString().equals("/Games")) {
                    folders[i] = new JbedSelectorData.SelectorCharSequence(JbedSelector.ROOT_FOLDER_NAME + this.mContext.getString(R.string.PRJ_GAMES), folders[i].mData);
                } else if (folders[i].toString().equals("/sdcard")) {
                    folders[i] = new JbedSelectorData.SelectorCharSequence(JbedSelector.ROOT_FOLDER_NAME + this.mContext.getString(R.string.PRJ_EXTERNAL_STORAGE_SDCARD), folders[i].mData);
                }
            }
            folderListDialog = new AlertDialog.Builder(getContext()).setTitle(R.string.AMS_SELECT_FOLDER_TITLE).setItems(folders, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderListEventHandler.3
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int pos) {
                    String selectedPath = folders[pos].mData.getFullPath();
                    if (FolderListEventHandler.this.mEvent.mId == 65) {
                        ((AmsClient) FolderListEventHandler.this.mClient).requestInstalledFolderEvent(selectedPath);
                    } else {
                        int result = ((AmsClient) FolderListEventHandler.this.mClient).requestMoveToFolderEvent((JbedSelectorData) FolderListEventHandler.this.mEvent.mObj, selectedPath);
                        FolderListEventHandler.this.showMoveResult(result);
                    }
                    dialog.dismiss();
                }
            }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderListEventHandler.2
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog) {
                    if (FolderListEventHandler.this.mEvent.mId == 65) {
                        ((AmsClient) FolderListEventHandler.this.mClient).requestSelectStorageCancel();
                    }
                    dialog.dismiss();
                }
            }).setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.FolderListEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                    if (FolderListEventHandler.this.mEvent.mId == 65) {
                        ((AmsClient) FolderListEventHandler.this.mClient).requestSelectStorageCancel();
                    }
                    dialog.dismiss();
                }
            }).create();
            folderListDialog.show();
        }
    }

    public static class AndroidMoveMultipleConfirmEventHandler extends AmsEventHandler {
        private boolean includeRoot;
        List<String> storages;
        private int storageSelected = -1;
        private JbedSelectorData.SelectorCharSequence[] folders = null;
        private JbedSelectorData.SelectorCharSequence[] suites = null;
        private boolean[] choosed = null;
        private final int MIDLET_IS_IN_INTERNAL_STORAGE = 0;
        private final int MIDLET_IS_IN_EXTERNAL_SDCARD = 1;

        /* JADX INFO: Access modifiers changed from: private */
        public void showStorageSetting() {
            this.storages.add(this.mContext.getString(R.string.AMS_PHONE_STORAGE_NAME));
            if (JbedFileManager.isExternalStorageReady()) {
                this.storages.add(this.mContext.getString(R.string.PRJ_EXTERNAL_STORAGE_SDCARD));
            }
            this.storageSelected = 0;
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_STORAGE_SETTING)).setSingleChoiceItems((CharSequence[]) this.storages.toArray(new String[this.storages.size()]), this.storageSelected, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                    AndroidMoveMultipleConfirmEventHandler.this.storageSelected = which;
                }
            }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    AndroidMoveMultipleConfirmEventHandler.this.showFolderChoose();
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
        }

        private void showMultiMidletChoose() {
            String title = this.mContext.getString(R.string.PRJ_MOVE_MULTI_MIDLETS_TITLE);
            new AlertDialog.Builder(getContext()).setTitle(title).setMultiChoiceItems(this.suites, this.choosed, new DialogInterface.OnMultiChoiceClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.5
                @Override // android.content.DialogInterface.OnMultiChoiceClickListener
                public void onClick(DialogInterface dialog, int whichItem, boolean isChecked) {
                    AndroidMoveMultipleConfirmEventHandler.this.choosed[whichItem] = isChecked;
                }
            }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.4
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    AndroidMoveMultipleConfirmEventHandler.this.showMultiChooseConfirm();
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.3
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                }
            }).show();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void showMultiChooseConfirm() {
            String msg = this.mContext.getString(R.string.PRJ_MOVE_MULTI_MIDLETS);
            int choosedNum = 0;
            for (int j = 0; j < this.choosed.length; j++) {
                if (this.choosed[j]) {
                    choosedNum++;
                }
            }
            if (choosedNum == 0) {
                showWarning(this.mContext.getString(R.string.PRJ_NO_FILES_SELECTED));
                return;
            }
            for (int i = 0; i < this.choosed.length; i++) {
                if (this.choosed[i]) {
                    msg = this.suites[i].mData.mName + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + msg + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                }
            }
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_MOVE)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.6
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    AndroidMoveMultipleConfirmEventHandler.this.showStorageSetting();
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void showFolderChoose() {
            boolean isStorageChanged = false;
            for (int i = 0; i < this.choosed.length; i++) {
                if (this.choosed[i]) {
                    int storageFlag = this.suites[i].mData.isOnSdcard() ? 1 : 0;
                    if (storageFlag != this.storageSelected) {
                        isStorageChanged = true;
                        break;
                    }
                }
            }
            List<JbedSelectorData> moveFolders = this.mClient.getAllFolders(false, false, this.includeRoot);
            if (!isStorageChanged) {
                moveFolders.remove(this.suites[0].mData.mParent);
            }
            this.folders = this.mClient.getSelector().toFolderCharSequences(moveFolders);
            for (int i2 = 0; i2 < this.folders.length; i2++) {
                if (this.folders[i2].toString().equals("/Applications")) {
                    this.folders[i2] = new JbedSelectorData.SelectorCharSequence(JbedSelector.ROOT_FOLDER_NAME + this.mContext.getString(R.string.PRJ_APPLICATIONS), this.folders[i2].mData);
                } else if (this.folders[i2].toString().equals("/Games")) {
                    this.folders[i2] = new JbedSelectorData.SelectorCharSequence(JbedSelector.ROOT_FOLDER_NAME + this.mContext.getString(R.string.PRJ_GAMES), this.folders[i2].mData);
                }
            }
            new AlertDialog.Builder(getContext()).setTitle(R.string.AMS_SELECT_FOLDER_TITLE).setItems(this.folders, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.8
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int pos) {
                    String selectedPath = AndroidMoveMultipleConfirmEventHandler.this.folders[pos].mData.getFullPath();
                    for (int i3 = 0; i3 < AndroidMoveMultipleConfirmEventHandler.this.choosed.length; i3++) {
                        if (AndroidMoveMultipleConfirmEventHandler.this.choosed[i3] && AndroidMoveMultipleConfirmEventHandler.this.storageSelected != -1) {
                            String storage = AndroidMoveMultipleConfirmEventHandler.this.storages.get(AndroidMoveMultipleConfirmEventHandler.this.storageSelected);
                            if (storage.equals(AndroidMoveMultipleConfirmEventHandler.this.mContext.getString(R.string.PRJ_EXTERNAL_STORAGE_SDCARD))) {
                                storage = JbedFileManager.EXTERNAL_STORAGE_NAME;
                            }
                            AmsEvent resultStorageEvent = ((AmsClient) AndroidMoveMultipleConfirmEventHandler.this.mClient).requestMoveToStorageEvent(AndroidMoveMultipleConfirmEventHandler.this.suites[i3].mData, storage);
                            if (resultStorageEvent.mResult == 1) {
                                int resultFolderEvent = ((AmsClient) AndroidMoveMultipleConfirmEventHandler.this.mClient).requestMoveToFolderEvent(AndroidMoveMultipleConfirmEventHandler.this.suites[i3].mData, selectedPath);
                                AndroidMoveMultipleConfirmEventHandler.this.showMoveResult(resultFolderEvent);
                            } else {
                                String msg = resultStorageEvent.getDataAsUtf8();
                                AndroidMoveMultipleConfirmEventHandler.this.showToast(msg);
                            }
                        }
                    }
                }
            }).setNegativeButton(android.R.string.cancel, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.7
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                }
            }).show();
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.storages = new ArrayList();
            this.includeRoot = !JbedConfig.Ams.isMidletInFolderOnly();
            this.folders = this.mClient.getSelector().toFolderCharSequences(this.mClient.getAllFolders(false, false, this.includeRoot));
            if (this.mEvent.mResult == 1) {
                List<JbedSelectorData> allMidlets = Lists.newArrayList();
                allMidlets.add((JbedSelectorData) this.mEvent.mObj);
                this.suites = this.mClient.getSelector().toSuiteCharSequences(allMidlets);
            } else {
                this.suites = this.mClient.getSelector().toSuiteCharSequences(getUnrunningMidlets());
            }
            if (this.suites.length == 0) {
                showWarning(this.mContext.getString(R.string.PRJ_SELECT_MIDLET));
                return;
            }
            this.choosed = new boolean[this.suites.length];
            if (this.mEvent.mResult == 1) {
                this.choosed[0] = true;
            }
            showMultiMidletChoose();
        }

        public List<JbedSelectorData> getUnrunningMidlets() {
            List<JbedSelectorData> runningMidlets = ((AmsClient) this.mClient).getRunningMidletList();
            List<JbedSelectorData> allMidlets = (List) this.mEvent.mObj;
            List<JbedSelectorData> unrunningMidlets = Lists.newArrayList();
            for (JbedSelectorData data : allMidlets) {
                boolean isRunning = false;
                for (JbedSelectorData runningmidlet : runningMidlets) {
                    if (runningmidlet.mRoot.equals(data.mRoot)) {
                        isRunning = true;
                        break;
                    }
                }
                if (!data.mIsPreInstall && !isRunning) {
                    unrunningMidlets.add(data);
                }
            }
            return unrunningMidlets;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void showMoveResult(int result) {
            String msg;
            switch (result) {
                case 1:
                    msg = this.mContext.getString(R.string.AMS_SUCCESS);
                    break;
                case 8:
                    msg = this.mContext.getString(R.string.AMS_INVALID_FILE_NAME);
                    break;
                case 15:
                    msg = this.mEvent.getDataAsUtf8();
                    break;
                default:
                    throw new IllegalStateException("RemoveEventHandler unknown result value");
            }
            showToast(msg);
        }
    }
}
