include("${CMAKE_CURRENT_LIST_DIR}/common_shell_common_post.cmake")

add_custom_target(rsync
    WORKING_DIRECTORY ${PROJECT_MAIN_APP_DIR}
)

set(_target_cmd ${PROJECT_SHELL_INTERPRETER} ./${PROJECT_MAIN_APP} ${PROJECT_MAIN_APP_OPTION})
message(STATUS "run command: ${_target_cmd}")
add_custom_target(run
    WORKING_DIRECTORY ${PROJECT_MAIN_APP_DIR}
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

set(_target_cmd ${PROJECT_SHELL_INTERPRETER} -x ./${PROJECT_MAIN_APP} ${PROJECT_MAIN_APP_OPTION})
message(STATUS "debug command: ${_target_cmd}")
add_custom_target(debug
    WORKING_DIRECTORY ${PROJECT_MAIN_APP_DIR}
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

message(STATUS "")
message(STATUS "")
