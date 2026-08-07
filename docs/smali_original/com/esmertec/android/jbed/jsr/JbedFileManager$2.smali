.class Lcom/esmertec/android/jbed/jsr/JbedFileManager$2;
.super Ljava/lang/Object;
.source "JbedFileManager.java"

# interfaces
.implements Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedFileManager;->onCreate(Landroid/content/Context;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)V
    .locals 0

    .prologue
    .line 159
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$2;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onRootChanged(Ljava/lang/String;Ljava/lang/String;Z)V
    .locals 0
    .param p1, "rootName"    # Ljava/lang/String;
    .param p2, "rootPath"    # Ljava/lang/String;
    .param p3, "isAdded"    # Z

    .prologue
    .line 162
    invoke-static {p1, p2, p3}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->access$200(Ljava/lang/String;Ljava/lang/String;Z)V

    .line 163
    return-void
.end method
