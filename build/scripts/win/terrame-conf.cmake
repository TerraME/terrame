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
#

# Main configurations
set(CMAKE_BUILD_TYPE "$ENV{_TERRAME_BUILD_TYPE}" CACHE PATH "Build Type" FORCE)
set(CMAKE_INSTALL_PREFIX "$ENV{_TERRAME_INSTALL_PATH}" CACHE PATH "Where to install TerraME?" FORCE)
set(CMAKE_PREFIX_PATH "$ENV{_TERRALIB_3RDPARTY_DIR};$ENV{_Qt5_DIR}/lib/cmake;$ENV{_TERRAME_DEPENDS_DIR};$ENV{_MSYS_DIR};$ENV{_TERRAME_VLD_DIR}" CACHE PATH "Where are the dependencies of TerraME?" FORCE)
set(TERRAME_VERSION_STATUS "" CACHE STRING "Define name of installer" FORCE)

set(TERRAME_BUILD_AS_BUNDLE $ENV{_TERRAME_BUILD_AS_BUNDLE} CACHE BOOL "If on, tells that the build will generate a bundle" FORCE)
set(TERRAME_CREATE_INSTALLER $ENV{_TERRAME_CREATE_INSTALLER} CACHE BOOL "Create the installer" FORCE)
set(TERRAME_MEMORY_LEAK_DETECTOR OFF CACHE BOOL "Create the installer" FORCE)

# Paths configurations
set(MSYS_DIR "$ENV{_MSYS_DIR}" CACHE PATH "MSYS directory" FORCE)
set(TERRAME_DEPENDENCIES_DIR "$ENV{_TERRAME_DEPENDS_DIR}" CACHE PATH "TerraME dependencies" FORCE)
set(TERRALIB_DIR "$ENV{_TERRALIB_MODULES_DIR}" CACHE PATH "TerraLib directory" FORCE)
set(TERRALIB_3RDPARTY_DIR "$ENV{_TERRALIB_3RDPARTY_DIR}" CACHE PATH "TerraLib 3rdparty directory" FORCE)
set(QWT_INCLUDE_DIR "$ENV{_TERRALIB_3RDPARTY_DIR}/include/qwt" CACHE PATH "Qwt include" FORCE)
set(SWIG_EXECUTABLE "$ENV{_TERRALIB_3RDPARTY_DIR}/swig/swig.exe" CACHE FILEPATH "Where are the SWIG?" FORCE)
