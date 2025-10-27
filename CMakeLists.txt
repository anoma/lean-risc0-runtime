cmake_minimum_required(VERSION 3.18)
project(ModifiedLeanRuntime C CXX)

# 1) Generate lean/config.h from config.h.in
set(LEAN_GEN_INC "${CMAKE_CURRENT_BINARY_DIR}/generated-include/lean")
file(MAKE_DIRECTORY "${LEAN_GEN_INC}")
configure_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/include/lean/config.h.in"
  "${LEAN_GEN_INC}/config.h"
  @ONLY
)

# 2) Runtime sources (C + C++)
file(GLOB RUNTIME_CS   "${CMAKE_CURRENT_SOURCE_DIR}/runtime/*.c")
file(GLOB RUNTIME_CPPS "${CMAKE_CURRENT_SOURCE_DIR}/runtime/*.cpp")

# 3) Static library: libLean.a
add_library(Lean STATIC ${RUNTIME_CS} ${RUNTIME_CPPS})
target_include_directories(Lean PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/include"           # for <lean/lean.h>
  "${CMAKE_CURRENT_BINARY_DIR}/generated-include" # for <lean/config.h>
)
target_compile_features(Lean PUBLIC c_std_11 cxx_std_17)
