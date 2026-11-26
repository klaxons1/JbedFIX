package org.jbed.source;

import android.app.ActivityManager;
import android.app.ApplicationExitInfo;
import android.content.Context;
import android.os.Build;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.RandomAccessFile;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Date;

/** Read-only diagnostics. Does not intercept native signals or hide failures. */
final class CrashDiagnostics {
    private CrashDiagnostics() { }

    static File checkpointFile(Context context) {
        return new File(context.getFilesDir(), "source-runtime.log");
    }

    static String checkpoints(Context context, int limit) {
        File file = checkpointFile(context);
        if (!file.exists()) return "No native checkpoints recorded yet.";
        try (RandomAccessFile input = new RandomAccessFile(file, "r")) {
            long length = input.length();
            int count = (int)Math.min(length, limit);
            input.seek(length - count);
            byte[] bytes = new byte[count];
            input.readFully(bytes);
            return new String(bytes, StandardCharsets.UTF_8);
        } catch (IOException error) {
            return "Cannot read native checkpoints: " + error;
        }
    }

    static String report(Context context) {
        StringBuilder report = new StringBuilder("Jbed source startup diagnostics\n");
        try {
            report.append("App: ").append(context.getPackageManager()
                .getPackageInfo(context.getPackageName(), 0).versionName).append('\n');
        } catch (Exception error) {
            report.append("App version unavailable: ").append(error).append('\n');
        }
        report.append("Android API: ").append(Build.VERSION.SDK_INT)
            .append("\nDevice: ").append(Build.MANUFACTURER).append(' ').append(Build.MODEL)
            .append("\nABIs: ").append(Arrays.toString(Build.SUPPORTED_ABIS))
            .append("\nBuild: ").append(Build.FINGERPRINT)
            .append("\n\nNative checkpoints (latest runs):\n")
            .append(checkpoints(context, 32768)).append('\n');
        if (Build.VERSION.SDK_INT >= 30) appendExitHistory(context, report);
        else report.append("\nAndroid exit history requires Android 11 or newer. Capture logcat for the native backtrace.\n");
        return report.toString();
    }

    @android.annotation.TargetApi(30)
    private static void appendExitHistory(Context context, StringBuilder report) {
        report.append("\nAndroid process exit history:\n");
        try {
            ActivityManager manager = (ActivityManager)context.getSystemService(Context.ACTIVITY_SERVICE);
            if (manager == null) { report.append("ActivityManager unavailable.\n"); return; }
            boolean traceRead = false;
            java.util.List<ApplicationExitInfo> exits = manager.getHistoricalProcessExitReasons(null, 0, 4);
            if (exits.isEmpty()) report.append("No previous process exits supplied by Android.\n");
            for (ApplicationExitInfo exit : exits) {
                report.append(new Date(exit.getTimestamp())).append(" pid=").append(exit.getPid())
                    .append(" reason=").append(exit.getReason()).append(" status=").append(exit.getStatus())
                    .append(" description=").append(exit.getDescription()).append('\n');
                // Android 12+ may expose the native tombstone here. Older OS
                // versions/devices may return null; do not require root access.
                int reason = exit.getReason();
                if (traceRead || (reason != ApplicationExitInfo.REASON_CRASH_NATIVE &&
                        reason != ApplicationExitInfo.REASON_CRASH && reason != ApplicationExitInfo.REASON_ANR)) continue;
                try (InputStream input = exit.getTraceInputStream()) {
                    if (input == null) { report.append("No trace supplied for this exit.\n"); continue; }
                    ByteArrayOutputStream bytes = new ByteArrayOutputStream();
                    byte[] buffer = new byte[4096];
                    while (bytes.size() < 98304) {
                        int count = input.read(buffer, 0, Math.min(buffer.length, 98304 - bytes.size()));
                        if (count < 0) break;
                        if (count == 0) break;
                        bytes.write(buffer, 0, count);
                    }
                    byte[] trace = bytes.toByteArray();
                    boolean binary = false;
                    for (byte value : trace) {
                        int ch = value & 255;
                        if (ch < 32 && ch != '\n' && ch != '\r' && ch != '\t') { binary = true; break; }
                    }
                    report.append("--- Android trace (up to 96 KiB)")
                        .append(binary ? "; binary/protobuf, Base64 encoded ---\n" : " ---\n")
                        .append(binary ? android.util.Base64.encodeToString(trace, android.util.Base64.DEFAULT)
                            : new String(trace, StandardCharsets.UTF_8))
                        .append("\n--- end trace ---\n");
                    traceRead = true;
                } catch (IOException error) {
                    report.append("Cannot read exit trace: ").append(error).append('\n');
                }
            }
        } catch (RuntimeException error) {
            report.append("Exit history unavailable: ").append(error).append('\n');
        }
    }
}
