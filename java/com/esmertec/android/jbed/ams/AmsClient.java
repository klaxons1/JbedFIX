package com.esmertec.android.jbed.ams;

import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.widget.Toast;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.esmertec.android.jbed.util.SimpleEntry;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Vector;

/* JADX INFO: loaded from: classes.dex */
public class AmsClient extends AmsClientBase implements AmsConstants {
    private static final String TAG = "AmsClient";
    private static boolean mInstallLock;
    private static String mInstalingUri = null;
    private static HashMap<Integer, Class<? extends AmsEventHandler>> mEventHandlerMap = new HashMap<>(30);

    static {
        mEventHandlerMap.put(2, BasicEventHandler.RunEventHandler.class);
        mEventHandlerMap.put(58, BasicEventHandler.RuntimeErrorEventHandler.class);
        mEventHandlerMap.put(20, BasicEventHandler.InfoEventHandler.class);
        mEventHandlerMap.put(10000, BasicEventHandler.AndroidListLocallInstallEventHandler.class);
        mEventHandlerMap.put(10002, BasicEventHandler.AndroidShowAboutEventHandler.class);
        mEventHandlerMap.put(10003, BasicEventHandler.AndroidShowAlertEventHandler.class);
        mEventHandlerMap.put(10004, BasicEventHandler.AndroidLaunchBrowserHandler.class);
        mEventHandlerMap.put(48, BasicEventHandler.RunningMidletManagerEventHandler.class);
        mEventHandlerMap.put(5, InstallEventHandler.InstalledEventHandler.class);
        mEventHandlerMap.put(6, InstallEventHandler.InstallCancelEventHandler.class);
        mEventHandlerMap.put(33, InstallEventHandler.RequestInstallEventHandler.class);
        mEventHandlerMap.put(15, InstallEventHandler.InstallPreviewJadEventHandler.class);
        mEventHandlerMap.put(13, InstallEventHandler.InstallQueryEventHandler.class);
        mEventHandlerMap.put(19, InstallEventHandler.InstallStepEventHandler.class);
        mEventHandlerMap.put(4, InstallEventHandler.InstallProgressEventHandler.class);
        mEventHandlerMap.put(12, InstallEventHandler.InstallStatusEventHandler.class);
        mEventHandlerMap.put(14, InstallEventHandler.InstallUnStoppableEventHandler.class);
        mEventHandlerMap.put(57, InstallEventHandler.InstallQueryYesNoEventHandler.class);
        mEventHandlerMap.put(46, InstallEventHandler.PreinstallFolderStartEventHandler.class);
        mEventHandlerMap.put(47, InstallEventHandler.PreinstallFolderFinishedEventHandler.class);
        mEventHandlerMap.put(7, BasicEventHandler.RemoveEventHandler.class);
        mEventHandlerMap.put(26, BasicEventHandler.RemoveAllEventHandler.class);
        mEventHandlerMap.put(10001, BasicEventHandler.AndroidRemoveConfirmEventHandler.class);
        mEventHandlerMap.put(10009, BasicEventHandler.AndroidMidletStartupErrorHandler.class);
        mEventHandlerMap.put(10012, BasicEventHandler.RemoveEventHandler.class);
        mEventHandlerMap.put(10011, BasicEventHandler.AndroidRemoveMultipleConfirmEventHandler.class);
        mEventHandlerMap.put(10013, FolderEventHandler.AndroidMoveMultipleConfirmEventHandler.class);
        mEventHandlerMap.put(51, PermissionEventHandler.RequestPermissionEventHandler.class);
        mEventHandlerMap.put(23, PermissionEventHandler.PermissionsEventHandler.class);
        mEventHandlerMap.put(43, PermissionEventHandler.RequestPushEventHandler.class);
        mEventHandlerMap.put(11, BasicEventHandler.MidletLifecycleEventHandler.class);
        mEventHandlerMap.put(18, BasicEventHandler.MidletLifecycleEventHandler.class);
        mEventHandlerMap.put(17, BasicEventHandler.MidletLifecycleEventHandler.class);
        mEventHandlerMap.put(29, BasicEventHandler.SelectStorageEventHandler.class);
        mEventHandlerMap.put(10010, BasicEventHandler.StorageSettingEventHandler.class);
        mEventHandlerMap.put(30, BasicEventHandler.RemovableMediaChangedEventHandler.class);
        mEventHandlerMap.put(52, BasicEventHandler.ListCertificatesEventHandler.class);
        mEventHandlerMap.put(10006, BasicEventHandler.SuiteRenameInputEventHandler.class);
        mEventHandlerMap.put(21, FolderEventHandler.FolderOperationResultEventHandler.class);
        mEventHandlerMap.put(65, FolderEventHandler.FolderListEventHandler.class);
        mEventHandlerMap.put(10005, FolderEventHandler.FolderNameInputEventHandler.class);
        mEventHandlerMap.put(10007, FolderEventHandler.FolderListEventHandler.class);
        mEventHandlerMap.put(Integer.valueOf(AmsConstants.EVENT_ANDROID_REMOVE_FOLDER_CONFIRM), FolderEventHandler.AndroidRemoveFolderConfirmEventHandler.class);
        mEventHandlerMap.put(72, BasicEventHandler.DisplaySizeHandler.class);
        mEventHandlerMap.put(73, BasicEventHandler.SetDisplaySizeHandler.class);
        mEventHandlerMap.put(60, FolderEventHandler.FolderOperationResultEventHandler.class);
        mEventHandlerMap.put(61, FolderEventHandler.FolderOperationResultEventHandler.class);
        mEventHandlerMap.put(62, FolderEventHandler.FolderOperationResultEventHandler.class);
        mEventHandlerMap.put(63, FolderEventHandler.FolderOperationResultEventHandler.class);
        mEventHandlerMap.put(31, BasicEventHandler.MoveEventHandler.class);
        mEventHandlerMap.put(67, BasicEventHandler.DrmGetConstraintEventHandler.class);
        mEventHandlerMap.put(38, BasicEventHandler.DrmActivateEventHandler.class);
        mEventHandlerMap.put(74, BasicEventHandler.PlatformRequestHandler.class);
        mEventHandlerMap.put(10014, BasicEventHandler.AndroidPurchaseROConfirmEventHandler.class);
        mEventHandlerMap.put(10016, BasicEventHandler.SortSettingEventHandler.class);
    }

