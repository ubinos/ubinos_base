cmake_minimum_required(VERSION 3.24)

set(PROJECT_TARGET_NAME "app")

if(NOT DEFINED PROJECT_BASE_DIR)
    set(PROJECT_BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../..")
    get_filename_component(PROJECT_BASE_DIR ${PROJECT_BASE_DIR} REALPATH)
endif()
if(NOT DEFINED PROJECT_LIB_DIR)
    set(PROJECT_LIB_DIR "${PROJECT_BASE_DIR}/lib")
endif()

set(PROJECT_SRC_DIR "${PROJECT_LIB_DIR}/ubinos_base/app/helloworld_python")

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_config.cmake")

include("${PROJECT_LIB_DIR}/ubinos_base/common/common_python_remote_pre.cmake")

project(${PROJECT_TARGET_NAME} NONE)

##
set(PROJECT_MAIN_APP "main.py")
set(PROJECT_MAIN_APP_OPTION "")
set(PROJECT_MAIN_APP_DIR "${PROJECT_SRC_DIR}")

##
set(PROJECT_REMOTE_HOST "${UBI_CONFIG_HOST_01}")
set(PROJECT_REMOTE_USER "${UBI_CONFIG_USER_01}")

set(PROJECT_REMOTE_VENV "${PROJECT_BASE_DIR}/venv")
set(PROJECT_REMOTE_SOURCE_BASE "${PROJECT_LIB_DIR}/ubinos_base")
set(PROJECT_REMOTE_DESTINATION_BASE "${PROJECT_LIB_DIR}/ubinos_base")
set(PROJECT_REMOTE_SYNC_SRC_DIR_LIST 
    "app/helloworld_python" 
    "app/helloworld_python_on_host_01" 
)

##
include("${PROJECT_LIB_DIR}/ubinos_base/common/common_python_remote_post.cmake")
