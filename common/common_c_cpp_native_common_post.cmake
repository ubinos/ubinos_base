message(STATUS "")
message(STATUS "")

message(STATUS "UBI_CONFIG_WIFI_SSID:               ${UBI_CONFIG_WIFI_SSID}")
message(STATUS "UBI_CONFIG_WIFI_PW:                 ${UBI_CONFIG_WIFI_PW}")
message(STATUS "UBI_CONFIG_SERVER_ADDR:             ${UBI_CONFIG_SERVER_ADDR}")

message(STATUS "PROJECT_TARGET_NAME:                ${PROJECT_TARGET_NAME}")
message(STATUS "PROJECT_BASE_DIR:                   ${PROJECT_BASE_DIR}")
message(STATUS "PROJECT_LIB_DIR:                    ${PROJECT_LIB_DIR}")
message(STATUS "PROJECT_BSP_DIR:                    ${PROJECT_BSP_DIR}")
message(STATUS "PROJECT_SRC_DIR:                    ${PROJECT_SRC_DIR}")

message(STATUS "PROJECT_MAIN_APP:                   ${PROJECT_MAIN_APP}")
message(STATUS "PROJECT_MAIN_APP_OPTION:            ${PROJECT_MAIN_APP_OPTION}")
message(STATUS "PROJECT_MAIN_APP_DIR:               ${PROJECT_MAIN_APP_DIR}")

message(STATUS "PROJECT_REMOTE_HOST:                ${PROJECT_REMOTE_HOST}")
message(STATUS "PROJECT_REMOTE_USER:                ${PROJECT_REMOTE_USER}")
message(STATUS "PROJECT_REMOTE_VENV:                ${PROJECT_REMOTE_VENV}")
message(STATUS "PROJECT_REMOTE_SOURCE_BASE:         ${PROJECT_REMOTE_SOURCE_BASE}")
message(STATUS "PROJECT_REMOTE_DESTINATION_BASE:    ${PROJECT_REMOTE_DESTINATION_BASE}")
message(STATUS "PROJECT_REMOTE_SYNC_SRC_DIR_LIST:   ${PROJECT_REMOTE_SYNC_SRC_DIR_LIST}")
message(STATUS "PROJECT_REMOTE_SYNC_BIN_DIR_LIST:   ${PROJECT_REMOTE_SYNC_SRC_DIR_LIST}")

message(STATUS "CMAKE_BUILD_TYPE:                   ${CMAKE_BUILD_TYPE}")
message(STATUS "CMAKE_EXPORT_COMPILE_COMMANDS:      ${CMAKE_EXPORT_COMPILE_COMMANDS}")

message(STATUS "CMAKE_CURRENT_BINARY_DIR:           ${CMAKE_CURRENT_BINARY_DIR}")
message(STATUS "CMAKE_C_COMPILER_LAUNCHER:          ${CMAKE_C_COMPILER_LAUNCHER}")
message(STATUS "CMAKE_CXX_COMPILER_LAUNCHER:        ${CMAKE_CXX_COMPILER_LAUNCHER}")
message(STATUS "CMAKE_C_STANDARD:                   ${CMAKE_C_STANDARD}")
message(STATUS "CMAKE_CXX_STANDARD:                 ${CMAKE_CXX_STANDARD}")

message(STATUS "")

file(RELATIVE_PATH _rel_path "${PROJECT_BASE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")
execute_process(
    COMMAND ubitool json -w 
                         -k "[\"C_Cpp.default.compileCommands\"]"
                         -v "\${workspaceFolder}/${_rel_path}/compile_commands.json"
                         "${PROJECT_BASE_DIR}/.vscode/settings.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"local app debug\"].cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"local app debug\"].program | [0]"
                         -v "\${workspaceFolder}/${_rel_path}/app"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app reset\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app build\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app load\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"
)

##
add_custom_target(all_build ALL
    COMMAND ${CMAKE_COMMAND} --build . --target rsync
    COMMAND ${CMAKE_COMMAND} --build . --target prebuild
    COMMAND ${CMAKE_COMMAND} --build . --target build
    COMMENT "---- All: rsync prebuild, build  (UBI_CONFIG_NAME: ${UBI_CONFIG_NAME}, UBI_BUILD_DIR: ${UBI_BUILD_DIR})"
    VERBATIM
)

##
add_custom_target(prebuild
)

set(_target_cmd)
set(_target_cmd ${_target_cmd} ${CMAKE_COMMAND} --build . --target app)
message(STATUS "build command: ${_target_cmd}")
add_custom_target(build
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

add_custom_target(cleand
    COMMAND ${CMAKE_COMMAND} --build . --target clean
    VERBATIM
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target clean
    COMMAND ${CMAKE_COMMAND} --build . --target build
    VERBATIM
)

##
add_custom_target(reset
)

add_custom_target(dserver
)

add_custom_target(xdserver
)

message(STATUS "")
