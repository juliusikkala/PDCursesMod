
IF (PDC_SDL2_DEPS_BUILD)

    INCLUDE(ExternalProject)

    IF(NOT WIN32)
        set(FLAGS_FOR_DYNAMIC_LINK -fPIC) 
    ENDIF()

    SET(SDL2_RELEASE 2.32.8)
    ExternalProject_Add(sdl2_ext
        GIT_REPOSITORY "https://github.com/libsdl-org/SDL.git"
        GIT_TAG "release-${SDL2_RELEASE}"
        GIT_SHALLOW true
        UPDATE_COMMAND ""
        DOWNLOAD_DIR ${CMAKE_BINARY_DIR}
        SOURCE_DIR ${CMAKE_BINARY_DIR}/SDL2-${SDL2_RELEASE}
        BUILD_IN_SOURCE 0
        CMAKE_ARGS
            ${SDL_CMAKE_BUILD_OPTS}
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
            -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
        )

    MESSAGE(STATUS "SDL2 Installing to: ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
    SET(SDL2_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/include/SDL2)
    SET(SDL2_LIBRARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
    IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        IF(WIN32)
            set(SDL2_LIBRARIES "SDL2main.lib;SDL2.lib")
            set(SDL2_LIBRARY "SDL2.lib")
        ELSEIF(APPLE)
            set(SDL2_LIBRARIES "SDL2main;SDL2")
            set(SDL2_LIBRARY "SDL2")
        ELSE()
            set(SDL2_LIBRARIES "SDL2main;SDL2-2.0")
            set(SDL2_LIBRARY "SDL2-2.0")
        ENDIF()
    ELSE()
        IF(WIN32)
            set(SDL2_LIBRARIES "SDL2main.lib;SDL2.lib")
            set(SDL2_LIBRARY "SDL2.lib")
        ELSEIF(APPLE)
            set(SDL2_LIBRARIES "SDL2main;SDL2")
            set(SDL2_LIBRARY "SDL2")
        ELSE()
            set(SDL2_LIBRARIES "SDL2main;SDL2-2.0")
            set(SDL2_LIBRARY "SDL2-2.0")
        ENDIF()
    ENDIF()

    IF (PDC_WIDE OR PDC_UTF8 OR PDC_GL_BUILD)

        ExternalProject_Add(zlib_ext
            GIT_REPOSITORY "https://github.com/madler/zlib.git"
            GIT_TAG "v1.2.11"
            GIT_SHALLOW true
            UPDATE_COMMAND ""
            DOWNLOAD_DIR ${CMAKE_BINARY_DIR}
            SOURCE_DIR ${CMAKE_BINARY_DIR}/zlib
            BUILD_IN_SOURCE 1
            CMAKE_ARGS
                ${ZLIB_CMAKE_BUILD_OPTS}
                -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
                -DCMAKE_C_FLAGS=${EXTERNAL_C_FLAGS}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DBUILD_SHARED_LIBS=${BUILD_SHARED}
                -DAMD64=${ZLIB_AMD64}
                -DASM686=${ZLIB_ASM686}
            )

        MESSAGE(STATUS "zlib Installing to: ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
        SET(ZLIB_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/include)
        SET(ZLIB_LIBRARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
        IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            IF(WIN32)
                set(ZLIB_LIBRARY zlib.lib)
            ELSE()
                set(ZLIB_LIBRARY z)
            ENDIF()
        ELSE()
            IF(WIN32)
                set(ZLIB_LIBRARY zlib.lib)
            ELSE()
                set(ZLIB_LIBRARY z)
            ENDIF()
        ENDIF()

        ExternalProject_Add(freetype2_ext
            GIT_REPOSITORY "https://git.savannah.gnu.org/git/freetype/freetype2.git"
            GIT_TAG "VER-2-12-1"
            GIT_SHALLOW true
            UPDATE_COMMAND ""
            DOWNLOAD_DIR ${CMAKE_BINARY_DIR}
            SOURCE_DIR ${CMAKE_BINARY_DIR}/freetype2
            BUILD_IN_SOURCE 0
            CMAKE_ARGS
                ${FT2_CMAKE_BUILD_OPTS}
                -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
                -DCMAKE_C_FLAGS=${FLAGS_FOR_DYNAMIC_LINK} ${EXTERNAL_C_FLAGS}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DFT_DISABLE_HARFBUZZ=ON
                -DFT_DISABLE_BZIP2=ON
                -DFT_DISABLE_PNG=ON
                -DFT_DISABLE_BROTLI=ON
                -DWITH_ZLIB=ON
                -DZLIB_FOUND=ON
                -DZLIB_LIBRARY=${ZLIB_LIBRARY}
                -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}
                -DZLIB_LIBRARY_DIR=${ZLIB_LIBRARY_DIR}
            )

        ADD_DEPENDENCIES(freetype2_ext zlib_ext)
        MESSAGE(STATUS "freetype2 Installing to: ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
        SET(FT2_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/include/freetype2)
        SET(FT2_LIBRARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
        IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            IF(WIN32)
                set(FT2_LIBRARY freetype.lib)
            ELSE()
                set(FT2_LIBRARY freetype)
            ENDIF()
        ELSE()
            IF(WIN32)
                set(FT2_LIBRARY freetype.lib)
            ELSE()
                set(FT2_LIBRARY freetype)
            ENDIF()
        ENDIF()        
        
        SET(SDL2_TTF_RELEASE 2.20.1)

        ExternalProject_Add(sdl2_ttf_ext
            GIT_REPOSITORY "https://github.com/libsdl-org/SDL_ttf.git"
            GIT_TAG "release-${SDL2_TTF_RELEASE}"
            GIT_SHALLOW true
            PATCH_COMMAND cmake -E copy 
            ${CMAKE_CURRENT_SOURCE_DIR}/cmake/sdl2_ttf/CMakeLists.txt 
            ${CMAKE_BINARY_DIR}/sdl2_ttf/CMakeLists.txt
            UPDATE_COMMAND ""
            DOWNLOAD_DIR ${CMAKE_BINARY_DIR}
            SOURCE_DIR ${CMAKE_BINARY_DIR}/sdl2_ttf
            BUILD_IN_SOURCE 0
            CMAKE_ARGS
                ${SDL2_TTF_CMAKE_BUILD_OPTS}
                -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
                -DCMAKE_INSTALL_PREFIX=${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}
                -DCMAKE_C_FLAGS=${EXTERNAL_C_FLAGS}
                -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                -DSDL2_TTF_RELEASE=${SDL2_TTF_RELEASE}
                -DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}
                -DZLIB_LIBRARY_DIR=${ZLIB_LIB_DIR}
                -DZLIB_LIBRARY=${ZLIB_LIBRARY}
                -DFT2_INCLUDE_DIR=${FT2_INCLUDE_DIR}
                -DFT2_LIBRARY_DIR=${FT2_LIBRARY_DIR}
                -DFT2_LIBRARY=${FT2_LIBRARY}
                -DSDL2_INCLUDE_DIR=${SDL2_INCLUDE_DIR}
                -DSDL2_LIBRARY_DIR=${SDL2_LIBRARY_DIR}
                -DSDL2_LIBRARY=${SDL2_LIBRARY}
                -DSDL2_LIBRARIES=${SDL2_LIBRARIES}
            )

        ADD_DEPENDENCIES(sdl2_ttf_ext sdl2_ext freetype2_ext)
        MESSAGE(STATUS "SDL2_ttf Installing to: ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")
        SET(SDL2_TTF_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/include/SDL2_ttf)
        SET(SDL2_TTF_LIBRARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib)
        IF("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
            IF(WIN32)
                set(SDL2_TTF_LIBRARY "SDL2_ttf.lib")
            ELSE()
                set(SDL2_TTF_LIBRARY "SDL2_ttf")
            ENDIF()
        ELSE()
            IF(WIN32)
                set(SDL2_TTF_LIBRARY "SDL2_ttf.lib")
            ELSE()
                set(SDL2_TTF_LIBRARY "SDL2_ttf")
            ENDIF()
        ENDIF()

    ENDIF (PDC_WIDE OR PDC_UTF8)

ENDIF()
