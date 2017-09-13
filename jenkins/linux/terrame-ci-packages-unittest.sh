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

# Usage: ./terrame-ci-package-unittest.sh COMMIT PACKAGE
#
# COMMIT - GitCommit
# PACKAGE - TerraME Package name
#

COMMIT=$1
PACKAGE=$2
CONTEXT="Functional tests of package $PACKAGE"
TARGET_URL="$BUILD_URL/consoleFull"

$TERRAME_JENKINS_SCRIPTS_PATH/terrame-git-notify-linux-ubuntu-14.04.sh $COMMIT "$CONTEXT" "-1" "$TARGET_URL" "$PACKAGE"

echo "Check if TerraME is running"
if pgrep -x "terrame" > /dev/null; then
    echo "TerrME is already running, waiting it finishes..."
	echo ""
	sleep 30s
	while pgrep -x "terrame" > /dev/null; do
		sleep 30s
	done
fi

cd $TERRAME_PACKAGE_PATH

rm -rf terrame-unittest-linux-ubuntu-14.04.sh
cp $TERRAME_JENKINS_SCRIPTS_PATH/terrame-unittest-linux-ubuntu-14.04.sh .
./terrame-unittest-linux-ubuntu-14.04.sh $PACKAGE
RESULT=$?

$TERRAME_JENKINS_SCRIPTS_PATH/terrame-git-notify-linux-ubuntu-14.04.sh $COMMIT "$CONTEXT" "$RESULT" "$TARGET_URL" "$PACKAGE"

rm -rf $TERRAME_PACKAGE_PATH

exit $RESULT
