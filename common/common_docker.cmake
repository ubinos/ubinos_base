function(get_current_username out_var)
    set(_u "")

    if(DEFINED ENV{USERNAME} AND NOT "$ENV{USERNAME}" STREQUAL "")
        set(_u "$ENV{USERNAME}")
    elseif(DEFINED ENV{USER} AND NOT "$ENV{USER}" STREQUAL "")
        set(_u "$ENV{USER}")
    elseif(DEFINED ENV{LOGNAME} AND NOT "$ENV{LOGNAME}" STREQUAL "")
        set(_u "$ENV{LOGNAME}")
    endif()

    if(_u STREQUAL "")
        if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        execute_process(
            COMMAND powershell -NoProfile -Command "$env:UserName"
            OUTPUT_VARIABLE _u
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        else()
        execute_process(
            COMMAND whoami
            OUTPUT_VARIABLE _u
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        endif()
    endif()

    if(_u STREQUAL "")
        set(_u "unknown")
    endif()

    set(${out_var} "${_u}" PARENT_SCOPE)
endfunction()

function(get_uid_gid out_uid out_gid)
    set(_uid "")
    set(_gid "")

    # 1) POSIX 계열: id 명령이 가장 표준
    if(NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        execute_process(
            COMMAND id -u
            OUTPUT_VARIABLE _uid
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
        execute_process(
            COMMAND id -g
            OUTPUT_VARIABLE _gid
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_QUIET
        )
    endif()

    # 2) 보조 fallback: Python이 있으면 os.getuid/getgid (POSIX에서만 유효)
    if((_uid STREQUAL "" OR _gid STREQUAL "") AND NOT CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        find_package(Python3 COMPONENTS Interpreter QUIET)
        if(Python3_Interpreter_FOUND)
            if(_uid STREQUAL "")
                execute_process(
                    COMMAND "${Python3_EXECUTABLE}" -c "import os; print(os.getuid())"
                    OUTPUT_VARIABLE _uid
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_QUIET
                )
            endif()
            if(_gid STREQUAL "")
                execute_process(
                    COMMAND "${Python3_EXECUTABLE}" -c "import os; print(os.getgid())"
                    OUTPUT_VARIABLE _gid
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_QUIET
                )
            endif()
        endif()
    endif()

    # 3) Windows 네이티브: POSIX UID/GID가 없으므로 정책 선택
    #    - Docker에서 사용자 매핑이 필요하면 기본값(보통 1000:1000) 사용
    #    - 또는 빈 값 유지하고 -DDOCKER_UID/GID로 강제 지정
    if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
        if(_uid STREQUAL "")
            set(_uid "1000")   # 정책값: 필요 시 프로젝트 규칙에 맞게 변경
        endif()
        if(_gid STREQUAL "")
            set(_gid "1000")
        endif()
    endif()

    # 4) 최종 방어
    if(_uid STREQUAL "")
        set(_uid "1000")
    endif()
    if(_gid STREQUAL "")
        set(_gid "1000")
    endif()

    set(${out_uid} "${_uid}" PARENT_SCOPE)
    set(${out_gid} "${_gid}" PARENT_SCOPE)
endfunction()

get_current_username(DOCKER_USERNAME)

message(STATUS "DOCKER_USERNAME              = ${DOCKER_USERNAME}")

set(DOCKER_USER_BASEDIR /home)

message(STATUS "DOCKER_USER_BASEDIR          = ${DOCKER_USER_BASEDIR}")

get_uid_gid(DOCKER_UID DOCKER_GID)

message(STATUS "DOCKER_UID                   = ${DOCKER_UID}")
message(STATUS "DOCKER_GID                   = ${DOCKER_GID}")

if(NOT DEFINED DOCKER_IMAGE_NAME OR DOCKER_IMAGE_NAME STREQUAL "")
    set(_docker_image_name "${PROJECT_TARGET_NAME}_${DOCKER_UID}")
    string(TOLOWER "${_docker_image_name}" _docker_image_name)
    set(DOCKER_IMAGE_NAME "${_docker_image_name}" CACHE STRING "Docker image name")
else()
    set(DOCKER_IMAGE_NAME "${DOCKER_IMAGE_NAME}" CACHE STRING "Docker image name (user override)")
endif()

message(STATUS "DOCKER_IMAGE_NAME            = ${DOCKER_IMAGE_NAME}")

if(NOT DEFINED DOCKER_CONTAINER_NAME OR DOCKER_CONTAINER_NAME STREQUAL "")
    set(DOCKER_CONTAINER_NAME "${DOCKER_IMAGE_NAME}_container" CACHE STRING "Docker container name")
else()
    set(DOCKER_CONTAINER_NAME "${DOCKER_CONTAINER_NAME}" CACHE STRING "Docker container name (user override)")
endif()

message(STATUS "DOCKER_CONTAINER_NAME        = ${DOCKER_CONTAINER_NAME}")

# ---- DOCKER_RUN_CMD ----
if(NOT DEFINED DOCKER_RUN_CMD OR DOCKER_RUN_CMD STREQUAL "")
    set(DOCKER_RUN_CMD
        "docker run -d --name ${DOCKER_CONTAINER_NAME} -v ${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR} -v ${PROJECT_LIB_DIR}:${PROJECT_LIB_DIR} --user ${DOCKER_UID}:${DOCKER_GID} ${DOCKER_IMAGE_NAME}"
        CACHE STRING "Docker run command")
else()
    set(DOCKER_RUN_CMD "${DOCKER_RUN_CMD}" CACHE STRING "Docker run command (user override)")
endif()

# ---- DOCKER_EXE_CMD ----
if(NOT DEFINED DOCKER_EXE_CMD OR DOCKER_EXE_CMD STREQUAL "")
    set(DOCKER_EXE_CMD
        "docker exec --user ${DOCKER_UID}:${DOCKER_GID} ${DOCKER_CONTAINER_NAME}"
        CACHE STRING "Docker exec command (non-interactive)")
else()
    set(DOCKER_EXE_CMD "${DOCKER_EXE_CMD}" CACHE STRING "Docker exec command (user override)")
endif()

# ---- DOCKER_EXE_CLI ----
if(NOT DEFINED DOCKER_EXE_CLI OR DOCKER_EXE_CLI STREQUAL "")
    set(DOCKER_EXE_CLI
        "docker exec --user ${DOCKER_UID}:${DOCKER_GID} -it ${DOCKER_CONTAINER_NAME}"
        CACHE STRING "Docker exec command (interactive)")
else()
    set(DOCKER_EXE_CLI "${DOCKER_EXE_CLI}" CACHE STRING "Docker exec command (user override)")
endif()

# ---- DOCKER_STOP_CMD ----
if(NOT DEFINED DOCKER_STOP_CMD OR DOCKER_STOP_CMD STREQUAL "")
    set(DOCKER_STOP_CMD
        "docker stop ${DOCKER_CONTAINER_NAME}"
        CACHE STRING "Docker stop command")
else()
    set(DOCKER_STOP_CMD "${DOCKER_STOP_CMD}" CACHE STRING "Docker stop command (user override)")
endif()

# ---- DOCKER_REMOVE_CONTAINER_CMD ----
# (typo fix: CONTAINTER -> CONTAINER, but keep variable name if you want exact compatibility)
if(NOT DEFINED DOCKER_REMOVE_CONTAINTER_CMD OR DOCKER_REMOVE_CONTAINTER_CMD STREQUAL "")
    set(DOCKER_REMOVE_CONTAINTER_CMD
        "docker rm -f ${DOCKER_CONTAINER_NAME}"
        CACHE STRING "Docker rm command (force remove container)")
else()
    set(DOCKER_REMOVE_CONTAINTER_CMD "${DOCKER_REMOVE_CONTAINTER_CMD}"
        CACHE STRING "Docker rm command (user override)")
endif()

message(STATUS "DOCKER_RUN_CMD               = ${DOCKER_RUN_CMD}")
message(STATUS "DOCKER_EXE_CMD               = ${DOCKER_EXE_CMD}")
message(STATUS "DOCKER_EXE_CLI               = ${DOCKER_EXE_CLI}")
message(STATUS "DOCKER_STOP_CMD              = ${DOCKER_STOP_CMD}")
message(STATUS "DOCKER_REMOVE_CONTAINTER_CMD = ${DOCKER_REMOVE_CONTAINTER_CMD}")

# ---- DOCKER_CMD_ONETIME ----
if(NOT DEFINED DOCKER_CMD_ONETIME OR DOCKER_CMD_ONETIME STREQUAL "")
    set(DOCKER_CMD_ONETIME
        "docker run --rm --name ${DOCKER_IMAGE_NAME} -v ${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR} -v ${PROJECT_LIB_DIR}:${PROJECT_LIB_DIR} --user ${DOCKER_UID}:${DOCKER_GID} ${DOCKER_IMAGE_NAME}"
        CACHE STRING "Docker one-time run command (non-interactive)")
else()
    set(DOCKER_CMD_ONETIME "${DOCKER_CMD_ONETIME}"
        CACHE STRING "Docker one-time run command (user override)")
endif()

# ---- DOCKER_CLI_ONETIME ----
if(NOT DEFINED DOCKER_CLI_ONETIME OR DOCKER_CLI_ONETIME STREQUAL "")
    set(DOCKER_CLI_ONETIME
        "docker run --rm --name ${DOCKER_IMAGE_NAME} -v ${CMAKE_CURRENT_BINARY_DIR}:${CMAKE_CURRENT_BINARY_DIR} -v ${PROJECT_LIB_DIR}:${PROJECT_LIB_DIR} --user ${DOCKER_UID}:${DOCKER_GID} -it ${DOCKER_IMAGE_NAME}"
        CACHE STRING "Docker one-time run command (interactive)")
else()
    set(DOCKER_CLI_ONETIME "${DOCKER_CLI_ONETIME}"
        CACHE STRING "Docker one-time run command (user override)")
endif()

message(STATUS "DOCKER_CMD_ONETIME           = ${DOCKER_CMD_ONETIME}")
message(STATUS "DOCKER_CLI_ONETIME           = ${DOCKER_CLI_ONETIME}")

add_custom_target(xdserver
)

add_custom_target(load
)

add_custom_target(rsync
)

add_custom_target(config
)

add_custom_target(build
    COMMAND docker build
        --build-arg USERNAME=${DOCKER_USERNAME}
        --build-arg USER_BASEDIR=${DOCKER_USER_BASEDIR}
        --build-arg USER_UID=${DOCKER_UID}
        --build-arg USER_GID=${DOCKER_GID}
        -t ${DOCKER_IMAGE_NAME}
        ${PROJECT_SRC_DIR}

    COMMAND docker run
        --name ${DOCKER_CONTAINER_NAME}
        --user ${DOCKER_UID}:${DOCKER_GID}
        ${DOCKER_IMAGE_NAME}
        /bin/bash -c
        "mkdir -p ${PROJECT_BASE_DIR} && mkdir -p ${PROJECT_LIB_DIR} && mkdir -p ${CMAKE_CURRENT_BINARY_DIR}"

    COMMAND docker commit ${DOCKER_CONTAINER_NAME} ${DOCKER_IMAGE_NAME}

    COMMAND docker rm ${DOCKER_CONTAINER_NAME}

    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker run container example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_RUN_CMD} /bin/bash -c \"while true; do sleep 1; done\""
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker execute command example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_EXE_CMD} /bin/bash -c \"ls -alsF\""
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker interactive execute command example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_EXE_CLI} /bin/bash"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker stop container example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_STOP_CMD}"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker remove container example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_REMOVE_CONTAINTER_CMD}"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker onetime execute command example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_CMD_ONETIME} /bin/bash -c \"ls -alsF\""
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "* Docker onetime interactive execute command example: "
    COMMAND ${CMAKE_COMMAND} -E echo "${DOCKER_CLI_ONETIME} /bin/bash"
    COMMAND ${CMAKE_COMMAND} -E echo ""

    VERBATIM
    USES_TERMINAL
)

add_custom_target(cleand
    COMMAND docker rm  -f ${DOCKER_CONTAINER_NAME}
    COMMAND docker rmi -f ${DOCKER_IMAGE_NAME}
    VERBATIM
    USES_TERMINAL
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target config
    COMMAND ${CMAKE_COMMAND} --build . --target cleand
    COMMAND ${CMAKE_COMMAND} --build . --target build
    VERBATIM
    USES_TERMINAL
)
