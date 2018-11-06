#!/bin/bash -l

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
## It performs TerraME TerraLib compilation on MacOSX El Capitan system
#

if [ -z "$_TERRALIB_TARGET_3RDPARTY_DIR" ]; then
  export _TERRALIB_TARGET_3RDPARTY_DIR="$HOME/MyDevel/terrame/terralib/3rdparty/5.4"
fi

if [ -z "$_TERRAME_TARGET_3RDPARTY_DIR" ]; then
  export _TERRAME_TARGET_3RDPARTY_DIR="$HOME/MyDevel/terrame/terrame/3rdparty"
fi

_TERRALIB_VERSION="5.4"
_TERRALIB_BRANCH="release-$_TERRALIB_VERSION"
export _TERRALIB_3RDPARTY_NAME="terralib-3rdparty-macosx-el-capitan.tar.gz"
export _TERRALIB_TARGET_URL="http://www.dpi.inpe.br/terralib5-devel/3rdparty/src/$_TERRALIB_VERSION/$_TERRALIB_3RDPARTY_NAME"

export PATH=$PATH:$_QT5_DIR:$_CMAKE_DIR

#
# Valid parameter val or abort script
#
function valid_operation()
{
  if [ $1 -ne 0 ]; then
    echo $2
    echo ""
    exit $1
  else
    echo "done."
  fi
}


echo ""
echo "#### TerraME Dependencies Compilation on MacOSX El Capitan ####"
echo ""

echo -ne "Cleaning up old builds ... "
rm -rf $_TERRAME_TARGET_3RDPARTY_DIR
mkdir -p $_TERRAME_TARGET_3RDPARTY_DIR
cd $_TERRALIB_TARGET_3RDPARTY_DIR
echo "done."

echo ""

echo -ne "Downloading TerraLib 3rdparty ... "
curl -L -O $_TERRALIB_TARGET_URL --silent
valid_operation $? "Error. Check $_TERRALIB_TARGET_URL"

echo -ne "Cloning TerraLib ... "
rm -rf $_TERRALIB_GIT_DIR
mkdir $_TERRALIB_GIT_DIR
git clone -b $_TERRALIB_BRANCH https://gitlab.dpi.inpe.br/rodrigo.avancini/terralib.git $_TERRALIB_GIT_DIR --quiet
valid_operation $? "Error. Could not clone TerraLib $_TERRALIB_BRANCH" terralib

# Configuring TerraLib 3rdparty compilation
cp -v $_TERRALIB_GIT_DIR/install/install-3rdparty-macosx-el-capitan.sh .

echo -ne "Compiling TerraLib dependencies ... "
TERRALIB_DEPENDENCIES_DIR="$_TERRALIB_TARGET_3RDPARTY_DIR/libs" ./install-3rdparty-macosx-el-capitan.sh
valid_operation $? "Error: Could not finish TerraLib 3rdparty compilation"

echo ""
echo ""

cd $_TERRAME_TARGET_3RDPARTY_DIR

# Configuring TerraME dependencies compilation
cp -v $_TERRAME_GIT_DIR/build/scripts/mac/terrame-deps-conf.sh .

echo -ne "Downloading Protobuf ... "
curl -L -O https://github.com/google/protobuf/releases/download/v3.1.0/protobuf-cpp-3.1.0.tar.gz --silent
valid_operation $? "Error. Could not download 3rdparty"

echo -ne "Downloading Luacheck ... "
curl -L -O https://github.com/mpeterv/luacheck/archive/0.17.0.tar.gz --silent
valid_operation $? "Error: Could not download LuaCheck"

echo ""
echo -ne "Preparing to compilation ... "
tar zxf protobuf-cpp-3.1.0.tar.gz
valid_operation $? "Error: Could not extract protobuff"
mv protobuf-3.1.0 protobuf
valid_operation $? "Error: Could find 'protobuf' folder inside compressed protobuf"
tar zxf 0.17.0.tar.gz
valid_operation $? "Error: Could not extract Luacheck"
mv luacheck* luacheck
valid_operation $? "Error: Could find luacheck inside luacheck compressed file"

echo -ne "Compiling TerraME dependencies ... "
./terrame-deps-conf.sh
valid_operation $? "Error: Could not finish TerraME 3rdparty compilation."

echo ""
echo "Finished"
echo ""
