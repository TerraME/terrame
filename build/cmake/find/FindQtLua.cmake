#
#  Copyright (C) 2008-2014 National Institute For Space Research (INPE) - Brazil.
#
#  This file is part of the TerraLib - a Framework for building GIS enabled applications.
#
#  TerraLib is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#
#  TerraLib is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with TerraLib. See COPYING. If not, write to
#  TerraLib Team at <terralib-team@terralib.org>.
#
#
#  Description: Find QtLua include directory and libraries.
#
#
# The following variables are set if QtLua is found:
#  QTLUA_FOUND        - Set to true when QtLua is found.
#  QTLUA_INCLUDE_DIR  - Include directories for QtLua
#  QTLUA_LIBRARY      - The QtLua library.
#
#  Author: Matheus Cavassan Zaglia <mzaglia@dpi.inpe.br>
#	

cmake_minimum_required(VERSION 2.8.8)
# Find library - - tries to find *.a,*.so,*.dylib in paths hard-coded by the script

find_path(QTLUA_INCLUDE_DIR QtLua
	HINTS /usr/include/ 
		/usr/local/include/ 
		/usr/local/QtLua/include/
	PATH_SUFFIXES include/QtLua
		include
		QtLua)

if(UNIX)
	find_library(QTLUA_LIBRARY
	NAMES qtlua
	PATHS /usr/local/QtLua
		/usr/local
		/usr
	PATH_SUFFIXES lib 
		lib/x86_64-linux-gnu)
elseif(WIN32)  
	find_library(QTLUA_LIBRARY_RELEASE
		NAMES qtlua
		PATH_SUFFIXES lib )

	find_library(QTLUA_LIBRARY_DEBUG
		NAMES qtluad				
		PATH_SUFFIXES lib)

	if(QTLUA_LIBRARY_RELEASE AND QTLUA_LIBRARY_DEBUG)
		set(QTLUA_LIBRARY optimized ${QTLUA_LIBRARY_RELEASE} debug ${QTLUA_LIBRARY_DEBUG})
	elseif(QTLUA_LIBRARY_RELEASE)
		set(QTLUA_LIBRARY optimized ${QTLUA_LIBRARY_RELEASE} debug ${QTLUA_LIBRARY_RELEASE})
	elseif(QTLUA_LIBRARY_DEBUG)
		set(QTLUA_LIBRARY optimized ${QTLUA_LIBRARY_DEBUG} debug ${QTLUA_LIBRARY_DEBUG})
	endif()
endif()

# Export include and library path for linking with other libraries
if(QTLUA_INCLUDE_DIR AND QTLUA_LIBRARY)
	set(QTLUA_FOUND TRUE)
else()
	set(QTLUA_FOUND FALSE)
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(QtLua DEFAULT_MSG QTLUA_LIBRARY QTLUA_INCLUDE_DIR)
mark_as_advanced(QTLUA_LIBRARY QTLUA_INCLUDE_DIR)
