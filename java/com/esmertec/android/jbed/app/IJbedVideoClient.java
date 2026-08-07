package com.esmertec.android.jbed.app;

import android.graphics.Bitmap;
import android.graphics.Rect;
import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;
import com.esmertec.android.jbed.jsr.JbedVideoPlayerState;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedVideoClient extends IInterface {
    byte[] getSnapshotFromCamera() throws RemoteException;

    Bitmap getSnapshotFromMedia() throws RemoteException;

    int operation(int i, int i2, int i3, int i4, int i5) throws RemoteException;

    int prepareData(String str) throws RemoteException;

    void reconnectCamera() throws RemoteException;

    void restorePlayerState(JbedVideoPlayerState jbedVideoPlayerState) throws RemoteException;

    void setListener(IJbedVideoClientListener iJbedVideoClientListener) throws RemoteException;

    void updateDisplayRect(Rect rect) throws RemoteException;

    void updateRegionRect(Rect rect) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedVideoClient {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.app.IJbedVideoClient";
        static final int TRANSACTION_getSnapshotFromCamera = 5;
        static final int TRANSACTION_getSnapshotFromMedia = 4;
        static final int TRANSACTION_operation = 2;
        static final int TRANSACTION_prepareData = 1;
        static final int TRANSACTION_reconnectCamera = 6;
        static final int TRANSACTION_restorePlayerState = 7;
        static final int TRANSACTION_setListener = 3;
        static final int TRANSACTION_updateDisplayRect = 8;
        static final int TRANSACTION_updateRegionRect = 9;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedVideoClient asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedVideoClient)) {
                return (IJbedVideoClient) iin;
            }
            return new Proxy(obj);
        }

        @Override // android.os.IInterface
        public IBinder asBinder() {
            return this;
        }

        @Override // android.os.Binder
        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            Rect _arg0;
            Rect _arg1;
            JbedVideoPlayerState _arg2;
            switch (code) {
                case 1:
                    data.enforceInterface(DESCRIPTOR);
                    String _arg3 = data.readString();
                    int _result = prepareData(_arg3);
                    reply.writeNoException();
                    reply.writeInt(_result);
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg4 = data.readInt();
                    int _arg5 = data.readInt();
                    int _arg6 = data.readInt();
                    int _arg7 = data.readInt();
                    int _arg8 = data.readInt();
                    int _result2 = operation(_arg4, _arg5, _arg6, _arg7, _arg8);
                    reply.writeNoException();
                    reply.writeInt(_result2);
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    IJbedVideoClientListener _arg9 = IJbedVideoClientListener.Stub.asInterface(data.readStrongBinder());
                    setListener(_arg9);
                    reply.writeNoException();
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    Bitmap _result3 = getSnapshotFromMedia();
                    reply.writeNoException();
                    if (_result3 != null) {
                        reply.writeInt(1);
                        _result3.writeToParcel(reply, 1);
                    } else {
                        reply.writeInt(0);
                    }
                    return true;
                case 5:
                    data.enforceInterface(DESCRIPTOR);
                    byte[] _result4 = getSnapshotFromCamera();
                    reply.writeNoException();
                    reply.writeByteArray(_result4);
                    return true;
                case 6:
                    data.enforceInterface(DESCRIPTOR);
                    reconnectCamera();
                    reply.writeNoException();
                    return true;
                case 7:
                    data.enforceInterface(DESCRIPTOR);
                    if (data.readInt() != 0) {
                        _arg2 = JbedVideoPlayerState.CREATOR.createFromParcel(data);
                    } else {
                        _arg2 = null;
                    }
                    restorePlayerState(_arg2);
                    reply.writeNoException();
                    return true;
                case 8:
                    data.enforceInterface(DESCRIPTOR);
                    if (data.readInt() != 0) {
                        _arg1 = (Rect) Rect.CREATOR.createFromParcel(data);
                    } else {
                        _arg1 = null;
                    }
                    updateDisplayRect(_arg1);
                    reply.writeNoException();
                    return true;
                case 9:
                    data.enforceInterface(DESCRIPTOR);
                    if (data.readInt() != 0) {
                        _arg0 = (Rect) Rect.CREATOR.createFromParcel(data);
                    } else {
                        _arg0 = null;
                    }
                    updateRegionRect(_arg0);
                    reply.writeNoException();
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedVideoClient {
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

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public int prepareData(String url) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeString(url);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                    int _result = _reply.readInt();
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public int operation(int playerId, int opId, int param1, int param2, int param3) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(playerId);
                    _data.writeInt(opId);
                    _data.writeInt(param1);
                    _data.writeInt(param2);
                    _data.writeInt(param3);
                    this.mRemote.transact(2, _data, _reply, 0);
                    _reply.readException();
                    int _result = _reply.readInt();
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public void setListener(IJbedVideoClientListener listener) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeStrongBinder(listener != null ? listener.asBinder() : null);
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public Bitmap getSnapshotFromMedia() throws RemoteException {
                Bitmap _result;
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                    if (_reply.readInt() != 0) {
                        _result = (Bitmap) Bitmap.CREATOR.createFromParcel(_reply);
                    } else {
                        _result = null;
                    }
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public byte[] getSnapshotFromCamera() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(5, _data, _reply, 0);
                    _reply.readException();
                    byte[] _result = _reply.createByteArray();
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public void reconnectCamera() throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    this.mRemote.transact(6, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public void restorePlayerState(JbedVideoPlayerState state) throws RemoteException {
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
                    this.mRemote.transact(7, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public void updateDisplayRect(Rect rect) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    if (rect != null) {
                        _data.writeInt(1);
                        rect.writeToParcel(_data, 0);
                    } else {
                        _data.writeInt(0);
                    }
                    this.mRemote.transact(8, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.app.IJbedVideoClient
            public void updateRegionRect(Rect rect) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    if (rect != null) {
                        _data.writeInt(1);
                        rect.writeToParcel(_data, 0);
                    } else {
                        _data.writeInt(0);
                    }
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
