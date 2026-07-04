function(styio_configure_library_target target_name)
  target_include_directories(${target_name} PUBLIC
    "${STYIO_SOURCE_DIR}/src"
    "${STYIO_BINARY_DIR}/generated"
  )
  styio_apply_llvm_compile_settings(${target_name})
endfunction()

function(styio_configure_binary_target target_name)
  target_include_directories(${target_name} PRIVATE
    "${STYIO_BINARY_DIR}/generated"
  )
  styio_apply_llvm_compile_settings(${target_name})
endfunction()
