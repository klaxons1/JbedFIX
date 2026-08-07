.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;
.super Ljava/lang/Object;
.source "RunningMidletManagerActivity.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemSelectedListener;


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
    .line 206
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onItemSelected(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 2
    .param p2, "arg1"    # Landroid/view/View;
    .param p3, "position"    # I
    .param p4, "id"    # J
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/widget/AdapterView",
            "<*>;",
            "Landroid/view/View;",
            "IJ)V"
        }
    .end annotation

    .prologue
    .line 209
    .local p1, "arg0":Landroid/widget/AdapterView;, "Landroid/widget/AdapterView<*>;"
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->getListView()Landroid/widget/ListView;

    move-result-object v1

    invoke-virtual {v1}, Landroid/widget/ListView;->getSelectedItemPosition()I

    move-result v1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$202(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;I)I

    .line 210
    return-void
.end method

.method public onNothingSelected(Landroid/widget/AdapterView;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/widget/AdapterView",
            "<*>;)V"
        }
    .end annotation

    .prologue
    .line 213
    .local p1, "arg0":Landroid/widget/AdapterView;, "Landroid/widget/AdapterView<*>;"
    const-string v0, "RunningActivity"

    const-string v1, "onNothingSelected have nothing to selected!! "

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 214
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    const/4 v1, -0x1

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->access$202(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;I)I

    .line 215
    return-void
.end method
