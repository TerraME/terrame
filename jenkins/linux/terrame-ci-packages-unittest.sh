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
