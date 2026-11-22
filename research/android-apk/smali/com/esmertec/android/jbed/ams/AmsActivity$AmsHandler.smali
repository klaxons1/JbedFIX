.class Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;
.super Landroid/os/Handler;
.source "AmsActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "AmsHandler"
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/AmsActivity;)V
    .locals 0

    .prologue
    .line 818
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Landroid/os/Handler;-><init>()V

    return-void
.end method


# virtual methods
.method public handleMessage(Landroid/os/Message;)V
    .locals 14
    .param p1, "msg"    # Landroid/os/Message;

    .prologue
    const v12, 0x7f080036

    const/4 v11, 0x1

    const/4 v9, 0x0

    const-string v13, "current.storage"

    const-string v10, "AmsActivity"

    .line 822
    const-string v7, "AmsActivity"

    new-instance v7, Ljava/lang/StringBuilder;

    invoke-direct {v7}, Ljava/lang/StringBuilder;-><init>()V

    const-string v8, "AmsHandler.handleMessage() msg="

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget v8, p1, Landroid/os/Message;->what:I

    invoke-virtual {v7, v8}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v10, v7}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 823
    iget v7, p1, Landroid/os/Message;->what:I

    sparse-switch v7, :sswitch_data_0

    .line 941
    :cond_0
    :goto_0
    invoke-super {p0, p1}, Landroid/os/Handler;->handleMessage(Landroid/os/Message;)V

    .line 942
    return-void

    .line 825
    :sswitch_0
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1400(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    goto :goto_0

    .line 828
    :sswitch_1
    const-string v7, "AmsActivity"

    const-string v7, "WARNING: receive EVENT_SERVICE_DISCONNECTED event"

    invoke-static {v10, v7}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 831
    :sswitch_2
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Z

    move-result v7

    if-eqz v7, :cond_2

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    if-eqz v7, :cond_2

    .line 833
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->refreshSelector()V

    .line 837
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v7, :cond_1

    const/4 v7, 0x0

    move-object v0, v7

    .line 839
    .local v0, "curFolder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_1
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$400(Lcom/esmertec/android/jbed/ams/AmsActivity;)I

    move-result v8

    invoke-static {v7, v8, v0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$500(Lcom/esmertec/android/jbed/ams/AmsActivity;ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_0

    .line 837
    .end local v0    # "curFolder":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v8, v8, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v8}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getHierarchyNames()[Ljava/lang/String;

    move-result-object v8

    invoke-virtual {v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->getMildetByHierarchyNames([Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-result-object v7

    move-object v0, v7

    goto :goto_1

    .line 844
    :cond_2
    const-string v7, "AmsActivity"

    const-string v7, "handleMessage HANDLE_REFRESH_LIST but have no connection!!"

    invoke-static {v10, v7}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_0

    .line 848
    :sswitch_3
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->showDialog(I)V

    .line 849
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    if-eqz v7, :cond_0

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    if-eqz v7, :cond_0

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v7, Ljava/lang/Boolean;

    check-cast v7, Ljava/lang/Boolean;

    invoke-virtual {v7}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v7

    if-eqz v7, :cond_0

    .line 850
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    invoke-virtual {v7, v9}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    goto/16 :goto_0

    .line 854
    :sswitch_4
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    if-eqz v7, :cond_0

    .line 855
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    iget v8, p1, Landroid/os/Message;->arg1:I

    invoke-virtual {v7, v8}, Landroid/app/ProgressDialog;->setProgress(I)V

    goto/16 :goto_0

    .line 858
    :sswitch_5
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->removeDialog(I)V

    goto/16 :goto_0

    .line 861
    :sswitch_6
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    if-eqz v7, :cond_0

    .line 862
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    invoke-virtual {v7, v9}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    .line 863
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const v9, 0x7f0501df

    invoke-virtual {v8, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getText(I)Ljava/lang/CharSequence;

    move-result-object v8

    invoke-virtual {v7, v8}, Landroid/app/ProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    goto/16 :goto_0

    .line 867
    :sswitch_7
    new-instance v4, Landroid/content/Intent;

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const-class v8, Lcom/esmertec/android/jbed/app/JbedAppActivity;

    invoke-direct {v4, v7, v8}, Landroid/content/Intent;-><init>(Landroid/content/Context;Ljava/lang/Class;)V

    .line 868
    .local v4, "jbedIntent":Landroid/content/Intent;
    const/high16 v7, 0x4000000

    invoke-virtual {v4, v7}, Landroid/content/Intent;->setFlags(I)Landroid/content/Intent;

    .line 869
    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v7, Ljava/lang/Boolean;

    invoke-virtual {v7}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    .line 870
    .local v3, "isFullString":Z
    const-string v7, "isFullScreen"

    invoke-virtual {v4, v7, v3}, Landroid/content/Intent;->putExtra(Ljava/lang/String;Z)Landroid/content/Intent;

    .line 872
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v4}, Lcom/esmertec/android/jbed/ams/AmsActivity;->startActivity(Landroid/content/Intent;)V

    goto/16 :goto_0

    .line 875
    .end local v3    # "isFullString":Z
    .end local v4    # "jbedIntent":Landroid/content/Intent;
    :sswitch_8
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1600(Lcom/esmertec/android/jbed/ams/AmsActivity;)V

    .line 876
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->finish()V

    goto/16 :goto_0

    .line 879
    :sswitch_9
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    if-eqz v7, :cond_0

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    if-eqz v7, :cond_0

    .line 880
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v8

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v7, Ljava/lang/String;

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    const-string v9, "\n"

    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    iget-object v9, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    const v10, 0x7f050378

    invoke-virtual {v9, v10}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getString(I)Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v7, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v7

    invoke-virtual {v7}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-virtual {v8, v7}, Landroid/app/ProgressDialog;->setMessage(Ljava/lang/CharSequence;)V

    goto/16 :goto_0

    .line 885
    :sswitch_a
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    if-eqz v7, :cond_0

    .line 886
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1500(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/app/ProgressDialog;

    move-result-object v7

    invoke-virtual {v7, v9}, Landroid/app/ProgressDialog;->setCancelable(Z)V

    goto/16 :goto_0

    .line 890
    :sswitch_b
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v11}, Lcom/esmertec/android/jbed/ams/AmsActivity;->showDialog(I)V

    goto/16 :goto_0

    .line 894
    :sswitch_c
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v11}, Lcom/esmertec/android/jbed/ams/AmsActivity;->removeDialog(I)V

    goto/16 :goto_0

    .line 897
    :sswitch_d
    iget-object v6, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v6, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 898
    .local v6, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v8}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$400(Lcom/esmertec/android/jbed/ams/AmsActivity;)I

    move-result v8

    invoke-static {v7, v8, v6}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$500(Lcom/esmertec/android/jbed/ams/AmsActivity;ILcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_0

    .line 901
    .end local v6    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :sswitch_e
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v8, v8, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurFolder:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInputFolderName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_0

    .line 904
    :sswitch_f
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v8, v8, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requsetInputName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto/16 :goto_0

    .line 907
    :sswitch_10
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v8

    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v9, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v7, Ljava/lang/String;

    invoke-virtual {v8, v9, v7}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestHandleMideltStartupError(Ljava/lang/String;Ljava/lang/String;)V

    goto/16 :goto_0

    .line 910
    :sswitch_11
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getPreferences(I)Landroid/content/SharedPreferences;

    move-result-object v7

    invoke-interface {v7}, Landroid/content/SharedPreferences;->edit()Landroid/content/SharedPreferences$Editor;

    move-result-object v1

    .line 911
    .local v1, "editor":Landroid/content/SharedPreferences$Editor;
    const-string v7, "current.storage"

    iget v7, p1, Landroid/os/Message;->arg1:I

    invoke-interface {v1, v13, v7}, Landroid/content/SharedPreferences$Editor;->putInt(Ljava/lang/String;I)Landroid/content/SharedPreferences$Editor;

    .line 912
    invoke-interface {v1}, Landroid/content/SharedPreferences$Editor;->commit()Z

    goto/16 :goto_0

    .line 915
    .end local v1    # "editor":Landroid/content/SharedPreferences$Editor;
    :sswitch_12
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v7, v9}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getPreferences(I)Landroid/content/SharedPreferences;

    move-result-object v7

    const-string v8, "current.storage"

    invoke-interface {v7, v13, v9}, Landroid/content/SharedPreferences;->getInt(Ljava/lang/String;I)I

    move-result v5

    .line 916
    .local v5, "storage":I
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$200(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsClient;

    move-result-object v7

    if-nez v5, :cond_3

    move v8, v11

    :goto_2
    invoke-virtual {v7, v8}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestHandleSelectStorage(Z)V

    goto/16 :goto_0

    :cond_3
    move v8, v9

    goto :goto_2

    .line 919
    .end local v5    # "storage":I
    :sswitch_13
    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    invoke-virtual {v7}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v7

    invoke-static {v7}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;)I

    move-result v7

    if-ne v7, v11, :cond_4

    .line 920
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1700(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/view/Menu;

    move-result-object v7

    if-eqz v7, :cond_0

    .line 921
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1700(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/view/Menu;

    move-result-object v7

    invoke-interface {v7, v12}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v7

    invoke-interface {v7, v11}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    goto/16 :goto_0

    .line 925
    :cond_4
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1700(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/view/Menu;

    move-result-object v7

    if-eqz v7, :cond_0

    .line 926
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1700(Lcom/esmertec/android/jbed/ams/AmsActivity;)Landroid/view/Menu;

    move-result-object v7

    invoke-interface {v7, v12}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v7

    invoke-interface {v7, v9}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    goto/16 :goto_0

    .line 931
    :sswitch_14
    iget v7, p1, Landroid/os/Message;->arg1:I

    const/16 v8, 0x11

    if-ne v7, v8, :cond_0

    .line 932
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    move-result-object v7

    iget-object v8, v7, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    new-instance v9, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v7, p1, Landroid/os/Message;->obj:Ljava/lang/Object;

    check-cast v7, Ljava/lang/String;

    iget v10, p1, Landroid/os/Message;->arg2:I

    invoke-direct {v9, v7, v10}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;-><init>(Ljava/lang/String;I)V

    invoke-interface {v8, v9}, Ljava/util/List;->indexOf(Ljava/lang/Object;)I

    move-result v2

    .line 933
    .local v2, "index":I
    if-ltz v2, :cond_0

    .line 934
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    move-result-object v7

    iget-object v7, v7, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v7, v2}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-boolean v11, v7, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 935
    iget-object v7, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$AmsHandler;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-static {v7}, Lcom/esmertec/android/jbed/ams/AmsActivity;->access$1800(Lcom/esmertec/android/jbed/ams/AmsActivity;)Lcom/esmertec/android/jbed/ams/AmsListAdapter;

    move-result-object v7

    invoke-virtual {v7}, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->notifyDataSetChanged()V

    goto/16 :goto_0

    .line 823
    :sswitch_data_0
    .sparse-switch
        0x2710 -> :sswitch_7
        0x2711 -> :sswitch_8
        0x2712 -> :sswitch_2
        0x2713 -> :sswitch_3
        0x2714 -> :sswitch_4
        0x2715 -> :sswitch_5
        0x2716 -> :sswitch_a
        0x2717 -> :sswitch_6
        0x2719 -> :sswitch_9
        0x271a -> :sswitch_b
        0x271b -> :sswitch_c
        0x271c -> :sswitch_b
        0x271d -> :sswitch_c
        0x271f -> :sswitch_14
        0x2721 -> :sswitch_d
        0x2722 -> :sswitch_e
        0x2723 -> :sswitch_f
        0x2724 -> :sswitch_10
        0x2725 -> :sswitch_11
        0x2726 -> :sswitch_12
        0x2729 -> :sswitch_13
        0x182b9 -> :sswitch_0
        0x182ba -> :sswitch_1
    .end sparse-switch
.end method
