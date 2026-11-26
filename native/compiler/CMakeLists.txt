cmake_minimum_required(VERSION 3.16)
project(jbed_compiler LANGUAGES C)

find_package(ZLIB REQUIRED)

add_library(jbedcompiler STATIC
    compiler.c
    runtime.c
    reader.c
    pool.c
    verifier.c
    coder.c
    emitter.c
    optlist.c
    thumb.c
    writer.c
    writer_arm.c
    code_block.c
    stack_map.c
    block_stream.c
    rom_objects.c
    class_access.c
    vm/vm_types.c
    vm/vm_memory.c
    vm/vm_strings.c
    vm/vm_mark.c
    vm/vm_collector.c
    vm/vm_compactor.c
    vm/vm_compact_roots.c
    vm/vm_stackmap.c
    vm/vm_exception.c
    vm/vm_monitor.c
    vm/vm_scheduler.c
    method_ranges.c
    reflection_table.c
    signatures.c
)
target_compile_features(jbedcompiler PUBLIC c_std_11)
target_include_directories(jbedcompiler PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" vm)
target_link_libraries(jbedcompiler PUBLIC ZLIB::ZLIB)
if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
    target_compile_options(jbedcompiler PRIVATE -Wall -Wextra -Werror -Wpedantic)
endif()

option(JBED_BUILD_HOST_COMPILER "Build the offline JAR compiler (requires libzip)" OFF)
if(JBED_BUILD_HOST_COMPILER)
    # Ubuntu's libzip CMake export also imports optional command-line tools
    # (zipcmp, zipmerge, ziptool), which need not be installed with libzip-dev.
    # Import only the library via pkg-config; the ROM tools do not use those
    # executables. Keep this host-only so Android needs no libzip installation.
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(JBED_LIBZIP REQUIRED IMPORTED_TARGET libzip)
    add_executable(jbedc host/jbedc.c host/host_inputs.c)
    target_link_libraries(jbedc PRIVATE jbedcompiler PkgConfig::JBED_LIBZIP)
    add_executable(jbedrom host/jbedrom.c host/host_inputs.c)
    target_link_libraries(jbedrom PRIVATE jbedcompiler PkgConfig::JBED_LIBZIP)
    if(CMAKE_C_COMPILER_ID MATCHES "Clang|GNU")
        target_compile_options(jbedc PRIVATE -Wall -Wextra -Wpedantic)
        target_compile_options(jbedrom PRIVATE -Wall -Wextra -Wpedantic)
    endif()
endif()

# This small protocol driver lets the Python test compare C results with the
# original ARM instructions under Unicorn. It is not part of the APK build.
add_executable(jbedcompiler_oracle EXCLUDE_FROM_ALL tests/oracle_bridge.c)
target_link_libraries(jbedcompiler_oracle PRIVATE jbedcompiler)

add_executable(jbedcompiler_verifier_test EXCLUDE_FROM_ALL tests/verifier_test.c)
target_link_libraries(jbedcompiler_verifier_test PRIVATE jbedcompiler)

add_executable(jbedcompiler_signature_oracle EXCLUDE_FROM_ALL tests/signature_oracle.c)
target_link_libraries(jbedcompiler_signature_oracle PRIVATE jbedcompiler)

add_executable(jbedcompiler_thumb_smoke EXCLUDE_FROM_ALL tests/thumb_smoke.c)
target_link_libraries(jbedcompiler_thumb_smoke PRIVATE jbedcompiler)

add_executable(jbedcompiler_reader_pool_test EXCLUDE_FROM_ALL tests/reader_pool_test.c)
target_link_libraries(jbedcompiler_reader_pool_test PRIVATE jbedcompiler)

add_executable(jbedcompiler_block_stream_test EXCLUDE_FROM_ALL tests/block_stream_test.c)
target_link_libraries(jbedcompiler_block_stream_test PRIVATE jbedcompiler)

add_executable(jbedcompiler_coder_test EXCLUDE_FROM_ALL tests/coder_test.c)
target_link_libraries(jbedcompiler_coder_test PRIVATE jbedcompiler)

foreach(test IN ITEMS vm_exception vm_memory vm_mark vm_types vm_stackmap vm_compactor vm_monitor)
    add_executable(jbedcompiler_${test}_test EXCLUDE_FROM_ALL tests/${test}_test.c)
    target_link_libraries(jbedcompiler_${test}_test PRIVATE jbedcompiler)
endforeach()
target_sources(jbedcompiler_vm_types_test PRIVATE tests/class_access_test.c)

option(JBED_BUILD_HOST_TESTS "Build self-contained native tests (no original VM required)" OFF)
if(JBED_BUILD_HOST_TESTS)
    if(ANDROID)
        message(FATAL_ERROR "JBED_BUILD_HOST_TESTS requires a host build")
    endif()
    enable_testing()
    add_executable(jbedcompiler_rom_format_test tests/rom_format_check.c)
    target_link_libraries(jbedcompiler_rom_format_test PRIVATE jbedcompiler)
    # The other fixtures need the original ELF and are intentionally not
    # registered here. Never silently skip them and call that full coverage.
    foreach(test IN ITEMS verifier reader_pool block_stream coder rom_format
            vm_exception vm_memory vm_mark vm_compactor vm_monitor)
        set(target jbedcompiler_${test}_test)
        set_target_properties(${target} PROPERTIES EXCLUDE_FROM_ALL FALSE)
        # Assertions are the test oracle, including in Release host builds.
        target_compile_options(${target} PRIVATE -UNDEBUG)
        add_test(NAME ${test} COMMAND ${target})
    endforeach()
endif()
