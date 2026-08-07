.class Lcom/esmertec/android/jbed/ams/AmsActivity$4;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Landroid/view/View$OnCreateContextMenuListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;->onCreate(Landroid/os/Bundle;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0

    .prologue
    .line 274
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onCreateContextMenu(Landroid/view/ContextMenu;Landroid/view/View;Landroid/view/ContextMenu$ContextMenuInfo;)V
    .locals 6
    .param p1, "menu"    # Landroid/view/ContextMenu;
    .param p2, "v"    # Landroid/view/View;
    .param p3, "menuInfo"    # Landroid/view/ContextMenu$ContextMenuInfo;

    .prologue
    const/4 v5, 0x0

    .line 277
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getMenuInflater()Landroid/view/MenuInflater;

    move-result-object v2

    const/high16 v3, 0x7f070000

    invoke-virtual {v2, v3, p1}, Landroid/view/MenuInflater;->inflate(ILandroid/view/Menu;)V

    .line 278
    move-object v0, p3

    check-cast v0, Landroid/widget/AdapterView$AdapterContextMenuInfo;

    move-object v1, v0

    .line 279
    .local v1, "info":Landroid/widget/AdapterView$AdapterContextMenuInfo;
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    iget v4, v1, Landroid/widget/AdapterView$AdapterContextMenuInfo;->position:I

    invoke-virtual {v2, v4}, Landroid/widget/ListView;->getItemAtPosition(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-object v2, v3, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 280
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    iget v3, v1, Landroid/widget/AdapterView$AdapterContextMenuInfo;->position:I

    invoke-virtual {v2, v3}, Landroid/widget/ListView;->setSelection(I)V

    .line 281
    invoke-static {p1}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->access$600(Landroid/view/Menu;)V

    .line 282
    const v2, 0x7f080034

    invoke-interface {p1, v2, v5}, Landroid/view/ContextMenu;->setGroupVisible(IZ)V

    .line 283
    const v2, 0x7f080041

    invoke-interface {p1, v2, v5}, Landroid/view/ContextMenu;->setGroupVisible(IZ)V

    .line 285
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$4;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    const/4 v5, 0x1

    invoke-static {v2, p1, v3, v4, v5}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->access$700(Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/view/Menu;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    .line 286
    return-void
.end method
