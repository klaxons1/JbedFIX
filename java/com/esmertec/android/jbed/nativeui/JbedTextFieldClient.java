package com.esmertec.android.jbed.nativeui;

import android.content.Context;
import android.os.Handler;
import android.os.RemoteException;
import android.util.Log;
import android.view.View;
import android.widget.AbsoluteLayout;
import android.widget.EditText;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.service.IJbedUiListener;
import com.esmertec.android.jbed.util.EditTextHelper;
import com.esmertec.android.jbed.util.SerialExecutor;
import java.util.HashMap;

/* JADX INFO: loaded from: classes.dex */
public class JbedTextFieldClient {
    static final boolean DEBUG = false;
    private static final boolean DEBUG_CALSIZEHINT = false;
    private static JbedTextFieldClient INSTANCE = null;
    static final String TAG = "NativeTextField";
    private static IJbedUiListener mJbedUiListener;
    private IJbedTextFieldConnection mConnection;
    private AbsoluteLayout mContainerView;
    private Context mContext;
    private int mMaxWidth;
    private static int focusId = -1;
    private static int RESERVE_WIDTH = 20;
    private Handler mHandler = new Handler();
    private Object mMutex = new Object();
    private HashMap<Integer, JbedEditText> mTextFieldMap = new HashMap<>();
    private int pendingFocusId = -1;
    private JbedTextFieldClientImpl mClient = new JbedTextFieldClientImpl();

    public static JbedTextFieldClient create(IJbedUiListener listener, Context context, AbsoluteLayout nativeWidgetView, IJbedTextFieldConnection conn, int maxWidth) {
        mJbedUiListener = listener;
        if (nativeWidgetView == null) {
            throw new IllegalArgumentException("NativeTextField create  nativeWidgetView is null");
        }
        if (INSTANCE == null) {
            INSTANCE = new JbedTextFieldClient(context, nativeWidgetView, conn, maxWidth);
        }
        return INSTANCE;
    }

    public static void dispose() {
        if (INSTANCE != null) {
            try {
                INSTANCE.mConnection.setClient(null);
                INSTANCE.mTextFieldMap.clear();
                INSTANCE.mContainerView.removeAllViews();
                INSTANCE = null;
            } catch (RemoteException e) {
                throw new RuntimeException("failed to call setClient");
            }
        }
    }

    private JbedTextFieldClient(Context context, AbsoluteLayout containerView, IJbedTextFieldConnection connection, int maxWidth) {
        this.mContext = context;
        this.mContainerView = containerView;
        this.mConnection = connection;
        this.mMaxWidth = maxWidth;
        try {
            this.mConnection.setClient(this.mClient);
        } catch (RemoteException e) {
            throw new RuntimeException("fail to call setClient");
        }
    }

    class JbedTextFieldClientImpl extends IJbedTextFieldClient.Stub {
        private static final int HIDEN_POSITION = -1000;

        JbedTextFieldClientImpl() {
        }

        private void cretateTextField(final int id) {
            new SerialExecutor().execute(JbedTextFieldClient.this.mHandler, new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.1
                @Override // java.lang.Runnable
                public void run() {
                    JbedEditText editText = new JbedEditText(JbedTextFieldClient.this.mContext, null);
                    editText.init(JbedTextFieldClient.mJbedUiListener, id, JbedTextFieldClient.this.mContext, JbedTextFieldClient.this.mConnection);
                    JbedTextFieldClient.this.mTextFieldMap.put(Integer.valueOf(id), editText);
                    JbedTextFieldClient.this.mContainerView.addView(editText);
                    editText.setVisibility(4);
                    editText.setGravity(51);
                }
            });
        }

