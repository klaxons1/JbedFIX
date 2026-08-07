package com.esmertec.android.jbed;

import android.content.ContentProvider;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.database.sqlite.SQLiteQueryBuilder;
import android.net.Uri;
import android.os.FileUtils;
import android.os.ParcelFileDescriptor;
import android.provider.BaseColumns;
import android.text.TextUtils;
import android.util.Log;
import java.io.File;
import java.io.FileNotFoundException;

/* JADX INFO: loaded from: classes.dex */
public class JbedProvider extends ContentProvider {
    private static final String AUTHORITY = "jbed";
    private static final String DATABASE_NAME = "jbed.db";
    private static final int DATABASE_VERSION = 35;
    public static final boolean DEBUG = false;
    private static final int MATCH_MIDLETS = 2;
    private static final int MATCH_MIDLET_ID = 3;
    private static final int MATCH_SETTINGS = 1;
    private static final String TAG = "JbedProvider";
    private SQLiteDatabase mDb;
    private static final String BASE_URI = "content://jbed";
    private static final int BASE_URI_LEN = BASE_URI.length();
    private static final UriMatcher sUrlMatcher = new UriMatcher(-1);

    public static class Midlets implements BaseColumns {
        public static final Uri CONTENT_URI = Uri.parse("content://jbed/midlets");
        public static final String DISPLAY_INFO = "display_info";
        public static final String DOMAIN = "domain";
        public static final String DRM_PENDING = "drm_pending";
        public static final String DRM_PROTECTED = "drm_protected";
        public static final String FILE_ROOT = "file_root";
        public static final String HAS_SHORT_CUT = "has_short_cut";
        public static final String HIDDEN = "is_hidden";
        public static final String ICON_PATH = "_data";
        public static final String INSTALL_TIME = "install_time";
        public static final String NAME = "name";
        public static final String NO = "no";
        public static final String PARENT_UID = "parent_uid";
        public static final String REMOVABLE = "removable";
        public static final String ROOT = "root";
        public static final String SIZE = "size";
        public static final String STORAGE_PATH = "storage_path";
        public static final String TABLE_NAME = "midlets";
        public static final String UID = "uid";
        public static final String VENDOR = "vendor";
    }

    public static class Settings {
        public static final String BASE_DIR_COLUMN = "base_dir";
        public static final String CERTS_ROOT_DIR_COLUMN = "certs_root_dir";
        public static final Uri CONTENT_URI = Uri.parse("content://jbed/settings");
        public static final String DEFAULT_BASE_DIR = "/data/data/com.esmertec.android.jbed/Installed/";
        public static final String DEFAULT_CERTS_DEVICE_DIR = "/data/data/com.esmertec.android.jbed/certs/SIM/DF/trustedCertificates/";
        public static final String DEFAULT_CERTS_ROOT_DIR = "/data/data/com.esmertec.android.jbed/certs/";
        public static final String DEFAULT_LAPI_DIR = "/data/data/com.esmertec.android.jbed/location/";
        public static final String DEFAULT_LOCALINSTALL_DIR = "/data/data/com.esmertec.android.jbed/LocalInstall/";
        public static final String DEFAULT_PENDINGINSTALL_DIR = "/data/data/com.esmertec.android.jbed/PendingInstall/";
        public static final String DEFAULT_PREINSTALL_DIR = "/data/data/com.esmertec.android.jbed/PreInstall/";
        public static final String DEFAULT_ROOT_DIR = "/data/data/com.esmertec.android.jbed/";
        public static final String DEFAULT_TMP_DIR = "/data/data/com.esmertec.android.jbed/tmp/";
        public static final String EXTRA_COMMAND_LINE_COLUMN = "extra_command_line";
        public static final String IS_ALLOWED_HIDDEN_MENU_COLUMN = "is_allowed_hidden_menu";
        public static final String IS_LAUNCH_AMS_LIST_COLUMN = "is_launch_ams_list";
        public static final String IS_NATIVEAMS_COLUMN = "is_nativeams";
        public static final String IS_RUNTCK_COLUMN = "is_runtck";
        public static final String LOCALINSTALL_DIR_COLUMN = "localinstall_dir";
        public static final String OPERATOR_CERTS_DEVICE_DIR = "/data/data/com.esmertec.android.jbed/certs/DEVICE/";
        public static final String ROOT_DIR_COLUMN = "root_dir";
        public static final String SYNC_CERTS_DATE_COLUMN = "sync_certs_date";
        public static final String SYNC_CERTS_SIZE_COLUMN = "sync_certs_size";
        private static final String TABLE_NAME = "settings";
        public static final String TCK_URL_COLUMN = "tck_url";
    }

