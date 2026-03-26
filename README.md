![CMakeCommon banner](assets/banners/cmake_common_banner.svg)

# CMake Common

Reusable CMake settings for dkyb C++ repositories.

## What it standardizes

- Build types: `Debug`, `Release`, `RelWithDebInfo`, `MinSizeRel`, `Coverage`, `Performance`
- Default build type: `RelWithDebInfo`
- Output directories:
  - `${binary_dir}/${config}/bin`
  - `${binary_dir}/${config}/lib`
- Language defaults:
  - `CMAKE_CXX_STANDARD=23`
  - `CMAKE_CXX_EXTENSIONS=OFF`
  - `CMAKE_EXPORT_COMPILE_COMMANDS=ON`
- Baseline flags:
  - Common: `-rdynamic -Wall -Werror`
  - Coverage: gcov/coverage flags
  - Performance: `-O3 -DNDEBUG -march=native -flto`

## Consumer usage

### Option A: Git submodule (most reproducible)

```bash
git submodule add https://github.com/kingkybel/cmake-common.git cmake-common
git submodule update --init --recursive
```

Then in your root `CMakeLists.txt`:

```cmake
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake-common/cmake/DkybBuildSettings.cmake)
dkyb_apply_common_settings()
```

### Option B: FetchContent

```cmake
include(FetchContent)
FetchContent_Declare(
    dkyb_cmake_common
    GIT_REPOSITORY https://github.com/kingkybel/cmake-common.git
    GIT_TAG v0.1.0
)
FetchContent_MakeAvailable(dkyb_cmake_common)
include(${dkyb_cmake_common_SOURCE_DIR}/cmake/DkybBuildSettings.cmake)
dkyb_apply_common_settings()
```

Pin to a tag for stable/reproducible builds.
## Dependency helpers

`cmake/DkybDependency.cmake` introduces lightweight helpers for fetching and caching common third-party artifacts. Consumers can register dependencies (GitHub repos, archive URLs, version transforms) once and then call `dkyb_fetch(<name>, <version>)` or `dkyb_build_and_cache(<name>, <version>)` from their own `CMakeLists.txt`.

```cmake
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/DkybDependency.cmake)
include(${CMAKE_CURRENT_SOURCE_DIR}/cmake/DkybDependencyRegistry.cmake) # optional registry for boost/gtest

# fetch a release archive if it is missing locally
set(DKYB_DEPENDENCY_CACHE_ROOT "${CMAKE_BINARY_DIR}/.dkyb-deps")
dkyb_fetch(DebugTrace latest)

# build a heavy dependency once on CI, then reuse the install tree
dkyb_build_and_cache(boost 1.90.0)
dkyb_dependency_lookup(boost 1.90.0 BUILD_PREFIX boost_install)
list(APPEND CMAKE_PREFIX_PATH "${boost_install}")
```

Use `dkyb_dependency_lookup(<name> <version> FETCH_ROOT <var>)` or `BUILD_PREFIX` after calling the helpers to expose the downloaded/install tree to the rest of your project.

`cmake/DkybDependencyRegistry.cmake` ships sample entries for `boost` and `gtest` and can be copied or extended in consumer repositories.

### Runner + workflow

`cmake/dependency/CMakeLists.txt` and `cmake/DkybDependencyRunner.cmake` expose a tiny driver that exposes a `dkyb_dependency_runner` target. The reusable workflow at `.github/workflows/dependency-cache.yml` can be called from any repository to build/cache a dependency and upload the resulting directory as an artifact.

Example workflow usage (in another repo):

```yaml
jobs:
  cache-boost:
    uses: kingkybel/cmake-common/.github/workflows/dependency-cache.yml@main
    with:
      dependency-name: boost
      dependency-version: 1.90.0
      build: true
```

The workflow restores the `build/dkyb-cache` directory, configures `cmake/dependency` with the requested dependency, builds `dkyb_dependency_runner`, and uploads the cached outputs. Subsequent workflow consumers can either download the artifact or restore the cache key to reuse the built files.
