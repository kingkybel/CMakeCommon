include_guard(GLOBAL)

if(NOT DEFINED DKYB_DEPENDENCY_NAME)
    message(FATAL_ERROR "DKYB_DEPENDENCY_NAME must be set before including DkybDependencyRunner.cmake")
endif()

if(NOT DEFINED DKYB_DEPENDENCY_VERSION)
    set(DKYB_DEPENDENCY_VERSION latest)
endif()

if(NOT DEFINED DKYB_DEPENDENCY_BUILD)
    set(DKYB_DEPENDENCY_BUILD OFF)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/DkybDependency.cmake)

add_custom_target(dkyb_dependency_runner)

if(DKYB_DEPENDENCY_BUILD)
    message(STATUS "Building and caching ${DKYB_DEPENDENCY_NAME}@${DKYB_DEPENDENCY_VERSION}")
    dkyb_build_and_cache(${DKYB_DEPENDENCY_NAME} ${DKYB_DEPENDENCY_VERSION})
    dkyb_dependency_lookup(${DKYB_DEPENDENCY_NAME} ${DKYB_DEPENDENCY_VERSION} BUILD_TARGET _build_target)
    if(_build_target)
        add_dependencies(dkyb_dependency_runner ${_build_target})
    endif()
else()
    message(STATUS "Fetching ${DKYB_DEPENDENCY_NAME}@${DKYB_DEPENDENCY_VERSION}")
    dkyb_fetch(${DKYB_DEPENDENCY_NAME} ${DKYB_DEPENDENCY_VERSION})
endif()
