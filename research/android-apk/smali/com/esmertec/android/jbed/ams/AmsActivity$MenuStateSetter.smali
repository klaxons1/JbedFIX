.class Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;
.super Ljava/lang/Object;
.source "AmsActivity.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsActivity;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0xa
    name = "MenuStateSetter"
.end annotation


# static fields
.field private static final ALL:I = 0x610

.field private static final DISABLE_IF_IS_RUNNING:I = 0x8000

.field private static final DISABLE_IF_NONE_SUITES:I = 0x100000

.field private static final ENABLE_ALL:I = 0x10

.field private static final ENABLE_FOLDER:I = 0x4

.field private static final ENABLE_MIDLET:I = 0x2

.field private static final ENABLE_REMOVABLE_ONLY:I = 0x20

.field private static final ENABLE_SUITE:I = 0x8

.field private static final INVISIBLE_IF_CANT_REMOVE_ON_CONTEXTMENU:I = 0x1000

.field private static final INVISIBLE_IF_IS_MIDLET_IN_SUITE:I = 0x4000

.field private static final INVISIBLE_IF_IS_RUNNING_ON_CONTEXTMENU:I = 0x2000

.field private static final TOP_ALL:I = 0x210

.field private static final VISIBLE_ALL_LEVEL:I = 0x600

.field private static final VISIBLE_SUB_LEVEL_ONLY:I = 0x400

.field private static final VISIBLE_SUB_LEVEL_ON_CONTEXTMENU_ONLY:I = 0x800

.field private static final VISIBLE_TOP_LEVEL_ONLY:I = 0x200

