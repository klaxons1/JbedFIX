package com.google.android.mms.pdu;
import java.io.UnsupportedEncodingException;
public class EncodedStringValue {
    private final int charset; private final byte[] data;
    public EncodedStringValue(int charset, byte[] data) { this.charset = charset; this.data = data; }
    public byte[] getTextString() { return data; }
    public String getString() { try { return new String(data, CharacterSets.getMimeName(charset)); } catch (UnsupportedEncodingException e) { return new String(data); } }
    @Override public String toString() { return getString(); }
}
