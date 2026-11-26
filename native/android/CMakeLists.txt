cmake_minimum_required(VERSION 3.18)
project(jbed_android LANGUAGES C CXX ASM)

if(NOT ANDROID OR NOT ANDROID_ABI STREQUAL "armeabi-v7a")
    message(FATAL_ERROR "The Jbed source runner requires Android ARM32")
endif()
if(NOT JBED_BOOT_IMAGE OR NOT EXISTS "${JBED_BOOT_IMAGE}")
    message(FATAL_ERROR "Build through Gradle to generate the boot image, or set JBED_BOOT_IMAGE to an existing image")
endif()

set(JBED_ANDROID_HEAP_BYTES 0 CACHE STRING "Managed heap size for the selected boot image")
option(JBED_ANDROID_INITIALIZE "Initialize the complete VM before invoking ROM methods" ON)
if(NOT JBED_ANDROID_HEAP_BYTES MATCHES "^[0-9]+$")
    message(FATAL_ERROR "JBED_ANDROID_HEAP_BYTES must be a nonnegative byte count")
endif()

get_filename_component(source_root "${CMAKE_CURRENT_SOURCE_DIR}/.." ABSOLUTE)
add_compile_options("-ffile-prefix-map=${source_root}=native"
    "-fdebug-prefix-map=${CMAKE_BINARY_DIR}=build")
add_subdirectory("${source_root}" runtime)

add_library(jbedsource_jni SHARED app/src/main/cpp/source_jni.c)
target_compile_features(jbedsource_jni PRIVATE c_std_11)
target_compile_options(jbedsource_jni PRIVATE -Wall -Wextra -Werror)
target_compile_definitions(jbedsource_jni PRIVATE JBED_ANDROID_HEAP_BYTES=${JBED_ANDROID_HEAP_BYTES}
    JBED_ANDROID_INITIALIZE=$<BOOL:${JBED_ANDROID_INITIALIZE}>)
target_link_options(jbedsource_jni PRIVATE -Wl,--no-undefined)
target_link_libraries(jbedsource_jni PRIVATE jbedruntime log android)
