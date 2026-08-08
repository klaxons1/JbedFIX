package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.util.Log;
import com.esmertec.android.jbed.ams.JbedSelectorData;
import com.google.android.mms.pdu.CharacterSets;
import com.google.android.mms.pdu.PduPart;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Comparator;

/* JADX INFO: compiled from: JbedMmsManager.java */
/* JADX INFO: loaded from: classes.dex */
class JbedMmsMessagePart {
    static final /* synthetic */ boolean $assertionsDisabled;
    static final byte MMS_CONTENTID_INDEX = 0;
    static final byte MMS_ENCODING_INDEX = 3;
    static final byte MMS_LOCATION_INDEX = 2;
    static final byte MMS_MIMETYPE_INDEX = 1;
    private Context mContext;
    private byte[] mData;
    String[] mHeaderFields = new String[4];
    int mIndex;
    private PduPart mPduPart;

    static {
        $assertionsDisabled = !JbedMmsMessagePart.class.desiredAssertionStatus();
    }

    /* JADX INFO: compiled from: JbedMmsManager.java */
    static class StartCotentIdCompartor implements Comparator<JbedMmsMessagePart> {
        private String mStartContentId;

        public StartCotentIdCompartor(String startCotentId) {
            this.mStartContentId = startCotentId;
        }

        @Override // java.util.Comparator
        public int compare(JbedMmsMessagePart p1, JbedMmsMessagePart p2) {
            String p1ContentId = new String(p1.mPduPart.getContentId());
            return p1ContentId.equals(this.mStartContentId) ? -1 : 1;
        }
    }

    JbedMmsMessagePart(Context context, int index) {
        this.mContext = context;
        this.mIndex = index;
    }

    public void write(byte[] data, int len) {
        byte[] tmp;
        int from = 0;
        if (this.mData == null) {
            tmp = new byte[len];
        } else {
            tmp = new byte[this.mData.length + len];
            from = this.mData.length;
            System.arraycopy(this.mData, 0, tmp, 0, this.mData.length);
        }
        System.arraycopy(data, 0, tmp, from, len);
        this.mData = tmp;
    }

    public byte[] read(int from, int len) {
        if (!$assertionsDisabled && from + len >= this.mData.length) {
            throw new AssertionError();
        }
        if (this.mData == null && this.mPduPart != null) {
            this.mData = loadData();
        }
        if (this.mData == null) {
            Log.e(JbedMmsManager.TAG, "[part] failed to read data which is null!!");
            return null;
        }
        byte[] ret = new byte[len];
        System.arraycopy(this.mData, from, ret, 0, len);
        return ret;
    }

    public void fillPduPart() {
        if (this.mPduPart == null) {
            this.mPduPart = new PduPart();
        }
        int charset = CharacterSets.getMibEnumValue(this.mHeaderFields[3].toLowerCase());
        this.mPduPart.setCharset(charset == 0 ? 106 : charset);
        this.mPduPart.setContentId(this.mHeaderFields[0].getBytes());
        this.mPduPart.setContentType(this.mHeaderFields[1].getBytes());
        this.mPduPart.setContentLocation(this.mHeaderFields[2].getBytes());
        this.mPduPart.setData(this.mData);
    }

    public void setPduPart(PduPart pduPart) {
        this.mPduPart = pduPart;
    }

    public PduPart getPduPart() {
        return this.mPduPart;
    }

    public int getDataLength() {
        int i;
        if (this.mData != null) {
            return this.mData.length;
        }
        if (this.mPduPart == null) {
            return 0;
        }
        byte[] data = this.mPduPart.getData();
        if (data != null) {
            return data.length;
        }
        InputStream is = null;
        try {
            try {
                is = this.mContext.getContentResolver().openInputStream(this.mPduPart.getDataUri());
                byte[] buf = new byte[8096];
                int totalRead = 0;
                while (true) {
                    int bytesRead = is.read(buf);
                    if (bytesRead == -1) {
                        break;
                    }
                    totalRead += bytesRead;
                }
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e) {
                    }
                }
                i = totalRead;
            } catch (FileNotFoundException e2) {
                Log.e(JbedMmsManager.TAG, "failed to find " + this.mPduPart.getDataUri().toString(), e2);
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e3) {
                    }
                }
                i = 0;
            } catch (IOException e4) {
                Log.e(JbedMmsManager.TAG, "failed to read " + this.mPduPart.getDataUri().toString(), e4);
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e5) {
                    }
                }
                i = 0;
            }
            return i;
        } catch (Throwable th) {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException e6) {
                }
            }
            throw th;
        }
    }

    byte[] loadData() {
        byte[] result = this.mPduPart.getData();
        if (result == null) {
            InputStream is = null;
            try {
                is = this.mContext.getContentResolver().openInputStream(this.mPduPart.getDataUri());
                ByteArrayOutputStream os = new ByteArrayOutputStream();
                byte[] buf = new byte[8096];
                while (true) {
                    int bytesRead = is.read(buf);
                    if (bytesRead == -1) {
                        break;
                    }
                    os.write(buf, 0, bytesRead);
                }
                result = os.toByteArray();
            } catch (IOException e) {
                Log.e(JbedMmsManager.TAG, "failed to read " + this.mPduPart.getDataUri().toString(), e);
                return null;
            } finally {
                if (is != null) {
                    try {
                        is.close();
                    } catch (IOException e3) {
                    }
                }
            }
        }
        return result;
    }

    private void writeString(DataOutputStream out, byte flag, byte[] data) throws IOException {
        if (data == null) {
            data = JbedSelectorData.EXT_NULL.getBytes();
        }
        out.writeByte(flag);
        out.write(data);
        out.writeByte(0);
    }

    public byte[] toBytes(boolean isLastPart) {
        if (this.mPduPart == null) {
            Log.e(JbedMmsManager.TAG, "part.toBytes() : the pdupart is null! can't get the bytes");
            return null;
        }
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            out.writeInt(this.mIndex);
            out.writeInt(getDataLength());
            out.writeInt(isLastPart ? 1 : 0);
            int charset = this.mPduPart.getCharset();
            if (charset == -1) {
                charset = 106;
            }
            writeString(out, (byte) 1, this.mPduPart.getContentType());
            writeString(out, MMS_CONTENTID_INDEX, this.mPduPart.getContentId());
            writeString(out, (byte) 2, this.mPduPart.getContentLocation());
            writeString(out, MMS_ENCODING_INDEX, CharacterSets.getMimeName(charset).getBytes());
            return bo.toByteArray();
        } catch (Exception e) {
            Log.e(JbedMmsManager.TAG, " failed to convert the part to bytes", e);
            return null;
        }
    }

    public String toString() {
        return "id=" + this.mIndex + " len=" + getDataLength() + " charset=" + this.mPduPart.getCharset() + " location=" + this.mPduPart.getContentLocation() + " mime=" + this.mPduPart.getContentType() + " contentid=" + this.mPduPart.getContentId();
    }
}
