include_guard(GLOBAL)

include(ExternalProject)
include(GNUInstallDirs)

function(dkyb_dependency_cache_root _out)
    if(DKYB_DEPENDENCY_CACHE_ROOT)
        set(${_out} "${DKYB_DEPENDENCY_CACHE_ROOT}" PARENT_SCOPE)
    else()
        set(_default_root "${CMAKE_BINARY_DIR}/.dkyb-dependency-cache")
        set(${_out} "${_default_root}" PARENT_SCOPE)
    endif()
endfunction()

function(dkyb_dependency_sanitize identifier _out)
    string(REGEX REPLACE "[^A-Za-z0-9]" "_" _clean "${identifier}")
    string(TOLOWER "${_clean}" _lower)
    set(${_out} "${_lower}" PARENT_SCOPE)
endfunction()

function(dkyb_dependency_register_argument NAME KEY VALUE)
    set(_prop_name "DKYB_DEP_${NAME}_${KEY}")
    set_property(GLOBAL PROPERTY "${_prop_name}" "${VALUE}")
endfunction()

function(dkyb_dependency_get_argument NAME KEY _out)
    set(_prop_name "DKYB_DEP_${NAME}_${KEY}")
    get_property(_value GLOBAL PROPERTY "${_prop_name}")
    if(_value)
        set(${_out} "${_value}" PARENT_SCOPE)
    else()
        set(${_out} "" PARENT_SCOPE)
    endif()
endfunction()

