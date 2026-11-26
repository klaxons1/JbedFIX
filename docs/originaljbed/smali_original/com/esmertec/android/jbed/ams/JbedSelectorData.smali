.class public Lcom/esmertec/android/jbed/ams/JbedSelectorData;
.super Ljava/lang/Object;
.source "JbedSelectorData.java"

# interfaces
.implements Landroid/os/Parcelable;


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/esmertec/android/jbed/ams/JbedSelectorData$SelectorCharSequence;
    }
.end annotation


# static fields
.field public static final CREATOR:Landroid/os/Parcelable$Creator;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Landroid/os/Parcelable$Creator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field public static final EXT_NULL:Ljava/lang/String; = "null"

.field public static final EXT_PROTECT:Ljava/lang/String; = "protected"

.field public static final EXT_SYSLOCK:Ljava/lang/String; = "syslocked"

.field public static final FOLDER_NO:I = -0x1

.field private static final FULL_SCREEN_LANDSCAPE_HEIGHT:Ljava/lang/String; = "320"

.field private static final FULL_SCREEN_LANDSCAPE_WIDTH:Ljava/lang/String; = "480"

.field private static final FULL_SCREEN_PORTRAIT_HEIGHT:Ljava/lang/String; = "480"

.field private static final FULL_SCREEN_PORTRAIT_WIDTH:Ljava/lang/String; = "320"

.field private static final ICON_FILENAME:Ljava/lang/String; = ".icn"

.field private static final INFO_STORE_PREFIX:Ljava/lang/String; = "info_"

.field public static INSTALLTIME_ORDER:Ljava/util/Comparator; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field private static final KEY_3G_MIDLET_AFTER_OTA_INSTALL_START:Ljava/lang/String; = "3G-MIDlet-After-OTA-Install-Start"

.field private static final KEY_ATT_BG_MODE_RUN:Ljava/lang/String; = "ATT-MIDlet-BG-Mode-Run"

.field public static final KEY_CLDC:Ljava/lang/String; = "MicroEdition-Configuration"

.field private static final KEY_DISPLAY_NAV_KEYPAD:Ljava/lang/String; = "LGE-MIDlet-Display-Nav-Keypad"

.field private static final KEY_FULL_SCREEN:Ljava/lang/String; = "MIDlet-Touch-Support"

.field private static final KEY_LGE_MIDLET_AUTOLANCH_AFTER_INSTALL:Ljava/lang/String; = "LGE-MIDlet-autolaunch-after-install"

.field private static final KEY_LGE_MIDLET_HEIGHT:Ljava/lang/String; = "LGE-MIDlet-Height"

.field private static final KEY_LGE_MIDLET_TARGETLCD_HEIGHT:Ljava/lang/String; = "LGE-MIDlet-TargetLCD-Height"

.field private static final KEY_LGE_MIDLET_TARGETLCD_WIDTH:Ljava/lang/String; = "LGE-MIDlet-TargetLCD-Width"

.field private static final KEY_LGE_MIDLET_WIDTH:Ljava/lang/String; = "LGE-MIDlet-Width"

.field public static final KEY_MDIP:Ljava/lang/String; = "MicroEdition-Profile"

.field private static final KEY_MGR_USER_DENIED:Ljava/lang/String; = "LGE-MIDlet-Mgr-User-Denied"

.field public static final KEY_MIDLET_DELETE_CONFIRM:Ljava/lang/String; = "MIDlet-Delete-Confirm"

.field public static final KEY_MIDLET_DESCRIPT:Ljava/lang/String; = "MIDlet-Description"

.field private static final KEY_MIDLET_FULLSCREEN:Ljava/lang/String; = "MIDlet-fullscreen"

.field public static final KEY_MIDLET_INFO_URL:Ljava/lang/String; = "MIDlet-Info-URL"

.field public static final KEY_MIDLET_JAR_URL:Ljava/lang/String; = "MIDlet-Jar-URL"

.field public static final KEY_MIDLET_NAME:Ljava/lang/String; = "MIDlet-Name"

.field public static final KEY_MIDLET_VENDOR:Ljava/lang/String; = "MIDlet-Vendor"

.field public static final KEY_MIDLET_VERSION:Ljava/lang/String; = "MIDlet-Version"

.field private static final KEY_MVM_PAUSE_BG:Ljava/lang/String; = "MVM-Pause-Background"

.field private static final KEY_SCALE_UP:Ljava/lang/String; = "MIDlet-Scaleup-Support"

.field public static final KEY_STORAGE_PHONE_NAME:Ljava/lang/String; = "Phone"

.field public static NAME_ORDER:Ljava/util/Comparator; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field public static NAME_REVERSE_ORDER:Ljava/util/Comparator; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field private static final PROPERTIES_FILENAME:Ljava/lang/String; = "suite.utf"

.field public static SIZE_ORDER:Ljava/util/Comparator; = null
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Comparator",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field public static final SUITE_NO:I = 0x0

.field static final TAG:Ljava/lang/String; = "JbedSelectorData"

.field private static final mCachedSizeMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/String;",
            "Ljava/lang/Integer;",
            ">;"
        }
    .end annotation
.end field


# instance fields
.field private icon:Landroid/graphics/drawable/Drawable;

.field public mAllowRunBackground:Z

.field mChildren:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation
.end field

.field public mDisplayInfo:Ljava/lang/String;

.field public mDomain:Ljava/lang/String;

.field public mDrmIntervalEverLaunched:Ljava/lang/String;

.field public mDrmMethodType:I

.field mDrmPending:Ljava/lang/String;

.field mDrmProtected:Ljava/lang/String;

.field public mEntryClass:Ljava/lang/String;

.field mFileRoot:Ljava/lang/String;

.field public mHasShortCut:Z

.field public mInstallTime:J

.field public mIsExpired:Z

.field public mIsHidden:Z

.field public mIsPaused:Z

.field public mIsPreInstall:Z

.field public mIsRunning:Z

.field public mLaunchPowerOn:Z

.field public mModifiableContent:Z

.field public final mName:Ljava/lang/String;

.field public mNo:I

.field mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

.field public mProtectExt:Ljava/lang/String;

.field public mRemovable:Ljava/lang/String;

.field public mRoot:Ljava/lang/String;

.field public mSize:I

.field public final mStoragePath:Ljava/lang/String;

.field public mUid:Ljava/lang/String;

.field public mVendor:Ljava/lang/String;


