package com.esmertec.android.jbed;

import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.os.Parcel;
import android.util.Log;

/* JADX INFO: compiled from: JbedConfig.java */
/* JADX INFO: loaded from: classes.dex */
class JbedCustomizationUtils {
    private static final String LOG_TAG = "CustomizationUtils";
    private static final String UADATA_VALUE_KEY = "value";
    private static final String VALUE_COLUMN_NAME = "value";

    JbedCustomizationUtils() {
    }

    public static Bundle loadCustomizationData(Context context, Uri customizeURI, String selection) {
        Cursor c = null;
        try {
            ContentResolver cr = context.getContentResolver();
            String[] projection = {"value"};
            c = cr.query(customizeURI, projection, selection, null, null);
            if (c == null) {
                if (Log.isLoggable(LOG_TAG, 6)) {
                    Log.e(LOG_TAG, "load customize URI failed, Cursor is null: " + customizeURI.toString());
                }
                return null;
            }
            if (c.moveToFirst()) {
                byte[] data = c.getBlob(0);
                Bundle bundle = byteArray2Bundle(data);
                return bundle;
            }
            if (Log.isLoggable(LOG_TAG, 6)) {
                Log.e(LOG_TAG, "load customize URI failed, !c.moveToFirst(): " + customizeURI.toString());
            }
            return null;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    private static Bundle byteArray2Bundle(byte[] data) {
        Parcel parcel = Parcel.obtain();
        parcel.unmarshall(data, 0, data.length);
        parcel.setDataPosition(0);
        Bundle bundle = new Bundle();
        bundle.readFromParcel(parcel);
        return bundle;
    }

    public static String getUaData(Bundle bundle, String key) {
        Bundle ua_stringBundle = bundle.getBundle(key);
        if (ua_stringBundle == null) {
            return null;
        }
        return ua_stringBundle.getString("value");
    }
}