function(dkyb_register_dependency NAME)
    set(options)
    set(oneValueArgs GIT_REPOSITORY ARCHIVE_URL_TEMPLATE LATEST_ASSET_URL LATEST_GIT_TAG SOURCE_SUBDIR VERSION_TRANSFORM)
    set(multiValueArgs CMAKE_ARGS)
    cmake_parse_arguments(DKYB_DEP_REG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(DKYB_DEP_REG_GIT_REPOSITORY)
        dkyb_dependency_register_argument(${NAME} GIT_REPOSITORY "${DKYB_DEP_REG_GIT_REPOSITORY}")
    endif()
    if(DKYB_DEP_REG_ARCHIVE_URL_TEMPLATE)
        dkyb_dependency_register_argument(${NAME} ARCHIVE_URL_TEMPLATE "${DKYB_DEP_REG_ARCHIVE_URL_TEMPLATE}")
    endif()
    if(DKYB_DEP_REG_LATEST_ASSET_URL)
        dkyb_dependency_register_argument(${NAME} LATEST_ASSET_URL "${DKYB_DEP_REG_LATEST_ASSET_URL}")
    endif()
    if(DKYB_DEP_REG_LATEST_GIT_TAG)
        dkyb_dependency_register_argument(${NAME} LATEST_GIT_TAG "${DKYB_DEP_REG_LATEST_GIT_TAG}")
    endif()
    if(DKYB_DEP_REG_SOURCE_SUBDIR)
        dkyb_dependency_register_argument(${NAME} SOURCE_SUBDIR "${DKYB_DEP_REG_SOURCE_SUBDIR}")
    endif()
    if(DKYB_DEP_REG_CMAKE_ARGS)
        dkyb_dependency_register_argument(${NAME} CMAKE_ARGS "${DKYB_DEP_REG_CMAKE_ARGS}")
    endif()
    if(DKYB_DEP_REG_VERSION_TRANSFORM)
        dkyb_dependency_register_argument(${NAME} VERSION_TRANSFORM "${DKYB_DEP_REG_VERSION_TRANSFORM}")
    endif()
endfunction()

function(dkyb_dependency_record NAME VERSION KEY VALUE)
    dkyb_dependency_sanitize("${VERSION}" _version_key)
    set(_prop_name "DKYB_DEP_${NAME}_${_version_key}_${KEY}")
    set_property(GLOBAL PROPERTY "${_prop_name}" "${VALUE}")
endfunction()

function(dkyb_dependency_lookup NAME VERSION KEY _out)
    dkyb_dependency_sanitize("${VERSION}" _version_key)
    set(_prop_name "DKYB_DEP_${NAME}_${_version_key}_${KEY}")
    get_property(_value GLOBAL PROPERTY "${_prop_name}")
    if(_value)
        set(${_out} "${_value}" PARENT_SCOPE)
    else()
        set(${_out} "" PARENT_SCOPE)
    endif()
endfunction()

function(dkyb_dependency_resolve_version NAME VERSION _out)
    if(VERSION STREQUAL "latest")
        dkyb_dependency_get_argument(${NAME} LATEST_GIT_TAG _latest_git)
        if(_latest_git)
            set(${_out} "${_latest_git}" PARENT_SCOPE)
        else()
            set(${_out} "latest" PARENT_SCOPE)
        endif()
    else()
        set(${_out} "${VERSION}" PARENT_SCOPE)
    endif()
endfunction()

function(dkyb_fetch NAME VERSION)
    dkyb_dependency_resolve_version(${NAME} ${VERSION} _resolved_version)
    dkyb_dependency_cache_root(_cache_root)
    dkyb_dependency_sanitize("${_resolved_version}" _version_key)
    set(_target_root "${_cache_root}/${NAME}/${_version_key}")

    if(EXISTS "${_target_root}/.dkyb-fetch-ok")
        message(STATUS "${NAME}@${_resolved_version} already fetched; using cache at ${_target_root}")
        dkyb_dependency_record(${NAME} ${_resolved_version} FETCH_ROOT "${_target_root}")
        return()
    endif()

    file(MAKE_DIRECTORY "${_target_root}")
    dkyb_dependency_get_argument(${NAME} ARCHIVE_URL_TEMPLATE _template)
    dkyb_dependency_get_argument(${NAME} LATEST_ASSET_URL _latest_asset)

    dkyb_dependency_get_argument(${NAME} VERSION_TRANSFORM _version_transform)
    set(_template_version "${_resolved_version}")
    if(_version_transform STREQUAL "underscore")
        string(REPLACE "." "_" _template_version "${_template_version}")
    elseif(_version_transform STREQUAL "hyphen")
        string(REPLACE "." "-" _template_version "${_template_version}")
    endif()

    if(_resolved_version STREQUAL "latest" AND _latest_asset)
        set(_artifact_url "${_latest_asset}")
    elseif(_template)
        string(REPLACE "<version>" "${_template_version}" _artifact_url "${_template}")
    else()
        message(FATAL_ERROR "No download template recorded for dependency ${NAME}")
    endif()

    file(TIMESTAMP "${_target_root}" _unused OUTPUT_FORMAT UNIX)
    set(_asset_filename "${NAME}-${_resolved_version}.archive")
    set(_download_path "${_target_root}/${_asset_filename}")

    message(STATUS "Downloading ${NAME}@${_resolved_version} from ${_artifact_url}")
    file(DOWNLOAD
        ${_artifact_url}
        ${_download_path}
        SHOW_PROGRESS
        STATUS _download_status
        LOG log)
    list(GET _download_status 0 _status_code)
    if(NOT _status_code EQUAL 0)
        list(GET _download_status 1 _status_msg)
        message(FATAL_ERROR "Failed to download ${_artifact_url}: ${_status_msg}")
    endif()

    set(_extract_dir "${_target_root}/contents")
    file(MAKE_DIRECTORY "${_extract_dir}")
    file(ARCHIVE_EXTRACT INPUT "${_download_path}" DESTINATION "${_extract_dir}")

    file(WRITE "${_target_root}/.dkyb-fetch-ok" "${_resolved_version}")
    dkyb_dependency_record(${NAME} ${_resolved_version} FETCH_ROOT "${_extract_dir}")

    message(STATUS "Fetched ${NAME}@${_resolved_version} into ${_extract_dir}")
endfunction()

function(dkyb_build_and_cache NAME VERSION)
    dkyb_dependency_resolve_version(${NAME} ${VERSION} _resolved_version)
    dkyb_dependency_cache_root(_cache_root)
    dkyb_dependency_sanitize("${_resolved_version}" _version_key)

    dkyb_dependency_get_argument(${NAME} GIT_REPOSITORY _repo)
    if(NOT _repo)
        message(FATAL_ERROR "Dependency ${NAME} has no Git repository registered")
    endif()

    dkyb_dependency_get_argument(${NAME} SOURCE_SUBDIR _source_subdir)
    dkyb_dependency_get_argument(${NAME} CMAKE_ARGS _extra_cmake_args)

    if(_resolved_version STREQUAL "latest")
        dkyb_dependency_get_argument(${NAME} LATEST_GIT_TAG _git_tag)
        if(NOT _git_tag)
            set(_git_tag "main")
        endif()
    else()
        set(_git_tag "${_resolved_version}")
    endif()

    dkyb_dependency_sanitize("${NAME}" _name_key)
    dkyb_dependency_sanitize("${_resolved_version}" _version_key_sanitized)
    set(_target_name "dkyb_build_${_name_key}_${_version_key_sanitized}")

    if(TARGET ${_target_name})
        message(STATUS "Build target ${_target_name} already defined")
    else()
        set(_external_prefix "${_cache_root}/${NAME}/${_version_key}/external")
        set(_install_prefix "${_cache_root}/${NAME}/${_version_key}/install")
        set(_configure_args
            -DCMAKE_INSTALL_PREFIX=${_install_prefix}
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -S <SOURCE_DIR>
            -B <BINARY_DIR>
        )
        if(_extra_cmake_args)
            list(APPEND _configure_args ${_extra_cmake_args})
        endif()

        set(_external_args
            PREFIX "${_external_prefix}"
            GIT_REPOSITORY "${_repo}"
            GIT_TAG "${_git_tag}"
            CMAKE_ARGS ${_configure_args}
            UPDATE_DISCONNECTED ON
            INSTALL_DIR "${_install_prefix}"
        )
        if(_source_subdir)
            list(APPEND _external_args SOURCE_SUBDIR "${_source_subdir}")
        endif()

        message(STATUS "Configuring build for ${NAME}@${_resolved_version}")
        ExternalProject_Add(
            ${_target_name}
            ${_external_args}
        )
    endif()

    dkyb_dependency_record(${NAME} ${_resolved_version} BUILD_PREFIX "${_cache_root}/${NAME}/${_version_key}/install")
    dkyb_dependency_record(${NAME} ${_resolved_version} BUILD_TARGET ${_target_name})
endfunction()
