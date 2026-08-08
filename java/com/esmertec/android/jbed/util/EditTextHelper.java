package com.esmertec.android.jbed.util;

import android.text.InputFilter;
import android.text.InputType;
import android.text.method.DigitsKeyListener;
import android.text.method.NumberKeyListener;
import android.text.method.KeyListener;
import android.text.method.PasswordTransformationMethod;
import android.text.method.TextKeyListener;
import android.widget.EditText;
import com.esmertec.android.jbed.JbedConstants;

/* JADX INFO: loaded from: classes.dex */
public class EditTextHelper implements JbedConstants {
    private EditTextHelper() {
    }

    public static void setConstraint(EditText editText, int constraint) {
        KeyListener l;
        EditText bakEditText = null;
        switch (65535 & constraint) {
            case 2:
                l = DigitsKeyListener.getInstance(true, false);
                break;
            case 3:
                l = new NumberKeyListener() { // from class: com.esmertec.android.jbed.util.EditTextHelper.1
                    @Override // android.text.method.NumberKeyListener
                    protected char[] getAcceptedChars() {
                        return new char[]{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
                    }

                    @Override // android.text.method.NumberKeyListener
                    public int getInputType() {
                        return InputType.TYPE_CLASS_PHONE;
                    }
                };
                break;
            case 4:
            default:
                if (1 != 0 && (constraint & JbedConstants.JBED_CONSTRAINT_PASSWORD) != 0) {
                    editText.setInputType(131073 | 128);
                    return;
                }
                TextKeyListener.Capitalize capitalize = TextKeyListener.Capitalize.NONE;
                boolean autotext = true;
                if ((2097152 & constraint) != 0) {
                    capitalize = TextKeyListener.Capitalize.SENTENCES;
                }
                if ((1048576 & constraint) != 0) {
                    capitalize = TextKeyListener.Capitalize.WORDS;
                }
                if ((262144 & constraint) != 0) {
                    autotext = false;
                }
                if ((524288 & constraint) != 0) {
                    autotext = false;
                }
                l = TextKeyListener.getInstance(autotext, capitalize);
                break;
                break;
            case 5:
                l = DigitsKeyListener.getInstance(true, true);
                break;
        }
        if (1 != 0 && (constraint & JbedConstants.JBED_CONSTRAINT_PASSWORD) != 0) {
            editText.setTransformationMethod(PasswordTransformationMethod.getInstance());
        }
        if ((131072 & constraint) != 0) {
            bakEditText = editText;
        }
        if (editText != bakEditText) {
            editText.setKeyListener(l);
        }
    }

    public static void setMaxSize(EditText editText, int maxSize) {
        if (maxSize >= 0) {
            editText.setFilters(new InputFilter[]{new InputFilter.LengthFilter(maxSize)});
        }
    }
}
