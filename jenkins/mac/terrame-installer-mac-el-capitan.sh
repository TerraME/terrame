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
## It performs a TerraME Installer generation on MacOSX environment
#
## USAGE:
## ./terrame-installer-linux-ubuntu-14.04.sh
#

export _TERRAME_CREATE_INSTALLER="ON"
export _TERRAME_BUILD_AS_BUNDLE="ON"

cd $_TERRAME_OUT_DIR/..

cp -rap $_TERRAME_INSTALL_PATH/bin/packages/base/doc $_TERRAME_GIT_DIR/packages/base/doc
cp -rap $_TERRAME_INSTALL_PATH/bin/packages/terralib/doc $_TERRAME_GIT_DIR/packages/terralib/doc

# Removing old builds
rm -rf $_TERRAME_INSTALL_PATH $_TERRAME_OUT_DIR

# Executing TerraME build script
./terrame-conf.sh

exit $?