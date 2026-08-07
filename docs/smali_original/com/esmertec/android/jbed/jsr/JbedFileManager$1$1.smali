.class Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;
.super Ljava/lang/Object;
.source "JbedFileManager.java"

# interfaces
.implements Ljava/lang/Runnable;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->onReceive(Landroid/content/Context;Landroid/content/Intent;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# static fields
.field static final synthetic $assertionsDisabled:Z


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;

.field final synthetic val$intent:Landroid/content/Intent;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 104
    const-class v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-virtual {v0}, Ljava/lang/Class;->desiredAssertionStatus()Z

    move-result v0

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    sput-boolean v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->$assertionsDisabled:Z

    return-void

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method constructor <init>(Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;Landroid/content/Intent;)V
    .locals 0

    .prologue
    .line 104
    iput-object p1, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;

    iput-object p2, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->val$intent:Landroid/content/Intent;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 10

    .prologue
    const-string v9, "JbedFileManager"

    .line 106
    sget-boolean v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->$assertionsDisabled:Z

    if-nez v6, :cond_0

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->val$intent:Landroid/content/Intent;

    invoke-virtual {v6}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v6

    if-nez v6, :cond_0

    new-instance v6, Ljava/lang/AssertionError;

    invoke-direct {v6}, Ljava/lang/AssertionError;-><init>()V

    throw v6

    .line 107
    :cond_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->val$intent:Landroid/content/Intent;

    invoke-virtual {v6}, Landroid/content/Intent;->getData()Landroid/net/Uri;

    move-result-object v5

    .line 108
    .local v5, "uri":Landroid/net/Uri;
    invoke-static {}, Landroid/os/Environment;->getExternalStorageDirectory()Ljava/io/File;

    move-result-object v6

    invoke-virtual {v6}, Ljava/io/File;->getPath()Ljava/lang/String;

    move-result-object v0

    .line 109
    .local v0, "externalStoragePath":Ljava/lang/String;
    invoke-virtual {v5}, Landroid/net/Uri;->getScheme()Ljava/lang/String;

    move-result-object v6

    const-string v7, "file"

    invoke-virtual {v6, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_3

    invoke-virtual {v5}, Landroid/net/Uri;->getPath()Ljava/lang/String;

    move-result-object v6

    const/4 v7, 0x0

    const/16 v8, 0xb

    invoke-virtual {v6, v7, v8}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v0, v6}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_3

    .line 115
    const/4 v2, 0x0

    .line 116
    .local v2, "isAdded":Z
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->val$intent:Landroid/content/Intent;

    invoke-virtual {v6}, Landroid/content/Intent;->getAction()Ljava/lang/String;

    move-result-object v6

    const-string v7, "android.intent.action.MEDIA_MOUNTED"

    invoke-virtual {v6, v7}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v6

    if-eqz v6, :cond_1

    .line 117
    const/4 v2, 0x1

    .line 118
    const-string v6, "JbedFileManager"

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, " mouted sdcard at "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v9, v6}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    .line 122
    :goto_0
    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;

    iget-object v6, v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    iget-object v6, v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->mListeners:Ljava/util/List;

    invoke-interface {v6}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_1
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_2

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;

    .line 123
    .local v3, "listener":Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;
    sget-object v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->convertFilePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v6

    invoke-static {v0}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->convertFilePath(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v7

    invoke-interface {v3, v6, v7, v2}, Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;->onRootChanged(Ljava/lang/String;Ljava/lang/String;Z)V

    goto :goto_1

    .line 120
    .end local v1    # "i$":Ljava/util/Iterator;
    .end local v3    # "listener":Lcom/esmertec/android/jbed/jsr/JbedFileManager$RootChangeListener;
    :cond_1
    const-string v6, "JbedFileManager"

    new-instance v6, Ljava/lang/StringBuilder;

    invoke-direct {v6}, Ljava/lang/StringBuilder;-><init>()V

    const-string v7, " unmounted sdcard from "

    invoke-virtual {v6, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v6

    invoke-static {v9, v6}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0

    .line 127
    .restart local v1    # "i$":Ljava/util/Iterator;
    :cond_2
    new-instance v4, Lcom/esmertec/android/jbed/ams/JbedSelector;

    iget-object v6, p0, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1$1;->this$1:Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;

    iget-object v6, v6, Lcom/esmertec/android/jbed/jsr/JbedFileManager$1;->this$0:Lcom/esmertec/android/jbed/jsr/JbedFileManager;

    invoke-static {v6}, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->access$100(Lcom/esmertec/android/jbed/jsr/JbedFileManager;)Landroid/content/Context;

    move-result-object v6

    invoke-static {v6}, Lcom/esmertec/android/jbed/JbedSettings;->getInstance(Landroid/content/Context;)Lcom/esmertec/android/jbed/JbedSettings;

    move-result-object v6

    invoke-virtual {v6}, Lcom/esmertec/android/jbed/JbedSettings;->getBaseDir()Ljava/lang/String;

    move-result-object v6

    invoke-direct {v4, v6}, Lcom/esmertec/android/jbed/ams/JbedSelector;-><init>(Ljava/lang/String;)V

    .line 128
    .local v4, "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelector;->touch()V

    .line 130
    .end local v1    # "i$":Ljava/util/Iterator;
    .end local v2    # "isAdded":Z
    .end local v4    # "selector":Lcom/esmertec/android/jbed/ams/JbedSelector;
    :cond_3
    return-void
.end method
