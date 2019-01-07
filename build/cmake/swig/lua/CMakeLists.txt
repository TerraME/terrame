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

find_package(Lua REQUIRED)
if(LUA_FOUND)
	message("Lua found!")
	message("library: ${LUA_LIBRARY}")
	message("include: ${LUA_INCLUDE_DIR}")
else()
	message("Lua not found!")
endif()

file(GLOB TERRAME_SWIG_SCRIPT_FILE ${TERRAME_ABSOLUTE_ROOT_DIR}/src/swig/TerraMELua.i)

include_directories(${TERRAME_ABSOLUTE_ROOT_DIR}/src)
include_directories(${LUA_INCLUDE_DIR})

set(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_BINARY_DIR}/src CACHE PATH "Directory for swig output.")

set_property(SOURCE ${TERRAME_SWIG_SCRIPT_FILE} PROPERTY CPLUSPLUS ON)
set_property(SOURCE ${TERRAME_SWIG_SCRIPT_FILE} PROPERTY CMAKE_SWIG_FLAGS "-includeall")
set_property(SOURCE ${TERRAME_SWIG_SCRIPT_FILE} PROPERTY SWIG_MODULE_NAME swig)

SWIG_ADD_LIBRARY(
	swig
	TYPE SHARED
	LANGUAGE lua
	SOURCES ${TERRAME_SWIG_SCRIPT_FILE}
)

SWIG_LINK_LIBRARIES(swig qgis ${LUA_LIBRARY})

set_target_properties(swig PROPERTIES PREFIX "")

install(TARGETS swig
		RUNTIME DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
		LIBRARY DESTINATION ${TERRAME_INSTALL_PREFIX}/bin
		COMPONENT runtime)
