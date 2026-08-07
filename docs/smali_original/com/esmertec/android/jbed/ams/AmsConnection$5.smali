.class Lcom/esmertec/android/jbed/ams/AmsConnection$5;
.super Ljava/lang/Object;
.source "AmsConnection.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConnection$AmsEventFilter;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsConnection;)V
    .locals 0

    .prologue
    .line 297
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onEvent(II[B)Z
    .locals 10
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    const/4 v9, 0x1

    const/4 v8, 0x0

    .line 304
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v4}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v4

    monitor-enter v4

    .line 306
    :try_start_0
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v5

    if-nez v5, :cond_0

    .line 307
    const-string v5, "AmsConnection"

    const-string v6, "mRequestPermissionFilter(): guess the jbed client is on the way. ! wait 2\'s!"

    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 309
    :try_start_1
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$000(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v5

    const-wide/16 v6, 0x7d0

    invoke-virtual {v5, v6, v7}, Ljava/lang/Object;->wait(J)V
    :try_end_1
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_1} :catch_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    .line 314
    :cond_0
    :goto_0
    :try_start_2
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$100(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/service/JbedService$ClientProxy;

    move-result-object v5

    if-nez v5, :cond_5

    .line 315
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v5}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$500(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/concurrent/BlockingQueue;

    move-result-object v5

    new-instance v6, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v6, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    invoke-interface {v5, v6}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 316
    const/4 v2, 0x0

    .line 317
    .local v2, "root":Ljava/lang/String;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->isSupportSoftKeyboard()Z
    :try_end_2
    .catchall {:try_start_2 .. :try_end_2} :catchall_0

    move-result v5

    if-eqz v5, :cond_2

    .line 319
    :try_start_3
    new-instance v0, Ljava/io/DataInputStream;

    new-instance v5, Ljava/io/ByteArrayInputStream;

    invoke-direct {v5, p3}, Ljava/io/ByteArrayInputStream;-><init>([B)V

    invoke-direct {v0, v5}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V

    .line 320
    .local v0, "in":Ljava/io/DataInputStream;
    invoke-virtual {v0}, Ljava/io/DataInputStream;->readBoolean()Z

    move-result v5

    if-eqz v5, :cond_1

    .line 321
    invoke-virtual {v0}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v2

    .line 322
    :cond_1
    invoke-virtual {v0}, Ljava/io/DataInputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_0
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 328
    .end local v0    # "in":Ljava/io/DataInputStream;
    :cond_2
    :try_start_4
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    const/4 v5, -0x1

    invoke-direct {v3, v2, v5}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;I)V

    .line 329
    .local v3, "selectorData":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$5;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    if-nez v2, :cond_3

    move v6, v8

    :goto_1
    invoke-static {v5, v6}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$1100(Lcom/esmertec/android/jbed/ams/AmsConnection;Z)V

    .line 330
    monitor-exit v4

    move v4, v9

    .line 333
    .end local v2    # "root":Ljava/lang/String;
    .end local v3    # "selectorData":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_2
    return v4

    .line 323
    .restart local v2    # "root":Ljava/lang/String;
    :catch_0
    move-exception v5

    move-object v1, v5

    .line 324
    .local v1, "ioe":Ljava/io/IOException;
    new-instance v5, Ljava/lang/RuntimeException;

    const-string v6, "readJbedString IOException"

    invoke-direct {v5, v6}, Ljava/lang/RuntimeException;-><init>(Ljava/lang/String;)V

    throw v5

    .line 332
    .end local v1    # "ioe":Ljava/io/IOException;
    .end local v2    # "root":Ljava/lang/String;
    :catchall_0
    move-exception v5

    monitor-exit v4
    :try_end_4
    .catchall {:try_start_4 .. :try_end_4} :catchall_0

    throw v5

    .line 329
    .restart local v2    # "root":Ljava/lang/String;
    .restart local v3    # "selectorData":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_3
    :try_start_5
    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFullScreen()Z

    move-result v6

    if-nez v6, :cond_4

    move v6, v9

    goto :goto_1

    :cond_4
    move v6, v8

    goto :goto_1

    .line 332
    .end local v2    # "root":Ljava/lang/String;
    .end local v3    # "selectorData":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_5
    monitor-exit v4
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    move v4, v8

    .line 333
    goto :goto_2

    .line 310
    :catch_1
    move-exception v5

    goto :goto_0
.end method
