@echo off
if exist gradle\wrapper\gradle-wrapper.jar (
    java -jar gradle\wrapper\gradle-wrapper.jar %*
) else (
    echo gradle-wrapper.jar not found, falling back to system 'gradle'
    gradle %*
)
