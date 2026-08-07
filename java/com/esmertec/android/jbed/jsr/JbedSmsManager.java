package com.esmertec.android.jbed.jsr;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Handler;
import android.os.Message;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.telephony.PhoneNumberUtils;
import android.telephony.gsm.SmsManager;
import android.telephony.gsm.SmsMessage;
import android.text.TextUtils;
import android.util.Log;
import com.android.internal.telephony.EncodeException;
import com.android.internal.telephony.GsmAlphabet;
import com.android.internal.telephony.ISms;
import com.android.internal.telephony.SmsHeader;
import com.esmertec.android.jbed.JbedConstants;
import com.esmertec.android.jbed.ams.AmsConstants;
import com.esmertec.android.jbed.service.JbedService;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

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
        SmsManager.getDefault();
        String text = getText(payload, type);
        Intent intent = new Intent(MESSAGE_SENT_ACTION);
        intent.putExtra(NATIVE_CONTEXT_KEY, new Integer(nativeContext));
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

    static class SmsReceiver extends BroadcastReceiver {
        private Handler mHandler;
        private int mPort;

        SmsReceiver(int port, Handler handler) {
            this.mPort = port;
            this.mHandler = handler;
        }

        private SmsMessage[] getMessagesFromIntent(Intent intent) {
            Object[] messages = (Object[]) intent.getSerializableExtra("pdus");
            int len = messages.length;
            SmsMessage[] msgs = new SmsMessage[len];
            for (int i = 0; i < len; i++) {
                msgs[i] = SmsMessage.createFromPdu((byte[]) messages[i]);
            }
            return msgs;
        }

        @Override // android.content.BroadcastReceiver
        public void onReceive(Context context, Intent intent) {
            int encoding;
            Intent SmsIntent = (Intent) intent.getExtra(JbedConstants.ACTION_JBED_PUSH_SMS);
            Uri uri = SmsIntent.getData();
            if (uri.getPort() == this.mPort) {
                SmsMessage[] messages = getMessagesFromIntent(SmsIntent);
                int len = messages.length;
                byte[] payload = null;
                int encoding2 = messages[0].mWrappedSmsMessage.encodingType;
                if (encoding2 == 2 || encoding2 == 0) {
                    encoding = 1;
                    byte[][] userdata = new byte[len][];
                    for (int i = 0; i < len; i++) {
                        userdata[i] = messages[i].getUserData();
                    }
                    payload = mergeData(userdata);
                    Log.i(JbedSmsManager.TAG, "onReceive get binary message =");
                    for (int i2 = 0; i2 < payload.length; i2++) {
                        Log.i(JbedSmsManager.TAG, "  data[" + i2 + "]= " + ((int) payload[i2]));
                    }
                } else {
                    encoding = 2;
                    String messageText = "";
                    for (SmsMessage smsMessage : messages) {
                        messageText = messageText + smsMessage.getMessageBody();
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
        }

        private byte[] mergeData(byte[][] data) {
            int segmentLen = data.length;
            if (segmentLen == 1) {
                return data[0];
            }
            int totalSize = 0;
            for (byte[] bArr : data) {
                totalSize += bArr.length;
            }
            byte[] ret = new byte[totalSize];
            int curPos = 0;
            for (int i = 0; i < segmentLen; i++) {
                System.arraycopy(data[i], 0, ret, curPos, data[i].length);
                curPos += data[i].length;
            }
            return ret;
        }
    }

    static class JbedSmsSender {
        private static final int MAX_USER_DATA_BYTES = 140;
        private static final int MAX_USER_DATA_BYTES_LONG_PORT_SMS = 128;
        private static final int MAX_USER_DATA_BYTES_PORT_SMS = 132;
        private static final int MAX_USER_DATA_SEPTETS = 160;
        private static final int MAX_USER_DATA_SEPTETS_LONG_PORT_SMS = 146;
        private static final int MAX_USER_DATA_SEPTETS_PORT_SMS = 153;

        JbedSmsSender() {
        }

        /* JADX INFO: Access modifiers changed from: private */
        public static byte[] getConcatenatedData(int refId, int totalParts, int currentPart) {
            byte[] data = {(byte) refId, (byte) totalParts, (byte) (currentPart + 1)};
            return data;
        }

        /* JADX INFO: Access modifiers changed from: private */
        public static void sendRawPdu(byte[] smsc, byte[] pdu, PendingIntent sentIntent, PendingIntent deliveryIntent, boolean bFirstOfAll, boolean bLastOfAll) {
            try {
                ISms simISms = ISms.Stub.asInterface(ServiceManager.getService("isms"));
                if (simISms != null) {
                    simISms.sendRawPdu(smsc, pdu, sentIntent, deliveryIntent, bFirstOfAll, bLastOfAll);
                }
            } catch (RemoteException e) {
            }
        }

        /* JADX INFO: Access modifiers changed from: private */
        public static ByteArrayOutputStream getSubmitPduHead(String scAddress, String destinationAddress, byte mtiByte, boolean statusReportRequested, SmsMessage.SubmitPdu ret) {
            ByteArrayOutputStream bo = new ByteArrayOutputStream(180);
            if (scAddress == null) {
                ret.encodedScAddress = null;
            } else {
                ret.encodedScAddress = PhoneNumberUtils.networkPortionToCalledPartyBCDWithLength(scAddress);
            }
            if (statusReportRequested) {
                mtiByte = (byte) (mtiByte | AmsConstants.PERM_ANSWER_ALWAYS);
            }
            bo.write(mtiByte);
            bo.write(0);
            byte[] daBytes = PhoneNumberUtils.networkPortionToCalledPartyBCD(destinationAddress);
            bo.write(((daBytes.length - 1) * 2) - ((daBytes[daBytes.length - 1] & 240) == 240 ? 1 : 0));
            bo.write(daBytes, 0, daBytes.length);
            bo.write(0);
            return bo;
        }

        private static abstract class SmsData {
            protected String mDstAddr;
            protected int mDstPort;
            protected String mSrcAddr;

            abstract SmsMessage.SubmitPdu getSubmitPdu(int i, byte[] bArr);

            public abstract void sendByDefault(List<PendingIntent> list);

            public abstract void sendSinglepartMessage(PendingIntent pendingIntent);

            public abstract int size();

            public SmsData(String dstAddr, int dstPort, String srcAddr) {
                this.mDstAddr = dstAddr;
                this.mDstPort = dstPort;
                this.mSrcAddr = srcAddr;
            }

            public void sendMultipartMessage(List<PendingIntent> sentIntents) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (size() == 0) {
                    throw new IllegalArgumentException("Invalid message body");
                }
                if (!hasPort()) {
                    sendByDefault(sentIntents);
                    return;
                }
                int sConcatenatedRef = new Random().nextInt(256);
                int ref = (sConcatenatedRef + 1) & 255;
                int count = size();
                for (int i = 0; i < count; i++) {
                    byte[] concatenatedInfo = JbedSmsSender.getConcatenatedData(ref, count, i);
                    SmsMessage.SubmitPdu pdus = getSubmitPdu(i, concatenatedInfo);
                    JbedSmsSender.sendRawPdu(pdus.encodedScAddress, pdus.encodedMessage, sentIntents.get(i), null, false, false);
                }
            }

            boolean hasPort() {
                return (this.mDstPort == -1 || this.mDstPort == 0) ? false : true;
            }
        }

        private static class TextSmsData extends SmsData {
            private List<String> mData;

            TextSmsData(String dstAddr, int dstPort, String srcAddr, String text) {
                super(dstAddr, dstPort, srcAddr);
                this.mData = divideMessageWithPort(text);
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public int size() {
                return this.mData.size();
            }

            private static int[] calculateLength(String messageBody) {
                int[] ret = new int[4];
                try {
                    int septets = GsmAlphabet.countGsmSeptets(messageBody, true);
                    ret[1] = septets;
                    if (septets > JbedSmsSender.MAX_USER_DATA_SEPTETS_PORT_SMS) {
                        ret[0] = (septets / JbedSmsSender.MAX_USER_DATA_SEPTETS_LONG_PORT_SMS) + 1;
                        ret[2] = septets % JbedSmsSender.MAX_USER_DATA_SEPTETS_LONG_PORT_SMS;
                    } else {
                        ret[0] = 1;
                        ret[2] = JbedSmsSender.MAX_USER_DATA_SEPTETS_PORT_SMS - septets;
                    }
                    ret[3] = 1;
                } catch (EncodeException e) {
                    int octets = messageBody.length() * 2;
                    ret[1] = octets;
                    if (octets > JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS) {
                        ret[0] = (octets / JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS) + 1;
                        ret[2] = octets % JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS;
                    } else {
                        ret[0] = 1;
                        ret[2] = JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS - octets;
                    }
                    ret[3] = 3;
                }
                return ret;
            }

            private static List<String> divideMessageWithPort(String text) {
                int contentAvailableSize;
                int[] params = calculateLength(text);
                int messageCount = params[0];
                List<String> result = new ArrayList<>(messageCount);
                if (text.length() == 0) {
                    result.add("");
                } else {
                    if (messageCount > 1) {
                        contentAvailableSize = params[3] == 3 ? JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS : JbedSmsSender.MAX_USER_DATA_SEPTETS_LONG_PORT_SMS;
                    } else {
                        contentAvailableSize = params[3] == 3 ? JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS : JbedSmsSender.MAX_USER_DATA_SEPTETS_PORT_SMS;
                    }
                    int fragmentStart = 0;
                    int textSize = params[3] == 3 ? text.length() * 2 : text.length();
                    if (params[3] == 3) {
                        while (fragmentStart < textSize) {
                            int fragmentEnd = fragmentStart + contentAvailableSize < textSize ? fragmentStart + contentAvailableSize : textSize;
                            result.add(text.substring(fragmentStart / 2, fragmentEnd / 2));
                            fragmentStart = fragmentEnd;
                        }
                    } else {
                        while (fragmentStart < textSize) {
                            int fragmentEnd2 = GsmAlphabet.findGsmSeptetLimitIndex(text, fragmentStart, contentAvailableSize);
                            result.add(text.substring(fragmentStart, fragmentEnd2));
                            fragmentStart = fragmentEnd2;
                        }
                    }
                }
                return result;
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendSinglepartMessage(PendingIntent sentIntent) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (hasPort()) {
                    SmsMessage.SubmitPdu pdus = getSubmitPdu(0, null);
                    JbedSmsSender.sendRawPdu(pdus.encodedScAddress, pdus.encodedMessage, sentIntent, null, false, false);
                } else {
                    ArrayList<PendingIntent> sentIntents = new ArrayList<>();
                    sentIntents.add(sentIntent);
                    sendByDefault(sentIntents);
                }
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendByDefault(List<PendingIntent> sentIntents) {
                SmsManager.getDefault().sendMultipartTextMessage(this.mDstAddr, null, (ArrayList) this.mData, (ArrayList) sentIntents, null);
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public SmsMessage.SubmitPdu getSubmitPdu(int index, byte[] concatenatedElementData) {
                String fragment = this.mData.get(index);
                if (fragment == null || this.mDstAddr == null) {
                    return null;
                }
                SmsMessage.SubmitPdu ret = new SmsMessage.SubmitPdu();
                ByteArrayOutputStream bo = JbedSmsSender.getSubmitPduHead(this.mSrcAddr, this.mDstAddr, (byte) 65, false, ret);
                byte[] portData = new byte[4];
                try {
                    SmsHeader header = new SmsHeader();
                    if (concatenatedElementData != null) {
                        SmsHeader.MiscElt misc = new SmsHeader.MiscElt();
                        misc.id = 0;
                        misc.data = concatenatedElementData;
                        header.miscEltList.add(misc);
                    }
                    portData[0] = (byte) ((this.mDstPort >> 8) & 255);
                    portData[1] = (byte) (this.mDstPort & 255);
                    portData[2] = 0;
                    portData[3] = 0;
                    SmsHeader.MiscElt misc2 = new SmsHeader.MiscElt();
                    misc2.id = 5;
                    misc2.data = portData;
                    header.miscEltList.add(misc2);
                    byte[] userData = GsmAlphabet.stringToGsm7BitPackedWithHeader(fragment, SmsHeader.toByteArray(header));
                    if ((userData[0] & 255) > JbedSmsSender.MAX_USER_DATA_SEPTETS) {
                        Log.w(JbedSmsManager.TAG, "getSubmitPdu Message too long");
                        return null;
                    }
                    bo.write(0);
                    bo.write(userData, 0, userData.length);
                    ret.encodedMessage = bo.toByteArray();
                    return ret;
                } catch (EncodeException e) {
                    try {
                        byte[] userData2 = fragment.getBytes("utf-16be");
                        if (userData2.length > JbedSmsSender.MAX_USER_DATA_BYTES) {
                            Log.w(JbedSmsManager.TAG, "getSubmitPdu Message too long");
                            return null;
                        }
                        bo.write(11);
                        bo.write(userData2.length + (concatenatedElementData == null ? 7 : 12));
                        bo.write(concatenatedElementData == null ? 6 : 11);
                        if (concatenatedElementData != null) {
                            bo.write(0);
                            bo.write(3);
                            bo.write(concatenatedElementData, 0, concatenatedElementData.length);
                        }
                        bo.write(5);
                        bo.write(4);
                        bo.write(portData, 0, portData.length);
                        bo.write(userData2, 0, userData2.length);
                    } catch (UnsupportedEncodingException e2) {
                        return null;
                    }
                }
            }
        }

        private static class BinarySmsData extends SmsData {
            private List<byte[]> mData;

            public BinarySmsData(String dstAddr, int dstPort, String srcAddr, byte[] payload) {
                super(dstAddr, dstPort, srcAddr);
                this.mData = divideMessageWithPort(payload);
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public int size() {
                return this.mData.size();
            }

            private static int[] calculateLength(byte[] payload) {
                int[] ret = new int[3];
                ret[1] = payload.length;
                if (ret[1] > JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS) {
                    ret[0] = (ret[1] / JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS) + 1;
                    ret[2] = ret[1] % JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS;
                } else {
                    ret[0] = 1;
                    ret[2] = JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS - ret[1];
                }
                return ret;
            }

            private List<byte[]> divideMessageWithPort(byte[] payload) {
                int contentAvailableSize;
                int[] params = calculateLength(payload);
                int messageCount = params[0];
                List<byte[]> result = new ArrayList<>(messageCount);
                if (payload.length == 0) {
                    result.add(new byte[0]);
                } else {
                    if (messageCount > 1) {
                        contentAvailableSize = JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS;
                    } else {
                        contentAvailableSize = JbedSmsSender.MAX_USER_DATA_BYTES_PORT_SMS;
                    }
                    int fragmentStart = 0;
                    while (fragmentStart < params[1]) {
                        int fragmentEnd = fragmentStart + contentAvailableSize < params[1] ? fragmentStart + contentAvailableSize : params[1];
                        int fragmentLen = fragmentEnd - fragmentStart;
                        byte[] fragment = new byte[fragmentLen];
                        System.arraycopy(payload, fragmentStart, fragment, 0, fragmentLen);
                        result.add(fragment);
                        fragmentStart = fragmentEnd;
                    }
                }
                return result;
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendSinglepartMessage(PendingIntent sentIntent) {
                if (TextUtils.isEmpty(this.mDstAddr)) {
                    throw new IllegalArgumentException("Invalid destinationAddress");
                }
                if (this.mData.get(0) == null) {
                    throw new IllegalArgumentException("Invalid message data");
                }
                SmsMessage.SubmitPdu pdus = SmsMessage.getSubmitPdu(this.mSrcAddr, this.mDstAddr, (short) this.mDstPort, this.mData.get(0), false);
                JbedSmsSender.sendRawPdu(pdus.encodedScAddress, pdus.encodedMessage, sentIntent, null, false, false);
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public SmsMessage.SubmitPdu getSubmitPdu(int index, byte[] concatenatedElementData) {
                byte[] fragment = this.mData.get(index);
                if (fragment.length > JbedSmsSender.MAX_USER_DATA_BYTES_LONG_PORT_SMS) {
                    Log.e(JbedSmsManager.TAG, "SMS data message may only contain 128 bytes");
                    return null;
                }
                SmsMessage.SubmitPdu ret = new SmsMessage.SubmitPdu();
                ByteArrayOutputStream bo = JbedSmsSender.getSubmitPduHead(this.mSrcAddr, this.mDstAddr, (byte) 65, false, ret);
                bo.write(4);
                bo.write(fragment.length + 12);
                bo.write(11);
                bo.write(0);
                bo.write(3);
                bo.write(concatenatedElementData, 0, concatenatedElementData.length);
                bo.write(5);
                bo.write(4);
                bo.write((this.mDstPort >> 8) & 255);
                bo.write(this.mDstPort & 255);
                bo.write(0);
                bo.write(0);
                bo.write(fragment, 0, fragment.length);
                ret.encodedMessage = bo.toByteArray();
                return ret;
            }

            @Override // com.esmertec.android.jbed.jsr.JbedSmsManager.JbedSmsSender.SmsData
            public void sendByDefault(List<PendingIntent> sentIntents) {
                throw new UnsupportedOperationException("don't support send binary without port");
            }
        }
    }
}
