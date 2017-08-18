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

# usage: ./terrame-git-notify-linux-ubuntu-14.04.sh COMMIT_HASH STATUS_CONTEXT STATUS JOB_URL

STATUS=$3

# Define the status
if [ $STATUS -eq 0 ]; then
	GITHUB_STATUS="success"
	GITHUB_DESCRIPTION="Success"
elif [ $STATUS -eq -2 ]; then
	GITHUB_STATUS="pending"
	GITHUB_DESCRIPTION="Triggered"
elif [ $STATUS -eq -1 ]; then
	GITHUB_STATUS="pending"
	GITHUB_DESCRIPTION="Running"	
elif [ $STATUS -eq 255 ]; then
	GITHUB_STATUS="failure"
	GITHUB_DESCRIPTION="Failure: $STATUS or more errors found"
else
	GITHUB_STATUS="failure"
	GITHUB_DESCRIPTION="Failure: $STATUS errors found"
fi

/home/jenkins/Configs/terrame/status/send.sh $1 $2 "$GITHUB_STATUS" $4 "$GITHUB_DESCRIPTION"

exit $?
