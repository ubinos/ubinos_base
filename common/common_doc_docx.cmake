add_custom_target(xdserver
)

add_custom_target(load
)

add_custom_target(rsync
)

add_custom_target(build
    COMMAND sphinx-build -b docx "${PROJECT_DOC_DIR}" .
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
if(NOT _doc_file_docx)
    set(_doc_file_docx "${CMAKE_BINARY_DIR}/Logbook.docx")
endif()

if(WIN32)
    set(_open_cmd_docx cmd /c start "${_doc_file_docx}")
elseif(APPLE)
    set(_open_cmd_docx open "${_doc_file_docx}")
else()
    set(_open_cmd_docx xdg-open "${_doc_file_docx}")
endif()

add_custom_target(run
    COMMAND ${_open_cmd_docx}
    VERBATIM
)
