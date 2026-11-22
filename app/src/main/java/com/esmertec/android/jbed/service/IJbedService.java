package com.esmertec.android.jbed.service;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import com.esmertec.android.jbed.ams.IJbedAmsConnection;
import com.esmertec.android.jbed.nativeui.IJbedTextFieldConnection;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedService extends IInterface {
    IJbedAmsConnection openAmsConnection() throws RemoteException;

    IJbedConnection openConnection() throws RemoteException;

    IJbedTextFieldConnection openTextFieldConnection() throws RemoteException;

    void requestVmBackground() throws RemoteException;

    void setRotateHappen(boolean z) throws RemoteException;

    void setStartWay(boolean z) throws RemoteException;

    void setVmState(int i, int i2) throws RemoteException;

    void shutdownVm() throws RemoteException;

    void startVm(int i, int i2, int i3, int i4, int i5, boolean z, boolean z2) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedService {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.service.IJbedService";
        static final int TRANSACTION_openAmsConnection = 4;
        static final int TRANSACTION_openConnection = 3;
        static final int TRANSACTION_openTextFieldConnection = 5;
        static final int TRANSACTION_requestVmBackground = 9;
        static final int TRANSACTION_setRotateHappen = 7;
        static final int TRANSACTION_setStartWay = 8;
        static final int TRANSACTION_setVmState = 6;
        static final int TRANSACTION_shutdownVm = 2;
        static final int TRANSACTION_startVm = 1;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedService asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedService)) {
                return (IJbedService) iin;
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
                    boolean _arg5 = data.readInt() != 0;
                    boolean _arg6 = data.readInt() != 0;
                    startVm(_arg0, _arg1, _arg2, _arg3, _arg4, _arg5, _arg6);
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    shutdownVm();
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedConnection _result = openConnection();
                    reply.writeNoException();
                    reply.writeStrongBinder(_result != null ? _result.asBinder() : null);
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedAmsConnection _result2 = openAmsConnection();
                    reply.writeNoException();
                    reply.writeStrongBinder(_result2 != null ? _result2.asBinder() : null);
                    return true;
                case 5:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedTextFieldConnection _result3 = openTextFieldConnection();
                    reply.writeNoException();
                    reply.writeStrongBinder(_result3 != null ? _result3.asBinder() : null);
                    return true;
                case 6:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg7 = data.readInt();
                    int _arg8 = data.readInt();
                    setVmState(_arg7, _arg8);
                    reply.writeNoException();
                    return true;
                case 7:
                    data.enforceInterface(DESCRIPTOR);
                    boolean _arg9 = data.readInt() != 0;
                    setRotateHappen(_arg9);
                    reply.writeNoException();
                    return true;
                case 8:
                    data.enforceInterface(DESCRIPTOR);
                    boolean _arg10 = data.readInt() != 0;
                    setStartWay(_arg10);
                    reply.writeNoException();
                    return true;
                case 9:
                    data.enforceInterface(DESCRIPTOR);
                    requestVmBackground();
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedService {
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

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void startVm(int viewWidth, int viewHeight, int bytesPerPixel, int viewFullScreenWidth, int viewFullScreenHeight, boolean isRefreshViewSize, boolean forceSizeChanged) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(viewWidth);
                    _data.writeInt(viewHeight);
                    _data.writeInt(bytesPerPixel);
                    _data.writeInt(viewFullScreenWidth);
                    _data.writeInt(viewFullScreenHeight);
                    _data.writeInt(isRefreshViewSize ? 1 : 0);
                    _data.writeInt(forceSizeChanged ? 1 : 0);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void shutdownVm() throws RemoteException {
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

            @Override // com.esmertec.android.jbed.service.IJbedService
            public IJbedConnection openConnection() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                    IJbedConnection _result = IJbedConnection.Stub.asInterface(_reply.readStrongBinder());
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public IJbedAmsConnection openAmsConnection() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                    IJbedAmsConnection _result = IJbedAmsConnection.Stub.asInterface(_reply.readStrongBinder());
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public IJbedTextFieldConnection openTextFieldConnection() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(5, _data, _reply, 0);
                    _reply.readException();
                    IJbedTextFieldConnection _result = IJbedTextFieldConnection.Stub.asInterface(_reply.readStrongBinder());
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void setVmState(int state, int reason) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(state);
                    _data.writeInt(reason);
                    this.mRemote.transact(6, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void setRotateHappen(boolean b) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(b ? 1 : 0);
                    this.mRemote.transact(7, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void setStartWay(boolean b) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(b ? 1 : 0);
                    this.mRemote.transact(8, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.service.IJbedService
            public void requestVmBackground() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(9, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
