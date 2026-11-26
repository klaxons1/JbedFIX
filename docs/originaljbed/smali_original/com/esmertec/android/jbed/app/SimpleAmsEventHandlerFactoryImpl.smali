.class Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;
.super Ljava/lang/Object;
.source "JbedView.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;


# direct methods
.method constructor <init>()V
    .locals 0

    .prologue
    .line 701
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public buildAmsHandler(I)Lcom/esmertec/android/jbed/ams/AmsEventHandler;
    .locals 1
    .param p1, "eventId"    # I

    .prologue
    .line 704
    new-instance v0, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;

    invoke-direct {v0, p0}, Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl$1;-><init>(Lcom/esmertec/android/jbed/app/SimpleAmsEventHandlerFactoryImpl;)V

    return-object v0
.end method
