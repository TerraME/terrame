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
# Valid parameter val or abort script
#
function valid()
{
	if [ $1 -ne 0 ]; then
		echo $2
		echo ""
		exit 1
	fi
}

echo ""
echo ""

echo "TerraLib GitLab environment"
cd $_TERRALIB_GIT_DIR

GIT_SSL_NO_VERIFY=true git fetch --progress --prune origin
git remote update
git status
GIT_STATUS=$(git status)

echo "Check if TerraLib must be updated"
if [ -z "$ghprbActualCommit" ]; then
	echo "Daily tests are always updated"
	cd $_TERRALIB_BUILD_BASE

	rm -rf $_TERRALIB_GIT_DIR $_TERRALIB_BUILD_BASE/solution $_TERRALIB_INSTALL_PATH
	valid $? "Error: Cleaning fail"

	mkdir $_TERRALIB_GIT_DIR $_TERRALIB_BUILD_BASE/solution
	valid $? "Error: Cleaning fail"

	git clone -b $_TERRALIB_BRANCH https://gitlab.dpi.inpe.br/rodrigo.avancini/terralib.git $_TERRALIB_GIT_DIR
elif [[ "$GIT_STATUS" = *"git pull"* ]]; then
	git pull --no-commit origin $_TERRALIB_BRANCH
	echo "Cleaning last install"
	rm -rf $_TERRALIB_OUT_DIR/terralib_mod_binding_lua  $_TERRALIB_INSTALL_PATH
	valid $? "Error: Cleaning fail"
else
	echo ""
	echo ""
	echo "Updating is not necessary"
	rm -rf $_TERRALIB_INSTALL_PATH
fi

echo ""
echo ""
######################## TerraLib Environment
echo "### TerraLib Environment ###"
echo "Cleaning last config scripts"
rm -rf $_TERRALIB_BUILD_BASE/solution/terralib-conf.*
valid $? "Error: Cleaning fail"

echo "Copying TerraLib compilation scripts to TerraLib Solution folder"
cp --verbose $_TERRAME_GIT_DIR/build/scripts/linux/terralib-conf.* $_TERRALIB_BUILD_BASE/solution
valid $? "Error: Copying fail"

echo ""
echo ""
echo ""

tree -D -L 2 $_TERRALIB_BUILD_BASE

echo "### TerraLib Environment Finished ###"
echo ""
echo ""

# Returns a TerraLib compilation execution code in order to Jenkins be able to set build status
echo "Compiling TerraLib"
cd $_TERRALIB_BUILD_BASE/solution
./terralib-conf.sh
RESULT=$?

echo ""
echo ""

exit $RESULT
