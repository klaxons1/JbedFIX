package com.esmertec.android.jbed.jsr;

import android.media.AudioSystem;

/* JADX INFO: compiled from: JbedMediaPlayer.java */
/* JADX INFO: loaded from: classes.dex */
class JbedVolumn {
    JbedVolumn() {
    }

    public static int getVol() {
        return AudioSystem.getStreamVolumeIndex(3);
    }

    public static int setVol(int vol) {
        AudioSystem.setStreamVolumeIndex(3, vol);
        return AudioSystem.getStreamVolumeIndex(3);
    }
}
