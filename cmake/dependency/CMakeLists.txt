cmake_minimum_required(VERSION 3.26.4)
project(DkybDependencyBuild LANGUAGES CXX)

execute_process(
    COMMAND git config --global url.https://github.com/.insteadOf git@github.com:
)

include(${CMAKE_SOURCE_DIR}/cmake-common/cmake/DkybDependency.cmake)
include(${CMAKE_SOURCE_DIR}/cmake-common/cmake/DkybDependencyRegistry.cmake)

set(_dependency_cache_root "${DKYB_DEPENDENCY_CACHE_ROOT}")
if(NOT _dependency_cache_root)
    set(_dependency_cache_root "${CMAKE_BINARY_DIR}/.dkyb-dependency-cache")
endif()

include(${CMAKE_SOURCE_DIR}/cmake-common/cmake/DkybDependencyRunner.cmake)
