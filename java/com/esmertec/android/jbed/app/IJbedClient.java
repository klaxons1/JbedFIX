package com.esmertec.android.jbed.app;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedClient extends IInterface {
    void finish() throws RemoteException;

    IJbedVideoClient getVideoClient() throws RemoteException;

    void onSoftButtonChanged(String str, String str2) throws RemoteException;

    void repaint(int i, int i2, int i3, int i4, int i5, int i6, float f, float f2) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedClient {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.app.IJbedClient";
        static final int TRANSACTION_finish = 2;
        static final int TRANSACTION_getVideoClient = 3;
        static final int TRANSACTION_onSoftButtonChanged = 4;
        static final int TRANSACTION_repaint = 1;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedClient asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedClient)) {
                return (IJbedClient) iin;
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
                    int _arg2 = data.readInt();
                    int _arg3 = data.readInt();
                    int _arg4 = data.readInt();
                    int _arg5 = data.readInt();
                    float _arg6 = data.readFloat();
                    float _arg7 = data.readFloat();
                    repaint(_arg0, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6, _arg7);
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    finish();
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedVideoClient _result = getVideoClient();
                    reply.writeNoException();
                    reply.writeStrongBinder(_result != null ? _result.asBinder() : null);
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    String _arg8 = data.readString();
                    String _arg9 = data.readString();
                    onSoftButtonChanged(_arg8, _arg9);
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedClient {
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

            @Override // com.esmertec.android.jbed.app.IJbedClient
            public void repaint(int clipLeft, int clipTop, int clipRight, int clipBottom, int width, int height, float pScale, float lScale) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(clipLeft);
                    _data.writeInt(clipTop);
                    _data.writeInt(clipRight);
                    _data.writeInt(clipBottom);
                    _data.writeInt(width);
                    _data.writeInt(height);
                    _data.writeFloat(pScale);
                    _data.writeFloat(lScale);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedClient
            public void finish() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(2, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedClient
            public IJbedVideoClient getVideoClient() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                    IJbedVideoClient _result = IJbedVideoClient.Stub.asInterface(_reply.readStrongBinder());
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedClient
            public void onSoftButtonChanged(String leftButton, String rightButton) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeString(leftButton);
                    _data.writeString(rightButton);
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
