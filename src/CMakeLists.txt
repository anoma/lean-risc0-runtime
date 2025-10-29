cmake_minimum_required(VERSION 3.18)
project(lean-risc0-runtime C CXX)
include(GNUInstallDirs)

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
file(GLOB RUNTIME_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/runtime/*.cpp")

file(GLOB UTIL_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/util/*.cpp")

configure_file(util/ffi.cpp.in "${CMAKE_CURRENT_BINARY_DIR}/util/ffi.cpp" @ONLY)

# 3) Static library: libLean.a
add_library(Lean STATIC ${RUNTIME_CPPS} ${UTIL_CPPS} "${CMAKE_CURRENT_BINARY_DIR}/util/ffi.cpp")
target_include_directories(Lean PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated-include>
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_features(Lean PUBLIC c_std_11 cxx_std_17)
target_compile_definitions(Lean PRIVATE LEAN_RISC0=1)

install(TARGETS Lean
    EXPORT LeanTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
  DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  FILES_MATCHING PATTERN "*.h"
)
install(
  DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/generated-include/"
  DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
  FILES_MATCHING PATTERN "*.h"
)

set(AUTO_THREAD_FINALIZATION OFF)

set(CMAKE_CXX_FLAGS                "-DLEAN_BUILD_TYPE=\"${CMAKE_BUILD_TYPE}\" -DLEAN_EXPORTING")
set(CMAKE_CXX_FLAGS_DEBUG          "-DLEAN_DEBUG")
set(CMAKE_CXX_FLAGS_MINSIZEREL     "-DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE        "-DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-DNDEBUG")
set(CMAKE_CXX_FLAGS_RELWITHASSERT  "-DLEAN_DEBUG")

set(CMAKE_CXX_FLAGS                "-Wall -Wextra -ffunction-sections -fdata-sections -fPIC -march=rv32im -mabi=ilp32 -fno-builtin -fno-rtti -fno-threadsafe-statics ${CMAKE_CXX_FLAGS}")
set(CMAKE_CXX_FLAGS_DEBUG          "-g3 ${CMAKE_CXX_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_MINSIZEREL     "-Os ${CMAKE_CXX_FLAGS_MINSIZEREL}")
set(CMAKE_CXX_FLAGS_RELEASE        "-O3 ${CMAKE_CXX_FLAGS_RELEASE}")
set(CMAKE_CXX_FLAGS_RELWITHASSERT  "-O3 ${CMAKE_CXX_FLAGS_RELWITHASSERT}")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O2 -g3 -fno-omit-frame-pointer ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
