.class public Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;
.super Ljava/lang/Object;
.source "JbedCalendarTodo.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;
    }
.end annotation


# static fields
.field private static final NEW_LINE:Ljava/lang/String; = "\r\n"

.field static final TAG:Ljava/lang/String; = "JbedPIMTodo"


# instance fields
.field private mResolver:Landroid/content/ContentResolver;


# direct methods
.method public constructor <init>(Landroid/content/ContentResolver;)V
    .locals 0
    .param p1, "resolver"    # Landroid/content/ContentResolver;

    .prologue
    .line 25
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 26
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->mResolver:Landroid/content/ContentResolver;

    .line 27
    return-void
.end method

.method public static isSupported(Landroid/content/ContentResolver;)Z
    .locals 11
    .param p0, "resolver"    # Landroid/content/ContentResolver;

    .prologue
    const-string v10, "JbedPIMTodo"

    .line 84
    const/4 v8, 0x0

    .line 85
    .local v8, "result":Z
    new-instance v9, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;

    invoke-direct {v9, p0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;-><init>(Landroid/content/ContentResolver;)V

    .line 86
    .local v9, "todo":Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;
    const/4 v6, 0x0

    .line 88
    .local v6, "cursor":Landroid/database/Cursor;
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    const/4 v2, 0x0

    const-string v3, "_id>-1"

    const/4 v4, 0x0

    const-string v5, "_id"

    move-object v0, p0

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    move-result-object v6

    .line 92
    :cond_0
    :goto_0
    if-eqz v6, :cond_1

    .line 93
    const/4 v8, 0x1

    .line 94
    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 97
    :cond_1
    return v8

    .line 89
    :catch_0
    move-exception v0

    move-object v7, v0

    .line 90
    .local v7, "e":Ljava/lang/Exception;
    const-string v0, "JbedPIMTodo"

    const/4 v0, 0x5

    invoke-static {v10, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "JbedPIMTodo"

    const-string v0, "WARNING: isSupported exception"

    invoke-static {v10, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method

.method private loadOneTask(Landroid/database/Cursor;)Ljava/lang/String;
    .locals 9
    .param p1, "cursor"    # Landroid/database/Cursor;

    .prologue
    const-string v8, "\r\n"

    .line 48
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    .line 49
    .local v5, "vcalendar":Ljava/lang/StringBuilder;
    const-string v6, "BEGIN:VCALENDAR"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 50
    const-string v6, "VERSION:1.0"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 51
    const-string v6, "BEGIN:VTODO"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 53
    const-string v6, "_id"

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v6

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v2

    .line 54
    .local v2, "id":J
    const-string v6, "UID:"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 56
    const-string v6, "title"

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v6

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v4

    .line 57
    .local v4, "title":Ljava/lang/String;
    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v6

    if-nez v6, :cond_0

    .line 58
    const-string v6, "SUMMARY:"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 61
    :cond_0
    const-string v6, "alarm"

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v6

    invoke-interface {p1, v6}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    .line 62
    .local v0, "alarm":I
    const-string v1, "FALSE"

    .line 63
    .local v1, "alarmStr":Ljava/lang/String;
    const/4 v6, 0x2

    if-ne v0, v6, :cond_1

    const-string v1, "COMPLETED"

    .line 64
    :cond_1
    const-string v6, "STATUS:"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 65
    const-string v6, "END:VTODO"

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "\r\n"

    invoke-virtual {v6, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    const-string v7, "END:VCALENDAR"

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 66
    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    return-object v6
.end method

.method private save(JLandroid/content/ContentValues;)J
    .locals 4
    .param p1, "id"    # J
    .param p3, "values"    # Landroid/content/ContentValues;

    .prologue
    const/4 v3, 0x0

    .line 118
    const-wide/16 v1, 0x0

    cmp-long v1, p1, v1

    if-nez v1, :cond_0

    .line 119
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->mResolver:Landroid/content/ContentResolver;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v1, v2, p3}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object v0

    .line 120
    .local v0, "uri":Landroid/net/Uri;
    invoke-static {v0}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide p1

    .line 125
    :goto_0
    return-wide p1

    .line 122
    .end local v0    # "uri":Landroid/net/Uri;
    :cond_0
    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    invoke-static {v1, p1, p2}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v0

    .line 123
    .restart local v0    # "uri":Landroid/net/Uri;
    iget-object v1, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->mResolver:Landroid/content/ContentResolver;

    invoke-virtual {v1, v0, p3, v3, v3}, Landroid/content/ContentResolver;->update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I

    goto :goto_0
.end method

.method public static store(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Z)J
    .locals 6
    .param p0, "resolver"    # Landroid/content/ContentResolver;
    .param p1, "idStr"    # Ljava/lang/String;
    .param p2, "title"    # Ljava/lang/String;
    .param p3, "isCompleted"    # Z

    .prologue
    .line 102
    const-wide/16 v0, 0x0

    .line 104
    .local v0, "id":J
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_0

    .line 105
    invoke-static {p1}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v0

    .line 107
    :cond_0
    new-instance v3, Landroid/content/ContentValues;

    invoke-direct {v3}, Landroid/content/ContentValues;-><init>()V

    .line 108
    .local v3, "values":Landroid/content/ContentValues;
    const-string v4, "title"

    invoke-virtual {v3, v4, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 110
    const-string v4, "alarm"

    if-eqz p3, :cond_1

    const/4 v5, 0x2

    :goto_0
    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v5

    invoke-virtual {v3, v4, v5}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 112
    new-instance v2, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;

    invoke-direct {v2, p0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;-><init>(Landroid/content/ContentResolver;)V

    .line 113
    .local v2, "todo":Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;
    invoke-direct {v2, v0, v1, v3}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->save(JLandroid/content/ContentValues;)J

    move-result-wide v4

    return-wide v4

    .line 110
    .end local v2    # "todo":Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;
    :cond_1
    const/4 v5, 0x0

    goto :goto_0
.end method


# virtual methods
.method public getNext(Ljava/lang/String;)Ljava/lang/String;
    .locals 8
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    const/4 v2, 0x0

    const-string v3, "JbedPIMTodo"

    .line 30
    const-string v0, "JbedPIMTodo"

    const/4 v0, 0x3

    invoke-static {v3, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "JbedPIMTodo"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "getNext id ="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v3, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 32
    :cond_0
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 33
    const-string p1, "-1"

    .line 35
    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->mResolver:Landroid/content/ContentResolver;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "_id>"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v5, "_id"

    move-object v4, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 36
    .local v6, "cursor":Landroid/database/Cursor;
    const/4 v7, 0x0

    .line 38
    .local v7, "result":Ljava/lang/String;
    if-eqz v6, :cond_2

    :try_start_0
    invoke-interface {v6}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 39
    invoke-direct {p0, v6}, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->loadOneTask(Landroid/database/Cursor;)Ljava/lang/String;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v7

    .line 42
    :cond_2
    if-eqz v6, :cond_3

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 44
    :cond_3
    return-object v7

    .line 42
    :catchall_0
    move-exception v0

    if-eqz v6, :cond_4

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_4
    throw v0
.end method

.method public remove(Ljava/lang/String;)I
    .locals 7
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    const/4 v6, 0x0

    const-string v5, "JbedPIMTodo"

    .line 70
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 71
    const-string v2, "JbedPIMTodo"

    const/4 v2, 0x6

    invoke-static {v5, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "JbedPIMTodo"

    const-string v2, " the id is empty! can\'t delete"

    invoke-static {v5, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 72
    :cond_0
    const/4 v2, -0x1

    .line 80
    :goto_0
    return v2

    .line 74
    :cond_1
    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    invoke-static {p1}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v3

    invoke-static {v2, v3, v4}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v1

    .line 75
    .local v1, "uri":Landroid/net/Uri;
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;->mResolver:Landroid/content/ContentResolver;

    invoke-virtual {v2, v1, v6, v6}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I

    move-result v0

    .line 76
    .local v0, "count":I
    if-nez v0, :cond_2

    .line 77
    const-string v2, "JbedPIMTodo"

    const/4 v2, 0x5

    invoke-static {v5, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_2

    const-string v2, "JbedPIMTodo"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "WARNING: failed to delete todo id "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v5, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 80
    :cond_2
    const/4 v2, 0x0

    goto :goto_0
.end method
