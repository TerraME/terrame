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

find_package(Boost REQUIRED system filesystem)
find_package(Qt5Xml REQUIRED)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)

find_library(TERRALIB_CORE_LIBRARY
			NAMES terralib_mod_core
			PATHS ${TERRALIB_DIR}/lib)

find_library(TERRALIB_XML_LIBRARY
			NAMES terralib_mod_xml
			PATHS ${TERRALIB_DIR}/lib)

find_path(TERRALIB_INCLUDE_DIR terralib.h
			HINTS ${TERRALIB_DIR}/include)

set(TERRALIB_INCLUDE_DIR ${TERRALIB_DIR}/include)

file(GLOB TERRAME_QGIS_SRC_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/qgis/*.cpp)
file(GLOB TERRAME_QGIS_HDR_FILES ${TERRAME_ABSOLUTE_ROOT_DIR}/src/qgis/*.h)

add_library(qgis SHARED ${TERRAME_QGIS_SRC_FILES} ${TERRAME_QGIS_HDR_FILES})

target_include_directories(qgis PUBLIC ${TERRALIB_INCLUDE_DIR}
										${Boost_INCLUDE_DIR}
										${Qt5Xml_INCLUDE_DIRS})

target_link_libraries(qgis ${TERRALIB_CORE_LIBRARY}
							${TERRALIB_XML_LIBRARY}
							${Boost_SYSTEM_LIBRARY}
							${Boost_FILESYSTEM_LIBRARY}
							Qt5::Xml)

install(TARGETS qgis
		RUNTIME DESTINATION ${TERRAME_DESTINATION_RUNTIME}
        LIBRARY DESTINATION ${TERRAME_DESTINATION_LIBRARY}
        COMPONENT runtime)
