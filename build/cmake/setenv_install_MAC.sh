#!/bin/bash

if [ -f ~/.profile ]
then
	echo "File Found!"
else
   touch ~/.profile
fi
echo "" >> ~/.profile
echo "#Environment variable used by TerraME 1.4" >> ~/.profile
echo "TME_PATH=/usr/local/terrame" >> ~/.profile
echo "PATH=\$PATH:\$TME_PATH/bin" >> ~/.profile
echo "export TME_PATH PATH" >> ~/.profile

mkdir -p /opt/local/lib/lua/5.2/
mkdir -p /usr/local/lib/lua/5.2/
ln -s /usr/local/terrame/lib/libqtluae.0.1.dylib /opt/local/lib/lua/5.2/
ln -s /usr/local/terrame/lib/libqtluae.0.1.dylib /usr/local/lib/lua/5.2/
ln -s /usr/local/terrame/lib/libqtluae.0.1.dylib /usr/local/terrame/bin/qtluae.so