.field private static menuItemFlagMap:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .locals 8

    .prologue
    const/16 v7, 0x410

    const/16 v6, 0x4610

    const/16 v5, 0x608

    const/16 v4, 0x210

    const/16 v3, 0x610

    .line 1012
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    .line 1016
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080035

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1019
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080049

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x62c

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1022
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004c

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x62c

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1025
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080036

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1026
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080037

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1027
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1028
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1029
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003c

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1030
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1031
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080042

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x100210

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1033
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isReconfigEnable()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 1035
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x107410

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1037
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080039

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x107410

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1041
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x4808

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1042
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x408

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1043
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x5808

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1047
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x4802

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1050
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080040

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v7}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1052
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080043

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x4410

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1054
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080050

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const/16 v2, 0x4810

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1056
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1058
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1060
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080038

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v6}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1086
    :goto_0
    return-void

    .line 1063
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x100610

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1064
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080039

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x100610

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1067
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1068
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1069
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1072
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08004b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const v2, 0x8602

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1075
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080040

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1077
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080043

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1079
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v4}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1081
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f08003e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 1083
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    const v1, 0x7f080038

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-interface {v0, v1, v2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto/16 :goto_0
.end method

.method private constructor <init>()V
    .locals 0

    .prologue
    .line 976
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method static synthetic access$600(Landroid/view/Menu;)V
    .locals 0
    .param p0, "x0"    # Landroid/view/Menu;

    .prologue
    .line 976
    invoke-static {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->reset(Landroid/view/Menu;)V

    return-void
.end method

.method static synthetic access$700(Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/view/Menu;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V
    .locals 0
    .param p0, "x0"    # Lcom/esmertec/android/jbed/ams/AmsClient;
    .param p1, "x1"    # Landroid/view/Menu;
    .param p2, "x2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p3, "x3"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p4, "x4"    # Z

    .prologue
    .line 976
    invoke-static {p0, p1, p2, p3, p4}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->setState(Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/view/Menu;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V

    return-void
.end method

.method private static isEnabled(Lcom/esmertec/android/jbed/ams/AmsClient;ILcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Z
    .locals 4
    .param p0, "amsClient"    # Lcom/esmertec/android/jbed/ams/AmsClient;
    .param p1, "itemFlag"    # I
    .param p2, "curParent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p3, "selectedItem"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 1101
    and-int/lit8 v1, p1, 0x20

    if-eqz v1, :cond_1

    if-eqz p3, :cond_0

    invoke-virtual {p3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isRemovable()Z

    move-result v1

    if-nez v1, :cond_1

    :cond_0
    move v1, v2

    .line 1134
    :goto_0
    return v1

    .line 1106
    :cond_1
    const/high16 v1, 0x100000

    and-int/2addr v1, p1

    if-eqz v1, :cond_2

    const/4 v1, 0x0

    invoke-virtual {p0, v1, v2, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->size()I

    move-result v1

    if-nez v1, :cond_2

    move v1, v2

    .line 1107
    goto :goto_0

    .line 1111
    :cond_2
    const v1, 0x8000

    and-int/2addr v1, p1

    if-eqz v1, :cond_3

    iget-boolean v1, p3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    if-eqz v1, :cond_3

    move v1, v2

    .line 1112
    goto :goto_0

    .line 1115
    :cond_3
    and-int/lit8 v1, p1, 0x10

    if-eqz v1, :cond_4

    move v1, v3

    .line 1116
    goto :goto_0

    .line 1118
    :cond_4
    and-int/lit8 v1, p1, 0x2

    if-eqz v1, :cond_5

    if-eqz p3, :cond_5

    invoke-virtual {p3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v1

    if-eqz v1, :cond_5

    move v1, v3

    .line 1119
    goto :goto_0

    .line 1121
    :cond_5
    move-object v0, p3

    .line 1124
    .local v0, "data":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eqz v0, :cond_6

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v1

    if-eqz v1, :cond_6

    iget-object v1, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getChildCount()I

    move-result v1

    if-ne v1, v3, :cond_6

    .line 1125
    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 1127
    :cond_6
    and-int/lit8 v1, p1, 0x4

    if-eqz v1, :cond_7

    if-eqz v0, :cond_7

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v1

    if-eqz v1, :cond_7

    move v1, v3

    .line 1128
    goto :goto_0

    .line 1130
    :cond_7
    and-int/lit8 v1, p1, 0x8

    if-eqz v1, :cond_8

    if-eqz v0, :cond_8

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v1

    if-eqz v1, :cond_8

    move v1, v3

    .line 1131
    goto :goto_0

    :cond_8
    move v1, v2

    .line 1134
    goto :goto_0
.end method

.method private static isVisibleFromConfig(I)Z
    .locals 2
    .param p0, "itemKey"    # I

    .prologue
    const/4 v1, 0x0

    .line 1139
    const v0, 0x7f08004a

    if-ne p0, v0, :cond_0

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isMoveDisabled()Z

    move-result v0

    if-eqz v0, :cond_0

    move v0, v1

    .line 1199
    :goto_0
    return v0

    .line 1144
    :cond_0
    const v0, 0x7f080043

    if-ne p0, v0, :cond_1

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isSortDisabled()Z

    move-result v0

    if-eqz v0, :cond_1

    move v0, v1

    .line 1145
    goto :goto_0

    .line 1149
    :cond_1
    const v0, 0x7f080049

    if-ne p0, v0, :cond_2

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isRenameDisabled()Z

    move-result v0

    if-eqz v0, :cond_2

    move v0, v1

    .line 1150
    goto :goto_0

    .line 1154
    :cond_2
    const v0, 0x7f080039

    if-ne p0, v0, :cond_3

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isRemoveMultiEnabled()Z

    move-result v0

    if-nez v0, :cond_3

    move v0, v1

    .line 1155
    goto :goto_0

    .line 1159
    :cond_3
    const v0, 0x7f08003a

    if-ne p0, v0, :cond_4

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isCreateFolderDisabled()Z

    move-result v0

    if-eqz v0, :cond_4

    move v0, v1

    .line 1160
    goto :goto_0

    .line 1163
    :cond_4
    const v0, 0x7f08003e

    if-ne p0, v0, :cond_5

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isStorateSettingEnable()Z

    move-result v0

    if-nez v0, :cond_5

    move v0, v1

    .line 1164
    goto :goto_0

    .line 1167
    :cond_5
    const v0, 0x7f080037

    if-ne p0, v0, :cond_6

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isInstallDisabled()Z

    move-result v0

    if-eqz v0, :cond_6

    move v0, v1

    .line 1168
    goto :goto_0

    .line 1171
    :cond_6
    const v0, 0x7f08003c

    if-ne p0, v0, :cond_7

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isApnDisabled()Z

    move-result v0

    if-eqz v0, :cond_7

    move v0, v1

    .line 1172
    goto :goto_0

    .line 1175
    :cond_7
    const v0, 0x7f08003f

    if-ne p0, v0, :cond_8

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isAboutDisabled()Z

    move-result v0

    if-eqz v0, :cond_8

    move v0, v1

    .line 1176
    goto :goto_0

    .line 1179
    :cond_8
    const v0, 0x7f08004c

    if-ne p0, v0, :cond_9

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isRemoveDisabled()Z

    move-result v0

    if-eqz v0, :cond_9

    move v0, v1

    .line 1180
    goto :goto_0

    .line 1183
    :cond_9
    const v0, 0x7f080042

    if-ne p0, v0, :cond_a

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isRemoveAllDisabled()Z

    move-result v0

    if-eqz v0, :cond_a

    move v0, v1

    .line 1184
    goto/16 :goto_0

    .line 1187
    :cond_a
    const v0, 0x7f080035

    if-ne p0, v0, :cond_b

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isUpFolderDisabled()Z

    move-result v0

    if-eqz v0, :cond_b

    move v0, v1

    .line 1188
    goto/16 :goto_0

    .line 1191
    :cond_b
    const v0, 0x7f08004f

    if-ne p0, v0, :cond_c

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isUpdateDisabled()Z

    move-result v0

    if-eqz v0, :cond_c

    move v0, v1

    .line 1192
    goto/16 :goto_0

    .line 1195
    :cond_c
    const v0, 0x7f080040

    if-ne p0, v0, :cond_d

    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Menu;->isExitDisabled()Z

    move-result v0

    if-eqz v0, :cond_d

    move v0, v1

    .line 1196
    goto/16 :goto_0

    .line 1199
    :cond_d
    const/4 v0, 0x1

    goto/16 :goto_0
.end method

.method private static isVisibled(IILcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)Z
    .locals 3
    .param p0, "itemKey"    # I
    .param p1, "itemFlag"    # I
    .param p2, "curParent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p3, "selectedItem"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p4, "isContextMenu"    # Z

    .prologue
    const/4 v2, 0x1

    const/4 v1, 0x0

    .line 1204
    invoke-static {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->isVisibleFromConfig(I)Z

    move-result v0

    if-nez v0, :cond_0

    move v0, v1

    .line 1231
    :goto_0
    return v0

    .line 1208
    :cond_0
    and-int/lit16 v0, p1, 0x1000

    if-eqz v0, :cond_1

    if-eqz p2, :cond_1

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_1

    invoke-virtual {p3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isRemovable()Z

    move-result v0

    if-nez v0, :cond_1

    if-eqz p4, :cond_1

    move v0, v1

    .line 1209
    goto :goto_0

    .line 1212
    :cond_1
    and-int/lit16 v0, p1, 0x2000

    if-eqz v0, :cond_2

    if-eqz p2, :cond_2

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_2

    iget-boolean v0, p3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    if-eqz v0, :cond_2

    if-eqz p4, :cond_2

    move v0, v1

    .line 1213
    goto :goto_0

    .line 1216
    :cond_2
    and-int/lit16 v0, p1, 0x4000

    if-eqz v0, :cond_3

    if-eqz p2, :cond_3

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_3

    invoke-virtual {p2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v0

    if-eqz v0, :cond_3

    invoke-virtual {p3}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v0

    if-eqz v0, :cond_3

    move v0, v1

    .line 1217
    goto :goto_0

    .line 1220
    :cond_3
    and-int/lit16 v0, p1, 0x200

    if-eqz v0, :cond_5

    if-eqz p2, :cond_4

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-nez v0, :cond_5

    :cond_4
    move v0, v2

    .line 1221
    goto :goto_0

    .line 1223
    :cond_5
    and-int/lit16 v0, p1, 0x400

    if-eqz v0, :cond_6

    if-eqz p2, :cond_6

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_6

    move v0, v2

    .line 1224
    goto :goto_0

    .line 1226
    :cond_6
    and-int/lit16 v0, p1, 0x800

    if-eqz v0, :cond_7

    if-eqz p2, :cond_7

    iget-object v0, p2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_7

    if-eqz p4, :cond_7

    move v0, v2

    .line 1227
    goto :goto_0

    :cond_7
    move v0, v1

    .line 1231
    goto :goto_0
.end method

.method private static reset(Landroid/view/Menu;)V
    .locals 5
    .param p0, "menu"    # Landroid/view/Menu;

    .prologue
    const/4 v4, 0x1

    .line 1091
    sget-object v3, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    invoke-interface {v3}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v3

    invoke-interface {v3}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_0

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/Map$Entry;

    .line 1092
    .local v2, "menuItemFlag":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/Integer;>;"
    invoke-interface {v2}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Integer;

    invoke-virtual {v3}, Ljava/lang/Integer;->intValue()I

    move-result v3

    invoke-interface {p0, v3}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v1

    .line 1093
    .local v1, "item":Landroid/view/MenuItem;
    invoke-interface {v1, v4}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    .line 1094
    invoke-interface {v1, v4}, Landroid/view/MenuItem;->setVisible(Z)Landroid/view/MenuItem;

    goto :goto_0

    .line 1096
    .end local v1    # "item":Landroid/view/MenuItem;
    .end local v2    # "menuItemFlag":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/Integer;>;"
    :cond_0
    return-void
.end method

.method private static setState(Lcom/esmertec/android/jbed/ams/AmsClient;Landroid/view/Menu;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V
    .locals 7
    .param p0, "amsClient"    # Lcom/esmertec/android/jbed/ams/AmsClient;
    .param p1, "menu"    # Landroid/view/Menu;
    .param p2, "curParent"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p3, "selectedItem"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p4, "isContextMenu"    # Z

    .prologue
    const/4 v6, 0x1

    const/4 v5, 0x0

    .line 1235
    sget-object v4, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->menuItemFlagMap:Ljava/util/Map;

    invoke-interface {v4}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/util/Map$Entry;

    .line 1236
    .local v3, "menuItemFlag":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/Integer;>;"
    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v4

    invoke-interface {p1, v4}, Landroid/view/Menu;->findItem(I)Landroid/view/MenuItem;

    move-result-object v1

    .line 1237
    .local v1, "item":Landroid/view/MenuItem;
    invoke-interface {v3}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v2

    .line 1238
    .local v2, "itemFlag":I
    invoke-interface {v1}, Landroid/view/MenuItem;->isEnabled()Z

    move-result v4

    if-eqz v4, :cond_0

    if-eqz p0, :cond_0

    invoke-static {p0, v2, p2, p3}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->isEnabled(Lcom/esmertec/android/jbed/ams/AmsClient;ILcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)Z

    move-result v4

    if-eqz v4, :cond_0

    move v4, v6

    :goto_1
    invoke-interface {v1, v4}, Landroid/view/MenuItem;->setEnabled(Z)Landroid/view/MenuItem;

    .line 1239
    invoke-interface {v1}, Landroid/view/MenuItem;->isVisible()Z

    move-result v4

    if-eqz v4, :cond_1

    invoke-interface {v3}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/Integer;

    invoke-virtual {v4}, Ljava/lang/Integer;->intValue()I

    move-result v4

    invoke-static {v4, v2, p2, p3, p4}, Lcom/esmertec/android/jbed/ams/AmsActivity$MenuStateSetter;->isVisibled(IILcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)Z

    move-result v4

    if-eqz v4, :cond_1

    move v4, v6

    :goto_2
    invoke-interface {v1, v4}, Landroid/view/MenuItem;->setVisible(Z)Landroid/view/MenuItem;

    goto :goto_0

    :cond_0
    move v4, v5

    .line 1238
    goto :goto_1

    :cond_1
    move v4, v5

    .line 1239
    goto :goto_2

    .line 1241
    .end local v1    # "item":Landroid/view/MenuItem;
    .end local v2    # "itemFlag":I
    .end local v3    # "menuItemFlag":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/Integer;>;"
    :cond_2
    return-void
.end method
