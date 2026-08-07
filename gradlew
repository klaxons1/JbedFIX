#!/bin/sh

##############################################################################
#
#   Gradle start up script for POSIX with bootstrap capability
#
##############################################################################

# Attempt to set APP_HOME
app_path=$0
while
    APP_HOME=${app_path%"${app_path##*/}"}
    [ -h "$app_path" ]
do
    ls=$( ls -ld "$app_path" )
    link=${ls#*' -> '}
    case $link in
      /*) app_path=$link ;;
      *)  app_path=$APP_HOME$link ;;
    esac
done
APP_BASE_NAME=${0##*/}
APP_HOME=$( cd "${APP_HOME:-./}" > /dev/null && pwd -P ) || exit

# Use the Gradle wrapper JAR if it exists
WRAPPER_JAR="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

if [ -f "$WRAPPER_JAR" ]; then
    CLASSPATH=$WRAPPER_JAR
else
    # Bootstrap: download Gradle wrapper JAR
    GRADLE_VERSION=8.4
    WRAPPER_URL="https://raw.githubusercontent.com/gradle/gradle/v${GRADLE_VERSION}/gradle/wrapper/gradle-wrapper.jar"
    
    echo "Downloading Gradle wrapper..."
    
    # Try multiple mirrors
    for url in \
        "https://raw.githubusercontent.com/gradle/gradle/v${GRADLE_VERSION}/gradle/wrapper/gradle-wrapper.jar" \
        "https://github.com/gradle/gradle/raw/v${GRADLE_VERSION}/gradle/wrapper/gradle-wrapper.jar" \
        "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip"; do
        
        if command -v curl &> /dev/null; then
            if curl -fsSL -o "$WRAPPER_JAR" "$url" 2>/dev/null; then
                if [ -f "$WRAPPER_JAR" ] && [ -s "$WRAPPER_JAR" ]; then
                    break
                fi
            fi
        elif command -v wget &> /dev/null; then
            if wget -q -O "$WRAPPER_JAR" "$url" 2>/dev/null; then
                if [ -f "$WRAPPER_JAR" ] && [ -s "$WRAPPER_JAR" ]; then
                    break
                fi
            fi
        fi
    done
    
    if [ ! -f "$WRAPPER_JAR" ] || [ ! -s "$WRAPPER_JAR" ]; then
        echo "ERROR: Failed to download Gradle wrapper. Please check your network connection."
        echo "Attempted URLs:"
        echo "  $WRAPPER_URL"
        exit 1
    fi
    
    CLASSPATH=$WRAPPER_JAR
fi

# Determine the Java command to use
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD=$JAVA_HOME/jre/sh/java
    else
        JAVACMD=$JAVA_HOME/bin/java
    fi
    if [ ! -x "$JAVACMD" ] ; then
        echo "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
        exit 1
    fi
else
    JAVACMD=java
    if ! which java >/dev/null 2>&1; then
        echo "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH."
        exit 1
    fi
fi

# Set default JVM options
DEFAULT_JVM_OPTS='"-Xmx64m" "-Xms64m"'

# Execute Gradle
exec "$JAVACMD" $DEFAULT_JVM_OPTS \
    -Dorg.gradle.appname="$APP_BASE_NAME" \
    -classpath "$CLASSPATH" \
    org.gradle.wrapper.GradleWrapperMain \
    "$@"
