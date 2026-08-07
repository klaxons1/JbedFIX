.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;
.super Ljava/lang/Object;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Landroid/view/View$OnCreateContextMenuListener;


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
    .line 220
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCreateContextMenu(Landroid/view/ContextMenu;Landroid/view/View;Landroid/view/ContextMenu$ContextMenuInfo;)V
    .locals 4
    .param p1, "menu"    # Landroid/view/ContextMenu;
    .param p2, "v"    # Landroid/view/View;
    .param p3, "menuInfo"    # Landroid/view/ContextMenu$ContextMenuInfo;

    .prologue
    .line 231
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getMenuInflater()Landroid/view/MenuInflater;

    move-result-object v2

    const v3, 0x7f070001

    invoke-virtual {v2, v3, p1}, Landroid/view/MenuInflater;->inflate(ILandroid/view/Menu;)V

    .line 232
    move-object v0, p3

    check-cast v0, Landroid/widget/AdapterView$AdapterContextMenuInfo;

    move-object v1, v0

    .line 233
    .local v1, "info":Landroid/widget/AdapterView$AdapterContextMenuInfo;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget v3, v1, Landroid/widget/AdapterView$AdapterContextMenuInfo;->position:I

    invoke-static {v2, v3}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$202(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;I)I

    .line 234
    const v2, 0x7f080034

    const/4 v3, 0x0

    invoke-interface {p1, v2, v3}, Landroid/view/ContextMenu;->setGroupVisible(IZ)V

    .line 236
    return-void
.end method
