cmake_minimum_required(VERSION 3.18)
project(jbed_source LANGUAGES C CXX ASM)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)
option(JBED_BUILD_HOST_TESTS "Build self-contained native tests (no original VM required)" OFF)
if(JBED_BUILD_HOST_TESTS)
    if(ANDROID)
        message(FATAL_ERROR "JBED_BUILD_HOST_TESTS requires a host build")
    endif()
    enable_testing()
    add_executable(jbed_png_compat_test compat/tests/png_compat_test.c)
    target_compile_features(jbed_png_compat_test PRIVATE c_std_11)
    target_compile_options(jbed_png_compat_test PRIVATE -UNDEBUG)
    add_test(NAME png_compat COMMAND jbed_png_compat_test)
    add_executable(jbed_drm_compat_test compat/tests/drm_compat_test.c compat/libdrm1.c)
    target_compile_features(jbed_drm_compat_test PRIVATE c_std_11)
    target_compile_options(jbed_drm_compat_test PRIVATE -UNDEBUG -Wall -Wextra -Werror)
    add_test(NAME drm_compat COMMAND jbed_drm_compat_test)
    add_executable(jbed_guest_layout_test runtime/tests/guest_layout_test.c
        runtime/guest_writer.c runtime/guest_rom.c runtime/guest_blocks.c runtime/guest_queue.c runtime/guest_stackmap.c)
    target_include_directories(jbed_guest_layout_test PRIVATE runtime)
    target_link_libraries(jbed_guest_layout_test PRIVATE jbedcompiler)
    target_compile_options(jbed_guest_layout_test PRIVATE -UNDEBUG -Wall -Wextra -Werror -Wpedantic)
    add_test(NAME guest_layout COMMAND jbed_guest_layout_test)
endif()
add_subdirectory(compiler)
add_subdirectory(platform)
add_subdirectory(swerve)

set(runtime_sources runtime/boot_image.c runtime/bindings.c runtime/jbni.c
    runtime/arithmetic.c runtime/signals.c)
if(ANDROID AND ANDROID_ABI STREQUAL "armeabi-v7a")
    target_compile_definitions(jbedcompiler PUBLIC JBED_NATIVE_ADDRESS_SPACE=1)
    list(APPEND runtime_sources runtime/arm32.c runtime/arm32.S runtime/execution.c compat/libdrm1.c
        runtime/class_init.c runtime/reflection.c runtime/events.c runtime/instance.c
        runtime/native_call.c runtime/roots.c runtime/monitor_init.c runtime/metadata_init.c
        runtime/rom_reflection.c runtime/collector_init.c runtime/trace.c runtime/memory.c
        runtime/arch.c runtime/compiler.c runtime/signature_encoder.c runtime/isolate.c
        runtime/code_cache.c runtime/field.c runtime/lifecycle.c runtime/class_access.c
        runtime/scheduler.c runtime/java_string.c runtime/sysinfo.c runtime/array.c
        runtime/bundle.c runtime/guest_writer.c runtime/guest_rom.c runtime/guest_call.c
        runtime/guest_blocks.c runtime/deep_copy.c runtime/guest_queue.c runtime/guest_stackmap.c)
    add_library(jbedruntime SHARED ${runtime_sources})
    set_target_properties(jbedplatform PROPERTIES C_VISIBILITY_PRESET hidden
        CXX_VISIBILITY_PRESET hidden VISIBILITY_INLINES_HIDDEN YES)
    target_compile_options(jbedplatform PRIVATE -ffunction-sections -fdata-sections)
    target_compile_options(jbedruntime PRIVATE -mthumb -ffp-contract=off)
    target_link_options(jbedruntime PRIVATE -Wl,--no-undefined -Wl,--gc-sections
        -Wl,-u,jbed_android_initialize)
else()
    add_library(jbedruntime STATIC ${runtime_sources})
endif()
target_compile_features(jbedruntime PUBLIC c_std_11)
target_include_directories(jbedruntime PUBLIC runtime)
target_link_libraries(jbedruntime PUBLIC jbedcompiler PRIVATE jbedplatform jbedswerve)
if(UNIX AND NOT APPLE)
    target_link_libraries(jbedruntime PRIVATE m)
endif()

set(JBED_BOOT_IMAGE "" CACHE FILEPATH "Generated C boot image to link into jbedruntime")
if(JBED_BOOT_IMAGE)
    target_sources(jbedruntime PRIVATE "${JBED_BOOT_IMAGE}")
endif()
