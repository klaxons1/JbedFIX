.class Lcom/esmertec/android/jbed/ams/AmsActivity$2;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemClickListener;


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
    .line 209
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onItemClick(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 6
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
    .line 211
    .local p1, "parent":Landroid/widget/AdapterView;, "Landroid/widget/AdapterView<*>;"
    invoke-static {}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$100()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 237
    :cond_0
    :goto_0
    return-void

    .line 212
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {p1}, Landroid/widget/AdapterView;->getAdapter()Landroid/widget/Adapter;

    move-result-object v2

    invoke-interface {v2, p3}, Landroid/widget/Adapter;->getItem(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-object v2, v3, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 213
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v2

    invoke-virtual {v2, p3}, Landroid/widget/ListView;->setSelection(I)V

    .line 218
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v0

    .line 219
    .local v0, "client":Lcom/esmertec/android/jbed/ams/AmsClient;
    if-eqz v0, :cond_0

    .line 220
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmPending()Z

    move-result v2

    if-eqz v2, :cond_2

    .line 221
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestDrmInstallEvent(Ljava/lang/String;)V

    goto :goto_0

    .line 222
    :cond_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_4

    .line 223
    invoke-static {}, Lcom/esmertec/android/jbed/ams/AmsActivity;->hasEnoughFreeMemory()Z

    move-result v2

    if-eqz v2, :cond_3

    .line 224
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v2

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget v4, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestRunEvent(Ljava/lang/String;I)V

    goto :goto_0

    .line 226
    :cond_3
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const v4, 0x7f05006d

    invoke-virtual {v3, v4}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const v5, 0x1040111

    invoke-virtual {v4, v5}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v4

    invoke-static {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$300(Lcom/esmertec/android/jbed/ams/AmsActivity;Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 229
    :cond_4
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v2

    if-eqz v2, :cond_5

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-eqz v2, :cond_5

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-boolean v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-nez v2, :cond_5

    .line 230
    new-instance v1, Lcom/esmertec/android/jbed/ams/FolderNameI18N;

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {v1, v2}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;-><init>(Landroid/content/Context;)V

    .line 231
    .local v1, "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getFolderUrl()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestLaunchBrowser(Ljava/lang/String;)V

    goto/16 :goto_0

    .line 234
    .end local v1    # "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    :cond_5
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$400(Lcom/esmertec/android/jbed/ams/AmsActivity;)I

    move-result v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$2;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-static {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$500(Lcom/esmertec/android/jbed/ams/AmsActivity;ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_0
.end method
