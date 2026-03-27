include_guard(GLOBAL)

# Sample defaults for high-level dependencies that dkyb CMake projects might need.
# Consumers can override or extend these by calling dkyb_register_dependency again.

dkyb_register_dependency(boost
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    ARCHIVE_URL_TEMPLATE https://boostorg.jfrog.io/artifactory/main/release/<version>/source/boost_<version>.tar.gz
    VERSION_TRANSFORM underscore
    GIT_TAG_TEMPLATE boost-<version>
    CMAKE_ARGS -DBOOST_SUPPRESS_DEPRECATED_FEATURES=ON -DBUILD_TESTING=OFF
)

dkyb_register_dependency(gtest
    GIT_REPOSITORY https://github.com/google/googletest.git
    ARCHIVE_URL_TEMPLATE https://github.com/google/googletest/archive/refs/tags/v<version>.zip
    GIT_TAG_TEMPLATE v<version>
)

dkyb_register_dependency(debugtrace
    GIT_REPOSITORY https://github.com/kingkybel/DebugTrace.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(typetraits
    GIT_REPOSITORY https://github.com/kingkybel/TypeTraits.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(containerconvert
    GIT_REPOSITORY https://github.com/kingkybel/ContainerConvert.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(stringutilities
    GIT_REPOSITORY https://github.com/kingkybel/StringUtilities.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(performancetimer
    GIT_REPOSITORY https://github.com/kingkybel/PerformanceTimer.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(jsonobject
    GIT_REPOSITORY https://github.com/kingkybel/JsonObject.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(messagetoobject
    GIT_REPOSITORY https://github.com/kingkybel/MessageToObject.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(threadutilities
    GIT_REPOSITORY https://github.com/kingkybel/ThreadUtilities.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(ringbuffer
    GIT_REPOSITORY https://github.com/kingkybel/RingBuffer.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(directedgraph
    GIT_REPOSITORY https://github.com/kingkybel/DirectedGraph.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(fastfurioustransformation
    GIT_REPOSITORY https://github.com/kingkybel/FastFuriousTransformation.git
    GIT_TAG_TEMPLATE main
)

dkyb_register_dependency(fixdecoder
    GIT_REPOSITORY https://github.com/kingkybel/FixDecoder.git
    GIT_TAG_TEMPLATE main
)
