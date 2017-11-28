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
echo ""
##################### TerraME Environment
echo "### TerraME Environment ###"

echo "Cleaning last directories"
rm -rf $_TERRAME_BUILD_BASE/solution $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR
valid $? "Error: Cleaning fail"

echo "Creating TerraME Test directories"
mkdir $_TERRAME_BUILD_BASE/solution $_TERRAME_REPOSITORY_DIR $_TERRAME_TEST_DIR $_TERRAME_EXECUTION_DIR
valid $? "Error: Creating fail"

echo "Copying TerraME compilation scripts to TerraME Solution directory"
cp --verbose $_TERRAME_GIT_DIR/build/scripts/linux/terrame-conf.* $_TERRAME_BUILD_BASE/solution
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-build-linux-ubuntu-14.04.sh $_TERRAME_BUILD_BASE/solution
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-git-notify-linux-ubuntu-14.04.sh $_TERRAME_BUILD_BASE/solution
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-installer-linux-ubuntu-14.04.sh $_TERRAME_BUILD_BASE/solution
valid $? "Error: Copying fail"

echo ""
echo ""
echo ""
####################### GitHub Triggers
if [ ! -z "$ghprbActualCommit" ]; then
	echo "Triggering All Builds"
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "C++ Syntax" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Linux Compilation" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "C++ Unit Testing" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Code analysis of package base" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Code analysis of package gis" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Documentation of package base" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Documentation of package gis" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Functional test of package base" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Functional test of package gis" -2 "$BUILD_URL/consoleFull"
	sleep 1s
	$_TERRAME_BUILD_BASE/solution/terrame-git-notify-linux-ubuntu-14.04.sh $ghprbActualCommit "Execution Test" -2 "$BUILD_URL/consoleFull"
fi

cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-repository-test-linux-ubuntu-14.04.sh $_TERRAME_REPOSITORY_DIR
valid $? "Error: Copying fail"

cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-test-execution-linux-ubuntu-14.04.sh $_TERRAME_EXECUTION_DIR
valid $? "Error: Copying fail"

echo "Copying TerraME test and config file to Test folder"
cp --verbose $_TERRAME_GIT_DIR/jenkins/all/*.lua $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-unittest-linux-ubuntu-14.04.sh $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-code-analysis-linux-ubuntu-14.04.sh $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-doc-linux-ubuntu-14.04.sh $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-unittest-cpp-linux-ubuntu-14.04.sh $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"
cp --verbose $_TERRAME_GIT_DIR/jenkins/linux/terrame-syntaxcheck-cpp-linux-ubuntu-14.04.sh $_TERRAME_TEST_DIR
valid $? "Error: Copying fail"

echo ""
echo ""
echo ""

tree -D -L 2 $_TERRAME_BUILD_BASE

echo "Copying TerraME Git Repository to Test Repository Folder"
cp -r $_TERRAME_GIT_DIR/repository/* $_TERRAME_REPOSITORY_DIR
valid $? "Error: Copying fail"

echo "Copying TerraME Git Test Execution to Test Execution Folder"
cp -r $_TERRAME_GIT_DIR/test/* $_TERRAME_EXECUTION_DIR
valid $? "Error: Copying fail"

echo ""
echo ""
echo ""
