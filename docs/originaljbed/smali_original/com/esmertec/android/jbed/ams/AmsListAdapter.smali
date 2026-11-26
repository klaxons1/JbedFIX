.class Lcom/esmertec/android/jbed/ams/AmsListAdapter;
.super Landroid/widget/BaseAdapter;
.source "AmsActivity.java"


# instance fields
.field private mContext:Landroid/content/Context;

.field private mInflater:Landroid/view/LayoutInflater;

.field mList:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public constructor <init>(Landroid/content/Context;)V
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 1254
    invoke-direct {p0}, Landroid/widget/BaseAdapter;-><init>()V

    .line 1255
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    .line 1256
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    const-string v1, "layout_inflater"

    invoke-virtual {v0, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Landroid/view/LayoutInflater;

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mInflater:Landroid/view/LayoutInflater;

    .line 1257
    return-void
.end method


# virtual methods
.method public getCount()I
    .locals 1

    .prologue
    .line 1260
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    return v0
.end method

.method public getItem(I)Ljava/lang/Object;
    .locals 1
    .param p1, "position"    # I

    .prologue
    .line 1264
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v0

    return-object v0
.end method

.method public getItemId(I)J
    .locals 2
    .param p1, "position"    # I

    .prologue
    .line 1268
    int-to-long v0, p1

    return-wide v0
.end method

.method public getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
    .locals 18
    .param p1, "position"    # I
    .param p2, "convertView"    # Landroid/view/View;
    .param p3, "parent"    # Landroid/view/ViewGroup;

    .prologue
    .line 1272
    const/4 v10, 0x0

    .line 1273
    .local v10, "layout":Landroid/widget/LinearLayout;
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mList:Ljava/util/List;

    move-object v15, v0

    move-object v0, v15

    move/from16 v1, p1

    invoke-interface {v0, v1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 1275
    .local v4, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v15

    if-eqz v15, :cond_3

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v15

    if-eqz v15, :cond_3

    .line 1277
    iget-object v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v15}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v6

    .local v6, "i$":Ljava/util/Iterator;
    :cond_0
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v15

    if-eqz v15, :cond_1

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v11

    check-cast v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 1278
    .local v11, "mChildren":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-boolean v15, v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    if-eqz v15, :cond_0

    .line 1279
    const/4 v15, 0x1

    iput-boolean v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    .line 1283
    .end local v11    # "mChildren":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    iget-object v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v15}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :cond_2
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v15

    if-eqz v15, :cond_3

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v11

    check-cast v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 1284
    .restart local v11    # "mChildren":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-boolean v15, v11, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    if-eqz v15, :cond_2

    .line 1285
    const/4 v15, 0x1

    iput-boolean v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 1312
    .end local v6    # "i$":Ljava/util/Iterator;
    .end local v11    # "mChildren":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_3
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mInflater:Landroid/view/LayoutInflater;

    move-object v15, v0

    const v16, 0x7f030006

    const/16 v17, 0x0

    move-object v0, v15

    move/from16 v1, v16

    move-object/from16 v2, p3

    move/from16 v3, v17

    invoke-virtual {v0, v1, v2, v3}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;Z)Landroid/view/View;

    move-result-object v10

    .end local v10    # "layout":Landroid/widget/LinearLayout;
    check-cast v10, Landroid/widget/LinearLayout;

    .line 1313
    .restart local v10    # "layout":Landroid/widget/LinearLayout;
    iget-boolean v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    if-eqz v15, :cond_4

    .line 1314
    const v15, 0x7f080016

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    .line 1319
    :cond_4
    const v15, 0x7f080012

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v13

    check-cast v13, Landroid/widget/TextView;

    .line 1320
    .local v13, "text":Landroid/widget/TextView;
    const v15, 0x7f080015

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v14

    check-cast v14, Landroid/widget/TextView;

    .line 1321
    .local v14, "vendor":Landroid/widget/TextView;
    const v15, 0x7f080019

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v12

    check-cast v12, Landroid/widget/TextView;

    .line 1322
    .local v12, "size":Landroid/widget/TextView;
    const v15, 0x7f08001a

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v9

    check-cast v9, Landroid/widget/TextView;

    .line 1323
    .local v9, "installDate":Landroid/widget/TextView;
    const v15, 0x7f080011

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v8

    check-cast v8, Landroid/widget/ImageView;

    .line 1325
    .local v8, "icon":Landroid/widget/ImageView;
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v15

    if-eqz v15, :cond_5

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v15

    if-eqz v15, :cond_8

    iget-object v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v15}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v15

    const/16 v16, 0x1

    move v0, v15

    move/from16 v1, v16

    if-ne v0, v1, :cond_8

    .line 1326
    :cond_5
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$ListItem;->isVendorDisabled()Z

    move-result v15

    if-nez v15, :cond_6

    .line 1327
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getVendorText()Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v14, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 1329
    :cond_6
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$ListItem;->isSizeDisabled()Z

    move-result v15

    if-nez v15, :cond_7

    .line 1330
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object v15, v0

    invoke-virtual {v4, v15}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeText(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v12, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 1332
    :cond_7
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$ListItem;->isDateDisabled()Z

    move-result v15

    if-nez v15, :cond_8

    .line 1333
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInstallTimeText()Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v9, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 1338
    :cond_8
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object/from16 p1, v0

    .end local p1    # "position":I
    check-cast p1, Lcom/esmertec/android/jbed/ams/AmsActivity;

    move-object/from16 v0, p1

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsActivity;->mCurSelectedItem:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v15, v0

    if-ne v4, v15, :cond_d

    .line 1339
    sget-object v15, Landroid/text/TextUtils$TruncateAt;->MARQUEE:Landroid/text/TextUtils$TruncateAt;

    invoke-virtual {v13, v15}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    .line 1343
    :goto_0
    const/4 v7, 0x0

    .line 1344
    .local v7, "i18nString":Ljava/lang/String;
    new-instance v5, Lcom/esmertec/android/jbed/ams/FolderNameI18N;

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object v15, v0

    invoke-direct {v5, v15}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;-><init>(Landroid/content/Context;)V

    .line 1345
    .local v5, "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    const-string v16, "Download Games"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_e

    .line 1346
    const/4 v15, 0x1

    invoke-virtual {v5, v15}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v7

    .line 1353
    :cond_9
    :goto_1
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    const-string v16, "Download Games"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    if-nez v15, :cond_a

    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    const-string v16, "Download Applications"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_f

    .line 1354
    :cond_a
    invoke-virtual {v13, v7}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 1361
    :goto_2
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v15

    if-eqz v15, :cond_13

    .line 1362
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v15

    if-eqz v15, :cond_12

    .line 1363
    iget-boolean v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    if-eqz v15, :cond_11

    .line 1364
    const v15, 0x7f020004

    invoke-virtual {v8, v15}, Landroid/widget/ImageView;->setBackgroundResource(I)V

    .line 1379
    :goto_3
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmPending()Z

    move-result v15

    if-eqz v15, :cond_15

    .line 1380
    const v15, 0x7f080018

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    .line 1393
    :cond_b
    :goto_4
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isOnSdcard()Z

    move-result v15

    if-eqz v15, :cond_c

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v15

    if-eqz v15, :cond_c

    .line 1394
    const v15, 0x7f080013

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    .line 1397
    :cond_c
    return-object v10

    .line 1341
    .end local v5    # "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    .end local v7    # "i18nString":Ljava/lang/String;
    :cond_d
    sget-object v15, Landroid/text/TextUtils$TruncateAt;->END:Landroid/text/TextUtils$TruncateAt;

    invoke-virtual {v13, v15}, Landroid/widget/TextView;->setEllipsize(Landroid/text/TextUtils$TruncateAt;)V

    goto :goto_0

    .line 1348
    .restart local v5    # "folderNameI18N":Lcom/esmertec/android/jbed/ams/FolderNameI18N;
    .restart local v7    # "i18nString":Ljava/lang/String;
    :cond_e
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    const-string v16, "Download Applications"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_9

    .line 1349
    const/4 v15, 0x2

    invoke-virtual {v5, v15}, Lcom/esmertec/android/jbed/ams/FolderNameI18N;->getI18NStrings(I)Ljava/lang/String;

    move-result-object v7

    goto :goto_1

    .line 1355
    :cond_f
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    const-string v16, "sdcard"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_10

    .line 1356
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object v15, v0

    const v16, 0x7f05037c

    invoke-virtual/range {v15 .. v16}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v13, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    goto :goto_2

    .line 1358
    :cond_10
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getNameText()Ljava/lang/String;

    move-result-object v15

    invoke-virtual {v13, v15}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    goto :goto_2

    .line 1366
    :cond_11
    const v15, 0x7f020002

    invoke-virtual {v8, v15}, Landroid/widget/ImageView;->setBackgroundResource(I)V

    goto :goto_3

    .line 1368
    :cond_12
    const v15, 0x7f020003

    invoke-virtual {v8, v15}, Landroid/widget/ImageView;->setBackgroundResource(I)V

    goto :goto_3

    .line 1371
    :cond_13
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object v15, v0

    invoke-virtual {v4, v15}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getIcon(Landroid/content/Context;)Landroid/graphics/drawable/Drawable;

    move-result-object v15

    if-eqz v15, :cond_14

    .line 1372
    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/AmsListAdapter;->mContext:Landroid/content/Context;

    move-object v15, v0

    invoke-virtual {v4, v15}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getIcon(Landroid/content/Context;)Landroid/graphics/drawable/Drawable;

    move-result-object v15

    invoke-virtual {v8, v15}, Landroid/widget/ImageView;->setImageDrawable(Landroid/graphics/drawable/Drawable;)V

    goto/16 :goto_3

    .line 1375
    :cond_14
    const v15, 0x7f020001

    invoke-virtual {v8, v15}, Landroid/widget/ImageView;->setBackgroundResource(I)V

    goto/16 :goto_3

    .line 1381
    :cond_15
    invoke-virtual {v4}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isDrmProtected()Z

    move-result v15

    if-eqz v15, :cond_b

    .line 1382
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isUsingSpecialIcon()Z

    move-result v15

    if-eqz v15, :cond_16

    .line 1383
    const v15, 0x7f080014

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    goto/16 :goto_4

    .line 1385
    :cond_16
    iget-boolean v15, v4, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsExpired:Z

    if-eqz v15, :cond_17

    .line 1386
    const/high16 v15, 0x1010000

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    goto/16 :goto_4

    .line 1388
    :cond_17
    const v15, 0x7f080017

    invoke-virtual {v10, v15}, Landroid/widget/LinearLayout;->findViewById(I)Landroid/view/View;

    move-result-object v15

    const/16 v16, 0x0

    invoke-virtual/range {v15 .. v16}, Landroid/view/View;->setVisibility(I)V

    goto/16 :goto_4
.end method
