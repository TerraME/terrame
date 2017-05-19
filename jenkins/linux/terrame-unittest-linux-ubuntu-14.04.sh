#!/bin/bash

#
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
## It performs a TerraME functional test of any package. For TerraME purporses, "base" and "terralib" internal packages. 
## It may be useful for TerraME external packages.
#
## USAGE:
## ./terrame-unittest-linux-ubuntu-14.04.sh PACKAGE_NAME
#
## WHERE:
## PACKAGE_NAME - Represents a name of TerraME package to execute
#

# Exporting enviroment variables
export TME_PATH=$_TERRAME_INSTALL_PATH/bin
export PATH=$PATH:$TME_PATH
export LD_LIBRARY_PATH=$TME_PATH

cd $_TERRAME_TEST_DIR

terrame -version

# You may use $ghprbActualCommit for handling if job has triggered by CI event or daily timer.
# In this way, if you need a specific configuration for CI execution, use this flag
#
# if [ -z "$ghprbActualCommit" ]; then
  # Daily execution config

#  if [ "$1" == "terralib" ]; then
#    echo "myconfig" > test.lua
#  else
#    echo "myconfig2" > test.lua
#  fi
# else
#  # CI execution config
# fi

TERRAME_COMMANDS=""
# Extra commands if package is terralib
if [ "$1" != "" ] && [ "$1" != "base" ]; then
  TERRAME_COMMANDS="-package $1"
fi

# Executing unittest
terrame -color $TERRAME_COMMANDS -test test.lua 2> /dev/null
RESULT=$?

# Compressing Log
tar -czf build-daily-linux-$BUILD_NUMBER.tar.gz .terrame*

# Cleaning up
rm -rf .terrame*

exit $RESULT