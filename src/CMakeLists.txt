cmake_minimum_required(VERSION 3.18)
project(ModifiedLeanRuntime C CXX)
set(LEAN_VERSION_MAJOR 4)
set(LEAN_VERSION_MINOR 22)
set(LEAN_VERSION_PATCH 0)
set(LEAN_VERSION_IS_RELEASE 1)  # This number is 1 in the release revision, and 0 otherwise.
set(LEAN_VERSION_STRING "${LEAN_VERSION_MAJOR}.${LEAN_VERSION_MINOR}.${LEAN_VERSION_PATCH}")
if (LEAN_SPECIAL_VERSION_DESC)
  string(APPEND LEAN_VERSION_STRING "-${LEAN_SPECIAL_VERSION_DESC}")
elseif (NOT LEAN_VERSION_IS_RELEASE)
  string(APPEND LEAN_VERSION_STRING "-pre")
endif()
if (LEAN_VERSION_IS_RELEASE)
  set(LEAN_MANUAL_ROOT "https://lean-lang.org/doc/reference/${LEAN_VERSION_STRING}/")
else()
  set(LEAN_MANUAL_ROOT "")
endif()

set(LEAN_PLATFORM_TARGET "riscv32im-risc0-zkvm-elf")

set(LEAN_IS_STAGE0 "#define LEAN_IS_STAGE0 0")

# 1) Generate lean/config.h from config.h.in
set(LEAN_GEN_INC "${CMAKE_CURRENT_BINARY_DIR}/generated-include/lean")
file(MAKE_DIRECTORY "${LEAN_GEN_INC}")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/include/lean/config.h.in"
  "${LEAN_GEN_INC}/config.h"
  @ONLY
)
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/include/lean/version.h.in"
  "${LEAN_GEN_INC}/version.h"
  @ONLY
)
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/githash.h.in"
  "${CMAKE_CURRENT_BINARY_DIR}/generated-include/githash.h"
  @ONLY
)

# 2) Runtime sources
file(GLOB RUNTIME_CS   "${CMAKE_CURRENT_SOURCE_DIR}/runtime/*.c")
file(GLOB RUNTIME_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/runtime/*.cpp")

file(GLOB UTIL_CS   "${CMAKE_CURRENT_SOURCE_DIR}/util/*.c")
file(GLOB UTIL_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/util/*.cpp")

configure_file(util/ffi.cpp "${CMAKE_CURRENT_BINARY_DIR}/util/ffi.cpp" @ONLY)

# 3) Static library: libLean.a
add_library(Lean STATIC ${RUNTIME_CS} ${RUNTIME_CPPS} ${UTIL_CS} ${UTIL_CPPS} "${CMAKE_CURRENT_BINARY_DIR}/util/ffi.cpp")
target_include_directories(Lean PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/include"
  "${CMAKE_CURRENT_BINARY_DIR}/generated-include"
)
target_compile_features(Lean PUBLIC c_std_11 cxx_std_17)
