package com.esmertec.android.jbed.nativeui;

import android.content.Context;
import android.graphics.Canvas;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.text.InputFilter;
import android.text.Spanned;
import android.text.method.ScrollingMovementMethod;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.widget.AbsoluteLayout;
import android.widget.EditText;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.service.IJbedUiListener;

/* JADX INFO: loaded from: classes.dex */
public class JbedEditText extends EditText {
    static final int HANDLE_TEXT_CHANGED = 10001;
    private static IJbedUiListener mJbedUiListener;
    private int clipHeight;
    private int clipWdith;
    private int clipX;
    private int clipY;
    private boolean editable;
    private IJbedTextFieldConnection mConnection;
    private Handler mHandler;
    private int mId;
    private boolean onKeyDownReturn;

    public JbedEditText(Context context, AttributeSet attrs) {
        super(context, attrs);
        this.editable = true;
        this.clipX = JbedConstants.JBED_MAX_IDLE;
        this.mHandler = null;
    }

    void init(IJbedUiListener listener, int id, Context context, IJbedTextFieldConnection connection) {
        mJbedUiListener = listener;
        this.mId = id;
        this.mConnection = connection;
    }

    @Override // android.widget.TextView, android.view.View
    public boolean onCheckIsTextEditor() {
        if (this.editable) {
            return super.onCheckIsTextEditor();
        }
        return false;
    }

    void setUneditable() {
        this.editable = false;
        setCursorVisible(false);
        setMovementMethod(ScrollingMovementMethod.getInstance());
        setFilters(new InputFilter[]{new InputFilter() { // from class: com.esmertec.android.jbed.nativeui.JbedEditText.1
            @Override // android.text.InputFilter
            public CharSequence filter(CharSequence src, int start, int end, Spanned dst, int dstart, int dend) {
                return src.length() < 1 ? dst.subSequence(dstart, dend) : "";
            }
        }});
    }

    @Override // android.widget.TextView, android.view.View, android.view.KeyEvent.Callback
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        this.onKeyDownReturn = super.onKeyDown(keyCode, event);
        return this.onKeyDownReturn;
    }

    @Override // android.widget.TextView, android.view.View, android.view.KeyEvent.Callback
    public boolean onKeyUp(int keyCode, KeyEvent event) {
        super.onKeyUp(keyCode, event);
        return this.onKeyDownReturn;
    }

    @Override // android.widget.TextView
    public void onTextChanged(CharSequence text, int start, int before, int after) {
        super.onTextChanged(text, start, before, after);
        if (this.mHandler == null) {
            this.mHandler = new Handler() { // from class: com.esmertec.android.jbed.nativeui.JbedEditText.2
                @Override // android.os.Handler
                public void handleMessage(Message msg) {
                    int id = msg.arg1;
                    String text2 = (String) msg.obj;
                    try {
                        if (JbedEditText.this.mConnection != null) {
                            JbedEditText.this.mConnection.onTextChanged(id, text2);
                        }
                    } catch (RemoteException e) {
                        throw new RuntimeException("NativeEditText fail to call onTextChanged");
                    }
                }
            };
        }
        Message message = this.mHandler.obtainMessage(10001, this.mId, 0, text.toString());
        this.mHandler.removeMessages(10001);
        this.mHandler.sendMessageDelayed(message, 350L);
    }

    @Override // android.widget.TextView, android.view.View
    public boolean onTouchEvent(MotionEvent motionEvent) {
        super.onTouchEvent(motionEvent);
        AbsoluteLayout.LayoutParams layout = (AbsoluteLayout.LayoutParams) getLayoutParams();
        try {
            int x = (int) motionEvent.getX();
            int y = (int) motionEvent.getY();
            requestFocusFromTouch();
            if (mJbedUiListener != null) {
                return mJbedUiListener.notifyOnTouchEvent(layout.x + x, layout.y + y, motionEvent.getAction());
            }
            return true;
        } catch (RemoteException e) {
            throw new RuntimeException(" failed to call notifyOnTouchEvent");
        }
    }

    @Override // android.view.View
    public void draw(Canvas canvas) {
        if (this.editable) {
            AbsoluteLayout.LayoutParams layout = (AbsoluteLayout.LayoutParams) getLayoutParams();
            setLayoutParams(layout);
        }
        if (this.clipX != Integer.MAX_VALUE) {
            canvas.clipRect(this.clipX, this.clipY, this.clipX + this.clipWdith, this.clipY + this.clipHeight);
        }
        super.draw(canvas);
    }

    public void setClip(int x, int y, int width, int height) {
        this.clipX = x;
        this.clipY = y;
        this.clipWdith = width;
        this.clipHeight = height;
    }
}
