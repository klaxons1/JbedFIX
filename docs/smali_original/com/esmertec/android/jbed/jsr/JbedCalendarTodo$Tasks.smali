.class public final Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;
.super Ljava/lang/Object;
.source "JbedCalendarTodo.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Tasks"
.end annotation


# static fields
.field public static final ALARM:Ljava/lang/String; = "alarm"

.field public static final CONTENT_URI:Landroid/net/Uri;

.field public static final HAS_ALARM:I = 0x1

.field public static final ID:Ljava/lang/String; = "_id"

.field public static final IS_DUE:I = 0x2

.field public static final NO_ALARM:I = 0x0

.field public static final TITLE:Ljava/lang/String; = "title"


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 144
    const-string v0, "content://todo/todo_tasks"

    invoke-static {v0}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v0

    sput-object v0, Lcom/esmertec/android/jbed/jsr/JbedCalendarTodo$Tasks;->CONTENT_URI:Landroid/net/Uri;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 134
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
