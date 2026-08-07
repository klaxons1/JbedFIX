.class Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
.super Landroid/widget/ArrayAdapter;
.source "BasicEventHandler.java"

# interfaces
.implements Landroid/widget/AdapterView$OnItemClickListener;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = "CertificatesItemAdapter"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Landroid/widget/ArrayAdapter",
        "<",
        "Ljava/lang/String;",
        ">;",
        "Landroid/widget/AdapterView$OnItemClickListener;"
    }
.end annotation


# static fields
.field public static final DELIMITER:Ljava/lang/String; = "\n"


# instance fields
.field final synthetic this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;


# direct methods
.method private constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;Ljava/util/List;)V
    .locals 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List",
            "<",
            "Ljava/lang/String;",
            ">;)V"
        }
    .end annotation

    .prologue
    .line 1512
    .local p2, "subjects":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    .line 1513
    iget-object v0, p1, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->mContext:Landroid/content/Context;

    const/4 v1, -0x1

    invoke-direct {p0, v0, v1, p2}, Landroid/widget/ArrayAdapter;-><init>(Landroid/content/Context;ILjava/util/List;)V

    .line 1514
    return-void
.end method

.method synthetic constructor <init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;Ljava/util/List;Lcom/esmertec/android/jbed/ams/BasicEventHandler$1;)V
    .locals 0
    .param p1, "x0"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;
    .param p2, "x1"    # Ljava/util/List;
    .param p3, "x2"    # Lcom/esmertec/android/jbed/ams/BasicEventHandler$1;

    .prologue
    .line 1508
    invoke-direct {p0, p1, p2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;-><init>(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;Ljava/util/List;)V

    return-void
.end method


# virtual methods
.method public getView(ILandroid/view/View;Landroid/view/ViewGroup;)Landroid/view/View;
    .locals 5
    .param p1, "position"    # I
    .param p2, "convertView"    # Landroid/view/View;
    .param p3, "parent"    # Landroid/view/ViewGroup;

    .prologue
    .line 1518
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1200(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Landroid/view/LayoutInflater;

    move-result-object v2

    const v3, 0x7f03000c

    const/4 v4, 0x0

    invoke-virtual {v2, v3, v4}, Landroid/view/LayoutInflater;->inflate(ILandroid/view/ViewGroup;)Landroid/view/View;

    move-result-object v1

    .line 1519
    .local v1, "view":Landroid/view/View;
    const v2, 0x7f080024

    invoke-virtual {v1, v2}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object v0

    check-cast v0, Landroid/widget/TextView;

    .line 1520
    .local v0, "text":Landroid/widget/TextView;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v2}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1300(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    check-cast p0, Ljava/lang/CharSequence;

    invoke-virtual {v0, p0}, Landroid/widget/TextView;->setText(Ljava/lang/CharSequence;)V

    .line 1521
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 1522
    new-instance v2, Landroid/widget/AbsListView$LayoutParams;

    const/4 v3, -0x1

    const/16 v4, 0x40

    invoke-direct {v2, v3, v4}, Landroid/widget/AbsListView$LayoutParams;-><init>(II)V

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setLayoutParams(Landroid/view/ViewGroup$LayoutParams;)V

    .line 1524
    const/16 v2, 0x10

    invoke-virtual {v0, v2}, Landroid/widget/TextView;->setGravity(I)V

    .line 1526
    :cond_0
    return-object v1
.end method

.method public onItemClick(Landroid/widget/AdapterView;Landroid/view/View;IJ)V
    .locals 6
    .param p1, "parent"    # Landroid/widget/AdapterView;
    .param p2, "view"    # Landroid/view/View;
    .param p3, "position"    # I
    .param p4, "id"    # J

    .prologue
    const v5, 0x7f080024

    const-string v4, "\n\n"

    const-string v3, "\n"

    .line 1531
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v1

    if-nez v1, :cond_0

    .line 1547
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    :goto_0
    return-void

    .line 1535
    .restart local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    :cond_0
    new-instance v0, Ljava/lang/StringBuffer;

    invoke-direct {v0}, Ljava/lang/StringBuffer;-><init>()V

    .line 1536
    .local v0, "mInfo":Ljava/lang/StringBuffer;
    const-string v1, "Issuer"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v2

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1700(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1, p3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n\n"

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "Subject"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v2

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1600(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1, p3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n\n"

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "Due Date"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v2

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1500(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1, p3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n\n"

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "Fingerprint"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v2

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->this$0:Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-static {v1}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;->access$1400(Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1, p3}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    invoke-virtual {v2, v1}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    move-result-object v1

    const-string v2, "\n\n"

    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 1541
    new-instance v1, Landroid/app/AlertDialog$Builder;

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;->getContext()Landroid/content/Context;

    move-result-object v2

    invoke-direct {v1, v2}, Landroid/app/AlertDialog$Builder;-><init>(Landroid/content/Context;)V

    invoke-virtual {v1, v0}, Landroid/app/AlertDialog$Builder;->setMessage(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const v2, 0x104000a

    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsEventHandler;->defaultDismissListener:Landroid/content/DialogInterface$OnClickListener;

    invoke-virtual {v1, v2, v3}, Landroid/app/AlertDialog$Builder;->setNeutralButton(ILandroid/content/DialogInterface$OnClickListener;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    const/high16 v2, 0x7f020000

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setIcon(I)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {p2, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler$CertificatesItemAdapter;
    check-cast p0, Landroid/widget/TextView;

    invoke-virtual {p0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;

    move-result-object v2

    const/4 v3, 0x3

    invoke-virtual {p2, v5}, Landroid/view/View;->findViewById(I)Landroid/view/View;

    move-result-object p0

    check-cast p0, Landroid/widget/TextView;

    invoke-virtual {p0}, Landroid/widget/TextView;->getText()Ljava/lang/CharSequence;

    move-result-object v4

    invoke-interface {v4}, Ljava/lang/CharSequence;->length()I

    move-result v4

    invoke-interface {v2, v3, v4}, Ljava/lang/CharSequence;->subSequence(II)Ljava/lang/CharSequence;

    move-result-object v2

    invoke-virtual {v1, v2}, Landroid/app/AlertDialog$Builder;->setTitle(Ljava/lang/CharSequence;)Landroid/app/AlertDialog$Builder;

    move-result-object v1

    invoke-virtual {v1}, Landroid/app/AlertDialog$Builder;->show()Landroid/app/AlertDialog;

    goto/16 :goto_0
.end method
