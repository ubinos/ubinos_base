cmake_minimum_required(VERSION 3.24)

set(PROJECT_TARGET_NAME "python")

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

include("${PROJECT_LIB_DIR}/ubinos_base/common/common_python_local_pre.cmake")

project(${PROJECT_TARGET_NAME} NONE)

##
set(PROJECT_MAIN_APP "main.py")
set(PROJECT_MAIN_APP_OPTION "")
set(PROJECT_MAIN_APP_DIR "${PROJECT_SRC_DIR}")

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_python_local_post.cmake")
