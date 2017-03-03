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

MACRO(TmeInstallPlugins plugins location)

  set(_files)

  foreach(plugin ${plugins})
    get_target_property(_loc ${plugin} LOCATION)
    list(APPEND _files ${_loc})
  endforeach()
  
	install(FILES ${_files}
           DESTINATION "${TERRAME_INSTALL_PREFIX}/qtplugins/${location}"
           CONFIGURATIONS Release
           COMPONENT runtime)
  
ENDMACRO(TmeInstallPlugins)


MACRO(TmeInstallQt5Plugins)
  find_package(Qt5 COMPONENTS Sql Svg PrintSupport)

# Installing image plugins
  set(_plugins Qt5::QGifPlugin Qt5::QICOPlugin Qt5::QJpegPlugin Qt5::QMngPlugin Qt5::QTiffPlugin)
  TmeInstallPlugins("${_plugins}" "imageformats")
  
# Installing svg plugins
  set(_plugins Qt5::QSvgPlugin Qt5::QSvgIconPlugin)
  TmeInstallPlugins("${_plugins}" "iconengines")
    
# Installing sql plugins
  set(_plugins Qt5::QSQLiteDriverPlugin)
  TmeInstallPlugins("${_plugins}" "sqldrivers")

# Installing printer support plugin
  if(WIN32)
    set(_plugins Qt5::QWindowsPrinterSupportPlugin)
    TmeInstallPlugins("${_plugins}" "printsupport")
  endif()
  
# Installing platform plugins
  if(WIN32)
    set(_plugins Qt5::QWindowsIntegrationPlugin Qt5::QMinimalIntegrationPlugin)
    TmeInstallPlugins("${_plugins}" "platforms")
  elseif(APPLE)
    set(_plugins Qt5::QCocoaIntegrationPlugin Qt5::QMinimalIntegrationPlugin)
    TmeInstallPlugins("${_plugins}" "platforms")
  endif()
  
ENDMACRO(TmeInstallQt5Plugins)

#
# Macro installQtPlugins
#
# Description: Installs the required Qt plugins.
#
# param plugs List of the names of plugins to be installed.
#
MACRO(TmeInstallQtPlugins plgs)

  if ("${QT_PLUGINS_DIR}" STREQUAL "")
    set (QT_PLUGINS_DIR "${Qt5_DIR}/../../../plugins")
  endif()

  set (_regex_exp "")

  set( _first TRUE)

  foreach(plg ${plgs})
    if(NOT _first)
      set (_regex_exp ${_regex_exp}|${plg})
    else()
      set (_regex_exp ${plg})
      set (_first FALSE)
    endif()
  endforeach()

  set (_regex_exp "(${_regex_exp})?(${CMAKE_SHARED_LIBRARY_SUFFIX})$")

  set (_dest "${TERRAME_INSTALL_PREFIX}/qtplugins")

  set (_plugin_dirs "imageformats;iconengines;platforms") #TODO(#1711)

  foreach(_plugin_dir ${_plugin_dirs})

    install (DIRECTORY ${QT_PLUGINS_DIR}/${_plugin_dir}
             DESTINATION ${_dest}  COMPONENT runtime
             FILES_MATCHING REGEX "${_regex_exp}")
  endforeach()

ENDMACRO(TmeInstallQtPlugins)
