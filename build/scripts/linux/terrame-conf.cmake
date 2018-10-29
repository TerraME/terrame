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

# Main configurations
set(TERRALIB_3RDPARTY_DIR "$ENV{_TERRALIB_3RDPARTY_DIR}" CACHE PATH "3RDPARTY" FORCE)
set(Qt5_DIR "$ENV{_QT5_DIR}" CACHE PATH "Qt" FORCE)
set(TERRAME_DEPENDENCIES_DIR "$ENV{_TERRAME_DEPENDS_DIR}" CACHE PATH "TerraME dependencies" FORCE)
set(TERRALIB_DIR "$ENV{_TERRALIB_MODULES_DIR}" CACHE PATH "TerraLib directory" FORCE)

set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
set(CMAKE_INSTALL_PREFIX "$ENV{_TERRAME_INSTALL_PATH}" CACHE PATH "Where to install TerraME?" FORCE)
set(CMAKE_PREFIX_PATH "${TERRALIB_3RDPARTY_DIR};${Qt5_DIR};${TERRAME_DEPENDENCIES_DIR}" CACHE PATH "Where are the dependencies of TerraME?" FORCE)
set(TERRAME_VERSION_STATUS "rc9-dev" CACHE STRING "Define name of installer" FORCE)
set(TERRAME_BUILD_AS_BUNDLE $ENV{_TERRAME_BUILD_AS_BUNDLE} CACHE BOOL "If on, tells that the build will generate a bundle" FORCE)
set(TERRAME_CREATE_INSTALLER $ENV{_TERRAME_CREATE_INSTALLER} CACHE BOOL "Create the installer" FORCE)

# Dependencies paths
set(QTLUA_INCLUDE_DIR "$ENV{_TERRALIB_3RDPARTY_DIR}/include/QtLua" CACHE PATH "QtLua include" FORCE)
set(QTLUA_LIBRARY "$ENV{_TERRALIB_3RDPARTY_DIR}/lib/libqtlua.so" CACHE PATH "QtLua lib" FORCE)
set(QTLUAEXTRAS_LIBRARY "$ENV{_TERRALIB_3RDPARTY_DIR}/lib/qtluae.so" CACHE PATH "QtLua Extras lib" FORCE)
