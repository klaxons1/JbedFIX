.class Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$7;
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


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;)V
    .locals 0

    .prologue
    .line 337
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onClick(Landroid/content/DialogInterface;I)V
    .locals 1
    .param p1, "dialog"    # Landroid/content/DialogInterface;
    .param p2, "which"    # I

    .prologue
    .line 339
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity$7;->this$0:Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;

    iput p2, v0, Lcom/esmertec/android/jbed/ams/RunningMidletManagerActivity;->selectedResumeItem:I

    .line 340
    return-void
.end method
