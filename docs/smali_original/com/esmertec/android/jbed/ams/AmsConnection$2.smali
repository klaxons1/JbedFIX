.class Lcom/esmertec/android/jbed/ams/AmsConnection$2;
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
    .line 181
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onEvent(II[B)Z
    .locals 3
    .param p1, "eventId"    # I
    .param p2, "result"    # I
    .param p3, "data"    # [B

    .prologue
    .line 184
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$300(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/lang/Object;

    move-result-object v0

    monitor-enter v0

    .line 185
    :try_start_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$400(Lcom/esmertec/android/jbed/ams/AmsConnection;)Lcom/esmertec/android/jbed/ams/IJbedAmsClient;

    move-result-object v1

    if-nez v1, :cond_0

    .line 189
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsConnection$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsConnection;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/AmsConnection;->access$500(Lcom/esmertec/android/jbed/ams/AmsConnection;)Ljava/util/concurrent/BlockingQueue;

    move-result-object v1

    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-direct {v2, p1, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsEvent;-><init>(II[B)V

    invoke-interface {v1, v2}, Ljava/util/concurrent/BlockingQueue;->add(Ljava/lang/Object;)Z

    .line 191
    :cond_0
    monitor-exit v0

    .line 192
    const/4 v0, 0x0

    return v0

    .line 191
    :catchall_0
    move-exception v1

    monitor-exit v0
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    throw v1
.end method
