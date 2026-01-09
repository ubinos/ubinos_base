include("${CMAKE_CURRENT_LIST_DIR}/common_c_cpp_native_common_post.cmake")

##
add_custom_target(rsync
)

##
add_custom_target(load
)

##
set(_target_cmd)
list(APPEND _target_cmd
    cd "${PROJECT_MAIN_APP_DIR}" && "./${PROJECT_MAIN_APP}" "${PROJECT_MAIN_APP_OPTION}"
)
message(STATUS "run command: ${_target_cmd}")
add_custom_target(run
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

message(STATUS "")
message(STATUS "")
