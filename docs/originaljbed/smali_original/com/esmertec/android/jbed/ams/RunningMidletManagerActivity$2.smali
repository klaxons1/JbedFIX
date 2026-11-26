.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$2;
.super Ljava/lang/Object;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V
    .locals 0

    .prologue
    .line 191
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onItemClick(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 4
    .param p1, "parent"    # Landroid/widget/AdapterView;
    .param p2, "v"    # Landroid/view/View;
    .param p3, "position"    # I
    .param p4, "id"    # J

    .prologue
    .line 193
    invoke-virtual {p1}, Landroid/widget/AdapterView;->getAdapter()Landroid/widget/Adapter;

    move-result-object v1

    invoke-interface {v1, p3}, Landroid/widget/Adapter;->getItem(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 200
    .local v0, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$000(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v1

    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v3, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRunEvent(Ljava/lang/String;I)V

    .line 202
    return-void
.end method
