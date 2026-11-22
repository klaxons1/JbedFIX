package com.esmertec.android.jbed.app;

import android.app.AlertDialog;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.graphics.drawable.StateListDrawable;
import android.os.SystemClock;
import android.util.AttributeSet;
import android.view.InputDevice;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewConfiguration;
import android.widget.Button;
import android.widget.LinearLayout;
import com.esmertec.android.jbed.R;
import java.util.ArrayList;
import java.util.List;

/** Touch controls that use the same key events as a physical keyboard. */
public final class JbedControls extends LinearLayout {
    public static final String PREFERENCES = "game_controls";
    private static final int DIRECTIONS = 1;
    private static final int NUMBERS = 2;
    private static final int HIDDEN = 3;
    private final SharedPreferences preferences;
    private final List<KeyButton> keys = new ArrayList<>();
    private final KeyButton leftSoftKey;
    private final KeyButton rightSoftKey;
    private final LinearLayout keypad;
    private Callback callback;

    public interface Callback {
        void onKey(KeyEvent event);
        void onOpenMenu();
    }

    public JbedControls(Context context, AttributeSet attrs) {
        super(context, attrs);
        preferences = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE);
        setOrientation(VERTICAL);
        setBackgroundColor(0xff151b23);
        setPadding(dp(4), dp(4), dp(4), dp(4));
        setMotionEventSplittingEnabled(true);

