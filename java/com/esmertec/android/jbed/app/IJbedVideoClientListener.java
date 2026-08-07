package com.esmertec.android.jbed.app;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import com.esmertec.android.jbed.jsr.JbedVideoPlayerState;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedVideoClientListener extends IInterface {
    void onCompletion() throws RemoteException;

    void onError(int i, int i2) throws RemoteException;

    void onPrepared() throws RemoteException;

    void onSuspend(JbedVideoPlayerState jbedVideoPlayerState) throws RemoteException;

    void restoreState() throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedVideoClientListener {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.app.IJbedVideoClientListener";
        static final int TRANSACTION_onCompletion = 1;
        static final int TRANSACTION_onError = 3;
        static final int TRANSACTION_onPrepared = 2;
        static final int TRANSACTION_onSuspend = 4;
        static final int TRANSACTION_restoreState = 5;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedVideoClientListener asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedVideoClientListener)) {
                return (IJbedVideoClientListener) iin;
            }
            return new Proxy(obj);
        }

        @Override // android.os.IInterface
        public IBinder asBinder() {
            return this;
        }

        @Override // android.os.Binder
        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            JbedVideoPlayerState _arg0;
            switch (code) {
                case 1:
                    data.enforceInterface(DESCRIPTOR);
                    onCompletion();
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    onPrepared();
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg1 = data.readInt();
                    int _arg2 = data.readInt();
                    onError(_arg1, _arg2);
                    reply.writeNoException();
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    if (data.readInt() != 0) {
                        _arg0 = JbedVideoPlayerState.CREATOR.createFromParcel(data);
                    } else {
                        _arg0 = null;
                    }
                    onSuspend(_arg0);
                    reply.writeNoException();
                    return true;
                case 5:
                    data.enforceInterface(DESCRIPTOR);
                    restoreState();
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedVideoClientListener {
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

            @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
            public void onCompletion() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
            public void onPrepared() throws RemoteException {
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

            @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
            public void onError(int arg1, int arg2) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(arg1);
                    _data.writeInt(arg2);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
            public void onSuspend(JbedVideoPlayerState state) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    if (state != null) {
                        _data.writeInt(1);
                        state.writeToParcel(_data, 0);
                    } else {
                        _data.writeInt(0);
                    }
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClientListener
            public void restoreState() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(5, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
