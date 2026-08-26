include("${CMAKE_CURRENT_LIST_DIR}/common_python_common_post.cmake")

##
# 실행 중인 docker 컨테이너(PROJECT_DOCKER_CONTAINER_NAME) 안에서 docker exec 로 python 을 실행한다.
# - PROJECT_DOCKER_MAIN_APP_DIR 는 컨테이너 안에서 보이는 경로여야 한다. 컨테이너가
#   PROJECT_LIB_DIR 를 host 와 동일 경로로 mount 하면 host 경로를 그대로 쓸 수 있다.
# - PROJECT_DOCKER_USER 가 빈 값이면 컨테이너가 기동될 때 지정된 사용자로 실행된다.
# - 소스가 mount 로 컨테이너와 공유되므로 rsync 는 필요 없다 (빈 타깃).
# - -i -t: tty 를 할당해야 Ctrl+C(SIGINT)가 컨테이너 안 프로세스로 전달되어 종료되고,
#   ipdb 같은 대화형 디버거도 동작한다 (remote 버전의 ssh -CYt 와 같은 이유).
#   tty 없이 docker exec 를 SIGINT 로 끊으면 컨테이너 안 프로세스가 잔존한다.
set(_docker_user_opt)
if (NOT "${PROJECT_DOCKER_USER}" STREQUAL "")
    set(_docker_user_opt --user ${PROJECT_DOCKER_USER})
endif()

add_custom_target(rsync
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

set(_target_cmd docker exec -i -t ${_docker_user_opt} -w "${PROJECT_DOCKER_MAIN_APP_DIR}" ${PROJECT_DOCKER_CONTAINER_NAME} ${PROJECT_PYTHON_INTERPRETER} -u ./${PROJECT_MAIN_APP} ${PROJECT_MAIN_APP_OPTION})
message(STATUS "run command: ${_target_cmd}")
add_custom_target(run
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

set(_target_cmd docker exec -i -t ${_docker_user_opt} -w "${PROJECT_DOCKER_MAIN_APP_DIR}" ${PROJECT_DOCKER_CONTAINER_NAME} ${PROJECT_PYTHON_INTERPRETER} -u ./${PROJECT_MAIN_APP} --debug ${PROJECT_MAIN_APP_OPTION})
message(STATUS "debug command: ${_target_cmd}")
add_custom_target(debug
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMAND ${_target_cmd}
    USES_TERMINAL
    VERBATIM
)

message(STATUS "")
message(STATUS "")
