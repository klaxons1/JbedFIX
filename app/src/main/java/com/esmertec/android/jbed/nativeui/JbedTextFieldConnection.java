package com.esmertec.android.jbed.nativeui;

import android.content.Context;
import android.os.DeadObjectException;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class JbedTextFieldConnection {
    private static final boolean DEBUG = false;
    private static final boolean DEBUG_CALSIZEHINT = false;
    public static JbedTextFieldConnection INSTANCE = null;
    private static final String TAG = "JbedTextFieldConnection";
    private static int mIdCounter;
    private IJbedTextFieldClient mClient;
    public IJbedTextFieldConnection mConnection = new IJbedTextFieldConnection.Stub() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldConnection.1
        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
        public void setClient(IJbedTextFieldClient client) {
            synchronized (JbedTextFieldConnection.INSTANCE) {
                JbedTextFieldConnection.this.mClient = client;
                if (JbedTextFieldConnection.this.mClient != null) {
                    Message msg = JbedTextFieldConnection.this.mHandler.obtainMessage(3);
                    msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldConnection.1.1
                        @Override // java.lang.Runnable
                        public void run() {
                            JbedTextFieldConnection.this.notifyTextFieldClientAttached();
                        }
                    };
                    msg.sendToTarget();
                    JbedTextFieldConnection.INSTANCE.notify();
                }
            }
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
        public void onTextChanged(final int id, final String text) {
            Message msg = JbedTextFieldConnection.this.mHandler.obtainMessage(3);
            msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldConnection.1.2
                @Override // java.lang.Runnable
                public void run() {
                    JbedTextFieldConnection.this.notifyTextFieldTextChanged(id, text);
                }
            };
            msg.sendToTarget();
        }

        @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
        public void requestRefresh(final int id) {
            Message msg = JbedTextFieldConnection.this.mHandler.obtainMessage(3);
            msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.nativeui.JbedTextFieldConnection.1.3
                @Override // java.lang.Runnable
                public void run() {
                    JbedTextFieldConnection.this.notifyRefreshTextField(id);
                }
            };
            msg.sendToTarget();
        }
    };
    private Handler mHandler;

    /* JADX INFO: Access modifiers changed from: private */
    public native void notifyRefreshTextField(int i);

    /* JADX INFO: Access modifiers changed from: private */
    public native void notifyTextFieldClientAttached();

    /* JADX INFO: Access modifiers changed from: private */
    public native void notifyTextFieldTextChanged(int i, String str);

    public JbedTextFieldConnection(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
    }

    public JbedTextFieldConnection() {
        INSTANCE = this;
    }

    public void onDestroy(Context context) {
        INSTANCE = null;
    }

    private static int create(int mask) throws DeadObjectException {
        synchronized (INSTANCE) {
            if (INSTANCE.mClient == null) {
                return -1;
            }
            int i = mIdCounter;
            mIdCounter = i + 1;
            int id = mask | i;
            try {
                INSTANCE.mClient.create(id);
                return id;
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call create");
            }
        }
    }

    private static void dispose(int id) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.dispose(id);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call destroy");
            }
        }
    }

    private static void setText(int id, String text) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setText(id, text);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setText");
            }
        }
    }

    private static void calculateSizeHints(int id, int widthHint, int heightHint, int[] data) {
        if (INSTANCE.mClient == null) {
            synchronized (INSTANCE) {
                try {
                    INSTANCE.wait();
                } catch (InterruptedException e) {
                }
            }
        }
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.calculateSizeHints(id, widthHint, heightHint, data);
            } catch (RemoteException e2) {
                throw new RuntimeException("JbedTextFieldConnection fail to call calculateSizeHints");
            }
        }
    }

    private static void setPosition(int id, int x, int y, int width, int height, boolean isTextBox, int maxScrollbarWidth) {
        if (INSTANCE.mClient == null) {
            synchronized (INSTANCE) {
                try {
                    INSTANCE.wait();
                } catch (InterruptedException e) {
                }
            }
        }
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setPosition(id, x, y, width, height, isTextBox, maxScrollbarWidth);
            } catch (RemoteException e2) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setPosition");
            }
        }
    }

    private static void setClip(int id, int x, int y, int width, int height) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setClip(id, x, y, width, height);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setClip");
            }
        }
    }

    private static void setFocus(int id, boolean hasFocus) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setFocus(id, hasFocus);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setFocus");
            }
        }
    }

    private static void replaceText(int id, int offset, int len, String text) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.replaceText(id, offset, len, text);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setFocus");
            }
        }
    }

    private static void setConstraints(int id, int constraints) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setConstraints(id, constraints);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setCosntraints");
            }
        }
    }

    private static void setMaxSize(int id, int maxSize) {
        if (INSTANCE.mClient != null) {
            try {
                INSTANCE.mClient.setMaxSize(id, maxSize);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call setMaxSize");
            }
        }
    }

    private static int getCaretPosition(int id) {
        if (INSTANCE.mClient != null) {
            try {
                return INSTANCE.mClient.getCaretPosition(id);
            } catch (RemoteException e) {
                throw new RuntimeException("JbedTextFieldConnection fail to call getCaretPosition");
            }
        }
        Log.w(TAG, "getCaretPosition return -1");
        return -1;
    }
}
