package com.esmertec.android.jbed.nativeui;

import android.os.Binder;
import android.os.IBinder;
import android.os.IInterface;
import android.os.Parcel;
import android.os.RemoteException;

/* JADX INFO: loaded from: classes.dex */
public interface IJbedTextFieldClient extends IInterface {
    void calculateSizeHints(int i, int i2, int i3, int[] iArr) throws RemoteException;

    void create(int i) throws RemoteException;

    void dispose(int i) throws RemoteException;

    int getCaretPosition(int i) throws RemoteException;

    void replaceText(int i, int i2, int i3, String str) throws RemoteException;

    void setClip(int i, int i2, int i3, int i4, int i5) throws RemoteException;

    void setConstraints(int i, int i2) throws RemoteException;

    void setFocus(int i, boolean z) throws RemoteException;

    void setMaxSize(int i, int i2) throws RemoteException;

    void setPosition(int i, int i2, int i3, int i4, int i5, boolean z, int i6) throws RemoteException;

    void setText(int i, String str) throws RemoteException;

    public static abstract class Stub extends Binder implements IJbedTextFieldClient {
        private static final String DESCRIPTOR = "com.esmertec.android.jbed.nativeui.IJbedTextFieldClient";
        static final int TRANSACTION_calculateSizeHints = 3;
        static final int TRANSACTION_create = 1;
        static final int TRANSACTION_dispose = 5;
        static final int TRANSACTION_getCaretPosition = 11;
        static final int TRANSACTION_replaceText = 8;
        static final int TRANSACTION_setClip = 7;
        static final int TRANSACTION_setConstraints = 9;
        static final int TRANSACTION_setFocus = 4;
        static final int TRANSACTION_setMaxSize = 10;
        static final int TRANSACTION_setPosition = 2;
        static final int TRANSACTION_setText = 6;

        public Stub() {
            attachInterface(this, DESCRIPTOR);
        }

        public static IJbedTextFieldClient asInterface(IBinder obj) {
            if (obj == null) {
                return null;
            }
            IInterface iin = obj.queryLocalInterface(DESCRIPTOR);
            if (iin != null && (iin instanceof IJbedTextFieldClient)) {
                return (IJbedTextFieldClient) iin;
            }
            return new Proxy(obj);
        }

        @Override // android.os.IInterface
        public IBinder asBinder() {
            return this;
        }

