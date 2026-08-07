package com.android.internal.telephony;

public interface Phone {
    enum State {
        IDLE,
        RINGING,
        OFFHOOK
    }
}
