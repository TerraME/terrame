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
STATUS="pending"
DESCRIPTION="Running."
TARGET_URL="$BUILD_URL/consoleFull"

/home/jenkins/Configs/terrame/status/send.sh $COMMIT "$CONTEXT" "$STATUS" "$TARGET_URL" "$DESCRIPTION" "$PACKAGE"

export TME_PATH=$TERRAME_PATH/bin
export PATH=$PATH:$TME_PATH
export LD_LIBRARY_PATH=$TME_PATH

cd $TERRAME_PACKAGE_PATH

cp /home/jenkins/Configs/terrame/tests/files/config.lua .
terrame -color -package $PACKAGE -test 2> /dev/null
RESULT=$?

if [ $RESULT -eq 0 ]; then
  STATUS="success"
  DESCRIPTION="Executed Successfully"
else
  STATUS="failure"
  DESCRIPTION="$RESULT errors found"
fi

/home/jenkins/Configs/terrame/status/send.sh $COMMIT "$CONTEXT" "$STATUS" "$TARGET_URL" "$DESCRIPTION" "$PACKAGE"

rm -rf $TERRAME_PACKAGE_PATH

exit $RESULT
