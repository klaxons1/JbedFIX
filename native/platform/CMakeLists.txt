cmake_minimum_required(VERSION 3.16)
project(jbed_platform LANGUAGES C CXX)

find_package(ZLIB REQUIRED)
set(jpeg_sources
    jpeg6b/jcomapi.c jpeg6b/jdapimin.c jpeg6b/jdapistd.c jpeg6b/jdcoefct.c
    jpeg6b/jdcolor.c jpeg6b/jddctmgr.c jpeg6b/jdhuff.c jpeg6b/jdinput.c
    jpeg6b/jdmainct.c jpeg6b/jdmarker.c jpeg6b/jdmaster.c jpeg6b/jdphuff.c
    jpeg6b/jdpostct.c jpeg6b/jdsample.c jpeg6b/jerror.c jpeg6b/jidctint.c
    jpeg6b/jmemmgr.c jpeg6b/jmemnobs.c jpeg6b/jutils.c
)
add_library(jbedplatform STATIC
    ams.c media.c pim.c drm.c push.c push_sms.c push_storage.c
    display.c graphics.c graphics_jbni.c image.c png.c gif.c jpeg.c ${jpeg_sources}
    io/io_files.c io/io_files_jbni.c io/io_socket.c io/io_socket_jbni.c io/io_textfield.c
    io/io_zlib.c io/io_zlib_jbni.c vm/vm_async.c vm/vm_helpers.c vm/vm_lifecycle.c vm/vm_os.c
    vm/vm_poll.c vm/vm_properties.c vm/vm_trace.c vm/vm_upcall.c
)
target_compile_features(jbedplatform PRIVATE c_std_11)
target_include_directories(jbedplatform PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}" vm io android)
target_link_libraries(jbedplatform PUBLIC ZLIB::ZLIB)
if(ANDROID)
    target_sources(jbedplatform PRIVATE android/android_ams.c android/android_engine.c android/android_files.c
        android/android_jni.c android/android_locale.c android/android_media.c android/android_messaging.c android/android_midp.c
        android/android_phone.c android/android_pim.c android/android_textfield.c android/android_view.cpp)
    set_source_files_properties(android/android_view.cpp PROPERTIES COMPILE_OPTIONS "-fno-exceptions")
    target_link_libraries(jbedplatform PUBLIC log android jnigraphics)
    if(ANDROID_ABI STREQUAL "armeabi-v7a")
        set_source_files_properties(jpeg.c ${jpeg_sources} PROPERTIES COMPILE_OPTIONS "-fshort-enums")
    endif()
endif()
