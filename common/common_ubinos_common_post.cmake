message(STATUS "")
message(STATUS "")

message(STATUS "UBI_CONFIG_WIFI_SSID:               ${UBI_CONFIG_WIFI_SSID}")
message(STATUS "UBI_CONFIG_WIFI_PW:                 ${UBI_CONFIG_WIFI_PW}")
message(STATUS "UBI_CONFIG_SERVER_ADDR:             ${UBI_CONFIG_SERVER_ADDR}")

message(STATUS "")

message(STATUS "PROJECT_TARGET_NAME:                ${PROJECT_TARGET_NAME}")
message(STATUS "PROJECT_BASE_DIR:                   ${PROJECT_BASE_DIR}")
message(STATUS "PROJECT_LIB_DIR:                    ${PROJECT_LIB_DIR}")
message(STATUS "PROJECT_BSP_DIR:                    ${PROJECT_BSP_DIR}")
message(STATUS "PROJECT_SRC_DIR:                    ${PROJECT_SRC_DIR}")

message(STATUS "")

message(STATUS "PROJECT_MAIN_APP:                   ${PROJECT_MAIN_APP}")
message(STATUS "PROJECT_MAIN_APP_OPTION:            ${PROJECT_MAIN_APP_OPTION}")
message(STATUS "PROJECT_MAIN_APP_DIR:               ${PROJECT_MAIN_APP_DIR}")

message(STATUS "")

message(STATUS "PROJECT_BUILD_SCRIPT_DIR:           ${PROJECT_BUILD_SCRIPT_DIR}")
message(STATUS "PROJECT_BUILD_TMP_DIR:              ${PROJECT_BUILD_TMP_DIR}")
message(STATUS "PROJECT_BUILD_TMP_APP_FILE:         ${PROJECT_BUILD_TMP_APP_FILE}")
message(STATUS "PROJECT_BUILD_CUSTOM_OPTION:        ${PROJECT_BUILD_CUSTOM_OPTION}")

message(STATUS "")

message(STATUS "PROJECT_REMOTE_HOST:                ${PROJECT_REMOTE_HOST}")
message(STATUS "PROJECT_REMOTE_USER:                ${PROJECT_REMOTE_USER}")
message(STATUS "PROJECT_REMOTE_VENV:                ${PROJECT_REMOTE_VENV}")
message(STATUS "PROJECT_REMOTE_SOURCE_BASE:         ${PROJECT_REMOTE_SOURCE_BASE}")
message(STATUS "PROJECT_REMOTE_DESTINATION_BASE:    ${PROJECT_REMOTE_DESTINATION_BASE}")
message(STATUS "PROJECT_REMOTE_SYNC_SRC_DIR_LIST:   ${PROJECT_REMOTE_SYNC_SRC_DIR_LIST}")
message(STATUS "PROJECT_REMOTE_SYNC_BIN_DIR_LIST:   ${PROJECT_REMOTE_SYNC_SRC_DIR_LIST}")

message(STATUS "")

message(STATUS "PROJECT_DEBUG_HBREAKPOINTS_LIMIT:   ${PROJECT_DEBUG_HBREAKPOINTS_LIMIT}")
message(STATUS "PROJECT_DEBUG_ARCHITECTURE:         ${PROJECT_DEBUG_ARCHITECTURE}")
message(STATUS "PROJECT_DEBUG_DEBUGGER_PATH:        ${PROJECT_DEBUG_DEBUGGER_PATH}")
message(STATUS "PROJECT_DEBUG_SERVER_ADDRESS:       ${PROJECT_DEBUG_SERVER_ADDRESS}")
message(STATUS "PROJECT_DEBUG_SERVER_GDB_PORT:      ${PROJECT_DEBUG_SERVER_GDB_PORT}")
message(STATUS "PROJECT_DEBUG_SERVER_TLC_PORT:      ${PROJECT_DEBUG_SERVER_TLC_PORT}")
message(STATUS "PROJECT_DEBUG_SERVER_TELNET_PORT:   ${PROJECT_DEBUG_SERVER_TELNET_PORT}")
message(STATUS "PROJECT_DEBUG_ARGS:                 ${PROJECT_DEBUG_ARGS}")
message(STATUS "PROJECT_DEBUG_OPENOCD_PATH:         ${PROJECT_DEBUG_OPENOCD_PATH}")

