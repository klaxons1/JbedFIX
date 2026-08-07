.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidShowAlertEventHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1175
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 3

    .prologue
    .line 1178
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    packed-switch v0, :pswitch_data_0

    .line 1189
    new-instance v0, Ljava/lang/IllegalArgumentException;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "AndroidShowAlertEventHandler unkonwn type "

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mResult:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0

    .line 1180
    :pswitch_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v0, Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->showInfo(Ljava/lang/String;)V

    .line 1191
    :goto_0
    return-void

    .line 1183
    :pswitch_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v0, Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->showWarning(Ljava/lang/String;)V

    goto :goto_0

    .line 1186
    :pswitch_2
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsEvent;->mObj:Ljava/lang/Object;

    check-cast v0, Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;->showError(Ljava/lang/String;)V

    goto :goto_0

    .line 1178
    :pswitch_data_0
    .packed-switch 0x0
        :pswitch_0
        :pswitch_1
        :pswitch_2
    .end packed-switch
.end method
