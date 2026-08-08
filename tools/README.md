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

If the Android device displays an installation/permission dialog, increase the
capture duration:

```powershell
.\tools\collect-jbed-log.ps1 -Adb C:\adb\adb.exe -Seconds 30
```
