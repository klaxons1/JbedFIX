package com.esmertec.android.jbed.ams;

import android.R;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Handler;
import android.os.Message;
import android.widget.Toast;
import java.io.DataInputStream;
import java.io.IOException;

/* JADX INFO: loaded from: classes.dex */
public abstract class AmsEventHandler implements Runnable, AmsConstants {
    protected static final String TAG = "AmsEventHandler";
    protected AmsClientBase mClient;
    protected Context mContext;
    protected AmsEvent mEvent;
    protected Handler mHandler;
    static DialogInterface.OnClickListener defaultDismissListener = new DialogInterface.OnClickListener() { // from class: com.esmertec.android.jbed.ams.AmsEventHandler.1
        @Override // android.content.DialogInterface.OnClickListener
        public void onClick(DialogInterface dialog, int which) {
            dialog.dismiss();
        }
    };
    static DialogInterface.OnCancelListener defaultCancelListener = new DialogInterface.OnCancelListener() { // from class: com.esmertec.android.jbed.ams.AmsEventHandler.2
        @Override // android.content.DialogInterface.OnCancelListener
        public void onCancel(DialogInterface dialog) {
            dialog.dismiss();
        }
    };
    private static int INFO_ID = -1;
    private static int WARNING_ID = -1;
    private static int ERROR_ID = -1;

    public interface Factory {
        AmsEventHandler buildAmsHandler(int i);
    }

    public Context getContext() {
        return this.mContext;
    }

    @Override // java.lang.Runnable
    public void run() {
    }

    protected void parseData(byte[] data) throws IOException {
    }

    protected void showDialg(int titleId, String msg) {
        showDialg(titleId, msg, null);
    }

    protected void showDialg(int titleId, String msg, DialogInterface.OnClickListener listener) {
        AlertDialog.Builder builder = new AlertDialog.Builder(getContext()).setMessage(msg).setNeutralButton(R.string.ok, listener == null ? defaultDismissListener : listener);
        if (titleId != -1) {
            builder.setTitle(titleId);
        }
        builder.show();
    }

    protected void showDialg(int titleId, int msgId) {
        showDialg(titleId, this.mContext.getString(msgId));
    }

    protected void showInfo(int msgId) {
        String msg = this.mContext.getString(msgId);
        showInfo(msg);
    }

    protected void showToast(String msg) {
        Toast.makeText(this.mContext, msg, 0).show();
    }

    protected void showInfo(String msg) {
        try {
            if (INFO_ID == -1) {
                INFO_ID = Class.forName("com.esmertec.android.jbed.R$string").getField("AMS_INFO").getInt(null);
            }
            showDialg(INFO_ID, msg);
        } catch (Exception e) {
            throw new IllegalStateException("Class cannot be found");
        }
    }

    protected void showWarning(String msg) {
        try {
            if (WARNING_ID == -1) {
                WARNING_ID = Class.forName("com.esmertec.android.jbed.R$string").getField("AMS_WARNING").getInt(null);
            }
            showDialg(WARNING_ID, msg);
        } catch (Exception e) {
            throw new IllegalStateException("Class cannot be found");
        }
    }

    protected void showError(String msg) {
        showError(msg, null);
    }

    protected void showError(String msg, DialogInterface.OnClickListener listener) {
        try {
            if (ERROR_ID == -1) {
                ERROR_ID = Class.forName("com.esmertec.android.jbed.R$string").getField("AMS_ERROR").getInt(null);
            }
            showDialg(ERROR_ID, msg, listener);
        } catch (Exception e) {
            throw new IllegalStateException("Class cannot be found");
        }
    }

    protected void bringMidletToForeground(boolean isFullScreen) {
        this.mClient.bringMidletToForeground(isFullScreen);
    }

    static String readJbedString(DataInputStream in) throws IOException {
        boolean hasContent = in.readBoolean();
        if (hasContent) {
            return in.readUTF();
        }
        return null;
    }

    protected void processMessageImmediately(Message message) {
        this.mHandler.sendMessageAtFrontOfQueue(message);
    }
}
