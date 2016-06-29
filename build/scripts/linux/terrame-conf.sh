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
# variables to reflect you environment.
# -----------------
# Location of the builded 3rd-parties.
export _TERRALIB_3RDPARTY_DIR=/home/avancini/terralib/3rdparty/libs
export _TERRAME_DEPENDS_DIR=/home/avancini/terrame/3rdparty/install
export _TERRALIB_MODULES_DIR=/home/avancini/terralib/build-cmake/install
export _QT5_DIR=/home/avancini/Qt/5.7/gcc_64

# Location to install TerraLib
export _TERRAME_INSTALL_PATH=$(pwd)/install

# Build location (where is tha Makefile)
export _TERRAME_OUT_DIR=$(pwd)/build

# -----------------
# Configuring output folder
# -----------------
mkdir $_TERRAME_OUT_DIR
cp -rf terrame-conf.cmake $_TERRAME_OUT_DIR

# -----------------
# Entering the output folder
# -----------------
cd $_TERRAME_OUT_DIR

# -----------------
# Calling CMake: note that we are using a release configuration and Xcode generator
# -----------------
cmake -G "Unix Makefiles" -C terrame-conf.cmake ./../../git/terrame/build/cmake

make -j4
make install
