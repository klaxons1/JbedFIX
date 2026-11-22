package com.esmertec.android.jbed.jsr;

import android.content.Context;
import android.os.Handler;
import com.esmertec.android.jbed.service.JbedService;
import java.text.Collator;
import java.text.DateFormat;
import java.text.NumberFormat;
import java.util.Currency;
import java.util.Date;
import java.util.Hashtable;
import java.util.Locale;

/* JADX INFO: loaded from: classes.dex */
public class JbedMiapiManager implements JbedService.LifecycleListener {
    private static final int ANDROID_LONG = 1;
    private static final int ANDROID_MEDIUM = 2;
    private static final int ANDROID_SHORT = 3;
    private static final int COLLATER_BASE_HANDLE = 10000;
    private static final int FORMATTER_DATETIME_LONG = 5;
    private static final int FORMATTER_DATETIME_SHORT = 4;
    private static final int FORMATTER_DATE_LONG = 1;
    private static final int FORMATTER_DATE_SHORT = 0;
    private static final int FORMATTER_TIME_LONG = 3;
    private static final int FORMATTER_TIME_SHORT = 2;
    private static final String TAG = "JbedMiapiManager";
    private static Hashtable collaterHandles = new Hashtable();
    private static Hashtable collators = new Hashtable();
    private static String[] localesOfCollator = getCollatorLocales();
    private static String[] localesOfFormatter = getFormatterLocales();

    private static native void nativeInitialization();

    static {
        nativeInitialization();
    }

    public JbedMiapiManager(Handler handler) {
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
    }

    public static int openCollator(String localeName) {
        int index = 0;
        while (!localesOfCollator[index].equals(localeName)) {
            index++;
        }
        Locale locale = getLocaleInstance(localeName);
        if (collaterHandles.containsKey(locale)) {
            return ((Integer) collaterHandles.get(locale)).intValue();
        }
        Collator collator = Collator.getInstance(locale);
        int handle = index + 10000;
        collators.put(Integer.valueOf(handle), collator);
        collaterHandles.put(locale, Integer.valueOf(handle));
        return handle;
    }

    public static int closeCollator(int collatorHandle) {
        return 0;
    }

    public static int compare(int collatorHandle, int level, String str1, String str2) {
        Collator collator = (Collator) collators.get(Integer.valueOf(collatorHandle));
        switch (level) {
            case 1:
                collator.setStrength(0);
                break;
            case 2:
                collator.setStrength(1);
                break;
            case 3:
            case 15:
                collator.setStrength(2);
                break;
            default:
                collator.setStrength(3);
                break;
        }
        return collator.compare(str1, str2);
    }

    public static int getCollatorLocalesNum() {
        return localesOfCollator.length;
    }

    public static int getCollatorLocaleLen(int idx) {
        return localesOfCollator[idx].length();
    }

    public static String getCollatorLocaleName(int idx) {
        return localesOfCollator[idx];
    }

    public static int getFormatterLocalesNum() {
        return localesOfFormatter.length;
    }

    public static int getFormatterLocaleLen(int idx) {
        return localesOfFormatter[idx].length();
    }

    public static String getFormatterLocaleName(int idx) {
        return localesOfFormatter[idx];
    }

    public static String formatNumber(String localeName, double number) {
        Locale locale = getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getNumberInstance(locale);
        return nf.format(number);
    }

    public static String formatNumber(String localeName, long number) {
        Locale locale = getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getNumberInstance(locale);
        return nf.format(number);
    }

    public static String formatNumber(String localeName, double number, int decimals) {
        getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getNumberInstance();
        nf.setMinimumFractionDigits(decimals);
        nf.setMaximumFractionDigits(decimals);
        return nf.format(number);
    }

    public static String formatPercent(String localeName, long value) {
        Locale locale = getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getPercentInstance(locale);
        return nf.format(value);
    }

    public static String formatPercent(String localeName, float value, int decimals) {
        getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getPercentInstance();
        nf.setMinimumFractionDigits(decimals);
        nf.setMaximumFractionDigits(decimals);
        return nf.format(value);
    }

    public static String formatCurrency(String localeName, double value) {
        Locale locale = getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getCurrencyInstance(locale);
        return nf.format(value);
    }

    public static String formatCurrency(String localeName, double value, String currencyCode) {
        Locale locale = getLocaleInstance(localeName);
        NumberFormat nf = NumberFormat.getCurrencyInstance(locale);
        nf.setCurrency(Currency.getInstance(currencyCode));
        return nf.format(value);
    }

    public static String formatDateTime(String localeName, int style, long timeInMillis) {
        DateFormat df;
        Locale locale = getLocaleInstance(localeName);
        switch (style) {
            case 0:
                df = DateFormat.getDateInstance(3, locale);
                break;
            case 1:
                df = DateFormat.getDateInstance(1, locale);
                break;
            case 2:
                df = DateFormat.getTimeInstance(3, locale);
                break;
            case 3:
                df = DateFormat.getTimeInstance(1, locale);
                break;
            case 4:
                df = DateFormat.getDateTimeInstance(3, 3, locale);
                break;
            case 5:
                df = DateFormat.getDateTimeInstance(1, 1, locale);
                break;
            default:
                throw new IllegalArgumentException("Wrong date time style!");
        }
        return df.format(new Date(timeInMillis));
    }

    private static String[] getCollatorLocales() {
        String[] availableLocales = convertLocales(Collator.getAvailableLocales());
        String[] collatorLocales = new String[availableLocales.length + 1];
        for (int i = 0; i < availableLocales.length; i++) {
            collatorLocales[i] = availableLocales[i];
        }
        collatorLocales[availableLocales.length] = "generic";
        return collatorLocales;
    }

    private static String[] getFormatterLocales() {
        return convertLocales(NumberFormat.getAvailableLocales());
    }

    private static String[] convertLocales(Locale[] locales) {
        String[] localesStr = new String[locales.length];
        int index = 0;
        for (int i = 0; i < locales.length; i++) {
            if ((locales[i].getCountry().length() != 0 || locales[i].getVariant().length() == 0) && locales[i].getCountry().length() <= 2) {
                localesStr[index] = getLocaleNameStr(locales[i]);
                index++;
            }
        }
        String[] result = new String[index];
        System.arraycopy(localesStr, 0, result, 0, index);
        return result;
    }

    private static String getLocaleNameStr(Locale locale) {
        String language = locale.getLanguage();
        String country = locale.getCountry();
        String variant = locale.getVariant();
        boolean l = language.length() != 0;
        boolean c = country.length() != 0;
        boolean v = variant.length() != 0;
        StringBuilder result = new StringBuilder(language);
        if (c || (l && v)) {
            result.append('-').append(country);
        }
        if (v && (l || c)) {
            result.append('-').append(variant);
        }
        return result.toString();
    }

    private static Locale getLocaleInstance(String localeName) {
        String[] fields = localeName.split("-", 3);
        switch (fields.length) {
            case 2:
                Locale result = new Locale(fields[0], fields[1]);
                return result;
            case 3:
                Locale result2 = new Locale(fields[0], fields[1], fields[2]);
                return result2;
            default:
                Locale result3 = new Locale(fields[0]);
                return result3;
        }
    }
}
