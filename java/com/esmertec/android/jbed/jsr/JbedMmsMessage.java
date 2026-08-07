package com.esmertec.android.jbed.jsr;

import android.content.ContentUris;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.provider.Telephony;
import android.util.Log;
import com.google.android.mms.MmsException;
import com.google.android.mms.pdu.EncodedStringValue;
import com.google.android.mms.pdu.PduBody;
import com.google.android.mms.pdu.PduPersister;
import com.google.android.mms.pdu.RetrieveConf;
import com.google.android.mms.pdu.SendReq;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/* JADX INFO: compiled from: JbedMmsManager.java */
/* JADX INFO: loaded from: classes.dex */
class JbedMmsMessage {
    private static final boolean DEBUG = JbedMmsManager.DEBUG;
    static final String DUMMY_CONTENTID = "dummy";
    static final byte MMS_APP_ID_FLAG = 5;
    static final byte MMS_CC_ADRS_FLAG = 9;
    static final byte MMS_DATE_FLAG = 6;
    static final byte MMS_DELIVERY_FLAG = 3;
    static final byte MMS_FROM_FLAG = 1;
    static final byte MMS_PRIORITY_FLAG = 4;
    public static final String MMS_PROTOCOL = "mms://";
    static final byte MMS_START_CONTENT_ID_FLAG = 7;
    static final byte MMS_SUBJECT_FLAG = 2;
    static final byte MMS_TO_ADRS_FLAG = 8;
    private String mAppId;
    public String mContentId;
    private Context mContext;
    private long mId;
    private boolean mIsChecked;
    private JbedMmsManager mManager;
    List<JbedMmsMessagePart> mParts;
    private RetrieveConf mRetrieveConf;

    JbedMmsMessage(Context context, JbedMmsManager manager, RetrieveConf retrieveConf, long uriId, String appId) {
        this.mParts = new ArrayList();
        this.mContext = context;
        this.mManager = manager;
        this.mRetrieveConf = retrieveConf;
        this.mId = uriId;
        this.mAppId = appId;
        buildParts();
    }

    JbedMmsMessage(Context context, JbedMmsManager manager, Uri uri, String appId) throws Exception {
        this(context, manager, PduPersister.getPduPersister(context).load(uri), ContentUris.parseId(uri), appId);
    }

    public void setCheck(boolean isChecked) {
        this.mIsChecked = isChecked;
    }

    public boolean isChecked() {
        return this.mIsChecked;
    }

    public byte[] getFrom() {
        return getFromAddress(this.mRetrieveConf);
    }

    public String getAppId() {
        return this.mAppId;
    }

    public int getId() {
        return (int) this.mId;
    }

    public JbedMmsMessagePart getPart(int arrayIndex) {
        if (arrayIndex >= this.mParts.size()) {
            return null;
        }
        return this.mParts.get(arrayIndex);
    }

    public void dispose() {
        for (int i = 0; i < this.mParts.size(); i++) {
            this.mManager.mPartStore[this.mParts.get(i).mIndex] = null;
        }
        this.mParts.clear();
    }

    static Uri send(Context context, String[] headerFields, PduBody body) {
        SendReq request = new SendReq();
        setHeaderFields(request, headerFields);
        request.setBody(body);
        try {
            Uri uri = PduPersister.getPduPersister(context).persist(request, Telephony.Mms.Outbox.CONTENT_URI);
            Intent intent = new Intent().setClassName(TransactionService.APP_PACKAGE_NAME, TransactionService.CLASS_NAME);
            Bundle bundle = new Bundle();
            bundle.putInt(TransactionService.TRANSACTION_TYPE, 2);
            bundle.putString("uri", uri.toString());
            intent.putExtras(bundle);
            if (DEBUG) {
                Log.v(JbedMmsManager.TAG, "Starting service");
            }
            context.startService(intent);
            if (DEBUG) {
                Log.v(JbedMmsManager.TAG, "Service started");
            }
            return uri;
        } catch (MmsException e) {
            Log.e(JbedMmsManager.TAG, "failed to send mms ", e);
            return null;
        }
    }

    static String[] decodeAddress(String address) {
        String[] result = new String[2];
        if (address.startsWith(MMS_PROTOCOL)) {
            String address2 = address.substring(MMS_PROTOCOL.length());
            int pos = address2.indexOf(":");
            if (pos != -1) {
                result[0] = address2.substring(0, pos);
                result[1] = address2.substring(pos + 1);
            } else {
                result[0] = address2;
                result[1] = null;
            }
        } else {
            result[0] = address;
            result[1] = null;
        }
        return result;
    }

