#!/bin/bash -l
exit 0
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
## It performs a TerraME doc generation of any package. For TerraME purporses, "base" and "gis" internal packages. 
## It may be useful for TerraME external packages.
#
## USAGE:
## ./terrame-doc-linux-ubuntu-14.04.sh PACKAGE_NAME
#
## WHERE:
## PACKAGE_NAME - Represents a name of TerraME package to execute
##
#

# Exporting context
export TME_PATH=$_TERRAME_INSTALL_PATH/bin
export PATH=$PATH:$TME_PATH
export LD_LIBRARY_PATH=$TME_PATH

TERRAME_COMMANDS=""
terrame -version
if [ "$1" != "" ] && [ "$1" != "base" ]; then
  TERRAME_COMMANDS="-package $1"
  terrame -color $TERRAME_COMMANDS -projects 2>/dev/null
fi

# Execute TerraME doc generation
terrame -color $TERRAME_COMMANDS -doc 2> /dev/null
# Retrieve TerraME exit code
exit $?