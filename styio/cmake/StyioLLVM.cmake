if(LLVM_DIR)
  get_filename_component(STYIO_LLVM_CMAKE_DIR "${LLVM_DIR}" ABSOLUTE)
  get_filename_component(STYIO_LLVM_PREFIX "${STYIO_LLVM_CMAKE_DIR}/../../.." ABSOLUTE)
  if(EXISTS "${STYIO_LLVM_PREFIX}/include" AND EXISTS "${STYIO_LLVM_PREFIX}/lib")
    list(PREPEND CMAKE_PREFIX_PATH "${STYIO_LLVM_PREFIX}")
    if(NOT ZLIB_ROOT)
      set(ZLIB_ROOT "${STYIO_LLVM_PREFIX}")
    endif()
    if(NOT LibXml2_ROOT)
      set(LibXml2_ROOT "${STYIO_LLVM_PREFIX}")
    endif()
  endif()
endif()

find_package(ZLIB QUIET)
find_package(zstd CONFIG QUIET)
find_package(LibXml2 QUIET)
find_package(LLVM 18.1.0 REQUIRED CONFIG)

# LLVM headers ship a libc++abi-flavored cxxabi.h. On Debian + libstdc++,
# putting LLVM on the normal -I/-isystem search path lets internal libstdc++
# includes pick up the wrong cxxabi.h, which breaks GoogleTest and other
# host-side tooling. Keep LLVM reachable, but only after the standard library
# headers.
separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})

message(STATUS "[LLVM] Include Directory: ${LLVM_INCLUDE_DIRS}")
message(STATUS "[LLVM] Definitions: ${LLVM_DEFINITIONS_LIST}")
message(STATUS "[LLVM] Version: ${LLVM_PACKAGE_VERSION}")
message(STATUS "[LLVM] Using LLVMConfig.cmake in: ${LLVM_DIR}")

llvm_map_components_to_libnames(LLVM_LIBS support core irreader orcjit native)

function(styio_apply_llvm_compile_settings target_name)
  if(MSVC)
    target_compile_options(${target_name} PRIVATE
      "$<$<COMPILE_LANGUAGE:C>:/utf-8>"
      "$<$<COMPILE_LANGUAGE:CXX>:/utf-8>"
    )
  endif()

  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang|GNU|AppleClang" AND NOT MSVC)
    foreach(llvm_include_dir IN LISTS LLVM_INCLUDE_DIRS)
      target_compile_options(${target_name} PRIVATE
        "$<$<COMPILE_LANGUAGE:C>:SHELL:-idirafter ${llvm_include_dir}>"
        "$<$<COMPILE_LANGUAGE:CXX>:SHELL:-idirafter ${llvm_include_dir}>"
      )
    endforeach()
  else()
    target_include_directories(${target_name} SYSTEM PRIVATE ${LLVM_INCLUDE_DIRS})
  endif()

  target_compile_definitions(${target_name} PRIVATE ${LLVM_DEFINITIONS_LIST})
endfunction()
