cmake_minimum_required(VERSION 3.24)

set(PROJECT_TARGET_NAME "app")

if(NOT DEFINED PROJECT_BASE_DIR)
    set(PROJECT_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../..")
    get_filename_component(PROJECT_BASE_DIR ${PROJECT_BASE_DIR} REALPATH)
endif()
if(NOT DEFINED PROJECT_LIB_DIR)
    set(PROJECT_LIB_DIR "${PROJECT_BASE_DIR}/lib")
endif()

set(PROJECT_SRC_DIR "${CMAKE_CURRENT_LIST_DIR}")

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_config.cmake")

include("${PROJECT_LIB_DIR}/ubinos_base/common/common_c_cpp_native_local_pre.cmake")

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
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_c_cpp_native_local_post.cmake")
