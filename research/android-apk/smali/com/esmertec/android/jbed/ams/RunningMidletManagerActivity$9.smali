.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;
.super Ljava/lang/Object;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Landroid/content/DialogInterface$OnClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->onOptionsItemSelected(Landroid/view/MenuItem;)Z
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

.field final synthetic val$suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;)V
    .locals 0

    .prologue
    .line 376
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->val$suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 5
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "whichButton"    # I

    .prologue
    .line 378
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget v0, v0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedStopItem:I

    const/4 v1, -0x1

    if-eq v0, v1, :cond_0

    .line 379
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->val$suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedStopItem:I

    aget-object v2, v2, v3

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->val$suites:[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$9;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget v4, v4, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedStopItem:I

    aget-object v3, v3, v4

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v3, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->findMidlet(Ljava/lang/String;I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$300(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    .line 381
    :cond_0
    return-void
.end method
