add_custom_target(xdserver
)

add_custom_target(load
)

add_custom_target(rsync
)

# 출력 PDF 경로 (ubiconfig output.doc_file_latexpdf; 미설정 시 기본값)
if(NOT _doc_file_latexpdf)
    set(_doc_file_latexpdf "${CMAKE_BINARY_DIR}/latex/sphinx.pdf")
endif()

add_custom_target(build
    COMMAND sphinx-build -M latexpdf "${PROJECT_DOC_DIR}" .
    # Ghostscript 후처리: 폰트 서브셋 + 이미지 다운샘플로 PDF 경량화.
    # gs 가 있을 때만 실행하고 실패해도 빌드에 영향 없음(끝에 true). gs 미설치 시 원본 PDF 유지.
    COMMAND bash -c "f=${_doc_file_latexpdf}; if command -v gs >/dev/null 2>&1 && [ -f $f ]; then gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=$f.min $f && mv -f $f.min $f && echo '[gs] latexpdf compressed'; fi; true"
    VERBATIM
)

add_custom_target(cleand
    COMMAND ${CMAKE_COMMAND} -E remove_directory latex
    VERBATIM
)

add_custom_target(rebuild
    COMMAND ${CMAKE_COMMAND} --build . --target cleand
    COMMAND ${CMAKE_COMMAND} --build . --target build
    VERBATIM
)

##
if(NOT _doc_file_latexpdf)
    set(_doc_file_latexpdf "${CMAKE_BINARY_DIR}/latex/sphinx.pdf")
endif()

if(WIN32)
    set(_open_cmd_latexpdf cmd /c start "${_doc_file_latexpdf}")
elseif(APPLE)
    set(_open_cmd_latexpdf open "${_doc_file_latexpdf}")
else()
    set(_open_cmd_latexpdf xdg-open "${_doc_file_latexpdf}")
endif()

add_custom_target(run
    COMMAND ${_open_cmd_latexpdf}
    VERBATIM
)
