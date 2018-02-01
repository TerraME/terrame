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
#  Description: Find Qwt - find Qwt include directory and libraries.
#
#  QWT_INCLUDE_DIR - where to find qwt.h.
#  QWT_LIBRARY     - where to find Qwt libraries.
#  QWT_FOUND       - True if Qwt found.
#
#  Author: Gilberto Ribeiro de Queiroz <gribeiro@dpi.inpe.br>
#          Juan Carlos P. Garrido <juan@dpi.inpe.br>
#

if(UNIX)

	find_path(QWT_INCLUDE_DIR qwt.h
			  PATHS /usr
					/usr/local
					/usr/local/qwt
			  PATH_SUFFIXES include
							qwt
							include/qwt
							lib/qwt.framework/Headers)

	find_library(QWT_LIBRARY
			 NAMES qwt
			 PATHS /usr
				   /usr/local
				   /usr/local/qwt
			 PATH_SUFFIXES lib
						   lib/qwt.framework)

elseif(WIN32)

	find_path(QWT_INCLUDE_DIR
			  NAMES qwt.h
			  PATH_SUFFIXES include
							qwt
							include/qwt)

	find_library(QWT_LIBRARY_RELEASE
				 NAMES qwt
				 PATH_SUFFIXES lib)

	find_library(QWT_LIBRARY_DEBUG
				 NAMES qwt_d qwtd
				 PATH_SUFFIXES lib)

	if(QWT_LIBRARY_RELEASE AND QWT_LIBRARY_DEBUG)
		set(QWT_LIBRARY optimized ${QWT_LIBRARY_RELEASE} debug ${QWT_LIBRARY_DEBUG})
	elseif(QWT_LIBRARY_RELEASE)
		set(QWT_LIBRARY optimized ${QWT_LIBRARY_RELEASE} debug ${QWT_LIBRARY_RELEASE})
	elseif(QWT_LIBRARY_DEBUG)
		set(QWT_LIBRARY optimized ${QWT_LIBRARY_DEBUG} debug ${QWT_LIBRARY_DEBUG})
	endif()

endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Qwt DEFAULT_MSG QWT_LIBRARY QWT_INCLUDE_DIR)

mark_as_advanced(QWT_INCLUDE_DIR QWT_LIBRARY)
