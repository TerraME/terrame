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

if(UNIX)
	find_path(XERCES_INCLUDE_DIR
				NAMES xercesc/util/XercesVersion.hpp
				PATHS /usr
					/usr/local
				PATH_SUFFIXES include)

	find_library(XERCES_LIBRARY
				NAMES xerces-c
				PATHS /usr
					 /usr/local
				PATH_SUFFIXES lib)
elseif(WIN32)
	find_path(XERCES_INCLUDE_DIR
				NAMES xercesc/util/XercesVersion.hpp
					include/xerces
				PATH_SUFFIXES include
				)

	find_library(XERCES_LIBRARY_RELEASE
				NAMES xerces-c xerces-c_3
				PATH_SUFFIXES lib
				)

	find_library(XERCES_LIBRARY_DEBUG
				NAMES xerces-cD xerces-c_3D
				PATH_SUFFIXES lib
				)
	if(XERCES_LIBRARY_RELEASE AND XERCES_LIBRARY_DEBUG)
		set(XERCES_LIBRARY optimized ${XERCES_LIBRARY_RELEASE} debug ${XERCES_LIBRARY_DEBUG})
	elseif(XERCES_LIBRARY_RELEASE)
		set(XERCES_LIBRARY optimized ${XERCES_LIBRARY_RELEASE} debug ${XERCES_LIBRARY_RELEASE})
	elseif(XERCES_LIBRARY_DEBUG)
		set(XERCES_LIBRARY optimized ${XERCES_LIBRARY_DEBUG} debug ${XERCES_LIBRARY_DEBUG})
	endif()
endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(Xerces DEFAULT_MSG XERCES_LIBRARY XERCES_INCLUDE_DIR)

if(XERCES_INCLUDE_DIR AND XERCES_LIBRARY)
	message("Xerces found!")
	message("Xerces include ${XERCES_INCLUDE_DIR}")
	message("Xerces library ${XERCES_LIBRARY}")
else()
	message("Xerces not found!")
endif()

mark_as_advanced(XERCES_INCLUDE_DIR XERCES_LIBRARY)
