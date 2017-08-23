
COMMIT=$1
PACKAGE=$2
CONTEXT="Documentation of package $PACKAGE"
STATUS="pending"
DESCRIPTION="Running."
TARGET_URL="$BUILD_URL/consoleFull"

/home/jenkins/Configs/terrame/status/send.sh $COMMIT "$CONTEXT" "$STATUS" "$TARGET_URL" "$DESCRIPTION" "$PACKAGE"

export TME_PATH=$TERRAME_PATH/bin
export PATH=$PATH:$TME_PATH
export LD_LIBRARY_PATH=$TME_PATH

cd $TERRAME_PACKAGE_PATH

terrame -color -package $PACKAGE -projects 2> /dev/null
terrame -color -package $PACKAGE -doc 2> /dev/null
RESULT=$?

if [ $RESULT -eq 0 ]; then
  STATUS="success"
  DESCRIPTION="Executed Successfully"
else
  STATUS="failure"
  DESCRIPTION="$RESULT errors found"
fi

/home/jenkins/Configs/terrame/status/send.sh $COMMIT "$CONTEXT" "$STATUS" "$TARGET_URL" "$DESCRIPTION" "$PACKAGE"

exit $RESULT
