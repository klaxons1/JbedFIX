.class Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;
.super Landroid/widget/ArrayAdapter;
.source "PermissionEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "PermissionItemAdapter"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroid/widget/ArrayAdapter",
        "<",
        "Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;",
        ">;"
    }
.end annotation


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;


# direct methods
.method public constructor <init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;Ljava/util/List;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 251
    .local p2, "permissions":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;>;"
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    .line 252
    iget-object v0, p1, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->mContext:Landroid/content/Context;

    const/4 v1, -0x1

    invoke-direct {p0, v0, v1, p2}, Landroid/widget/ArrayAdapter;-><init>(Landroid/content/Context;ILjava/util/List;)V

    .line 253
    return-void
.end method


# virtual methods
.method public getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
    .locals 7
    .param p1, "position"    # I
    .param p2, "convertView"    # Landroid/view/View;
    .param p3, "parent"    # Landroid/view/ViewGroup;

    .prologue
    .line 257
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-static {v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->access$000(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Landroid/view/LayoutInflater;

    move-result-object v4

    const v5, 0x7f030008

    const/4 v6, 0x0

    invoke-virtual {v4, v5, p3, v6}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;Z)Landroid/view/View;

    move-result-object v1

    check-cast v1, Landroid/widget/LinearLayout;

    .line 259
    .local v1, "layout":Landroid/widget/LinearLayout;
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-static {v4}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;->access$100(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;)Ljava/util/List;

    move-result-object v4

    invoke-interface {v4, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;

    .line 261
    .local v0, "item":Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;
    const v4, 0x7f08001b

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v3

    check-cast v3, Landroid/widget/TextView;

    .line 262
    .local v3, "text":Landroid/widget/TextView;
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mTypeText:Ljava/lang/String;

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 264
    const v4, 0x7f08001c

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v3

    .end local v3    # "text":Landroid/widget/TextView;
    check-cast v3, Landroid/widget/TextView;

    .line 265
    .restart local v3    # "text":Landroid/widget/TextView;
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mLabel:Ljava/lang/String;

    invoke-virtual {v3, v4}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 268
    const v4, 0x7f08001d

    invoke-virtual {v1, v4}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/Spinner;

    .line 269
    .local v2, "spinner":Landroid/widget/Spinner;
    iget-object v4, v0, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;->mBuilder:Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;

    invoke-virtual {v4, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionBuilder;->bindToSpinner(Landroid/widget/Spinner;)V

    .line 271
    new-instance v4, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;

    invoke-direct {v4, p0, v0, p1, v2}, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter$1;-><init>(Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$PermissionItemAdapter;Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler$FgPermission;ILandroid/widget/Spinner;)V

    invoke-virtual {v2, v4}, Landroid/widget/Spinner;->setOnItemSelectedListener(Landroid/widget/AdapterView$OnItemSelectedListener;)V

    .line 312
    return-object v1
.end method
