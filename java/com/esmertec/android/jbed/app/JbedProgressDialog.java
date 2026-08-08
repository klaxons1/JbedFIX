package com.esmertec.android.jbed.app;

import android.R;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.ContextThemeWrapper;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.TextView;

/* JADX INFO: loaded from: classes.dex */
public class JbedProgressDialog extends AlertDialog {
    public static final int STYLE_HORIZONTAL = 1;
    public static final int STYLE_SPINNER = 0;
    private boolean mBackKeyAvailable;
    private boolean mHasStarted;
    private int mIncrementBy;
    private int mIncrementSecondaryBy;
    private boolean mIndeterminate;
    private Drawable mIndeterminateDrawable;
    private Context mJbedContext;
    private int mMax;
    private CharSequence mMessage;
    private TextView mMessageView;
    private ProgressBar mProgress;
    private TextView mProgressDescView;
    private Drawable mProgressDrawable;
    private int mProgressStyle;
    private int mProgressVal;
    private int mSecondaryProgressVal;
    private Handler mViewUpdateHandler;

    public JbedProgressDialog(Context context) {
        this(context, android.R.style.Theme_DeviceDefault_Dialog);
    }

    public JbedProgressDialog(Context context, int theme) {
        super(context, theme);
        this.mProgressStyle = 0;
        this.mJbedContext = new ContextThemeWrapper(context, theme == 0 ? android.R.style.Theme_DeviceDefault_Dialog : theme);
    }

    public static JbedProgressDialog show(Context context, CharSequence title, CharSequence message) {
        return show(context, title, message, false);
    }

    public static JbedProgressDialog show(Context context, CharSequence title, CharSequence message, boolean indeterminate) {
        return show(context, title, message, indeterminate, false, null);
    }

    public static JbedProgressDialog show(Context context, CharSequence title, CharSequence message, boolean indeterminate, boolean cancelable) {
        return show(context, title, message, indeterminate, cancelable, null);
    }

    public static JbedProgressDialog show(Context context, CharSequence title, CharSequence message, boolean indeterminate, boolean cancelable, DialogInterface.OnCancelListener cancelListener) {
        JbedProgressDialog dialog = new JbedProgressDialog(context);
        dialog.setTitle(title);
        dialog.setMessage(message);
        dialog.setIndeterminate(indeterminate);
        dialog.setCancelable(cancelable);
        dialog.setOnCancelListener(cancelListener);
        dialog.show();
        return dialog;
    }

    @Override // android.app.AlertDialog, android.app.Dialog
    protected void onCreate(Bundle savedInstanceState) {
        this.mBackKeyAvailable = true;
        LayoutInflater inflater = LayoutInflater.from(this.mJbedContext);
        if (this.mProgressStyle == 1) {
            this.mViewUpdateHandler = new Handler() { // from class: com.esmertec.android.jbed.app.JbedProgressDialog.1
                @Override // android.os.Handler
                public void handleMessage(Message msg) {
                    super.handleMessage(msg);
                    int progress = JbedProgressDialog.this.mProgress.getProgress();
                    int max = JbedProgressDialog.this.mProgress.getMax();
                    double d = ((double) progress) / ((double) max);
                }
            };
            View view = inflater.inflate(com.esmertec.android.jbed.R.layout.jbed_progress_dialog, (ViewGroup) null);
            this.mProgress = (ProgressBar) view.findViewById(com.esmertec.android.jbed.R.id.progress_bar);
            this.mProgressDescView = (TextView) view.findViewById(com.esmertec.android.jbed.R.id.progress_desc);
            setView(view);
        } else {
            View view2 = inflater.inflate(com.esmertec.android.jbed.R.layout.progress_dialog, (ViewGroup) null);
            this.mProgress = (ProgressBar) view2.findViewById(com.esmertec.android.jbed.R.id.progress);
            this.mMessageView = (TextView) view2.findViewById(com.esmertec.android.jbed.R.id.message);
            setView(view2);
        }
        if (this.mMax > 0) {
            setMax(this.mMax);
        }
        if (this.mProgressVal > 0) {
            setProgress(this.mProgressVal);
        }
        if (this.mSecondaryProgressVal > 0) {
            setSecondaryProgress(this.mSecondaryProgressVal);
        }
        if (this.mIncrementBy > 0) {
            incrementProgressBy(this.mIncrementBy);
        }
        if (this.mIncrementSecondaryBy > 0) {
            incrementSecondaryProgressBy(this.mIncrementSecondaryBy);
        }
        if (this.mProgressDrawable != null) {
            setProgressDrawable(this.mProgressDrawable);
        }
        if (this.mIndeterminateDrawable != null) {
            setIndeterminateDrawable(this.mIndeterminateDrawable);
        }
        if (this.mMessage != null) {
            setMessage(this.mMessage);
        }
        setIndeterminate(this.mIndeterminate);
        onProgressChanged();
        super.onCreate(savedInstanceState);
    }

