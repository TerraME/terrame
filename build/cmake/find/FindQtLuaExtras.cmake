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

#
# The following variables are set if QtLuaExtras is found:
#  QTLUA_EXTRAS_FOUND        - Set to true when QtLuaExtras is found.
#  QTLUA_EXTRAS_INCLUDE_DIR  - Include directories for QtLuaExtras
#  QTLUA_EXTRAS_LIBRARY      - The QtLuaExtras library.
#	

cmake_minimum_required(VERSION 2.8.8)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_path(QTLUA_EXTRAS_INCLUDE_DIR QtLuaExtras
	HINTS /usr/include/ 
		/usr/local/include/ 
		/usr/local/QtLuaExtras/include/
	PATH_SUFFIXES include/QtLuaExtras
		include
		QtLuaExtras)

if(UNIX)
find_library(QTLUA_EXTRAS_LIBRARY
	NAMES qtluae
	PATHS /usr/local/QtLuaExtras
		/usr/local
		/usr
	PATH_SUFFIXES lib 
		lib/x86_64-linux-gnu)

elseif(WIN32)  
	find_library(QTLUA_EXTRAS_LIBRARY_RELEASE
		NAMES qtluae
		PATH_SUFFIXES lib )

	find_library(QTLUA_EXTRAS_LIBRARY_DEBUG
		NAMES qtluaed				
		PATH_SUFFIXES lib)

	if(QTLUA_EXTRAS_LIBRARY_RELEASE AND QTLUA_EXTRAS_LIBRARY_DEBUG)
		set(QTLUA_EXTRAS_LIBRARY optimized ${QTLUA_EXTRAS_LIBRARY_RELEASE} debug ${QTLUA_EXTRAS_LIBRARY_DEBUG})
	elseif(QTLUA_EXTRAS_LIBRARY_RELEASE)
		set(QTLUA_EXTRAS_LIBRARY optimized ${QTLUA_EXTRAS_LIBRARY_RELEASE} debug ${QTLUA_EXTRAS_LIBRARY_RELEASE})
	elseif(QTLUA_EXTRAS_LIBRARY_DEBUG)
		set(QTLUA_EXTRAS_LIBRARY optimized ${QTLUA_EXTRAS_LIBRARY_DEBUG} debug ${QTLUA_EXTRAS_LIBRARY_DEBUG})
	endif()
endif()

# Export include and library path for linking with other libraries
if(QTLUA_EXTRAS_INCLUDE_DIR AND QTLUA_EXTRAS_LIBRARY)
	set(QTLUA_EXTRAS_FOUND TRUE)
else()
	set(QTLUA_EXTRAS_FOUND FALSE)
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(QtLuaExtras DEFAULT_MSG QTLUA_EXTRAS_LIBRARY QTLUA_EXTRAS_INCLUDE_DIR)
mark_as_advanced(QTLUA_EXTRAS_LIBRARY QTLUA_EXTRAS_INCLUDE_DIR)
