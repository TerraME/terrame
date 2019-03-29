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

echo ""
echo ""
##################### TerraME Environment
echo "### TerraME Environment ###"

echo "Cleaning last directories"
rm -rf $_TERRAME_BUILD_BASE/solution $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR

echo "Creating TerraME Test directories"
mkdir $_TERRAME_BUILD_BASE/solution $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR

echo "Copying TerraME compilation scripts to TerraME Solution directory"
cp $_TERRAME_GIT_DIR/build/scripts/mac/terrame-conf.* $_TERRAME_BUILD_BASE/solution
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-build-mac-high-sierra.sh $_TERRAME_BUILD_BASE/solution
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-installer-mac-high-sierra.sh $_TERRAME_BUILD_BASE/solution
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-repository-test-mac-high-sierra.sh $_TERRAME_REPOSITORY_DIR
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-test-execution-mac-high-sierra.sh $_TERRAME_EXECUTION_DIR

echo "Copying TerraME test and config file to Test folder"
cp $_TERRAME_GIT_DIR/jenkins/all/*.lua $_TERRAME_TEST_DIR
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-unittest-mac-high-sierra.sh $_TERRAME_TEST_DIR
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-doc-mac-high-sierra.sh $_TERRAME_TEST_DIR
cp $_TERRAME_GIT_DIR/jenkins/mac/terrame-unittest-cpp-mac-high-sierra.sh $_TERRAME_TEST_DIR

echo "Copying TerraME Git Repository to Test Repository Folder"
cp -r $_TERRAME_GIT_DIR/repository/* $_TERRAME_REPOSITORY_DIR

echo "Copying TerraME Git Test Execution to Test Execution Folder"
cp -r $_TERRAME_GIT_DIR/test/* $_TERRAME_EXECUTION_DIR

echo ""
echo ""
cmake -version
echo ""