        private void createAndRefresh(int id) {
            cretateTextField(id);
            try {
                JbedTextFieldClient.this.mConnection.requestRefresh(id);
            } catch (RemoteException e) {
                throw new RuntimeException("NativeEditText fail to call requestRefresh");
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setPosition(final int id, final int x, final int y, final int width, final int height, final boolean isTextBox, final int maxScrollbarWidth) {
            final JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
            if (textField != null) {
                JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.2
                    @Override // java.lang.Runnable
                    public void run() {
                        textField.setVisibility(0);
                        AbsoluteLayout.LayoutParams layout = (AbsoluteLayout.LayoutParams) textField.getLayoutParams();
                        layout.x = x;
                        layout.y = y;
                        layout.width = Math.min(width, JbedTextFieldClient.this.mMaxWidth - maxScrollbarWidth);
                        layout.height = height;
                        textField.setLayoutParams(layout);
                        if (isTextBox) {
                            textField.requestFocus();
                        }
                        if (x != JbedTextFieldClientImpl.HIDEN_POSITION || y != JbedTextFieldClientImpl.HIDEN_POSITION) {
                            if (id == JbedTextFieldClient.focusId) {
                                textField.requestFocus();
                            }
                            if (id == JbedTextFieldClient.this.pendingFocusId) {
                                JbedTextFieldClient.this.pendingFocusId = -1;
                                textField.requestFocus();
                                return;
                            }
                            return;
                        }
                        textField.clearFocus();
                    }
                });
            } else {
                createAndRefresh(id);
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void create(int id) {
            cretateTextField(id);
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void calculateSizeHints(int id, int widthHint, int heightHint, final int[] info) {
            final JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
            if (textField == null) {
                createAndRefresh(id);
                return;
            }
            final int widthSpec = widthHint > 0 ? View.MeasureSpec.makeMeasureSpec(widthHint, Integer.MIN_VALUE) : 0;
            final int heightSpec = heightHint > 0 ? View.MeasureSpec.makeMeasureSpec(heightHint, Integer.MIN_VALUE) : 0;
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.3
                @Override // java.lang.Runnable
                public void run() {
                    EditText dummyMeasureEditText = new EditText(JbedTextFieldClient.this.mContext);
                    dummyMeasureEditText.setText(textField.getText().toString());
                    dummyMeasureEditText.measure(widthSpec, heightSpec);
                    int[] iArr = info;
                    int[] iArr2 = info;
                    int measuredWidth = dummyMeasureEditText.getMeasuredWidth() + JbedTextFieldClient.RESERVE_WIDTH;
                    iArr2[2] = measuredWidth;
                    iArr[0] = measuredWidth;
                    int[] iArr3 = info;
                    int[] iArr4 = info;
                    int measuredHeight = dummyMeasureEditText.getMeasuredHeight();
                    iArr4[3] = measuredHeight;
                    iArr3[1] = measuredHeight;
                    synchronized (JbedTextFieldClient.this.mMutex) {
                        JbedTextFieldClient.this.mMutex.notify();
                    }
                }
            });
            synchronized (JbedTextFieldClient.this.mMutex) {
                try {
                    JbedTextFieldClient.this.mMutex.wait();
                } catch (Exception e) {
                }
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setFocus(final int id, final boolean focus) {
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.4
                @Override // java.lang.Runnable
                public void run() {
                    if (JbedTextFieldClient.this.mTextFieldMap != null) {
                        JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
                        if (textField == null) {
                            Log.w(JbedTextFieldClient.TAG, "WARNING: set Focus but text field has been disposed");
                            return;
                        }
                        if (!focus) {
                            int unused = JbedTextFieldClient.focusId = -1;
                            textField.clearFocus();
                        } else {
                            if (!textField.requestFocus()) {
                                JbedTextFieldClient.this.pendingFocusId = id;
                            }
                            int unused2 = JbedTextFieldClient.focusId = id;
                        }
                    }
                }
            });
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void dispose(final int id) {
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.5
                @Override // java.lang.Runnable
                public void run() {
                    JbedTextFieldClient.this.mContainerView.removeView((View) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id)));
                    JbedTextFieldClient.this.mTextFieldMap.remove(Integer.valueOf(id));
                }
            });
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setText(final int id, final String text) {
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.6
                @Override // java.lang.Runnable
                public void run() {
                    JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
                    if (textField != null) {
                        textField.setText(text);
                    }
                }
            });
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setClip(int id, int x, int y, int width, int height) {
            final JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
            if (textField != null) {
                textField.setClip(x, y, JbedTextFieldClient.RESERVE_WIDTH + width, height);
                JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.7
                    @Override // java.lang.Runnable
                    public void run() {
                        textField.invalidate();
                    }
                });
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void replaceText(final int id, final int offset, final int length, final String text) {
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.8
                @Override // java.lang.Runnable
                public void run() {
                    JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
                    if (textField != null) {
                        String originalText = textField.getText().toString();
                        if (text != null) {
                            textField.setText(new StringBuffer(originalText).replace(offset, offset + length, text).toString());
                        } else {
                            textField.setText(new StringBuffer(originalText).delete(offset, offset + length).toString());
                        }
                    }
                }
            });
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setConstraints(final int id, final int constraints) {
            JbedTextFieldClient.this.mHandler.post(new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldClient.JbedTextFieldClientImpl.9
                @Override // java.lang.Runnable
                public void run() {
                    JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
                    if (textField != null) {
                        EditTextHelper.setConstraint(textField, constraints);
                        if ((constraints & JbedConstants.JBED_CONSTRAINT_UNEDITABLE) != 0) {
                            textField.setUneditable();
                        }
                    }
                }
            });
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public void setMaxSize(int id, int maxSize) {
            JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
            if (textField != null) {
                EditTextHelper.setMaxSize(textField, maxSize);
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
        public int getCaretPosition(int id) {
            JbedEditText textField = (JbedEditText) JbedTextFieldClient.this.mTextFieldMap.get(Integer.valueOf(id));
            if (textField == null) {
                return -1;
            }
            return textField.getSelectionEnd();
        }
    }
}
