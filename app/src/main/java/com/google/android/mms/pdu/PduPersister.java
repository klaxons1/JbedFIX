package com.google.android.mms.pdu;
import android.content.Context; import android.net.Uri; import com.google.android.mms.MmsException;
/** Build-time compatibility facade for APIs removed from the public SDK. */
public final class PduPersister { private PduPersister(){} public static PduPersister getPduPersister(Context c){return new PduPersister();} public RetrieveConf load(Uri uri) throws MmsException { throw new MmsException("MMS PDU access is unavailable on this Android version"); } public Uri persist(SendReq request, Uri uri) throws MmsException { throw new MmsException("MMS PDU access is unavailable on this Android version"); } }
