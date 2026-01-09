cmake_minimum_required(VERSION 3.24)

set(PROJECT_TARGET_NAME "app")

if(NOT DEFINED PROJECT_BASE_DIR)
    set(PROJECT_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../..")
    get_filename_component(PROJECT_BASE_DIR ${PROJECT_BASE_DIR} REALPATH)
endif()
if(NOT DEFINED PROJECT_LIB_DIR)
    set(PROJECT_LIB_DIR "${PROJECT_BASE_DIR}/lib")
endif()

set(PROJECT_SRC_DIR "${PROJECT_LIB_DIR}/ubinos_base/app/helloworld_c")

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_config.cmake")

include("${PROJECT_LIB_DIR}/ubinos_base/common/common_c_cpp_native_remote_pre.cmake")

project(${PROJECT_TARGET_NAME} C CXX ASM)

##
set(PROJECT_MAIN_APP "${PROJECT_TARGET_NAME}")
set(PROJECT_MAIN_APP_OPTION "")
set(PROJECT_MAIN_APP_DIR "${CMAKE_CURRENT_BINARY_DIR}")

##
file(GLOB_RECURSE APP_SOURCES CONFIGURE_DEPENDS
    "${PROJECT_SRC_DIR}/*.c"
    "${PROJECT_SRC_DIR}/*.cpp"
)

add_executable(${PROJECT_TARGET_NAME}
    ${APP_SOURCES}
)

target_include_directories(${PROJECT_TARGET_NAME} PRIVATE
    "${PROJECT_SRC_DIR}"
)

##
set(PROJECT_REMOTE_HOST "${UBI_CONFIG_HOST_01}")
set(PROJECT_REMOTE_USER "${UBI_CONFIG_USER_01}")

set(PROJECT_REMOTE_VENV "${PROJECT_BASE_DIR}/venv")
set(PROJECT_REMOTE_SOURCE_BASE "${PROJECT_LIB_DIR}/ubinos_base")
set(PROJECT_REMOTE_DESTINATION_BASE "${PROJECT_LIB_DIR}/ubinos_base")
set(PROJECT_REMOTE_SYNC_SRC_DIR_LIST 
    "app/helloworld_c" 
    "app/helloworld_c_on_host_01" 
)
file(RELATIVE_PATH _rel_dir "${PROJECT_REMOTE_SOURCE_BASE}" "${PROJECT_MAIN_APP_DIR}")
set(PROJECT_REMOTE_SYNC_BIN_DIR_LIST 
    "${_rel_dir}"
)

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_c_cpp_native_remote_post.cmake")
