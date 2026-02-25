include_guard(GLOBAL)

function(dkyb_apply_common_settings)
    set(options)
    set(oneValueArgs CXX_STANDARD)
    set(multiValueArgs EXTRA_CXX_FLAGS)
    cmake_parse_arguments(DKYB "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT DKYB_CXX_STANDARD)
        set(DKYB_CXX_STANDARD 23)
    endif ()

    # Build type defaults and allowed values (single-config + multi-config generators).
    if (NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Build type" FORCE)
    endif ()

    set(_dkyb_build_types "Debug;Release;RelWithDebInfo;MinSizeRel;Coverage;Performance")
    set(CMAKE_BUILD_TYPE "${CMAKE_BUILD_TYPE}" CACHE STRING "Build type" FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${_dkyb_build_types})

    if (CMAKE_CONFIGURATION_TYPES)
        set(CMAKE_CONFIGURATION_TYPES "${_dkyb_build_types}" CACHE STRING "Configs" FORCE)
    endif ()

    # Uniform output layout for all generators.
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/bin")
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib")
    set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/lib")

    foreach(_cfg IN ITEMS DEBUG RELEASE RELWITHDEBINFO MINSIZEREL COVERAGE PERFORMANCE)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_${_cfg} "${CMAKE_BINARY_DIR}/${_cfg}/bin")
        set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_${_cfg} "${CMAKE_BINARY_DIR}/${_cfg}/lib")
        set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_${_cfg} "${CMAKE_BINARY_DIR}/${_cfg}/lib")
    endforeach ()

    set(_dkyb_base_flags "-rdynamic -Wall -Werror")
    if (DKYB_EXTRA_CXX_FLAGS)
        string(JOIN " " _dkyb_extra_flags ${DKYB_EXTRA_CXX_FLAGS})
        set(_dkyb_base_flags "${_dkyb_base_flags} ${_dkyb_extra_flags}")
    endif ()

    set(_dkyb_coverage_flags "-g -O0 -fno-default-inline --coverage -fprofile-abs-path -fprofile-arcs -fno-inline -fno-inline-small-functions -ftest-coverage -lgcov")
    set(_dkyb_performance_flags "-O3 -DNDEBUG -march=native -flto")

    set(CMAKE_CXX_FLAGS "${_dkyb_base_flags}" CACHE STRING "Default C++ compiler flags" FORCE)
    set(CMAKE_CXX_FLAGS_DEBUG "-g" CACHE STRING "g++ debug flags" FORCE)
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-g -O2" CACHE STRING "g++ rel+dbg flags" FORCE)
    set(CMAKE_CXX_FLAGS_RELEASE "-O2" CACHE STRING "g++ release flags" FORCE)
    set(CMAKE_CXX_FLAGS_COVERAGE "${_dkyb_coverage_flags}" CACHE STRING "g++ coverage flags" FORCE)
    set(CMAKE_CXX_FLAGS_PERFORMANCE "${_dkyb_performance_flags}" CACHE STRING "g++ performance flags" FORCE)

    set(CMAKE_CXX_STANDARD ${DKYB_CXX_STANDARD})
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    set(CMAKE_CXX_EXTENSIONS OFF)
    set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

    message(STATUS "BUILD TYPE ${CMAKE_BUILD_TYPE}")
endfunction()
