package org.jbed.source;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.TextView;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public final class MainActivity extends Activity {
    private static final ExecutorService WORKER = Executors.newSingleThreadExecutor();
    private TextView output;
    private EditText arguments;
    private Spinner methods;
    private Button run, stop;
    private volatile boolean stopRequested;
    private boolean running;
    private boolean runFromIntent;
    private int requestedMethod;
    private String[] entries;

    private static native String nativeDescribe();
    private static native String[] nativeMethods();
    private static native int nativeArgumentWords(int method);
    private static native String nativeRun(int method, int[] arguments);
    private static native String nativeStartMain(int method, byte[][] arguments);
    private static native int nativeIterate(int sliceMillis);
    private static native void nativeRequestStop();
    private static native String nativeStatus();

    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        LinearLayout body = new LinearLayout(this);
        body.setOrientation(LinearLayout.VERTICAL);
        int margin = (int) (20 * getResources().getDisplayMetrics().density);
        body.setPadding(margin, margin, margin, margin);
        TextView title = new TextView(this);
        title.setText("Jbed source build");
        title.setTextSize(24);
        body.addView(title);
        TextView explanation = new TextView(this);
        explanation.setText("Rebuilt ROM and runtime · ARM32");
        body.addView(explanation);

        methods = new Spinner(this);
        body.addView(methods);
        arguments = new EditText(this);
        arguments.setSingleLine(true);
        arguments.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS);
        arguments.setHint("JVM words, separated by commas");
        body.addView(arguments);
        run = new Button(this);
        run.setText("Run method");
        body.addView(run);
        stop = new Button(this);
        stop.setText("Stop program");
        stop.setEnabled(false);
        stop.setOnClickListener(view -> {
            stopRequested = true;
            stop.setEnabled(false);
        });
        body.addView(stop);
        output = new TextView(this);
        output.setTextIsSelectable(true);
        ScrollView scroll = new ScrollView(this);
        scroll.addView(output);
        body.addView(scroll, new LinearLayout.LayoutParams(-1, 0, 1));
        setContentView(body);

        try {
            System.loadLibrary("jbedsource_jni");
            output.setText(nativeDescribe());
            entries = nativeMethods();
            ArrayAdapter<String> adapter = new ArrayAdapter<>(this,
                android.R.layout.simple_spinner_item, entries);
            adapter.setDropDownViewResource(android.R.layout.simple_spinner_dropdown_item);
            methods.setAdapter(adapter);
            run.setEnabled(entries.length != 0);
            String requested = getIntent().getStringExtra("method");
            int selected = 0;
            for (int i = 0; i < entries.length; ++i)
                if (entries[i].equals("TransformProbe.main([Ljava/lang/String;)V")) selected = i;
            if (requested != null) {
                selected = -1;
                for (int i = 0; i < entries.length; ++i)
                    if (requested.equals(entries[i])) selected = i;
                if (selected < 0) {
                    output.setText("Method is not in this ROM: " + requested);
                    return;
                }
            }
            requestedMethod = selected;
            runFromIntent = getIntent().getBooleanExtra("run", false);
            methods.setSelection(requestedMethod);
            methods.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
                @Override public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                    boolean main = isMain(position);
                    run.setText(main ? "Run program" : "Run method");
                    arguments.setSingleLine(!main);
                    arguments.setHint(main ? "Program arguments, one per line" : "JVM words, separated by commas");
                    int words = main ? 0 : nativeArgumentWords(position);
                    StringBuilder values = new StringBuilder();
                    for (int i = 0; i < words; ++i) {
                        if (i != 0) values.append(", ");
                        values.append('0');
                    }
                    arguments.setText(values);
                    if (runFromIntent && position == requestedMethod) {
                        runFromIntent = false;
                        getIntent().removeExtra("run");
                        String supplied = getIntent().getStringExtra("arguments");
                        if (supplied != null) arguments.setText(supplied);
                        run.post(() -> runMethod());
                    }
                }
                @Override public void onNothingSelected(AdapterView<?> parent) { }
            });
            run.setOnClickListener(view -> runMethod());
        } catch (LinkageError error) {
            output.setText("Native library failed to load:\n" + error);
            run.setEnabled(false);
        }
    }

    private boolean isMain(int selected) {
        return entries[selected].endsWith(".main([Ljava/lang/String;)V");
    }

    private void runMethod() {
        if (running) return;
        final int selected = methods.getSelectedItemPosition();
        if (isMain(selected)) {
            String input = arguments.getText().toString();
            String[] values = input.isEmpty() ? new String[0] : input.split("\\r?\\n", -1);
            byte[][] encoded = new byte[values.length][];
            for (int i = 0; i < values.length; ++i)
                encoded[i] = values[i].getBytes(StandardCharsets.UTF_8);
            beginRun(true);
            WORKER.execute(() -> {
                String result = nativeStartMain(selected, encoded);
                if (result == null) {
                    boolean stopSent = false;
                    while (true) {
                        if (stopRequested && !stopSent) {
                            nativeRequestStop();
                            stopSent = true;
                        }
                        int delay = nativeIterate(50);
                        if (delay == -3 || delay == Integer.MIN_VALUE) break;
                        if (delay > 0) {
                            try { Thread.sleep(Math.min(delay, 50)); }
                            catch (InterruptedException interrupted) { stopRequested = true; }
                        }
                    }
                    result = nativeStatus();
                }
                finishRun(result);
            });
            return;
        }
        final int[] words;
        try {
            String input = arguments.getText().toString().trim();
            String[] parts = input.isEmpty() ? new String[0] : input.split("\\s*,\\s*", -1);
            words = new int[parts.length];
            for (int i = 0; i < parts.length; ++i) {
                long value = Long.decode(parts[i]);
                if (value < Integer.MIN_VALUE || value > 0xffffffffL)
                    throw new NumberFormatException("Word outside 32-bit range: " + parts[i]);
                words[i] = (int) value;
            }
        } catch (NumberFormatException error) {
            output.setText("Invalid arguments: " + error.getMessage());
            return;
        }
        beginRun(false);
        WORKER.execute(() -> finishRun(nativeRun(selected, words)));
    }

    private void beginRun(boolean main) {
        running = true;
        stopRequested = false;
        run.setEnabled(false);
        methods.setEnabled(false);
        arguments.setEnabled(false);
        stop.setEnabled(main);
        output.setText("Running…");
    }

    private void finishRun(String result) {
        runOnUiThread(() -> {
            running = false;
            if (isDestroyed()) return;
            output.setText(nativeDescribe() + "\n\n" + result);
            run.setEnabled(true);
            methods.setEnabled(true);
            arguments.setEnabled(true);
            stop.setEnabled(false);
        });
    }

    @Override protected void onDestroy() {
        stopRequested = true;
        super.onDestroy();
    }

    @Override protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (entries == null || running) return;
        String requested = intent.getStringExtra("method");
        if (requested == null) requested = entries[methods.getSelectedItemPosition()];
        for (int i = 0; i < entries.length; ++i) {
            if (!entries[i].equals(requested)) continue;
            requestedMethod = i;
            runFromIntent = intent.getBooleanExtra("run", false);
            if (methods.getSelectedItemPosition() != i) {
                methods.setSelection(i);
            } else if (runFromIntent) {
                runFromIntent = false;
                intent.removeExtra("run");
                String supplied = intent.getStringExtra("arguments");
                if (supplied != null) arguments.setText(supplied);
                runMethod();
            }
            return;
        }
        output.setText("Method is not in this ROM: " + requested);
    }

}