message(STATUS "")

message(STATUS "CMAKE_EXPORT_COMPILE_COMMANDS:      ${CMAKE_EXPORT_COMPILE_COMMANDS}")
message(STATUS "CMAKE_COLOR_MAKEFILE:               ${CMAKE_COLOR_MAKEFILE}")
message(STATUS "CMAKE_BUILD_TYPE:                   ${CMAKE_BUILD_TYPE}")

message(STATUS "")

message(STATUS "CMAKE_CURRENT_BINARY_DIR:           ${CMAKE_CURRENT_BINARY_DIR}")
message(STATUS "CMAKE_C_COMPILER_LAUNCHER:          ${CMAKE_C_COMPILER_LAUNCHER}")
message(STATUS "CMAKE_CXX_COMPILER_LAUNCHER:        ${CMAKE_CXX_COMPILER_LAUNCHER}")
message(STATUS "CMAKE_C_STANDARD:                   ${CMAKE_C_STANDARD}")
message(STATUS "CMAKE_CXX_STANDARD:                 ${CMAKE_CXX_STANDARD}")

message(STATUS "")

####

set(_abs_debugger_path ${PROJECT_DEBUG_DEBUGGER_PATH})

set(_rel_debugger_path ${PROJECT_DEBUG_DEBUGGER_PATH})

set(_workspace_rel_debugger_path ${PROJECT_DEBUG_DEBUGGER_PATH})

file(RELATIVE_PATH _rel_bin_path "${PROJECT_BASE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}")

set(_abs_bin_subbuild_path "${CMAKE_CURRENT_BINARY_DIR}/build/${PROJECT_TARGET_NAME}")

file(RELATIVE_PATH _rel_bin_subbuild_path "${PROJECT_BASE_DIR}" "${_abs_bin_subbuild_path}")

set(_gdb_script_path ${PROJECT_BSP_DIR})

set(_build_working_path ${_abs_bin_subbuild_path})

####

function(add_forward_target_with_terminal tgt)
    add_custom_target(${tgt}
        WORKING_DIRECTORY ${_build_working_path}
        COMMAND ${CMAKE_COMMAND} --build ${_build_working_path} --target ${tgt}
        USES_TERMINAL
        VERBATIM
    )
endfunction()

####

execute_process(
    COMMAND ubitool json -w 
                        -k "[\"C_Cpp.default.compileCommands\"]"
                        -v "\${workspaceFolder}/${_rel_bin_subbuild_path}/compile_commands.json"
                        "${PROJECT_BASE_DIR}/.vscode/settings.json"
)

####

add_forward_target_with_terminal(xconfig)

add_forward_target_with_terminal(menuconfig)

add_custom_target(rsync)

add_custom_target(prebuild
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}

    ##
    COMMAND ${CMAKE_COMMAND} -E make_directory "${_build_working_path}"
    COMMAND ${CMAKE_COMMAND} -E chdir "${_build_working_path}"
            ${CMAKE_COMMAND} -E env --unset=MAKEFLAGS
            ${CMAKE_COMMAND} -G "Unix Makefiles"
                             -D PROJECT_CONFIG_NAME=${PROJECT_CONFIG_NAME}
                             -D PROJECT_CONFIG_DIR=${PROJECT_CONFIG_DIR}
                             -D PROJECT_LIBRARY_DIR=${PROJECT_LIB_DIR}
                            ${PROJECT_SRC_DIR}
                            --fresh
    VERBATIM
)

add_custom_target(build
    WORKING_DIRECTORY ${_build_working_path}
    COMMAND make ${UBI_CONFIG_UBINOS_CUSTOM_MAKE_OPTIONS}
    VERBATIM
)

