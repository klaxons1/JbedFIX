package com.google.android.mms.pdu;
import java.util.Locale;
public final class CharacterSets {
    private CharacterSets() { }
    public static int getMibEnumValue(String mimeName) { return "utf-8".equalsIgnoreCase(mimeName) ? 106 : 0; }
    public static String getMimeName(int mibEnumValue) { return mibEnumValue == 106 ? "utf-8" : "iso-8859-1"; }
}
