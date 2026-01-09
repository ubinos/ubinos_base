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

message(STATUS "")

file(RELATIVE_PATH _rel_path "${PROJECT_BASE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")
execute_process(
    COMMAND ubitool json -w 
                         -k "[\"C_Cpp.default.compileCommands\"]"
                         -v "\${workspaceFolder}/${_rel_path}/build/Default/compile_commands.json"
                         "${PROJECT_BASE_DIR}/.vscode/settings.json"
)

execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"target app debug\"].cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}/build/Default"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"target app debug\"].program | [0]"
                         -v "\${workspaceFolder}/${_rel_path}/build/Default/app.elf"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
)

execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"target app debug (load)\"].cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_path}/build/Default"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
)
execute_process(
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"target app debug (load)\"].program | [0]"
                         -v "\${workspaceFolder}/${_rel_path}/build/Default/app.elf"
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
function(add_forward_target_with_terminal tgt)
    add_custom_target(${tgt}
        WORKING_DIRECTORY ${PROJECT_BUILD_DIR}
        COMMAND ${CMAKE_COMMAND} --build ${PROJECT_BUILD_DIR} --target ${tgt}
        USES_TERMINAL
        VERBATIM
    )
endfunction()

##
add_forward_target_with_terminal(dserver)
add_forward_target_with_terminal(xdserver)

add_forward_target_with_terminal(load)
add_forward_target_with_terminal(unload)
add_forward_target_with_terminal(reset)

add_forward_target_with_terminal(run)
add_forward_target_with_terminal(xrun)

add_forward_target_with_terminal(debug)
add_forward_target_with_terminal(xdebug)

add_forward_target_with_terminal(attach)
add_forward_target_with_terminal(xattach)

add_forward_target_with_terminal(xconfig)
add_forward_target_with_terminal(menuconfig)

##
add_custom_target(config
)

add_custom_target(prebuild
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${CMAKE_COMMAND} -E make_directory "${PROJECT_BUILD_DIR}"
    COMMAND ${CMAKE_COMMAND} -E chdir "${PROJECT_BUILD_DIR}"
            ${CMAKE_COMMAND} -E env --unset=MAKEFLAGS
            ${CMAKE_COMMAND} -G "Unix Makefiles"
                             -D PROJECT_CONFIG_NAME=${PROJECT_CONFIG_NAME}
                             -D PROJECT_CONFIG_DIR=${PROJECT_CONFIG_DIR}
                             -D PROJECT_LIBRARY_DIR=${PROJECT_LIB_DIR}
                            ${PROJECT_SRC_DIR}
                            --fresh
    VERBATIM
)

add_custom_target(mainbuild
    WORKING_DIRECTORY ${PROJECT_BUILD_DIR}
    COMMAND make ${UBI_CONFIG_UBINOS_CUSTOM_MAKE_OPTIONS}
    VERBATIM
)

add_custom_target(build
    COMMAND ${CMAKE_COMMAND} --build . --target prebuild
    COMMAND ${CMAKE_COMMAND} --build . --target mainbuild
    VERBATIM
)

add_custom_target(cleand
    COMMAND ${CMAKE_COMMAND} --build . --target clean
    VERBATIM
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target config
    COMMAND ${CMAKE_COMMAND} --build . --target clean
    COMMAND ${CMAKE_COMMAND} --build . --target build
    VERBATIM
)

message(STATUS "")
