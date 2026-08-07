package com.esmertec.android.jbed.ams;

import android.util.Log;
import java.io.UnsupportedEncodingException;

/* JADX INFO: loaded from: classes.dex */
public class AmsEvent {
    public static final String TAG = "AmsEvent";
    public final byte[] mData;
    public final int mId;
    public Object mObj;
    public final int mResult;

    public AmsEvent(int eventId, int result, byte[] data) {
        this.mId = eventId;
        this.mResult = result;
        this.mData = data;
    }

    public String getDataAsUtf8() {
        String str;
        if (this.mData != null) {
            try {
                if (this.mData[this.mData.length - 1] == 0) {
                    str = new String(this.mData, 0, this.mData.length - 1, "utf-8");
                } else {
                    str = new String(this.mData, "utf-8");
                }
                return str;
            } catch (UnsupportedEncodingException e) {
                Log.e(TAG, "Failed to decode data with Utf8");
            }
        }
        return null;
    }

    public String toString() {
        String ret = "[" + AmsClientBase.getEventName(this.mId) + "] mResult=" + this.mResult;
        return this.mData == null ? ret + " with empty data" : ret + ", len=" + this.mData.length;
    }
}