# direct methods
.method static constructor <clinit>()V
    .locals 1

    .prologue
    .line 48
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$1;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$1;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_ORDER:Ljava/util/Comparator;

    .line 58
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$2;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$2;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->NAME_REVERSE_ORDER:Ljava/util/Comparator;

    .line 68
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$3;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$3;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->INSTALLTIME_ORDER:Ljava/util/Comparator;

    .line 78
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$4;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$4;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->SIZE_ORDER:Ljava/util/Comparator;

    .line 210
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0}, Ljava/util/HashMap;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mCachedSizeMap:Ljava/util/HashMap;

    .line 707
    new-instance v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData$5;

    invoke-direct {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData$5;-><init>()V

    sput-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->CREATOR:Landroid/os/Parcelable$Creator;

    return-void
.end method

.method public constructor <init>(Landroid/os/Parcel;)V
    .locals 9
    .param p1, "source"    # Landroid/os/Parcel;

    .prologue
    const/4 v6, 0x0

    const/4 v8, 0x0

    const/4 v7, 0x1

    .line 231
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 94
    const/4 v5, -0x1

    iput v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 103
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    .line 124
    iput-boolean v7, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    .line 154
    iput-object v6, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    .line 156
    iput-boolean v8, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    .line 158
    iput-boolean v8, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mAllowRunBackground:Z

    .line 160
    iput-object v6, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDisplayInfo:Ljava/lang/String;

    .line 232
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 233
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v5

    iput v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 234
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    .line 235
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    .line 236
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    .line 237
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    .line 238
    invoke-virtual {p1}, Landroid/os/Parcel;->readLong()J

    move-result-wide v5

    iput-wide v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    .line 239
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v5

    iput v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    .line 240
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDomain:Ljava/lang/String;

    .line 241
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    .line 242
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    .line 243
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    .line 244
    invoke-virtual {p1}, Landroid/os/Parcel;->readString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmIntervalEverLaunched:Ljava/lang/String;

    .line 245
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v0

    .line 246
    .local v0, "hidden":I
    if-ne v0, v7, :cond_0

    move v5, v7

    :goto_0
    iput-boolean v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    .line 247
    invoke-virtual {p1}, Landroid/os/Parcel;->readInt()I

    move-result v4

    .line 248
    .local v4, "pause":I
    if-ne v4, v7, :cond_1

    move v5, v7

    :goto_1
    iput-boolean v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 249
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v3

    .line 250
    .local v3, "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    sget-object v5, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->CREATOR:Landroid/os/Parcelable$Creator;

    invoke-virtual {p1, v3, v5}, Landroid/os/Parcel;->readTypedList(Ljava/util/List;Landroid/os/Parcelable$Creator;)V

    .line 251
    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_2
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_2

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 252
    .local v2, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {p0, v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V

    goto :goto_2

    .end local v1    # "i$":Ljava/util/Iterator;
    .end local v2    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .end local v3    # "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    .end local v4    # "pause":I
    :cond_0
    move v5, v8

    .line 246
    goto :goto_0

    .restart local v4    # "pause":I
    :cond_1
    move v5, v8

    .line 248
    goto :goto_1

    .line 254
    .restart local v1    # "i$":Ljava/util/Iterator;
    .restart local v3    # "midlets":Ljava/util/List;, "Ljava/util/List<Lcom/esmertec/android/jbed/ams/JbedSelectorData;>;"
    :cond_2
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v5

    invoke-virtual {v5}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v5

    iput-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    .line 256
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;I)V
    .locals 3
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I

    .prologue
    const/4 v2, 0x0

    const/4 v1, 0x0

    .line 213
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 94
    const/4 v0, -0x1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 103
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    .line 124
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    .line 154
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    .line 156
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    .line 158
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mAllowRunBackground:Z

    .line 160
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDisplayInfo:Ljava/lang/String;

    .line 214
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    .line 215
    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    .line 216
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    .line 217
    iput p2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 218
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    .line 219
    return-void
.end method

.method public constructor <init>(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "storagePath"    # Ljava/lang/String;
    .param p2, "name"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    const/4 v2, 0x1

    const/4 v1, 0x0

    .line 221
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 94
    const/4 v0, -0x1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    .line 103
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    .line 124
    iput-boolean v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mModifiableContent:Z

    .line 154
    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    .line 156
    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mHasShortCut:Z

    .line 158
    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mAllowRunBackground:Z

    .line 160
    iput-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDisplayInfo:Ljava/lang/String;

    .line 223
    invoke-virtual {p1}, Ljava/lang/String;->length()I

    move-result v0

    sub-int/2addr v0, v2

    invoke-virtual {p1, v0}, Ljava/lang/String;->charAt(I)C

    move-result v0

    sget-char v1, Ljava/io/File;->separatorChar:C

    if-eq v0, v1, :cond_0

    .line 224
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    sget-char v1, Ljava/io/File;->separatorChar:C

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 226
    :cond_0
    iput-object p1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    .line 227
    iput-object p2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    .line 228
    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v0

    invoke-virtual {v0}, Ljava/util/UUID;->toString()Ljava/lang/String;

    move-result-object v0

    iput-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    .line 229
    return-void
.end method

.method private getInfoStoreRoot()Ljava/lang/String;
    .locals 2

    .prologue
    .line 384
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, "info_"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private getProperty(Ljava/lang/String;)Ljava/lang/String;
    .locals 10
    .param p1, "key"    # Ljava/lang/String;

    .prologue
    .line 329
    new-instance v6, Ljava/io/File;

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInfoStoreRoot()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "suite.utf"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-direct {v6, v8}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 330
    .local v6, "suiteUtfFile":Ljava/io/File;
    const/4 v1, 0x0

    .line 332
    .local v1, "in":Ljava/io/DataInputStream;
    const/4 v4, 0x0

    .line 334
    .local v4, "res":Ljava/lang/String;
    :try_start_0
    new-instance v2, Ljava/io/DataInputStream;

    new-instance v8, Ljava/io/FileInputStream;

    invoke-direct {v8, v6}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v2, v8}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 336
    .end local v1    # "in":Ljava/io/DataInputStream;
    .local v2, "in":Ljava/io/DataInputStream;
    :try_start_1
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readInt()I

    move-result v5

    .line 337
    .local v5, "size":I
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_0
    if-ge v0, v5, :cond_0

    .line 338
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v3

    .line 339
    .local v3, "k":Ljava/lang/String;
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v7

    .line 340
    .local v7, "v":Ljava/lang/String;
    invoke-virtual {v3, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    move-result v8

    if-eqz v8, :cond_1

    .line 341
    move-object v4, v7

    .line 348
    .end local v3    # "k":Ljava/lang/String;
    .end local v7    # "v":Ljava/lang/String;
    :cond_0
    :try_start_2
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    move-object v1, v2

    .line 352
    .end local v0    # "i":I
    .end local v2    # "in":Ljava/io/DataInputStream;
    .end local v5    # "size":I
    .restart local v1    # "in":Ljava/io/DataInputStream;
    :goto_1
    return-object v4

    .line 337
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v0    # "i":I
    .restart local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "k":Ljava/lang/String;
    .restart local v5    # "size":I
    .restart local v7    # "v":Ljava/lang/String;
    :cond_1
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 349
    .end local v3    # "k":Ljava/lang/String;
    .end local v7    # "v":Ljava/lang/String;
    :catch_0
    move-exception v8

    move-object v1, v2

    .line 351
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_1

    .line 345
    .end local v0    # "i":I
    .end local v5    # "size":I
    :catch_1
    move-exception v8

    .line 348
    :goto_2
    :try_start_3
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_2

    goto :goto_1

    .line 349
    :catch_2
    move-exception v8

    goto :goto_1

    .line 347
    :catchall_0
    move-exception v8

    .line 348
    :goto_3
    :try_start_4
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_3

    .line 350
    :goto_4
    throw v8

    .line 349
    :catch_3
    move-exception v9

    goto :goto_4

    .line 347
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catchall_1
    move-exception v8

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_3

    .line 345
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_4
    move-exception v8

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_2
.end method

.method private getSizeStr(J)Ljava/lang/String;
    .locals 13
    .param p1, "size"    # J

    .prologue
    .line 455
    const-string v10, ""

    .line 456
    .local v10, "retStr":Ljava/lang/String;
    const-string v0, "B"

    .line 457
    .local v0, "bStr":Ljava/lang/String;
    const-string v4, "KB"

    .line 458
    .local v4, "kbStr":Ljava/lang/String;
    const-string v7, "MB"

    .line 462
    .local v7, "mbStr":Ljava/lang/String;
    const-wide/16 v11, 0x400

    cmp-long v11, p1, v11

    if-gez v11, :cond_0

    .line 463
    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    invoke-static {p1, p2}, Ljava/lang/String;->valueOf(J)Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v11

    .line 486
    :goto_0
    return-object v11

    .line 465
    :cond_0
    const-wide/16 v11, 0xa

    mul-long/2addr p1, v11

    .line 468
    const/16 v11, 0xa

    shr-long v2, p1, v11

    .line 469
    .local v2, "kb":J
    const/16 v11, 0xa

    shl-long v11, v2, v11

    sub-long v8, p1, v11

    .line 470
    .local v8, "rem":J
    const-wide/16 v11, 0x400

    cmp-long v11, v2, v11

    if-gez v11, :cond_2

    .line 471
    const-wide/16 v11, 0x200

    cmp-long v11, v8, v11

    if-lez v11, :cond_1

    .line 472
    const-wide/16 v11, 0x1

    add-long/2addr v2, v11

    .line 474
    :cond_1
    long-to-float v11, v2

    const/high16 v12, 0x41200000    # 10.0f

    div-float v1, v11, v12

    .line 475
    .local v1, "fResult":F
    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-static {v1}, Ljava/lang/String;->valueOf(F)Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    move-object v11, v10

    .line 476
    goto :goto_0

    .line 478
    .end local v1    # "fResult":F
    :cond_2
    const/16 v11, 0xa

    shr-long v5, v2, v11

    .line 479
    .local v5, "mb":J
    const/16 v11, 0x14

    shl-long v11, v5, v11

    sub-long v8, p1, v11

    .line 480
    const-wide/16 v11, 0x200

    cmp-long v11, v8, v11

    if-ltz v11, :cond_3

    .line 482
    const-wide/16 v11, 0x1

    add-long/2addr v5, v11

    .line 484
    :cond_3
    long-to-float v11, v5

    const/high16 v12, 0x41200000    # 10.0f

    div-float v1, v11, v12

    .line 485
    .restart local v1    # "fResult":F
    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v11, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-static {v1}, Ljava/lang/String;->valueOf(F)Ljava/lang/String;

    move-result-object v12

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    move-object v11, v10

    .line 486
    goto :goto_0
.end method

.method private getTextByKey(Ljava/lang/String;)Ljava/lang/String;
    .locals 10
    .param p1, "key"    # Ljava/lang/String;

    .prologue
    .line 497
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v8

    if-eqz v8, :cond_0

    .line 498
    iget-object v8, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-direct {v8, p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 523
    :goto_0
    return-object v8

    .line 500
    :cond_0
    new-instance v6, Ljava/io/File;

    new-instance v8, Ljava/lang/StringBuilder;

    invoke-direct {v8}, Ljava/lang/StringBuilder;-><init>()V

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInfoStoreRoot()Ljava/lang/String;

    move-result-object v9

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    const-string v9, "suite.utf"

    invoke-virtual {v8, v9}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v8

    invoke-virtual {v8}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v8

    invoke-direct {v6, v8}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 501
    .local v6, "suiteUtfFile":Ljava/io/File;
    const/4 v1, 0x0

    .line 503
    .local v1, "in":Ljava/io/DataInputStream;
    const/4 v4, 0x0

    .line 505
    .local v4, "res":Ljava/lang/String;
    :try_start_0
    new-instance v2, Ljava/io/DataInputStream;

    new-instance v8, Ljava/io/FileInputStream;

    invoke-direct {v8, v6}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v2, v8}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 507
    .end local v1    # "in":Ljava/io/DataInputStream;
    .local v2, "in":Ljava/io/DataInputStream;
    :try_start_1
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readInt()I

    move-result v5

    .line 508
    .local v5, "size":I
    const/4 v0, 0x0

    .local v0, "i":I
    :goto_1
    if-ge v0, v5, :cond_1

    .line 509
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v3

    .line 510
    .local v3, "k":Ljava/lang/String;
    invoke-virtual {v2}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v7

    .line 511
    .local v7, "v":Ljava/lang/String;
    invoke-virtual {v3, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    :try_end_1
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_4
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    move-result v8

    if-eqz v8, :cond_2

    .line 512
    move-object v4, v7

    .line 519
    .end local v3    # "k":Ljava/lang/String;
    .end local v7    # "v":Ljava/lang/String;
    :cond_1
    :try_start_2
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    move-object v1, v2

    .end local v0    # "i":I
    .end local v2    # "in":Ljava/io/DataInputStream;
    .end local v5    # "size":I
    .restart local v1    # "in":Ljava/io/DataInputStream;
    :goto_2
    move-object v8, v4

    .line 523
    goto :goto_0

    .line 508
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v0    # "i":I
    .restart local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "k":Ljava/lang/String;
    .restart local v5    # "size":I
    .restart local v7    # "v":Ljava/lang/String;
    :cond_2
    add-int/lit8 v0, v0, 0x1

    goto :goto_1

    .line 520
    .end local v3    # "k":Ljava/lang/String;
    .end local v7    # "v":Ljava/lang/String;
    :catch_0
    move-exception v8

    move-object v1, v2

    .line 522
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_2

    .line 516
    .end local v0    # "i":I
    .end local v5    # "size":I
    :catch_1
    move-exception v8

    .line 519
    :goto_3
    :try_start_3
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_3
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_2

    goto :goto_2

    .line 520
    :catch_2
    move-exception v8

    goto :goto_2

    .line 518
    :catchall_0
    move-exception v8

    .line 519
    :goto_4
    :try_start_4
    invoke-virtual {v1}, Ljava/io/DataInputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_3

    .line 521
    :goto_5
    throw v8

    .line 520
    :catch_3
    move-exception v9

    goto :goto_5

    .line 518
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catchall_1
    move-exception v8

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_4

    .line 516
    .end local v1    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_4
    move-exception v8

    move-object v1, v2

    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "in":Ljava/io/DataInputStream;
    goto :goto_3
.end method

.method public static sortFolderToTop(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Lcom/esmertec/android/jbed/ams/JbedSelectorData;)I
    .locals 2
    .param p0, "m1"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p1, "m2"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 37
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-eqz v0, :cond_0

    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-nez v0, :cond_0

    .line 38
    const/4 v0, -0x1

    .line 44
    :goto_0
    return v0

    .line 39
    :cond_0
    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-eqz v0, :cond_1

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-nez v0, :cond_1

    .line 40
    const/4 v0, 0x1

    goto :goto_0

    .line 41
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-eqz v0, :cond_2

    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-eqz v0, :cond_2

    .line 42
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    iget-object v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->compareToIgnoreCase(Ljava/lang/String;)I

    move-result v0

    goto :goto_0

    .line 44
    :cond_2
    const/4 v0, 0x0

    goto :goto_0
.end method


# virtual methods
.method public addChild(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 1
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 427
    iput-object p0, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 428
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 429
    return-void
.end method

.method public calculateSize(Z)V
    .locals 3
    .param p1, "isforced"    # Z

    .prologue
    .line 669
    sget-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mCachedSizeMap:Ljava/util/HashMap;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->containsKey(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    if-nez p1, :cond_0

    .line 670
    sget-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mCachedSizeMap:Ljava/util/HashMap;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/util/HashMap;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Integer;

    invoke-virtual {v0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    .line 683
    :goto_0
    return-void

    .line 674
    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-static {v0, v1}, Lcom/esmertec/android/jbed/util/FileUtil;->getFilesSizeWithPrefix(Ljava/lang/String;Ljava/lang/String;)I

    move-result v0

    iput v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    .line 677
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_1

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    if-eqz v0, :cond_1

    .line 678
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v2, v2, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "java"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-object v2, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "Installed"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-object v2, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-static {v1, v2}, Lcom/esmertec/android/jbed/util/FileUtil;->getFilesSizeWithPrefix(Ljava/lang/String;Ljava/lang/String;)I

    move-result v1

    add-int/2addr v0, v1

    iput v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    .line 682
    :cond_1
    sget-object v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mCachedSizeMap:Ljava/util/HashMap;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    invoke-static {v2}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    goto :goto_0
.end method

.method public clearState()V
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 841
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 842
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    .line 843
    iput-boolean v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    .line 849
    :cond_0
    return-void

    .line 844
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 845
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    .local v1, "i$":Ljava/util/Iterator;
    :goto_0
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_0

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 846
    .local v0, "children":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->clearState()V

    goto :goto_0
.end method

.method public describeContents()I
    .locals 1

    .prologue
    .line 719
    const/4 v0, 0x0

    return v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .locals 6
    .param p1, "oMidlet"    # Ljava/lang/Object;

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 646
    if-eqz p1, :cond_4

    instance-of v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v2, :cond_4

    .line 647
    move-object v0, p1

    check-cast v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    move-object v1, v0

    .line 648
    .local v1, "other":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    if-eq v1, p0, :cond_0

    iget-object v2, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_1

    :cond_0
    move v2, v5

    .line 659
    .end local v1    # "other":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    return v2

    .line 654
    .restart local v1    # "other":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_1
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-eqz v2, :cond_2

    .line 655
    iget-object v2, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    goto :goto_0

    .line 657
    :cond_2
    iget-object v2, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_3

    iget v2, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    iget v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-ne v2, v3, :cond_3

    move v2, v5

    goto :goto_0

    :cond_3
    move v2, v4

    goto :goto_0

    .end local v1    # "other":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_4
    move v2, v4

    .line 659
    goto :goto_0
.end method

.method public getATTBGModeRun()Ljava/lang/String;
    .locals 1

    .prologue
    .line 599
    const-string v0, "ATT-MIDlet-BG-Mode-Run"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getAllChildren()Ljava/util/List;
    .locals 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List",
            "<",
            "Lcom/esmertec/android/jbed/ams/JbedSelectorData;",
            ">;"
        }
    .end annotation

    .prologue
    .line 279
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    return-object v0
.end method

.method public getChildCount()I
    .locals 1

    .prologue
    .line 275
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0

    return v0
.end method

.method public getChildren(I)Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .locals 1
    .param p1, "index"    # I

    .prologue
    .line 423
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v0, p1}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    check-cast p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    return-object p0
.end method

.method public getDeleteConfirmText()Ljava/lang/String;
    .locals 1

    .prologue
    .line 531
    const-string v0, "MIDlet-Delete-Confirm"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getDescription()Ljava/lang/String;
    .locals 1

    .prologue
    .line 542
    const-string v0, "MIDlet-Description"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getFormatedLevelName()Ljava/lang/String;
    .locals 5

    .prologue
    .line 584
    new-instance v2, Ljava/lang/StringBuffer;

    invoke-direct {v2}, Ljava/lang/StringBuffer;-><init>()V

    .line 585
    .local v2, "result":Ljava/lang/StringBuffer;
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getLevel()I

    move-result v1

    .line 586
    .local v1, "level":I
    const/4 v0, 0x1

    .local v0, "i":I
    :goto_0
    if-ge v0, v1, :cond_0

    .line 588
    const/4 v3, 0x0

    const-string v4, "/.."

    invoke-virtual {v2, v3, v4}, Ljava/lang/StringBuffer;->insert(ILjava/lang/String;)Ljava/lang/StringBuffer;

    .line 586
    add-int/lit8 v0, v0, 0x1

    goto :goto_0

    .line 590
    :cond_0
    if-lez v1, :cond_1

    .line 591
    const-string v3, "/"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 593
    :cond_1
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 594
    invoke-virtual {v2}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v3

    return-object v3
.end method

.method public getFullPath()Ljava/lang/String;
    .locals 5

    .prologue
    const/4 v4, 0x0

    .line 607
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 608
    new-instance v2, Ljava/lang/UnsupportedOperationException;

    const-string v3, "Midlet type can\'t support full path"

    invoke-direct {v2, v3}, Ljava/lang/UnsupportedOperationException;-><init>(Ljava/lang/String;)V

    throw v2

    .line 610
    :cond_0
    new-instance v1, Ljava/lang/StringBuffer;

    invoke-direct {v1}, Ljava/lang/StringBuffer;-><init>()V

    .line 611
    .local v1, "result":Ljava/lang/StringBuffer;
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(Ljava/lang/String;)Ljava/lang/StringBuffer;

    .line 612
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 613
    .local v0, "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    if-eqz v0, :cond_2

    .line 614
    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    sget-object v3, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v2, v3}, Ljava/lang/String;->endsWith(Ljava/lang/String;)Z

    move-result v2

    if-nez v2, :cond_1

    .line 615
    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v4, v2}, Ljava/lang/StringBuffer;->insert(IC)Ljava/lang/StringBuffer;

    .line 617
    :cond_1
    iget-object v2, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v1, v4, v2}, Ljava/lang/StringBuffer;->insert(ILjava/lang/String;)Ljava/lang/StringBuffer;

    .line 618
    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    goto :goto_0

    .line 621
    :cond_2
    invoke-virtual {v1, v4}, Ljava/lang/StringBuffer;->charAt(I)C

    move-result v2

    sget-char v3, Ljava/io/File;->separatorChar:C

    if-eq v2, v3, :cond_3

    .line 622
    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v4, v2}, Ljava/lang/StringBuffer;->insert(IC)Ljava/lang/StringBuffer;

    .line 624
    :cond_3
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->length()I

    move-result v2

    const/4 v3, 0x1

    sub-int/2addr v2, v3

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->charAt(I)C

    move-result v2

    sget-char v3, Ljava/io/File;->separatorChar:C

    if-eq v2, v3, :cond_4

    .line 625
    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v2}, Ljava/lang/StringBuffer;->append(C)Ljava/lang/StringBuffer;

    .line 628
    :cond_4
    invoke-virtual {v1}, Ljava/lang/StringBuffer;->toString()Ljava/lang/String;

    move-result-object v2

    return-object v2
