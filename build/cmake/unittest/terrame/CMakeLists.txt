############################################################################################
# TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
# Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org
#
# This code is part of the TerraME framework.
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
# indirect, special, incidental, or consequential damages arising out of the use
# of this software and its documentation.
############################################################################################

project(unittest)

if(MSVC)
  set(CMAKE_CXX_FLAGS_RELEASE "/MT")
endif(MSVC)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER MATCHES ".*clang") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif()

include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src)
include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/terrame)
include_directories(${GTEST_INCLUDE_DIRS} ${GMOCK_INCLUDE_DIRS})

file(GLOB TERRAME_UNITTEST_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/*.cpp)
file(GLOB TERRAME_UNITTEST_CORE_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/core/*.cpp)
file(GLOB TERRAME_UNITTEST_CORE_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/core/*.h)

source_group("Source Files" FILES ${TERRAME_UNITTEST_SRC_FILES})
source_group("Source Files\\core" FILES ${TERRAME_UNITTEST_CORE_SRC_FILES})
source_group("Header Files\\core" FILES ${TERRAME_UNITTEST_CORE_HDR_FILES})

add_executable(unittest ${TERRAME_UNITTEST_SRC_FILES}
						${TERRAME_UNITTEST_CORE_SRC_FILES} ${TERRAME_UNITTEST_CORE_HDR_FILES})

target_link_libraries(unittest ${GTEST_BOTH_LIBRARIES} ${GMOCK_BOTH_LIBRARIES})

install(TARGETS unittest
		RUNTIME DESTINATION bin
		COMPONENT runtime)

add_test(NAME unittest COMMAND unittest)