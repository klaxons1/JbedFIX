.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
.super Ljava/lang/Object;
.source "PermissionEventHandler.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemSelectedListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

.field final synthetic val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

.field final synthetic val$position:I

.field final synthetic val$spinner:Landroid/widget/Spinner;


# direct methods
.method constructor <init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;ILandroid/widget/Spinner;)V
    .locals 0

    .prologue
    .line 272
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iput p3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$position:I

    iput-object p4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$spinner:Landroid/widget/Spinner;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onItemSelected(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 5
    .param p1, "av"    # Landroid/widget/AdapterView;
    .param p2, "v"    # Landroid/view/View;
    .param p3, "p"    # I
    .param p4, "id"    # J

    .prologue
    .line 275
    invoke-virtual {p1}, Landroid/widget/AdapterView;->getAdapter()Landroid/widget/Adapter;

    move-result-object v2

    invoke-interface {v2, p3}, Landroid/widget/Adapter;->getItem(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/util/SimpleEntry;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/util/SimpleEntry;->getKey()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Byte;

    .line 277
    .local v1, "select":Ljava/lang/Byte;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    iget-byte v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mCurrentAllowed:B

    invoke-virtual {v1}, Ljava/lang/Byte;->byteValue()B

    move-result v3

    if-ne v2, v3, :cond_0

    .line 305
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    :goto_0
    return-void

    .line 280
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Ljava/util/List;

    move-result-object v2

    iget v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$position:I

    invoke-interface {v2, v3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-boolean v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mChangable:Z

    if-nez v2, :cond_1

    .line 281
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$spinner:Landroid/widget/Spinner;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getDefaultAllowedPos()I

    move-result v3

    invoke-virtual {v2, v3}, Landroid/widget/Spinner;->setSelection(I)V

    .line 282
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mContext:Landroid/content/Context;

    const v4, 0x7f05036c

    invoke-virtual {v3, v4}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->showWarning(Ljava/lang/String;)V

    goto :goto_0

    .line 288
    :cond_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    check-cast v2, Lcom/esmertec/android/jbed/ams/AmsClient;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-static {v3}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Ljava/util/List;

    move-result-object v3

    iget v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$position:I

    invoke-interface {v3, v4}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-byte v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mIndex:B

    invoke-virtual {v1}, Ljava/lang/Byte;->byteValue()B

    move-result v4

    invoke-virtual {v2, v3, v4}, Lcom/esmertec/android/jbed/ams/AmsClient;->checkPermissionAnswer(BB)Ljava/util/Map$Entry;

    move-result-object v0

    .line 290
    .local v0, "result":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/String;>;"
    invoke-interface {v0}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/Integer;

    invoke-virtual {v2}, Ljava/lang/Integer;->intValue()I

    move-result v2

    packed-switch v2, :pswitch_data_0

    .line 303
    :pswitch_0
    new-instance v2, Ljava/lang/IllegalArgumentException;

    const-string v3, "PermissionItemAdapter unkonw return value"

    invoke-direct {v2, v3}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 292
    :pswitch_1
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$spinner:Landroid/widget/Spinner;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->getDefaultAllowedPos()I

    move-result v3

    invoke-virtual {v2, v3}, Landroid/widget/Spinner;->setSelection(I)V

    .line 293
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    check-cast p0, Ljava/lang/String;

    invoke-virtual {v2, p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->showError(Ljava/lang/String;)V

    goto/16 :goto_0

    .line 296
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    :pswitch_2
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v1}, Ljava/lang/Byte;->byteValue()B

    move-result v3

    iput-byte v3, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mCurrentAllowed:B

    .line 297
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->this$1:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-interface {v0}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    check-cast p0, Ljava/lang/String;

    invoke-virtual {v2, p0}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->showWarning(Ljava/lang/String;)V

    goto/16 :goto_0

    .line 300
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;
    :pswitch_3
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;->val$item:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v1}, Ljava/lang/Byte;->byteValue()B

    move-result v3

    iput-byte v3, v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->mCurrentAllowed:B

    goto/16 :goto_0

    .line 290
    nop

    :pswitch_data_0
    .packed-switch 0x1
        :pswitch_3
        :pswitch_0
        :pswitch_0
        :pswitch_0
        :pswitch_2
        :pswitch_1
    .end packed-switch
.end method

.method public onNothingSelected(Landroid/widget/AdapterView;)V
    .locals 0
    .param p1, "arg0"    # Landroid/widget/AdapterView;

    .prologue
    .line 309
    return-void
.end method
