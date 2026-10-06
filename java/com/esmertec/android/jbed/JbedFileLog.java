package com.esmertec.android.jbed;

import android.content.ClipData;
import android.content.Context;
import android.content.Intent;
import android.os.Environment;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.nio.charset.Charset;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Small last-resort diagnostic logger for devices where logcat is unavailable.
 *
 * The first location is intentionally a public, user-visible directory so a
 * Jbed failure can be diagnosed without adb.  The app targets API 22, so the
 * legacy external-storage permission is still the appropriate access model on
 * the Android 11 test device.  A private fallback is retained for devices
 * which deny external-storage access.
 */
public final class JbedFileLog {
    private static final String TAG = "JbedFileLog";
    private static final String PUBLIC_DIRECTORY = "/storage/emulated/0/jbedfix";
    private static final String LOG_FILE_NAME = "jbed.log";
    private static final long MAX_LOG_BYTES = 4L * 1024L * 1024L;
    private static final Object LOCK = new Object();
    private static final Charset UTF8 = Charset.forName("UTF-8");
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat(
            "yyyy-MM-dd HH:mm:ss.SSSZ", Locale.US);
    private static File sLogFile;
    private static boolean sInitialized;
    private static Thread.UncaughtExceptionHandler sPreviousExceptionHandler;

    private JbedFileLog() {
    }

    public static void initialize(Context context) {
        synchronized (LOCK) {
            if (sInitialized) {
                return;
            }
            sInitialized = true;
            sLogFile = openableLogFile(context);
            installExceptionHandler();
        }
        info(TAG, "file logging initialized; path=" + getLogPath());
        info(TAG, "process=" + android.os.Process.myPid() + " externalState="
                + Environment.getExternalStorageState());
    }

    private static File openableLogFile(Context context) {
        File[] candidates = new File[]{
                new File(PUBLIC_DIRECTORY, LOG_FILE_NAME),
                new File(Environment.getExternalStorageDirectory(), "jbedfix/" + LOG_FILE_NAME),
                new File(context.getFilesDir(), "jbedfix/" + LOG_FILE_NAME)
        };
        for (File candidate : candidates) {
            File parent = candidate.getParentFile();
            if (parent == null || (!parent.exists() && !parent.mkdirs())) {
                continue;
            }
            try {
                FileOutputStream output = new FileOutputStream(candidate, true);
                output.close();
                return candidate;
            } catch (Throwable ignored) {
                // Try the next location. The failure is deliberately silent:
                // this logger must never prevent the emulator from starting.
            }
        }
        return null;
    }

    private static void installExceptionHandler() {
        sPreviousExceptionHandler = Thread.getDefaultUncaughtExceptionHandler();
        Thread.setDefaultUncaughtExceptionHandler(new Thread.UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread thread, Throwable throwable) {
                exception("uncaught", throwable);
                if (sPreviousExceptionHandler != null
                        && sPreviousExceptionHandler != this) {
                    sPreviousExceptionHandler.uncaughtException(thread, throwable);
                }
            }
        });
    }

    public static String getLogPath() {
        synchronized (LOCK) {
            return sLogFile == null ? "unavailable" : sLogFile.getAbsolutePath();
        }
    }

    public static void info(String tag, String message) {
        append("I", tag, message, null);
    }

    public static void warn(String tag, String message) {
        append("W", tag, message, null);
    }

    public static void error(String tag, String message, Throwable throwable) {
        append("E", tag, message, throwable);
    }

    public static void exception(String label, Throwable throwable) {
        append("X", TAG, label, throwable);
    }

    public static void intent(String tag, String stage, Intent intent) {
        if (intent == null) {
            info(tag, stage + " intent=null");
            return;
        }
        StringBuilder value = new StringBuilder(stage)
                .append(" action=").append(intent.getAction())
                .append(" type=").append(intent.getType())
                .append(" data=").append(intent.getData())
                .append(" flags=0x").append(Integer.toHexString(intent.getFlags()));
        try {
            if (intent.getExtras() != null) {
                value.append(" extras=").append(intent.getExtras().keySet());
            }
            ClipData clipData = intent.getClipData();
            if (clipData != null) {
                value.append(" clipItems=").append(clipData.getItemCount());
            }
        } catch (Throwable throwable) {
            value.append(" extras=<unreadable:").append(throwable.getClass().getSimpleName())
                    .append(">");
        }
        info(tag, value.toString());
    }

    private static void append(String level, String tag, String message, Throwable throwable) {
        synchronized (LOCK) {
            if (sLogFile == null) {
                return;
            }
            try {
                rotateIfNeeded();
                StringBuilder line = new StringBuilder()
                        .append(DATE_FORMAT.format(new Date()))
                        .append(" pid=").append(android.os.Process.myPid())
                        .append(" tid=").append(Thread.currentThread().getId())
                        .append(" ").append(level).append("/").append(tag).append(" ")
                        .append(message == null ? "" : message);
                if (throwable != null) {
                    StringWriter stack = new StringWriter();
                    throwable.printStackTrace(new PrintWriter(stack));
                    line.append("\n").append(stack.toString());
                }
                line.append("\n");
                FileOutputStream output = new FileOutputStream(sLogFile, true);
                output.write(line.toString().getBytes(UTF8));
                output.flush();
                output.close();
            } catch (Throwable failure) {
                // Never turn a diagnostic write failure into an emulator crash.
                Log.w(TAG, "unable to append diagnostic log", failure);
            }
        }
    }

    private static void rotateIfNeeded() {
        if (sLogFile == null || !sLogFile.exists() || sLogFile.length() < MAX_LOG_BYTES) {
            return;
        }
        File oldLog = new File(sLogFile.getParentFile(), "jbed.log.previous");
        if (oldLog.exists()) {
            oldLog.delete();
        }
        if (!sLogFile.renameTo(oldLog)) {
            // Truncate if the filesystem does not permit rename in this
            // directory; keeping current diagnostics is more useful than
            // silently growing without bound.
            try {
                FileOutputStream output = new FileOutputStream(sLogFile, false);
                output.close();
            } catch (IOException ignored) {
            }
        }
    }
}
