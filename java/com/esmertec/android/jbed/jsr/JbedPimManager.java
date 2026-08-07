package com.esmertec.android.jbed.jsr;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.Context;
import android.database.Cursor;
import android.net.Uri;
import android.util.Log;
import com.esmertec.android.jbed.service.JbedService;
import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;

/* JADX INFO: loaded from: classes.dex */
public class JbedPimManager implements JbedService.LifecycleListener {
    static final int CONTACT_LIST = 1;
    static final int EVENT_LIST = 2;
    private static JbedPimManager INSTANCE = null;
    static final String TAG = "JbedPimManager";
    static final int TODO_LIST = 3;
    private ContentResolver mResolver;

    public interface PimAction {
        String getNext(String str);

        int remove(String str);
    }

    private static native void nativeInitialization();

    static {
        nativeInitialization();
    }

    public JbedPimManager() {
        INSTANCE = this;
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onCreate(Context context) {
        this.mResolver = context.getContentResolver();
    }

    @Override // com.esmertec.android.jbed.service.JbedService.LifecycleListener
    public void onDestroy(Context context) {
        INSTANCE = null;
    }

    static byte[] convertToBytes(String contents) {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            byte[] data = contents.getBytes("utf-8");
            out.writeInt(data.length);
            out.write(data);
            return bo.toByteArray();
        } catch (Exception e) {
            Log.e(TAG, " failed to wrap vcard to bytes", e);
            return null;
        }
    }

    static byte[] convertIdToBytes(long id) {
        ByteArrayOutputStream bo = new ByteArrayOutputStream();
        DataOutputStream out = new DataOutputStream(bo);
        try {
            out.writeLong(-1L);
            byte[] data = String.valueOf(id).getBytes();
            out.write(data);
            return bo.toByteArray();
        } catch (Exception e) {
            Log.e(TAG, " failed to wrap the id to bytes", e);
            return null;
        }
    }

    private static PimAction getAction(int type) {
        if (type == 1) {
            return new JbedContact(INSTANCE.mResolver);
        }
        if (type == 3) {
            return new JbedCalendarTodo(INSTANCE.mResolver);
        }
        if (type == 2) {
            return new JbedCalendarEvent(INSTANCE.mResolver);
        }
        return null;
    }

    public static boolean isSupported(int type) {
        if (type == 3) {
            return JbedCalendarTodo.isSupported(INSTANCE.mResolver);
        }
        return true;
    }

    public static byte[] getNextItem(int type, String id) {
        String content;
        PimAction action = getAction(type);
        if (action == null || (content = action.getNext(id)) == null) {
            return null;
        }
        return convertToBytes(content);
    }

    public static int remove(int type, String id) {
        PimAction action = getAction(type);
        if (action == null) {
            return -1;
        }
        return action.remove(id);
    }

    static byte[] storeContact(String id, String name, int[] nameAttr, String[] names, String company, String title, String notes, int[] phoneAttr, String[] phones, int[] emailAttr, String[] emails, int[] addrAttr, String[] addrs, int[] urlAttr, String[] urls, byte[] photo) {
        long newId = JbedContact.store(INSTANCE.mResolver, id, name, nameAttr, names, company, title, notes, phoneAttr, phones, emailAttr, emails, addrAttr, addrs, urlAttr, urls, photo);
        return convertIdToBytes(newId);
    }

    static byte[] storeTodo(String id, String summary, boolean isCompleted) {
        long newId = JbedCalendarTodo.store(INSTANCE.mResolver, id, summary, isCompleted);
        return convertIdToBytes(newId);
    }

    static byte[] storeEvent(String id, String title, String description, String location, int eventClass, long dtstart, long dtend, int[] alarms, int repeat_frequence, int repeat_interval, int repeat_count, long repeat_end) {
        long newId = JbedCalendarEvent.store(INSTANCE.mResolver, id, title, description, location, eventClass, dtstart, dtend, alarms, repeat_frequence, repeat_interval, repeat_count, repeat_end);
        if (Log.isLoggable(TAG, 3)) {
            Log.d(TAG, " storeEvent new Id=" + newId);
        }
        return convertIdToBytes(newId);
    }

    public static void removeByUri(ContentResolver resolver, Uri fromUri, Uri deleteUri, String where) {
        Cursor cursor = resolver.query(fromUri, null, where, null, null);
        while (cursor != null) {
            try {
                if (!cursor.moveToNext()) {
                    break;
                }
                long id = cursor.getLong(cursor.getColumnIndexOrThrow(JbedCalendarTodo.Tasks.ID));
                Uri uri = ContentUris.withAppendedId(deleteUri != null ? deleteUri : fromUri, id);
                int count = resolver.delete(uri, null, null);
                if (count == 0) {
                    Log.w(TAG, "WARNING: failed to delete id " + id);
                }
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
    }
}
