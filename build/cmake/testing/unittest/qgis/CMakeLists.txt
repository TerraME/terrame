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

if(MSVC)
	set(CMAKE_CXX_FLAGS_RELEASE "/MT")
endif(MSVC)

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR (CMAKE_CXX_COMPILER MATCHES ".*clang") OR (CMAKE_CXX_COMPILER_ID STREQUAL "Clang"))
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread")
endif()

file(GLOB TERRAME_INTTEST_QGIS_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/qgis/*.cpp)
file(GLOB TERRAME_INTTEST_QGIS_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/unittest/qgis/*.h)

if(UNIX)
	set(CMAKE_INSTALL_RPATH "${TERRAME_INSTALL_PREFIX}/bin:\$ORIGIN:\$ORIGIN/bin")
	set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
endif()

add_executable(qgis_utest ${TERRAME_INTTEST_QGIS_SRC_FILES} ${TERRAME_INTTEST_QGIS_HDR_FILES})

target_include_directories(qgis_utest PUBLIC ${TERRAME_ABSOLUTE_ROOT_DIR}/src
											${GTEST_INCLUDE_DIRS} ${GMOCK_INCLUDE_DIRS})

target_link_libraries(qgis_utest qgis ${GTEST_BOTH_LIBRARIES} ${GMOCK_BOTH_LIBRARIES})

install(TARGETS qgis_utest
        RUNTIME DESTINATION bin
        COMPONENT runtime)

install(DIRECTORY ${PKG_TEST_DIR}
		DESTINATION bin/qgistestdata
		COMPONENT runtime)

add_test(NAME qgis_utest COMMAND qgis_utest)