    public AmsClient(Context context, Handler handler, IJbedAmsConnection conn, long id) {
        super(context, handler, conn, id, new AmsEventHandler.Factory() { // from class: com.esmertec.android.jbed.ams.AmsClient.1
            @Override // com.esmertec.android.jbed.ams.AmsEventHandler.Factory
            public AmsEventHandler buildAmsHandler(int eventId) {
                Class<? extends AmsEventHandler> cls = (Class) AmsClient.mEventHandlerMap.get(Integer.valueOf(eventId));
                if (cls == null) {
                    Log.e(AmsClient.TAG, "ERROR: can't find the handler for event " + eventId);
                    return null;
                }
                try {
                    return (AmsEventHandler) cls.newInstance();
                } catch (Exception ex) {
                    Log.e(AmsClient.TAG, "ERROR: failed to build event by " + cls, ex);
                    throw new IllegalArgumentException("Failed to new event handler " + cls);
                }
            }
        });
        if (id == 1) {
            AmsActivity.initAmsClient(this);
        }
    }

    private byte[] convertStringArrayToBytes(String[] s) {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        out.write(s.length);
        for (String str : s) {
            try {
                out.write(str.getBytes("utf-8"));
                out.write(0);
            } catch (IOException ex) {
                Log.e(TAG, "ERROR: combineByteData " + ex);
            }
        }
        return out.toByteArray();
    }

    public synchronized boolean requestInstallLock() {
        boolean z;
        if (!mInstallLock) {
            mInstallLock = true;
            z = true;
        } else {
            if (JbedConfig.Ams.isShowToastEnabled()) {
                String text = this.mContext.getString(R.string.PRJ_INSTALL_WARNING);
                Toast.makeText(this.mContext, text, 0).show();
            }
            Log.e(TAG, "Another install process exist, installation canceled");
            z = false;
        }
        return z;
    }

