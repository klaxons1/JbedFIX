package com.esmertec.android.jbed.jsr;

import android.content.BroadcastReceiver;
import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import com.esmertec.android.jbed.ams.AmsConstants;
import com.esmertec.android.jbed.service.JbedService;
import com.esmertec.android.jbed.util.SimpleEntry;
import com.google.android.mms.pdu.PduBody;
import com.google.android.mms.pdu.PduPart;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.ConcurrentModificationException;
import java.util.HashMap;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedMmsManager implements JbedService.LifecycleListener {
    static final /* synthetic */ boolean $assertionsDisabled;
    static boolean DEBUG;
    private static JbedMmsManager INSTANCE;
    static int MAX_STORED_PARTS;
    public static String TAG;
    private Context mContext;
    private Handler mHandler;
    JbedMmsMessagePart[] mPartStore = new JbedMmsMessagePart[MAX_STORED_PARTS];
    private List<JbedMmsPort> mRegPorts = new ArrayList();
    private HashMap<Long, Integer> mSendResultNativeContextMap = new HashMap<>();
    private List<JbedMmsMessage> mReceivedMessages = new ArrayList();
    private BroadcastReceiver mMmsTransactionReceiver = new BroadcastReceiver() { // from class: com.esmertec.android.jbed.jsr.JbedMmsManager.1
        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            Uri uri = (Uri) intent.getParcelableExtra("uri");
            int state = intent.getIntExtra(TransactionService.STATE, 0);
            SimpleEntry<String, Integer> info = JbedMmsManager.getMmsAppIdAndType(context, intent);
            String appId = info.getKey();
            int messageType = info.getValue().intValue();
            JbedMmsManager.log(" get TRANSACTION_COMPLETED_ACTION type=" + messageType + " uri=" + uri + " state=" + state);
            switch (messageType) {
                case 128:
                    boolean sendResult = state == 1;
                    JbedMmsManager.this.handleSendResult(uri, sendResult);
                    break;
                case 132:
                    if (state == 1 && appId != null) {
                        JbedMmsManager.this.handleRetrieve(uri, appId);
                    } else if (JbedMmsManager.DEBUG) {
                        Log.d(JbedMmsManager.TAG, "get failed MESSAGE_TYPE_RETRIEVE_CONF message");
                    }
                    break;
                default:
                    if (JbedMmsManager.DEBUG) {
                        Log.d(JbedMmsManager.TAG, " get a MMS TRANSACTION notification with unknown type!!");
                    }
                    break;
            }
        }
    };

    enum PushType {
        NONE,
        STATIC,
        DYNMAIC
    }

    private static native void nativeNotifyMmsSendResult(int i, boolean z);

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifyNewMms(boolean z);

    static {
        $assertionsDisabled = !JbedMmsManager.class.desiredAssertionStatus();
        TAG = "JbedMmsManager";
        DEBUG = false;
        MAX_STORED_PARTS = 64;
    }

    public JbedMmsManager(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static void log(String msg) {
        if (DEBUG) {
            Log.d(TAG, msg);
        }
    }

    public static SimpleEntry<String, Integer> getMmsAppIdAndType(Context context, Intent intent) {
        Uri uri = (Uri) intent.getParcelableExtra("uri");
        intent.getIntExtra(TransactionService.STATE, 0);
        Cursor c = null;
        String appId = null;
        int messageType = -1;
        try {
            try {
                c = context.getContentResolver().query(uri, new String[]{"apl_id", "m_type"}, null, null, null);
                if (c != null && c.moveToFirst()) {
                    appId = c.getString(0);
                    messageType = c.getInt(1);
                }
                if (c != null) {
                    c.close();
                }
            } catch (Exception e) {
                Log.e(TAG, "failed to query " + uri + "! ignore it");
                if (c != null) {
                    c.close();
                }
            }
            return new SimpleEntry<>(appId, Integer.valueOf(messageType));
        } catch (Throwable th) {
            if (c != null) {
                c.close();
            }
            throw th;
        }
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void handleRetrieve(Uri uri, String appId) {
        if (isRegisteredAppId(appId)) {
            try {
                JbedMmsMessage newMessage = new JbedMmsMessage(this.mContext, this, uri, appId);
                this.mReceivedMessages.add(newMessage);
                notifyNewMessage(isPushPort(appId));
                return;
            } catch (ClassCastException e) {
                Log.w(TAG, "get a NotificationTransation defered type message! ingore it. " + uri.toString());
                return;
            } catch (Exception e2) {
                Log.e(TAG, "failed to receive message " + uri.toString() + " appid=" + appId);
                return;
            }
        }
        Log.w(TAG, " get a Mms with appid not for jbed!!!");
    }

    private boolean isRegisteredAppId(String appId) {
        for (JbedMmsPort port : this.mRegPorts) {
            if (port.mAppId.equals(appId)) {
                return true;
            }
        }
        return false;
    }

    private boolean isPushPort(String appId) {
        for (JbedMmsPort port : this.mRegPorts) {
            if (port.mAppId.equals(appId)) {
                return port.isPush();
            }
        }
        return false;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public void handleSendResult(Uri uri, boolean isSucceed) {
        try {
            long uriId = ContentUris.parseId(uri);
            Integer nativeContext = this.mSendResultNativeContextMap.remove(Long.valueOf(uriId));
            if (nativeContext != null) {
                nativeNotifyMmsSendResult(nativeContext.intValue(), isSucceed);
            } else if (DEBUG) {
                Log.d(TAG, "Received a sending result message which sent by other app");
            }
        } catch (Exception e) {
            Log.e(TAG, "failed to send message by " + e);
        }
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
        IntentFilter filter = new IntentFilter();
        filter.addAction(TransactionService.TRANSACTION_COMPLETED_ACTION);
        this.mContext.registerReceiver(this.mMmsTransactionReceiver, filter);
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        for (int i = 0; i < MAX_STORED_PARTS; i++) {
            this.mPartStore[i] = null;
        }
        this.mSendResultNativeContextMap.clear();
        this.mReceivedMessages.clear();
        this.mContext.unregisterReceiver(this.mMmsTransactionReceiver);
    }

    int findEmptyIndex() {
        for (int i = 0; i < this.mPartStore.length; i++) {
            if (this.mPartStore[i] == null) {
                this.mPartStore[i] = new JbedMmsMessagePart(this.mContext, i);
                return i;
            }
        }
        Log.e(TAG, "findEmptyIndex() have no memory to hold this part!!");
        return -1;
    }

    int storeDataPieceInternal(int index, byte[] data, int len) {
        log("storeDataPieceInternal() index:" + index + "len:" + len);
        if (index == -1) {
            index = findEmptyIndex();
        }
        if (index == -1) {
            return -1;
        }
        this.mPartStore[index].write(data, len);
        return index;
    }

    private byte[] getDataPieceInternal(int index, int from, int len) {
        log("getDataPieceInternal() enter...");
        if (!$assertionsDisabled && (index < 0 || index >= MAX_STORED_PARTS)) {
            throw new AssertionError();
        }
        if ($assertionsDisabled || this.mPartStore[index] != null) {
            return this.mPartStore[index].read(from, len);
        }
        throw new AssertionError();
    }

    private int sendInternal(int nativeContext, byte[] headerFields, byte[] partHeaderFields, int[] partIndex) {
        String[] allHeaderFields = decodeBytesToStrings(headerFields);
        String startContentId = JbedMmsMessage.getStartContentId(allHeaderFields);
        String[] allPartHeaderFields = decodeBytesToStrings(partHeaderFields);
        if (DEBUG) {
            Log.d(TAG, headerFields.length + "  " + partHeaderFields.length);
        }
        JbedMmsMessagePart[] parts = new JbedMmsMessagePart[partIndex.length];
        for (int i = 0; i < partIndex.length; i++) {
            JbedMmsMessagePart part = this.mPartStore[partIndex[i]];
            for (int j = 0; j < part.mHeaderFields.length; j++) {
                part.mHeaderFields[j] = allPartHeaderFields[(part.mHeaderFields.length * i) + j];
            }
            part.fillPduPart();
            parts[i] = part;
        }
        if (startContentId != null) {
            Arrays.sort(parts, new JbedMmsMessagePart.StartCotentIdCompartor(startContentId));
        }
        PduBody body = new PduBody();
        for (JbedMmsMessagePart jbedMmsMessagePart : parts) {
            body.addPart(jbedMmsMessagePart.getPduPart());
        }
        if (parts.length == 0) {
            PduPart part2 = new PduPart();
            part2.setCharset(106);
            part2.setContentId("dummy".getBytes());
            part2.setContentType("text/html".getBytes());
            part2.setContentLocation(new byte[]{AmsConstants.PERM_ANSWER_ALWAYS});
            part2.setData(new byte[]{AmsConstants.PERM_ANSWER_ALWAYS});
            body.addPart(part2);
        }
        if (DEBUG) {
            if (DEBUG) {
                Log.d(TAG, " startContentId=" + startContentId);
            }
            for (int i2 = 0; i2 < allHeaderFields.length; i2++) {
                if (DEBUG) {
                    Log.d(TAG, "sendInternal()  header[" + i2 + "]=" + allHeaderFields[i2]);
                }
            }
            for (int i3 = 0; i3 < allPartHeaderFields.length; i3++) {
                if (DEBUG) {
                    Log.d(TAG, "sendInternal()  partheader[" + i3 + "]=" + allPartHeaderFields[i3]);
                }
            }
            for (int i4 = 0; i4 < partIndex.length; i4++) {
                if (DEBUG) {
                    Log.d(TAG, "sendInternal()  partindex[" + i4 + "]=" + partIndex[i4]);
                }
            }
        }
        Uri uri = JbedMmsMessage.send(this.mContext, allHeaderFields, body);
        log("sendInternal nativeContext=" + nativeContext + " uri=" + uri.toString());
        if (uri == null) {
            return -1;
        }
        this.mSendResultNativeContextMap.put(Long.valueOf(ContentUris.parseId(uri)), Integer.valueOf(nativeContext));
        return 0;
    }

    private byte[] retrieveMessageInternal() {
        byte[] bytes;
        synchronized (this.mReceivedMessages) {
            if (this.mReceivedMessages.size() == 0) {
                bytes = null;
            } else {
                log("retrieveMessagePartInternal() " + this.mReceivedMessages.get(0).toString());
                bytes = this.mReceivedMessages.get(0).toBytes();
            }
        }
        return bytes;
    }

    private byte[] retrieveMessagePartInternal(int msgId, int partArrayIndex) throws ConcurrentModificationException {
        for (JbedMmsMessage msg : this.mReceivedMessages) {
            if (msg.getId() == msgId) {
                JbedMmsMessagePart part = msg.getPart(partArrayIndex);
                boolean isLastPart = partArrayIndex + 1 == msg.mParts.size();
                if (isLastPart) {
                    this.mReceivedMessages.remove(msg);
                }
                if (msg.mContentId.equals("<dummy>")) {
                    return null;
                }
                log("retrieveMessagePartInternal() " + part.toString() + " isLastPart=" + isLastPart);
                return part.toBytes(isLastPart);
            }
        }
        return null;
    }

    private void disposePendingMessageInternal() {
        for (JbedMmsMessage msg : this.mReceivedMessages) {
            msg.dispose();
        }
        this.mReceivedMessages.clear();
    }

    private static byte[] checkPushMessage(String appId) {
        for (JbedMmsMessage msg : INSTANCE.mReceivedMessages) {
            if (msg.getAppId().equals(appId) && !msg.isChecked()) {
                msg.setCheck(true);
                return msg.getFrom();
            }
        }
        return null;
    }

    private int registerInternal(JbedMmsPort port) {
        if (this.mRegPorts.indexOf(port) != -1) {
            Log.w(TAG, "register a appID which has been reigstered");
            return -1;
        }
        this.mRegPorts.add(port);
        return 0;
    }

    private int deregisterInternal(JbedMmsPort port) throws ConcurrentModificationException {
        for (JbedMmsMessage msg : this.mReceivedMessages) {
            if (msg.getAppId().equals(port.mAppId)) {
                msg.dispose();
                this.mReceivedMessages.remove(msg);
            }
        }
        if (this.mRegPorts.remove(port)) {
            return 0;
        }
        Log.e(TAG, "deregister remove a un-registe app ID");
        return -1;
    }

    static String[] decodeBytesToStrings(byte[] bytes) {
        List<String> result = new ArrayList<>();
        int from = 0;
        for (int i = 0; i < bytes.length; i++) {
            if (bytes[i] == 0) {
                try {
                    result.add(new String(bytes, from, i - from, "UTF-8"));
                    from = i + 1;
                } catch (UnsupportedEncodingException e) {
                    result.add("error encoding");
                    Log.e(TAG, "decodeBytesToStrings UnsupportedEncodingException ", e);
                }
            }
        }
        return (String[]) result.toArray(new String[result.size()]);
    }

    static class JbedMmsPort {
        String mAppId;
        PushType mType;

        public JbedMmsPort(String port, boolean isStatic, boolean isPush) {
            this.mType = PushType.NONE;
            this.mAppId = port;
            if (isStatic) {
                this.mType = PushType.STATIC;
            } else if (isPush) {
                this.mType = PushType.DYNMAIC;
            } else {
                this.mType = PushType.NONE;
            }
        }

        public boolean equals(Object o) {
            JbedMmsPort mmsPort = (JbedMmsPort) o;
            if (o == null) {
                return false;
            }
            return this.mAppId.equals(mmsPort.mAppId) && this.mType == mmsPort.mType;
        }

        public boolean isPush() {
            return this.mType == PushType.STATIC || this.mType == PushType.DYNMAIC;
        }
    }

    static byte[] retrieveMessage() {
        byte[] result = INSTANCE.retrieveMessageInternal();
        if (result == null) {
            log(" retrieveMessage() have no more message!");
        } else {
            log(" retrieveMessage() data size=" + result.length);
        }
        return result;
    }

    static byte[] retrieveMessagePart(int msgId, int partArrayIndex) {
        byte[] result = null;
        try {
            result = INSTANCE.retrieveMessagePartInternal(msgId, partArrayIndex);
        } catch (ConcurrentModificationException e) {
            log("retrieveMessagePartInternal() makes CME");
        }
        if (result == null) {
            log(" retrieveMessagePart() have no more message! msgId=" + msgId + " partIndex=" + partArrayIndex);
        } else {
            log(" retrieveMessagePart() msgId=" + msgId + " partIndex=" + partArrayIndex + "data size=" + result.length);
        }
        return result;
    }

    static int storeDataPiece(int index, byte[] data, int len) {
        return INSTANCE.storeDataPieceInternal(index, data, len);
    }

    static byte[] getDataPiece(int index, int from, int len) {
        return INSTANCE.getDataPieceInternal(index, from, len);
    }

    static int send(int nativeContext, byte[] headerFields, byte[] partHeaderFields, int[] partIndex) {
        return INSTANCE.sendInternal(nativeContext, headerFields, partHeaderFields, partIndex);
    }

    private static void disposePendingMessage() {
        INSTANCE.disposePendingMessageInternal();
    }

    private static void disposeMessagePart(int index) {
        INSTANCE.mPartStore[index] = null;
    }

    static int registerPort(String appId, boolean isStatic, boolean isPush) {
        return INSTANCE.registerInternal(new JbedMmsPort(appId, isStatic, isPush));
    }

    static int deregisterPort(String appId, boolean isStatic, boolean isPush) {
        try {
            int ret = INSTANCE.deregisterInternal(new JbedMmsPort(appId, isStatic, isPush));
            return ret;
        } catch (ConcurrentModificationException e) {
            log("deregisterInternal makes CME");
            return 0;
        }
    }

    private void notifyNewMessage(final boolean isPush) {
        Message msg = this.mHandler.obtainMessage(3);
        msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedMmsManager.2
            @Override // java.lang.Runnable
            public void run() {
                JbedMmsManager.log("-----------notifyNewMessage() have new message--------- ");
                JbedMmsManager.nativeNotifyNewMms(isPush);
            }
        };
        msg.sendToTarget();
    }
}
