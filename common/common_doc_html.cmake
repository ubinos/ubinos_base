add_custom_target(xdserver
)

add_custom_target(load
)

add_custom_target(rsync
)

add_custom_target(build
    COMMAND sphinx-build -M html "${PROJECT_DOC_DIR}" .
    VERBATIM
)

add_custom_target(cleand
    COMMAND ${CMAKE_COMMAND} -E remove_directory html
    VERBATIM
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target cleand
    COMMAND ${CMAKE_COMMAND} --build . --target build
    VERBATIM
)

##
set(_doc_file_html "${CMAKE_BINARY_DIR}/html/index.html")

if(WIN32)
    set(_open_cmd_html cmd /c start "${_doc_file_html}")
elseif(APPLE)
    set(_open_cmd_html open "${_doc_file_html}")
else()
    set(_open_cmd_html xdg-open "${_doc_file_html}")
endif()

add_custom_target(run
    COMMAND ${_open_cmd_html}
    VERBATIM
)
