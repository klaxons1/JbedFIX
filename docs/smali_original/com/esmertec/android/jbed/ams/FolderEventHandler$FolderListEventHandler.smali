.class public Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;
.super Lcom/esmertec/android/jbed/ams/AmsEventHandler;
.source "FolderEventHandler.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/FolderEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x9
    name = "FolderListEventHandler"
.end annotation


# static fields
.field private static final TAG:Ljava/lang/String; = "FolderListEventHandler"

.field private static folderListDialog:Landroid/app/AlertDialog;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 144
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->folderListDialog:Landroid/app/AlertDialog;

    return-void
.end method

.method public constructor <init>()V
    .locals 0

    .prologue
    .line 142
    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/AmsEventHandler;-><init>()V

    return-void
.end method

.method static synthetic access$000(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;I)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;
    .param p1, "x1"    # I

    .prologue
    .line 142
    invoke-direct {p0, p1}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->showMoveResult(I)V

    return-void
.end method

.method public static dismissDialog()V
    .locals 3

    .prologue
    .line 166
    :try_start_0
    sget-object v1, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->folderListDialog:Landroid/app/AlertDialog;

    if-eqz v1, :cond_0

    .line 167
    sget-object v1, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->folderListDialog:Landroid/app/AlertDialog;

    invoke-virtual {v1}, Landroid/app/AlertDialog;->dismiss()V
    :try_end_0
    .catch Ljava/lang/Exception; {:try_start_0 .. :try_end_0} :catch_0

    .line 177
    :cond_0
    :goto_0
    return-void

    .line 168
    :catch_0
    move-exception v1

    move-object v0, v1

    .line 175
    .local v0, "e":Ljava/lang/Exception;
    const-string v1, "FolderListEventHandler"

    const-string v2, "ignore exception in dismissDialog()"

    invoke-static {v1, v2, v0}, Landroid/util/Log;->w(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    goto :goto_0
.end method

.method private showMoveResult(I)V
    .locals 3
    .param p1, "result"    # I

    .prologue
    .line 147
    const-string v0, ""

    .line 148
    .local v0, "msg":Ljava/lang/String;
    sparse-switch p1, :sswitch_data_0

    .line 159
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "RemoveEventHandler unknown result value"

    invoke-direct {v1, v2}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1

    .line 150
    :sswitch_0
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e5

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 161
    :goto_0
    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->showToast(Ljava/lang/String;)V

    .line 162
    return-void

    .line 153
    :sswitch_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mContext:Landroid/content/Context;

    const v2, 0x7f0501e8

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 154
    goto :goto_0

    .line 156
    :sswitch_2
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mEvent:Lcom/esmertec/android/jbed/ams/AmsEvent;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsEvent;->getDataAsUtf8()Ljava/lang/String;

    move-result-object v0

    .line 157
    goto :goto_0

    .line 148
    nop

    :sswitch_data_0
    .sparse-switch
        0x1 -> :sswitch_0
        0x8 -> :sswitch_1
        0xf -> :sswitch_2
    .end sparse-switch
.end method


# virtual methods
.method public run()V
    .locals 8

    .prologue
    const/4 v5, 0x0

    const-string v7, "/"

    .line 181
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isMidletInFolderOnly()Z

    move-result v3

    if-nez v3, :cond_1

    const/4 v3, 0x1

    move v2, v3

    .line 182
    .local v2, "includeRoot":Z
    :goto_0
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v3

    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mClient:Lcom/esmertec/android/jbed/ams/AmsClientBase;

    invoke-virtual {v4, v5, v5, v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase;->getAllFolders(ZZZ)Ljava/util/List;

    move-result-object v4

    invoke-virtual {v3, v4}, Lcom/esmertec/android/jbed/ams/JbedSelector;->toFolderCharSequences(Ljava/util/List;)[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    move-result-object v0

    .line 186
    .local v0, "folders":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    array-length v3, v0

    if-ge v1, v3, :cond_4

    .line 187
    aget-object v3, v0, v1

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "/Applications"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_2

    .line 188
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f050388

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    aget-object v5, v0, v1

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v3, v0, v1

    .line 186
    :cond_0
    :goto_2
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .end local v0    # "folders":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .end local v1    # "i":I
    .end local v2    # "includeRoot":Z
    :cond_1
    move v2, v5

    .line 181
    goto :goto_0

    .line 189
    .restart local v0    # "folders":[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    .restart local v1    # "i":I
    .restart local v2    # "includeRoot":Z
    :cond_2
    aget-object v3, v0, v1

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "/Games"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_3

    .line 190
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f050387

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    aget-object v5, v0, v1

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v3, v0, v1

    goto :goto_2

    .line 191
    :cond_3
    aget-object v3, v0, v1

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->toString()Ljava/lang/String;

    move-result-object v3

    const-string v4, "/sdcard"

    invoke-virtual {v3, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_0

    .line 192
    new-instance v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/"

    invoke-virtual {v4, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->mContext:Landroid/content/Context;

    const v6, 0x7f05037c

    invoke-virtual {v5, v6}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    aget-object v5, v0, v1

    iget-object v5, v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;->mData:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v3, v4, v5}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;-><init>(Ljava/lang/String;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    aput-object v3, v0, v1

    goto :goto_2

    .line 199
    :cond_4
    new-instance v3, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->getContext()Landroid/content/Context;

    move-result-object v4

    invoke-direct {v3, v4}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    const v4, 0x7f0500b9

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setTitle(I)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;

    invoke-direct {v4, p0, v0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$3;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;[Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;)V

    invoke-virtual {v3, v0, v4}, Landroid/app/AlertDialog$Builder;->setItems([Ljava/lang/CharSequence;Landroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    new-instance v4, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$2;

    invoke-direct {v4, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$2;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;)V

    invoke-virtual {v3, v4}, Landroid/app/AlertDialog$Builder;->setOnCancelListener(Landroid/content/DialogInterface$OnCancelListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    const/high16 v4, 0x1040000

    new-instance v5, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;

    invoke-direct {v5, p0}, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler$1;-><init>(Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;)V

    invoke-virtual {v3, v4, v5}, Landroid/app/AlertDialog$Builder;->setNegativeButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v3

    invoke-virtual {v3}, Landroid/app/AlertDialog$Builder;->create()Landroid/app/AlertDialog;

    move-result-object v3

    sput-object v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->folderListDialog:Landroid/app/AlertDialog;

    .line 227
    sget-object v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;->folderListDialog:Landroid/app/AlertDialog;

    invoke-virtual {v3}, Landroid/app/AlertDialog;->show()V

    .line 228
    return-void
.end method
