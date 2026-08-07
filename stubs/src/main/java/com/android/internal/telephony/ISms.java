package com.android.internal.telephony;

import android.app.PendingIntent;
import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.RemoteException;

public interface ISms extends IInterface {
    void sendRawPdu(byte[] smsc, byte[] pdu, PendingIntent sentIntent, PendingIntent deliveryIntent) throws RemoteException;
    void sendRawPdu(byte[] smsc, byte[] pdu, PendingIntent sentIntent, PendingIntent deliveryIntent, boolean bFirstOfAll, boolean bLastOfAll) throws RemoteException;

    abstract class Stub extends Binder implements ISms {
        public static ISms asInterface(IBinder obj) {
            return null;
        }
    }
}
