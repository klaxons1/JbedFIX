package com.esmertec.android.jbed.app;

import android.util.Log;
import com.esmertec.android.jbed.ams.AmsConstants;
import com.esmertec.android.jbed.ams.AmsEventHandler;

/* JADX INFO: compiled from: JbedView.java */
/* JADX INFO: loaded from: classes.dex */
class SimpleAmsEventHandlerFactoryImpl implements AmsEventHandler.Factory {
    SimpleAmsEventHandlerFactoryImpl() {
    }

    @Override // com.esmertec.android.jbed.ams.AmsEventHandler.Factory
    public AmsEventHandler buildAmsHandler(int eventId) {
        return new AmsEventHandler() { // from class: com.esmertec.android.jbed.app.SimpleAmsEventHandlerFactoryImpl.1
            @Override // com.esmertec.android.jbed.ams.AmsEventHandler, java.lang.Runnable
            public void run() {
                switch (this.mEvent.mId) {
                    case 2:
                        if (this.mEvent.mResult == 15) {
                            this.mHandler.obtainMessage(10016, 2, 0, this.mEvent.getDataAsUtf8());
                        } else {
                            this.mHandler.obtainMessage(10013).sendToTarget();
                        }
                        break;
                    case 11:
                    case 17:
                    case 18:
                        this.mHandler.obtainMessage(10015, this.mEvent.mId, this.mEvent.mResult, this.mEvent.getDataAsUtf8()).sendToTarget();
                        break;
                    case AmsConstants.EVENT_RUNTIME_ERROR /* 58 */:
                        this.mHandler.obtainMessage(10016, 58, 0, this.mEvent.getDataAsUtf8());
                        break;
                    default:
                        Log.w("AmsEventHandler", "WARNING, ignored ams event " + this.mEvent.toString());
                        break;
                }
            }
        };
    }
}
