package com.esmertec.android.jbed.ams;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedAmsConnection extends IInterface {
    List<JbedSelectorData> getRunningMidletList() throws RemoteException;

    void onClientConnected(IJbedAmsClient iJbedAmsClient) throws RemoteException;

    void onClientDisconnected(IJbedAmsClient iJbedAmsClient) throws RemoteException;

    void requestEvent(int i, int i2, byte[] bArr) throws RemoteException;

    void setPowerOnMidlets(List<JbedSelectorData> list) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedAmsConnection {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.ams.IJbedAmsConnection";
        static final int TRANSACTION_getRunningMidletList = 5;
        static final int TRANSACTION_onClientConnected = 3;
        static final int TRANSACTION_onClientDisconnected = 4;
        static final int TRANSACTION_requestEvent = 1;
        static final int TRANSACTION_setPowerOnMidlets = 2;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedAmsConnection asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedAmsConnection)) {
                return (IJbedAmsConnection) iin;
            }
            return new Proxy(obj);
        }

        @Override // android.os.IInterface
        public IBinder asBinder() {
            return this;
        }

        @Override // android.os.Binder
        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            switch (code) {
                case 1:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg0 = data.readInt();
                    int _arg1 = data.readInt();
                    byte[] _arg2 = data.createByteArray();
                    requestEvent(_arg0, _arg1, _arg2);
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    List<JbedSelectorData> _arg3 = data.createTypedArrayList(JbedSelectorData.CREATOR);
                    setPowerOnMidlets(_arg3);
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedAmsClient _arg4 = IJbedAmsClient.Stub.asInterface(data.readStrongBinder());
                    onClientConnected(_arg4);
                    reply.writeNoException();
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedAmsClient _arg5 = IJbedAmsClient.Stub.asInterface(data.readStrongBinder());
                    onClientDisconnected(_arg5);
                    reply.writeNoException();
                    return true;
                case 5:
                    data.enforceInterface(DESCRIPTOR);
                    List<JbedSelectorData> _result = getRunningMidletList();
                    reply.writeNoException();
                    reply.writeTypedList(_result);
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedAmsConnection {
            private IBinder mRemote;

            Proxy(IBinder remote) {
                this.mRemote = remote;
            }

            @Override // android.os.IInterface
            public IBinder asBinder() {
                return this.mRemote;
            }

            public String getInterfaceDescriptor() {
                return Stub.DESCRIPTOR;
            }

            @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
            public void requestEvent(int eventId, int result, byte[] data) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(eventId);
                    _data.writeInt(result);
                    _data.writeByteArray(data);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
            public void setPowerOnMidlets(List<JbedSelectorData> midlets) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeTypedList(midlets);
                    this.mRemote.transact(2, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
            public void onClientConnected(IJbedAmsClient amsClient) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeStrongBinder(amsClient != null ? amsClient.asBinder() : null);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
            public void onClientDisconnected(IJbedAmsClient amsClient) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeStrongBinder(amsClient != null ? amsClient.asBinder() : null);
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.ams.IJbedAmsConnection
            public List<JbedSelectorData> getRunningMidletList() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(5, _data, _reply, 0);
                    _reply.readException();
                    List<JbedSelectorData> _result = _reply.createTypedArrayList(JbedSelectorData.CREATOR);
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
