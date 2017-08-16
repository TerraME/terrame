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

if [ ! -z "$ghprbActualCommit" ]; then
	echo "Triggering Builds"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "C++ Syntax" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Linux Compilation" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Code analysis of package base" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Code analysis of package gis" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Documentation of package base" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Documentation of package gis" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Functional test of package base" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Functional test of package gis" "$BUILD_URL/consoleFull" "Build Triggered"
	/home/jenkins/Configs/terrame/status/send.sh $ghprbActualCommit "Execution Test" "$BUILD_URL/consoleFull" "Build Triggered"
fi

echo "### TerraLib ###"
cd $_TERRALIB_GIT_DIR
GIT_SSL_NO_VERIFY=true git fetch --progress --prune origin
git status
if [ $(git status --porcelain) ]; then # Check if TerraLib must be compiled
	git pull
	rm -rf $_TERRALIB_OUT_DIR/terralib_mod_binding_lua # Removing TerraLib Mod Binding Lua in order to re-generate it
#else
#	git status
fi


#if [ ! -z "$ghprbActualCommit" ]; then
#else
#fi

#echo $BUILD_URL

#ls -la $WORKSPACE


