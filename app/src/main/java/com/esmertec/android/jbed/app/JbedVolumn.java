package com.esmertec.android.jbed.app;

import android.content.Context;
import android.media.AudioManager;
import com.esmertec.android.jbed.JbedApp;

/* JADX INFO: compiled from: JbedVideoClientImpl.java */
/* JADX INFO: loaded from: classes.dex */
class JbedVolumn {
    JbedVolumn() {
    }

    private static AudioManager getAudioManager() {
        Context ctx = JbedApp.getInstance();
        if (ctx == null) {
            return null;
        }
        return (AudioManager) ctx.getSystemService(Context.AUDIO_SERVICE);
    }

    public static int getVol() {
        AudioManager am = getAudioManager();
        if (am == null) {
            return -1;
        }
        return am.getStreamVolume(3);
    }

    public static int setVol(int vol) {
        AudioManager am = getAudioManager();
        if (am == null) {
            return -1;
        }
        int max = am.getStreamMaxVolume(3);
        if (vol < 0) {
            vol = 0;
        }
        if (vol > max) {
            vol = max;
        }
        am.setStreamVolume(3, vol, 0);
        return am.getStreamVolume(3);
    }
}
