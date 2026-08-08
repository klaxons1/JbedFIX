<#
Capture a short, useful Jbed Android log on Windows PowerShell.

Examples:
  .\tools\collect-jbed-log.ps1
  .\tools\collect-jbed-log.ps1 -Seconds 20
  .\tools\collect-jbed-log.ps1 -Adb C:\adb\adb.exe -Seconds 15
#>

param(
    [string]$Adb = "adb",
    [int]$Seconds = 15,
    [string]$PackageName = "com.esmertec.android.jbed"
)

$ErrorActionPreference = "Stop"
if ($Seconds -lt 3) { throw "Seconds must be at least 3." }

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logDirectory = Join-Path $PSScriptRoot "..\logs"
New-Item -ItemType Directory -Force -Path $logDirectory | Out-Null
$allLog = Join-Path $logDirectory "jbed-$timestamp-all.txt"
$errorLog = Join-Path $logDirectory "jbed-$timestamp-logcat-stderr.txt"
$focusLog = Join-Path $logDirectory "jbed-$timestamp-focus.txt"

& $Adb get-state | Out-Null
& $Adb logcat -c
& $Adb shell am force-stop $PackageName

# Keep all buffers: ART JNI abort reports and tombstones can be in different
# buffers on Android 11/MIUI.
$process = Start-Process -FilePath $Adb `
    -ArgumentList @("logcat", "-b", "all", "-v", "threadtime") `
    -RedirectStandardOutput $allLog `
    -RedirectStandardError $errorLog `
    -PassThru -NoNewWindow

try {
    Start-Sleep -Milliseconds 500
    Write-Host "Launching $PackageName and recording for $Seconds seconds..."
    & $Adb shell monkey -p $PackageName 1 | Out-Null
    Start-Sleep -Seconds $Seconds
}
finally {
    if (-not $process.HasExited) {
        Stop-Process -Id $process.Id -Force
        $process.WaitForExit()
    }
}

$pattern = "jbed-jni-compat|jbed\.native|JbedEngine|JbedMidpManager|jbedservice|JNI DETECTED|JNI ERROR|Fatal signal|SIGSEGV|FATAL EXCEPTION|UnsatisfiedLinkError|Abort message|dlopen failed|android_midp_getString"
Select-String -Path $allLog -Pattern $pattern -Context 8,30 |
    Out-File -FilePath $focusLog -Encoding utf8

Write-Host ""
Write-Host "Full log:     $allLog"
Write-Host "Focused log: $focusLog"
Write-Host ""
Write-Host "Send the contents of the focused log first. If it is incomplete, also send the full log file."
