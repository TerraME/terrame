#!/bin/bash
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

if [ "$_TERRALIB_3RDPARTY_DIR" == "" ]; then
  _TERRALIB_3RDPARTY_DIR="/home/developer/terralib/3rdparty/libs"
fi
export _TERRALIB_3RDPARTY_DIR="$_TERRALIB_3RDPARTY_DIR"
echo "$_TERRALIB_3RDPARTY_DIR"

if [ "$_TERRALIB_INSTALL_PATH" == "" ]; then
  _TERRALIB_INSTALL_PATH=$(pwd)/install
fi
export _TERRALIB_INSTALL_PATH="$_TERRALIB_INSTALL_PATH"
echo "$_TERRALIB_INSTALL_PATH"

if [ "$_TERRALIB_OUT_DIR" == "" ]; then
  _TERRALIB_OUT_DIR=$(pwd)/build
fi
export _TERRALIB_OUT_DIR="$_TERRALIB_OUT_DIR"
echo "$_TERRALIB_OUT_DIR"

if [ "$_TERRALIB_GIT_DIR" == "" ]; then
  _TERRALIB_GIT_DIR="../../git/terralib"
fi
export _TERRALIB_GIT_DIR="$_TERRALIB_GIT_DIR"
echo "$_TERRALIB_GIT_DIR"

mkdir $_TERRALIB_OUT_DIR
cp terralib-build-conf.cmake $_TERRALIB_OUT_DIR
cd $_TERRALIB_OUT_DIR

cmake -G "Unix Makefiles" -C terralib-build-conf.cmake $_TERRALIB_GIT_DIR/build/cmake
cmake --build . --target install --config Release 
