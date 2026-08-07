.class public Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;
.super Ljava/lang/Object;
.source "JbedCalendarEvent.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedPimManager$PimAction;


# static fields
.field private static final JBED_CALENDAR_NAME:Ljava/lang/String; = "jbed"

.field static final JBED_CLASS_CONFIDENTIAL:I = 0xc8

.field static final JBED_CLASS_NONE:I = 0x0

.field static final JBED_CLASS_PRIVATE:I = 0xc9

.field static final JBED_CLASS_PUBLIC:I = 0xca

.field private static final MAX_SUPPORT_REMINDER:I = 0xa

.field private static final NEW_LINE:Ljava/lang/String; = "\r\n"

.field static final REPEAT_RULE_DAILY:I = 0x10

.field static final REPEAT_RULE_MONTHLY:I = 0x12

.field static final REPEAT_RULE_WEEKLY:I = 0x11

.field static final REPEAT_RULE_YEARLY:I = 0x13

.field private static final TAG:Ljava/lang/String; = "JbedPIMEvent"

.field private static calendarId:J

.field private static final jbedClassTypeMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field private mDescription:Ljava/lang/String;

.field private mDtend:Ljava/lang/String;

.field private mDtstart:Ljava/lang/String;

.field private mHasAlarm:Z

.field private mId:J

.field private mLocation:Ljava/lang/String;

.field private mResolver:Landroid/content/ContentResolver;

.field private mRrule:Ljava/lang/String;

.field private mTitle:Ljava/lang/String;

.field private mVisibility:Ljava/lang/String;

.field private reminderList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 49
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    .line 54
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    const/16 v1, 0xc8

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, 0x1

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 55
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    const/16 v1, 0xc9

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, 0x2

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 56
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    const/16 v1, 0xca

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/4 v2, 0x3

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 57
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 82
    const-wide/16 v0, -0x1

    sput-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    return-void
.end method

.method public constructor <init>(Landroid/content/ContentResolver;)V
    .locals 1
    .param p1, "resolver"    # Landroid/content/ContentResolver;

    .prologue
    .line 87
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 84
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->reminderList:Ljava/util/List;

    .line 88
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    .line 89
    return-void
.end method

.method private static buildRRuleToRfc2445Recurrence(IIIJ)Ljava/lang/String;
    .locals 3
    .param p0, "repeatFrequence"    # I
    .param p1, "repeatInterval"    # I
    .param p2, "repeatCount"    # I
    .param p3, "repeatEnd"    # J

    .prologue
    .line 306
    const-string v0, "FREQ="

    .line 307
    .local v0, "result":Ljava/lang/String;
    packed-switch p0, :pswitch_data_0

    .line 321
    const/4 v1, 0x0

    .line 335
    :goto_0
    return-object v1

    .line 309
    :pswitch_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "DAILY"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 323
    :goto_1
    if-lez p1, :cond_2

    .line 324
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ";INTERVAL="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 329
    :goto_2
    const-wide/16 v1, 0x0

    cmp-long v1, p3, v1

    if-lez v1, :cond_0

    .line 330
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ";UNTIL="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-static {p3, p4}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->convertLongToRFC2445DateTime(J)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 332
    :cond_0
    if-lez p2, :cond_1

    .line 333
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ";COUNT="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1, p2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    :cond_1
    move-object v1, v0

    .line 335
    goto :goto_0

    .line 312
    :pswitch_1
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "WEEKLY"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 313
    goto :goto_1

    .line 315
    :pswitch_2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "MONTHLY"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 316
    goto :goto_1

    .line 318
    :pswitch_3
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "YEARLY"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 319
    goto/16 :goto_1

    .line 327
    :cond_2
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ";INTERVAL=1"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    goto/16 :goto_2

    .line 307
    nop

    :pswitch_data_0
    .packed-switch 0x10
        :pswitch_0
        :pswitch_1
        :pswitch_2
        :pswitch_3
    .end packed-switch
.end method

