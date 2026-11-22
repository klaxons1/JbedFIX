package com.esmertec.android.jbed;

import android.content.Intent;
import android.util.Log;

/** Lifecycle and failure diagnostics use Android's buffered log. */
public final class JbedLog {
    private JbedLog() {}

    public static void info(String tag, String message) {
        Log.i(tag, message);
    }

    public static void warn(String tag, String message) {
        Log.w(tag, message);
    }

    public static void error(String tag, String message, Throwable throwable) {
        Log.e(tag, message, throwable);
    }

    public static void intent(String tag, String stage, Intent intent) {
        if (!Log.isLoggable(tag, Log.DEBUG)) {
            return;
        }
        Log.d(tag, stage + " " + intent);
    }
}
