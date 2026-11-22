package com.esmertec.android.jbed.jsr;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.text.TextUtils;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public class JbedCalendarTodo implements JbedPimManager.PimAction {
    private static final String NEW_LINE = "\r\n";
    static final String TAG = "JbedPIMTodo";
    private ContentResolver mResolver;

    public static final class Tasks {
        public static final String ALARM = "alarm";
        public static final Uri CONTENT_URI = Uri.parse("content://todo/todo_tasks");
        public static final int HAS_ALARM = 1;
        public static final String ID = "_id";
        public static final int IS_DUE = 2;
        public static final int NO_ALARM = 0;
        public static final String TITLE = "title";
    }

    public JbedCalendarTodo(ContentResolver resolver) {
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
        Cursor cursor = this.mResolver.query(Tasks.CONTENT_URI, null, "_id>" + id, null, Tasks.ID);
        String result = null;
        if (cursor != null) {
            try {
                if (cursor.moveToFirst()) {
                    result = loadOneTask(cursor);
                }
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        return result;
    }

    private String loadOneTask(Cursor cursor) {
        StringBuilder vcalendar = new StringBuilder();
        vcalendar.append("BEGIN:VCALENDAR").append(NEW_LINE);
        vcalendar.append("VERSION:1.0").append(NEW_LINE);
        vcalendar.append("BEGIN:VTODO").append(NEW_LINE);
        long id = cursor.getLong(cursor.getColumnIndexOrThrow(Tasks.ID));
        vcalendar.append("UID:").append(id).append(NEW_LINE);
        String title = cursor.getString(cursor.getColumnIndexOrThrow(Tasks.TITLE));
        if (!TextUtils.isEmpty(title)) {
            vcalendar.append("SUMMARY:").append(title).append(NEW_LINE);
        }
        int alarm = cursor.getInt(cursor.getColumnIndexOrThrow(Tasks.ALARM));
        String alarmStr = alarm == 2 ? "COMPLETED" : "FALSE";
        vcalendar.append("STATUS:").append(alarmStr).append(NEW_LINE);
        vcalendar.append("END:VTODO").append(NEW_LINE).append("END:VCALENDAR");
        return vcalendar.toString();
    }

    @Override // com.esmertec.android.jbed.jsr.JbedPimManager.PimAction
    public int remove(String id) {
        if (TextUtils.isEmpty(id)) {
            if (Log.isLoggable(TAG, 6)) {
                Log.e(TAG, " the id is empty! can't delete");
            }
            return -1;
        }
        Uri uri = ContentUris.withAppendedId(Tasks.CONTENT_URI, Long.parseLong(id));
        int count = this.mResolver.delete(uri, null, null);
        if (count == 0 && Log.isLoggable(TAG, 5)) {
            Log.w(TAG, "WARNING: failed to delete todo id " + id);
        }
        return 0;
    }

    public static boolean isSupported(ContentResolver resolver) {
        new JbedCalendarTodo(resolver);
        Cursor cursor = null;
        try {
            cursor = resolver.query(Tasks.CONTENT_URI, null, "_id>-1", null, Tasks.ID);
        } catch (Exception e) {
            if (Log.isLoggable(TAG, 5)) {
                Log.w(TAG, "WARNING: isSupported exception");
            }
        }
        if (cursor == null) {
            return false;
        }
        cursor.close();
        return true;
    }

    public static long store(ContentResolver resolver, String idStr, String title, boolean isCompleted) {
        long id = 0;
        if (!TextUtils.isEmpty(idStr)) {
            id = Long.parseLong(idStr);
        }
        ContentValues values = new ContentValues();
        values.put(Tasks.TITLE, title);
        values.put(Tasks.ALARM, Integer.valueOf(isCompleted ? 2 : 0));
        JbedCalendarTodo todo = new JbedCalendarTodo(resolver);
        return todo.save(id, values);
    }

    private long save(long id, ContentValues values) {
        if (id == 0) {
            Uri uri = this.mResolver.insert(Tasks.CONTENT_URI, values);
            return ContentUris.parseId(uri);
        }
        Uri uri2 = ContentUris.withAppendedId(Tasks.CONTENT_URI, id);
        this.mResolver.update(uri2, values, null, null);
        return id;
    }
}