    static {
        sUrlMatcher.addURI(AUTHORITY, JbedSettings.SETTINGS_NAME, 1);
        sUrlMatcher.addURI(AUTHORITY, Midlets.TABLE_NAME, 2);
        sUrlMatcher.addURI(AUTHORITY, "midlets/#", 3);
    }

    private static class DatabaseHelper extends SQLiteOpenHelper {
        public DatabaseHelper(Context context) {
            super(context, JbedProvider.DATABASE_NAME, (SQLiteDatabase.CursorFactory) null, 35);
        }

        @Override // android.database.sqlite.SQLiteOpenHelper
        public void onCreate(SQLiteDatabase db) {
            db.execSQL("CREATE TABLE settings (_id INTEGER PRIMARY KEY,root_dir TEXT,base_dir TEXT,localinstall_dir TEXT,certs_root_dir TEXT,is_nativeams INTEGER,is_runtck INTEGER,tck_url TEXT,is_allowed_hidden_menu INTEGER,is_launch_ams_list INTEGER,extra_command_line TEXT,sync_certs_size INTEGER DEFAULT 0,sync_certs_date INTEGER DEFAULT 0);");
            db.execSQL("INSERT INTO settings (root_dir,base_dir,localinstall_dir,certs_root_dir,is_nativeams,is_runtck,tck_url,is_allowed_hidden_menu,is_launch_ams_list,extra_command_line) VALUES ('/data/data/com.esmertec.android.jbed/','/data/data/com.esmertec.android.jbed/Installed/','/data/data/com.esmertec.android.jbed/LocalInstall/','/data/data/com.esmertec.android.jbed/certs/',1 ,0 ,'' ,0 ,0 ,'');");
            db.execSQL("CREATE TABLE midlets (_id INTEGER PRIMARY KEY,uid TEXT not null,name TEXT not null,no INTEGER not null,root TEXT not null,parent_uid TEXT,storage_path TEXT not null,file_root TEXT,vendor TEXT,install_time INTEGER,domain TEXT,size INTEGER DEFAULT 0,removable TEXT,_data TEXT,drm_protected TEXT,drm_pending TEXT,is_hidden INTEGER,has_short_cut INTEGER DEFAULT 0,display_info TEXT);");
            createDefaultFolders();
        }

        private void createFolder(String folder) {
            File file = new File(folder);
            if (!file.exists()) {
                if (!file.mkdirs()) {
                    throw new IllegalStateException(" failed to create import folder [" + folder + "]! please check the permission with [ls -l]");
                }
                int mode = 500;
                if (folder.equals(Settings.DEFAULT_TMP_DIR)) {
                    mode = 500 | 1;
                }
                FileUtils.setPermissions(folder, mode, -1, -1);
            }
        }

        private void createDefaultFolders() {
            createFolder(Settings.DEFAULT_ROOT_DIR);
            createFolder(Settings.DEFAULT_BASE_DIR);
            createFolder(Settings.DEFAULT_LOCALINSTALL_DIR);
            createFolder(Settings.DEFAULT_PREINSTALL_DIR);
            createFolder(Settings.DEFAULT_CERTS_ROOT_DIR);
            createFolder(Settings.DEFAULT_CERTS_DEVICE_DIR);
            createFolder(Settings.OPERATOR_CERTS_DEVICE_DIR);
            createFolder(Settings.DEFAULT_TMP_DIR);
            createFolder(Settings.DEFAULT_LAPI_DIR);
            createFolder(Settings.DEFAULT_PENDINGINSTALL_DIR);
        }

