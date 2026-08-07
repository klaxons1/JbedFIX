#!/bin/sh

# Directory containing the wrapper jar
WRAPPER_DIR="gradle/wrapper"
WRAPPER_JAR="$WRAPPER_DIR/gradle-wrapper.jar"

# If the wrapper jar doesn't exist, download it!
if [ ! -f "$WRAPPER_JAR" ]; then
    echo "gradle-wrapper.jar not found, downloading..."
    mkdir -p "$WRAPPER_DIR"
    
    # We will try several reliable, non-LFS repository URLs to download the actual binary jar
    for url in \
        "https://raw.githubusercontent.com/apache/kafka/trunk/gradle/wrapper/gradle-wrapper.jar" \
        "https://raw.githubusercontent.com/square/retrofit/master/gradle/wrapper/gradle-wrapper.jar" \
        "https://raw.githubusercontent.com/spring-projects/spring-boot/main/gradle/wrapper/gradle-wrapper.jar"
    do
        echo "Trying to download from $url..."
        if curl -sLo "$WRAPPER_JAR" "$url" || wget -qO "$WRAPPER_JAR" "$url"; then
            # Verify the downloaded file is a valid ZIP/JAR (starts with 'PK')
            # Use 'od' or 'head' in a safe way to check ZIP magic number
            if head -c 2 "$WRAPPER_JAR" | grep -q "^PK"; then
                echo "Successfully downloaded and verified gradle-wrapper.jar!"
                break
            else
                echo "Downloaded file from $url was invalid/corrupt (e.g. Git LFS pointer), trying next..."
                rm -f "$WRAPPER_JAR"
            fi
        fi
    done
fi

if [ -f "$WRAPPER_JAR" ]; then
    exec java -jar "$WRAPPER_JAR" "$@"
else
    echo "ERROR: Failed to download gradle-wrapper.jar, falling back to system 'gradle'"
    exec gradle "$@"
fi
