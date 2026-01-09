include("${CMAKE_CURRENT_LIST_DIR}/common_c_cpp_native_common_post.cmake")

##
set(_remote_login_cmd ssh -CYt "${PROJECT_REMOTE_USER}@${PROJECT_REMOTE_HOST}")
set(_remote_venv_cmd ". ${PROJECT_REMOTE_VENV}/bin/activate")

##
set(_target_cmd)
foreach(_sync_item IN LISTS PROJECT_REMOTE_SYNC_SRC_DIR_LIST)
    list(APPEND _target_cmd
        COMMAND rsync -av --mkpath
            "${PROJECT_REMOTE_SOURCE_BASE}/${_sync_item}/"
            "${PROJECT_REMOTE_USER}@${PROJECT_REMOTE_HOST}:${PROJECT_REMOTE_DESTINATION_BASE}/${_sync_item}/"
    )
endforeach()
message(STATUS "rsync command: ${_target_cmd}")
add_custom_target(rsync
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    ${_target_cmd}
    VERBATIM
)

##
set(_target_cmd)
foreach(_sync_item IN LISTS PROJECT_REMOTE_SYNC_BIN_DIR_LIST)
    list(APPEND _target_cmd
        COMMAND rsync -av --mkpath
            "${PROJECT_REMOTE_SOURCE_BASE}/${_sync_item}/"
            "${PROJECT_REMOTE_USER}@${PROJECT_REMOTE_HOST}:${PROJECT_REMOTE_DESTINATION_BASE}/${_sync_item}/"
    )
endforeach()
message(STATUS "load command: ${_target_cmd}")
add_custom_target(load
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

##
set(_target_cmd)
list(APPEND _target_cmd
    ${_remote_login_cmd} 
    "${_remote_venv_cmd} && cd \"${PROJECT_MAIN_APP_DIR}\" && ./${PROJECT_MAIN_APP} ${PROJECT_MAIN_APP_OPTION}"
)
message(STATUS "run command: ${_target_cmd}")
add_custom_target(run
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

message(STATUS "")
message(STATUS "")
