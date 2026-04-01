#!/usr/bin/env bash
set -euo pipefail

# Builds each dependency listed in DEPENDENCY_LIST using the reusable dependency runner.
# Expects these environment variables to be set:
#   DEPENDENCY_LIST (newline-separated entries like "name:version")
#   DKYB_DEPENDENCY_CACHE_ROOT (cache directory under build/dkyb-cache)
#   INSTALL_PREFIX (directory where dependencies should be installed/nt prefixed)
#   DEPENDENCY_BUILD_TYPE (CMake configuration, defaults to Release)
#   GITHUB_WORKSPACE (defaults to current directory)

DEPENDENCY_LIST="${DEPENDENCY_LIST:-}"
if [[ -z "$(printf '%s' "$DEPENDENCY_LIST" | tr -d '[:space:]')" ]]; then
  echo "No dependencies configured"
  exit 0
fi

DKYB_DEPENDENCY_CACHE_ROOT="${DKYB_DEPENDENCY_CACHE_ROOT:-${PWD}/build/dkyb-cache}"
INSTALL_PREFIX="${INSTALL_PREFIX:-${PWD}/build/dkyb-install}"
DEPENDENCY_BUILD_TYPE="${DEPENDENCY_BUILD_TYPE:-Release}"
GITHUB_WORKSPACE="${GITHUB_WORKSPACE:-${PWD}}"

sanitize() {
  local value="$1"
  printf '%s' "$value" | sed 's/[^A-Za-z0-9]/_/g' | tr '[:upper:]' '[:lower:]'
}

trimmed_dependencies="${DEPENDENCY_LIST}"

echo "Building dependencies from list:"
printf '%s
' "$trimmed_dependencies"

while IFS= read -r line || [[ -n "$line" ]]; do
  line=$(printf '%s' "$line" | tr -d '\r')
  line=${line%%#*}
  line=$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//;s/[[:space:]]+$//')
  if [[ -z "$line" ]]; then
    continue
  fi

  name=${line%%:*}
  version=${line#*:}
  if [[ "$name" == "$line" ]]; then
    echo "Warning: dependency entry '$line' does not contain ':'; using version 'latest'."
    version=latest
  fi
  version=${version:-latest}

  sanitized_version=$(sanitize "$version")
  cache_dir="${DKYB_DEPENDENCY_CACHE_ROOT}/${name}/${sanitized_version}"
  if [[ -f "${cache_dir}/.dkyb-build-ok" ]]; then
    echo "Dependency ${name}@${version} already built; skipping."
    continue
  fi

  build_dir="${GITHUB_WORKSPACE}/build/dependency-${name}-${sanitized_version}"
  cmake -S cmake-common/cmake/dependency -B "$build_dir" \
    -DDKYB_DEPENDENCY_NAME=${name} \
    -DDKYB_DEPENDENCY_VERSION=${version} \
    -DDKYB_DEPENDENCY_BUILD=ON \
    -DDKYB_DEPENDENCY_CACHE_ROOT=${DKYB_DEPENDENCY_CACHE_ROOT} \
    -DDKYB_DEPENDENCY_SYSTEM_INSTALL_PREFIX=${INSTALL_PREFIX} \
    -DDKYB_DEPENDENCY_SYSTEM_INSTALL_USE_SUDO=OFF \
    -DCMAKE_BUILD_TYPE=${DEPENDENCY_BUILD_TYPE}
  cmake --build "$build_dir" --target dkyb_dependency_runner --config ${DEPENDENCY_BUILD_TYPE}
  mkdir -p "$cache_dir"
  touch "$cache_dir/.dkyb-build-ok"
done <<< "$trimmed_dependencies"
