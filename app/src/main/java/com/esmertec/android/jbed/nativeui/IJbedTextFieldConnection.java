package com.esmertec.android.jbed.nativeui;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedTextFieldConnection extends IInterface {
    void onTextChanged(int i, String str) throws RemoteException;

    void requestRefresh(int i) throws RemoteException;

    void setClient(IJbedTextFieldClient iJbedTextFieldClient) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedTextFieldConnection {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection";
        static final int TRANSACTION_onTextChanged = 2;
        static final int TRANSACTION_requestRefresh = 3;
        static final int TRANSACTION_setClient = 1;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedTextFieldConnection asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedTextFieldConnection)) {
                return (IJbedTextFieldConnection) iin;
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
                    IJbedTextFieldClient _arg0 = IJbedTextFieldClient.Stub.asInterface(data.readStrongBinder());
                    setClient(_arg0);
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg1 = data.readInt();
                    String _arg2 = data.readString();
                    onTextChanged(_arg1, _arg2);
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg3 = data.readInt();
                    requestRefresh(_arg3);
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedTextFieldConnection {
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

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
            public void setClient(IJbedTextFieldClient client) throws RemoteException {
                Parcel _data = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeStrongBinder(client != null ? client.asBinder() : null);
                    this.mRemote.transact(1, _data, null, 1);
                } finally {
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
            public void onTextChanged(int id, String text) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeString(text);
                    this.mRemote.transact(2, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection
            public void requestRefresh(int id) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
