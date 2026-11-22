package com.esmertec.android.jbed.jsr;

import android.content.ContentResolver;
import android.content.ContentUris;
import android.content.ContentValues;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;
import com.esmertec.android.jbed.ams.BasicEventHandler;
import com.esmertec.android.jbed.util.Base64Coder;
import com.esmertec.android.jbed.util.SimpleEntry;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public class JbedContact implements JbedPimManager.PimAction {
    private static final String CUSTOM_DISPLAY_LABEL = "Custom";
    private static final int EMAIL_TYPE = 4;
    private static final String EMPTY_CONTACT_NAME = "<empty>";
    static final int JBED_CONTACT_ATTR_ASST = 1;
    static final int JBED_CONTACT_ATTR_AUTO = 2;
    static final int JBED_CONTACT_ATTR_FAX = 4;
    static final int JBED_CONTACT_ATTR_HOME = 8;
    static final int JBED_CONTACT_ATTR_MOBILE = 16;
    static final int JBED_CONTACT_ATTR_OTHER = 32;
    static final int JBED_CONTACT_ATTR_PAGER = 64;
    static final int JBED_CONTACT_ATTR_PREF = 128;
    static final int JBED_CONTACT_ATTR_SMS = 256;
    static final int JBED_CONTACT_ATTR_WORK = 512;
    private static final int LGE_KIND_WEBSITE = 6;
    private static final String NEW_LINE = "\r\n";
    private static final int POSTAL_TYPE = 5;
    private static final String TAG = "JbedPIMContact";
    private long count;
    private long mId;
    private String mName;
    private String mNotes;
    private byte[] mPhoto;
    private ContentResolver mResolver;
    private List<PhoneData> mPhoneList = new ArrayList();
    private List<ContactMethod> mContactmethodList = new ArrayList();
    private List<Organization> mOrganizationList = new ArrayList();

    private interface Mergeable {
        String getAttribute();

        String getData();

        String getKeyWord();
    }

    static class PhoneData implements Mergeable {
        private static final HashMap<Integer, String> phoneAttrMap = new HashMap<>();
        private String data;
        private String label;
        private int type;

        PhoneData() {
        }

        static {
            phoneAttrMap.put(0, "PREF");
            phoneAttrMap.put(1, "HOME");
            phoneAttrMap.put(2, "CELL");
            phoneAttrMap.put(3, "WORK");
            phoneAttrMap.put(4, "FAX");
            phoneAttrMap.put(6, "PAGER");
            phoneAttrMap.put(7, "X-JBED-OTHER");
        }

        /* JADX INFO: Access modifiers changed from: private */
        public ContentValues toValues(long rawContactId) {
            ContentValues result = new ContentValues();
            result.put("raw_contact_id", Long.valueOf(rawContactId));
            result.put("mimetype", "vnd.android.cursor.item/phone_v2");
            result.put("data2", Integer.valueOf(this.type));
            Log.d(JbedContact.TAG, "type " + this.type);
            result.put("data1", this.data);
            Log.d(JbedContact.TAG, "PhoneData " + this.data);
            String label = this.type == 0 ? JbedContact.CUSTOM_DISPLAY_LABEL : null;
            Log.d(JbedContact.TAG, "Label " + label);
            result.put("data3", label);
            return result;
        }

        public String toString() {
            return "[PhoneData]type=" + this.type + " data=" + this.data;
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getKeyWord() {
            return "TEL";
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getData() {
            return this.data;
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getAttribute() {
            String attr = phoneAttrMap.get(Integer.valueOf(this.type));
            if (attr == null) {
                throw new IllegalArgumentException("unkown attribute type");
            }
            return attr;
        }
    }

    static class Organization {
        public String mCompany;
        public String mTitle;

        Organization() {
        }

        /* JADX INFO: Access modifiers changed from: private */
        public ContentValues toValues(long rawContactId) {
            ContentValues result = new ContentValues();
            result.put("raw_contact_id", Long.valueOf(rawContactId));
            result.put("mimetype", "vnd.android.cursor.item/organization");
            result.put("data4", this.mTitle);
            result.put("data1", this.mCompany);
            result.put("data2", (Integer) 1);
            return result;
        }

        public String toVCard() {
            StringBuilder vcard = new StringBuilder();
            if (!TextUtils.isEmpty(this.mCompany)) {
                vcard.append("ORG:").append(this.mCompany).append(JbedContact.NEW_LINE);
            }
            if (!TextUtils.isEmpty(this.mTitle)) {
                vcard.append("TITLE:").append(JbedContact.foldingString(this.mTitle)).append(JbedContact.NEW_LINE);
            }
            return vcard.toString();
        }

        public String toString() {
            return "title =" + this.mTitle + "  company=" + this.mCompany;
        }
    }

    static class ContactMethod implements Mergeable {
        public String data;
        public int kind;
        public int type;
        private static final HashMap<Integer, String> emailAttrMap = new HashMap<>();
        private static final HashMap<Integer, String> addrAttrMap = new HashMap<>();
        private static final HashMap<Integer, String> urlAttrMap = new HashMap<>();

        ContactMethod() {
        }

        static {
            emailAttrMap.put(0, "PREF");
            emailAttrMap.put(1, "HOME");
            emailAttrMap.put(2, "WORK");
            emailAttrMap.put(3, "X-JBED-OTHER");
            addrAttrMap.put(0, "PREF");
            addrAttrMap.put(1, "HOME");
            addrAttrMap.put(2, "WORK");
            addrAttrMap.put(3, "X-JBED-OTHER");
            urlAttrMap.put(0, "PREF");
            urlAttrMap.put(4, "HOME");
            urlAttrMap.put(5, "WORK");
            urlAttrMap.put(7, "X-JBED-OTHER");
        }

        /* JADX INFO: Access modifiers changed from: private */
        public ContentValues toValues(long rawContactId) {
            ContentValues result = new ContentValues();
            result.put("raw_contact_id", Long.valueOf(rawContactId));
            if (this.kind == 4) {
                result.put("mimetype", "vnd.android.cursor.item/email_v2");
                result.put("data1", this.data);
                result.put("data2", Integer.valueOf(this.type));
                String label = this.type == 0 ? JbedContact.CUSTOM_DISPLAY_LABEL : null;
                result.put("data3", label);
            } else if (this.kind == 5) {
                result.put("mimetype", "vnd.android.cursor.item/postal-address_v2");
                result.put("data1", this.data);
                result.put("data2", Integer.valueOf(this.type));
                String label2 = this.type == 0 ? JbedContact.CUSTOM_DISPLAY_LABEL : null;
                result.put("data3", label2);
            } else if (this.kind == 6) {
                result.put("mimetype", "vnd.android.cursor.item/website");
                result.put("data1", this.data);
                result.put("data2", Integer.valueOf(this.type));
                String label3 = this.type == 0 ? JbedContact.CUSTOM_DISPLAY_LABEL : null;
                result.put("data3", label3);
            }
            return result;
        }

        public String toString() {
            return "[contactmethod]kind=" + this.kind + " type=" + this.type + " data=" + this.data;
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getKeyWord() {
            if (this.kind == 4) {
                return "EMAIL";
            }
            if (this.kind == 5) {
                return "LABEL";
            }
            if (this.kind == 6) {
                return "URL";
            }
            throw new IllegalArgumentException("unkown contact type");
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getAttribute() {
            String attr = null;
            if (this.kind == 4) {
                String attr2 = emailAttrMap.get(Integer.valueOf(this.type));
                attr = attr2;
            } else if (this.kind == 5) {
                String attr3 = addrAttrMap.get(Integer.valueOf(this.type));
                attr = attr3;
            } else if (this.kind == 6) {
                String attr4 = urlAttrMap.get(Integer.valueOf(this.type));
                attr = attr4;
            }
            if (attr == null) {
                throw new IllegalArgumentException("unkown attribute type");
            }
            return attr;
        }

        @Override // com.esmertec.android.jbed.jsr.JbedContact.Mergeable
        public String getData() {
            if (this.kind == 4) {
                return this.data;
            }
            if (this.kind == 5) {
                return JbedContact.foldingString(this.data);
            }
            if (this.kind == 6) {
                return this.data;
            }
            return "";
        }
    }

    public JbedContact(ContentResolver resolver) {
        this.mResolver = resolver;
    }

    private void addJbedPhone(int attr, String data) {
        if (data != null) {
            if ((attr & JBED_CONTACT_ATTR_PREF) != 0) {
                addPhone(data, 0, null);
            }
            if ((attr & 8) != 0) {
                addPhone(data, 1, null);
            }
            if ((attr & 16) != 0) {
                addPhone(data, 2, null);
            }
            if ((attr & JBED_CONTACT_ATTR_WORK) != 0) {
                addPhone(data, 3, null);
            }
            if ((attr & 4) != 0) {
                addPhone(data, 4, null);
            }
            if ((attr & 64) != 0) {
                addPhone(data, 6, null);
            }
            if ((attr & 32) != 0) {
                addPhone(data, 7, null);
            }
        }
    }

    private void addJbedEmail(int attr, String data) {
        if (data != null) {
            if ((attr & JBED_CONTACT_ATTR_PREF) != 0) {
                addContactMethod(4, 0, data);
            }
            if ((attr & 8) != 0) {
                addContactMethod(4, 1, data);
            }
            if ((attr & JBED_CONTACT_ATTR_WORK) != 0) {
                addContactMethod(4, 2, data);
            }
            if ((attr & 32) != 0) {
                addContactMethod(4, 3, data);
            }
        }
    }

    private void addJbedUrl(int attr, String data) {
        if (data != null) {
            if ((attr & JBED_CONTACT_ATTR_PREF) != 0) {
                addContactMethod(6, 0, data);
            }
            if ((attr & 8) != 0) {
                addContactMethod(6, 4, data);
            }
            if ((attr & JBED_CONTACT_ATTR_WORK) != 0) {
                addContactMethod(6, 5, data);
            }
            if ((attr & 32) != 0) {
                addContactMethod(6, 7, data);
            }
        }
    }

    private void addJbedAddr(int attr, String data) {
        if (data != null) {
            if ((attr & JBED_CONTACT_ATTR_PREF) != 0) {
                addContactMethod(5, 0, data);
            }
            if ((attr & 8) != 0) {
                addContactMethod(5, 1, data);
            }
            if ((attr & JBED_CONTACT_ATTR_WORK) != 0) {
                addContactMethod(5, 2, data);
            }
            if ((attr & 32) != 0) {
                addContactMethod(5, 3, data);
            }
        }
    }

    private void addPhone(String data, int type, String label) {
        PhoneData st = new PhoneData();
        st.data = data;
        st.type = type;
        st.label = label;
        this.mPhoneList.add(st);
    }

    private void addContactMethod(int kind, int type, String data) {
        ContactMethod st = new ContactMethod();
        st.kind = kind;
        st.data = data;
        st.type = type;
        this.mContactmethodList.add(st);
    }

    private void addOrganization(String title, String company) {
        Organization org = new Organization();
        org.mTitle = title;
        org.mCompany = company;
        this.mOrganizationList.add(org);
    }

    private String toVCard() {
        StringBuilder vcard = new StringBuilder();
        vcard.append("BEGIN:VCARD").append(NEW_LINE);
        vcard.append("VERSION:2.1").append(NEW_LINE);
        vcard.append("UID:").append(this.mId).append(NEW_LINE);
        if (!TextUtils.isEmpty(this.mName)) {
            vcard.append("FN:").append(this.mName).append(NEW_LINE);
        }
        if (!TextUtils.isEmpty(this.mNotes)) {
            vcard.append("NOTE:").append(foldingString(this.mNotes)).append(NEW_LINE);
        }
        if (this.mOrganizationList.size() > 0) {
            vcard.append(this.mOrganizationList.get(0).toVCard());
        }
        Log.d(TAG, "mergeDataToText Phonelist");
        vcard.append(mergeDataToText(this.mPhoneList));
        Log.d(TAG, "mergeDataToText mContactmethodList");
        vcard.append(mergeDataToText(this.mContactmethodList));
        if (this.mPhoto != null) {
            Log.d(TAG, " the photo binary data length is " + this.mPhoto.length);
            String photoStr = new String(Base64Coder.encode(this.mPhoto));
            if (!TextUtils.isEmpty(photoStr)) {
                Log.d(TAG, " the photo encoded data length is " + photoStr.length());
                vcard.append("PHOTO;ENCODING=BASE64:").append(photoStr).append(NEW_LINE);
            }
        }
        vcard.append("END:VCARD").append(NEW_LINE);
        return vcard.toString();
    }

    private ContentValues nametoValues(long rawContactId) {
        ContentValues result = new ContentValues();
        Log.d(TAG, "mName=" + this.mName);
        result.put("raw_contact_id", Long.valueOf(rawContactId));
        result.put("mimetype", "vnd.android.cursor.item/name");
        result.put("data1", this.mName);
        return result;
    }

    private ContentValues notetoValues(long rawContactId) {
        ContentValues result = new ContentValues();
        Log.d(TAG, "mNotes=" + this.mNotes + "id=" + rawContactId);
        result.put("raw_contact_id", Long.valueOf(rawContactId));
        result.put("mimetype", "vnd.android.cursor.item/note");
        result.put("data1", this.mNotes);
        return result;
    }

    private ContentValues phototoValues(long rawContactId) {
        ContentValues result = new ContentValues();
        Log.d(TAG, "mPhoto=" + this.mPhoto + "id=" + rawContactId);
        result.put("raw_contact_id", Long.valueOf(rawContactId));
        result.put("mimetype", "vnd.android.cursor.item/photo");
        result.put("data15", this.mPhoto);
        return result;
    }

    private long save() {
        Log.d(TAG, "mId=" + this.mId);
        if (this.mId == 0) {
            ContentValues result = new ContentValues();
            Uri rawContactUri = this.mResolver.insert(ContactsContract.RawContacts.CONTENT_URI, result);
            long rawContactId = ContentUris.parseId(rawContactUri);
            this.mResolver.insert(ContactsContract.Data.CONTENT_URI, nametoValues(rawContactId));
            Uri contactURI = this.mResolver.insert(ContactsContract.Data.CONTENT_URI, notetoValues(rawContactId));
            Log.d(TAG, "save name and note URI" + contactURI.getPath());
            for (Organization org : this.mOrganizationList) {
                Log.d(TAG, "save Organization");
                this.mResolver.insert(ContactsContract.Data.CONTENT_URI, org.toValues(rawContactId));
                Log.d(TAG, "end save Organization");
            }
            this.mId = rawContactId;
        } else {
            String selection = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/name'");
            long row = this.mResolver.update(ContactsContract.Data.CONTENT_URI, nametoValues(this.mId), selection, null);
            Log.d(TAG, "name  row= " + row);
            String selection2 = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/note'");
            long row2 = this.mResolver.update(ContactsContract.Data.CONTENT_URI, notetoValues(this.mId), selection2, null);
            Log.d(TAG, "note  row= " + row2);
            for (Organization org2 : this.mOrganizationList) {
                Log.d(TAG, "save Organization");
                String selection3 = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/organization'");
                this.mResolver.update(ContactsContract.Data.CONTENT_URI, org2.toValues(this.mId), selection3, null);
                Log.d(TAG, "end save Organization");
            }
            String selection4 = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/phone_v2'");
            this.mResolver.delete(ContactsContract.Data.CONTENT_URI, selection4, null);
            String selection5 = new String("raw_contact_id=" + this.mId + " AND (mimetype='vnd.android.cursor.item/email_v2' OR mimetype='vnd.android.cursor.item/postal-address_v2' OR mimetype='vnd.android.cursor.item/website')");
            this.mResolver.delete(ContactsContract.Data.CONTENT_URI, selection5, null);
        }
        for (PhoneData phone : this.mPhoneList) {
            String selection6 = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/phone_v2'");
            Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, selection6, null, null);
            Log.d(TAG, "save phone" + cursor.getCount());
            try {
                if (cursor.getCount() > 0) {
                    this.mResolver.update(ContactsContract.Data.CONTENT_URI, phone.toValues(this.mId), selection6, null);
                } else {
                    Log.d(TAG, "insert phone");
                    this.mResolver.insert(ContactsContract.Data.CONTENT_URI, phone.toValues(this.mId));
                }
                if (cursor != null) {
                    cursor.close();
                }
                Log.d(TAG, "end save phone");
            } catch (Throwable th) {
                if (cursor != null) {
                    cursor.close();
                }
                throw th;
            }
        }
        for (ContactMethod contactMethod : this.mContactmethodList) {
            String selection7 = new String("raw_contact_id=" + this.mId + " AND (mimetype='vnd.android.cursor.item/email_v2' OR mimetype='vnd.android.cursor.item/postal-address_v2' OR mimetype='vnd.android.cursor.item/website')");
            Cursor cursor2 = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, selection7, null, null);
            Log.d(TAG, "save contactMethod" + cursor2.getCount());
            try {
                try {
                    this.mResolver.insert(ContactsContract.Data.CONTENT_URI, contactMethod.toValues(this.mId));
                    if (cursor2 != null) {
                        cursor2.close();
                    }
                } catch (IllegalArgumentException e) {
                    Log.e(TAG, " kind " + contactMethod.kind + " with type " + contactMethod.type + " is not supported! can't insert");
                    if (cursor2 != null) {
                        cursor2.close();
                    }
                }
            } catch (Throwable th2) {
                if (cursor2 != null) {
                    cursor2.close();
                }
                throw th2;
            }
        }
        if (this.mPhoto != null && this.mPhoto.length > 0) {
            Log.d(TAG, " the photo encoded data length is " + this.mPhoto.length);
            try {
                String photoStr = new String(this.mPhoto);
                this.mPhoto = Base64Coder.decode(photoStr.toCharArray());
            } catch (IllegalArgumentException iae) {
                Log.d(TAG, " based decode error? " + iae.getMessage());
            }
            Log.d(TAG, " the photo binary data length is " + this.mPhoto.length);
            String selection8 = new String("raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/photo'");
            Cursor cursor3 = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, selection8, null, null);
            Log.d(TAG, "photo" + cursor3.getCount());
            try {
                if (cursor3.getCount() > 0) {
                    this.mResolver.update(ContactsContract.Data.CONTENT_URI, phototoValues(this.mId), selection8, null);
                } else {
                    this.mResolver.insert(ContactsContract.Data.CONTENT_URI, phototoValues(this.mId));
                }
                if (cursor3 != null) {
                    cursor3.close();
                }
            } catch (Throwable th3) {
                if (cursor3 != null) {
                    cursor3.close();
                }
                throw th3;
            }
        }
        Log.d("JbedPimManager", " save() the new contact id=" + this.mId);
        return this.mId;
    }

    private Uri getPhoneURI(Uri contactURI) {
        return contactURI;
    }

    private Uri getContactMethodsURI(Uri contactURI) {
        return contactURI;
    }

    private Uri getPhotosURI(Uri contactURI) {
        return contactURI;
    }

    private Uri getOrganizationURI(Uri contactURI) {
        return contactURI;
    }

    /* JADX INFO: Access modifiers changed from: private */
    public static String foldingString(String str) {
        return str.replaceAll(NEW_LINE, BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER).replaceAll(BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER, "\r\n ");
    }

    public String toString() {
        String s = "id=" + this.mId + " name=" + this.mName + " notes=" + this.mNotes + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
        for (Organization org : this.mOrganizationList) {
            s = s + org.toString() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
        }
        for (PhoneData phone : this.mPhoneList) {
            s = s + phone.toString() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
        }
        for (ContactMethod contactMethod : this.mContactmethodList) {
            s = s + contactMethod.toString() + BasicEventHandler.ListCertificatesEventHandler.CertificatesItemAdapter.DELIMITER;
        }
        return s;
    }

    @Override // com.esmertec.android.jbed.jsr.JbedPimManager.PimAction
    public String getNext(String id) {
        if (TextUtils.isEmpty(id)) {
            id = "-1";
        }
        String result = null;
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, new String[]{"raw_contact_id", "data1"}, "raw_contact_id>" + id + " AND mimetype='vnd.android.cursor.item/name'", null, "raw_contact_id ASC");
        Log.d(TAG, "cursor is " + cursor);
        if (cursor == null) {
            return null;
        }
        Log.d(TAG, "after cursor is " + cursor.getCount());
        if (cursor != null) {
            try {
                if (cursor.moveToFirst()) {
                    long curId = cursor.getLong(cursor.getColumnIndexOrThrow("raw_contact_id"));
                    Log.d(TAG, "getNext first one id= " + curId);
                    ContentUris.withAppendedId(ContactsContract.Data.CONTENT_URI, curId);
                    loadOneContact(curId);
                    result = toVCard();
                }
            } finally {
                cursor.close();
            }
        }
        return result;
    }

    /* JADX WARN: Code duplicated, block: B:16:0x0110 A[Catch: all -> 0x0119, TRY_ENTER, TRY_LEAVE, TryCatch #1 {all -> 0x0119, blocks: (B:4:0x0066, B:6:0x006c, B:7:0x0078, B:16:0x0110), top: B:28:0x0066 }] */
    /* JADX WARN: Code duplicated, block: B:21:0x011e A[Catch: all -> 0x0126, TRY_ENTER, TRY_LEAVE, TryCatch #0 {all -> 0x0126, blocks: (B:10:0x00d4, B:12:0x00da, B:13:0x00e6, B:21:0x011e), top: B:26:0x00d4 }] */
    private void loadOneContact(long curId) {
        this.mId = curId;
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/name'", null, null);
        Log.d(TAG, "Load One Contact:  cursor is " + cursor.getCount());
        if (cursor == null) {
            Log.d(TAG, "cursor is null in loadonecontact");
        } else {
            try {
                if (cursor.moveToLast()) {
                    this.mName = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                } else {
                    Log.d(TAG, "cursor is null in loadonecontact");
                }
            } catch (Throwable th) {
                cursor.close();
                throw th;
            }
        }
        Log.d(TAG, "name=" + this.mName);
        cursor.close();
        Cursor cursor2 = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + this.mId + " AND mimetype='vnd.android.cursor.item/note'", null, null);
        if (cursor2 == null) {
            Log.d(TAG, "cursor is null in loadonecontact");
        } else {
            try {
                if (cursor2.moveToLast()) {
                    this.mNotes = cursor2.getString(cursor2.getColumnIndexOrThrow("data1"));
                } else {
                    Log.d(TAG, "cursor is null in loadonecontact");
                }
            } catch (Throwable th2) {
                cursor2.close();
                throw th2;
            }
        }
        Log.d(TAG, "mNotes=" + this.mNotes);
        cursor2.close();
        loadOrganizations(curId);
        loadPhone(curId);
        loadContactMethods(curId);
        loadPhoto(curId);
    }

    private void loadPhone(long mId) {
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + mId + " AND mimetype='vnd.android.cursor.item/phone_v2'", null, null);
        Log.d(TAG, "Load Phone:  cursor is " + cursor.getCount());
        while (cursor != null) {
            try {
                if (!cursor.moveToNext()) {
                    break;
                }
                String data = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                Log.d(TAG, "data=" + data);
                int type = cursor.getInt(cursor.getColumnIndexOrThrow("data2"));
                String label = cursor.getString(cursor.getColumnIndexOrThrow("data3"));
                addPhone(data, type, label);
            } catch (Throwable th) {
                if (cursor != null) {
                    cursor.close();
                }
                throw th;
            }
        }
        if (cursor != null) {
            cursor.close();
        }
    }

    /* JADX WARN: Code duplicated, block: B:27:0x0113  */
    /* JADX WARN: Code duplicated, block: B:37:? A[RETURN, SYNTHETIC] */
    private void loadContactMethods(long mId) {
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + mId + " AND (mimetype='vnd.android.cursor.item/email_v2' OR mimetype='vnd.android.cursor.item/postal-address_v2' OR mimetype='vnd.android.cursor.item/website')", null, null);
        while (cursor != null) {
            try {
                if (cursor.moveToNext()) {
                    int type = 0;
                    String data = null;
                    int kind = 0;
                    String minetype = cursor.getString(cursor.getColumnIndexOrThrow("mimetype"));
                    Log.d(TAG, " minetype=" + minetype);
                    if (minetype.compareTo("vnd.android.cursor.item/email_v2") == 0) {
                        kind = 4;
                    } else if (minetype.compareTo("vnd.android.cursor.item/postal-address_v2") == 0) {
                        kind = 5;
                    } else if (minetype.compareTo("vnd.android.cursor.item/website") == 0) {
                        kind = 6;
                    }
                    switch (kind) {
                        case 4:
                            type = cursor.getInt(cursor.getColumnIndexOrThrow("data2"));
                            data = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                            break;
                        case 5:
                            type = cursor.getInt(cursor.getColumnIndexOrThrow("data2"));
                            data = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                            break;
                        case 6:
                            type = cursor.getInt(cursor.getColumnIndexOrThrow("data2"));
                            data = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                            break;
                    }
                    addContactMethod(kind, type, data);
                } else if (cursor != null) {
                    cursor.close();
                }
            } catch (Throwable th) {
                if (cursor != null) {
                    cursor.close();
                }
                throw th;
            }
        }
        if (cursor != null) {
            cursor.close();
        }
    }

    private void loadPhoto(long mId) {
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + mId + " AND mimetype='vnd.android.cursor.item/photo'", null, null);
        Log.d(TAG, "loadPhoto:  cursor is " + cursor.getCount() + "movetoLast= " + cursor.moveToLast());
        if (cursor != null) {
            try {
                if (cursor.moveToLast()) {
                    Log.d(TAG, "Test Photo");
                    this.mPhoto = cursor.getBlob(cursor.getColumnIndexOrThrow("data15"));
                }
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
    }

    private void loadOrganizations(long mId) {
        Cursor cursor = this.mResolver.query(ContactsContract.Data.CONTENT_URI, null, "raw_contact_id=" + mId + " AND mimetype='vnd.android.cursor.item/organization'", null, null);
        while (cursor != null) {
            try {
                if (!cursor.moveToNext()) {
                    break;
                }
                String company = cursor.getString(cursor.getColumnIndexOrThrow("data1"));
                String title = cursor.getString(cursor.getColumnIndexOrThrow("data4"));
                addOrganization(title, company);
            } catch (Throwable th) {
                if (cursor != null) {
                    cursor.close();
                }
                throw th;
            }
        }
        if (cursor != null) {
            cursor.close();
        }
    }

    @Override // com.esmertec.android.jbed.jsr.JbedPimManager.PimAction
    public int remove(String mId) {
        if (TextUtils.isEmpty(mId)) {
            Log.e(TAG, " the id is empty! can't delete");
            return -1;
        }
        Log.d("JbedPimManager", "delete old contact id=" + mId);
        Uri contactURI = ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, Long.parseLong(mId));
        int count = this.mResolver.delete(contactURI, null, null);
        if (count == 0) {
            Log.w(TAG, "WARNING: failed to delete contact id " + mId);
        }
        return 0;
    }

    public static long store(ContentResolver resolver, String id, String name, int[] nameAttr, String[] names, String company, String title, String notes, int[] phoneAttr, String[] phones, int[] emailAttr, String[] emails, int[] addrAttr, String[] addrs, int[] urlAttr, String[] urls, byte[] photo) {
        JbedContact contact = new JbedContact(resolver);
        if (TextUtils.isEmpty(id)) {
            contact.mId = 0L;
        } else {
            contact.mId = Long.parseLong(id);
        }
        if (TextUtils.isEmpty(name)) {
            name = EMPTY_CONTACT_NAME;
        }
        contact.mName = name;
        contact.mNotes = notes;
        Log.d(TAG, "phones=" + phones.length + " emails=" + emails.length + " addrs=" + addrs.length + " urls=" + urls.length);
        contact.addOrganization(title, company);
        for (int i = 0; i < phones.length; i++) {
            contact.addJbedPhone(phoneAttr[i], phones[i]);
        }
        for (int i2 = 0; i2 < emails.length; i2++) {
            contact.addJbedEmail(emailAttr[i2], emails[i2]);
        }
        for (int i3 = 0; i3 < addrs.length; i3++) {
            contact.addJbedAddr(addrAttr[i3], addrs[i3]);
        }
        for (int i4 = 0; i4 < urls.length; i4++) {
            contact.addJbedUrl(urlAttr[i4], urls[i4]);
        }
        contact.mPhoto = photo;
        Log.d(TAG, " store() contact " + contact.toString());
        return contact.save();
    }

    private String mergeDataToText(List<?> list) {
        List<SimpleEntry<String, String>> mergeList = new ArrayList<>();
        Iterator<?> it = list.iterator();
        while (it.hasNext()) {
            Mergeable mergeable = (Mergeable) it.next();
            String data = mergeable.getData();
            if (!TextUtils.isEmpty(data)) {
                String attr = mergeable.getAttribute();
                String keyword = mergeable.getKeyWord();
                Log.d(TAG, " keyword " + keyword);
                for (SimpleEntry<String, String> entry : mergeList) {
                    if (entry.getKey().equals(data)) {
                        attr = entry.getValue() + ";" + attr;
                        break;
                    }
                }
                mergeList.add(new SimpleEntry<>(data, keyword + ";" + attr));
            }
        }
        StringBuilder result = new StringBuilder();
        for (SimpleEntry<String, String> entry2 : mergeList) {
            result.append(entry2.getValue()).append(":").append(entry2.getKey()).append(NEW_LINE);
        }
        return result.toString();
    }
}
