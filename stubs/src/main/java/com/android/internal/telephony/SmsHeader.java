package com.android.internal.telephony;

import java.util.ArrayList;

public class SmsHeader {
    public ArrayList<MiscElt> miscEltList = new ArrayList<>();

    public static class MiscElt {
        public int id;
        public byte[] data;
    }

    public static byte[] toByteArray(SmsHeader header) {
        return null;
    }
}
