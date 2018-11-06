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
## It prepares a entire TerraME build process. Firstly, it prepares environment, cloning both TerraME and TerraLib.
## After that, It copies required scripts to respective folders. Once done, it compiles TerraLib.
## Jenkins will export variables defined in jenkins/linux for respective build type. If PR events, it uses VARIABLES-ci.
## Otherwise, use VARIABLES-daily
##
#
## VARIABLES:
## _TERRAME_GIT_DIR - Path to TerraME clone
## _TERRALIB_GIT_DIR - Path to TerraLib clone
## _TERRAME_DEPENDS_DIR - Path to TerraME dependencies
## _TERRALIB_INSTALL_PATH - Path to TerraLib Installation
## _TERRALIB_3RDPARTY_DIR - Path to TerraLib dependencies
## _TERRAME_TEST_DIR - Path where TerraME tests will execute.
## _TERRAME_REPOSITORY_DIR - Path where TerraME repository test will execute
## _TERRAME_EXECUTION_DIR - Path where TerraME test execution will run
## ghprbActualCommit (Injected by Jenkins on GitHub Pull Requests) (Optional) - Git Commit hash
## sha1 (Injected by Jenkins on GitHub Pull Requests) (Optional) - Represents refspec Pull Request (origin/PR_ID/head)
#
## USAGE:
## ./terrame-terralib-build-mac-el-capitan.sh
##
#

# Constants
_TERRALIB_BRANCH=release-5.4

# Removing TerraLib Mod Binding Lua in order to re-generate folder if there is
rm -rf $_TERRALIB_BUILD_BASE/solution $_TERRALIB_GIT_DIR $_TERRAME_BUILD_BASE/solution
rm -rf $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR

echo "### TerraLib ###"
git clone -b $_TERRALIB_BRANCH https://gitlab.dpi.inpe.br/rodrigo.avancini/terralib.git $_TERRALIB_GIT_DIR

# Creating TerraME Test folders and TerraLib solution
mkdir $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR $_TERRALIB_BUILD_BASE/solution $_TERRAME_BUILD_BASE/solution

cd $_TERRALIB_BUILD_BASE/solution

# Copying TerraME Git Repository to Test Repository Folder
cp -r $_TERRAME_GIT_DIR/repository/* $_TERRAME_REPOSITORY_DIR
# Copying TerraME Git Test Execution to Test Execution Folder
cp -r $_TERRAME_GIT_DIR/test/* $_TERRAME_EXECUTION_DIR
# Copying TerraME test and config file to Test folder
cp $_TERRAME_GIT_DIR/jenkins/all/*.lua $_TERRAME_TEST_DIR
# Copying TerraME TerraLib compilation scripts to TerraLib solution folder
cp $_TERRAME_GIT_DIR/build/scripts/mac/terralib-conf.* .
# Copying TerraME compilation scripts to TerraME Solution folder
cp $_TERRAME_GIT_DIR/build/scripts/mac/terrame-conf.* $_TERRAME_BUILD_BASE/solution

cmake -version

# Compile TerraLib
./terralib-conf.sh

# Returns a TerraLib compilation execution code in order to Jenkins be able to set build status
exit $?
