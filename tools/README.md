# Android-device debugging helper

For a Windows host with `adb` installed, run this from the repository root:

```powershell
.\tools\collect-jbed-log.ps1 -Adb C:\adb\adb.exe -Seconds 15
```

The script will:

1. verify the connected device;
2. clear Android logs;
3. force-stop Jbed;
4. start an `all`-buffer log capture;
5. launch `com.esmertec.android.jbed` with `monkey`;
6. wait for the chosen duration;
7. create both a full log and a focused log in `tools/logs/`.

The focused log includes Jbed messages, linker errors, ART JNI failures,
tombstone information, and native crashes while excluding unrelated Google/MIUI
noise. Send the generated `*-focus.txt` file content when reporting a run.

## Device-side log files without logcat

The APK also writes a diagnostic trace to:

```text
/storage/emulated/0/jbedfix/jbed.log
/storage/emulated/0/jbedfix/native.log
/storage/emulated/0/jbedfix/native-crash.log
```

`jbed.log` records application lifecycle events, the complete external VIEW
intent summary, MIME/URI normalization, content-URI copies, installer errors,
uncaught Java exceptions, and the legacy VM bootstrap path. `native.log` records
compatibility-shim load, JNI, linker, and scheduler markers. Both files rotate
their current contents at approximately 4 MiB. The app keeps a private fallback
under its internal files directory if the device denies public storage access.
Copy both files from the device after reproducing the issue; they can be read
with any file manager and do not require adb/logcat.

If the Android device displays an installation/permission dialog, increase the
capture duration:

```powershell
.\tools\collect-jbed-log.ps1 -Adb C:\adb\adb.exe -Seconds 30
```
