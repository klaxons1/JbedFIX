#!/bin/sh

# Directory containing the wrapper jar
WRAPPER_DIR="gradle/wrapper"
WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper.jar"

# If the wrapper jar doesn't exist, download it!
if [ ! -f "$WRAPPER_JAR" ]; then
    echo "gradle-wrapper.jar not found, downloading..."
    mkdir -p "$WRAPPER_DIR"
    # Download from official Gradle repository
    curl -sLo "$WRAPPER_JAR" "https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar" || \
    wget -qO "$WRAPPER_JAR" "https://raw.githubusercontent.com/gradle/gradle/v8.4.0/gradle/wrapper/gradle-wrapper.jar"
fi

if [ -f "$WRAPPER_JAR" ]; then
    exec java -jar "$WRAPPER_JAR" "$@"
else
    echo "ERROR: Failed to download gradle-wrapper.jar, falling back to system 'gradle'"
    exec gradle "$@"
fi