.end method

.method getHierarchyNames()[Ljava/lang/String;
    .locals 7

    .prologue
    .line 288
    invoke-static {}, Lcom/google/android/collect/Lists;->newArrayList()Ljava/util/ArrayList;

    move-result-object v2

    .line 289
    .local v2, "names":Ljava/util/List;, "Ljava/util/List<Ljava/lang/String;>;"
    iget-object v5, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-interface {v2, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 290
    iget-object v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 291
    .local v3, "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    if-eqz v3, :cond_0

    .line 292
    iget-object v5, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-interface {v2, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 293
    iget-object v3, v3, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    goto :goto_0

    .line 297
    :cond_0
    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v5

    new-array v4, v5, [Ljava/lang/String;

    .line 298
    .local v4, "result":[Ljava/lang/String;
    array-length v5, v4

    const/4 v6, 0x1

    sub-int v0, v5, v6

    .line 299
    .local v0, "i":I
    const/4 v1, 0x0

    .line 300
    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .local v1, "level":I
    :goto_1
    if-ltz v0, :cond_1

    .line 301
    invoke-interface {v2, v0}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object p0

    check-cast p0, Ljava/lang/String;

    aput-object p0, v4, v1

    .line 300
    add-int/lit8 v0, v0, -0x1

    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 303
    :cond_1
    return-object v4
.end method

.method public getIcon(Landroid/content/Context;)Landroid/graphics/drawable/Drawable;
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 400
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->icon:Landroid/graphics/drawable/Drawable;

    if-nez v1, :cond_1

    .line 401
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getIconPath()Ljava/lang/String;

    move-result-object v0

    .line 402
    .local v0, "path":Ljava/lang/String;
    invoke-static {v0}, Landroid/text/TextUtils;->isEmpty(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_2

    .line 403
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isCustomIconEnable()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 405
    const/4 v1, 0x0

    .line 414
    .end local v0    # "path":Ljava/lang/String;
    :goto_0
    return-object v1

    .line 408
    .restart local v0    # "path":Ljava/lang/String;
    :cond_0
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    invoke-virtual {v1}, Landroid/content/pm/PackageManager;->getDefaultActivityIcon()Landroid/graphics/drawable/Drawable;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->icon:Landroid/graphics/drawable/Drawable;

    .line 414
    .end local v0    # "path":Ljava/lang/String;
    :cond_1
    :goto_1
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->icon:Landroid/graphics/drawable/Drawable;

    goto :goto_0

    .line 412
    .restart local v0    # "path":Ljava/lang/String;
    :cond_2
    invoke-static {v0}, Landroid/graphics/drawable/BitmapDrawable;->createFromPath(Ljava/lang/String;)Landroid/graphics/drawable/Drawable;

    move-result-object v1

    iput-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->icon:Landroid/graphics/drawable/Drawable;

    goto :goto_1
.end method

.method public getIconPath()Ljava/lang/String;
    .locals 5

    .prologue
    const-string v4, ".icn"

    .line 394
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInfoStoreRoot()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    iget v3, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ".icn"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    .line 395
    .local v1, "path":Ljava/lang/String;
    new-instance v2, Ljava/lang/StringBuilder;

    invoke-direct {v2}, Ljava/lang/StringBuilder;-><init>()V

    invoke-direct {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInfoStoreRoot()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, "0"

    invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    const-string v3, ".icn"

    invoke-virtual {v2, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 396
    .local v0, "alterPath":Ljava/lang/String;
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_0

    move-object v2, v1

    :goto_0
    return-object v2

    :cond_0
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v2}, Ljava/io/File;->exists()Z

    move-result v2

    if-eqz v2, :cond_1

    move-object v2, v0

    goto :goto_0

    :cond_1
    const-string v2, ""

    goto :goto_0
.end method

.method public getInfoUrl()Ljava/lang/String;
    .locals 1

    .prologue
    .line 546
    const-string v0, "MIDlet-Info-URL"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getInstallTimeText()Ljava/lang/String;
    .locals 4

    .prologue
    .line 432
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v2

    if-eqz v2, :cond_0

    .line 433
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getInstallTimeText()Ljava/lang/String;

    move-result-object v2

    .line 439
    :goto_0
    return-object v2

    .line 434
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 435
    new-instance v0, Ljava/util/Date;

    iget-wide v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    invoke-direct {v0, v2, v3}, Ljava/util/Date;-><init>(J)V

    .line 436
    .local v0, "date":Ljava/util/Date;
    const/4 v2, 0x3

    invoke-static {v2}, Ljava/text/DateFormat;->getDateInstance(I)Ljava/text/DateFormat;

    move-result-object v1

    .line 437
    .local v1, "dateFormat":Ljava/text/DateFormat;
    invoke-virtual {v1, v0}, Ljava/text/DateFormat;->format(Ljava/util/Date;)Ljava/lang/String;

    move-result-object v2

    goto :goto_0

    .line 439
    .end local v0    # "date":Ljava/util/Date;
    .end local v1    # "dateFormat":Ljava/text/DateFormat;
    :cond_1
    const-string v2, ""

    goto :goto_0
.end method

.method public getLevel()I
    .locals 2

    .prologue
    .line 574
    const/4 v1, 0x0

    .line 575
    .local v1, "result":I
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 576
    .local v0, "parent":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :goto_0
    if-eqz v0, :cond_0

    .line 577
    add-int/lit8 v1, v1, 0x1

    .line 578
    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    goto :goto_0

    .line 580
    :cond_0
    return v1
.end method

.method public getMgrUserDenied()Ljava/lang/String;
    .locals 1

    .prologue
    .line 534
    const-string v0, "LGE-MIDlet-Mgr-User-Denied"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public getNameText()Ljava/lang/String;
    .locals 3

    .prologue
    .line 550
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    .line 551
    .local v0, "nameText":Ljava/lang/String;
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 552
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "("

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->size()I

    move-result v2

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ")"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 554
    :cond_0
    return-object v0
.end method

.method public getParentUid()Ljava/lang/String;
    .locals 1

    .prologue
    .line 567
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    if-eqz v0, :cond_0

    .line 568
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    .line 570
    :goto_0
    return-object v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public getScaleProperty()Ljava/lang/String;
    .locals 14

    .prologue
    const/4 v13, 0x0

    const-string v12, "JbedSelectorData"

    .line 930
    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    const-string v11, "/data/data/com.esmertec.android.jbed/Installed/"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    iget-object v11, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "info_suite.utf"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 931
    .local v5, "infoFilePath":Ljava/lang/String;
    new-instance v4, Ljava/io/File;

    invoke-direct {v4, v5}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 932
    .local v4, "infoFile":Ljava/io/File;
    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v10

    if-nez v10, :cond_0

    .line 933
    const-string v10, "JbedSelectorData"

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, "does not exist"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-static {v12, v10}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move-object v10, v13

    .line 962
    :goto_0
    return-object v10

    .line 936
    :cond_0
    const/4 v2, 0x0

    .line 938
    .local v2, "in":Ljava/io/DataInputStream;
    const/4 v7, 0x0

    .line 940
    .local v7, "res":Ljava/lang/String;
    :try_start_0
    new-instance v3, Ljava/io/DataInputStream;

    new-instance v10, Ljava/io/FileInputStream;

    invoke-direct {v10, v4}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v3, v10}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_1
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 941
    .end local v2    # "in":Ljava/io/DataInputStream;
    .local v3, "in":Ljava/io/DataInputStream;
    :try_start_1
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readInt()I

    move-result v8

    .line 942
    .local v8, "size":I
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    if-ge v1, v8, :cond_1

    .line 943
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v6

    .line 944
    .local v6, "key":Ljava/lang/String;
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v9

    .line 945
    .local v9, "value":Ljava/lang/String;
    const-string v10, "MIDlet-Scaleup-Support"

    invoke-virtual {v6, v10}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    :try_end_1
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_6
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_5
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    move-result v10

    if-eqz v10, :cond_2

    .line 946
    move-object v7, v9

    .line 958
    .end local v6    # "key":Ljava/lang/String;
    .end local v9    # "value":Ljava/lang/String;
    :cond_1
    :try_start_2
    invoke-virtual {v3}, Ljava/io/DataInputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_2

    :goto_2
    move-object v10, v7

    .line 962
    goto :goto_0

    .line 942
    .restart local v6    # "key":Ljava/lang/String;
    .restart local v9    # "value":Ljava/lang/String;
    :cond_2
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 950
    .end local v1    # "i":I
    .end local v3    # "in":Ljava/io/DataInputStream;
    .end local v6    # "key":Ljava/lang/String;
    .end local v8    # "size":I
    .end local v9    # "value":Ljava/lang/String;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_0
    move-exception v10

    move-object v0, v10

    .line 951
    .local v0, "e":Ljava/io/FileNotFoundException;
    :goto_3
    :try_start_3
    const-string v10, "JbedSelectorData"

    const-string v11, " selectorFile.toString() isn\'t exist "

    invoke-static {v10, v11, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 952
    new-instance v10, Ljava/lang/IllegalStateException;

    new-instance v11, Ljava/lang/StringBuilder;

    invoke-direct {v11}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v11, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    const-string v12, " isn\'t exist"

    invoke-virtual {v11, v12}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v11

    invoke-virtual {v11}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v11

    invoke-direct {v10, v11}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v10
    :try_end_3
    .catchall {:try_start_3 .. :try_end_3} :catchall_0

    .line 957
    .end local v0    # "e":Ljava/io/FileNotFoundException;
    :catchall_0
    move-exception v10

    .line 958
    :goto_4
    :try_start_4
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_4

    .line 960
    :goto_5
    throw v10

    .line 953
    :catch_1
    move-exception v10

    move-object v0, v10

    .line 954
    .local v0, "e":Ljava/io/IOException;
    :goto_6
    :try_start_5
    const-string v10, "JbedSelectorData"

    const-string v11, " failed to read selector file"

    invoke-static {v10, v11, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_5
    .catchall {:try_start_5 .. :try_end_5} :catchall_0

    .line 958
    :try_start_6
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_6
    .catch Ljava/io/IOException; {:try_start_6 .. :try_end_6} :catch_3

    :goto_7
    move-object v10, v13

    .line 960
    goto :goto_0

    .line 959
    .end local v0    # "e":Ljava/io/IOException;
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "i":I
    .restart local v3    # "in":Ljava/io/DataInputStream;
    .restart local v8    # "size":I
    :catch_2
    move-exception v10

    goto :goto_2

    .end local v1    # "i":I
    .end local v3    # "in":Ljava/io/DataInputStream;
    .end local v8    # "size":I
    .restart local v0    # "e":Ljava/io/IOException;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_3
    move-exception v10

    goto :goto_7

    .end local v0    # "e":Ljava/io/IOException;
    :catch_4
    move-exception v11

    goto :goto_5

    .line 957
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catchall_1
    move-exception v10

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_4

    .line 953
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catch_5
    move-exception v10

    move-object v0, v10

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_6

    .line 950
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catch_6
    move-exception v10

    move-object v0, v10

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_3
.end method

.method public getSimpleStorageName()Ljava/lang/String;
    .locals 3

    .prologue
    .line 558
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v2, Ljava/io/File;->separator:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/String;->startsWith(Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_0

    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 560
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    .line 562
    :goto_0
    return-object v0

    :cond_1
    const-string v0, "Phone"

    goto :goto_0
.end method

.method public getSizeText(Landroid/content/Context;)Ljava/lang/String;
    .locals 2
    .param p1, "context"    # Landroid/content/Context;

    .prologue
    .line 443
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 444
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v0, p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeText(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v0

    .line 448
    :goto_0
    return-object v0

    .line 445
    :cond_0
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v0

    if-eqz v0, :cond_1

    .line 446
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    int-to-long v0, v0

    invoke-direct {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getSizeStr(J)Ljava/lang/String;

    move-result-object v0

    goto :goto_0

    .line 448
    :cond_1
    const-string v0, ""

    goto :goto_0
.end method

.method public getVendorText()Ljava/lang/String;
    .locals 1

    .prologue
    .line 490
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 491
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getVendorText()Ljava/lang/String;

    move-result-object v0

    .line 493
    :goto_0
    return-object v0

    :cond_0
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    if-nez v0, :cond_1

    const-string v0, ""

    goto :goto_0

    :cond_1
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    goto :goto_0
.end method

.method public getVersionText()Ljava/lang/String;
    .locals 1

    .prologue
    .line 538
    const-string v0, "MIDlet-Version"

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getTextByKey(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method public isAllowRunBackground()Z
    .locals 3

    .prologue
    .line 370
    const-string v1, "ATT-MIDlet-BG-Mode-Run"

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->getProperty(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 371
    .local v0, "value":Ljava/lang/String;
    if-eqz v0, :cond_0

    invoke-virtual {v0}, Ljava/lang/String;->toLowerCase()Ljava/lang/String;

    move-result-object v1

    const-string v2, "yes"

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    const/4 v1, 0x1

    :goto_0
    iput-boolean v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mAllowRunBackground:Z

    .line 374
    iget-boolean v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mAllowRunBackground:Z

    return v1

    .line 371
    :cond_0
    const/4 v1, 0x0

    goto :goto_0
.end method

.method public isAutoRun()Z
    .locals 13

    .prologue
    const/4 v11, 0x0

    const-string v9, "YES"

    const-string v12, "JbedSelectorData"

    .line 805
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    const-string v10, "/data/data/com.esmertec.android.jbed/Installed/"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    iget-object v10, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "info_suite.utf"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 806
    .local v5, "infoFilePath":Ljava/lang/String;
    new-instance v4, Ljava/io/File;

    invoke-direct {v4, v5}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 807
    .local v4, "infoFile":Ljava/io/File;
    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v9

    if-nez v9, :cond_0

    .line 808
    const-string v9, "JbedSelectorData"

    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const-string v10, "does not exist"

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    invoke-static {v12, v9}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    move v9, v11

    .line 837
    :goto_0
    return v9

    .line 811
    :cond_0
    const/4 v2, 0x0

    .line 813
    .local v2, "in":Ljava/io/DataInputStream;
    :try_start_0
    new-instance v3, Ljava/io/DataInputStream;

    new-instance v9, Ljava/io/FileInputStream;

    invoke-direct {v9, v4}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v3, v9}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_2
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_3
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 814
    .end local v2    # "in":Ljava/io/DataInputStream;
    .local v3, "in":Ljava/io/DataInputStream;
    :try_start_1
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readInt()I

    move-result v7

    .line 815
    .local v7, "size":I
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_1
    if-ge v1, v7, :cond_3

    .line 816
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v6

    .line 817
    .local v6, "key":Ljava/lang/String;
    invoke-virtual {v3}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v8

    .line 818
    .local v8, "value":Ljava/lang/String;
    const-string v9, "LGE-MIDlet-autolaunch-after-install"

    invoke-virtual {v6, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_1

    .line 819
    const-string v9, "YES"

    invoke-virtual {v8, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    :try_end_1
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_8
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_7
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    move-result v9

    .line 833
    :try_start_2
    invoke-virtual {v3}, Ljava/io/DataInputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    goto :goto_0

    .line 834
    :catch_0
    move-exception v10

    goto :goto_0

    .line 821
    :cond_1
    :try_start_3
    const-string v9, "3G-MIDlet-After-OTA-Install-Start"

    invoke-virtual {v6, v9}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v9

    if-eqz v9, :cond_2

    .line 822
    const-string v9, "YES"

    invoke-virtual {v8, v9}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    :try_end_3
    .catch Ljava/io/FileNotFoundException; {:try_start_3 .. :try_end_3} :catch_8
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_7
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    move-result v9

    .line 833
    :try_start_4
    invoke-virtual {v3}, Ljava/io/DataInputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_1

    goto :goto_0

    .line 834
    :catch_1
    move-exception v10

    goto :goto_0

    .line 815
    :cond_2
    add-int/lit8 v1, v1, 0x1

    goto :goto_1

    .line 833
    .end local v6    # "key":Ljava/lang/String;
    .end local v8    # "value":Ljava/lang/String;
    :cond_3
    :try_start_5
    invoke-virtual {v3}, Ljava/io/DataInputStream;->close()V
    :try_end_5
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_4

    :goto_2
    move v9, v11

    .line 837
    goto :goto_0

    .line 825
    .end local v1    # "i":I
    .end local v3    # "in":Ljava/io/DataInputStream;
    .end local v7    # "size":I
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_2
    move-exception v9

    move-object v0, v9

    .line 826
    .local v0, "e":Ljava/io/FileNotFoundException;
    :goto_3
    :try_start_6
    const-string v9, "JbedSelectorData"

    const-string v10, " selectorFile.toString() isn\'t exist "

    invoke-static {v9, v10, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 827
    new-instance v9, Ljava/lang/IllegalStateException;

    new-instance v10, Ljava/lang/StringBuilder;

    invoke-direct {v10}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v10, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    const-string v11, " isn\'t exist"

    invoke-virtual {v10, v11}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v10

    invoke-virtual {v10}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    invoke-direct {v9, v10}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v9
    :try_end_6
    .catchall {:try_start_6 .. :try_end_6} :catchall_0

    .line 832
    .end local v0    # "e":Ljava/io/FileNotFoundException;
    :catchall_0
    move-exception v9

    .line 833
    :goto_4
    :try_start_7
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_7
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_7} :catch_6

    .line 835
    :goto_5
    throw v9

    .line 828
    :catch_3
    move-exception v9

    move-object v0, v9

    .line 829
    .local v0, "e":Ljava/io/IOException;
    :goto_6
    :try_start_8
    const-string v9, "JbedSelectorData"

    const-string v10, " failed to read selector file"

    invoke-static {v9, v10, v0}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_8
    .catchall {:try_start_8 .. :try_end_8} :catchall_0

    .line 833
    :try_start_9
    invoke-virtual {v2}, Ljava/io/DataInputStream;->close()V
    :try_end_9
    .catch Ljava/io/IOException; {:try_start_9 .. :try_end_9} :catch_5

    :goto_7
    move v9, v11

    .line 835
    goto :goto_0

    .line 834
    .end local v0    # "e":Ljava/io/IOException;
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v1    # "i":I
    .restart local v3    # "in":Ljava/io/DataInputStream;
    .restart local v7    # "size":I
    :catch_4
    move-exception v9

    goto :goto_2

    .end local v1    # "i":I
    .end local v3    # "in":Ljava/io/DataInputStream;
    .end local v7    # "size":I
    .restart local v0    # "e":Ljava/io/IOException;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    :catch_5
    move-exception v9

    goto :goto_7

    .end local v0    # "e":Ljava/io/IOException;
    :catch_6
    move-exception v10

    goto :goto_5

    .line 832
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catchall_1
    move-exception v9

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_4

    .line 828
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catch_7
    move-exception v9

    move-object v0, v9

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_6

    .line 825
    .end local v2    # "in":Ljava/io/DataInputStream;
    .restart local v3    # "in":Ljava/io/DataInputStream;
    :catch_8
    move-exception v9

    move-object v0, v9

    move-object v2, v3

    .end local v3    # "in":Ljava/io/DataInputStream;
    .restart local v2    # "in":Ljava/io/DataInputStream;
    goto :goto_3
.end method

.method public isDamaged()Z
    .locals 4

    .prologue
    const-string v3, ".obj"

    .line 724
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    if-eqz v1, :cond_0

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_0

    .line 725
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    sget-object v2, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "java"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "Installed"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    sget-char v2, Ljava/io/File;->separatorChar:C

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ".obj"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 729
    .local v0, "fullPath":Ljava/lang/String;
    :goto_0
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, v0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v1}, Ljava/io/File;->exists()Z

    move-result v1

    if-nez v1, :cond_1

    const/4 v1, 0x1

    :goto_1
    return v1

    .line 728
    .end local v0    # "fullPath":Ljava/lang/String;
    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    const-string v2, "/data/data/com.esmertec.android.jbed/Installed/"

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, ".obj"

    invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .restart local v0    # "fullPath":Ljava/lang/String;
    goto :goto_0

    .line 729
    :cond_1
    const/4 v1, 0x0

    goto :goto_1
.end method

.method public isDrmIntervalEverLaunched()Z
    .locals 2

    .prologue
    .line 325
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmIntervalEverLaunched:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmIntervalEverLaunched:Ljava/lang/String;

    const-string v1, "Y"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isDrmPending()Z
    .locals 2

    .prologue
    .line 321
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    const-string v1, "Y"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isDrmProtected()Z
    .locals 2

    .prologue
    .line 313
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    const-string v1, "Y"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isFirstMidletInSuite()Z
    .locals 2

    .prologue
    const/4 v1, 0x1

    .line 271
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-ne v0, v1, :cond_0

    move v0, v1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isFolder()Z
    .locals 2

    .prologue
    .line 263
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    const/4 v1, -0x1

    if-ne v0, v1, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isFolderContainProtectedSuite()Z
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 910
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-nez v2, :cond_0

    move v2, v3

    .line 916
    :goto_0
    return v2

    .line 912
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 913
    .local v1, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isProtected()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 914
    const/4 v2, 0x1

    goto :goto_0

    .end local v1    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    move v2, v3

    .line 916
    goto :goto_0
.end method

.method public isFolderContainRunningMidlet()Z
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 892
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-nez v2, :cond_0

    move v2, v3

    .line 898
    :goto_0
    return v2

    .line 894
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 895
    .local v1, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuiteContainRunningMidlet()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 896
    const/4 v2, 0x1

    goto :goto_0

    .end local v1    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    move v2, v3

    .line 898
    goto :goto_0
.end method

.method public isFolderContainSystemLockedSuite()Z
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 920
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v2

    if-nez v2, :cond_0

    move v2, v3

    .line 926
    :goto_0
    return v2

    .line 922
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 923
    .local v1, "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSystemLock()Z

    move-result v2

    if-eqz v2, :cond_1

    .line 924
    const/4 v2, 0x1

    goto :goto_0

    .end local v1    # "suite":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    move v2, v3

    .line 926
    goto :goto_0
.end method

.method public isFullScreen()Z
    .locals 17

    .prologue
    .line 733
    const/4 v4, 0x0

    .line 734
    .local v4, "LGEMIDletWidth":Ljava/lang/String;
    const/4 v1, 0x0

    .line 735
    .local v1, "LGEMIDletHeight":Ljava/lang/String;
    const/4 v3, 0x0

    .line 736
    .local v3, "LGEMIDletTargetLCDWidth":Ljava/lang/String;
    const/4 v2, 0x0

    .line 737
    .local v2, "LGEMIDletTargetLCDHeight":Ljava/lang/String;
    new-instance v14, Ljava/lang/StringBuilder;

    invoke-direct {v14}, Ljava/lang/StringBuilder;-><init>()V

    const-string v15, "/data/data/com.esmertec.android.jbed/Installed/"

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    move-object/from16 v0, p0

    iget-object v0, v0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    move-object v15, v0

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    const-string v15, "info_suite.utf"

    invoke-virtual {v14, v15}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v14

    invoke-virtual {v14}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v10

    .line 738
    .local v10, "infoFilePath":Ljava/lang/String;
    new-instance v9, Ljava/io/File;

    invoke-direct {v9, v10}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 739
    .local v9, "infoFile":Ljava/io/File;
    invoke-virtual {v9}, Ljava/io/File;->exists()Z

    move-result v14

    if-nez v14, :cond_0

    .line 740
    const-string v14, "JbedSelectorData"

    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v15, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    const-string v16, "does not exist"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    invoke-virtual {v15}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v15

    invoke-static {v14, v15}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    .line 741
    const/4 v14, 0x0

    .line 801
    :goto_0
    return v14

    .line 743
    :cond_0
    const/4 v7, 0x0

    .line 745
    .local v7, "in":Ljava/io/DataInputStream;
    :try_start_0
    new-instance v8, Ljava/io/DataInputStream;

    new-instance v14, Ljava/io/FileInputStream;

    invoke-direct {v14, v9}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    invoke-direct {v8, v14}, Ljava/io/DataInputStream;-><init>(Ljava/io/InputStream;)V
    :try_end_0
    .catch Ljava/io/FileNotFoundException; {:try_start_0 .. :try_end_0} :catch_4
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_5
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 746
    .end local v7    # "in":Ljava/io/DataInputStream;
    .local v8, "in":Ljava/io/DataInputStream;
    :try_start_1
    invoke-virtual {v8}, Ljava/io/DataInputStream;->readInt()I

    move-result v12

    .line 747
    .local v12, "size":I
    const/4 v6, 0x0

    .local v6, "i":I
    :goto_1
    if-ge v6, v12, :cond_9

    .line 748
    invoke-virtual {v8}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v11

    .line 749
    .local v11, "key":Ljava/lang/String;
    invoke-virtual {v8}, Ljava/io/DataInputStream;->readUTF()Ljava/lang/String;

    move-result-object v13

    .line 750
    .local v13, "value":Ljava/lang/String;
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v14

    const-string v15, "TW"

    invoke-virtual {v14, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_1

    .line 752
    const-string v14, "MIDlet-Touch-Support"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_8

    const-string v14, "true"

    invoke-virtual {v13, v14}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    :try_end_1
    .catch Ljava/io/FileNotFoundException; {:try_start_1 .. :try_end_1} :catch_a
    .catch Ljava/io/IOException; {:try_start_1 .. :try_end_1} :catch_9
    .catchall {:try_start_1 .. :try_end_1} :catchall_1

    move-result v14

    .line 792
    :try_start_2
    invoke-virtual {v8}, Ljava/io/DataInputStream;->close()V
    :try_end_2
    .catch Ljava/io/IOException; {:try_start_2 .. :try_end_2} :catch_0

    goto :goto_0

    .line 793
    :catch_0
    move-exception v15

    goto :goto_0

    .line 754
    :cond_1
    :try_start_3
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig;->getCustomerName()Ljava/lang/String;

    move-result-object v14

    const-string v15, "PK"

    invoke-virtual {v14, v15}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_2

    .line 756
    const-string v14, "MIDlet-fullscreen"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_8

    const-string v14, "true"

    invoke-virtual {v13, v14}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    :try_end_3
    .catch Ljava/io/FileNotFoundException; {:try_start_3 .. :try_end_3} :catch_a
    .catch Ljava/io/IOException; {:try_start_3 .. :try_end_3} :catch_9
    .catchall {:try_start_3 .. :try_end_3} :catchall_1

    move-result v14

    .line 792
    :try_start_4
    invoke-virtual {v8}, Ljava/io/DataInputStream;->close()V
    :try_end_4
    .catch Ljava/io/IOException; {:try_start_4 .. :try_end_4} :catch_1

    goto :goto_0

    .line 793
    :catch_1
    move-exception v15

    goto :goto_0

    .line 762
    :cond_2
    :try_start_5
    const-string v14, "LGE-MIDlet-Display-Nav-Keypad"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_4

    .line 763
    const-string v14, "no"

    invoke-virtual {v13, v14}, Ljava/lang/String;->equalsIgnoreCase(Ljava/lang/String;)Z
    :try_end_5
    .catch Ljava/io/FileNotFoundException; {:try_start_5 .. :try_end_5} :catch_a
    .catch Ljava/io/IOException; {:try_start_5 .. :try_end_5} :catch_9
    .catchall {:try_start_5 .. :try_end_5} :catchall_1

    move-result v14

    if-eqz v14, :cond_3

    .line 764
    const/4 v14, 0x1

    .line 792
    :try_start_6
    invoke-virtual {v8}, Ljava/io/DataInputStream;->close()V
    :try_end_6
    .catch Ljava/io/IOException; {:try_start_6 .. :try_end_6} :catch_2

    goto :goto_0

    .line 793
    :catch_2
    move-exception v15

    goto :goto_0

    .line 766
    :cond_3
    const/4 v14, 0x0

    .line 792
    :try_start_7
    invoke-virtual {v8}, Ljava/io/DataInputStream;->close()V
    :try_end_7
    .catch Ljava/io/IOException; {:try_start_7 .. :try_end_7} :catch_3

    goto :goto_0

    .line 793
    :catch_3
    move-exception v15

    goto :goto_0

    .line 769
    :cond_4
    :try_start_8
    const-string v14, "LGE-MIDlet-Width"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_5

    .line 770
    move-object v4, v13

    .line 772
    :cond_5
    const-string v14, "LGE-MIDlet-Height"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_6

    .line 773
    move-object v1, v13

    .line 775
    :cond_6
    const-string v14, "LGE-MIDlet-TargetLCD-Width"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_7

    .line 776
    move-object v3, v13

    .line 778
    :cond_7
    const-string v14, "LGE-MIDlet-TargetLCD-Height"

    invoke-virtual {v11, v14}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    :try_end_8
    .catch Ljava/io/FileNotFoundException; {:try_start_8 .. :try_end_8} :catch_a
    .catch Ljava/io/IOException; {:try_start_8 .. :try_end_8} :catch_9
    .catchall {:try_start_8 .. :try_end_8} :catchall_1

    move-result v14

    if-eqz v14, :cond_8

    .line 779
    move-object v2, v13

    .line 747
    :cond_8
    add-int/lit8 v6, v6, 0x1

    goto/16 :goto_1

    .line 792
    .end local v11    # "key":Ljava/lang/String;
    .end local v13    # "value":Ljava/lang/String;
    :cond_9
    :try_start_9
    invoke-virtual {v8}, Ljava/io/DataInputStream;->close()V
    :try_end_9
    .catch Ljava/io/IOException; {:try_start_9 .. :try_end_9} :catch_7

    .line 796
    :goto_2
    const-string v14, "480"

    invoke-virtual {v14, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_a

    const-string v14, "320"

    invoke-virtual {v14, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_d

    :cond_a
    const-string v14, "480"

    invoke-virtual {v14, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_b

    const-string v14, "320"

    invoke-virtual {v14, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_d

    :cond_b
    const-string v14, "320"

    invoke-virtual {v14, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_c

    const-string v14, "480"

    invoke-virtual {v14, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-nez v14, :cond_d

    :cond_c
    const-string v14, "320"

    invoke-virtual {v14, v3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_e

    const-string v14, "480"

    invoke-virtual {v14, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_e

    .line 800
    :cond_d
    const/4 v14, 0x1

    goto/16 :goto_0

    .line 784
    .end local v6    # "i":I
    .end local v8    # "in":Ljava/io/DataInputStream;
    .end local v12    # "size":I
    .restart local v7    # "in":Ljava/io/DataInputStream;
    :catch_4
    move-exception v14

    move-object v5, v14

    .line 785
    .local v5, "e":Ljava/io/FileNotFoundException;
    :goto_3
    :try_start_a
    const-string v14, "JbedSelectorData"

    const-string v15, " selectorFile.toString() isn\'t exist "

    invoke-static {v14, v15, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I

    .line 786
    new-instance v14, Ljava/lang/IllegalStateException;

    new-instance v15, Ljava/lang/StringBuilder;

    invoke-direct {v15}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v15, v10}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    const-string v16, " isn\'t exist"

    invoke-virtual/range {v15 .. v16}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v15

    invoke-virtual {v15}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v15

    invoke-direct {v14, v15}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v14
    :try_end_a
    .catchall {:try_start_a .. :try_end_a} :catchall_0

    .line 791
    .end local v5    # "e":Ljava/io/FileNotFoundException;
    :catchall_0
    move-exception v14

    .line 792
    :goto_4
    :try_start_b
    invoke-virtual {v7}, Ljava/io/DataInputStream;->close()V
    :try_end_b
    .catch Ljava/io/IOException; {:try_start_b .. :try_end_b} :catch_8

    .line 794
    :goto_5
    throw v14

    .line 787
    :catch_5
    move-exception v14

    move-object v5, v14

    .line 788
    .local v5, "e":Ljava/io/IOException;
    :goto_6
    :try_start_c
    const-string v14, "JbedSelectorData"

    const-string v15, " failed to read selector file"

    invoke-static {v14, v15, v5}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;Ljava/lang/Throwable;)I
    :try_end_c
    .catchall {:try_start_c .. :try_end_c} :catchall_0

    .line 789
    const/4 v14, 0x0

    .line 792
    :try_start_d
    invoke-virtual {v7}, Ljava/io/DataInputStream;->close()V
    :try_end_d
    .catch Ljava/io/IOException; {:try_start_d .. :try_end_d} :catch_6

    goto/16 :goto_0

    .line 793
    :catch_6
    move-exception v15

    goto/16 :goto_0

    .line 801
    .end local v5    # "e":Ljava/io/IOException;
    .end local v7    # "in":Ljava/io/DataInputStream;
    .restart local v6    # "i":I
    .restart local v8    # "in":Ljava/io/DataInputStream;
    .restart local v12    # "size":I
    :cond_e
    const/4 v14, 0x0

    goto/16 :goto_0

    .line 793
    :catch_7
    move-exception v14

    goto :goto_2

    .end local v6    # "i":I
    .end local v8    # "in":Ljava/io/DataInputStream;
    .end local v12    # "size":I
    .restart local v7    # "in":Ljava/io/DataInputStream;
    :catch_8
    move-exception v15

    goto :goto_5

    .line 791
    .end local v7    # "in":Ljava/io/DataInputStream;
    .restart local v8    # "in":Ljava/io/DataInputStream;
    :catchall_1
    move-exception v14

    move-object v7, v8

    .end local v8    # "in":Ljava/io/DataInputStream;
    .restart local v7    # "in":Ljava/io/DataInputStream;
    goto :goto_4

    .line 787
    .end local v7    # "in":Ljava/io/DataInputStream;
    .restart local v8    # "in":Ljava/io/DataInputStream;
    :catch_9
    move-exception v14

    move-object v5, v14

    move-object v7, v8

    .end local v8    # "in":Ljava/io/DataInputStream;
    .restart local v7    # "in":Ljava/io/DataInputStream;
    goto :goto_6

    .line 784
    .end local v7    # "in":Ljava/io/DataInputStream;
    .restart local v8    # "in":Ljava/io/DataInputStream;
    :catch_a
    move-exception v14

    move-object v5, v14

    move-object v7, v8

    .end local v8    # "in":Ljava/io/DataInputStream;
    .restart local v7    # "in":Ljava/io/DataInputStream;
    goto :goto_3
.end method

.method public isHidden()Z
    .locals 1

    .prologue
    .line 317
    iget-boolean v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    return v0
.end method

.method public isMidlet()Z
    .locals 1

    .prologue
    .line 267
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-lez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isOnSdcard()Z
    .locals 2

    .prologue
    .line 632
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    sget-object v1, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isProtected()Z
    .locals 2

    .prologue
    .line 902
    const-string v0, "protected"

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method public isRemovable()Z
    .locals 2

    .prologue
    .line 309
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    if-eqz v0, :cond_0

    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    const-string v1, "N"

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_0

    const/4 v0, 0x0

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x1

    goto :goto_0
.end method

.method public isSuite()Z
    .locals 1

    .prologue
    .line 259
    iget v0, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    if-nez v0, :cond_0

    const/4 v0, 0x1

    :goto_0
    return v0

    :cond_0
    const/4 v0, 0x0

    goto :goto_0
.end method

.method public isSuiteContainRunningMidlet()Z
    .locals 4

    .prologue
    const/4 v3, 0x0

    .line 882
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v2

    if-nez v2, :cond_0

    move v2, v3

    .line 888
    :goto_0
    return v2

    .line 884
    :cond_0
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    .local v0, "i$":Ljava/util/Iterator;
    :cond_1
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_2

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .line 885
    .local v1, "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    iget-boolean v2, v1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsRunning:Z

    if-eqz v2, :cond_1

    .line 886
    const/4 v2, 0x1

    goto :goto_0

    .end local v1    # "midlet":Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    :cond_2
    move v2, v3

    .line 888
    goto :goto_0
.end method

.method public isSystemLock()Z
    .locals 2

    .prologue
    .line 906
    const-string v0, "syslocked"

    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mProtectExt:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method public toString()Ljava/lang/String;
    .locals 3

    .prologue
    .line 637
    const-string v0, "  +--Midlet "

    .line 638
    .local v0, "prefix":Ljava/lang/String;
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isSuite()Z

    move-result v1

    if-eqz v1, :cond_0

    .line 639
    const-string v0, "Suite  "

    .line 641
    :cond_0
    new-instance v1, Ljava/lang/StringBuilder;

    invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "["

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, "] num="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(I)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " storage="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " fileRoot="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    const-string v2, " uid="

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mUid:Ljava/lang/String;

    invoke-virtual {v1, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method public writeToParcel(Landroid/os/Parcel;I)V
    .locals 6
    .param p1, "dest"    # Landroid/os/Parcel;
    .param p2, "flags"    # I

    .prologue
    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 686
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 687
    iget v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeInt(I)V

    .line 688
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 689
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mStoragePath:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 690
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mFileRoot:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 691
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mVendor:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 692
    iget-wide v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mInstallTime:J

    invoke-virtual {p1, v2, v3}, Landroid/os/Parcel;->writeLong(J)V

    .line 693
    iget v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mSize:I

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeInt(I)V

    .line 694
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDomain:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 695
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRemovable:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 696
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmProtected:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 697
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmPending:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 698
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mDrmIntervalEverLaunched:Ljava/lang/String;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeString(Ljava/lang/String;)V

    .line 699
    iget-boolean v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsHidden:Z

    if-eqz v2, :cond_0

    move v0, v5

    .line 700
    .local v0, "hidden":I
    :goto_0
    invoke-virtual {p1, v0}, Landroid/os/Parcel;->writeInt(I)V

    .line 701
    iget-boolean v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mIsPaused:Z

    if-eqz v2, :cond_1

    move v1, v5

    .line 702
    .local v1, "pause":I
    :goto_1
    invoke-virtual {p1, v1}, Landroid/os/Parcel;->writeInt(I)V

    .line 703
    iget-object v2, p0, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mChildren:Ljava/util/List;

    invoke-virtual {p1, v2}, Landroid/os/Parcel;->writeTypedList(Ljava/util/List;)V

    .line 705
    return-void

    .end local v0    # "hidden":I
    .end local v1    # "pause":I
    :cond_0
    move v0, v4

    .line 699
    goto :goto_0

    .restart local v0    # "hidden":I
    :cond_1
    move v1, v4

    .line 701
    goto :goto_1
.end method