    public synchronized void releaseInstallLock() {
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, "Install lock released");
        }
        mInstalingUri = null;
        mInstallLock = false;
    }

    public void requestInstallEvent(String installUrl) {
        Log.i(TAG, "requestInstallEvent() with url is " + installUrl);
        if (mInstalingUri == null || !mInstalingUri.equals(installUrl)) {
            LogTag.amsDebug(TAG, "requestInstallEvent() requestInstallLock");
            if (requestInstallLock()) {
                mInstalingUri = installUrl;
                requestEvent(5, 0, installUrl);
            } else {
                Log.w(TAG, "requestInstallEvent() ignored because install lock is held");
            }
        } else {
            Log.w(TAG, "requestInstallEvent() ignored duplicate uri " + installUrl);
        }
    }

    public void requestUpdateEvent(String root) {
        requestEvent(3, 0, root);
    }

    public void requestStorageSetting(int defaultStorage) {
        handleEventInternal(10010, defaultStorage, null, null);
    }

    public void requestRemoveConfirmEvent(JbedSelectorData midlet) {
        handleEventInternal(10001, 7, midlet.mRoot.getBytes(), midlet);
    }

    public void requestRemoveAllConfirmEvent() {
        handleEventInternal(10001, 26, null, getSelector().getMidlets());
    }

    public void requestRemoveMultipleConfirmEvent(JbedSelectorData folder, boolean isContextItemSelected) {
        if (isContextItemSelected) {
            handleEventInternal(10011, 1, null, folder.isMidlet() ? folder.mParent : folder);
        } else {
            handleEventInternal(10011, 0, null, getSelector().getAllSuites(folder, false, false));
        }
    }

    public List<JbedSelectorData> getAllMidlets() {
        return getSelector().getAllOnlyMidlets();
    }

    public List<JbedSelectorData> getAllSuites() {
        return getSelector().getMidlets();
    }

    public List<JbedSelectorData> getOnlySuites() {
        return getSelector().getOnlySuites();
    }

    public void requestRemoveEvent(String root) {
        requestEvent(7, 0, root);
    }

    public void requestRemoveMultipleEvent(Object obj) {
        handleEventInternal(10012, 0, null, obj == null ? null : obj);
    }

    public void requestRemoveMultipleCancelEvent() {
        handleEventInternal(10012, 6, null, null);
    }

    public void requestRemoveAllEvent() {
        requestEvent(26);
    }

    public void requestInfoEvent(String root) {
        requestEvent(20, 0, root);
    }

    public void requestStartRunningMidletManager() {
        handleEventInternal(48, 0, null, null);
    }

    public void requestInstallQueryEvent(boolean isContinue) {
        requestEvent(13, isContinue ? 5 : 6);
    }

    public void requestInstallAuthorization(String userName, String password, boolean isContinue) {
        requestEvent(16, isContinue ? 1 : 6, convertStringArrayToBytes(new String[]{userName, password}));
    }

    public void requestInstrallPreviewJadEvent(boolean isContinue) {
        requestEvent(15, isContinue ? 5 : 6);
    }

    public void requestInstallCancelEvent() {
        requestEvent(6);
    }

    public void requestListCertificatesEvent() {
        requestEvent(52);
    }

    public void requestInstallQueryYesNoResponse(boolean isYes) {
        requestEvent(57, isYes ? 25 : 6);
    }

    public void requestShowAboutEvent() {
        handleEventInternal(10002, 0, null, null);
    }

    public void requestPushAnswer(int transId, byte answer) {
        requestEvent(43, transId, new byte[]{answer});
    }

    public void requestPermissionAnswer(int transId, byte answer) {
        requestEvent(51, transId, new byte[]{answer});
    }

    public void requestSelectStorageContinue(String rootName) {
        requestEvent(29, 5, rootName);
    }

    public void requestSelectStorageCancel() {
        requestEvent(29, 6);
    }

    public void requestSelectFolderContinue(String rootName) {
        requestEvent(65, 5, rootName);
    }

    public void requestSelectFolderCancel() {
        requestEvent(65, 6);
    }

    public void requestListLocalInstall(boolean isSdcardOnly) {
        handleEventInternal(10000, 0, null, Boolean.valueOf(isSdcardOnly));
    }

    public void requestShowInfo(String msg) {
        handleEventInternal(10003, 0, null, msg);
    }

    public void requestPermission(String root) {
        requestEvent(23, 0, root);
    }

    public void requestShowWarning(String msg) {
        handleEventInternal(10003, 1, null, msg);
    }

    public void requestShowError(String msg) {
        handleEventInternal(10003, 2, null, msg);
    }

    public void requestLaunchBrowser(String url) {
        handleEventInternal(10004, 0, url == null ? null : url.getBytes(), 0);
    }

    public void requestPermissionAnswerCommit() {
        requestEvent(24, 2);
    }

    public void requsetInputName(JbedSelectorData midlet) {
        if (midlet.isFolder()) {
            handleEventInternal(10005, 62, null, midlet);
        } else {
            handleEventInternal(10006, 0, null, midlet);
        }
    }

    public void requestDisplaySize(JbedSelectorData midlet) {
        requestEvent(72, midlet.mNo, midlet.mRoot.getBytes());
    }

    public void requestSetDisplaySize(String root, int no, String displaySize) {
        String[] stringArray = {root, displaySize};
        requestEvent(73, no, convertStringArrayToBytes(stringArray));
    }

    public void requestHandleMideltStartupError(String root, String errorMsg) {
        handleEventInternal(10009, 0, root.getBytes(), errorMsg);
    }

    public void requestHandleSelectStorage(boolean isInternalStorage) {
        if (isInternalStorage) {
            requestSelectStorageContinue(this.mContext.getString(R.string.AMS_PHONE_STORAGE_NAME));
        } else {
            requestSelectStorageContinue(JbedFileManager.EXTERNAL_STORAGE_NAME);
        }
    }

    public void requestRenameSuite(JbedSelectorData midlet, String newName) {
        String[] stringArray = {midlet.mRoot, newName};
        requestEvent(21, midlet.mNo, convertStringArrayToBytes(stringArray));
    }

    public void requestInputFolderName(JbedSelectorData midlet) {
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, "requestFolderNameInput");
        }
        handleEventInternal(10005, 60, null, midlet);
    }

    public void requestCreateFolder(String parentPath, String folderName) {
        String[] stringArray = {parentPath, folderName};
        requestEvent(60, 0, convertStringArrayToBytes(stringArray));
    }

    public void requestRenameFolder(String srcName, String dstName) {
        String[] stringArray = {srcName, dstName};
        requestEvent(62, 0, convertStringArrayToBytes(stringArray));
    }

    public void requestRemoveFolderConfirmEvent(JbedSelectorData data) {
        handleEventInternal(AmsConstants.EVENT_ANDROID_REMOVE_FOLDER_CONFIRM, 63, null, data);
    }

    public void requestRemoveFolderEvent(String folderName) {
        requestEvent(63, 0, folderName);
    }

    public void requestFolderSelectEvent(JbedSelectorData midlet) {
        handleEventInternal(10007, 31, midlet.mName.getBytes(), midlet);
    }

    public void requestMoveMultipleSelectEvent(JbedSelectorData folder, boolean isContextItemSelected) {
        if (isContextItemSelected) {
            handleEventInternal(10013, 1, null, folder.isMidlet() ? folder.mParent : folder);
        } else {
            handleEventInternal(10013, 0, null, getSelector().getAllSuites(folder, false, false));
        }
    }

    public int requestMoveToFolderEvent(JbedSelectorData midlet, String folderName) {
        mSerialEventProxy = new AmsClientBase.SerialEventProxy(new int[]{31}) { // from class: com.esmertec.android.jbed.ams.AmsClient.2
            int mResult;

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            Object getResponse() {
                return Integer.valueOf(this.mResult);
            }

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            void onResponseReceived(int eventId, int result, byte[] data) throws IOException {
                this.mResult = result;
            }
        };
        String[] stringArray = {midlet.mRoot, folderName};
        mSerialEventProxy.requestEvent(31, 1, convertStringArrayToBytes(stringArray));
        int result = ((Integer) mSerialEventProxy.getResponse()).intValue();
        mSerialEventProxy = null;
        return result;
    }

    public AmsEvent requestMoveToStorageEvent(JbedSelectorData midlet, String storage) {
        mSerialEventProxy = new AmsClientBase.SerialEventProxy(new int[]{31}) { // from class: com.esmertec.android.jbed.ams.AmsClient.3
            AmsEvent mResult;

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            Object getResponse() {
                return this.mResult;
            }

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            void onResponseReceived(int eventId, int result, byte[] data) throws IOException {
                this.mResult = new AmsEvent(eventId, result, data);
            }
        };
        String[] stringArray = {midlet.mRoot, storage};
        mSerialEventProxy.requestEvent(31, 0, convertStringArrayToBytes(stringArray));
        AmsEvent result = (AmsEvent) mSerialEventProxy.getResponse();
        mSerialEventProxy = null;
        return result;
    }

    public void requestInstalledFolderEvent(String folderName) {
        if (!JbedConfig.Ams.unlimitMidletInDefaultFolder()) {
            String folders = this.mContext.getString(R.string.AMS_DEFAULT_FOLDERS);
            if (folders != null && folders.trim().length() != 0) {
                Vector fNames = new Vector();
                int index = folders.indexOf("|");
                while (index != -1) {
                    fNames.addElement(folders.substring(0, index));
                    folders = folders.substring(index + 1);
                    index = folders.indexOf("|");
                }
                fNames.addElement(folders);
                int i = 0;
                while (folderName != null && i < fNames.size() && !folderName.equals(JbedSelector.ROOT_FOLDER_NAME + ((String) fNames.elementAt(i)) + JbedSelector.ROOT_FOLDER_NAME)) {
                    i++;
                }
                if (folderName == null || i == fNames.size()) {
                    folderName = JbedSelector.ROOT_FOLDER_NAME + ((String) fNames.elementAt(0));
                }
            } else if (folderName == null) {
                folderName = JbedSelector.ROOT_FOLDER_NAME;
            }
        }
        requestEvent(65, 5, folderName);
    }

    public void requestDrmCheckRightsEvent(String root) {
        requestEvent(66, 0, root.getBytes());
    }

    public void requestDrmInstallEvent(String root) {
        if (requestInstallLock()) {
            requestEvent(39, 0, root.getBytes());
        }
    }

    public void requestChapiEvent(String chapiURL, String contentType, String action, String appName) {
        String[] stringArray = {chapiURL, contentType, action, appName};
        requestEvent(45, 0, convertStringArrayToBytes(stringArray));
    }

    public void requestDrmActivateEvent(String root) {
        requestEvent(38, 0, root);
    }

    public void requestDrmActivateErrorEvent(String msg) {
        handleEventInternal(38, 15, msg.getBytes(), null);
    }

    public void requestInstallQueryEvent(String msg) {
        handleEventInternal(13, 2, msg.getBytes(), null);
    }

    public void requestSortSetting(int defaultSort) {
        handleEventInternal(10016, defaultSort, null, null);
    }

    public void requestPauseMidlet(String mRoot, int mNo) {
        requestEvent(8, mNo, mRoot);
    }

    public void requestResumeMidlet(String mRoot, int mNo) {
        requestEvent(9, mNo, mRoot);
    }

    Map.Entry<Integer, String> checkPermissionAnswer(byte fgIndex, byte permissionAnswer) {
        mSerialEventProxy = new AmsClientBase.SerialEventProxy(new int[]{25, 24}) { // from class: com.esmertec.android.jbed.ams.AmsClient.4
            Map.Entry<Integer, String> mResult;

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            void onResponseReceived(int eventId, int result, byte[] data) throws IOException {
                this.mResult = new SimpleEntry(Integer.valueOf(result), data == null ? null : new String(data));
            }

            @Override // com.esmertec.android.jbed.ams.AmsClientBase.SerialEventProxy
            Object getResponse() {
                return this.mResult;
            }
        };
        mSerialEventProxy.requestEvent(24, 1, new byte[]{fgIndex, permissionAnswer});
        Map.Entry<Integer, String> result = (Map.Entry) mSerialEventProxy.getResponse();
        mSerialEventProxy = null;
        return result;
    }
}
