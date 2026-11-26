.class Lcom/esmertec/android/jbed/ams/AmsActivity$3;
.super Ljava/lang/Object;
.source "AmsActivity.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemSelectedListener;


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
    .line 241
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public onItemSelected(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 7
    .param p2, "layout"    # Landroid/view/View;
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
    .local p1, "adapterView":Landroid/widget/AdapterView;, "Landroid/widget/AdapterView<*>;"
    const v5, 0x7f080012

    const-string v6, "AmsActivity"

    .line 245
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/ListView;->getAdapter()Landroid/widget/ListAdapter;

    move-result-object v3

    invoke-interface {v3}, Landroid/widget/ListAdapter;->getCount()I

    move-result v3

    if-ge v1, v3, :cond_0

    .line 246
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3}, Landroid/widget/ListView;->getAdapter()Landroid/widget/ListAdapter;

    move-result-object v3

    invoke-interface {v3, v1}, Landroid/widget/ListAdapter;->getItem(I)Ljava/lang/Object;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-ne v3, v4, :cond_2

    .line 248
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3, v1}, Landroid/widget/ListView;->getChildAt(I)Landroid/view/View;

    move-result-object v3

    if-nez v3, :cond_1

    .line 256
    :cond_0
    :goto_1
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3, p3}, Landroid/widget/ListView;->getItemAtPosition(I)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    check-cast v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iput-object v3, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 258
    if-eqz p2, :cond_3

    invoke-virtual {p2, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v3

    if-eqz v3, :cond_3

    .line 259
    invoke-virtual {p2, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    .line 260
    .local v0, "curTextView":Landroid/widget/TextView;
    sget-object v3, Landroid/text/TextUtils$TruncateAt;->MARQUEE:Landroid/text/TextUtils$TruncateAt;

    invoke-virtual {v0, v3}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    .line 265
    .end local v0    # "curTextView":Landroid/widget/TextView;
    :goto_2
    const-string v3, "AmsActivity"

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "onItemSelected selected "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    iget-object v4, v4, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-static {v6, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 266
    return-void

    .line 251
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/AmsActivity$3;->this$0:Lcom/esmertec/android/jbed/ams/AmsActivity;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsActivity;->getListView()Landroid/widget/ListView;

    move-result-object v3

    invoke-virtual {v3, v1}, Landroid/widget/ListView;->getChildAt(I)Landroid/view/View;

    move-result-object v3

    invoke-virtual {v3, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v2

    check-cast v2, Landroid/widget/TextView;

    .line 252
    .local v2, "lastTextView":Landroid/widget/TextView;
    sget-object v3, Landroid/text/TextUtils$TruncateAt;->END:Landroid/text/TextUtils$TruncateAt;

    invoke-virtual {v2, v3}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    goto :goto_1

    .line 245
    .end local v2    # "lastTextView":Landroid/widget/TextView;
    :cond_2
    add-int/lit8 v1, v1, 0x1

    goto/16 :goto_0

    .line 263
    :cond_3
    const-string v3, "AmsActivity"

    const-string v3, "onItemSelected curTextView is not set"

    invoke-static {v6, v3}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    goto :goto_2
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
    .line 269
    .local p1, "adapterView":Landroid/widget/AdapterView;, "Landroid/widget/AdapterView<*>;"
    const-string v0, "AmsActivity"

    const-string v1, "onNothingSelected have nothing to selected!! "

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 270
    return-void
.end method
