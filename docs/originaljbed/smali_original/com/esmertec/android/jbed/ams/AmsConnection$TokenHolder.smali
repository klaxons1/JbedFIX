.class final enum Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
.super Ljava/lang/Enum;
.source "AmsConnection.java"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/esmertec/android/jbed/ams/AmsConnection;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x401a
    name = "TokenHolder"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum",
        "<",
        "Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;",
        ">;"
    }
.end annotation


# static fields
.field private static final synthetic $VALUES:[Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

.field public static final enum EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

.field public static final enum NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

.field public static final enum PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;


# direct methods
.method static constructor <clinit>()V
    .locals 5

    .prologue
    const/4 v4, 0x2

    const/4 v3, 0x1

    const/4 v2, 0x0

    .line 60
    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    const-string v1, "NONE"

    invoke-direct {v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    const-string v1, "PUSH_REQUEST"

    invoke-direct {v0, v1, v3}, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    new-instance v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    const-string v1, "EVENT_RUN"

    invoke-direct {v0, v1, v4}, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    const/4 v0, 0x3

    new-array v0, v0, [Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->NONE:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    aput-object v1, v0, v2

    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->PUSH_REQUEST:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    aput-object v1, v0, v3

    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->EVENT_RUN:Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    aput-object v1, v0, v4

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->$VALUES:[Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .locals 0
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .prologue
    .line 60
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
    .locals 1
    .param p0, "name"    # Ljava/lang/String;

    .prologue
    .line 60
    const-class v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object p0

    .end local p0    # "name":Ljava/lang/String;
    check-cast p0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    return-object p0
.end method

.method public static values()[Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;
    .locals 1

    .prologue
    .line 60
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->$VALUES:[Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    invoke-virtual {v0}, [Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;->clone()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, [Lcom/esmertec/android/jbed/ams/AmsConnection$TokenHolder;

    return-object v0
.end method