.method static convertLongToRFC2445DateTime(J)Ljava/lang/String;
    .locals 2
    .param p0, "mills"    # J

    .prologue
    .line 134
    new-instance v0, Landroid/text/format/Time;

    invoke-direct {v0}, Landroid/text/format/Time;-><init>()V

    .line 135
    .local v0, "time":Landroid/text/format/Time;
    invoke-virtual {v0, p0, p1}, Landroid/text/format/Time;->set(J)V

    .line 136
    invoke-virtual {v0}, Landroid/text/format/Time;->format2445()Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method private foldingString(Ljava/lang/String;)Ljava/lang/String;
    .locals 3
    .param p1, "str"    # Ljava/lang/String;

    .prologue
    const-string v2, "\n"

    .line 243
    const-string v0, "\r\n"

    const-string v1, "\n"

    invoke-virtual {p1, v0, v2}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "\n"

    const-string v1, "\r\n "

    invoke-virtual {v0, v2, v1}, Ljava/lang/String;->replaceAll(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method static getJbedCalendarId(Landroid/content/ContentResolver;)J
    .locals 9
    .param p0, "resolver"    # Landroid/content/ContentResolver;

    .prologue
    const/4 v2, 0x0

    const-string v0, "JbedPIMEvent"

    .line 431
    sget-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    const-wide/16 v3, -0x1

    cmp-long v0, v0, v3

    if-eqz v0, :cond_0

    .line 432
    sget-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    .line 452
    :goto_0
    return-wide v0

    .line 434
    :cond_0
    sget-object v1, Landroid/provider/Calendar$Calendars;->CONTENT_URI:Landroid/net/Uri;

    const-string v3, "name=\'jbed\'"

    move-object v0, p0

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v7

    .line 437
    .local v7, "cursor":Landroid/database/Cursor;
    if-eqz v7, :cond_3

    :try_start_0
    invoke-interface {v7}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v0

    if-eqz v0, :cond_3

    .line 438
    const-string v0, "_id"

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v7, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    sput-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    .line 439
    const-string v0, "JbedPIMEvent"

    const/4 v1, 0x3

    invoke-static {v0, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "JbedPIMEvent"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "jbed calendar has existed! calendarId="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-wide v2, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 450
    :cond_1
    :goto_1
    if-eqz v7, :cond_2

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    .line 452
    :cond_2
    sget-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    goto :goto_0

    .line 442
    :cond_3
    :try_start_1
    new-instance v6, Landroid/content/ContentValues;

    invoke-direct {v6}, Landroid/content/ContentValues;-><init>()V

    .line 443
    .local v6, "c":Landroid/content/ContentValues;
    const-string v0, "name"

    const-string v1, "jbed"

    invoke-virtual {v6, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 444
    const-string v0, "hidden"

    const/4 v1, 0x0

    invoke-static {v1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v1

    invoke-virtual {v6, v0, v1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Boolean;)V

    .line 445
    sget-object v0, Landroid/provider/Calendar$Calendars;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {p0, v0, v6}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object v8

    .line 446
    .local v8, "uri":Landroid/net/Uri;
    invoke-static {v8}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide v0

    sput-wide v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    .line 447
    const-string v0, "JbedPIMEvent"

    const/4 v1, 0x3

    invoke-static {v0, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_1

    const-string v0, "JbedPIMEvent"

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "create a jbed calendar id="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-wide v2, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->calendarId:J

    invoke-virtual {v1, v2, v3}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    goto :goto_1

    .line 450
    .end local v6    # "c":Landroid/content/ContentValues;
    .end local v8    # "uri":Landroid/net/Uri;
    :catchall_0
    move-exception v0

    if-eqz v7, :cond_4

    invoke-interface {v7}, Landroid/database/Cursor;->close()V

    :cond_4
    throw v0
.end method

.method private loadOneEvent(Landroid/database/Cursor;)V
    .locals 4
    .param p1, "c"    # Landroid/database/Cursor;

    .prologue
    const-string v3, "dtstart"

    .line 116
    const-string v0, "_id"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mId:J

    .line 117
    const-string v0, "title"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mTitle:Ljava/lang/String;

    .line 118
    const-string v0, "dtend"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->convertLongToRFC2445DateTime(J)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtend:Ljava/lang/String;

    .line 119
    const-string v0, "dtstart"

    invoke-interface {p1, v3}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v0

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->convertLongToRFC2445DateTime(J)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtstart:Ljava/lang/String;

    .line 120
    const-string v0, "eventLocation"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mLocation:Ljava/lang/String;

    .line 121
    const-string v0, "hasAlarm"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v0

    if-eqz v0, :cond_2

    const/4 v0, 0x1

    :goto_0
    iput-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mHasAlarm:Z

    .line 122
    const-string v0, "description"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDescription:Ljava/lang/String;

    .line 123
    const-string v0, "visibility"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mVisibility:Ljava/lang/String;

    .line 125
    const-string v0, "rrule"

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {p1, v0}, Landroid/database/Cursor;->getString(I)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    .line 126
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v0

    if-nez v0, :cond_0

    .line 127
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->convertRfc2445RecurrenceToRRule(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    .line 129
    :cond_0
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mHasAlarm:Z

    if-eqz v0, :cond_1

    .line 130
    iget-wide v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mId:J

    const-string v2, "dtstart"

    invoke-interface {p1, v3}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v2

    invoke-interface {p1, v2}, Landroid/database/Cursor;->getLong(I)J

    move-result-wide v2

    invoke-direct {p0, v0, v1, v2, v3}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->loadReminders(JJ)V

    .line 131
    :cond_1
    return-void

    .line 121
    :cond_2
    const/4 v0, 0x0

    goto :goto_0
.end method

.method private loadReminders(JJ)V
    .locals 11
    .param p1, "eventId"    # J
    .param p3, "startTime"    # J

    .prologue
    const/4 v2, 0x0

    .line 144
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    sget-object v1, Landroid/provider/Calendar$Reminders;->CONTENT_URI:Landroid/net/Uri;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "event_id="

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3, p1, p2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    move-object v4, v2

    move-object v5, v2

    invoke-virtual/range {v0 .. v5}, Landroid/content/ContentResolver;->query(Landroid/net/Uri;[Ljava/lang/String;Ljava/lang/String;[Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v6

    .line 147
    .local v6, "cursor":Landroid/database/Cursor;
    :try_start_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->reminderList:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V

    .line 148
    const/4 v7, 0x0

    .line 149
    .local v7, "i":I
    :goto_0
    if-eqz v6, :cond_1

    invoke-interface {v6}, Landroid/database/Cursor;->moveToNext()Z

    move-result v0

    if-eqz v0, :cond_1

    const/16 v0, 0xa

    if-ge v7, v0, :cond_1

    .line 150
    const-string v0, "minutes"

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getColumnIndexOrThrow(Ljava/lang/String;)I

    move-result v0

    invoke-interface {v6, v0}, Landroid/database/Cursor;->getInt(I)I

    move-result v8

    .line 153
    .local v8, "minutes":I
    const/4 v0, -0x1

    if-ne v8, v0, :cond_0

    .line 154
    const/16 v8, 0x5a0

    .line 156
    :cond_0
    mul-int/lit8 v0, v8, 0x3c

    mul-int/lit16 v0, v0, 0x3e8

    int-to-long v0, v0

    sub-long v9, p3, v0

    .line 157
    .local v9, "remindTime":J
    iget-object v0, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->reminderList:Ljava/util/List;

    invoke-static {v9, v10}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->convertLongToRFC2445DateTime(J)Ljava/lang/String;

    move-result-object v1

    invoke-interface {v0, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 158
    add-int/lit8 v7, v7, 0x1

    .line 159
    goto :goto_0

    .line 161
    .end local v8    # "minutes":I
    .end local v9    # "remindTime":J
    :cond_1
    if-eqz v6, :cond_2

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    .line 163
    :cond_2
    return-void

    .line 161
    .end local v7    # "i":I
    :catchall_0
    move-exception v0

    if-eqz v6, :cond_3

    invoke-interface {v6}, Landroid/database/Cursor;->close()V

    :cond_3
    throw v0
.end method

.method private save(JLandroid/content/ContentValues;Ljava/util/List;)J
    .locals 8
    .param p1, "id"    # J
    .param p3, "eventValues"    # Landroid/content/ContentValues;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(J",
            "Landroid/content/ContentValues;",
            "Ljava/util/List",
            "<",
            "Landroid/content/ContentValues;",
            ">;)J"
        }
    .end annotation

    .prologue
    .local p4, "remindValues":Ljava/util/List;, "Ljava/util/List<Landroid/content/ContentValues;>;"
    const/4 v7, 0x0

    .line 406
    const-wide/16 v3, 0x0

    cmp-long v3, p1, v3

    if-nez v3, :cond_0

    .line 408
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    sget-object v4, Landroid/provider/Calendar$Events;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v3, v4, p3}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    move-result-object v1

    .line 409
    .local v1, "uri":Landroid/net/Uri;
    invoke-static {v1}, Landroid/content/ContentUris;->parseId(Landroid/net/Uri;)J

    move-result-wide p1

    .line 419
    :goto_0
    invoke-interface {p4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_1

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Landroid/content/ContentValues;

    .line 422
    .local v2, "v":Landroid/content/ContentValues;
    const-string v3, "event_id"

    invoke-static {p1, p2}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v4

    invoke-virtual {v2, v3, v4}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 423
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    sget-object v4, Landroid/provider/Calendar$Reminders;->CONTENT_URI:Landroid/net/Uri;

    invoke-virtual {v3, v4, v2}, Landroid/content/ContentResolver;->insert(Landroid/net/Uri;Landroid/content/ContentValues;)Landroid/net/Uri;

    goto :goto_1

    .line 411
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "uri":Landroid/net/Uri;
    .end local v2    # "v":Landroid/content/ContentValues;
    :cond_0
    sget-object v3, Landroid/provider/Calendar$Events;->CONTENT_URI:Landroid/net/Uri;

    invoke-static {v3, p1, p2}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v1

    .line 413
    .restart local v1    # "uri":Landroid/net/Uri;
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    invoke-virtual {v3, v1, p3, v7, v7}, Landroid/content/ContentResolver;->update(Landroid/net/Uri;Landroid/content/ContentValues;Ljava/lang/String;[Ljava/lang/String;)I

    .line 416
    iget-object v3, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    sget-object v4, Landroid/provider/Calendar$Reminders;->CONTENT_URI:Landroid/net/Uri;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "event_id="

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, p1, p2}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-static {v3, v4, v7, v5}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->removeByUri(Landroid/content/ContentResolver;Landroid/net/Uri;Landroid/net/Uri;Ljava/lang/String;)V

    goto :goto_0

    .line 425
    .restart local v0    # "i$":Ljava/util/Iterator;
    :cond_1
    return-wide p1
.end method

.method public static store(Landroid/content/ContentResolver;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IJJ[IIIIJ)J
    .locals 7
    .param p0, "resolver"    # Landroid/content/ContentResolver;
    .param p1, "idStr"    # Ljava/lang/String;
    .param p2, "title"    # Ljava/lang/String;
    .param p3, "description"    # Ljava/lang/String;
    .param p4, "location"    # Ljava/lang/String;
    .param p5, "eventClass"    # I
    .param p6, "dtstart"    # J
    .param p8, "dtend"    # J
    .param p10, "alarms"    # [I
    .param p11, "repeatFrequence"    # I
    .param p12, "repeatInterval"    # I
    .param p13, "repeatCount"    # I
    .param p14, "repeatEnd"    # J

    .prologue
    .line 266
    const-wide/16 v2, 0x0

    .line 268
    .local v2, "id":J
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_4

    .line 269
    invoke-static {p1}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v2

    move-wide v3, v2

    .line 271
    .end local v2    # "id":J
    .local v3, "id":J
    :goto_0
    new-instance v2, Landroid/content/ContentValues;

    invoke-direct {v2}, Landroid/content/ContentValues;-><init>()V

    .line 274
    .local v2, "eventValues":Landroid/content/ContentValues;
    const-string p1, "calendar_id"

    .end local p1    # "idStr":Ljava/lang/String;
    invoke-static {p0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->getJbedCalendarId(Landroid/content/ContentResolver;)J

    move-result-wide v5

    invoke-static {v5, v6}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v5

    invoke-virtual {v2, p1, v5}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 275
    const-string p1, "title"

    invoke-virtual {v2, p1, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 276
    const-string p1, "description"

    invoke-virtual {v2, p1, p3}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 277
    const-string p1, "eventLocation"

    invoke-virtual {v2, p1, p4}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 278
    const-string p1, "dtstart"

    invoke-static {p6, p7}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p6

    .end local p6    # "dtstart":J
    invoke-virtual {v2, p1, p6}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 279
    const-string p1, "dtend"

    invoke-static/range {p8 .. p9}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object p6

    invoke-virtual {v2, p1, p6}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Long;)V

    .line 280
    const-string p6, "visibility"

    sget-object p1, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    invoke-static {p5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p7

    invoke-virtual {p1, p7}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p1

    check-cast p1, Ljava/lang/Integer;

    invoke-virtual {v2, p6, p1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 281
    invoke-static/range {p11 .. p15}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->buildRRuleToRfc2445Recurrence(IIIJ)Ljava/lang/String;

    move-result-object p1

    .line 282
    .local p1, "rrule":Ljava/lang/String;
    const-string p6, "rrule"

    invoke-virtual {v2, p6, p1}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/String;)V

    .line 283
    const-string p1, "JbedPIMEvent"

    .end local p1    # "rrule":Ljava/lang/String;
    const/4 p6, 0x3

    invoke-static {p1, p6}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result p1

    if-eqz p1, :cond_0

    const-string p1, "JbedPIMEvent"

    new-instance p6, Ljava/lang/StringBuilder;

    invoke-direct {p6}, Ljava/lang/StringBuilder;-><init>()V

    const-string p7, "[Events]title="

    invoke-virtual {p6, p7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p6

    invoke-virtual {p6, p2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    .end local p2    # "title":Ljava/lang/String;
    const-string p6, " DESCRIPTION="

    invoke-virtual {p2, p6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " EVENT_LOCATION="

    .end local p3    # "description":Ljava/lang/String;
    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2, p4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, "\n"

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, "VISIBILITY="

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    sget-object p3, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->jbedClassTypeMap:Ljava/util/HashMap;

    invoke-static {p5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p4

    .end local p4    # "location":Ljava/lang/String;
    invoke-virtual {p3, p4}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object p3

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    move-object v0, p2

    move/from16 v1, p11

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    move-object v0, p2

    move/from16 v1, p12

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p2

    const-string p3, " "

    invoke-virtual {p2, p3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object p2

    move-object v0, p2

    move/from16 v1, p13

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object p2

    invoke-virtual {p2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p2

    invoke-static {p1, p2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 287
    :cond_0
    new-instance p4, Ljava/util/ArrayList;

    invoke-direct {p4}, Ljava/util/ArrayList;-><init>()V

    .line 288
    .local p4, "reminderValues":Ljava/util/List;, "Ljava/util/List<Landroid/content/ContentValues;>;"
    const/4 p1, 0x0

    .end local p5    # "eventClass":I
    .local p1, "i":I
    :goto_1
    move-object/from16 v0, p10

    array-length v0, v0

    move p2, v0

    if-ge p1, p2, :cond_2

    .line 289
    aget p2, p10, p1

    if-gtz p2, :cond_1

    .line 288
    :goto_2
    add-int/lit8 p1, p1, 0x1

    goto :goto_1

    .line 292
    :cond_1
    aget p2, p10, p1

    div-int/lit8 p2, p2, 0x3c

    .line 293
    .local p2, "minutes":I
    new-instance p3, Landroid/content/ContentValues;

    invoke-direct {p3}, Landroid/content/ContentValues;-><init>()V

    .line 294
    .local p3, "reminder":Landroid/content/ContentValues;
    const-string p5, "method"

    const/4 p6, 0x0

    invoke-static {p6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p6

    invoke-virtual {p3, p5, p6}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 295
    const-string p5, "minutes"

    invoke-static {p2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object p2

    .end local p2    # "minutes":I
    invoke-virtual {p3, p5, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Integer;)V

    .line 296
    invoke-interface {p4, p3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_2

    .line 298
    .end local p3    # "reminder":Landroid/content/ContentValues;
    :cond_2
    const-string p1, "hasAlarm"

    .end local p1    # "i":I
    invoke-interface {p4}, Ljava/util/List;->size()I

    move-result p2

    if-lez p2, :cond_3

    const/4 p2, 0x1

    :goto_3
    invoke-static {p2}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object p2

    invoke-virtual {v2, p1, p2}, Landroid/content/ContentValues;->put(Ljava/lang/String;Ljava/lang/Boolean;)V

    .line 300
    new-instance p1, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;

    invoke-direct {p1, p0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;-><init>(Landroid/content/ContentResolver;)V

    .line 301
    .local p1, "event":Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;
    invoke-direct {p1, v3, v4, v2, p4}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->save(JLandroid/content/ContentValues;Ljava/util/List;)J

    move-result-wide p0

    .end local p0    # "resolver":Landroid/content/ContentResolver;
    return-wide p0

    .line 298
    .end local p1    # "event":Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;
    .restart local p0    # "resolver":Landroid/content/ContentResolver;
    :cond_3
    const/4 p2, 0x0

    goto :goto_3

    .end local v3    # "id":J
    .local v2, "id":J
    .local p1, "idStr":Ljava/lang/String;
    .local p2, "title":Ljava/lang/String;
    .local p3, "description":Ljava/lang/String;
    .local p4, "location":Ljava/lang/String;
    .restart local p5    # "eventClass":I
    .restart local p6    # "dtstart":J
    :cond_4
    move-wide v3, v2

    .end local v2    # "id":J
    .restart local v3    # "id":J
    goto/16 :goto_0
.end method


# virtual methods
.method convertRfc2445RecurrenceToRRule(Ljava/lang/String;)Ljava/lang/String;
    .locals 4
    .param p1, "rfc2445Recurrence"    # Ljava/lang/String;

    .prologue
    .line 371
    new-instance v0, Landroid/pim/EventRecurrence;

    invoke-direct {v0}, Landroid/pim/EventRecurrence;-><init>()V

    .line 372
    .local v0, "eventRecurrence":Landroid/pim/EventRecurrence;
    invoke-virtual {v0, p1}, Landroid/pim/EventRecurrence;->parse(Ljava/lang/String;)V

    .line 373
    const-string v1, ""

    .line 374
    .local v1, "result":Ljava/lang/String;
    iget v2, v0, Landroid/pim/EventRecurrence;->freq:I

    packed-switch v2, :pswitch_data_0

    .line 388
    const-string v2, ""

    .line 402
    :goto_0
    return-object v2

    .line 376
    :pswitch_0
    const-string v1, "D"

    .line 390
    :goto_1
    iget v2, v0, Landroid/pim/EventRecurrence;->interval:I

    if-lez v2, :cond_2

    .line 391
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, v0, Landroid/pim/EventRecurrence;->interval:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 396
    :goto_2
    iget-object v2, v0, Landroid/pim/EventRecurrence;->until:Ljava/lang/String;

    invoke-static {v2}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    if-nez v2, :cond_0

    .line 397
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget-object v3, v0, Landroid/pim/EventRecurrence;->until:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 399
    :cond_0
    iget v2, v0, Landroid/pim/EventRecurrence;->count:I

    if-lez v2, :cond_1

    .line 400
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, " #"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, v0, Landroid/pim/EventRecurrence;->count:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    :cond_1
    move-object v2, v1

    .line 402
    goto :goto_0

    .line 379
    :pswitch_1
    const-string v1, "W"

    .line 380
    goto :goto_1

    .line 382
    :pswitch_2
    const-string v1, "MP"

    .line 383
    goto :goto_1

    .line 385
    :pswitch_3
    const-string v1, "YM"

    .line 386
    goto :goto_1

    .line 394
    :cond_2
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v2, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "1"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    goto :goto_2

    .line 374
    :pswitch_data_0
    .packed-switch 0x4
        :pswitch_0
        :pswitch_1
        :pswitch_2
        :pswitch_3
    .end packed-switch
.end method

.method public getNext(Ljava/lang/String;)Ljava/lang/String;
    .locals 6
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    const-string v4, "JbedPIMEvent"

    .line 92
    const-string v2, "JbedPIMEvent"

    const/4 v2, 0x3

    invoke-static {v4, v2}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v2

    if-eqz v2, :cond_0

    const-string v2, "JbedPIMEvent"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "getNext id ="

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v4, v2}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 93
    :cond_0
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    if-eqz v2, :cond_1

    .line 94
    const-string p1, "-1"

    .line 99
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    const/4 v3, 0x0

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "_id>"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    const-string v5, "_id"

    invoke-static {v2, v3, v4, v5}, Landroid/provider/Calendar$Events;->query(Landroid/content/ContentResolver;[Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Landroid/database/Cursor;

    move-result-object v0

    .line 101
    .local v0, "cursor":Landroid/database/Cursor;
    const/4 v1, 0x0

    .line 103
    .local v1, "result":Ljava/lang/String;
    if-eqz v0, :cond_2

    :try_start_0
    invoke-interface {v0}, Landroid/database/Cursor;->moveToFirst()Z

    move-result v2

    if-eqz v2, :cond_2

    .line 104
    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->loadOneEvent(Landroid/database/Cursor;)V

    .line 105
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->toVCal()Ljava/lang/String;
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move-result-object v1

    .line 108
    :cond_2
    if-eqz v0, :cond_3

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    .line 110
    :cond_3
    return-object v1

    .line 108
    :catchall_0
    move-exception v2

    if-eqz v0, :cond_4

    invoke-interface {v0}, Landroid/database/Cursor;->close()V

    :cond_4
    throw v2
.end method

.method public remove(Ljava/lang/String;)I
    .locals 7
    .param p1, "id"    # Ljava/lang/String;

    .prologue
    const/4 v6, 0x0

    const-string v5, "JbedPIMEvent"

    .line 247
    invoke-static {p1}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v2

    if-eqz v2, :cond_0

    .line 248
    const-string v2, "JbedPIMEvent"

    const-string v2, " the id is empty! can\'t delete"

    invoke-static {v5, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 249
    const/4 v2, -0x1

    .line 259
    :goto_0
    return v2

    .line 251
    :cond_0
    sget-object v2, Landroid/provider/Calendar$Events;->CONTENT_URI:Landroid/net/Uri;

    invoke-static {p1}, Ljava/lang/Long;->parseLong(Ljava/lang/String;)J

    move-result-wide v3

    invoke-static {v2, v3, v4}, Landroid/content/ContentUris;->withAppendedId(Landroid/net/Uri;J)Landroid/net/Uri;

    move-result-object v0

    .line 253
    .local v0, "contentURI":Landroid/net/Uri;
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    invoke-virtual {v2, v0, v6, v6}, Landroid/content/ContentResolver;->delete(Landroid/net/Uri;Ljava/lang/String;[Ljava/lang/String;)I

    move-result v1

    .line 254
    .local v1, "count":I
    if-nez v1, :cond_1

    .line 255
    const-string v2, "JbedPIMEvent"

    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    const-string v3, "WARNING: failed to delete event id "

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v2

    invoke-static {v5, v2}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;)I

    .line 257
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mResolver:Landroid/content/ContentResolver;

    sget-object v3, Landroid/provider/Calendar$Reminders;->CONTENT_URI:Landroid/net/Uri;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "event_id="

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v2, v3, v6, v4}, Lcom/esmertec/android/jbed/jsr/JbedPimManager;->removeByUri(Landroid/content/ContentResolver;Landroid/net/Uri;Landroid/net/Uri;Ljava/lang/String;)V

    .line 259
    const/4 v2, 0x0

    goto :goto_0
.end method

.method public toVCal()Ljava/lang/String;
    .locals 8

    .prologue
    const-string v7, "\r\n"

    .line 178
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    .line 181
    .local v2, "sb":Ljava/lang/StringBuilder;
    const-string v4, "BEGIN:VCALENDAR"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 182
    const-string v4, "VERSION:1.0"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 184
    const-string v4, "BEGIN:VEVENT"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 186
    const-string v4, "UID:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-wide v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mId:J

    invoke-virtual {v4, v5, v6}, Ljava/lang/StringBuilder;->append(J)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 188
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mTitle:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_0

    .line 189
    const-string v4, "SUMMARY:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mTitle:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 191
    :cond_0
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDescription:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_1

    .line 192
    const-string v4, "DESCRIPTION:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDescription:Ljava/lang/String;

    invoke-direct {p0, v5}, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->foldingString(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 194
    :cond_1
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mLocation:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_2

    .line 195
    const-string v4, "LOCATION:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mLocation:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 198
    :cond_2
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mVisibility:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_3

    .line 199
    const-string v3, ""

    .line 200
    .local v3, "visibilityClass":Ljava/lang/String;
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mVisibility:Ljava/lang/String;

    invoke-static {v4}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v4

    packed-switch v4, :pswitch_data_0

    .line 211
    const-string v3, ""

    .line 213
    :goto_0
    invoke-static {v3}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_3

    .line 214
    const-string v4, "CLASS:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 218
    .end local v3    # "visibilityClass":Ljava/lang/String;
    :cond_3
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtstart:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_4

    .line 219
    const-string v4, "DTSTART:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtstart:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 221
    :cond_4
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtend:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_5

    const-string v4, "DTEND:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mDtend:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 224
    :cond_5
    iget-boolean v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mHasAlarm:Z

    if-eqz v4, :cond_6

    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->reminderList:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->size()I

    move-result v4

    if-lez v4, :cond_6

    .line 225
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->reminderList:Ljava/util/List;

    invoke-interface {v4}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_6

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 227
    .local v1, "remindTime":Ljava/lang/String;
    const-string v4, "DALARM:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    goto :goto_1

    .line 202
    .end local v0    # "i$":Ljava/util/Iterator;
    .end local v1    # "remindTime":Ljava/lang/String;
    .restart local v3    # "visibilityClass":Ljava/lang/String;
    :pswitch_0
    const-string v3, "CONFIDENTIAL"

    .line 203
    goto :goto_0

    .line 205
    :pswitch_1
    const-string v3, "PRIVATE"

    .line 206
    goto :goto_0

    .line 208
    :pswitch_2
    const-string v3, "PUBLIC"

    .line 209
    goto :goto_0

    .line 231
    .end local v3    # "visibilityClass":Ljava/lang/String;
    :cond_6
    iget-object v4, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    invoke-static {v4}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v4

    if-nez v4, :cond_7

    .line 232
    const-string v4, "RRULE:"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/jsr/JbedCalendarEvent;->mRrule:Ljava/lang/String;

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 234
    :cond_7
    const-string v4, "END:VEVENT"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "\r\n"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 236
    const-string v4, "END:VCALENDAR"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    .line 238
    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    return-object v4

    .line 200
    nop

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_0
        :pswitch_1
        :pswitch_2
    .end packed-switch
.end method
