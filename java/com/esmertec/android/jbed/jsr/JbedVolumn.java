package com.esmertec.android.jbed.jsr;

/* JADX INFO: compiled from: JbedMediaPlayer.java */
/* JADX INFO: loaded from: classes.dex */
class JbedVolumn {
    JbedVolumn() {
    }

    public static int getVol() {
        return JbedMediaManager.getVolume();
    }

    public static int setVol(int vol) {
        return JbedMediaManager.setVolume(vol);
    }
}