        LinearLayout toolbar = row();
        leftSoftKey = key(getResources().getString(R.string.GAME_LEFT_SOFT_KEY), KeyEvent.KEYCODE_SOFT_LEFT);
        rightSoftKey = key(getResources().getString(R.string.GAME_RIGHT_SOFT_KEY), KeyEvent.KEYCODE_SOFT_RIGHT);
        Button menu = new Button(context);
        style(menu);
        menu.setText(R.string.GAME_MENU);
        menu.setTextSize(14);
        menu.setOnClickListener(view -> {
            releaseKeys();
            if (callback != null) callback.onOpenMenu();
        });
        addCell(toolbar, leftSoftKey);
        addCell(toolbar, menu);
        addCell(toolbar, rightSoftKey);
        addView(toolbar);
        keypad = new LinearLayout(context);
        keypad.setOrientation(VERTICAL);
        keypad.setMotionEventSplittingEnabled(true);
        addView(keypad);
        rebuildKeypad(preferences.getInt("layout", DIRECTIONS));
    }

    public void setCallback(Callback callback) {
        this.callback = callback;
    }

    public void setSoftKeys(String left, String right) {
        leftSoftKey.setText(left == null || left.isEmpty()
                ? getResources().getString(R.string.GAME_LEFT_SOFT_KEY) : left);
        rightSoftKey.setText(right == null || right.isEmpty()
                ? getResources().getString(R.string.GAME_RIGHT_SOFT_KEY) : right);
    }

    public void releaseKeys() {
        for (KeyButton key : keys) key.release();
    }

    @Override
    protected void onDetachedFromWindow() {
        releaseKeys();
        super.onDetachedFromWindow();
    }

    public void chooseLayout() {
        releaseKeys();
        String[] labels = {getResources().getString(R.string.GAME_DIRECTION_PAD),
                getResources().getString(R.string.GAME_NUMBER_PAD),
                getResources().getString(R.string.GAME_HIDE_KEYS)};
        new AlertDialog.Builder(getContext()).setTitle(R.string.GAME_CONTROLS)
                .setSingleChoiceItems(labels, preferences.getInt("layout", DIRECTIONS) - 1,
                        (dialog, which) -> {
                            int mode = which + 1;
                            preferences.edit().putInt("layout", mode).apply();
                            rebuildKeypad(mode);
                            dialog.dismiss();
                        }).setNegativeButton(android.R.string.cancel, null).show();
    }

    private void rebuildKeypad(int mode) {
        releaseKeys();
        keypad.removeAllViews();
        keys.clear();
        keys.add(leftSoftKey);
        keys.add(rightSoftKey);
        if (mode == HIDDEN) return;
        if (mode == NUMBERS) {
            for (int first = 1; first <= 7; first += 3) {
                LinearLayout row = row();
                for (int number = first; number < first + 3; number++) {
                    addCell(row, key(Integer.toString(number), KeyEvent.KEYCODE_0 + number));
                }
                keypad.addView(row);
            }
            LinearLayout row = row();
            addCell(row, key("*", KeyEvent.KEYCODE_STAR));
            addCell(row, key("0", KeyEvent.KEYCODE_0));
            addCell(row, key("#", KeyEvent.KEYCODE_POUND));
            keypad.addView(row);
        } else {
            LinearLayout top = row();
            addCell(top, new View(getContext()));
            addCell(top, direction("↑", R.string.GAME_UP, KeyEvent.KEYCODE_DPAD_UP));
            addCell(top, new View(getContext()));
            keypad.addView(top);
            LinearLayout middle = row();
            addCell(middle, direction("←", R.string.GAME_LEFT, KeyEvent.KEYCODE_DPAD_LEFT));
            addCell(middle, direction("●", R.string.GAME_FIRE, KeyEvent.KEYCODE_DPAD_CENTER));
            addCell(middle, direction("→", R.string.GAME_RIGHT, KeyEvent.KEYCODE_DPAD_RIGHT));
            keypad.addView(middle);
            LinearLayout bottom = row();
            addCell(bottom, new View(getContext()));
            addCell(bottom, direction("↓", R.string.GAME_DOWN, KeyEvent.KEYCODE_DPAD_DOWN));
            addCell(bottom, new View(getContext()));
            keypad.addView(bottom);
        }
    }

    private KeyButton direction(String label, int description, int keyCode) {
        KeyButton button = key(label, keyCode);
        button.setContentDescription(getResources().getString(description));
        return button;
    }

    private KeyButton key(String label, int keyCode) {
        KeyButton button = new KeyButton(keyCode);
        button.setText(label);
        keys.add(button);
        return button;
    }

    private LinearLayout row() {
        LinearLayout row = new LinearLayout(getContext());
        row.setOrientation(HORIZONTAL);
        row.setMotionEventSplittingEnabled(true);
        row.setLayoutParams(new LayoutParams(LayoutParams.MATCH_PARENT, dp(48)));
        return row;
    }

    private void addCell(LinearLayout row, View view) {
        LayoutParams params = new LayoutParams(0, LayoutParams.MATCH_PARENT, 1);
        params.setMargins(dp(2), dp(2), dp(2), dp(2));
        row.addView(view, params);
    }

    private void style(Button button) {
        button.setFocusable(false);
        button.setAllCaps(false);
        button.setTextColor(Color.WHITE);
        button.setTextSize(18);
        button.setMinWidth(0);
        button.setMinHeight(0);
        button.setMinimumWidth(0);
        button.setMinimumHeight(0);
        button.setPadding(dp(4), 0, dp(4), 0);
        StateListDrawable background = new StateListDrawable();
        background.addState(new int[] {android.R.attr.state_pressed}, background(0xff3973ac));
        background.addState(new int[0], background(0xff28313d));
        button.setBackground(background);
    }

    private GradientDrawable background(int color) {
        GradientDrawable drawable = new GradientDrawable();
        drawable.setColor(color);
        drawable.setCornerRadius(dp(6));
        return drawable;
    }

    private int dp(int value) {
        return Math.round(value * getResources().getDisplayMetrics().density);
    }

    private final class KeyButton extends Button {
        private final int keyCode;
        private boolean held;
        private boolean touchClick;
        private long downTime;
        private int repeatCount;
        private final Runnable repeat = new Runnable() {
            @Override
            public void run() {
                if (!held) return;
                send(KeyEvent.ACTION_DOWN, ++repeatCount);
                postDelayed(this, ViewConfiguration.getKeyRepeatDelay());
            }
        };

        KeyButton(int keyCode) {
            super(JbedControls.this.getContext());
            this.keyCode = keyCode;
            style(this);
        }

        private void send(int action, int repeatCount) {
            if (callback != null) {
                callback.onKey(new KeyEvent(downTime, SystemClock.uptimeMillis(), action,
                        keyCode, repeatCount, 0, KeyCharacterMap.VIRTUAL_KEYBOARD, 0,
                        KeyEvent.FLAG_SOFT_KEYBOARD | KeyEvent.FLAG_KEEP_TOUCH_MODE,
                        InputDevice.SOURCE_KEYBOARD));
            }
        }

        private void press() {
            if (held) return;
            held = true;
            downTime = SystemClock.uptimeMillis();
            repeatCount = 0;
            setPressed(true);
            send(KeyEvent.ACTION_DOWN, 0);
            postDelayed(repeat, ViewConfiguration.getKeyRepeatTimeout());
        }

        void release() {
            if (!held) return;
            held = false;
            removeCallbacks(repeat);
            setPressed(false);
            send(KeyEvent.ACTION_UP, 0);
        }

        @Override
        public boolean onTouchEvent(MotionEvent event) {
            switch (event.getActionMasked()) {
                case MotionEvent.ACTION_DOWN:
                    press();
                    return true;
                case MotionEvent.ACTION_MOVE:
                    if (event.getX() >= 0 && event.getX() < getWidth()
                            && event.getY() >= 0 && event.getY() < getHeight()) {
                        press();
                    } else {
                        release();
                    }
                    return true;
                case MotionEvent.ACTION_UP:
                    release();
                    touchClick = true;
                    performClick();
                    touchClick = false;
                    return true;
                case MotionEvent.ACTION_CANCEL:
                    release();
                    return true;
                default:
                    return true;
            }
        }

        @Override
        public boolean performClick() {
            if (!touchClick) {
                press();
                release();
            }
            super.performClick();
            return true;
        }
    }
}