    @Override // android.app.Dialog
    public void onStart() {
        super.onStart();
        this.mHasStarted = true;
    }

    @Override // android.app.Dialog
    protected void onStop() {
        super.onStop();
        this.mHasStarted = false;
    }

    public void setProgress(int value) {
        if (this.mHasStarted) {
            this.mProgress.setProgress(value);
            onProgressChanged();
        } else {
            this.mProgressVal = value;
        }
    }

    public void setSecondaryProgress(int secondaryProgress) {
        if (this.mProgress != null) {
            this.mProgress.setSecondaryProgress(secondaryProgress);
            onProgressChanged();
        } else {
            this.mSecondaryProgressVal = secondaryProgress;
        }
    }

    public int getProgress() {
        return this.mProgress != null ? this.mProgress.getProgress() : this.mProgressVal;
    }

    public int getSecondaryProgress() {
        return this.mProgress != null ? this.mProgress.getSecondaryProgress() : this.mSecondaryProgressVal;
    }

    public int getMax() {
        return this.mProgress != null ? this.mProgress.getMax() : this.mMax;
    }

    public void setMax(int max) {
        if (this.mProgress != null) {
            this.mProgress.setMax(max);
            onProgressChanged();
        } else {
            this.mMax = max;
        }
    }

    public void incrementProgressBy(int diff) {
        if (this.mProgress != null) {
            this.mProgress.incrementProgressBy(diff);
            onProgressChanged();
        } else {
            this.mIncrementBy += diff;
        }
    }

    public void incrementSecondaryProgressBy(int diff) {
        if (this.mProgress != null) {
            this.mProgress.incrementSecondaryProgressBy(diff);
            onProgressChanged();
        } else {
            this.mIncrementSecondaryBy += diff;
        }
    }

    public void setProgressDrawable(Drawable d) {
        if (this.mProgress != null) {
            this.mProgress.setProgressDrawable(d);
        } else {
            this.mProgressDrawable = d;
        }
    }

    public void setIndeterminateDrawable(Drawable d) {
        if (this.mProgress != null) {
            this.mProgress.setIndeterminateDrawable(d);
        } else {
            this.mIndeterminateDrawable = d;
        }
    }

    public void setIndeterminate(boolean indeterminate) {
        if (this.mProgress != null) {
            this.mProgress.setIndeterminate(indeterminate);
        } else {
            this.mIndeterminate = indeterminate;
        }
    }

    public boolean isIndeterminate() {
        return this.mProgress != null ? this.mProgress.isIndeterminate() : this.mIndeterminate;
    }

    @Override // android.app.AlertDialog
    public void setMessage(CharSequence message) {
        if (this.mProgress != null) {
            if (this.mProgressStyle == 1) {
                super.setMessage(message);
                return;
            } else {
                this.mMessageView.setText(message);
                return;
            }
        }
        this.mMessage = message;
    }

    public void setDescMessage(String message) {
        if (this.mProgressDescView != null) {
            this.mProgressDescView.setText(message);
        }
    }

    public void setProgressStyle(int style) {
        this.mProgressStyle = style;
    }

    private void onProgressChanged() {
        if (this.mProgressStyle == 1) {
            this.mViewUpdateHandler.sendEmptyMessage(0);
        }
    }

    @Override // android.app.AlertDialog, android.app.Dialog, android.view.KeyEvent.Callback
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        return super.onKeyUp(keyCode, event);
    }

    @Override // android.app.AlertDialog, android.app.Dialog, android.view.KeyEvent.Callback
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return super.onKeyDown(keyCode, event);
    }

    public void enableBackKey(boolean available) {
        this.mBackKeyAvailable = available;
    }
}
