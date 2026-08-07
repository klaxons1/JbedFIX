#!/bin/sh

# Directory containing the wrapper jar
WRAPPER_DIR="gradle/wrapper"
WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper.jar"

if [ ! -f "$WRAPPER_JAR" ]; then
    echo "gradle-wrapper.jar not found, downloading..."
    mkdir -p "$WRAPPER_DIR"
    
    python3 -c '
import urllib.request, zipfile, sys, os
urls = [
    "https://raw.githubusercontent.com/apache/kafka/trunk/gradle/wrapper/gradle-wrapper.jar",
    "https://raw.githubusercontent.com/square/retrofit/master/gradle/wrapper/gradle-wrapper.jar",
    "https://raw.githubusercontent.com/spring-projects/spring-boot/main/gradle/wrapper/gradle-wrapper.jar"
]
for url in urls:
    try:
        print(f"Trying download from {url}...")
        urllib.request.urlretrieve(url, "gradle/wrapper/gradle-wrapper.jar")
        with zipfile.ZipFile("gradle/wrapper/gradle-wrapper.jar") as zf:
            zf.read("META-INF/MANIFEST.MF")
            print("Successfully verified JAR file!")
            sys.exit(0)
    except Exception as e:
        print(f"Failed: {e}")
        if os.path.exists("gradle/wrapper/gradle-wrapper.jar"):
            os.remove("gradle/wrapper/gradle-wrapper.jar")
sys.exit(1)
'
fi

if [ -f "$WRAPPER_JAR" ]; then
    exec java -jar "$WRAPPER_JAR" "$@"
else
    echo "ERROR: Failed to download gradle-wrapper.jar, falling back to system 'gradle'"
    exec gradle "$@"
fi
