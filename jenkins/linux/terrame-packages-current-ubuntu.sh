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

echo ""
echo ""

export TME_PATH="$_TERRAME_INSTALL_PATH/bin"
export PATH=$PATH:$TME_PATH

terrame -version


export GIT_BASE_URL=https://github.com/TerraME

repos=(
	ca
	calibration
	logo
	gpm
	publish
	sci
	sysdyn
)

for i in "${repos[@]}"; do
	git clone "$GIT_BASE_URL/$i" $i
done

RESULT=0

for i in "${repos[@]}"; do
	echo ""
	echo "###########################################################"
	terrame -color -package $i -check
	RESULT=$(($? + $RESULT))
	echo ""
	echo "###########################################################"	
	terrame -color -package $i -projects
	RESULT=$(($? + $RESULT))
	echo ""
	echo "###########################################################"
	terrame -color -package $i -doc
	RESULT=$(($? + $RESULT))
	echo ""
	echo "###########################################################"	
	terrame -color -package $i -test
	RESULT=$(($? + $RESULT))		
done

echo ""
echo ""

exit $RESULT
