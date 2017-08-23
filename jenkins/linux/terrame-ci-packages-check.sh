set +e

PACKAGE=$1

mkdir -p $TERRAME_PACKAGE_PATH/$PACKAGE

cp -rap * $TERRAME_PACKAGE_PATH/$PACKAGE

cd $TERRAME_PACKAGE_PATH

cp $TERRAME_JENKINS_SCRIPTS_PATH/terrame-code-analysis-linux-ubuntu-14.04.sh .
./terrame-code-analysis-linux-ubuntu-14.04.sh $PACKAGE

exit $?
