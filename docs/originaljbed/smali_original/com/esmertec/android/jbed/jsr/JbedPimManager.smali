.class public Lcom/esmertec/android/jbed/jsr/JbedPimManager;
.super Ljava/lang/Object;
.source "JbedPimManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/service/JbedService$LifecycleListener;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;
    }
.end annotation


# static fields
.field static final CONTACT_LIST:I = 0x1

.field static final EVENT_LIST:I = 0x2

.field private static INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager; = null

.field static final TAG:Ljava/lang/String; = "JbedPimManager"

.field static final TODO_LIST:I = 0x3


# instance fields
.field private mResolver:Landroid/content/ContentResolver;


# direct methods
.method static constructor <clinit>()V
    .locals 0

    .prologue
    .line 41
    invoke-static {}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->nativeInitialization()V

    .line 42
    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 44
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 45
    sput-object p0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    .line 46
    return-void
.end method

.method static convertIdToBytes(J)[B
    .locals 6
    .param p0, "id"    # J

    .prologue
    .line 74
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 75
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 76
    .local v3, "out":Ljava/io/DataOutputStream;
    const/4 v1, 0x0

    .line 79
    .local v1, "data":[B
    const-wide/16 v4, -0x1

    :try_start_0
    invoke-virtual {v3, v4, v5}, Ljava/io/DataOutputStream;->writeLong(J)V

    .line 81
    invoke-static {p0, p1}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    .line 82
    invoke-virtual {v3, v1}, Ljava/io/DataOutputStream;->write([B)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 87
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v4

    :goto_0
    return-object v4

    .line 83
    :catch_0
    move-exception v4

    move-object v2, v4

    .line 84
    .local v2, "e":Ljava/lang/Exception;
    const-string v4, "JbedPimManager"

    const-string v5, " failed to wrap the id to bytes"

    invoke-static {v4, v5, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 85
    const/4 v4, 0x0

    goto :goto_0
.end method

.method static convertToBytes(Ljava/lang/String;)[B
    .locals 6
    .param p0, "contents"    # Ljava/lang/String;

    .prologue
    .line 57
    new-instance v0, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v0}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 58
    .local v0, "bo":Ljava/io/ByteArrayOutputStream;
    new-instance v3, Ljava/io/DataOutputStream;

    invoke-direct {v3, v0}, Ljava/io/DataOutputStream;-><init>(Ljava/io/OutputStream;)V

    .line 60
    .local v3, "out":Ljava/io/DataOutputStream;
    :try_start_0
    const-string v4, "utf-8"

    invoke-virtual {p0, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v1

    .line 62
    .local v1, "data":[B
    array-length v4, v1

    invoke-virtual {v3, v4}, Ljava/io/DataOutputStream;->writeInt(I)V

    .line 64
    invoke-virtual {v3, v1}, Ljava/io/DataOutputStream;->write([B)V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 70
    invoke-virtual {v0}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v4

    .end local v1    # "data":[B
    :goto_0
    return-object v4

    .line 66
    :catch_0
    move-exception v4

    move-object v2, v4

    .line 67
    .local v2, "e":Ljava/lang/Exception;
    const-string v4, "JbedPimManager"

    const-string v5, " failed to wrap vcard to bytes"

    invoke-static {v4, v5, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 68
    const/4 v4, 0x0

    goto :goto_0
.end method

.method private static getAction(I)Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;
    .locals 2
    .param p0, "type"    # I

    .prologue
    .line 91
    const/4 v0, 0x1

    if-ne p0, v0, :cond_0

    .line 92
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedContact;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedContact;-><init>(Landroid/content/ContentResolver;)V

    .line 98
    :goto_0
    return-object v0

    .line 93
    :cond_0
    const/4 v0, 0x3

    if-ne p0, v0, :cond_1

    .line 94
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;-><init>(Landroid/content/ContentResolver;)V

    goto :goto_0

    .line 95
    :cond_1
    const/4 v0, 0x2

    if-ne p0, v0, :cond_2

    .line 96
    new-instance v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v1, v1, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    invoke-direct {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;-><init>(Landroid/content/ContentResolver;)V

    goto :goto_0

    .line 98
    :cond_2
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public static getNextItem(ILjava/lang/String;)[B
    .locals 3
    .param p0, "type"    # I
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    const/4 v2, 0x0

    .line 112
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->getAction(I)Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;

    move-result-object v0

    .line 113
    .local v0, "action":Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;
    if-nez v0, :cond_1

    .line 118
    :cond_0
    :goto_0
    return-object v2

    .line 115
    :cond_1
    invoke-interface {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;->getNext(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    .line 116
    .local v1, "content":Ljava/lang/String;
    if-eqz v1, :cond_0

    .line 117
    invoke-static {v1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->convertToBytes(Ljava/lang/String;)[B

    move-result-object v2

    goto :goto_0
.end method

.method public static isSupported(I)Z
    .locals 1
    .param p0, "type"    # I

    .prologue
    .line 105
    const/4 v0, 0x3

    if-ne p0, v0, :cond_0

    .line 106
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->isSupported(Landroid/content/ContentResolver;)Z

    move-result v0

    .line 108
    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x1

    goto :goto_0
.end method

.method private static native nativeInitialization()V
.end method

.method public static remove(ILjava/lang/String;)I
    .locals 2
    .param p0, "type"    # I
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    .line 122
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->getAction(I)Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;

    move-result-object v0

    .line 123
    .local v0, "action":Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;
    if-nez v0, :cond_0

    .line 124
    const/4 v1, -0x1

    .line 125
    :goto_0
    return v1

    :cond_0
    invoke-interface {v0, p1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;->remove(Ljava/lang/String;)I

    move-result v1

    goto :goto_0
.end method

.method public static removeByUri(Landroid/content/ContentResolver;Landroid/net/Uri;Landroid/net/Uri;Ljava/lang/String;)V
    .locals 11
    .param p0, "resolver"    # Landroid/content/ContentResolver;
    .param p1, "fromUri"    # Landroid/net/Uri;
    .param p2, "deleteUri"    # Landroid/net/Uri;
    .param p3, "where"    # Ljava/lang/String;

    .prologue
    const/4 v2, 0x0

    .line 156
    move-object v0, p0

    move-object v1, p1

    move-object v3, p3

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v7

    .line 158
    .local v7, "cursor":Landroid/database/Cursor;
    :cond_0
    :goto_0
    if-eqz v7, :cond_3

    :try_start_0
    invoke-interface {v7}, Landroid/database/Cursor;->moveToNext()Z

    move-result v0

    if-eqz v0, :cond_3

    .line 159
    const-string v0, "_id"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v8

    .line 160
    .local v8, "id":J
    if-eqz p2, :cond_2

    move-object v0, p2

    :goto_1
    invoke-static {v0, v8, v9}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v10

    .line 161
    .local v10, "uri":Landroid/net/Uri;
    const/4 v0, 0x0

    const/4 v1, 0x0

    invoke-virtual {p0, v10, v0, v1}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I

    move-result v6

    .line 162
    .local v6, "count":I
    if-nez v6, :cond_0

    .line 163
    const-string v0, "JbedPimManager"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "WARNING: failed to delete id "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, v8, v9}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    goto :goto_0

    .line 166
    .end local v6    # "count":I
    .end local v8    # "id":J
    .end local v10    # "uri":Landroid/net/Uri;
    :catchall_0
    move-exception v0

    if-eqz v7, :cond_1

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    :cond_1
    throw v0

    .restart local v8    # "id":J
    :cond_2
    move-object v0, p1

    .line 160
    goto :goto_1

    .line 166
    .end local v8    # "id":J
    :cond_3
    if-eqz v7, :cond_4

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 168
    :cond_4
    return-void
.end method

.method static storeContact(Ljava/lang/String;Ljava/lang/String;[I[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[B)[B
    .locals 17
    .param p0, "id"    # Ljava/lang/String;
    .param p1, "name"    # Ljava/lang/String;
    .param p2, "nameAttr"    # [I
    .param p3, "names"    # [Ljava/lang/String;
    .param p4, "company"    # Ljava/lang/String;
    .param p5, "title"    # Ljava/lang/String;
    .param p6, "notes"    # Ljava/lang/String;
    .param p7, "phoneAttr"    # [I
    .param p8, "phones"    # [Ljava/lang/String;
    .param p9, "emailAttr"    # [I
    .param p10, "emails"    # [Ljava/lang/String;
    .param p11, "addrAttr"    # [I
    .param p12, "addrs"    # [Ljava/lang/String;
    .param p13, "urlAttr"    # [I
    .param p14, "urls"    # [Ljava/lang/String;
    .param p15, "photo"    # [B

    .prologue
    .line 131
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v0, v0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    move-object/from16 v1, p0

    move-object/from16 v2, p1

    move-object/from16 v3, p2

    move-object/from16 v4, p3

    move-object/from16 v5, p4

    move-object/from16 v6, p5

    move-object/from16 v7, p6

    move-object/from16 v8, p7

    move-object/from16 v9, p8

    move-object/from16 v10, p9

    move-object/from16 v11, p10

    move-object/from16 v12, p11

    move-object/from16 v13, p12

    move-object/from16 v14, p13

    move-object/from16 v15, p14

    move-object/from16 v16, p15

    invoke-static/range {v0 .. v16}, Lcom/esmertec/android/jbed/jsr/JbedContact;->store(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;[I[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[I[Ljava/lang/String;[B)J

    move-result-wide p0

    .line 133
    .end local p1    # "name":Ljava/lang/String;
    .local p0, "newId":J
    invoke-static/range {p0 .. p1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->convertIdToBytes(J)[B

    move-result-object p0

    .end local p0    # "newId":J
    return-object p0
.end method

.method static storeEvent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IJJ[IIIIJ)[B
    .locals 19
    .param p0, "id"    # Ljava/lang/String;
    .param p1, "title"    # Ljava/lang/String;
    .param p2, "description"    # Ljava/lang/String;
    .param p3, "location"    # Ljava/lang/String;
    .param p4, "eventClass"    # I
    .param p5, "dtstart"    # J
    .param p7, "dtend"    # J
    .param p9, "alarms"    # [I
    .param p10, "repeat_frequence"    # I
    .param p11, "repeat_interval"    # I
    .param p12, "repeat_count"    # I
    .param p13, "repeat_end"    # J

    .prologue
    .line 145
    sget-object v3, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v3, v3, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    move-object/from16 v4, p0

    move-object/from16 v5, p1

    move-object/from16 v6, p2

    move-object/from16 v7, p3

    move/from16 v8, p4

    move-wide/from16 v9, p5

    move-wide/from16 v11, p7

    move-object/from16 v13, p9

    move/from16 v14, p10

    move/from16 v15, p11

    move/from16 v16, p12

    move-wide/from16 v17, p13

    invoke-static/range {v3 .. v18}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->store(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IJJ[IIIIJ)J

    move-result-wide p0

    .line 148
    .end local p1    # "title":Ljava/lang/String;
    .local p0, "newId":J
    const-string p2, "JbedPimManager"

    .end local p2    # "description":Ljava/lang/String;
    const/16 p3, 0x3

    invoke-static/range {p2 .. p3}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    .end local p3    # "location":Ljava/lang/String;
    move-result p2

    if-eqz p2, :cond_0

    const-string p2, "JbedPimManager"

    new-instance p3, Ljava/lang/StringBuilder;

    invoke-direct/range {p3 .. p3}, Ljava/lang/StringBuilder;-><init>()V

    const-string p4, " storeEvent new Id="

    .end local p4    # "eventClass":I
    invoke-virtual/range {p3 .. p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p3

    move-object/from16 v0, p3

    move-wide/from16 v1, p0

    invoke-virtual {v0, v1, v2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object p3

    invoke-virtual/range {p3 .. p3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p3

    invoke-static/range {p2 .. p3}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 149
    :cond_0
    invoke-static/range {p0 .. p1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->convertIdToBytes(J)[B

    move-result-object p0

    .end local p0    # "newId":J
    return-object p0
.end method

.method static storeTodo(Ljava/lang/String;Ljava/lang/String;Z)[B
    .locals 3
    .param p0, "id"    # Ljava/lang/String;
    .param p1, "summary"    # Ljava/lang/String;
    .param p2, "isCompleted"    # Z

    .prologue
    .line 137
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    iget-object v2, v2, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    invoke-static {v2, p0, p1, p2}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->store(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Z)J

    move-result-wide v0

    .line 138
    .local v0, "newId":J
    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->convertIdToBytes(J)[B

    move-result-object v2

    return-object v2
.end method


# virtual methods
.method public onCreate(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 49
    invoke-virtual {p1}, Landroid/content/Context;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->mResolver:Landroid/content/ContentResolver;

    .line 50
    return-void
.end method

.method public onDestroy(Landroid/content/Context;)V
    .locals 1
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 53
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->INSTANCE:Lcom/esmertec/android/jbed/jsr/JbedPimManager;

    .line 54
    return-void
.end method
