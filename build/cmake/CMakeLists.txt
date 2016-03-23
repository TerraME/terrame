# TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
# Copyright (C) 2001-2014 INPE and TerraLAB/UFOP.
#
# This file is part of the TerraME framework.
# This framework is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library.
#
# The authors reassure the license terms regarding the warranties.
# They specifically disclaim any warranties, including, but not limited to,
# the implied warranties of merchantability and fitness for a particular purpose.
# The framework provided hereunder is on an "as is" basis, and the authors have no
# obligation to provide maintenance, support, updates, enhancements, or modifications.
# In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
# indirect, special, incidental, or caonsequential damages arising out of the use
# of this library and its documentation.
#
# Authors: Pedro R. Andrade (pedro.andrade@inpe.br)
#          Rodrigo Avancini

cmake_minimum_required(VERSION 3.0)

project(terrame)

#
# main variables for the build script
#

# variables that control the system versioning
set(TERRAME_VERSION_MAJOR 2)
set(TERRAME_VERSION_MINOR 0)
set(TERRAME_VERSION_PATCH 0)
if(NOT DEFINED TERRAME_VERSION_PATCH)
	set(TERRAME_VERSION_STATUS "" CACHE STRING "Define name of installer")
endif()
# for future use
# set(TERRAME_BUILD_NUMBER "" CACHE STRING "Number of build in Jenkins")

if(TERRAME_VERSION_STATUS STREQUAL "build")
	set(TERRAME_VERSION_STATUS "${TERRAME_VERSION_STATUS}-${TERRAME_BUILD_NUMBER}")
endif()

set(TERRAME_VERSION_STRING "${TERRAME_VERSION_MAJOR}.${TERRAME_VERSION_MINOR}.${TERRAME_VERSION_PATCH}-${TERRAME_VERSION_STATUS}")
set(TERRAME_VERSION "0x020000")
set(TERRAME_PKG_VERSION ${TERRAME_VERSION_MAJOR}.${TERRAME_VERSION_MINOR}.${TERRAME_VERSION_PATCH})

# variables that controls what is built
if(NOT DEFINED TERRAME_BUILD_AS_BUNDLE)
	set(TERRAME_BUILD_AS_BUNDLE 0 CACHE BOOL "If on, tells that the build will generate a bundle")
endif()

set(TERRAME_ABSOLUTE_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../..)

#
# global definitions and includes
#
add_definitions(-w -DTME_LUA_5_2 -DQWT_DLL -DTME_BLACK_BOARD -DTME_PROTOCOL_BUFFERS ) #TODO: REVIEW

set(TERRAME_SRC_DIR ${TERRAME_ABSOLUTE_ROOT_DIR}/src) # this is the directory where terralib sources will be located
set(CMAKE_MODULE_PATH ${TERRAME_ABSOLUTE_ROOT_DIR}/build/cmake/find) # this is the directory where additional scritps are located

## Sets type of build: Release or Debug
if(NOT DEFINED CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "Release")
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER MATCHES ".*clang") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
endif()

cmake_policy(SET CMP0020 NEW)

if(CMAKE_VERSION VERSION_EQUAL "2.0.0" OR CMAKE_VERSION VERSION_GREATER "2.0.0")
	cmake_policy(SET CMP0007 NEW)
	cmake_policy(SET CMP0026 OLD)
	cmake_policy(SET CMP0042 NEW)
	cmake_policy(SET CMP0043 NEW)
	cmake_policy(SET CMP0045 OLD)
endif()

if(CMAKE_VERSION VERSION_EQUAL "3.1.0" OR CMAKE_VERSION VERSION_GREATER "3.1.0")
	cmake_policy(SET CMP0053 OLD)
endif()

#
# Build will generate files into a single folder
#
if((CMAKE_GENERATOR STREQUAL Xcode) OR MSVC)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
else()
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
endif()

#
# global configurations
#
set(CMAKE_AUTOMOC ON)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

if(MSVC)
	set(CMAKE_DEBUG_POSTFIX "d")
	add_definitions(/MP)
endif()

if(APPLE AND TERRAME_BUILD_AS_BUNDLE)
	set(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")
	set(TERRAME_APP_TYPE MACOSX_BUNDLE)
	set(TERRAME_INSTALL_PREFIX "terrame.app/Contents")
else()
	set(TERRAME_INSTALL_PREFIX .)
endif()

set(TERRAME_BIN_DIR ${TERRAME_ABSOLUTE_ROOT_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${TERRAME_BIN_DIR})

add_subdirectory(terrame)

set(CPACK_SOURCE_INSTALLED_DIRECTORIES "${TERRAME_ABSOLUTE_ROOT_DIR};/")

#
# CPack
#
configure_file(${CMAKE_SOURCE_DIR}/terrame-cpack-options.cmake.in
               ${CMAKE_BINARY_DIR}/terrameCPackOptions.cmake @ONLY)

set(CPACK_PROJECT_CONFIG_FILE ${CMAKE_BINARY_DIR}/terrameCPackOptions.cmake)

include(CPack)
