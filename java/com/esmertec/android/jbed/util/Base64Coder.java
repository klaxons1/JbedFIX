package com.esmertec.android.jbed.util;

/* JADX INFO: loaded from: classes.dex */
public class Base64Coder {
    private static char[] map1 = new char[64];
    private static byte[] map2;

    static {
        int i;
        int i2 = 0;
        char c = 'A';
        while (true) {
            i = i2;
            if (c > 'Z') {
                break;
            }
            i2 = i + 1;
            map1[i] = c;
            c = (char) (c + 1);
        }
        char c2 = 'a';
        while (c2 <= 'z') {
            map1[i] = c2;
            c2 = (char) (c2 + 1);
            i++;
        }
        char c3 = '0';
        while (c3 <= '9') {
            map1[i] = c3;
            c3 = (char) (c3 + 1);
            i++;
        }
        int i3 = i + 1;
        map1[i] = '+';
        int i4 = i3 + 1;
        map1[i3] = '/';
        map2 = new byte[128];
        for (int i5 = 0; i5 < map2.length; i5++) {
            map2[i5] = -1;
        }
        for (int i6 = 0; i6 < 64; i6++) {
            map2[map1[i6]] = (byte) i6;
        }
    }

    public static String encodeString(String s) {
        return new String(encode(s.getBytes()));
    }

    public static char[] encode(byte[] in) {
        return encode(in, in.length);
    }

    public static char[] encode(byte[] in, int iLen) {
        int ip;
        int i1;
        int ip2;
        int oDataLen = ((iLen * 4) + 2) / 3;
        int oLen = ((iLen + 2) / 3) * 4;
        char[] out = new char[oLen];
        int op = 0;
        int op2 = 0;
        while (op < iLen) {
            int ip3 = op + 1;
            int i0 = in[op] & 255;
            if (ip3 < iLen) {
                int ip4 = ip3 + 1;
                i1 = in[ip3] & 255;
                ip = ip4;
            } else {
                ip = ip3;
                i1 = 0;
            }
            if (ip < iLen) {
                int ip5 = ip + 1;
                int ip6 = in[ip] & 255;
                ip = ip5;
                ip2 = ip6;
            } else {
                ip2 = 0;
            }
            int o0 = i0 >>> 2;
            int o1 = ((i0 & 3) << 4) | (i1 >>> 4);
            int o2 = ((i1 & 15) << 2) | (ip2 >>> 6);
            int o3 = ip2 & 63;
            int op3 = op2 + 1;
            out[op2] = map1[o0];
            int op4 = op3 + 1;
            out[op3] = map1[o1];
            out[op4] = op4 < oDataLen ? map1[o2] : '=';
            int op5 = op4 + 1;
            out[op5] = op5 < oDataLen ? map1[o3] : '=';
            op2 = op5 + 1;
            op = ip;
        }
        return out;
    }

    public static String decodeString(String s) {
        return new String(decode(s));
    }

    public static byte[] decode(String s) {
        return decode(s.toCharArray());
    }

    public static byte[] decode(char[] in) {
        int ip;
        char c;
        int ip2;
        int o1;
        int op;
        int iLen = in.length;
        if (iLen % 4 != 0) {
            throw new IllegalArgumentException("Length of Base64 encoded input string is not a multiple of 4.");
        }
        int iLen2 = iLen;
        while (iLen2 > 0 && in[iLen2 - 1] == '=') {
            iLen2--;
        }
        int oLen = (iLen2 * 3) / 4;
        byte[] out = new byte[oLen];
        int op2 = 0;
        for (int op3 = 0; op3 < iLen2; op3 = ip) {
            int ip3 = op3 + 1;
            char c2 = in[op3];
            int ip4 = ip3 + 1;
            char c3 = in[ip3];
            if (ip4 < iLen2) {
                int ip5 = ip4 + 1;
                c = in[ip4];
                ip = ip5;
            } else {
                ip = ip4;
                c = 'A';
            }
            if (ip < iLen2) {
                int ip6 = ip + 1;
                char c4 = in[ip];
                ip = ip6;
                ip2 = c4;
            } else {
                ip2 = 65;
            }
            if (c2 > 127 || c3 > 127 || c > 127 || ip2 > 127) {
                throw new IllegalArgumentException("Illegal character in Base64 encoded data.");
            }
            int b0 = map2[c2];
            int b1 = map2[c3];
            int b2 = map2[c];
            int b3 = map2[ip2];
            if (b0 < 0 || b1 < 0 || b2 < 0 || b3 < 0) {
                throw new IllegalArgumentException("Illegal character in Base64 encoded data.");
            }
            int o0 = (b0 << 2) | (b1 >>> 4);
            int o2 = ((b1 & 15) << 4) | (b2 >>> 2);
            int o3 = ((b2 & 3) << 6) | b3;
            int b4 = op2 + 1;
            out[op2] = (byte) o0;
            if (b4 < oLen) {
                int op4 = b4 + 1;
                out[b4] = (byte) o2;
                o1 = op4;
            } else {
                o1 = b4;
            }
            if (o1 < oLen) {
                op = o1 + 1;
                out[o1] = (byte) o3;
            } else {
                op = o1;
            }
            op2 = op;
        }
        return out;
    }

    private Base64Coder() {
    }
}
