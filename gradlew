#!/bin/sh
# Minimal fallback gradle wrapper script
if [ -f "gradle/wrapper/gradle-wrapper.jar" ]; then
    exec java -jar gradle/wrapper/gradle-wrapper.jar "$@"
else
    echo "gradle-wrapper.jar not found, falling back to system 'gradle'"
    exec gradle "$@"
fi