    private static void setHeaderFields(SendReq request, String[] headerFields) {
        for (int i = 0; i < headerFields.length; i += 2) {
            String name = headerFields[i];
            String value = headerFields[i + 1];
            EncodedStringValue encodingValue = new EncodedStringValue(106, value.getBytes());
            if (name.equals("X-Mms-Delivery-Time")) {
                Log.w(JbedMmsManager.TAG, "WARNING: android doesn't support X-Mms-Delivery-Time");
            } else if (name.equals("StartContentId")) {
                continue;
            } else if (name.equals("X-Mms-To")) {
                String[] addr = decodeAddress(value);
                request.addTo(new EncodedStringValue(106, addr[0].getBytes()));
                if (addr[1] != null) {
                }
            } else if (name.equals("X-Mms-CC")) {
                String[] addr2 = decodeAddress(value);
                request.addCc(new EncodedStringValue(106, addr2[0].getBytes()));
            } else if (name.equals("X-Mms-BCC")) {
                String[] addr3 = decodeAddress(value);
                request.addBcc(new EncodedStringValue(106, addr3[0].getBytes()));
            } else if (name.equals("X-Mms-From")) {
                String[] addr4 = decodeAddress(value);
                if (addr4[1] != null) {
                }
            } else if (name.equals("X-Mms-Priority")) {
                try {
                    request.setPriority(Integer.parseInt(value));
                } catch (Exception e) {
                    Log.e(JbedMmsManager.TAG, "failed to setPriority", e);
                }
            } else if (name.equals("X-Mms-Subject")) {
                request.setSubject(encodingValue);
            } else if (name.equals("Date")) {
                if (value.equals("unknown")) {
                    request.setDate(new Date().getTime());
                } else if (value.length() > 0) {
                    request.setDate(Long.parseLong(value));
                }
            } else {
                throw new IllegalArgumentException("unknow field " + name);
            }
        }
    }

    static String getStartContentId(String[] headerFields) {
        for (int i = 0; i < headerFields.length; i += 2) {
            String name = headerFields[i];
            String value = headerFields[i + 1];
            if (name.equals("StartContentId")) {
                return value;
            }
        }
        return null;
    }

    private void buildParts() {
        int partNum = this.mRetrieveConf.getBody().getPartsNum();
        if (DEBUG) {
            Log.d(JbedMmsManager.TAG, "MmsMessage: buildParts() partNum =" + partNum);
        }
        for (int i = 0; i < partNum; i++) {
            int index = this.mManager.findEmptyIndex();
            if (index == -1) {
                throw new RuntimeException(" have no memory to hold the message part!");
            }
            this.mManager.mPartStore[index].setPduPart(this.mRetrieveConf.getBody().getPart(i));
            this.mParts.add(this.mManager.mPartStore[index]);
        }
    }

    private void writeString(DataOutputStream out, byte flag, byte[] data) throws IOException {
        if (data != null) {
            out.writeByte(flag);
            out.write(data);
            out.writeByte(0);
        }
    }

    private static byte[] getUtf8Bytes(String s) {
        try {
            if (s.length() == 0) {
                return null;
            }
            return s.getBytes("utf-8");
        } catch (UnsupportedEncodingException e) {
            Log.e(JbedMmsManager.TAG, "getUtf8Bytes UnsupportedEncodingException", e);
            return null;
        }
    }

    private static byte[] getUtf8Bytes(EncodedStringValue s) {
        if (s != null) {
            try {
                if (s.getString().length() != 0) {
                    return s.getString().getBytes("utf-8");
                }
            } catch (UnsupportedEncodingException e) {
                Log.e(JbedMmsManager.TAG, "getUtf8Bytes UnsupportedEncodingException", e);
                return null;
            }
        }
        return null;
    }

    static byte[] convertToMmsProtocolAddress(EncodedStringValue esv) {
        String s = esv.getString();
        if (s.indexOf("@") == -1) {
            s = MMS_PROTOCOL + s;
        }
        return getUtf8Bytes(s);
    }

    static byte[] getFromAddress(RetrieveConf retrieveConf) {
        if (retrieveConf == null || retrieveConf.getFrom() == null) {
            return null;
        }
        String fromAddr = retrieveConf.getFrom().getString();
        if (fromAddr.indexOf("@") == -1) {
            fromAddr = MMS_PROTOCOL + fromAddr;
        }
        return getUtf8Bytes(fromAddr);
    }

    byte[] toBytes() {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            out.writeInt(getId());
            writeString(out, (byte) 2, getUtf8Bytes(this.mRetrieveConf.getSubject()));
            writeString(out, (byte) 1, getFromAddress(this.mRetrieveConf));
            writeString(out, MMS_DATE_FLAG, getUtf8Bytes(String.valueOf(this.mRetrieveConf.getDate())));
            writeString(out, (byte) 4, getUtf8Bytes(String.valueOf(this.mRetrieveConf.getPriority())));
            if (this.mRetrieveConf.getBody().getPartsNum() > 0) {
                this.mContentId = new String(this.mRetrieveConf.getBody().getPart(0).getContentId());
                writeString(out, MMS_START_CONTENT_ID_FLAG, this.mContentId.getBytes());
            }
            writeString(out, MMS_APP_ID_FLAG, getUtf8Bytes(this.mAppId));
            EncodedStringValue[] tmp = this.mRetrieveConf.getTo();
            for (int i = 0; tmp != null && i < tmp.length; i++) {
                writeString(out, (byte) 8, convertToMmsProtocolAddress(tmp[i]));
            }
            EncodedStringValue[] tmp2 = this.mRetrieveConf.getCc();
            for (int i2 = 0; tmp2 != null && i2 < tmp2.length; i2++) {
                writeString(out, MMS_CC_ADRS_FLAG, convertToMmsProtocolAddress(tmp2[i2]));
            }
            return bo.toByteArray();
        } catch (Exception e) {
            Log.e(JbedMmsManager.TAG, " failed to convert the mms message to bytes", e);
            return null;
        }
    }

    public String toString() {
        return "id=" + this.mId + " subject=" + this.mRetrieveConf.getSubject() + " from=" + this.mRetrieveConf.getFrom() + " date=" + this.mRetrieveConf.getDate() + " priority=" + this.mRetrieveConf.getPriority();
    }
}
