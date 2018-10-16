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

message("CMAKE_INSTALL_PREFIX $ENV{_TERRALIB_INSTALL_PATH}")

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type" FORCE)
set(CMAKE_INSTALL_PREFIX "$ENV{_TERRALIB_INSTALL_PATH}" CACHE PATH "Where to install TerraLib?" FORCE)
set(CMAKE_PREFIX_PATH "$ENV{_TERRALIB_3RDPARTY_DIR};$ENV{_TERRALIB_3RDPARTY_DIR}/lib;$ENV{_TERRALIB_3RDPARTY_DIR}/include;$ENV{_TERRALIB_3RDPARTY_DIR}/gdal2;$ENV{_TERRALIB_3RDPARTY_DIR}/pgsql" CACHE PATH "Where are the dependencies of TerraLib?" FORCE)

set(Qt5_DIR "" CACHE PATH "Disabled Qt" FORCE)
set(SWIG_EXECUTABLE "$ENV{_TERRALIB_3RDPARTY_DIR}/bin/swig" CACHE FILEPATH "Where are the SWIG?" FORCE)
set(TERRALIB_DIR_VAR_NAME "TME_PATH" CACHE STRING "Name of an environment variable with the base installation path of TerraLib")
set(BOOST_ROOT "$ENV{_TERRALIB_3RDPARTY_DIR}" CACHE PATH "Boost directory" FORCE)

# Specific configurations
set(TERRALIB_BUILD_EXAMPLES_ENABLED OFF CACHE BOOL "Build the examples?" FORCE)#
set(TERRALIB_BUILD_UNITTEST_ENABLED OFF CACHE BOOL "Build the unit tests?" FORCE)#
set(TERRALIB_TRACK_3RDPARTY_DEPENDENCIES OFF CACHE BOOL "Track the 3rd-parties on instalation?" FORCE)
set(TERRALIB_BUILD_AS_BUNDLE OFF CACHE BOOL "If on, tells that the build will generate a bundle" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "Build testing?" FORCE)

# Enabling modules
set(TERRALIB_MOD_MNT_CORE_ENABLED ON CACHE BOOL "Build MNT Processing Core module?" FORCE)
set(TERRALIB_MOD_BINDING_LUA_ENABLED ON CACHE BOOL "Build TerraLib bindings?" FORCE)
set(TERRALIB_EXAMPLE_BINDING_LUA_ENABLED OFF CACHE BOOL "Build TerraLib bindings example?" FORCE)
set(TERRALIB_DOXYGEN OFF CACHE BOOL  "Enable API documentation build?" FORCE)
set(TERRALIB_LOGGER_ENABLED OFF CACHE BOOL  "Logger?" FORCE)
set(TERRALIB_TRANSLATOR_ENABLED OFF CACHE BOOL "Enable translator support?" FORCE)
set(TERRALIB_QTRANSLATION_ENABLED OFF CACHE BOOL "Enable translation for Qt Widgets?" FORCE)
set(TERRALIB_MOD_WMS_QT_ENABLED OFF CACHE BOOL "Build the TerraLib Qt Web Map Service?" FORCE)
set(TERRALIB_MOD_QT_WIDGETS_ENABLED OFF CACHE BOOL "Build Terralib Qt Widgets module?" FORCE)
set(TERRALIB_MOD_STATISTICS_QT_ENABLED OFF CACHE BOOL "Build Qt support for Statistics module?" FORCE)
set(TERRALIB_MOD_VP_QT_ENABLED OFF CACHE BOOL "Build Vector Processing Qt module?" FORCE)
set(TERRALIB_MOD_SA_QT_ENABLED OFF CACHE BOOL "Build Spatial Analysis Qt module?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_LAYOUT_ENABLED OFF CACHE BOOL "Build Layout plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_ADO_ENABLED OFF CACHE BOOL "Build ADO Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_GDAL_ENABLED OFF CACHE BOOL "Build GDAL Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_OGR_ENABLED OFF CACHE BOOL "Build OGR Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_POSTGIS_ENABLED OFF CACHE BOOL "Build PostGIS Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_TERRALIB4_ENABLED OFF CACHE BOOL "Build TerraLib4 Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_WCS_ENABLED OFF CACHE BOOL "Build WCS Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_WFS_ENABLED OFF CACHE BOOL "Build WFS Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_DATASOURCE_WMS_ENABLED OFF CACHE BOOL "Build WMS Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_VP_ENABLED OFF CACHE BOOL "Build Vector Processing Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_RP_ENABLED OFF CACHE BOOL "Build Raster Processing Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_SA_ENABLED OFF CACHE BOOL "Build Spatial Analysis Driver Qt plugin?" FORCE)
set(TERRALIB_TERRAVIEW OFF CACHE BOOL "Build TerraView?" FORCE)
set(TERRALIB_MOD_BINDING_JAVA_ENABLED OFF CACHE BOOL "Build TerraLib bindings?" FORCE)
set(TERRALIB_MOD_BINDING_PYTHON_ENABLED OFF CACHE BOOL "Build TerraLib bindings?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_CELLSPACE_ENABLED OFF CACHE BOOL "Build Cellular Spaces Qt Plugin?" FORCE)
set(TERRALIB_MOD_ATTRIBUTEFILL_QT_ENABLED OFF CACHE BOOL "Build Attribute Fill Qt module?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_ADDRESSGEOCODING OFF CACHE BOOL "Build Address Geocoding Driver Qt plugin?" FORCE)
set(TERRALIB_MOD_EDIT_QT_ENABLED OFF CACHE BOOL "Build Edit Qt module?" FORCE)
set(TERRALIB_MOD_QT_PLUGINS_EDIT_ENABLED OFF CACHE BOOL "Build Edit Qt plugin?" FORCE)
set(TERRALIB_QHELP_ENABLED OFF CACHE BOOL "QHelp?" FORCE)
set(TERRALIB_MOD_WS_OGC_WMS_QT_ENABLED OFF CACHE BOOL "Build Qt Components for OGC WMS?" FORCE)
set(TERRALIB_MOD_WS_OGC_WCS_CLIENT_ENABLED OFF CACHE BOOL "Build OGC WCS Client Support?" FORCE)
set(TERRALIB_MOD_METADATA_ENABLED OFF CACHE BOOL "Build Metadata?" FORCE)
