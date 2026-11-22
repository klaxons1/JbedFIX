.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;
.super Ljava/lang/Object;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->showStopConfirmDialog(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

.field final synthetic val$midlet:Lcom/esmertec/android/jbed/ams/JbedSelectorData;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 0

    .prologue
    .line 440
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;->val$midlet:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 3
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 442
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v0}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;->val$midlet:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v1, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$12;->val$midlet:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDestroyEvent(Ljava/lang/String;I)V

    .line 443
    return-void
.end method
