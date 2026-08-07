@echo off
set WRAPPER_DIR=gradle\wrapper
set WRAPPER_JAR=%WRAPPER_DIR%\gradle-wrapper.jar

if not exist "%WRAPPER_JAR%" (
    echo gradle-wrapper.jar not found, downloading...
    if not exist "%WRAPPER_DIR%" mkdir "%WRAPPER_DIR%"
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar', '%WRAPPER_JAR%')"
)

if exist "%WRAPPER_JAR%" (
    java -jar "%WRAPPER_JAR%" %*
) else (
    echo ERROR: Failed to download gradle-wrapper.jar, falling back to system 'gradle'
    gradle %*
)
