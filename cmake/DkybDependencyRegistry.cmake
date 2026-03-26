include_guard(GLOBAL)

# Sample defaults for high-level dependencies that dkyb CMake projects might need.
# Consumers can override or extend these by calling dkyb_register_dependency again.

dkyb_register_dependency(boost
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    ARCHIVE_URL_TEMPLATE https://boostorg.jfrog.io/artifactory/main/release/<version>/source/boost_<version>.tar.gz
    VERSION_TRANSFORM underscore
    CMAKE_ARGS -DBOOST_SUPPRESS_DEPRECATED_FEATURES=ON -DBUILD_TESTING=OFF
)

dkyb_register_dependency(gtest
    GIT_REPOSITORY https://github.com/google/googletest.git
    ARCHIVE_URL_TEMPLATE https://github.com/google/googletest/archive/refs/tags/release-<version>.zip
)
