package com.esmertec.android.jbed.ams;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.EditText;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.JbedSettings;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.jsr.JbedFileManager;
import com.google.android.collect.Lists;
import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Timer;
import java.util.TimerTask;

/* JADX INFO: loaded from: classes.dex */
public class BasicEventHandler {

    public static class RemovableMediaChangedEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.mHandler.obtainMessage(AmsConstants.HANDLE_SDCARD_EVENT, Integer.valueOf(this.mEvent.mResult)).sendToTarget();
        }
    }

    public static class DummyEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            Log.w("AmsEventHandler", "DummyEventHandler for " + this.mEvent.toString());
        }
    }

    public static class MidletLifecycleEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.mHandler.obtainMessage(10015, this.mEvent.mId, this.mEvent.mResult, this.mEvent.getDataAsUtf8()).sendToTarget();
        }
    }

    public static class RunEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            JbedSelectorData suite;
            processMessageImmediately(this.mHandler.obtainMessage(10013));
            if (this.mEvent.mResult == 15 || this.mEvent.mResult == 27) {
                this.mHandler.obtainMessage(AmsConstants.HANDLE_MIDLET_STARTUP_ERROR, this.mEvent.getDataAsUtf8()).sendToTarget();
            } else if (this.mEvent.mResult == 1 && (suite = this.mClient.findSuite(this.mEvent.getDataAsUtf8())) != null) {
                bringMidletToForeground(suite.isFullScreen());
            }
        }
    }

    public static class MoveEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String msg;
            switch (this.mEvent.mResult) {
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

    public static class DrmCheckRightsEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            switch (this.mEvent.mResult) {
                case 1:
                    showInfo(this.mContext.getString(R.string.AMS_SUCCESS));
                    return;
                case 8:
                    showError(this.mContext.getString(R.string.AMS_INVALID_FILE_NAME));
                    return;
                case 15:
                    showError(this.mEvent.getDataAsUtf8());
                    return;
                default:
                    throw new IllegalStateException("DrmCheckRightsHandler unknown result value");
            }
        }
    }

    public static class DrmActivateEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String msg;
            switch (this.mEvent.mResult) {
                case 1:
                    msg = this.mContext.getString(R.string.AMS_ACTIVATE_COMMAND);
                    break;
                case 8:
                    msg = this.mContext.getString(R.string.AMS_INVALID_FILE_NAME);
                    break;
                case 15:
                    msg = this.mEvent.getDataAsUtf8();
                    break;
                default:
                    throw new IllegalStateException("DrmActivateEventHandler unknown result value");
            }
            LogTag.amsDebug("AmsEventHandler", "DrmActivateEventHandler msg:" + msg);
            if (!JbedConfig.getCustomerName().equals("LGE")) {
                showToast(msg);
            }
        }
    }

    public static class DrmGetConstraintEventHandler extends AmsEventHandler {
        public static final String DELIMITER = " : ";

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (JbedConfig.getCustomerName().equals("LGE")) {
                StringBuffer mInfo = new StringBuffer();
                if (this.mEvent.mResult != 27 && this.mEvent.mResult != 15 && this.mEvent.mResult != 8 && this.mEvent.mData != null) {
                    DataInputStream in = new DataInputStream(new ByteArrayInputStream(this.mEvent.mData));
                    DateFormat.getDateTimeInstance(1, 1, Locale.getDefault());
                    int cnt = 0;
                    String suiteId = null;
                    while (in.available() > 0) {
                        try {
                            String token = readJbedString(in);
                            if ("drmConstraintCount".equals(token)) {
                                cnt = Integer.parseInt(readJbedString(in));
                            } else if ("suiteId".equals(token)) {
                                suiteId = readJbedString(in);
                            }
                        } catch (IOException e) {
                            return;
                        }
                    }
                    if (cnt == 1 && suiteId != null) {
                        JbedSelectorData midlet = this.mClient.findSuite(suiteId);
                        if (midlet == null) {
                            LogTag.amsDebug("AmsEventHandler", "DrmGetConstraintEventHandler midlet is null");
                            return;
                        } else if (((AmsClient) this.mClient).getDrmMethodType(midlet) == 3) {
                            ((AmsClient) this.mClient).requestDrmPurchaseRoConfirmEvent(0, midlet);
                            return;
                        } else {
                            mInfo.append(this.mContext.getString(R.string.PRJ_DRM_COUNT_POPUP_STR, Integer.valueOf(cnt)));
                            showInfo(mInfo.toString());
                            return;
                        }
                    }
                    return;
                }
                if (this.mEvent.mResult == 27 && this.mEvent.mData != null) {
                    String suiteId2 = new String(this.mEvent.mData);
                    JbedSelectorData midlet2 = this.mClient.findSuite(suiteId2);
                    if (midlet2 == null) {
                        LogTag.amsDebug("AmsEventHandler", "DrmGetConstraintEventHandler midlet is null");
                        return;
                    } else if (((AmsClient) this.mClient).getDrmMethodType(midlet2) == 3) {
                        ((AmsClient) this.mClient).requestDrmPurchaseRoConfirmEvent(1, midlet2);
                        return;
                    } else {
                        mInfo.append(this.mContext.getString(R.string.PRJ_DRM_EXPIRED_POPUP_STR));
                        showInfo(mInfo.toString());
                        return;
                    }
                }
                return;
            }
            if (this.mEvent.mResult != 27 && this.mEvent.mResult != 15 && this.mEvent.mResult != 8 && this.mEvent.mData != null) {
                StringBuffer mInfo2 = new StringBuffer();
                DataInputStream in2 = new DataInputStream(new ByteArrayInputStream(this.mEvent.mData));
                DateFormat dateFormat = DateFormat.getDateTimeInstance(1, 1, Locale.getDefault());
                while (in2.available() > 0) {
                    try {
                        String token2 = readJbedString(in2);
                        if ("drmConstraintCount".equals(token2)) {
                            mInfo2.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_COUNT)).append(" : ");
                            mInfo2.append(readJbedString(in2)).append('\n');
                        } else if ("drmConstraintStartDate".equals(token2)) {
                            mInfo2.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_START_DATE)).append(" : ");
                            String startDate = readJbedString(in2);
                            Date date = new Date(new Long(startDate).longValue());
                            mInfo2.append("  ").append(dateFormat.format(date)).append('\n');
                        } else if ("drmConstraintEndDate".equals(token2)) {
                            String endDate = readJbedString(in2);
                            Date date2 = new Date(new Long(endDate).longValue());
                            mInfo2.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_END_DATE)).append(" : ");
                            mInfo2.append("  ").append(dateFormat.format(date2)).append('\n');
                        } else if ("drmConstraintInterval".equals(token2)) {
                            String Interval = readJbedString(in2);
                            mInfo2.append(this.mContext.getString(R.string.AMS_CONTRAINT_INTERVAL)).append(" : ");
                            mInfo2.append("  ").append(Interval).append('\n');
                        }
                    } catch (IOException e2) {
                        return;
                    }
                }
                showToast(mInfo2.toString());
            }
        }
    }

    public static class AndroidRemoveMultipleConfirmEventHandler extends AmsEventHandler {
        private boolean[] choosed = null;
        private JbedSelectorData.SelectorCharSequence[] suites;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (this.mEvent.mResult == 1) {
                this.suites = this.mClient.getSelector().toSuiteCharSequences(Lists.newArrayList(new JbedSelectorData[]{(JbedSelectorData) this.mEvent.mObj}));
            } else {
                List<JbedSelectorData> allMidlets = getUnrunningMidlets();
                Collections.sort(allMidlets, JbedSelectorData.NAME_ORDER);
                this.suites = this.mClient.getSelector().toSuiteCharSequences(allMidlets);
            }
            if (this.suites.length == 0) {
                showWarning(this.mContext.getString(R.string.PRJ_SELECT_MIDLET));
                return;
            }
            this.choosed = new boolean[this.suites.length];
            if (this.mEvent.mResult == 1) {
                this.choosed[0] = true;
            }
            AlertDialog dialog = new AlertDialog.Builder(getContext()).setTitle(R.string.PRJ_DELETE).setMultiChoiceItems(this.suites, this.choosed, new DialogInterface.OnMultiChoiceClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveMultipleConfirmEventHandler.3
                @Override // android.content.DialogInterface.OnMultiChoiceClickListener
                public void onClick(DialogInterface dialog2, int whichItem, boolean isChecked) {
                    AndroidRemoveMultipleConfirmEventHandler.this.choosed[whichItem] = isChecked;
                }
            }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveMultipleConfirmEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog2, int whichButton) {
                    AndroidRemoveMultipleConfirmEventHandler.this.showMultiChooseConfirm();
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveMultipleConfirmEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog2, int whichButton) {
                }
            }).create();
            if (JbedConfig.Ams.isUsingSpecialIcon()) {
                dialog.setIcon(R.drawable.common_icon_info);
            }
            dialog.show();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void showMultiChooseConfirm() {
            String msg = this.mContext.getString(R.string.PRJ_DELETE_MULTI_MIDLETS);
            boolean checkjadproperity = true;
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
                    msg = this.suites[i].mData.mName + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + msg + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    String mgrUserDeniedbyJAD = this.suites[i].mData.getMgrUserDenied();
                    if (mgrUserDeniedbyJAD != null && mgrUserDeniedbyJAD.equals("delete")) {
                        checkjadproperity = false;
                        msg = this.suites[i].mData.mName + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "is not allowed to be delete by JAD";
                    }
                }
            }
            if (!checkjadproperity) {
                AlertDialog confirmDialogbyJAD = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_DELETE)).setMessage(msg).setNegativeButton(android.R.string.no, defaultDismissListener).create();
                if (JbedConfig.Ams.isUsingSpecialIcon()) {
                    confirmDialogbyJAD.setIcon(R.drawable.common_icon_info);
                }
                confirmDialogbyJAD.show();
                return;
            }
            AlertDialog confirmDialog = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_DELETE)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveMultipleConfirmEventHandler.4
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    for (int i2 = 0; i2 < AndroidRemoveMultipleConfirmEventHandler.this.choosed.length; i2++) {
                        if (AndroidRemoveMultipleConfirmEventHandler.this.choosed[i2]) {
                            ((AmsClient) AndroidRemoveMultipleConfirmEventHandler.this.mClient).requestRemoveEvent(AndroidRemoveMultipleConfirmEventHandler.this.suites[i2].mData.mRoot);
                        }
                    }
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).create();
            if (JbedConfig.Ams.isUsingSpecialIcon()) {
                confirmDialog.setIcon(R.drawable.common_icon_info);
            }
            confirmDialog.show();
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
    }

    public static class AndroidRemoveConfirmEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String msg = null;
            if (7 == this.mEvent.mResult) {
                JbedSelectorData data = (JbedSelectorData) this.mEvent.mObj;
                String msg2 = this.mContext.getString(R.string.AMS_CONFIRM_REMOVE, data.getNameText());
                if (data.isSuite()) {
                    msg2 = msg2 + this.mContext.getString(R.string.AMS_THIS_SUITE_CONTAINS);
                    Iterator<JbedSelectorData> it = data.mChildren.iterator();
                    while (it.hasNext()) {
                        msg2 = msg2 + it.next().getNameText() + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    }
                }
                msg = msg2 + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + this.mContext.getString(R.string.AMS_REMOVING_WILL_ERASE_DATA);
                if (JbedConfig.getCustomerName().equals("LGE") && data.mIsExpired) {
                    msg = data.mDrmMethodType == 3 ? this.mContext.getString(R.string.PRJ_DELETE) : this.mContext.getString(R.string.PRJ_DRM_DELETE_POPUP_STR);
                }
                if (data.getDeleteConfirmText() != null) {
                    msg = data.getDeleteConfirmText();
                }
            } else if (26 == this.mEvent.mResult) {
                List<JbedSelectorData> midlets = (List) this.mEvent.mObj;
                String msg3 = this.mContext.getString(R.string.AMS_CONFIRM_REMOVE_ALL);
                for (JbedSelectorData child : midlets) {
                    if (child.isSuite()) {
                        msg3 = msg3 + child.getNameText() + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    }
                }
                msg = msg3 + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + this.mContext.getString(R.string.AMS_REMOVING_WILL_ERASE_DATA);
            }
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveConfirmEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    boolean isSuccess = AndroidRemoveConfirmEventHandler.this.mEvent.mResult == 7 ? AndroidRemoveConfirmEventHandler.this.remove() : AndroidRemoveConfirmEventHandler.this.removeAll();
                    if (isSuccess) {
                        AndroidRemoveConfirmEventHandler.this.mHandler.obtainMessage(10010).sendToTarget();
                    }
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidRemoveConfirmEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    dialog.dismiss();
                    if (JbedConfig.getCustomerName().equals("LGE") && AndroidRemoveConfirmEventHandler.this.mEvent.mResult == 7) {
                        AndroidRemoveConfirmEventHandler.this.mHandler.obtainMessage(10002).sendToTarget();
                    }
                }
            }).show();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean remove() {
            if (((AmsClient) this.mClient).isRuningSuite(this.mEvent.getDataAsUtf8())) {
                String msg = this.mContext.getString(R.string.AMS_EXIT_MIDLET_BEFORE_REMOVE, this.mClient.findSuite(this.mEvent.getDataAsUtf8()).mName);
                showError(msg);
                return false;
            }
            ((AmsClient) this.mClient).requestRemoveEvent(this.mEvent.getDataAsUtf8());
            return true;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean removeAll() {
            List<JbedSelectorData> runningMidlets = ((AmsClient) this.mClient).getRunningMidletList();
            if (runningMidlets.size() > 0) {
                String nameList = "";
                for (JbedSelectorData midlet : runningMidlets) {
                    nameList = nameList + this.mClient.findMidlet(midlet.mRoot, midlet.mNo).mName + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                }
                String msg = this.mContext.getString(R.string.AMS_EXIT_MIDLET_BEFORE_REMOVE, nameList);
                showError(msg);
                return false;
            }
            ((AmsClient) this.mClient).requestRemoveAllEvent();
            return true;
        }
    }

    public static class RemoveEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String msg;
            switch (this.mEvent.mResult) {
                case 1:
                    msg = this.mContext.getString(R.string.AMS_REMOVE_SUCCESS);
                    break;
                case 8:
                    msg = this.mContext.getString(R.string.PRJ_ERROR_MIDLET_REMOVE_NOT_FOUND);
                    break;
                case 15:
                    msg = this.mContext.getString(R.string.PRJ_ERROR_MIDLET_REMOVE_FAIL);
                    break;
                case 21:
                    throw new IllegalStateException("RemoveEventHandler RES_RUNNING_MIDLETS should be process at requestRemove()!");
                default:
                    throw new IllegalStateException("RemoveEventHandler unknown result value");
            }
            this.mHandler.obtainMessage(10011).sendToTarget();
            if (JbedConfig.Ams.isShowToastEnabled()) {
                showToast(msg);
            } else {
                showInfo(msg);
            }
        }
    }

    public static class RemoveAllEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            switch (this.mEvent.mResult) {
                case 1:
                    this.mHandler.obtainMessage(10011).sendToTarget();
                    showInfo(this.mContext.getString(R.string.AMS_REMOVE_ALL_SUCCESS));
                    return;
                case 21:
                    throw new IllegalStateException("RemoveAllEventHandler RES_RUNNING_MIDLETS should be process at requestRemove()!");
                default:
                    throw new IllegalStateException("RemoveAllEventHandler unknown result value");
            }
        }
    }

    public static class AndroidMidletStartupErrorHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            final JbedSelectorData suite = this.mClient.findSuite(this.mEvent.getDataAsUtf8());
            if (suite != null && suite.isDamaged()) {
                String msg = this.mContext.getString(R.string.PRJ_CONFIRM_DELETE_NO_EXIST_MIDLET, suite.mName);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidMidletStartupErrorHandler.1
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface arg0, int arg1) {
                        ((AmsClient) AndroidMidletStartupErrorHandler.this.mClient).requestRemoveEvent(suite.mRoot);
                    }
                }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
            } else {
                Toast.makeText(this.mContext, (String) this.mEvent.mObj, 0).show();
            }
        }
    }

    public static class InfoEventHandler extends AmsEventHandler {
        public static final String DELIMITER = " : ";
        StringBuffer mInfo = new StringBuffer();
        DateFormat dateFormat = DateFormat.getDateTimeInstance(1, 1, Locale.getDefault());

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            String signer;
            if (data != null) {
                DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
                String isTrusted = null;
                String id = "";
                int numMidlets = 0;
                StringBuffer drmProtectionInfo = new StringBuffer();
                while (in.available() > 0) {
                    String token = readJbedString(in);
                    if ("trusted".equals(token)) {
                        isTrusted = readJbedString(in);
                        if ("false".equals(isTrusted)) {
                            this.mInfo.append(this.mContext.getString(R.string.AMS_UNTRUSTED_DOMAIN));
                        } else if ("true".equals(isTrusted)) {
                            this.mInfo.append(this.mContext.getString(R.string.AMS_TRUSTED_DOMAIN));
                        } else {
                            Log.e("AmsEventHandler", "unknown if trusted");
                        }
                        this.mInfo.append(" : ");
                    } else if (JbedProvider.Midlets.DOMAIN.equals(token)) {
                        this.mInfo.append(readJbedString(in)).append(ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER);
                    } else if (JbedProvider.Midlets.NAME.equals(token)) {
                        this.mInfo.append(this.mContext.getString(R.string.AMS_CONTENTS)).append(" : ");
                        this.mInfo.append(readJbedString(in)).append(ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER);
                    } else if ("id".equals(token)) {
                        id = readJbedString(in);
                    } else if ("signer".equals(token)) {
                        if ("true".equals(isTrusted)) {
                            this.mInfo.append(this.mContext.getString(R.string.PRJ_SIGNER)).append(" : ");
                            String signerString = readJbedString(in);
                            int start = signerString.indexOf("O=");
                            if (start == -1) {
                                start = signerString.indexOf("OU=");
                            }
                            if (start == -1) {
                                start = signerString.indexOf("CN=");
                            }
                            if (start == -1) {
                                Log.w("AmsEventHandler", "InfoEventHandler can not find signer");
                            }
                            int end = signerString.indexOf(";", start);
                            if (end == -1) {
                                signer = signerString.substring(start);
                            } else {
                                signer = signerString.substring(start, end);
                            }
                            if (signer != null) {
                                this.mInfo.append(signer.substring(signer.indexOf("=") + 1)).append(ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER);
                            }
                        }
                    } else if ("drmProtected".equals(token)) {
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_PROTECT)).append(" : ");
                        } else {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_PROTECTED)).append(" : ");
                        }
                        String isDrmProtected = readJbedString(in);
                        if ("true".equals(isDrmProtected)) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.AMS_YES_COMMAND_SHORT)).append('\n');
                        } else if ("false".equals(isDrmProtected)) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.AMS_NO_COMMAND_SHORT)).append('\n');
                        } else {
                            Log.e("AmsEventHandler", "unknown whether drm protected");
                        }
                    } else if ("drmIsForwardLocked".equals(token)) {
                        drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_FORWARD_LOCK)).append(" : ");
                        String isDrmProtected2 = readJbedString(in);
                        if ("false".equals(isDrmProtected2)) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.AMS_YES_COMMAND_SHORT)).append('\n');
                        } else if ("true".equals(isDrmProtected2)) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.AMS_NO_COMMAND_SHORT)).append('\n');
                        } else {
                            Log.e("AmsEventHandler", "unknown whether forward lock");
                        }
                    } else if ("drmConstraintCount".equals(token)) {
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_USES_LEFT)).append(" : ");
                        } else {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_COUNT)).append(" : ");
                        }
                        drmProtectionInfo.append(readJbedString(in)).append('\n');
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_VALID_FOR)).append(" : ");
                            drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_INFO_UNKNOWN)).append('\n');
                        }
                    } else if ("drmConstraintStartDate".equals(token)) {
                        drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_START_DATE)).append(" : ");
                        String startDate = readJbedString(in);
                        Date date = new Date(new Long(startDate).longValue());
                        drmProtectionInfo.append("  ").append(this.dateFormat.format(date)).append('\n');
                    } else if ("drmConstraintEndDate".equals(token)) {
                        String endDate = readJbedString(in);
                        Date date2 = new Date(new Long(endDate).longValue());
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            long currentMills = System.currentTimeMillis();
                            long endMills = new Long(endDate).longValue();
                            long remainedMills = endMills - currentMills;
                            LogTag.amsDebug("AmsEventHandler", "InfoEventHandler remainedMills:" + remainedMills);
                            if (remainedMills > 0) {
                                String drmDateTimeStr = convertDrmDateTime(remainedMills);
                                LogTag.amsDebug("AmsEventHandler", "InfoEventHandler drmDateTimeStr:" + drmDateTimeStr);
                                drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_VALID_FOR)).append(" : ");
                                drmProtectionInfo.append("  ").append(drmDateTimeStr).append('\n');
                            }
                        } else {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_CONSTRAINT_END_DATE)).append(" : ");
                            drmProtectionInfo.append("  ").append(this.dateFormat.format(date2)).append('\n');
                        }
                    } else if ("drmExpired".equals(token)) {
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            String isDrmExpired = readJbedString(in);
                            if ("true".equals(isDrmExpired)) {
                                drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_VALID_FOR)).append(" : ");
                                drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_INFO_UNKNOWN)).append('\n');
                                drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_USES_LEFT)).append(" : ");
                                drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_INFO_UNKNOWN)).append('\n');
                            }
                        }
                    } else if (JbedSelectorData.KEY_MIDLET_VENDOR.equals(token)) {
                        String vendor = readJbedString(in);
                        this.mInfo.append(this.mContext.getString(R.string.AMS_VENDOR)).append(" : ").append(vendor).append('\n');
                    } else if (JbedSelectorData.KEY_MIDLET_VERSION.equals(token)) {
                        String version = readJbedString(in);
                        this.mInfo.append(this.mContext.getString(R.string.AMS_VERSION)).append(" : ").append(version).append('\n');
                    } else if (JbedSelectorData.KEY_CLDC.equals(token)) {
                        String versionOfCLDC = readJbedString(in);
                        this.mInfo.append(JbedSelectorData.KEY_CLDC).append(" : ").append(versionOfCLDC).append('\n');
                    } else if (JbedSelectorData.KEY_MDIP.equals(token)) {
                        String versionOfMIDP = readJbedString(in);
                        this.mInfo.append(JbedSelectorData.KEY_MDIP).append(" : ").append(versionOfMIDP).append('\n');
                    } else if ("numMidlets".equals(token)) {
                        String numMidlets_str = readJbedString(in);
                        numMidlets = Integer.parseInt(numMidlets_str);
                    } else if ("drmConstraintInterval".equals(token) && JbedConfig.getCustomerName().equals("LGE")) {
                        String intervalStr = readJbedString(in);
                        long interval = new Long(intervalStr).longValue();
                        if (interval == -1) {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_USES_LEFT)).append(" : ");
                            drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_UNLIMITED)).append('\n');
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_VALID_FOR)).append(" : ");
                            drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_UNLIMITED)).append('\n');
                        } else {
                            drmProtectionInfo.append(this.mContext.getString(R.string.PRJ_DRM_USES_LEFT)).append(" : ");
                            drmProtectionInfo.append("  ").append(this.mContext.getString(R.string.PRJ_DRM_INFO_UNKNOWN)).append('\n');
                        }
                    }
                    for (int i = 1; i <= numMidlets; i++) {
                        String midletstr = "MIDlet-" + i;
                        if (midletstr.equals(token)) {
                            String midletNInfro = readJbedString(in);
                            this.mInfo.append(midletstr).append(" : ").append(midletNInfro).append('\n');
                        }
                    }
                }
                JbedSelectorData suite = this.mClient.findSuite(id);
                if (suite == null) {
                    throw new IllegalStateException("can't find the suite " + id + "! but it is in the suite deaitls");
                }
                this.mInfo.append(this.mContext.getString(R.string.AMS_SIZE)).append(" : ");
                this.mInfo.append(suite.getSizeText(this.mContext)).append('\n');
                this.mInfo.append(drmProtectionInfo);
                this.mInfo.append(this.mContext.getString(R.string.PRJ_INSTALL_LOCATION)).append(" : ");
                if (JbedSelectorData.KEY_STORAGE_PHONE_NAME.equals(suite.getSimpleStorageName())) {
                    this.mInfo.append(this.mContext.getString(R.string.AMS_PHONE_STORAGE_NAME)).append('\n');
                } else {
                    this.mInfo.append(suite.getSimpleStorageName()).append('\n');
                }
            }
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (JbedConfig.Menu.isReconfigEnable()) {
                showDialg(R.string.AMS_INFO_COMMAND_SHORT, this.mInfo.toString());
            } else {
                showInfo(this.mInfo.toString());
            }
        }

        private String convertDrmDateTime(long remainedMills) {
            StringBuffer drmDateTimeStr = new StringBuffer("");
            if (remainedMills < 0) {
                return drmDateTimeStr.toString();
            }
            int remainedSec = new Long(remainedMills / 1000).intValue();
            int second = remainedSec % 60;
            int minute = (remainedSec / 60) % 60;
            int hour = (remainedSec / 3600) % 24;
            int day = remainedSec / 86400;
            LogTag.amsDebug("AmsEventHandler", "convertDrmDateTime<" + day + ":" + hour + ":" + minute + ":" + second + ">");
            if (day != 0) {
                drmDateTimeStr.append(day).append("  ");
                drmDateTimeStr.append(this.mContext.getString(R.string.AMS_DAYS)).append("  ");
            }
            if (hour != 0) {
                drmDateTimeStr.append(hour).append("  ");
                drmDateTimeStr.append(this.mContext.getString(R.string.AMS_HOURS)).append("  ");
            }
            if (minute != 0) {
                drmDateTimeStr.append(minute).append("  ");
                drmDateTimeStr.append(this.mContext.getString(R.string.AMS_MINUTES)).append("  ");
            }
            drmDateTimeStr.append(second).append("  ");
            drmDateTimeStr.append(this.mContext.getString(R.string.AMS_SECONDS));
            return drmDateTimeStr.toString();
        }
    }

    public static class AndroidListLocallInstallEventHandler extends AmsEventHandler {
        static boolean mFileCollected = false;
        static boolean mThreadIsRunning = false;
        private static List<FileEntry> mLocalInsallFiles = Lists.newArrayList();
        boolean mIsOnlySdcard = false;
        private final boolean isCompressJarFile = true;
        private final String[] excludeFolders = JbedConfig.getExcludeSearchFolder().split(":");

        /* JADX INFO: Access modifiers changed from: private */
        public void collectLocalInstallFiles() {
            if (!this.mIsOnlySdcard) {
                File dir = new File(JbedSettings.getInstance(this.mContext).getLocalInstallDir());
                findAllMidlets(dir);
            }
            JbedFileManager manager = new JbedFileManager(this.mContext, null);
            List<String> roots = manager.getRootPathList();
            for (int i = 0; i < roots.size(); i++) {
                File dir2 = new File(roots.get(i));
                findAllMidlets(dir2);
            }
            Collections.sort(mLocalInsallFiles, FileEntry.FILE_COMPARATOR);
            compressJarFiles();
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void showSubDialog(final String fileUri, final AlertDialog dialog) {
            String s1 = this.mContext.getString(R.string.AMS_INSTALL_FORM_COMMAND);
            String s2 = this.mContext.getString(R.string.AMS_REMOVE_COMMAND_SHORT);
            String[] ss = {s1, s2};
            AlertDialog subDialog = new AlertDialog.Builder(getContext()).setItems(ss, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog2, int pos) {
                    switch (pos) {
                        case 0:
                            ((AmsClient) AndroidListLocallInstallEventHandler.this.mClient).requestInstallEvent(fileUri);
                            break;
                        case 1:
                            String uri = fileUri.substring("file:///".length());
                            String jadString = uri.substring(0, uri.length() - AmsConstants.JAD_EXTEND_NAME.length()) + AmsConstants.JAD_EXTEND_NAME;
                            String jarString = uri.substring(0, uri.length() - AmsConstants.JAR_EXTEND_NAME.length()) + AmsConstants.JAR_EXTEND_NAME;
                            final File jadFile = new File(jadString);
                            final File jarFile = new File(jarString);
                            String msg = AndroidListLocallInstallEventHandler.this.mContext.getString(R.string.PRJ_DELETE_MULTI_MIDLETS);
                            if (jarFile.exists()) {
                                msg = jarFile + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + msg;
                            }
                            if (jadFile.exists()) {
                                msg = jadFile + ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + msg;
                            }
                            AlertDialog confirmDialog = new AlertDialog.Builder(AndroidListLocallInstallEventHandler.this.getContext()).setTitle(AndroidListLocallInstallEventHandler.this.mContext.getString(R.string.PRJ_DELETE)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.1.1
                                @Override // android.content.DialogInterface.OnClickListener
                                public void onClick(DialogInterface dialog3, int whichButton) {
                                    jadFile.delete();
                                    jarFile.delete();
                                }
                            }).setNegativeButton(android.R.string.no, AmsEventHandler.defaultDismissListener).create();
                            confirmDialog.show();
                            break;
                    }
                }
            }).create();
            subDialog.setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.2
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface d) {
                    dialog.show();
                }
            });
            subDialog.show();
        }

        /* JADX WARN: Type inference failed for: r1v22, types: [com.esmertec.android.jbed.ams.BasicEventHandler$AndroidListLocallInstallEventHandler$3] */
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.mIsOnlySdcard = ((Boolean) this.mEvent.mObj).booleanValue();
            if (!mThreadIsRunning) {
                if (!mFileCollected) {
                    processMessageImmediately(this.mHandler.obtainMessage(10012));
                    mLocalInsallFiles.clear();
                    new Thread() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.3
                        @Override // java.lang.Thread, java.lang.Runnable
                        public void run() {
                            AndroidListLocallInstallEventHandler.mThreadIsRunning = true;
                            AndroidListLocallInstallEventHandler.mFileCollected = true;
                            AndroidListLocallInstallEventHandler.this.collectLocalInstallFiles();
                            AndroidListLocallInstallEventHandler.mThreadIsRunning = false;
                            ((AmsClient) AndroidListLocallInstallEventHandler.this.mClient).requestListLocalInstall(AndroidListLocallInstallEventHandler.this.mIsOnlySdcard);
                        }
                    }.start();
                    return;
                }
                mFileCollected = false;
                processMessageImmediately(this.mHandler.obtainMessage(10013));
                if (mLocalInsallFiles.isEmpty()) {
                    showInfo(R.string.AMS_NO_FILES_FOUND);
                    return;
                }
                final AlertDialog dialog = new AlertDialog.Builder(getContext()).setTitle(R.string.AMS_LOCAL_FILES_INSTALLED).setItems((CharSequence[]) mLocalInsallFiles.toArray(new CharSequence[mLocalInsallFiles.size()]), new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.4
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog2, int pos) {
                        String fileUri = "file:///" + ((FileEntry) AndroidListLocallInstallEventHandler.mLocalInsallFiles.get(pos)).mPath;
                        ((AmsClient) AndroidListLocallInstallEventHandler.this.mClient).requestInstallEvent(fileUri);
                        dialog2.dismiss();
                    }
                }).create();
                dialog.show();
                if (this.mIsOnlySdcard) {
                    dialog.getListView().setOnItemLongClickListener(new AdapterView.OnItemLongClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.5
                        @Override // android.widget.AdapterView.OnItemLongClickListener
                        public boolean onItemLongClick(AdapterView<?> arg0, View arg1, int arg2, long arg3) {
                            dialog.dismiss();
                            String fileUri = "file:///" + ((FileEntry) AndroidListLocallInstallEventHandler.mLocalInsallFiles.get(arg2)).mPath;
                            AndroidListLocallInstallEventHandler.this.showSubDialog(fileUri, dialog);
                            return false;
                        }
                    });
                }
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public void findAllMidlets(File root) {
            if (this.excludeFolders[0] != "") {
                for (int i = 0; i < this.excludeFolders.length; i++) {
                    if (this.excludeFolders[i].equals(root.getPath())) {
                        return;
                    }
                }
            }
            File[] files = root.listFiles(new FileFilter() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.6
                @Override // java.io.FileFilter
                public boolean accept(File f) {
                    if (f.isDirectory()) {
                        AndroidListLocallInstallEventHandler.this.findAllMidlets(f);
                        return false;
                    }
                    String[] arr$ = AmsConstants.SUPPORTED_EXT_NAMES;
                    for (String extname : arr$) {
                        if (f.getName().endsWith(extname)) {
                            return true;
                        }
                    }
                    return false;
                }
            });
            if (files != null) {
                for (int i2 = 0; i2 < files.length; i2++) {
                    LogTag.amsDebug("AmsEventHandler", "Add a midlet file " + files[i2].getPath());
                    mLocalInsallFiles.add(new FileEntry(files[i2]));
                }
            }
        }

        private static class FileEntry implements CharSequence {
            private static Comparator<FileEntry> FILE_COMPARATOR = new Comparator<FileEntry>() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidListLocallInstallEventHandler.FileEntry.1
                @Override // java.util.Comparator
                public int compare(FileEntry o1, FileEntry o2) {
                    return o1.mPath.compareToIgnoreCase(o2.mPath);
                }
            };
            String mExtendName;
            String mName;
            String mPath;
            String mRawName;

            FileEntry(File file) {
                this.mName = file.getName();
                this.mPath = file.getPath();
                this.mExtendName = this.mName.substring(this.mName.lastIndexOf(46));
                this.mRawName = this.mPath.substring(0, this.mPath.lastIndexOf(46));
            }

            @Override // java.lang.CharSequence
            public char charAt(int index) {
                return this.mName.charAt(index);
            }

            @Override // java.lang.CharSequence
            public int length() {
                return this.mName.length();
            }

            @Override // java.lang.CharSequence
            public CharSequence subSequence(int start, int end) {
                return this.mName.subSequence(start, end);
            }

            @Override // java.lang.CharSequence
            public String toString() {
                return this.mName.substring(0, this.mName.lastIndexOf(46));
            }
        }

        private void compressJarFiles() {
            int size = mLocalInsallFiles.size();
            for (int i = size - 1; i >= 0; i--) {
                FileEntry fileEntry = mLocalInsallFiles.get(i);
                if (fileEntry.mExtendName.equalsIgnoreCase(AmsConstants.JAR_EXTEND_NAME) || fileEntry.mExtendName.equalsIgnoreCase(".dm") || fileEntry.mExtendName.equalsIgnoreCase(AmsConstants.DCF_EXTEND_NAME)) {
                    for (FileEntry e : mLocalInsallFiles) {
                        if (e.mPath.equals(fileEntry.mRawName + AmsConstants.JAD_EXTEND_NAME)) {
                            mLocalInsallFiles.remove(fileEntry);
                            break;
                        }
                    }
                }
            }
        }
    }

    public static class AndroidShowAboutEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String mVersion = "Build ID: " + JbedConfig.getBuildVersion() + "\n\n";
            try {
                int version_ID = Class.forName("com.esmertec.android.jbed.R$string").getField("ap_version_id").getInt(null);
                mVersion = this.mContext.getString(R.string.AMS_VERSION) + " " + this.mContext.getString(version_ID) + "\n\n";
            } catch (Exception e) {
            }
            String mAboutMsg = mVersion + this.mContext.getString(R.string.AMS_AMS_COPYRIGHT);
            showDialg(R.string.AMS_ABOUT_TITLE, mAboutMsg);
        }
    }

    public static class AndroidShowAlertEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            switch (this.mEvent.mResult) {
                case 0:
                    showInfo((String) this.mEvent.mObj);
                    return;
                case 1:
                    showWarning((String) this.mEvent.mObj);
                    return;
                case 2:
                    showError((String) this.mEvent.mObj);
                    return;
                default:
                    throw new IllegalArgumentException("AndroidShowAlertEventHandler unkonwn type " + this.mEvent.mResult);
            }
        }
    }

    public static class AndroidLaunchBrowserHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            Intent intent;
            if (this.mEvent.mData != null) {
                String url = new String(this.mEvent.mData);
                intent = new Intent("android.intent.action.VIEW", Uri.parse(url));
            } else {
                intent = new Intent("android.intent.action.MAIN");
            }
            intent.setFlags(335544320);
            intent.setClassName("com.android.browser", "com.android.browser.BrowserActivity");
            this.mContext.startActivity(intent);
        }
    }

    public static class RunningMidletManagerEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            Intent taskManagerIntent = new Intent(this.mContext, (Class<?>) RunningMidletManagerActivity.class);
            ((Activity) this.mContext).startActivityForResult(taskManagerIntent, 0);
        }
    }

    public static class RuntimeErrorEventHandler extends AmsEventHandler {
        private String mMessage;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in RUNTIME_ERROR event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            JbedSelectorData midlet = this.mClient.findMidlet(readJbedString(in), in.readInt());
            this.mMessage = readJbedString(in);
            this.mMessage = midlet.mName + " : " + this.mMessage;
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            Toast.makeText(this.mContext, this.mMessage, 0).show();
        }
    }

    public static class SelectStorageEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.mHandler.obtainMessage(AmsConstants.HANDLE_GET_INSTALLED_STORAGE).sendToTarget();
        }
    }

    public static class StorageSettingEventHandler extends AmsEventHandler {
        int selected;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            List<String> storages = new ArrayList<>();
            storages.add(this.mContext.getString(R.string.AMS_PHONE_STORAGE_NAME));
            if (JbedFileManager.isExternalStorageReady()) {
                storages.add(this.mContext.getString(R.string.PRJ_EXTERNAL_STORAGE_SDCARD));
            }
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_STORAGE_SETTING)).setSingleChoiceItems((CharSequence[]) storages.toArray(new String[storages.size()]), Math.min(this.mEvent.mResult, storages.size() - 1), new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.StorageSettingEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                    StorageSettingEventHandler.this.selected = which;
                }
            }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.StorageSettingEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    StorageSettingEventHandler.this.mHandler.obtainMessage(AmsConstants.HANDLE_STORAGE_SETTING, StorageSettingEventHandler.this.selected, -1).sendToTarget();
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
        }
    }

    public static class SortSettingEventHandler extends AmsEventHandler {
        private int[] menuIdlist = {R.id.sort_by_name_menu_item, R.id.sort_by_size_menu_item, R.id.sort_by_time_menu_item};
        int orderId;
        int selected;

        private int getMenuIndex(int menuId) {
            int i = 0;
            while (i < this.menuIdlist.length && menuId != this.menuIdlist[i]) {
                i++;
            }
            return i;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public int getMenuId(int idx) {
            return (idx < 0 || idx >= this.menuIdlist.length) ? this.menuIdlist[0] : this.menuIdlist[idx];
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            List<String> sortList = new ArrayList<>();
            sortList.add(this.mContext.getString(R.string.PRJ_SORT_BY_NAME));
            sortList.add(this.mContext.getString(R.string.PRJ_SORT_BY_SIZE));
            sortList.add(this.mContext.getString(R.string.PRJ_SORT_BY_TIME));
            LogTag.amsDebug("AmsEventHandler", "SortSettingEventHandler mEvent.mResult:" + this.mEvent.mResult);
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_SORT)).setSingleChoiceItems((CharSequence[]) sortList.toArray(new String[sortList.size()]), Math.min(getMenuIndex(this.mEvent.mResult), sortList.size() - 1), new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SortSettingEventHandler.3
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                    SortSettingEventHandler.this.selected = which;
                }
            }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SortSettingEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    SortSettingEventHandler.this.orderId = SortSettingEventHandler.this.getMenuId(SortSettingEventHandler.this.selected);
                    LogTag.amsDebug("AmsEventHandler", "SortSettingEventHandler selected:" + SortSettingEventHandler.this.selected + " ,orderId:" + SortSettingEventHandler.this.orderId);
                    SortSettingEventHandler.this.mHandler.obtainMessage(AmsConstants.HANDLE_REFRESH_LIST_WITH_SORT_ORDER, SortSettingEventHandler.this.orderId, 0).sendToTarget();
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SortSettingEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int which) {
                    dialog.dismiss();
                }
            }).show();
        }
    }

    public static class SuiteRenameInputEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LogTag.amsDebug("AmsEventHandler", "SuiteNameInputEventHandler");
            LayoutInflater mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
            View v = mInflater.inflate(R.layout.name_input_dialog, (ViewGroup) null);
            final EditText edtText = (EditText) v.findViewById(R.id.edtName);
            final String oldName = ((JbedSelectorData) this.mEvent.mObj).mName;
            edtText.setText(oldName);
            new AlertDialog.Builder(getContext()).setTitle(R.string.AMS_ENTER_NEW_NAME).setView(v).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SuiteRenameInputEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    String newName = edtText.getText().toString().trim();
                    if (newName.length() != 0 && !oldName.equals(newName)) {
                        ((AmsClient) SuiteRenameInputEventHandler.this.mClient).requestRenameSuite((JbedSelectorData) SuiteRenameInputEventHandler.this.mEvent.mObj, newName);
                    }
                }
            }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
            if (JbedConfig.getToggleSoftInputDelay() != 0) {
                Timer timer = new Timer();
                timer.schedule(new TimerTask() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SuiteRenameInputEventHandler.2
                    @Override // java.util.TimerTask, java.lang.Runnable
                    public void run() {
                        InputMethodManager imm = (InputMethodManager) SuiteRenameInputEventHandler.this.mContext.getSystemService("input_method");
                        imm.toggleSoftInput(0, 2);
                    }
                }, JbedConfig.getToggleSoftInputDelay());
            }
        }
    }

    public static class ListCertificatesEventHandler extends AmsEventHandler {
        private LayoutInflater mInflater;
        private List<String> certificateInfos = Lists.newArrayList();
        private List<String> shortsubjects = Lists.newArrayList();
        private List<String> subjects = Lists.newArrayList();
        private List<String> issuers = Lists.newArrayList();
        private List<String> duedates = Lists.newArrayList();
        private List<String> fingerprints = Lists.newArrayList();
        private final char INDEX_SHORT_SUBJECT = 0;
        private final char INDEX_SUBJECT = 1;
        private final char INDEX_ISSUER = 2;
        private final char INDEX_NOTBEFORE = 3;
        private final char INDEX_NOTAFTER = 4;
        private final char INDEX_FINGERPRINT = 5;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        protected void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in SelectStorageEventHandler event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            int len = in.readInt();
            for (int i = 0; i < len; i++) {
                String certificateInfo = readJbedString(in);
                int start = certificateInfo.indexOf("CN=");
                if (start == -1) {
                    start = certificateInfo.indexOf("OU=");
                }
                if (start == -1) {
                    start = certificateInfo.indexOf("O=");
                }
                if (start == -1) {
                    LogTag.amsWarning("AmsEventHandler", "ListCertificatesEventHandler can not find infomation");
                }
                String certificateInfo2 = certificateInfo.substring(start);
                this.certificateInfos.add(certificateInfo2.substring(certificateInfo2.indexOf("=") + 1));
            }
            Collections.sort(this.certificateInfos, String.CASE_INSENSITIVE_ORDER);
            for (int i2 = 0; i2 < len; i2++) {
                String[] lines = this.certificateInfos.get(i2).split("\r\n");
                int end = lines[0].indexOf(";");
                if (end != -1) {
                    lines[0] = lines[0].substring(0, end);
                }
                this.shortsubjects.add("   " + lines[0]);
                if (JbedConfig.Menu.isReconfigEnable()) {
                    this.subjects.add(lines[1]);
                    this.issuers.add(lines[2]);
                    Date notbeforeDate = new Date(new Long(lines[3]).longValue());
                    Date notafterDate = new Date(new Long(lines[4]).longValue());
                    this.duedates.add((notbeforeDate.getYear() + 1900) + "." + notbeforeDate.getMonth() + "." + notbeforeDate.getDay() + "-" + (notafterDate.getYear() + 1900) + "." + notafterDate.getMonth() + "." + notafterDate.getDay());
                    this.fingerprints.add(lines[5]);
                }
            }
            this.mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            View view = this.mInflater.inflate(R.layout.list_content, (ViewGroup) null);
            ListView listView = (ListView) view.findViewById(R.id.listview);
            CertificatesItemAdapter certificatesitemadapter = new CertificatesItemAdapter(this.shortsubjects);
            listView.setAdapter((ListAdapter) certificatesitemadapter);
            listView.setOnItemClickListener(certificatesitemadapter);
            AlertDialog dialog = new AlertDialog.Builder(getContext()).setView(listView).setTitle(this.mContext.getString(R.string.AMS_MANAGE_CERTIFICATES_TITLE)).setPositiveButton(android.R.string.ok, defaultDismissListener).create();
            dialog.show();
        }

        public class CertificatesItemAdapter extends ArrayAdapter<String> implements AdapterView.OnItemClickListener {
            public static final String DELIMITER = "\n";

            private CertificatesItemAdapter(List<String> subjects) {
                super(ListCertificatesEventHandler.this.mContext, -1, subjects);
            }

            @Override // android.widget.ArrayAdapter, android.widget.Adapter
            public View getView(int position, View convertView, ViewGroup parent) {
                View view = ListCertificatesEventHandler.this.mInflater.inflate(R.layout.simple_gallery_item, (ViewGroup) null);
                TextView text = (TextView) view.findViewById(R.id.textview);
                text.setText((CharSequence) ListCertificatesEventHandler.this.shortsubjects.get(position));
                if (JbedConfig.Menu.isReconfigEnable()) {
                    text.setLayoutParams(new AbsListView.LayoutParams(-1, 64));
                    text.setGravity(16);
                }
                return view;
            }

            @Override // android.widget.AdapterView.OnItemClickListener
            public void onItemClick(AdapterView parent, View view, int position, long id) {
                if (JbedConfig.Menu.isReconfigEnable()) {
                    StringBuffer mInfo = new StringBuffer();
                    mInfo.append("Issuer").append(DELIMITER).append((String) ListCertificatesEventHandler.this.issuers.get(position)).append("\n\n").append("Subject").append(DELIMITER).append((String) ListCertificatesEventHandler.this.subjects.get(position)).append("\n\n").append("Due Date").append(DELIMITER).append((String) ListCertificatesEventHandler.this.duedates.get(position)).append("\n\n").append("Fingerprint").append(DELIMITER).append((String) ListCertificatesEventHandler.this.fingerprints.get(position)).append("\n\n");
                    new AlertDialog.Builder(getContext()).setMessage(mInfo).setNeutralButton(android.R.string.ok, AmsEventHandler.defaultDismissListener).setIcon(R.drawable.common_icon_info).setTitle(((TextView) view.findViewById(R.id.textview)).getText().subSequence(3, ((TextView) view.findViewById(R.id.textview)).getText().length())).show();
                }
            }
        }
    }

    public static class AndroidPurchaseROConfirmEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (this.mEvent.mResult == 0) {
                String msg = this.mContext.getString(R.string.PRJ_DRM_GET_LICENSE_USE1);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidPurchaseROConfirmEventHandler.1
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        AndroidPurchaseROConfirmEventHandler.this.activateDrm(((JbedSelectorData) AndroidPurchaseROConfirmEventHandler.this.mEvent.mObj).mRoot);
                    }
                }).setNegativeButton(android.R.string.no, defaultDismissListener).show();
            } else if (this.mEvent.mResult == 1) {
                String msg2 = this.mContext.getString(R.string.PRJ_DRM_GET_LICENSE_EXPIRED);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg2).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidPurchaseROConfirmEventHandler.3
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        AndroidPurchaseROConfirmEventHandler.this.activateDrm(((JbedSelectorData) AndroidPurchaseROConfirmEventHandler.this.mEvent.mObj).mRoot);
                    }
                }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidPurchaseROConfirmEventHandler.2
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        dialog.dismiss();
                        if (JbedConfig.getCustomerName().equals("LGE")) {
                            AndroidPurchaseROConfirmEventHandler.this.mHandler.obtainMessage(10002).sendToTarget();
                        }
                    }
                }).show();
            } else if (this.mEvent.mResult == 2) {
                String msg3 = this.mContext.getString(R.string.PRJ_DRM_GET_LICENSE_ALREADY_LOCKED);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg3).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidPurchaseROConfirmEventHandler.5
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        AndroidPurchaseROConfirmEventHandler.this.activateDrm(((JbedSelectorData) AndroidPurchaseROConfirmEventHandler.this.mEvent.mObj).mRoot);
                    }
                }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.AndroidPurchaseROConfirmEventHandler.4
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        ((AmsClient) AndroidPurchaseROConfirmEventHandler.this.mClient).requestRemoveConfirmEvent((JbedSelectorData) AndroidPurchaseROConfirmEventHandler.this.mEvent.mObj);
                    }
                }).show();
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public boolean activateDrm(String suiteID) {
            LogTag.amsDebug("AmsEventHandler", "AndroidPurchaseROConfirmEventHandler activateDrm suiteID:" + suiteID);
            ((AmsClient) this.mClient).requestDrmActivateEvent(suiteID);
            return true;
        }
    }

    public static class PlatformRequestHandler extends AmsEventHandler {
        public static String midletName;
        private static AlertDialog platformRequestDialog = null;
        private String url;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] data) throws IOException {
            if (data == null) {
                throw new IllegalArgumentException("pass the invalid data in REQUEST_PLATFORM_REQUEST event!!!");
            }
            DataInputStream in = new DataInputStream(new ByteArrayInputStream(data));
            midletName = readJbedString(in);
            this.url = readJbedString(in);
            in.close();
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String msg = this.mContext.getString(R.string.AMS_PLATFORM_REQUEST_ALERT_PROMPT, "'" + midletName + "'", "'" + this.url + "'");
            platformRequestDialog = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_PLATFORM_REQUEST_ALERT_TITLE)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.PlatformRequestHandler.3
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    dialog.dismiss();
                    ((AmsClient) PlatformRequestHandler.this.mClient).requestPlatformRequestAnswer(1);
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.PlatformRequestHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    dialog.dismiss();
                    ((AmsClient) PlatformRequestHandler.this.mClient).requestPlatformRequestAnswer(15);
                }
            }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.PlatformRequestHandler.1
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog) {
                    ((AmsClient) PlatformRequestHandler.this.mClient).requestPlatformRequestAnswer(15);
                }
            }).setCancelable(false).show();
        }

        public static void cancelPlatformReqeust() {
            LogTag.amsDebug("AmsEventHandler", "[PlatformRequestHandler]cancelPlatformReqeust()");
            if (platformRequestDialog != null && platformRequestDialog.isShowing()) {
                platformRequestDialog.cancel();
                platformRequestDialog = null;
            }
        }
    }

    public static class DisplaySizeHandler extends AmsEventHandler {
        private String[] displaySolutions;
        private String[] displayString;
        private int mSelected = 0;
        private int midletNo;
        private String midletRoot;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LogTag.amsDebug("AmsEventHandler", "DisplaySizeHandler");
            this.midletNo = this.mEvent.mResult;
            String displayInfo = this.mEvent.getDataAsUtf8();
            if (displayInfo != null) {
                String[] di = displayInfo.split(";");
                this.midletRoot = di[0];
                this.mSelected = Integer.parseInt(di[1]);
                this.displaySolutions = new String[2];
                this.displaySolutions[0] = "";
                this.displaySolutions[1] = di[2];
                this.displayString = new String[2];
                this.displayString[0] = this.mContext.getString(R.string.PRJ_OPTION_MENU_ORI_SIZE);
                this.displayString[1] = this.mContext.getString(R.string.PRJ_OPTION_MENU_FIT_SCREEN);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_OPTION_MENU_DISPLAY_SIZE)).setSingleChoiceItems(this.displayString, this.mSelected, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.DisplaySizeHandler.3
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int which) {
                        DisplaySizeHandler.this.mSelected = which;
                    }
                }).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.DisplaySizeHandler.2
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        ((AmsClient) DisplaySizeHandler.this.mClient).requestSetDisplaySize(DisplaySizeHandler.this.midletRoot, DisplaySizeHandler.this.midletNo, DisplaySizeHandler.this.displaySolutions[DisplaySizeHandler.this.mSelected]);
                    }
                }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.DisplaySizeHandler.1
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        dialog.dismiss();
                    }
                }).show();
            }
        }
    }

    public static class SetDisplaySizeHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LogTag.amsDebug("AmsEventHandler", "SetDisplaySizeHandler");
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_OPTION_MENU_DISPLAY_SIZE)).setMessage(this.mEvent.mResult == 1 ? this.mContext.getString(R.string.AMS_SET_SUCCESS) : this.mContext.getString(R.string.AMS_SET_ERROR)).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.BasicEventHandler.SetDisplaySizeHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                }
            }).show();
        }
    }
}
