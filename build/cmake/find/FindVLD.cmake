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
#  Description: Find VLD - find Visual Leak Detector include directory and libraries.
#
#  VLD_INCLUDE_DIR - where to find vld.h.
#  VLD_LIBRARY     - where to find VLD libraries.
#  VLD_FOUND       - True if VLD found.
#
#  Author: Eric Silva Abreu <eric.abreu@funcate.org.br>
#

if(WIN32)

  find_path(VLD_INCLUDE_DIR
            NAMES vld.h
            PATH_SUFFIXES include)

  find_library(VLD_LIBRARY_RELEASE
               NAMES vld
               PATH_SUFFIXES lib/Win64)
 
  find_library(VLD_LIBRARY_DEBUG
               NAMES vld_d vldd
               PATH_SUFFIXES lib/Win64)
 
  if(VLD_LIBRARY_RELEASE AND VLD_LIBRARY_DEBUG)
    set(VLD_LIBRARY optimized ${VLD_LIBRARY_RELEASE} debug ${VLD_LIBRARY_DEBUG})
  elseif(VLD_LIBRARY_RELEASE)
    set(VLD_LIBRARY optimized ${VLD_LIBRARY_RELEASE} debug ${VLD_LIBRARY_RELEASE})
  elseif(VLD_LIBRARY_DEBUG)
    set(VLD_LIBRARY optimized ${VLD_LIBRARY_DEBUG} debug ${VLD_LIBRARY_DEBUG})
  endif()

endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(VLD DEFAULT_MSG VLD_LIBRARY VLD_INCLUDE_DIR)

mark_as_advanced(VLD_INCLUDE_DIR VLD_LIBRARY)
