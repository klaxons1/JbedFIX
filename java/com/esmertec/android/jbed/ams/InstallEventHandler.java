package com.esmertec.android.jbed.ams;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import com.esmertec.android.jbed.JbedConfig;
import com.esmertec.android.jbed.LogTag;
import com.esmertec.android.jbed.R;
import com.esmertec.android.jbed.util.I18N;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class InstallEventHandler {

    public static class PreinstallFolderStartEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            ((AmsClient) this.mClient).requestInstallLock();
            this.mHandler.obtainMessage(10003, true).sendToTarget();
        }
    }

    public static class PreinstallFolderFinishedEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            Log.e("AmsEventHandler", "PreinstallFolderFinishedEventHandler");
            ((AmsClient) this.mClient).releaseInstallLock();
            this.mHandler.obtainMessage(10005).sendToTarget();
        }
    }

    public static class RequestInstallEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            String url = this.mEvent.getDataAsUtf8();
            if (url == null) {
                showError(this.mContext.getString(R.string.PRJ_ERROR_INVALID_URL));
            } else {
                ((AmsClient) this.mClient).requestInstallEvent(url);
            }
        }
    }

    public static class InstallProgressEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (this.mEvent.mResult >= 0 && this.mEvent.mResult <= 100) {
                if (this.mEvent.mResult == 100) {
                    LogTag.amsDebug("AmsEventHandler", "Receive finished downloading result.");
                }
                this.mHandler.obtainMessage(10004, this.mEvent.mResult, 0).sendToTarget();
                return;
            }
            Log.e("AmsEventHandler", "Receive invalid progress is " + this.mEvent.mResult);
        }
    }

    public static class InstallStatusEventHandler extends AmsEventHandler {
        private static final int AMS_MODULE_ID = 4;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            int retId = I18N.getStringID(4, this.mEvent.mResult);
            String msg = this.mContext.getResources().getString(retId);
            if (msg != null) {
                this.mHandler.obtainMessage(10009, msg).sendToTarget();
            }
        }
    }

    public static class InstallUnStoppableEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            this.mHandler.obtainMessage(10009).sendToTarget();
        }
    }

    public static class InstallCancelEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            LogTag.amsDebug("AmsEventHandler", "handleInstallCancelEvent() with evt is " + this.mEvent.toString());
            switch (this.mEvent.mResult) {
                case 22:
                    processMessageImmediately(this.mHandler.obtainMessage(10007));
                    break;
            }
        }
    }

    public static class InstalledEventHandler extends AmsEventHandler {
        static final int DRM_INSTALL_PENDING = 95;
        static final int JAR_SERVER_NOT_FOUND = 19;
        static final int USER_CANCELLED = 74;
        JbedSelectorData suite = null;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            ((AmsClient) this.mClient).releaseInstallLock();
            this.mHandler.obtainMessage(10005).sendToTarget();
            if (this.mEvent.mResult != 0) {
                if (this.mEvent.mResult == DRM_INSTALL_PENDING) {
                    String errMsg = this.mEvent.getDataAsUtf8();
                    showWarning(errMsg);
                    return;
                } else if (this.mEvent.mResult == 19 && JbedConfig.isCustomiseNetworkErrorNotify()) {
                    String errMsg2 = this.mContext.getString(R.string.PRJ_JAR_SERVER_NOT_FOUND);
                    new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.PRJ_JAR_SERVER_NOT_FOUND_TITLE)).setMessage(errMsg2).setNeutralButton(android.R.string.ok, defaultDismissListener).show();
                    return;
                } else if (this.mEvent.mResult != 74) {
                    String errMsg3 = this.mEvent.getDataAsUtf8();
                    showError(errMsg3);
                    return;
                } else {
                    this.mHandler.obtainMessage(10002).sendToTarget();
                    return;
                }
            }
            this.mClient.refreshSelector();
            this.suite = this.mClient.findSuite(this.mEvent.getDataAsUtf8());
            if (this.suite.isAutoRun()) {
                if (AmsActivity.hasEnoughFreeMemory()) {
                    if (this.suite.getChildCount() == 1) {
                        this.mClient.requestRunEvent(this.mEvent.getDataAsUtf8(), 1);
                    } else {
                        this.mHandler.obtainMessage(10017, this.suite).sendToTarget();
                    }
                } else {
                    new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(this.mContext.getString(android.R.string.accessibility_system_action_dpad_center_label)).setPositiveButton(android.R.string.yes, (DialogInterface.OnClickListener) null).show();
                }
            } else {
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(R.string.AMS_LAUNCH_MIDLET).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstalledEventHandler.1
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog, int whichButton) {
                        if (AmsActivity.hasEnoughFreeMemory()) {
                            if (InstalledEventHandler.this.suite.getChildCount() == 1) {
                                InstalledEventHandler.this.mClient.requestRunEvent(InstalledEventHandler.this.mEvent.getDataAsUtf8(), 1);
                                return;
                            } else {
                                InstalledEventHandler.this.mHandler.obtainMessage(10017, InstalledEventHandler.this.suite).sendToTarget();
                                return;
                            }
                        }
                        new AlertDialog.Builder(InstalledEventHandler.this.getContext()).setTitle(InstalledEventHandler.this.mContext.getString(R.string.AMS_WARNING)).setMessage(InstalledEventHandler.this.mContext.getString(android.R.string.accessibility_system_action_dpad_center_label)).setPositiveButton(android.R.string.yes, (DialogInterface.OnClickListener) null).show();
                    }
                }).setNegativeButton(android.R.string.no, defaultDismissListener).setOnCancelListener(defaultCancelListener).show();
            }
            if (this.suite != null) {
                this.suite.calculateSize(true);
            }
        }
    }

    public static class InstallQueryEventHandler extends AmsEventHandler {
        private static AlertDialog timeoutDialog = null;
        private boolean mIsActioned = false;

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            FolderEventHandler.FolderListEventHandler.dismissDialog();
            String msg = this.mEvent.getDataAsUtf8();
            if (this.mEvent.mResult == 2) {
                int index = msg.indexOf(44);
                int timeout = Integer.parseInt(msg.substring(0, index));
                String msg2 = msg.substring(index + 1);
                LogTag.amsDebug("AmsEventHandler", "InstallQueryEventHandler timeout:" + timeout + ", msg:" + msg2);
                if (timeout != 0) {
                    timeoutDialog = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg2).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.2
                        @Override // android.content.DialogInterface.OnClickListener
                        public void onClick(DialogInterface dialog, int whichButton) {
                            InstallQueryEventHandler.this.mIsActioned = true;
                            ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                        }
                    }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.1
                        @Override // android.content.DialogInterface.OnCancelListener
                        public void onCancel(DialogInterface dialog) {
                            InstallQueryEventHandler.this.mIsActioned = true;
                            ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                        }
                    }).create();
                    timeoutDialog.show();
                    this.mHandler.postDelayed(new Runnable() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.3
                        @Override // java.lang.Runnable
                        public void run() {
                            if (!InstallQueryEventHandler.this.mIsActioned) {
                                try {
                                    InstallQueryEventHandler.timeoutDialog.dismiss();
                                } catch (Exception e) {
                                }
                                ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                            }
                        }
                    }, timeout);
                    return;
                } else {
                    AlertDialog dialog = new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg2).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.5
                        @Override // android.content.DialogInterface.OnClickListener
                        public void onClick(DialogInterface dialog2, int whichButton) {
                            InstallQueryEventHandler.this.mIsActioned = true;
                            ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                        }
                    }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.4
                        @Override // android.content.DialogInterface.OnCancelListener
                        public void onCancel(DialogInterface dialog2) {
                            InstallQueryEventHandler.this.mIsActioned = true;
                            ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                        }
                    }).create();
                    dialog.show();
                    return;
                }
            }
            if (this.mEvent.mResult == 33) {
                LayoutInflater mInflater = (LayoutInflater) this.mContext.getSystemService("layout_inflater");
                View v = mInflater.inflate(R.layout.authorization_input_dialog, (ViewGroup) null);
                final EditText edtText = (EditText) v.findViewById(R.id.edtName);
                final EditText edtPwd = (EditText) v.findViewById(R.id.edtPwd);
                new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setView(v).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.8
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog2, int whichButton) {
                        ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallAuthorization(edtText.getText().toString(), edtPwd.getText().toString(), true);
                    }
                }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.7
                    @Override // android.content.DialogInterface.OnClickListener
                    public void onClick(DialogInterface dialog2, int whichButton) {
                        ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallAuthorization("", "", false);
                    }
                }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.6
                    @Override // android.content.DialogInterface.OnCancelListener
                    public void onCancel(DialogInterface dialog2) {
                        ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallAuthorization("", "", false);
                    }
                }).show();
                return;
            }
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(msg).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.11
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog2, int whichButton) {
                    ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(true);
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.10
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog2, int whichButton) {
                    ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(false);
                }
            }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryEventHandler.9
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog2) {
                    ((AmsClient) InstallQueryEventHandler.this.mClient).requestInstallQueryEvent(false);
                }
            }).show();
        }
    }

    public static class InstallStepEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            if (this.mEvent.mResult == 13 || this.mEvent.mResult == 3) {
                processMessageImmediately(this.mHandler.obtainMessage(10003, this.mEvent.mResult, 0));
                String msg = this.mContext.getString(R.string.PRJ_GETTING_JAR);
                this.mHandler.obtainMessage(10009, this.mEvent.mResult, 0, msg).sendToTarget();
            }
        }
    }

    public static class InstallQueryYesNoEventHandler extends AmsEventHandler {
        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_WARNING)).setMessage(this.mEvent.getDataAsUtf8()).setCancelable(false).setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryYesNoEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) InstallQueryYesNoEventHandler.this.mClient).requestInstallQueryYesNoResponse(true);
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallQueryYesNoEventHandler.1
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) InstallQueryYesNoEventHandler.this.mClient).requestInstallQueryYesNoResponse(false);
                }
            }).show();
        }
    }

    public static class InstallPreviewJadEventHandler extends AmsEventHandler {
        private static boolean mDenyDelete;
        private static String mSize;
        private String mJadPreviewText;

        private static String[] decodeBytesToStrings(byte[] bytes) {
            List<String> result = new ArrayList<>();
            int from = 0;
            for (int i = 0; i < bytes.length; i++) {
                if (bytes[i] == 0) {
                    try {
                        result.add(new String(bytes, from, i - from, "UTF-8"));
                        from = i + 1;
                    } catch (UnsupportedEncodingException e) {
                        result.add("error encoding");
                        Log.e("AmsEventHandler", "UnsupportedEncodingException ", e);
                    }
                }
            }
            return (String[]) result.toArray(new String[result.size()]);
        }

        public static boolean denyDelete() {
            return mDenyDelete;
        }

        public static String getJarSize() {
            return mSize;
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler
        public void parseData(byte[] rawData) throws IOException {
            if (rawData == null || rawData.length == 0) {
                Log.w("AmsEventHandler", "JadPreviewEventHandle.parseData(), No any data for event" + AmsClient.getEventName(this.mEvent.mId));
                return;
            }
            StringBuffer buf = new StringBuffer();
            String[] lines = decodeBytesToStrings(rawData);
            String suiteName = null;
            String vendor = null;
            String version = null;
            String description = null;
            String size = null;
            mDenyDelete = false;
            if (JbedConfig.isJadShowNecessary()) {
                for (int i = 0; i < lines.length; i += 2) {
                    String key = lines[i];
                    if (key.equalsIgnoreCase(JbedSelectorData.KEY_MIDLET_NAME)) {
                        suiteName = "Name: " + lines[i + 1] + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    } else if (key.equalsIgnoreCase("MIDlet-Jar-Size")) {
                        size = "Size: " + lines[i + 1] + "bytes\n";
                        mSize = lines[i + 1];
                    } else if (key.equalsIgnoreCase(JbedSelectorData.KEY_MIDLET_VENDOR)) {
                        vendor = "Vendor: " + lines[i + 1] + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    } else if (key.equalsIgnoreCase(JbedSelectorData.KEY_MIDLET_VERSION)) {
                        version = "Version: " + lines[i + 1] + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    } else if (key.equalsIgnoreCase(JbedSelectorData.KEY_MIDLET_DESCRIPT)) {
                        description = "Description: " + lines[i + 1] + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
                    } else if (key.equalsIgnoreCase("LGE-MIDlet-Mgr-User-Denied") && lines[i + 1].equalsIgnoreCase("delete")) {
                        mDenyDelete = true;
                    }
                }
                this.mJadPreviewText = suiteName;
                this.mJadPreviewText += vendor;
                this.mJadPreviewText += version;
                if (description == null) {
                    description = "Description: N/A\n";
                }
                this.mJadPreviewText += description;
                this.mJadPreviewText += size;
                return;
            }
            for (int i2 = 0; i2 < lines.length; i2 += 2) {
                buf.append(lines[i2]).append(": ").append(lines[i2 + 1]).append('\n');
                if (lines[i2].equalsIgnoreCase("MIDlet-Jar-Size")) {
                    mSize = lines[i2 + 1];
                }
                this.mJadPreviewText = buf.toString();
            }
        }

        @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
        public void run() {
            new AlertDialog.Builder(getContext()).setTitle(this.mContext.getString(R.string.AMS_INFO)).setMessage(this.mJadPreviewText).setPositiveButton(android.R.string.yes, new DisposableClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallPreviewJadEventHandler.3
                @Override // com.esmertec.android.jbed.ams.InstallEventHandler.DisposableClickListener
                public void execute(DialogInterface dialog, int whichButton) {
                    ((AmsClient) InstallPreviewJadEventHandler.this.mClient).requestInstrallPreviewJadEvent(true);
                }
            }).setNegativeButton(android.R.string.no, new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallPreviewJadEventHandler.2
                @Override // android.content.DialogInterface.OnClickListener
                public void onClick(DialogInterface dialog, int whichButton) {
                    ((AmsClient) InstallPreviewJadEventHandler.this.mClient).requestInstrallPreviewJadEvent(false);
                }
            }).setOnCancelListener(new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.InstallEventHandler.InstallPreviewJadEventHandler.1
                @Override // android.content.DialogInterface.OnCancelListener
                public void onCancel(DialogInterface dialog) {
                    ((AmsClient) InstallPreviewJadEventHandler.this.mClient).requestInstrallPreviewJadEvent(false);
                }
            }).show();
        }
    }

    public static class DisposableClickListener implements DialogInterface.OnClickListener {
        private static final String TAG = "DisposableClickListener";
        boolean executed = false;

        @Override // android.content.DialogInterface.OnClickListener
        public void onClick(DialogInterface dialog, int whichButton) {
            if (!this.executed) {
                execute(dialog, whichButton);
                this.executed = true;
            } else {
                Log.w(TAG, "multi pressing !");
            }
        }

        public void execute(DialogInterface dialog, int whichButton) {
        }
    }
}
