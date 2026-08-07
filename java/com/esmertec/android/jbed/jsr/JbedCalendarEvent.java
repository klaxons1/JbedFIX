package com.esmertec.android.jbed.jsr;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.pim.EventRecurrence;
import android.provider.Calendar;
import android.text.TextUtils;
import android.text.format.Time;
import android.util.Log;
import com.esmertec.android.jbed.JbedProvider;
import com.esmertec.android.jbed.ams.BasicEventHandler;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedCalendarEvent implements JbedPimManager.PimAction {
    private static final String JBED_CALENDAR_NAME = "jbed";
    static final int JBED_CLASS_CONFIDENTIAL = 200;
    static final int JBED_CLASS_NONE = 0;
    static final int JBED_CLASS_PRIVATE = 201;
    static final int JBED_CLASS_PUBLIC = 202;
    private static final int MAX_SUPPORT_REMINDER = 10;
    private static final String NEW_LINE = "\r\n";
    static final int REPEAT_RULE_DAILY = 16;
    static final int REPEAT_RULE_MONTHLY = 18;
    static final int REPEAT_RULE_WEEKLY = 17;
    static final int REPEAT_RULE_YEARLY = 19;
    private static final String TAG = "JbedPIMEvent";
    private static long calendarId;
    private static final HashMap<Integer, Integer> jbedClassTypeMap = new HashMap<>();
    private String mDescription;
    private String mDtend;
    private String mDtstart;
    private boolean mHasAlarm;
    private long mId;
    private String mLocation;
    private ContentResolver mResolver;
    private String mRrule;
    private String mTitle;
    private String mVisibility;
    private List<String> reminderList = new ArrayList();

    static {
        jbedClassTypeMap.put(Integer.valueOf(JBED_CLASS_CONFIDENTIAL), 1);
        jbedClassTypeMap.put(Integer.valueOf(JBED_CLASS_PRIVATE), 2);
        jbedClassTypeMap.put(Integer.valueOf(JBED_CLASS_PUBLIC), 3);
        jbedClassTypeMap.put(0, 0);
        calendarId = -1L;
    }

    public JbedCalendarEvent(ContentResolver resolver) {
        this.mResolver = resolver;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedPimManager.PimAction
    public String getNext(String id) {
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, "getNext id =" + id);
        }
        if (TextUtils.isEmpty(id)) {
            id = "-1";
        }
        Cursor cursor = Calendar.Events.query(this.mResolver, (String[]) null, "_id>" + id, JbedCalendarTodo.Tasks.ID);
        String result = null;
        if (cursor != null) {
            try {
                if (cursor.moveToFirst()) {
                    loadOneEvent(cursor);
                    result = toVCal();
                }
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        return result;
    }

    private void loadOneEvent(Cursor c) {
        this.mId = c.getLong(c.getColumnIndexOrThrow(JbedCalendarTodo.Tasks.ID));
        this.mTitle = c.getString(c.getColumnIndexOrThrow(JbedCalendarTodo.Tasks.TITLE));
        this.mDtend = convertLongToRFC2445DateTime(c.getLong(c.getColumnIndexOrThrow("dtend")));
        this.mDtstart = convertLongToRFC2445DateTime(c.getLong(c.getColumnIndexOrThrow("dtstart")));
        this.mLocation = c.getString(c.getColumnIndexOrThrow("eventLocation"));
        this.mHasAlarm = c.getInt(c.getColumnIndexOrThrow("hasAlarm")) != 0;
        this.mDescription = c.getString(c.getColumnIndexOrThrow("description"));
        this.mVisibility = c.getString(c.getColumnIndexOrThrow("visibility"));
        this.mRrule = c.getString(c.getColumnIndexOrThrow("rrule"));
        if (!TextUtils.isEmpty(this.mRrule)) {
            this.mRrule = convertRfc2445RecurrenceToRRule(this.mRrule);
        }
        if (this.mHasAlarm) {
            loadReminders(this.mId, c.getLong(c.getColumnIndexOrThrow("dtstart")));
        }
    }

    static String convertLongToRFC2445DateTime(long mills) {
        Time time = new Time();
        time.set(mills);
        return time.format2445();
    }

    private void loadReminders(long eventId, long startTime) {
        Cursor cursor = this.mResolver.query(Calendar.Reminders.CONTENT_URI, null, "event_id=" + eventId, null, null);
        try {
            this.reminderList.clear();
            for (int i = 0; cursor != null && cursor.moveToNext() && i < 10; i++) {
                int minutes = cursor.getInt(cursor.getColumnIndexOrThrow("minutes"));
                if (minutes == -1) {
                    minutes = 1440;
                }
                long remindTime = startTime - ((long) ((minutes * 60) * 1000));
                this.reminderList.add(convertLongToRFC2445DateTime(remindTime));
            }
            if (cursor != null) {
                cursor.close();
            }
        } catch (Throwable th) {
            if (cursor != null) {
                cursor.close();
            }
            throw th;
        }
    }

    public String toVCal() {
        String visibilityClass;
        StringBuilder sb = new StringBuilder();
        sb.append("BEGIN:VCALENDAR").append(NEW_LINE);
        sb.append("VERSION:1.0").append(NEW_LINE);
        sb.append("BEGIN:VEVENT").append(NEW_LINE);
        sb.append("UID:").append(this.mId).append(NEW_LINE);
        if (!TextUtils.isEmpty(this.mTitle)) {
            sb.append("SUMMARY:").append(this.mTitle).append(NEW_LINE);
        }
        if (!TextUtils.isEmpty(this.mDescription)) {
            sb.append("DESCRIPTION:").append(foldingString(this.mDescription)).append(NEW_LINE);
        }
        if (!TextUtils.isEmpty(this.mLocation)) {
            sb.append("LOCATION:").append(this.mLocation).append(NEW_LINE);
        }
        if (!TextUtils.isEmpty(this.mVisibility)) {
            switch (Integer.parseInt(this.mVisibility)) {
                case 1:
                    visibilityClass = "CONFIDENTIAL";
                    break;
                case 2:
                    visibilityClass = "PRIVATE";
                    break;
                case 3:
                    visibilityClass = "PUBLIC";
                    break;
                default:
                    visibilityClass = "";
                    break;
            }
            if (!TextUtils.isEmpty(visibilityClass)) {
                sb.append("CLASS:").append(visibilityClass).append(NEW_LINE);
            }
        }
        if (!TextUtils.isEmpty(this.mDtstart)) {
            sb.append("DTSTART:").append(this.mDtstart).append(NEW_LINE);
        }
        if (!TextUtils.isEmpty(this.mDtend)) {
            sb.append("DTEND:").append(this.mDtend).append(NEW_LINE);
        }
        if (this.mHasAlarm && this.reminderList.size() > 0) {
            for (String remindTime : this.reminderList) {
                sb.append("DALARM:").append(remindTime).append(NEW_LINE);
            }
        }
        if (!TextUtils.isEmpty(this.mRrule)) {
            sb.append("RRULE:").append(this.mRrule).append(NEW_LINE);
        }
        sb.append("END:VEVENT").append(NEW_LINE);
        sb.append("END:VCALENDAR");
        return sb.toString();
    }

    private String foldingString(String str) {
        return str.replaceAll(NEW_LINE, BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER).replaceAll(BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER, "\r\n ");
    }

    @Override // com.esmertec.android.jbed.jsr.JbedPimManager.PimAction
    public int remove(String id) {
        if (TextUtils.isEmpty(id)) {
            Log.e(TAG, " the id is empty! can't delete");
            return -1;
        }
        Uri contentURI = ContentUris.withAppendedId(Calendar.Events.CONTENT_URI, Long.parseLong(id));
        int count = this.mResolver.delete(contentURI, null, null);
        if (count == 0) {
            Log.w(TAG, "WARNING: failed to delete event id " + id);
        }
        JbedPimManager.removeByUri(this.mResolver, Calendar.Reminders.CONTENT_URI, null, "event_id=" + id);
        return 0;
    }

    public static long store(ContentResolver resolver, String idStr, String title, String description, String location, int eventClass, long dtstart, long dtend, int[] alarms, int repeatFrequence, int repeatInterval, int repeatCount, long repeatEnd) {
        long id;
        if (TextUtils.isEmpty(idStr)) {
            id = 0;
        } else {
            long id2 = Long.parseLong(idStr);
            id = id2;
        }
        ContentValues eventValues = new ContentValues();
        eventValues.put("calendar_id", Long.valueOf(getJbedCalendarId(resolver)));
        eventValues.put(JbedCalendarTodo.Tasks.TITLE, title);
        eventValues.put("description", description);
        eventValues.put("eventLocation", location);
        eventValues.put("dtstart", Long.valueOf(dtstart));
        eventValues.put("dtend", Long.valueOf(dtend));
        eventValues.put("visibility", jbedClassTypeMap.get(Integer.valueOf(eventClass)));
        String rrule = buildRRuleToRfc2445Recurrence(repeatFrequence, repeatInterval, repeatCount, repeatEnd);
        eventValues.put("rrule", rrule);
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, "[Events]title=" + title + " DESCRIPTION=" + description + " EVENT_LOCATION=" + location + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER + "VISIBILITY=" + jbedClassTypeMap.get(Integer.valueOf(eventClass)) + " " + repeatFrequence + " " + repeatInterval + " " + repeatCount);
        }
        List<ContentValues> reminderValues = new ArrayList<>();
        for (int i = 0; i < alarms.length; i++) {
            if (alarms[i] > 0) {
                int minutes = alarms[i] / 60;
                ContentValues reminder = new ContentValues();
                reminder.put("method", (Integer) 0);
                reminder.put("minutes", Integer.valueOf(minutes));
                reminderValues.add(reminder);
            }
        }
        eventValues.put("hasAlarm", Boolean.valueOf(reminderValues.size() > 0));
        JbedCalendarEvent event = new JbedCalendarEvent(resolver);
        return event.save(id, eventValues, reminderValues);
    }

    private static String buildRRuleToRfc2445Recurrence(int repeatFrequence, int repeatInterval, int repeatCount, long repeatEnd) {
        String result;
        String result2;
        switch (repeatFrequence) {
            case 16:
                result = "FREQ=DAILY";
                break;
            case 17:
                result = "FREQ=WEEKLY";
                break;
            case 18:
                result = "FREQ=MONTHLY";
                break;
            case 19:
                result = "FREQ=YEARLY";
                break;
            default:
                return null;
        }
        if (repeatInterval > 0) {
            result2 = result + ";INTERVAL=" + repeatInterval;
        } else {
            result2 = result + ";INTERVAL=1";
        }
        if (repeatEnd > 0) {
            result2 = result2 + ";UNTIL=" + convertLongToRFC2445DateTime(repeatEnd);
        }
        if (repeatCount > 0) {
            result2 = result2 + ";COUNT=" + repeatCount;
        }
        return result2;
    }

    String convertRfc2445RecurrenceToRRule(String rfc2445Recurrence) {
        String result;
        String result2;
        EventRecurrence eventRecurrence = new EventRecurrence();
        eventRecurrence.parse(rfc2445Recurrence);
        switch (eventRecurrence.freq) {
            case 4:
                result = "D";
                break;
            case 5:
                result = "W";
                break;
            case 6:
                result = "MP";
                break;
            case 7:
                result = "YM";
                break;
            default:
                return "";
        }
        if (eventRecurrence.interval > 0) {
            result2 = result + eventRecurrence.interval;
        } else {
            result2 = result + "1";
        }
        if (!TextUtils.isEmpty(eventRecurrence.until)) {
            result2 = result2 + " " + eventRecurrence.until;
        }
        if (eventRecurrence.count > 0) {
            result2 = result2 + " #" + eventRecurrence.count;
        }
        return result2;
    }

    private long save(long id, ContentValues eventValues, List<ContentValues> remindValues) {
        if (id == 0) {
            Uri uri = this.mResolver.insert(Calendar.Events.CONTENT_URI, eventValues);
            id = ContentUris.parseId(uri);
        } else {
            Uri uri2 = ContentUris.withAppendedId(Calendar.Events.CONTENT_URI, id);
            this.mResolver.update(uri2, eventValues, null, null);
            JbedPimManager.removeByUri(this.mResolver, Calendar.Reminders.CONTENT_URI, null, "event_id=" + id);
        }
        for (ContentValues v : remindValues) {
            v.put("event_id", Long.valueOf(id));
            this.mResolver.insert(Calendar.Reminders.CONTENT_URI, v);
        }
        return id;
    }

    /* JADX WARN: Code duplicated, block: B:16:0x0058 A[Catch: all -> 0x009e, TRY_ENTER, TryCatch #0 {all -> 0x009e, blocks: (B:8:0x001b, B:10:0x0021, B:12:0x0036, B:16:0x0058, B:18:0x0083), top: B:24:0x001b }] */
    /* JADX WARN: Code duplicated, block: B:18:0x0083 A[Catch: all -> 0x009e, TRY_LEAVE, TryCatch #0 {all -> 0x009e, blocks: (B:8:0x001b, B:10:0x0021, B:12:0x0036, B:16:0x0058, B:18:0x0083), top: B:24:0x001b }] */
    static long getJbedCalendarId(ContentResolver resolver) {
        if (calendarId != -1) {
            return calendarId;
        }
        Cursor cursor = resolver.query(Calendar.Calendars.CONTENT_URI, null, "name='jbed'", null, null);
        if (cursor == null) {
            ContentValues c = new ContentValues();
            c.put(JbedProvider.Midlets.NAME, JBED_CALENDAR_NAME);
            c.put("hidden", (Boolean) false);
            Uri uri = resolver.insert(Calendar.Calendars.CONTENT_URI, c);
            calendarId = ContentUris.parseId(uri);
            if (Log.isLoggable(TAG, 3)) {
                Log.d(TAG, "create a jbed calendar id=" + calendarId);
            }
        } else {
            try {
                if (cursor.moveToFirst()) {
                    calendarId = cursor.getLong(cursor.getColumnIndexOrThrow(JbedCalendarTodo.Tasks.ID));
                    if (Log.isLoggable(TAG, 3)) {
                        Log.d(TAG, "jbed calendar has existed! calendarId=" + calendarId);
                    }
                } else {
                    ContentValues c2 = new ContentValues();
                    c2.put(JbedProvider.Midlets.NAME, JBED_CALENDAR_NAME);
                    c2.put("hidden", (Boolean) false);
                    Uri uri2 = resolver.insert(Calendar.Calendars.CONTENT_URI, c2);
                    calendarId = ContentUris.parseId(uri2);
                    if (Log.isLoggable(TAG, 3)) {
                        Log.d(TAG, "create a jbed calendar id=" + calendarId);
                    }
                }
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        return calendarId;
    }
}