        @Override // android.os.Binder
        public boolean onTransact(int code, Parcel data, Parcel reply, int flags) throws RemoteException {
            int[] _arg3;
            switch (code) {
                case 1:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg0 = data.readInt();
                    create(_arg0);
                    reply.writeNoException();
                    return true;
                case 2:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg1 = data.readInt();
                    int _arg2 = data.readInt();
                    int _arg4 = data.readInt();
                    int _arg5 = data.readInt();
                    int _arg6 = data.readInt();
                    boolean _arg7 = data.readInt() != 0;
                    int _arg8 = data.readInt();
                    setPosition(_arg1, _arg2, _arg4, _arg5, _arg6, _arg7, _arg8);
                    reply.writeNoException();
                    return true;
                case 3:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg9 = data.readInt();
                    int _arg10 = data.readInt();
                    int _arg11 = data.readInt();
                    int _arg3_length = data.readInt();
                    if (_arg3_length < 0) {
                        _arg3 = null;
                    } else {
                        _arg3 = new int[_arg3_length];
                    }
                    calculateSizeHints(_arg9, _arg10, _arg11, _arg3);
                    reply.writeNoException();
                    reply.writeIntArray(_arg3);
                    return true;
                case 4:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg12 = data.readInt();
                    boolean _arg13 = data.readInt() != 0;
                    setFocus(_arg12, _arg13);
                    reply.writeNoException();
                    return true;
                case 5:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg14 = data.readInt();
                    dispose(_arg14);
                    reply.writeNoException();
                    return true;
                case 6:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg15 = data.readInt();
                    String _arg16 = data.readString();
                    setText(_arg15, _arg16);
                    reply.writeNoException();
                    return true;
                case 7:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg17 = data.readInt();
                    int _arg18 = data.readInt();
                    int _arg19 = data.readInt();
                    int _arg20 = data.readInt();
                    int _arg21 = data.readInt();
                    setClip(_arg17, _arg18, _arg19, _arg20, _arg21);
                    reply.writeNoException();
                    return true;
                case 8:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg22 = data.readInt();
                    int _arg23 = data.readInt();
                    int _arg24 = data.readInt();
                    String _arg25 = data.readString();
                    replaceText(_arg22, _arg23, _arg24, _arg25);
                    reply.writeNoException();
                    return true;
                case 9:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg26 = data.readInt();
                    int _arg27 = data.readInt();
                    setConstraints(_arg26, _arg27);
                    reply.writeNoException();
                    return true;
                case 10:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg28 = data.readInt();
                    int _arg29 = data.readInt();
                    setMaxSize(_arg28, _arg29);
                    reply.writeNoException();
                    return true;
                case 11:
                    data.enforceInterface(DESCRIPTOR);
                    int _arg30 = data.readInt();
                    int _result = getCaretPosition(_arg30);
                    reply.writeNoException();
                    reply.writeInt(_result);
                    return true;
                case 1598968902:
                    reply.writeString(DESCRIPTOR);
                    return true;
                default:
                    return super.onTransact(code, data, reply, flags);
            }
        }

        private static class Proxy implements IJbedTextFieldClient {
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

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void create(int id) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    this.mRemote.transact(1, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setPosition(int id, int x, int y, int width, int height, boolean isFocused, int maxScrollbarWidth) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(x);
                    _data.writeInt(y);
                    _data.writeInt(width);
                    _data.writeInt(height);
                    _data.writeInt(isFocused ? 1 : 0);
                    _data.writeInt(maxScrollbarWidth);
                    this.mRemote.transact(2, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void calculateSizeHints(int id, int widthHint, int heightHint, int[] info) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(widthHint);
                    _data.writeInt(heightHint);
                    if (info == null) {
                        _data.writeInt(-1);
                    } else {
                        _data.writeInt(info.length);
                    }
                    this.mRemote.transact(3, _data, _reply, 0);
                    _reply.readException();
                    _reply.readIntArray(info);
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setFocus(int id, boolean focus) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(focus ? 1 : 0);
                    this.mRemote.transact(4, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void dispose(int id) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    this.mRemote.transact(5, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setText(int id, String text) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeString(text);
                    this.mRemote.transact(6, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setClip(int id, int x, int y, int width, int height) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(x);
                    _data.writeInt(y);
                    _data.writeInt(width);
                    _data.writeInt(height);
                    this.mRemote.transact(7, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void replaceText(int id, int offset, int length, String text) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(offset);
                    _data.writeInt(length);
                    _data.writeString(text);
                    this.mRemote.transact(8, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setConstraints(int id, int constraints) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(constraints);
                    this.mRemote.transact(9, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public void setMaxSize(int id, int maxSize) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    _data.writeInt(maxSize);
                    this.mRemote.transact(10, _data, _reply, 0);
                    _reply.readException();
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }

            @Override // com.esmertec.android.jbed.nativeui.IJbedTextFieldClient
            public int getCaretPosition(int id) throws RemoteException {
                Parcel _data = Parcel.obtain();
                Parcel _reply = Parcel.obtain();
                try {
                    _data.writeInterfaceToken(Stub.DESCRIPTOR);
                    _data.writeInt(id);
                    this.mRemote.transact(11, _data, _reply, 0);
                    _reply.readException();
                    int _result = _reply.readInt();
                    return _result;
                } finally {
                    _reply.recycle();
                    _data.recycle();
                }
            }
        }
    }
}