add_custom_target(postbuild
    WORKING_DIRECTORY "${_build_working_path}"

    ##
    # COMMAND ubitool replace -a
    #         "${_abs_bin_subbuild_path}/gdb_custom.gdb"
    #         "localhost:2331"
    #         "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    COMMAND ubitool replace -a
            "${_abs_bin_subbuild_path}/gdb_init.gdb"
            "localhost:2331"
            "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    COMMAND ubitool replace -a
            "${_abs_bin_subbuild_path}/gdb_attach.gdb"
            "localhost:2331"
            "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    COMMAND ubitool replace -a
            "${_abs_bin_subbuild_path}/gdb_load.gdb"
            "localhost:2331"
            "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"
    COMMAND ubitool replace -a
            "${_abs_bin_subbuild_path}/gdb_load.gdb"
            "app.elf"
            "${PROJECT_BASE_DIR}/${_rel_bin_subbuild_path}/${PROJECT_TARGET_NAME}.elf"

    COMMAND ubitool replace -a
            "${_abs_bin_subbuild_path}/gdb_reset_and_halt.gdb"
            "localhost:2331"
            "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    # COMMAND ubitool replace -a
    #         "${_abs_bin_subbuild_path}/gdb_reset_and_run.gdb"
    #         "localhost:2331"
    #         "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    # COMMAND ubitool replace -a
    #         "${_abs_bin_subbuild_path}/gdb_reset_to_main.gdb"
    #         "localhost:2331"
    #         "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"

    ##
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_subbuild_path}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].program | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_subbuild_path}/${PROJECT_TARGET_NAME}.elf"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].hardwareBreakpoints.limit | [0]"
                         -v ${PROJECT_DEBUG_HBREAKPOINTS_LIMIT}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].targetArchitecture | [0]"
                         -v ${PROJECT_DEBUG_ARCHITECTURE}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].miDebuggerPath | [0]"
                         -v "${_workspace_rel_debugger_path}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].miDebuggerServerAddress | [0]"
                         -v "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgad - target app debug\"].miDebuggerArgs | [0]"
                         -v ${PROJECT_DEBUG_ARGS}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
    ##
    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_subbuild_path}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].program | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_subbuild_path}/${PROJECT_TARGET_NAME}.elf"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].hardwareBreakpoints.limit | [0]"
                         -v ${PROJECT_DEBUG_HBREAKPOINTS_LIMIT}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].targetArchitecture | [0]"
                         -v ${PROJECT_DEBUG_ARCHITECTURE}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].miDebuggerPath | [0]"
                         -v "${_workspace_rel_debugger_path}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].miDebuggerServerAddress | [0]"
                         -v "${PROJECT_DEBUG_SERVER_ADDRESS}:${PROJECT_DEBUG_SERVER_GDB_PORT}"
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"

    COMMAND ubitool json -w 
                         -k "configurations[?name==\"tgadl - target app debug (load)\"].miDebuggerArgs | [0]"
                         -v ${PROJECT_DEBUG_ARGS}
                         "${PROJECT_BASE_DIR}/.vscode/launch.json"
    ##
    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app reset\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"

    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app build\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"

    COMMAND ubitool json -w 
                         -k "tasks[?label==\"target app load\"].options.cwd | [0]"
                         -v "\${workspaceFolder}/${_rel_bin_path}"
                         "${PROJECT_BASE_DIR}/.vscode/tasks.json"

    VERBATIM
)

add_custom_target(clean_build
    COMMAND ${CMAKE_COMMAND} --build . --target clean
    VERBATIM
)

add_custom_target(clean_prebuild
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${_build_working_path}"
    VERBATIM
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target prebuild
    COMMAND ${CMAKE_COMMAND} --build . --target build
    COMMAND ${CMAKE_COMMAND} --build . --target postbuild
    VERBATIM
)

add_forward_target_with_terminal(reset)

add_forward_target_with_terminal(load)

add_forward_target_with_terminal(unload)

add_forward_target_with_terminal(run)

add_forward_target_with_terminal(xrun)

add_forward_target_with_terminal(debug)

add_forward_target_with_terminal(xdebug)

add_forward_target_with_terminal(attach)

add_forward_target_with_terminal(xattach)

add_forward_target_with_terminal(dserver)

add_forward_target_with_terminal(xdserver)

add_custom_target(flash)

add_custom_target(monitor)

##

message(STATUS "")

