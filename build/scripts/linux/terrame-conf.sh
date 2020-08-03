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

if [ "$_TERRAME_DEPENDS_DIR" == "" ]; then
  _TERRAME_DEPENDS_DIR="/home/developer/terrame/3rdparty/install"
fi
export _TERRAME_DEPENDS_DIR="$_TERRAME_DEPENDS_DIR"

if [ "$_TERRALIB_MODULES_DIR" == "" ]; then
  _TERRALIB_MODULES_DIR="/home/developer/terralib/solution/install"
fi
export _TERRALIB_MODULES_DIR="$_TERRALIB_MODULES_DIR"

if [ "$_QT5_DIR" == "" ]; then
  _QT5_DIR=/usr/lib/x86_64-linux-gnu/cmake/Qt5
fi
export _QT5_DIR=$_QT5_DIR

if [ "$_TERRAME_INSTALL_PATH" == "" ]; then
  _TERRAME_INSTALL_PATH=$(pwd)/install
fi
export _TERRAME_INSTALL_PATH="$_TERRAME_INSTALL_PATH"

if [ "$_TERRAME_OUT_DIR" == "" ]; then
_TERRAME_OUT_DIR=$(pwd)/build
fi
export _TERRAME_OUT_DIR="$_TERRAME_OUT_DIR"

if [ "$_TERRAME_GIT_DIR" == "" ]; then
  _TERRAME_GIT_DIR="../../git/terrame"
fi
export _TERRAME_GIT_DIR="$_TERRAME_GIT_DIR"

if [ -z ${_TERRAME_BUILD_AS_BUNDLE+x} ]; then
  _TERRAME_BUILD_AS_BUNDLE=OFF
fi
export _TERRAME_BUILD_AS_BUNDLE=$_TERRAME_BUILD_AS_BUNDLE

if [ -z ${_TERRAME_CREATE_INSTALLER+x} ]; then
  _TERRAME_CREATE_INSTALLER=OFF
fi
export _TERRAME_CREATE_INSTALLER=$_TERRAME_CREATE_INSTALLER

if [ "$_TERRAME_UBUNTU_VERSION" == "" ]; then
  _TERRAME_UBUNTU_VERSION="18"
fi
export _TERRAME_UBUNTU_VERSION="$_TERRAME_UBUNTU_VERSION"

if [ "$_TERRAME_BUILD_TYPE" == "" ]; then
  _TERRAME_BUILD_TYPE="Release"
fi
export _TERRAME_BUILD_TYPE="$_TERRAME_BUILD_TYPE"

mkdir -p $_TERRAME_OUT_DIR
cd $_TERRAME_OUT_DIR

cmake -G "Unix Makefiles" -C $_TERRAME_GIT_DIR/build/cmake/terrame-build-conf.cmake $_TERRAME_GIT_DIR/build/cmake
cmake --build . --target install --config $_TERRAME_BUILD_TYPE 
