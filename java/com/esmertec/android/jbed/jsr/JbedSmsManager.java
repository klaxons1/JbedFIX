package com.esmertec.android.jbed.jsr;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.SmsManager;
import android.telephony.SmsMessage;
import android.text.TextUtils;
import android.util.Log;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.service.JbedService;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedSmsManager extends BroadcastReceiver implements JbedService.LifecycleListener {
    static final boolean DEBUG = false;
    static final int ENC_8BIT_BIN = 1;
    static final int ENC_ASCII = 3;
    static final int ENC_GSM_7BIT = 0;
    static final int ENC_UCS_2 = 2;
    private static JbedSmsManager INSTANCE = null;
    static final String TAG = "JbedSmsManager";
    private Context mContext;
    private Handler mHandler;
    List<NewMessageListener> mListeners = new ArrayList();
    private static HashMap<Integer, SmsReceiver> receiverMap = new HashMap<>();
    private static String MESSAGE_SENT_ACTION = "jbed.intent.action.SMS.MESSAGE_SENT";
    private static String NATIVE_CONTEXT_KEY = "nativeContext";

    public interface NewMessageListener {
        void notifyNewSms(String str, int i, int i2, int i3, long j, byte[] bArr);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifyNewSms(String str, int i, int i2, int i3, long j, byte[] bArr);

    /* JADX INFO: Access modifiers changed from: private */
    public static native void nativeNotifySmsSendResult(int i, boolean z);

    public JbedSmsManager(Handler handler) {
        this.mHandler = handler;
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mContext = context;
        IntentFilter filter = new IntentFilter();
        filter.addAction(MESSAGE_SENT_ACTION);
        context.registerReceiver(this, filter);
        this.mListeners.add(new NewMessageListener() { // from class: com.esmertec.android.jbed.jsr.JbedSmsManager.1
            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.NewMessageListener
            public void notifyNewSms(final String srcAddr, final int srcPort, final int dstPort, final int encoding, final long timestamp, final byte[] payload) {
                Message msg = JbedSmsManager.this.mHandler.obtainMessage(3);
                msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedSmsManager.1.1
                    @Override // java.lang.Runnable
                    public void run() {
                        JbedSmsManager.nativeNotifyNewSms(srcAddr, srcPort, dstPort, encoding, timestamp, payload);
                    }
                };
                msg.sendToTarget();
            }
        });
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        deregisterAll();
        this.mListeners.clear();
        INSTANCE = null;
    }

    public static int register(int port) {
        if (receiverMap.containsKey(Integer.valueOf(port))) {
            Log.e(TAG, " have registered this port " + port);
            return -1;
        }
        SmsReceiver receiver = new SmsReceiver(port, INSTANCE.mHandler);
        receiverMap.put(Integer.valueOf(port), receiver);
        IntentFilter filter = new IntentFilter();
        filter.addAction(JbedConstants.ACTION_JBED_PUSH_SMS);
        INSTANCE.mContext.registerReceiver(receiver, filter);
        return 0;
    }

    public static int deregister(int port) {
        if (!receiverMap.containsKey(Integer.valueOf(port))) {
            Log.w(TAG, " port " + port + " haven't been registered");
            return -1;
        }
        INSTANCE.mContext.unregisterReceiver(receiverMap.remove(Integer.valueOf(port)));
        return 0;
    }

    private static void deregisterAll() {
        Iterator<SmsReceiver> receivers = receiverMap.values().iterator();
        while (receivers.hasNext()) {
            INSTANCE.mContext.unregisterReceiver(receivers.next());
        }
        receiverMap.clear();
        INSTANCE.mContext.unregisterReceiver(INSTANCE);
    }

    static String getText(byte[] payload, int type) throws UnsupportedEncodingException {
        switch (type) {
            case 1:
                return null;
            case 2:
                try {
                    String result = new String(payload, "utf-16be");
                    return result;
                } catch (UnsupportedEncodingException e) {
                    throw new UnsupportedEncodingException();
                }
            case 3:
                String result2 = new String(payload);
                return result2;
            default:
                throw new IllegalArgumentException("JbedSmsManager unsupport type = " + type);
        }
    }

    private static int sendSms(int nativeContext, String dstAddr, int dstPort, byte[] payload, int type) throws UnsupportedEncodingException {
        JbedSmsSender.SmsData data;
        String text = getText(payload, type);
        Intent intent = new Intent(MESSAGE_SENT_ACTION);
        intent.putExtra(NATIVE_CONTEXT_KEY, Integer.valueOf(nativeContext));
        if (text == null) {
            data = new JbedSmsSender.BinarySmsData(dstAddr, dstPort, null, payload);
        } else {
            data = new JbedSmsSender.TextSmsData(dstAddr, dstPort, null, text);
        }
        int messageCount = data.size();
        List<PendingIntent> sentIntents = new ArrayList<>(messageCount);
        for (int i = 0; i < messageCount; i++) {
            sentIntents.add(PendingIntent.getBroadcast(INSTANCE.mContext, 0, intent, 0));
        }
        if (messageCount == 1) {
            data.sendSinglepartMessage(sentIntents.get(0));
        } else {
            data.sendMultipartMessage(sentIntents);
        }
        return 0;
    }

    @Override // android.content.BroadcastReceiver
    public void onReceive(Context context, final Intent intent) {
        Message msg = this.mHandler.obtainMessage(3);
        msg.obj = new Runnable() { // from class: com.esmertec.android.jbed.jsr.JbedSmsManager.2
            @Override // java.lang.Runnable
            public void run() {
                if (JbedSmsManager.MESSAGE_SENT_ACTION.equals(intent.getAction())) {
                    int nativeContext = intent.getIntExtra(JbedSmsManager.NATIVE_CONTEXT_KEY, -1);
                    Log.w(JbedSmsManager.TAG, " success to send sms nativecontext=" + nativeContext);
                    JbedSmsManager.nativeNotifySmsSendResult(nativeContext, true);
                }
            }
        };
        msg.sendToTarget();
    }

    /* Detect the SMS data coding scheme from the raw PDU. Returns 1 = 7-bit,
       2 = 8-bit, 3 = 16-bit (UCS-2), 0 = unknown. */
    private static int getPduEncoding(byte[] pdu) {
        if (pdu == null || pdu.length == 0) {
            return 0;
        }
        try {
            int i = 0;
            int smscLen = pdu[i] & 255;
            i += smscLen + 1;
            if (i >= pdu.length) {
                return 0;
            }
            i++;
            if (i >= pdu.length) {
                return 0;
            }
            int addrLen = pdu[i] & 255;
            i += 2 + ((addrLen + 1) >> 1);
            if (i >= pdu.length) {
                return 0;
            }
            i++;
            if (i >= pdu.length) {
                return 0;
            }
            int dcs = pdu[i] & 255;
            switch ((dcs >> 2) & 3) {
                case 0:
                    return 1;
                case 1:
                    return 2;
                case 2:
                    return 3;
                default:
                    return 0;
            }
        } catch (IndexOutOfBoundsException e) {
            return 0;
        }
    }

    static class SmsReceiver extends BroadcastReceiver {
        private Handler mHandler;
        private int mPort;

        SmsReceiver(int port, Handler handler) {
            this.mPort = port;
            this.mHandler = handler;
        }

        private SmsMessage[] getMessagesFromIntent(Intent intent) {
            Bundle extras = intent.getExtras();
            if (extras == null) {
                return new SmsMessage[0];
            }
            Object[] messages = (Object[]) extras.get("pdus");
            if (messages == null) {
                return new SmsMessage[0];
            }
            String format = extras.getString("format");
            int len = messages.length;
            SmsMessage[] msgs = new SmsMessage[len];
            for (int i = 0; i < len; i++) {
                if (Build.VERSION.SDK_INT >= 23) {
                    msgs[i] = SmsMessage.createFromPdu((byte[]) messages[i], format);
                } else {
                    msgs[i] = SmsMessage.createFromPdu((byte[]) messages[i]);
                }
            }
            return msgs;
        }

        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            int encoding;
            Intent SmsIntent = (Intent) intent.getParcelableExtra(JbedConstants.ACTION_JBED_PUSH_SMS);
            if (SmsIntent == null) {
                return;
            }
            Uri uri = SmsIntent.getData();
            if (uri == null || uri.getPort() != this.mPort) {
                return;
            }
            SmsMessage[] messages = getMessagesFromIntent(SmsIntent);
            if (messages.length == 0 || messages[0] == null) {
                return;
            }
            int len = messages.length;
            byte[] payload = null;
            int encoding2 = JbedSmsManager.getPduEncoding(messages[0].getPdu());
            if (encoding2 == 2 || encoding2 == 0) {
                encoding = 1;
                byte[][] userdata = new byte[len][];
                for (int i = 0; i < len; i++) {
                    userdata[i] = messages[i].getUserData();
                }
                payload = mergeData(userdata);
                Log.i(JbedSmsManager.TAG, "onReceive get binary message =");
                if (payload != null) {
                    for (int i2 = 0; i2 < payload.length; i2++) {
                        Log.i(JbedSmsManager.TAG, "  data[" + i2 + "]= " + ((int) payload[i2]));
                    }
                }
            } else {
                encoding = 2;
                String messageText = "";
                for (SmsMessage smsMessage : messages) {
                    if (smsMessage.getMessageBody() != null) {
                        messageText = messageText + smsMessage.getMessageBody();
                    }
                }
                try {
                    payload = messageText.getBytes("UTF-16BE");
                } catch (UnsupportedEncodingException e) {
                    Log.e(JbedSmsManager.TAG, "UnsupportedEncodingException");
                }
                Log.i(JbedSmsManager.TAG, "onReceive get text message =" + messageText);
            }
            for (NewMessageListener listener : JbedSmsManager.INSTANCE.mListeners) {
                listener.notifyNewSms(messages[0].getOriginatingAddress(), 0, this.mPort, encoding, messages[0].getTimestampMillis(), payload);
            }
        }

        private byte[] mergeData(byte[][] data) {
            int segmentLen = data.length;
            if (segmentLen == 1) {
                return data[0];
            }
            int totalSize = 0;
            for (byte[] bArr : data) {
                if (bArr != null) {
                    totalSize += bArr.length;
                }
            }
            byte[] ret = new byte[totalSize];
            int curPos = 0;
            for (int i = 0; i < segmentLen; i++) {
                if (data[i] != null) {
                    System.arraycopy(data[i], 0, ret, curPos, data[i].length);
                    curPos += data[i].length;
                }
            }
            return ret;
        }
    }

    static class JbedSmsSender {
        private static final int MAX_USER_DATA_BYTES_LONG_PORT_SMS = 128;
        private static final int MAX_USER_DATA_BYTES_PORT_SMS = 132;
        private static final int MAX_USER_DATA_CHARS_LONG_PORT_SMS = 146;
        private static final int MAX_USER_DATA_CHARS_PORT_SMS = 153;

        JbedSmsSender() {
        }

        private static void sendDataMessage(String dstAddr, int dstPort, byte[] data, PendingIntent sentIntent) {
            SmsManager.getDefault().sendDataMessage(dstAddr, null, (short) dstPort, data, sentIntent, null);
        }

        private static abstract class SmsData {
            protected String mDstAddr;
            protected int mDstPort;
            protected String mSrcAddr;

            public abstract int size();

            public abstract void sendSinglepartMessage(PendingIntent pendingIntent);

            public abstract void sendMultipartMessage(List<PendingIntent> list);

            public SmsData(String dstAddr, int dstPort, String srcAddr) {
                this.mDstAddr = dstAddr;
                this.mDstPort = dstPort;
                this.mSrcAddr = srcAddr;
            }

            boolean hasPort() {
                return (this.mDstPort == -1 || this.mDstPort == 0) ? false : true;
            }
        }

        private static class TextSmsData extends SmsData {
            private List<String> mData;

            TextSmsData(String dstAddr, int dstPort, String srcAddr, String text) {
                super(dstAddr, dstPort, srcAddr);
                this.mData = divideMessage(text);
            }

            private List<String> divideMessage(String text) {
                if (!hasPort()) {
                    return SmsManager.getDefault().divideMessage(text);
                }
                List<String> result = new ArrayList<>();
                if (text.length() == 0) {
                    result.add("");
                    return result;
                }
                int count = ((text.length() - 1) / JbedSmsSender.MAX_USER_DATA_CHARS_LONG_PORT_SMS) + 1;
                int chunkSize = count > 1 ? JbedSmsSender.MAX_USER_DATA_CHARS_LONG_PORT_SMS : JbedSmsSender.MAX_USER_DATA_CHARS_PORT_SMS;
                int start = 0;
                while (start < text.length()) {
                    int end = Math.min(start + chunkSize, text.length());
                    result.add(text.substring(start, end));
                    start = end;
                }
                return result;
            }

            private static byte[] toBytes(String text) {
                try {
                    return text.getBytes("UTF-16BE");
                } catch (UnsupportedEncodingException e) {
                    return text.getBytes();
                }
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public int size() {
                return this.mData.size();
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendSinglepartMessage(PendingIntent sentIntent) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (size() == 0) {
                    throw new IllegalArgumentException("Invalid message body");
                }
                if (hasPort()) {
                    JbedSmsSender.sendDataMessage(this.mDstAddr, this.mDstPort, toBytes(this.mData.get(0)), sentIntent);
                } else {
                    SmsManager.getDefault().sendTextMessage(this.mDstAddr, null, this.mData.get(0), sentIntent, null);
                }
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendMultipartMessage(List<PendingIntent> sentIntents) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (size() == 0) {
                    throw new IllegalArgumentException("Invalid message body");
                }
                if (hasPort()) {
                    int count = this.mData.size();
                    for (int i = 0; i < count; i++) {
                        JbedSmsSender.sendDataMessage(this.mDstAddr, this.mDstPort, toBytes(this.mData.get(i)), sentIntents.get(i));
                    }
                    return;
                }
                SmsManager.getDefault().sendMultipartTextMessage(this.mDstAddr, null, new ArrayList<>(this.mData), new ArrayList<>(sentIntents), null);
            }
        }

        private static class BinarySmsData extends SmsData {
            private final List<byte[]> mData;

            public BinarySmsData(String dstAddr, int dstPort, String srcAddr, byte[] payload) {
                super(dstAddr, dstPort, srcAddr);
                this.mData = divideMessageWithPort(payload);
            }

            private static List<byte[]> divideMessageWithPort(byte[] payload) {
                List<byte[]> result = new ArrayList<>();
                if (payload.length == 0) {
                    result.add(new byte[0]);
                    return result;
                }
                if (payload.length <= JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS) {
                    result.add(payload);
                    return result;
                }
                int start = 0;
                while (start < payload.length) {
                    int end = Math.min(start + JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS, payload.length);
                    byte[] fragment = new byte[end - start];
                    System.arraycopy(payload, start, fragment, 0, fragment.length);
                    result.add(fragment);
                    start = end;
                }
                return result;
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public int size() {
                return this.mData.size();
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendSinglepartMessage(PendingIntent sentIntent) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (this.mData.get(0) == null) {
                    throw new IllegalArgumentException("Invalid message data");
                }
                if (!hasPort()) {
                    throw new UnsupportedOperationException("don't support send binary without port");
                }
                JbedSmsSender.sendDataMessage(this.mDstAddr, this.mDstPort, this.mData.get(0), sentIntent);
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendMultipartMessage(List<PendingIntent> sentIntents) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (size() == 0) {
                    throw new IllegalArgumentException("Invalid message body");
                }
                if (!hasPort()) {
                    throw new UnsupportedOperationException("don't support send binary without port");
                }
                int count = this.mData.size();
                for (int i = 0; i < count; i++) {
                    JbedSmsSender.sendDataMessage(this.mDstAddr, this.mDstPort, this.mData.get(i), sentIntents.get(i));
                }
            }
        }
    }
}
