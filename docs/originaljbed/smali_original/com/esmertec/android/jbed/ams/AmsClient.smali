.class public Lcom/esmertec/android/jbed/ams/AmsClient;
.super Lcom/esmertec/android/jbed/ams/AmsClientBase;
.source "AmsClient.java"

# interfaces
.implements Lcom/esmertec/android/jbed/ams/AmsConstants;


# static fields
.field private static final TAG:Ljava/lang/String; = "AmsClient"

.field private static mEventHandlerMap:Ljava/util/HashMap;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/HashMap",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/Class",
            "<+",
            "Lcom/esmertec/android/jbed/ams/AmsEventHandler;",
            ">;>;"
        }
    .end annotation
.end field

.field private static mInstalingUri:Ljava/lang/String;

.field private static mInstallLock:Z


# direct methods
.method static constructor <clinit>()V
    .locals 8

    .prologue
    const/16 v5, 0x1e

    const-class v7, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    const-class v6, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;

    const-class v4, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;

    const-class v3, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    .line 38
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstalingUri:Ljava/lang/String;

    .line 46
    new-instance v0, Ljava/util/HashMap;

    invoke-direct {v0, v5}, Ljava/util/HashMap;-><init>(I)V

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    .line 51
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/4 v1, 0x2

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 54
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x3a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RuntimeErrorEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 56
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x14

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$InfoEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 57
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2710

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidListLocallInstallEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 58
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2712

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAboutEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 59
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2713

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidShowAlertEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 60
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2714

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidLaunchBrowserHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 61
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x30

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RunningMidletManagerEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 64
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/4 v1, 0x5

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstalledEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 65
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/4 v1, 0x6

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallCancelEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 66
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x21

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$RequestInstallEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 67
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0xf

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallPreviewJadEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 68
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0xd

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 69
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x13

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStepEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 70
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/4 v1, 0x4

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallProgressEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 71
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0xc

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallStatusEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 72
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0xe

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallUnStoppableEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 73
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x39

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$InstallQueryYesNoEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 75
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$PreinstallFolderStartEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 76
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/InstallEventHandler$PreinstallFolderFinishedEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 79
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/4 v1, 0x7

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;

    invoke-virtual {v0, v1, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 80
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x1a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveAllEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 81
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2711

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveConfirmEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 82
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2719

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidMidletStartupErrorHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 85
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x271c

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemoveEventHandler;

    invoke-virtual {v0, v1, v6}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 86
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x271b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidRemoveMultipleConfirmEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 89
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x271d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidMoveMultipleConfirmEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 92
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x33

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPermissionEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 93
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x17

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$PermissionsEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 96
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2b

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/PermissionEventHandler$RequestPushEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 99
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0xb

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 100
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x12

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 101
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x11

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MidletLifecycleEventHandler;

    invoke-virtual {v0, v1, v4}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 104
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x1d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SelectStorageEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 105
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x271a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$StorageSettingEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 107
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    invoke-static {v5}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$RemovableMediaChangedEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 108
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x34

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$ListCertificatesEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 110
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2716

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SuiteRenameInputEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 111
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x15

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-virtual {v0, v1, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 114
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x41

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    invoke-virtual {v0, v1, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 115
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2715

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderNameInputEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 116
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2717

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderListEventHandler;

    invoke-virtual {v0, v1, v7}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 117
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2718

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$AndroidRemoveFolderConfirmEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 120
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x48

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DisplaySizeHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 121
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x49

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SetDisplaySizeHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 123
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x3c

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-virtual {v0, v1, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 124
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x3d

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-virtual {v0, v1, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 125
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x3e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-virtual {v0, v1, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 126
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x3f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/FolderEventHandler$FolderOperationResultEventHandler;

    invoke-virtual {v0, v1, v3}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 133
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x1f

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$MoveEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 135
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x43

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmGetConstraintEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 137
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x26

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$DrmActivateEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 139
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x4a

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$PlatformRequestHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 141
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x271e

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$AndroidPurchaseROConfirmEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 143
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    const/16 v1, 0x2720

    invoke-static {v1}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    const-class v2, Lcom/esmertec/android/jbed/ams/BasicEventHandler$SortSettingEventHandler;

    invoke-virtual {v0, v1, v2}, Ljava/util/HashMap;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;

    .line 146
    return-void
.end method

.method public constructor <init>(Landroid/content/Context;Landroid/os/Handler;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;J)V
    .locals 7
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "handler"    # Landroid/os/Handler;
    .param p3, "conn"    # Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;
    .param p4, "id"    # J

    .prologue
    .line 156
    new-instance v6, Lcom/esmertec/android/jbed/ams/AmsClient$1;

    invoke-direct {v6}, Lcom/esmertec/android/jbed/ams/AmsClient$1;-><init>()V

    move-object v0, p0

    move-object v1, p1

    move-object v2, p2

    move-object v3, p3

    move-wide v4, p4

    invoke-direct/range {v0 .. v6}, Lcom/esmertec/android/jbed/ams/AmsClientBase;-><init>(Landroid/content/Context;Landroid/os/Handler;Lcom/esmertec/android/jbed/ams/IJbedAmsConnection;JLcom/esmertec/android/jbed/ams/AmsEventHandler$Factory;)V

    .line 174
    const-wide/16 v0, 0x1

    cmp-long v0, p4, v0

    if-nez v0, :cond_0

    .line 175
    invoke-static {p0}, Lcom/esmertec/android/jbed/ams/AmsActivity;->initAmsClient(Lcom/esmertec/android/jbed/ams/AmsClient;)V

    .line 177
    :cond_0
    return-void
.end method

.method static synthetic access$000()Ljava/util/HashMap;
    .locals 1

    .prologue
    .line 34
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mEventHandlerMap:Ljava/util/HashMap;

    return-object v0
.end method

.method private convertStringArrayToBytes([Ljava/lang/String;)[B
    .locals 6
    .param p1, "s"    # [Ljava/lang/String;

    .prologue
    .line 180
    new-instance v2, Ljava/io/ByteArrayOutputStream;

    invoke-direct {v2}, Ljava/io/ByteArrayOutputStream;-><init>()V

    .line 181
    .local v2, "out":Ljava/io/ByteArrayOutputStream;
    array-length v3, p1

    invoke-virtual {v2, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V

    .line 182
    const/4 v1, 0x0

    .local v1, "i":I
    :goto_0
    array-length v3, p1

    if-ge v1, v3, :cond_0

    .line 184
    :try_start_0
    aget-object v3, p1, v1

    const-string v4, "utf-8"

    invoke-virtual {v3, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

    move-result-object v3

    invoke-virtual {v2, v3}, Ljava/io/ByteArrayOutputStream;->write([B)V

    .line 185
    const/4 v3, 0x0

    invoke-virtual {v2, v3}, Ljava/io/ByteArrayOutputStream;->write(I)V
    :try_end_0
    .catch Ljava/io/IOException; {:try_start_0 .. :try_end_0} :catch_0

    .line 182
    :goto_1
    add-int/lit8 v1, v1, 0x1

    goto :goto_0

    .line 186
    :catch_0
    move-exception v3

    move-object v0, v3

    .line 187
    .local v0, "ex":Ljava/io/IOException;
    const-string v3, "AmsClient"

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "ERROR: combineByteData "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-static {v3, v4}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_1

    .line 190
    .end local v0    # "ex":Ljava/io/IOException;
    :cond_0
    invoke-virtual {v2}, Ljava/io/ByteArrayOutputStream;->toByteArray()[B

    move-result-object v3

    return-object v3
.end method


# virtual methods
.method checkPermissionAnswer(BB)Ljava/util/Map$Entry;
    .locals 6
    .param p1, "fgIndex"    # B
    .param p2, "permissionAnswer"    # B
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(BB)",
            "Ljava/util/Map$Entry",
            "<",
            "Ljava/lang/Integer;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .prologue
    const/4 v3, 0x2

    const/4 v5, 0x1

    .line 750
    new-instance v1, Lcom/esmertec/android/jbed/ams/AmsClient$4;

    new-array v2, v3, [I

    fill-array-data v2, :array_0

    invoke-direct {v1, p0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient$4;-><init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 766
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    const/16 v2, 0x18

    new-array v3, v3, [B

    const/4 v4, 0x0

    aput-byte p1, v3, v4

    aput-byte p2, v3, v5

    invoke-virtual {v1, v2, v5, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->requestEvent(II[B)V

    .line 767
    sget-object v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v1}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->getResponse()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/util/Map$Entry;

    .line 769
    .local v0, "result":Ljava/util/Map$Entry;, "Ljava/util/Map$Entry<Ljava/lang/Integer;Ljava/lang/String;>;"
    const/4 v1, 0x0

    sput-object v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 771
    return-object v0

    .line 750
    :array_0
    .array-data 4
        0x19
        0x18
    .end array-data
.end method

.method public getAllMidlets()Ljava/util/List;
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
    .line 303
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllOnlyMidlets()Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getAllSuites()Ljava/util/List;
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
    .line 307
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getMidlets()Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public getOnlySuites()Ljava/util/List;
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
    .line 311
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getOnlySuites()Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public declared-synchronized releaseInstallLock()V
    .locals 2

    .prologue
    const-string v0, "AmsClient"

    .line 232
    monitor-enter p0

    :try_start_0
    const-string v0, "AmsClient"

    const/4 v1, 0x3

    invoke-static {v0, v1}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "AmsClient"

    const-string v1, "Install lock released"

    invoke-static {v0, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 233
    :cond_0
    const/4 v0, 0x0

    sput-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstalingUri:Ljava/lang/String;

    .line 234
    const/4 v0, 0x0

    sput-boolean v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstallLock:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    .line 235
    monitor-exit p0

    return-void

    .line 232
    :catchall_0
    move-exception v0

    monitor-exit p0

    throw v0
.end method

.method public requestChapiEvent(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "chapiURL"    # Ljava/lang/String;
    .param p2, "contentType"    # Ljava/lang/String;
    .param p3, "action"    # Ljava/lang/String;
    .param p4, "appName"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    .line 714
    const/4 v1, 0x4

    new-array v0, v1, [Ljava/lang/String;

    aput-object p1, v0, v3

    const/4 v1, 0x1

    aput-object p2, v0, v1

    const/4 v1, 0x2

    aput-object p3, v0, v1

    const/4 v1, 0x3

    aput-object p4, v0, v1

    .line 715
    .local v0, "stringArray":[Ljava/lang/String;
    const/16 v1, 0x2d

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v2

    invoke-virtual {p0, v1, v3, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 716
    return-void
.end method

.method public requestCreateFolder(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "parentPath"    # Ljava/lang/String;
    .param p2, "folderName"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    .line 589
    const/4 v1, 0x2

    new-array v0, v1, [Ljava/lang/String;

    aput-object p1, v0, v3

    const/4 v1, 0x1

    aput-object p2, v0, v1

    .line 590
    .local v0, "stringArray":[Ljava/lang/String;
    const/16 v1, 0x3c

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v2

    invoke-virtual {p0, v1, v3, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 591
    return-void
.end method

.method public requestDisplaySize(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 544
    const/16 v0, 0x48

    iget v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 545
    return-void
.end method

.method public requestDrmActivateErrorEvent(Ljava/lang/String;)V
    .locals 4
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 723
    const/16 v0, 0x26

    const/16 v1, 0xf

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {p0, v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 724
    return-void
.end method

.method public requestDrmActivateEvent(Ljava/lang/String;)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 719
    const/16 v0, 0x26

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 720
    return-void
.end method

.method public requestDrmCheckRightsEvent(Ljava/lang/String;)V
    .locals 3
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 701
    const/16 v0, 0x42

    const/4 v1, 0x0

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 702
    return-void
.end method

.method public requestDrmInstallEvent(Ljava/lang/String;)V
    .locals 3
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 706
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallLock()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 707
    const/16 v0, 0x27

    const/4 v1, 0x0

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 709
    :cond_0
    return-void
.end method

.method public requestFolderSelectEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 620
    const/16 v0, 0x2717

    const/16 v1, 0x1f

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mName:Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 621
    return-void
.end method

.method public requestHandleMideltStartupError(Ljava/lang/String;Ljava/lang/String;)V
    .locals 3
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "errorMsg"    # Ljava/lang/String;

    .prologue
    .line 553
    const/16 v0, 0x2719

    const/4 v1, 0x0

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2, p2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 554
    return-void
.end method

.method public requestHandleSelectStorage(Z)V
    .locals 2
    .param p1, "isInternalStorage"    # Z

    .prologue
    .line 557
    if-eqz p1, :cond_0

    .line 558
    iget-object v0, p0, Lcom/esmertec/android/jbed/ams/AmsClient;->mContext:Landroid/content/Context;

    const v1, 0x7f05029f

    invoke-virtual {v0, v1}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestSelectStorageContinue(Ljava/lang/String;)V

    .line 562
    :goto_0
    return-void

    .line 560
    :cond_0
    sget-object v0, Lcom/esmertec/android/jbed/jsr/JbedFileManager;->EXTERNAL_STORAGE_NAME:Ljava/lang/String;

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestSelectStorageContinue(Ljava/lang/String;)V

    goto :goto_0
.end method

.method public requestInfoEvent(Ljava/lang/String;)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 353
    const/16 v0, 0x14

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 354
    return-void
.end method

.method public requestInputFolderName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    const-string v1, "AmsClient"

    .line 579
    const-string v0, "AmsClient"

    const/4 v0, 0x3

    invoke-static {v1, v0}, Landroid/util/Log;->isLoggable(Ljava/lang/String;I)Z

    move-result v0

    if-eqz v0, :cond_0

    const-string v0, "AmsClient"

    const-string v0, "requestFolderNameInput"

    invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    .line 580
    :cond_0
    const/16 v0, 0x2715

    const/16 v1, 0x3c

    const/4 v2, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 581
    return-void
.end method

.method public requestInstallAuthorization(Ljava/lang/String;Ljava/lang/String;Z)V
    .locals 5
    .param p1, "userName"    # Ljava/lang/String;
    .param p2, "password"    # Ljava/lang/String;
    .param p3, "isContinue"    # Z

    .prologue
    const/4 v4, 0x1

    .line 381
    const/16 v0, 0x10

    if-eqz p3, :cond_0

    move v1, v4

    :goto_0
    const/4 v2, 0x2

    new-array v2, v2, [Ljava/lang/String;

    const/4 v3, 0x0

    aput-object p1, v2, v3

    aput-object p2, v2, v4

    invoke-direct {p0, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 383
    return-void

    .line 381
    :cond_0
    const/4 v1, 0x6

    goto :goto_0
.end method

.method public requestInstallCancelEvent()V
    .locals 1

    .prologue
    .line 399
    const/4 v0, 0x6

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(I)V

    .line 400
    return-void
.end method

.method public requestInstallEvent(Ljava/lang/String;)V
    .locals 3
    .param p1, "installUrl"    # Ljava/lang/String;

    .prologue
    const-string v2, "AmsClient"

    .line 244
    const-string v0, "AmsClient"

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "requestInstallEvent() with url is "

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 245
    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstalingUri:Ljava/lang/String;

    if-eqz v0, :cond_1

    sget-object v0, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstalingUri:Ljava/lang/String;

    invoke-virtual {v0, p1}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1

    .line 257
    :cond_0
    :goto_0
    return-void

    .line 247
    :cond_1
    const-string v0, "AmsClient"

    const-string v0, "requestInstallEvent() requestInstallLock"

    invoke-static {v2, v0}, Lcom/esmertec/android/jbed/LogTag;->amsDebug(Ljava/lang/String;Ljava/lang/String;)V

    .line 252
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestInstallLock()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 254
    sput-object p1, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstalingUri:Ljava/lang/String;

    .line 255
    const/4 v0, 0x5

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    goto :goto_0
.end method

.method public declared-synchronized requestInstallLock()Z
    .locals 4

    .prologue
    const/4 v2, 0x1

    const/4 v3, 0x0

    .line 198
    monitor-enter p0

    :try_start_0
    sget-boolean v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstallLock:Z

    if-nez v1, :cond_0

    .line 200
    const/4 v1, 0x1

    sput-boolean v1, Lcom/esmertec/android/jbed/ams/AmsClient;->mInstallLock:Z
    :try_end_0
    .catchall {:try_start_0 .. :try_end_0} :catchall_0

    move v1, v2

    .line 208
    :goto_0
    monitor-exit p0

    return v1

    .line 203
    :cond_0
    :try_start_1
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->isShowToastEnabled()Z

    move-result v1

    if-eqz v1, :cond_1

    .line 204
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClient;->mContext:Landroid/content/Context;

    const v2, 0x7f05039b

    invoke-virtual {v1, v2}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v0

    .line 205
    .local v0, "text":Ljava/lang/String;
    iget-object v1, p0, Lcom/esmertec/android/jbed/ams/AmsClient;->mContext:Landroid/content/Context;

    const/4 v2, 0x0

    invoke-static {v1, v0, v2}, Landroid/widget/Toast;->makeText(Landroid/content/Context;Ljava/lang/CharSequence;I)Landroid/widget/Toast;

    move-result-object v1

    invoke-virtual {v1}, Landroid/widget/Toast;->show()V

    .line 207
    .end local v0    # "text":Ljava/lang/String;
    :cond_1
    const-string v1, "AmsClient"

    const-string v2, "Another install process exist, installation canceled"

    invoke-static {v1, v2}, Landroid/util/Log;->e(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_1
    .catchall {:try_start_1 .. :try_end_1} :catchall_0

    move v1, v3

    .line 208
    goto :goto_0

    .line 198
    :catchall_0
    move-exception v1

    monitor-exit p0

    throw v1
.end method

.method public requestInstallQueryEvent(Ljava/lang/String;)V
    .locals 4
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 727
    const/16 v0, 0xd

    const/4 v1, 0x2

    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    const/4 v3, 0x0

    invoke-virtual {p0, v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 728
    return-void
.end method

.method public requestInstallQueryEvent(Z)V
    .locals 2
    .param p1, "isContinue"    # Z

    .prologue
    .line 371
    const/16 v0, 0xd

    if-eqz p1, :cond_0

    const/4 v1, 0x5

    :goto_0
    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 372
    return-void

    .line 371
    :cond_0
    const/4 v1, 0x6

    goto :goto_0
.end method

.method public requestInstallQueryYesNoResponse(Z)V
    .locals 2
    .param p1, "isYes"    # Z

    .prologue
    .line 415
    const/16 v0, 0x39

    if-eqz p1, :cond_0

    const/16 v1, 0x19

    :goto_0
    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 416
    return-void

    .line 415
    :cond_0
    const/4 v1, 0x6

    goto :goto_0
.end method

.method public requestInstalledFolderEvent(Ljava/lang/String;)V
    .locals 9
    .param p1, "folderName"    # Ljava/lang/String;

    .prologue
    const/4 v7, 0x0

    const-string v8, "|"

    const-string v6, "/"

    .line 670
    invoke-static {}, Lcom/esmertec/android/jbed/JbedConfig$Ams;->unlimitMidletInDefaultFolder()Z

    move-result v4

    if-nez v4, :cond_3

    .line 672
    iget-object v4, p0, Lcom/esmertec/android/jbed/ams/AmsClient;->mContext:Landroid/content/Context;

    const v5, 0x7f05031d

    invoke-virtual {v4, v5}, Landroid/content/Context;->getString(I)Ljava/lang/String;

    move-result-object v1

    .line 675
    .local v1, "folders":Ljava/lang/String;
    if-eqz v1, :cond_5

    invoke-virtual {v1}, Ljava/lang/String;->trim()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/String;->length()I

    move-result v4

    if-eqz v4, :cond_5

    .line 676
    new-instance v0, Ljava/util/Vector;

    invoke-direct {v0}, Ljava/util/Vector;-><init>()V

    .line 677
    .local v0, "fNames":Ljava/util/Vector;
    const-string v4, "|"

    invoke-virtual {v1, v8}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v3

    .line 678
    .local v3, "index":I
    :goto_0
    const/4 v4, -0x1

    if-eq v3, v4, :cond_0

    .line 679
    invoke-virtual {v1, v7, v3}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v0, v4}, Ljava/util/Vector;->addElement(Ljava/lang/Object;)V

    .line 680
    add-int/lit8 v4, v3, 0x1

    invoke-virtual {v1, v4}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v1

    .line 681
    const-string v4, "|"

    invoke-virtual {v1, v8}, Ljava/lang/String;->indexOf(Ljava/lang/String;)I

    move-result v3

    goto :goto_0

    .line 683
    :cond_0
    invoke-virtual {v0, v1}, Ljava/util/Vector;->addElement(Ljava/lang/Object;)V

    .line 685
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_1
    if-eqz p1, :cond_1

    invoke-virtual {v0}, Ljava/util/Vector;->size()I

    move-result v4

    if-ge v2, v4, :cond_1

    .line 686
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0, v2}, Ljava/util/Vector;->elementAt(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    const-string v5, "/"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {p1, v4}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_4

    .line 690
    :cond_1
    if-eqz p1, :cond_2

    invoke-virtual {v0}, Ljava/util/Vector;->size()I

    move-result v4

    if-ne v2, v4, :cond_3

    .line 691
    :cond_2
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/"

    invoke-virtual {v4, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0, v7}, Ljava/util/Vector;->elementAt(I)Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-virtual {v5, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object p1

    .line 697
    .end local v0    # "fNames":Ljava/util/Vector;
    .end local v1    # "folders":Ljava/lang/String;
    .end local v2    # "i":I
    .end local v3    # "index":I
    :cond_3
    :goto_2
    const/16 v4, 0x41

    const/4 v5, 0x5

    invoke-virtual {p0, v4, v5, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 698
    return-void

    .line 685
    .restart local v0    # "fNames":Ljava/util/Vector;
    .restart local v1    # "folders":Ljava/lang/String;
    .restart local v2    # "i":I
    .restart local v3    # "index":I
    :cond_4
    add-int/lit8 v2, v2, 0x1

    goto :goto_1

    .line 693
    .end local v0    # "fNames":Ljava/util/Vector;
    .end local v2    # "i":I
    .end local v3    # "index":I
    :cond_5
    if-nez p1, :cond_3

    .line 694
    const-string p1, "/"

    goto :goto_2
.end method

.method public requestInstrallPreviewJadEvent(Z)V
    .locals 2
    .param p1, "isContinue"    # Z

    .prologue
    .line 391
    const/16 v0, 0xf

    if-eqz p1, :cond_0

    const/4 v1, 0x5

    :goto_0
    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 392
    return-void

    .line 391
    :cond_0
    const/4 v1, 0x6

    goto :goto_0
.end method

.method public requestLaunchBrowser(Ljava/lang/String;)V
    .locals 4
    .param p1, "url"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    .line 522
    const/16 v0, 0x2714

    if-nez p1, :cond_0

    const/4 v1, 0x0

    :goto_0
    invoke-static {v3}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v2

    invoke-virtual {p0, v0, v3, v1, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 523
    return-void

    .line 522
    :cond_0
    invoke-virtual {p1}, Ljava/lang/String;->getBytes()[B

    move-result-object v1

    goto :goto_0
.end method

.method public requestListCertificatesEvent()V
    .locals 1

    .prologue
    .line 407
    const/16 v0, 0x34

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(I)V

    .line 408
    return-void
.end method

.method public requestListLocalInstall(Z)V
    .locals 4
    .param p1, "isSdcardOnly"    # Z

    .prologue
    .line 480
    const/16 v0, 0x2710

    const/4 v1, 0x0

    const/4 v2, 0x0

    invoke-static {p1}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v3

    invoke-virtual {p0, v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 481
    return-void
.end method

.method public requestMoveMultipleSelectEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V
    .locals 4
    .param p1, "folder"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "isContextItemSelected"    # Z

    .prologue
    const/4 v3, 0x0

    const/16 v2, 0x271d

    const/4 v1, 0x0

    .line 624
    if-eqz p2, :cond_1

    .line 625
    const/4 v0, 0x1

    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v1

    if-eqz v1, :cond_0

    iget-object v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    :goto_0
    invoke-virtual {p0, v2, v0, v3, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 628
    :goto_1
    return-void

    :cond_0
    move-object v1, p1

    .line 625
    goto :goto_0

    .line 627
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, v1, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;

    move-result-object v0

    invoke-virtual {p0, v2, v1, v3, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_1
.end method

.method public requestMoveToFolderEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)I
    .locals 7
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "folderName"    # Ljava/lang/String;

    .prologue
    const/16 v6, 0x1f

    const/4 v5, 0x0

    const/4 v4, 0x1

    .line 631
    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsClient$2;

    new-array v3, v4, [I

    aput v6, v3, v5

    invoke-direct {v2, p0, v3}, Lcom/esmertec/android/jbed/ams/AmsClient$2;-><init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V

    sput-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 642
    const/4 v2, 0x2

    new-array v1, v2, [Ljava/lang/String;

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    aput-object v2, v1, v5

    aput-object p2, v1, v4

    .line 643
    .local v1, "stringArray":[Ljava/lang/String;
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v3

    invoke-virtual {v2, v6, v4, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->requestEvent(II[B)V

    .line 644
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->getResponse()Ljava/lang/Object;

    move-result-object p0

    .end local p0    # "this":Lcom/esmertec/android/jbed/ams/AmsClient;
    check-cast p0, Ljava/lang/Integer;

    invoke-virtual {p0}, Ljava/lang/Integer;->intValue()I

    move-result v0

    .line 645
    .local v0, "result":I
    const/4 v2, 0x0

    sput-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 646
    return v0
.end method

.method public requestMoveToStorageEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)Lcom/esmertec/android/jbed/ams/AmsEvent;
    .locals 7
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "storage"    # Ljava/lang/String;

    .prologue
    const/16 v6, 0x1f

    const/4 v5, 0x1

    const/4 v4, 0x0

    .line 651
    new-instance v2, Lcom/esmertec/android/jbed/ams/AmsClient$3;

    new-array v3, v5, [I

    aput v6, v3, v4

    invoke-direct {v2, p0, v3}, Lcom/esmertec/android/jbed/ams/AmsClient$3;-><init>(Lcom/esmertec/android/jbed/ams/AmsClient;[I)V

    sput-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 662
    const/4 v2, 0x2

    new-array v1, v2, [Ljava/lang/String;

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    aput-object v2, v1, v4

    aput-object p2, v1, v5

    .line 663
    .local v1, "stringArray":[Ljava/lang/String;
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-direct {p0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v3

    invoke-virtual {v2, v6, v4, v3}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->requestEvent(II[B)V

    .line 664
    sget-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    invoke-virtual {v2}, Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;->getResponse()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Lcom/esmertec/android/jbed/ams/AmsEvent;

    .line 665
    .local v0, "result":Lcom/esmertec/android/jbed/ams/AmsEvent;
    const/4 v2, 0x0

    sput-object v2, Lcom/esmertec/android/jbed/ams/AmsClient;->mSerialEventProxy:Lcom/esmertec/android/jbed/ams/AmsClientBase$SerialEventProxy;

    .line 666
    return-object v0
.end method

.method public requestPauseMidlet(Ljava/lang/String;I)V
    .locals 1
    .param p1, "mRoot"    # Ljava/lang/String;
    .param p2, "mNo"    # I

    .prologue
    .line 738
    const/16 v0, 0x8

    invoke-virtual {p0, v0, p2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 739
    return-void
.end method

.method public requestPermission(Ljava/lang/String;)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 496
    const/16 v0, 0x17

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 497
    return-void
.end method

.method public requestPermissionAnswer(IB)V
    .locals 3
    .param p1, "transId"    # I
    .param p2, "answer"    # B

    .prologue
    .line 439
    const/16 v0, 0x33

    const/4 v1, 0x1

    new-array v1, v1, [B

    const/4 v2, 0x0

    aput-byte p2, v1, v2

    invoke-virtual {p0, v0, p1, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 440
    return-void
.end method

.method public requestPermissionAnswerCommit()V
    .locals 2

    .prologue
    .line 530
    const/16 v0, 0x18

    const/4 v1, 0x2

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 531
    return-void
.end method

.method public requestPushAnswer(IB)V
    .locals 3
    .param p1, "transId"    # I
    .param p2, "answer"    # B

    .prologue
    .line 429
    const/16 v0, 0x2b

    const/4 v1, 0x1

    new-array v1, v1, [B

    const/4 v2, 0x0

    aput-byte p2, v1, v2

    invoke-virtual {p0, v0, p1, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 430
    return-void
.end method

.method public requestRemoveAllConfirmEvent()V
    .locals 4

    .prologue
    .line 288
    const/16 v0, 0x2711

    const/16 v1, 0x1a

    const/4 v2, 0x0

    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v3

    invoke-virtual {v3}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getMidlets()Ljava/util/List;

    move-result-object v3

    invoke-virtual {p0, v0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 289
    return-void
.end method

.method public requestRemoveAllEvent()V
    .locals 1

    .prologue
    .line 345
    const/16 v0, 0x1a

    invoke-virtual {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(I)V

    .line 346
    return-void
.end method

.method public requestRemoveConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 280
    const/16 v0, 0x2711

    const/4 v1, 0x7

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->getBytes()[B

    move-result-object v2

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 281
    return-void
.end method

.method public requestRemoveEvent(Ljava/lang/String;)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 320
    const/4 v0, 0x7

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 321
    return-void
.end method

.method public requestRemoveFolderConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "data"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    .line 608
    const/16 v0, 0x2718

    const/16 v1, 0x3f

    const/4 v2, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 609
    return-void
.end method

.method public requestRemoveFolderEvent(Ljava/lang/String;)V
    .locals 2
    .param p1, "folderName"    # Ljava/lang/String;

    .prologue
    .line 616
    const/16 v0, 0x3f

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 617
    return-void
.end method

.method public requestRemoveMultipleCancelEvent()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 336
    const/16 v0, 0x271c

    const/4 v1, 0x6

    invoke-virtual {p0, v0, v1, v2, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 337
    return-void
.end method

.method public requestRemoveMultipleConfirmEvent(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Z)V
    .locals 4
    .param p1, "folder"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "isContextItemSelected"    # Z

    .prologue
    const/4 v3, 0x0

    const/16 v2, 0x271b

    const/4 v1, 0x0

    .line 296
    if-eqz p2, :cond_1

    .line 297
    const/4 v0, 0x1

    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isMidlet()Z

    move-result v1

    if-eqz v1, :cond_0

    iget-object v1, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mParent:Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    :goto_0
    invoke-virtual {p0, v2, v0, v3, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 300
    :goto_1
    return-void

    :cond_0
    move-object v1, p1

    .line 297
    goto :goto_0

    .line 299
    :cond_1
    invoke-virtual {p0}, Lcom/esmertec/android/jbed/ams/AmsClient;->getSelector()Lcom/esmertec/android/jbed/ams/JbedSelector;

    move-result-object v0

    invoke-virtual {v0, p1, v1, v1}, Lcom/esmertec/android/jbed/ams/JbedSelector;->getAllSuites(Lcom/esmertec/android/jbed/ams/JbedSelectorData;ZZ)Ljava/util/List;

    move-result-object v0

    invoke-virtual {p0, v2, v1, v3, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_1
.end method

.method public requestRemoveMultipleEvent(Ljava/lang/Object;)V
    .locals 4
    .param p1, "obj"    # Ljava/lang/Object;

    .prologue
    const/4 v3, 0x0

    .line 328
    const/16 v0, 0x271c

    const/4 v1, 0x0

    if-nez p1, :cond_0

    move-object v2, v3

    :goto_0
    invoke-virtual {p0, v0, v1, v3, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 329
    return-void

    :cond_0
    move-object v2, p1

    .line 328
    goto :goto_0
.end method

.method public requestRenameFolder(Ljava/lang/String;Ljava/lang/String;)V
    .locals 4
    .param p1, "srcName"    # Ljava/lang/String;
    .param p2, "dstName"    # Ljava/lang/String;

    .prologue
    const/4 v3, 0x0

    .line 598
    const/4 v1, 0x2

    new-array v0, v1, [Ljava/lang/String;

    aput-object p1, v0, v3

    const/4 v1, 0x1

    aput-object p2, v0, v1

    .line 599
    .local v0, "stringArray":[Ljava/lang/String;
    const/16 v1, 0x3e

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v2

    invoke-virtual {p0, v1, v3, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 600
    return-void
.end method

.method public requestRenameSuite(Lcom/esmertec/android/jbed/ams/JbedSelectorData;Ljava/lang/String;)V
    .locals 4
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;
    .param p2, "newName"    # Ljava/lang/String;

    .prologue
    .line 569
    const/4 v1, 0x2

    new-array v0, v1, [Ljava/lang/String;

    const/4 v1, 0x0

    iget-object v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mRoot:Ljava/lang/String;

    aput-object v2, v0, v1

    const/4 v1, 0x1

    aput-object p2, v0, v1

    .line 570
    .local v0, "stringArray":[Ljava/lang/String;
    const/16 v1, 0x15

    iget v2, p1, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->mNo:I

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v3

    invoke-virtual {p0, v1, v2, v3}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 571
    return-void
.end method

.method public requestResumeMidlet(Ljava/lang/String;I)V
    .locals 1
    .param p1, "mRoot"    # Ljava/lang/String;
    .param p2, "mNo"    # I

    .prologue
    .line 745
    const/16 v0, 0x9

    invoke-virtual {p0, v0, p2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 746
    return-void
.end method

.method public requestSelectFolderCancel()V
    .locals 2

    .prologue
    .line 473
    const/16 v0, 0x41

    const/4 v1, 0x6

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 474
    return-void
.end method

.method public requestSelectFolderContinue(Ljava/lang/String;)V
    .locals 2
    .param p1, "rootName"    # Ljava/lang/String;

    .prologue
    .line 465
    const/16 v0, 0x41

    const/4 v1, 0x5

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 466
    return-void
.end method

.method public requestSelectStorageCancel()V
    .locals 2

    .prologue
    .line 456
    const/16 v0, 0x1d

    const/4 v1, 0x6

    invoke-virtual {p0, v0, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II)V

    .line 457
    return-void
.end method

.method public requestSelectStorageContinue(Ljava/lang/String;)V
    .locals 2
    .param p1, "rootName"    # Ljava/lang/String;

    .prologue
    .line 448
    const/16 v0, 0x1d

    const/4 v1, 0x5

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 449
    return-void
.end method

.method public requestSetDisplaySize(Ljava/lang/String;ILjava/lang/String;)V
    .locals 3
    .param p1, "root"    # Ljava/lang/String;
    .param p2, "no"    # I
    .param p3, "displaySize"    # Ljava/lang/String;

    .prologue
    .line 548
    const/4 v1, 0x2

    new-array v0, v1, [Ljava/lang/String;

    const/4 v1, 0x0

    aput-object p1, v0, v1

    const/4 v1, 0x1

    aput-object p3, v0, v1

    .line 549
    .local v0, "stringArray":[Ljava/lang/String;
    const/16 v1, 0x49

    invoke-direct {p0, v0}, Lcom/esmertec/android/jbed/ams/AmsClient;->convertStringArrayToBytes([Ljava/lang/String;)[B

    move-result-object v2

    invoke-virtual {p0, v1, p2, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(II[B)V

    .line 550
    return-void
.end method

.method public requestShowAboutEvent()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 422
    const/16 v0, 0x2712

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, v2, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 423
    return-void
.end method

.method public requestShowError(Ljava/lang/String;)V
    .locals 3
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 514
    const/16 v0, 0x2713

    const/4 v1, 0x2

    const/4 v2, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 515
    return-void
.end method

.method public requestShowInfo(Ljava/lang/String;)V
    .locals 3
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 488
    const/16 v0, 0x2713

    const/4 v1, 0x0

    const/4 v2, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 489
    return-void
.end method

.method public requestShowWarning(Ljava/lang/String;)V
    .locals 3
    .param p1, "msg"    # Ljava/lang/String;

    .prologue
    .line 505
    const/16 v0, 0x2713

    const/4 v1, 0x1

    const/4 v2, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 506
    return-void
.end method

.method public requestSortSetting(I)V
    .locals 2
    .param p1, "defaultSort"    # I

    .prologue
    const/4 v1, 0x0

    .line 731
    const/16 v0, 0x2720

    invoke-virtual {p0, v0, p1, v1, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 732
    return-void
.end method

.method public requestStartRunningMidletManager()V
    .locals 3

    .prologue
    const/4 v2, 0x0

    .line 361
    const/16 v0, 0x30

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, v2, v2}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 362
    return-void
.end method

.method public requestStorageSetting(I)V
    .locals 2
    .param p1, "defaultStorage"    # I

    .prologue
    const/4 v1, 0x0

    .line 271
    const/16 v0, 0x271a

    invoke-virtual {p0, v0, p1, v1, v1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 272
    return-void
.end method

.method public requestUpdateEvent(Ljava/lang/String;)V
    .locals 2
    .param p1, "root"    # Ljava/lang/String;

    .prologue
    .line 267
    const/4 v0, 0x3

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->requestEvent(IILjava/lang/String;)V

    .line 268
    return-void
.end method

.method public requsetInputName(Lcom/esmertec/android/jbed/ams/JbedSelectorData;)V
    .locals 3
    .param p1, "midlet"    # Lcom/esmertec/android/jbed/ams/JbedSelectorData;

    .prologue
    const/4 v2, 0x0

    .line 537
    invoke-virtual {p1}, Lcom/esmertec/android/jbed/ams/JbedSelectorData;->isFolder()Z

    move-result v0

    if-eqz v0, :cond_0

    .line 538
    const/16 v0, 0x2715

    const/16 v1, 0x3e

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    .line 541
    :goto_0
    return-void

    .line 540
    :cond_0
    const/16 v0, 0x2716

    const/4 v1, 0x0

    invoke-virtual {p0, v0, v1, v2, p1}, Lcom/esmertec/android/jbed/ams/AmsClient;->handleEventInternal(II[BLjava/lang/Object;)V

    goto :goto_0
.end method
