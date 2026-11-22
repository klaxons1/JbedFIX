package com.esmertec.android.jbed.util;

import android.os.Handler;

/* JADX INFO: loaded from: classes.dex */
public class SerialExecutor {
    private boolean mIsDone = false;

    public void execute(Handler handler, final Runnable r) {
        Runnable myRunnable = new Runnable() { // from class: com.esmertec.android.jbed.util.SerialExecutor.1
            @Override // java.lang.Runnable
            public void run() {
                try {
                    r.run();
                    synchronized (SerialExecutor.this) {
                        SerialExecutor.this.notify();
                        SerialExecutor.this.mIsDone = true;
                    }
                } catch (Throwable th) {
                    synchronized (SerialExecutor.this) {
                        SerialExecutor.this.notify();
                        SerialExecutor.this.mIsDone = true;
                        throw th;
                    }
                }
            }
        };
        handler.post(myRunnable);
        synchronized (this) {
            if (!this.mIsDone) {
                try {
                    wait();
                } catch (InterruptedException e) {
                }
            }
        }
    }
}
