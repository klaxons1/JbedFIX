.class Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;
.super Landroid/database/sqlite/SQLiteOpenHelper;
.source "JbedProvider.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/JbedProvider;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "DatabaseHelper"
.end annotation


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 3
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 169
    const-string v0, "jbed.db"

    const/4 v1, 0x0

    const/16 v2, 0x23

    invoke-direct {p0, p1, v0, v1, v2}, Landroid/database/sqlite/SQLiteOpenHelper;-><init>(Landroid/content/Context;Ljava/lang/String;Landroid/database/sqlite/SQLiteDatabase$CursorFactory;I)V

    .line 170
    return-void
.end method

.method private createDefaultFolders()V
    .locals 1

    .prologue
    .line 261
    const-string v0, "/data/data/com.esmertec.android.jbed/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 262
    const-string v0, "/data/data/com.esmertec.android.jbed/Installed/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 263
    const-string v0, "/data/data/com.esmertec.android.jbed/LocalInstall/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 264
    const-string v0, "/data/data/com.esmertec.android.jbed/PreInstall/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 265
    const-string v0, "/data/data/com.esmertec.android.jbed/certs/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 266
    const-string v0, "/data/data/com.esmertec.android.jbed/certs/SIM/DF/trustedCertificates/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 267
    const-string v0, "/data/data/com.esmertec.android.jbed/certs/DEVICE/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 268
    const-string v0, "/data/data/com.esmertec.android.jbed/tmp/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 269
    const-string v0, "/data/data/com.esmertec.android.jbed/location/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 270
    const-string v0, "/data/data/com.esmertec.android.jbed/PendingInstall/"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createFolder(Ljava/lang/String;)V

    .line 271
    return-void
.end method

.method private createFolder(Ljava/lang/String;)V
    .locals 5
    .param p1, "folder"    # Ljava/lang/String;

    .prologue
    const/4 v3, -0x1

    .line 236
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 237
    .local v0, "file":Ljava/io/File;
    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 258
    :goto_0
    return-void

    .line 239
    :cond_0
    invoke-virtual {v0}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-nez v2, :cond_1

    .line 240
    new-instance v2, Ljava/lang/IllegalStateException;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, " failed to create import folder ["

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, "]! please check the permission with [ls -l]"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 244
    :cond_1
    const/16 v1, 0x1f4

    .line 246
    .local v1, "mode":I
    const-string v2, "/data/data/com.esmertec.android.jbed/tmp/"

    invoke-virtual {p1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_2

    .line 248
    or-int/lit8 v1, v1, 0x1

    .line 257
    :cond_2
    invoke-static {p1, v1, v3, v3}, Landroid/os/FileUtils;->setPermissions(Ljava/lang/String;III)I

    goto :goto_0
.end method


# virtual methods
.method public onCreate(Landroid/database/sqlite/SQLiteDatabase;)V
    .locals 1
    .param p1, "db"    # Landroid/database/sqlite/SQLiteDatabase;

    .prologue
    .line 174
    const-string v0, "CREATE TABLE settings (_id INTEGER PRIMARY KEY,root_dir TEXT,base_dir TEXT,localinstall_dir TEXT,certs_root_dir TEXT,is_nativeams INTEGER,is_runtck INTEGER,tck_url TEXT,is_allowed_hidden_menu INTEGER,is_launch_ams_list INTEGER,extra_command_line TEXT,sync_certs_size INTEGER DEFAULT 0,sync_certs_date INTEGER DEFAULT 0);"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V

    .line 191
    const-string v0, "INSERT INTO settings (root_dir,base_dir,localinstall_dir,certs_root_dir,is_nativeams,is_runtck,tck_url,is_allowed_hidden_menu,is_launch_ams_list,extra_command_line) VALUES (\'/data/data/com.esmertec.android.jbed/\',\'/data/data/com.esmertec.android.jbed/Installed/\',\'/data/data/com.esmertec.android.jbed/LocalInstall/\',\'/data/data/com.esmertec.android.jbed/certs/\',1 ,0 ,\'\' ,0 ,0 ,\'\');"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V

    .line 210
    const-string v0, "CREATE TABLE midlets (_id INTEGER PRIMARY KEY,uid TEXT not null,name TEXT not null,no INTEGER not null,root TEXT not null,parent_uid TEXT,storage_path TEXT not null,file_root TEXT,vendor TEXT,install_time INTEGER,domain TEXT,size INTEGER DEFAULT 0,removable TEXT,_data TEXT,drm_protected TEXT,drm_pending TEXT,is_hidden INTEGER,has_short_cut INTEGER DEFAULT 0,display_info TEXT);"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V

    .line 232
    invoke-direct {p0}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->createDefaultFolders()V

    .line 233
    return-void
.end method

.method public onUpgrade(Landroid/database/sqlite/SQLiteDatabase;II)V
    .locals 3
    .param p1, "db"    # Landroid/database/sqlite/SQLiteDatabase;
    .param p2, "oldVersion"    # I
    .param p3, "currentVersion"    # I

    .prologue
    const-string v2, "JbedProvider"

    .line 275
    const-string v0, "JbedProvider"

    const/4 v0, 0x5

    invoke-static {v2, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "JbedProvider"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Upgrading setting database from version "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, " to "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", which will destroy all old data"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 278
    :cond_0
    const-string v0, "DROP TABLE IF EXISTS settings"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V

    .line 279
    const-string v0, "DROP TABLE IF EXISTS midlets"

    invoke-virtual {p1, v0}, Landroid/database/sqlite/SQLiteDatabase;->execSQL(Ljava/lang/String;)V

    .line 280
    invoke-virtual {p0, p1}, Lcom/esmertec/android/jbed/JbedProvider$DatabaseHelper;->onCreate(Landroid/database/sqlite/SQLiteDatabase;)V

    .line 281
    return-void
.end method
