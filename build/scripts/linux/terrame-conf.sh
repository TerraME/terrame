#!/bin/bash
# TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
# Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org
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

# -----------------
# Script for building a TerraLib5 customized for TerraAmazon
# -----------------

# -----------------
# Setting up the environment variables: change the values of the above
# variables or just export them before in order to reflect you environment.
# -----------------
# Location of the builded 3rd-parties.

# Checking Terralib 3rdparty dir
if [ "$_TERRALIB_3RDPARTY_DIR" == "" ]; then
  _TERRALIB_3RDPARTY_DIR="/home/developer/terralib/3rdparty/libs"
fi
export _TERRALIB_3RDPARTY_DIR="$_TERRALIB_3RDPARTY_DIR"

# checking terrame 3rdparty dir
if [ "$_TERRAME_DEPENDS_DIR" == "" ]; then
  _TERRAME_DEPENDS_DIR="/home/developer/terrame/3rdparty/install"
fi
export _TERRAME_DEPENDS_DIR="$_TERRAME_DEPENDS_DIR"

# Checking Terralib Modules Dir
if [ "$_TERRALIB_MODULES_DIR" == "" ]; then
  _TERRALIB_MODULES_DIR="/home/developer/terralib/build-cmake/install"
fi
export _TERRALIB_MODULES_DIR="$_TERRALIB_MODULES_DIR"

# Checking QT5 dir
if [ "$_QT5_DIR" == "" ]; then
  _QT5_DIR=/usr/lib/x86_64-linux-gnu/cmake/Qt5
fi
export _QT5_DIR=$_QT5_DIR

# Checking Location to install TerraME
if [ "$_TERRAME_INSTALL_PATH" == "" ]; then
  _TERRAME_INSTALL_PATH=$(pwd)/install
fi
export _TERRAME_INSTALL_PATH="$_TERRAME_INSTALL_PATH"

# Checking Build location
if [ "$_TERRAME_OUT_DIR" == "" ]; then
_TERRAME_OUT_DIR=$(pwd)/build
fi
export _TERRAME_OUT_DIR="$_TERRAME_OUT_DIR"

# Checking source code location
if [ "$_TERRAME_GIT_DIR" == "" ]; then
  _TERRAME_GIT_DIR="../../git/terrame"
fi
export _TERRAME_GIT_DIR="$_TERRAME_GIT_DIR"

# Configuring output folder
mkdir -p $_TERRAME_OUT_DIR
cp -rf terrame-conf.cmake $_TERRAME_OUT_DIR

# Entering the output folder
cd $_TERRAME_OUT_DIR

# Calling CMake
cmake -G "Unix Makefiles" -C terrame-conf.cmake $_TERRAME_GIT_DIR/build/cmake

make -j4
make install
