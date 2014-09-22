#!/bin/bash

if [ -f ~/.profile ]
then
	echo "File Found!"
else
   touch ~/.profile
fi
echo "" >> ~/.profile
echo "#Environment variable used by TerraME 1.3.1" >> ~/.profile
echo "TME_PATH_1_3_1=/usr/local/terrame" >> ~/.profile
echo "PATH=\$PATH:\$TME_PATH_1_3_1/bin" >> ~/.profile
echo "DYLD_LIBRARY_PATH=\$DYLD_LIBRARY_PATH:\$TME_PATH_1_3_1/lib" >> ~/.profile
echo "export TME_PATH_1_3_1 PATH DYLD_LIBRARY_PATH" >> ~/.profile
echo "alias terrame=TerraME"
