set +e

PACKAGE=$1

mkdir -p $TERRAME_PACKAGE_PATH/$PACKAGE

cp -rap * $TERRAME_PACKAGE_PATH/$PACKAGE

cd $TERRAME_PACKAGE_PATH

# Exporting terrame vars
export TME_PATH="$TERRAME_PATH/bin"
export PATH=$PATH:$TME_PATH
export LD_LIBRARY_PATH=$TME_PATH

terrame -version
terrame -color -package $PACKAGE -uninstall
terrame -color -package $PACKAGE -check
RESULT=$?

exit $RESULT