        @Override // android.database.sqlite.SQLiteOpenHelper
        public void onUpgrade(SQLiteDatabase db, int oldVersion, int currentVersion) {
            if (Log.isLoggable(JbedProvider.TAG, 5)) {
                Log.w(JbedProvider.TAG, "Upgrading setting database from version " + oldVersion + " to " + currentVersion + ", which will destroy all old data");
            }
            db.execSQL("DROP TABLE IF EXISTS settings");
            db.execSQL("DROP TABLE IF EXISTS midlets");
            onCreate(db);
        }
    }

    @Override // android.content.ContentProvider
    public boolean onCreate() {
        DatabaseHelper dbHelper = new DatabaseHelper(getContext());
        this.mDb = dbHelper.getWritableDatabase();
        return this.mDb != null;
    }

    @Override // android.content.ContentProvider
    public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
        SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
        int match = sUrlMatcher.match(uri);
        switch (match) {
            case 1:
                qb.setTables(JbedSettings.SETTINGS_NAME);
                break;
            case 2:
                qb.setTables(Midlets.TABLE_NAME);
                break;
            case 3:
                qb.setTables(Midlets.TABLE_NAME);
                qb.appendWhere("_id=" + ContentUris.parseId(uri));
                break;
            default:
                throw new IllegalArgumentException(uri.toString());
        }
        Cursor ret = qb.query(this.mDb, projection, selection, selectionArgs, null, null, sortOrder);
        return ret;
    }

    @Override // android.content.ContentProvider
    public int delete(Uri uri, String selection, String[] selectionArgs) {
        String table;
        int match = sUrlMatcher.match(uri);
        String extraSelection = null;
        switch (match) {
            case 2:
                table = Midlets.TABLE_NAME;
                break;
            case 3:
                table = Midlets.TABLE_NAME;
                extraSelection = "_id=" + ContentUris.parseId(uri);
                break;
            default:
                throw new IllegalArgumentException(uri.toString());
        }
        String finalSelection = concatSelections(selection, extraSelection);
        return this.mDb.delete(table, finalSelection, selectionArgs);
    }

    private static String concatSelections(String selection1, String selection2) {
        if (TextUtils.isEmpty(selection1)) {
            return selection2;
        }
        return TextUtils.isEmpty(selection2) ? selection1 : selection1 + " AND " + selection2;
    }

    @Override // android.content.ContentProvider
    public String getType(Uri uri) {
        int match = sUrlMatcher.match(uri);
        switch (match) {
            case 2:
                return "*/*";
            default:
                throw new IllegalArgumentException(uri.toString());
        }
    }

    @Override // android.content.ContentProvider
    public Uri insert(Uri uri, ContentValues values) {
        int match = sUrlMatcher.match(uri);
        switch (match) {
            case 2:
                ContentValues finalValues = new ContentValues(values);
                if (Midlets.TABLE_NAME.equals(Midlets.TABLE_NAME)) {
                    long rowId = this.mDb.insert(Midlets.TABLE_NAME, null, finalValues);
                    if (rowId > 0) {
                        return ContentUris.withAppendedId(Midlets.CONTENT_URI, rowId);
                    }
                    if (Log.isLoggable(TAG, 6)) {
                        Log.e(TAG, "JbedProvider.insert: failed! " + finalValues);
                    }
                    return null;
                }
                throw new AssertionError("Unknown table type: " + Midlets.TABLE_NAME);
            default:
                throw new IllegalArgumentException(uri.toString());
        }
    }

    @Override // android.content.ContentProvider
    public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
        throw new UnsupportedOperationException();
    }

    @Override // android.content.ContentProvider
    public ParcelFileDescriptor openFile(Uri uri, String mode) throws FileNotFoundException {
        String uriPath = uri.toString();
        if (!uriPath.substring(uriPath.length() - "utf".length(), uriPath.length()).equalsIgnoreCase("utf")) {
            return openFileHelper(uri, mode);
        }
        if (!"r".equals(mode)) {
            throw new FileNotFoundException("Bad mode for " + uri + ": " + mode);
        }
        String filename = uriPath.substring(BASE_URI_LEN);
        return ParcelFileDescriptor.open(new File(filename), 268435456);
    }
}
