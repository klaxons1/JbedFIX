package com.esmertec.android.jbed.jsr;

/* JADX INFO: compiled from: JbedMmsManager.java */
/* JADX INFO: loaded from: classes.dex */
public interface TransactionService {
    public static final String APP_ID = "applicId";
    public static final String APP_PACKAGE_NAME = "com.android.mms";
    public static final String CLASS_NAME = "com.android.mms.transaction.TransactionService";
    public static final int FAILED = 2;
    public static final int INITIALIZED = 0;
    public static final String STATE = "state";
    public static final String STATE_URI = "uri";
    public static final int SUCCESS = 1;
    public static final String TRANSACTION_COMPLETED_ACTION = "android.intent.action.TRANSACTION_COMPLETED_ACTION";
    public static final String TRANSACTION_TYPE = "type";
    public static final int TRANSACTION_TYPE_RETRIEVE = 0;
    public static final int TRANSACTION_TYPE_SEND = 1;
    public static final int TRANSACTION_TYPE_UNKOWN = -1;
    public static final int TYPE_SEND_TRANSACTION = 2;
    public static final String URI = "uri";
}
