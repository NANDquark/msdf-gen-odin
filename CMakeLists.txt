cmake_minimum_required(VERSION 3.15)

project(msdfgen_odin_bridge LANGUAGES CXX)

# Default to a local Linux-friendly extension build; callers can override.
if(NOT DEFINED MSDFGEN_CORE_ONLY)
	set(MSDFGEN_CORE_ONLY OFF CACHE BOOL "Only build core msdfgen library" FORCE)
endif()
if(NOT DEFINED MSDFGEN_USE_VCPKG)
	set(MSDFGEN_USE_VCPKG OFF CACHE BOOL "Use vcpkg for msdfgen dependencies" FORCE)
endif()
if(NOT DEFINED MSDFGEN_DISABLE_SVG)
	set(MSDFGEN_DISABLE_SVG ON CACHE BOOL "Disable SVG support" FORCE)
endif()
if(NOT DEFINED MSDFGEN_USE_SKIA)
	set(MSDFGEN_USE_SKIA OFF CACHE BOOL "Disable Skia support" FORCE)
endif()
if(NOT DEFINED MSDFGEN_BUILD_STANDALONE)
	set(MSDFGEN_BUILD_STANDALONE OFF CACHE BOOL "Disable msdfgen standalone executable" FORCE)
endif()

add_subdirectory(lib/msdfgen)

add_library(msdfgen-c STATIC
	bridge/msdfgen_c.h
	bridge/msdfgen_c.cpp
)
target_compile_features(msdfgen-c PUBLIC cxx_std_11)
target_compile_definitions(msdfgen-c PRIVATE MSDFGEN_PUBLIC=)
target_link_libraries(msdfgen-c PRIVATE msdfgen::msdfgen-core)
target_include_directories(msdfgen-c PRIVATE
	${CMAKE_CURRENT_SOURCE_DIR}/bridge
	${CMAKE_CURRENT_SOURCE_DIR}/lib/msdfgen
)

if(NOT MSDFGEN_CORE_ONLY)
	add_library(msdfgen-ext-c STATIC
		bridge/msdfgen_ext_c.h
		bridge/msdfgen_ext_c.cpp
	)
	target_compile_features(msdfgen-ext-c PUBLIC cxx_std_11)
	target_compile_definitions(msdfgen-ext-c PRIVATE MSDFGEN_PUBLIC= MSDFGEN_EXT_PUBLIC=)
	target_link_libraries(msdfgen-ext-c PRIVATE msdfgen::msdfgen-ext msdfgen-c)
	target_include_directories(msdfgen-ext-c PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/bridge
		${CMAKE_CURRENT_SOURCE_DIR}/lib/msdfgen
	)
endif()
