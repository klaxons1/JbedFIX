.class public Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidLaunchBrowserHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "BasicEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "AndroidLaunchBrowserHandler"
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    .prologue
    .line 1198
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .locals 4

    .prologue
    .line 1202
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidLaunchBrowserHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    if-eqz v2, :cond_0

    .line 1203
    new-instance v1, Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidLaunchBrowserHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsEvent;->mData:[B

    invoke-direct {v1, v2}, Ljava/lang/String;-><init>([B)V

    .line 1204
    .local v1, "url":Ljava/lang/String;
    new-instance v0, Landroid/content/Intent;

    const-string v2, "android.intent.action.VIEW"

    invoke-static {v1}, Landroid/net/Uri;->parse(Ljava/lang/String;)Landroid/net/Uri;

    move-result-object v3

    invoke-direct {v0, v2, v3}, Landroid/content/Intent;-><init>(Ljava/lang/String;Landroid/net/Uri;)V

    .line 1209
    .end local v1    # "url":Ljava/lang/String;
    .local v0, "intent":Landroid/content/Intent;
    :goto_0
    const/high16 v2, 0x14000000

    invoke-virtual {v0, v2}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 1212
    const-string v2, "com.android.browser"

    const-string v3, "com.android.browser.BrowserActivity"

    invoke-virtual {v0, v2, v3}, Landroid/content/Intent;->setClassName(Ljava/lang/String;Ljava/lang/String;)Landroid/content/Intent;

    .line 1213
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidLaunchBrowserHandler;->mContext:Landroid/content/Context;

    invoke-virtual {v2, v0}, Landroid/content/Context;->startActivity(Landroid/content/Intent;)V

    .line 1214
    return-void

    .line 1206
    .end local v0    # "intent":Landroid/content/Intent;
    :cond_0
    new-instance v0, Landroid/content/Intent;

    const-string v2, "android.intent.action.MAIN"

    invoke-direct {v0, v2}, Landroid/content/Intent;-><init>(Ljava/lang/String;)V

    .restart local v0    # "intent":Landroid/content/Intent;
    goto :goto_0
.end method
