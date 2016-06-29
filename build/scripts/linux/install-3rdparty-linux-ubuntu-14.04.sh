#!/bin/bash
#
#  Copyright (C) 2008 National Institute For Space Research (INPE) - Brazil.
#
#  This file is part of the TerraLib - a Framework for building GIS enabled applications.
#
#  TerraLib is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation, either version 3 of the License,
#  or (at your option) any later version.
#
#  TerraLib is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with TerraLib. See COPYING. If not, write to
#  TerraLib Team at <terralib-team@terralib.org>.
#
#
#  Description: Install all required software for TerraLib on Linux Ubuntu 14.04.
#
#  Author: Gilberto Ribeiro de Queiroz
#          Paulo R. M. Oliveira
#
#
#  Example:
#  $ TERRALIB_DEPENDENCIES_DIR="/home/gribeiro/MyLibs" ./install-3rdparty-linux-ubuntu-14.04.sh
#

echo "*****************************************************************"
echo "* TerraLib 3rd-party Libraries Installer for Linux Ubuntu 14.04 *"
echo "*****************************************************************"
echo ""
sleep 1s

#
# Valid parameter val or abort script
#
function valid()
{
  if [ $1 -ne 0 ]; then
    echo $2
    echo ""
    exit
  fi
}


#
# Update Ubuntu install list
#
sudo apt-get update
valid $? "Error: could not update apt-get database list"


#
# gcc
#
gcpp_test=`dpkg -s g++ | grep Status`

if [ "$gcpp_test" != "Status: install ok installed" ]; then
  sudo  apt-get -y install g++
  valid $? "Error: could not install g++! Please, install g++: sudo apt-get -y install g++"
  echo "g++ installed!"
else
  echo "g++ already installed!"
fi


#
# zlibdevel
#
zlibdevel_test=`dpkg -s zlib1g-dev | grep Status`

if [ "$zlibdevel_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install zlib1g-dev
  valid $? "Error: could not install zlib1g-dev! Please, install g++: sudo apt-get -y install zlib1g-dev"
  echo "zlib1g-dev installed!"
else
  echo "zlib1g-dev already installed!"
fi


#
# libreadline-dev
#
readline_test=`dpkg -s libreadline-dev | grep Status`

if [ "$readline_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install libreadline-dev
  valid $? "Error: could not install libreadline-dev! Please, install readline: sudo apt-get -y install libreadline-dev"
  echo "libreadline-dev installed!"
else
  echo "libreadline-dev already installed!"
fi


#
# python support
#
pysetup_test=`dpkg -s python-setuptools | grep Status`

if [ "$gcpp_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install python-setuptools
  valid $? "Error: could not install python-setuptools! Please, install readline: sudo apt-get -y install python-setuptools"
  echo "python-setuptools installed!"
else
  echo "python-setuptools already installed!"
fi

pypip_test=`dpkg -s python-pip | grep Status`

if [ "$pypip_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install python-pip
  valid $? "Error: could not install python-pip! Please, install readline: sudo apt-get -y install python-pip"
  echo "python-pip installed!"
else
  echo "python-pip already installed!"
fi

pydev_test=`dpkg -s python-dev | grep Status`

if [ "$pydev_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install python-dev
  valid $? "Error: could not install python-dev! Please, install readline: sudo apt-get -y install python-dev"
  echo "python-dev installed!"
else
  echo "python-dev already installed!"
fi

numpy_test=`dpkg -s python-numpy | grep Status`

if [ "$numpy_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install python-numpy
  valid $? "Error: could not install python-numpy! Please, install readline: sudo apt-get -y install python-numpy"
  echo "python-numpy installed!"
else
  echo "python-numpy already installed!"
fi


#
# autoconf
#
autoconf_test=`dpkg -s autoconf | grep Status`

if [ "$autoconf_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install autoconf
  valid $? "Error: could not install autoconf! Please, install readline: sudo apt-get -y install autoconf" 
  echo "autoconf installed!"
else
  echo "autoconf already installed!"
fi


#
# GNU gettext
#
gettext_test=`dpkg -s gettext | grep Status`

if [ "$gettext_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install gettext
  valid $? "Error: could not install gettext! Please, install readline: sudo apt-get -y install gettext" 
  echo "gettext installed!"
else
  echo "gettext already installed!"
fi


#
# flex
#
flex_test=`dpkg -s flex | grep Status`

if [ "$flex_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install flex
  valid $? "Error: could not install flex! Please, install readline: sudo apt-get -y install flex"
  echo "flex installed!"
else
  echo "flex already installed!"
fi


#
# bison
#
bison_test=`dpkg -s bison | grep Status`

if [ "$bison_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install bison
  valid $? "Error: could not install bison! Please, install readline: sudo apt-get -y install bison"
  echo "bison installed!"
else
  echo "bison already installed!"
fi


#
# qt5-default qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5designer5
#
qt5_dev_test=`dpkg -s qt5-default qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5designer5 | grep Status`

if [ "$qt5_dev_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install qt5-default qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5designer5
  valid $? "Error: could not install qt5-default! Please, install Qt 5 support: sudo apt-get -y install qt5-default qttools5-dev qttools5-dev-tools libqt5svg5-dev libqt5designer5"
  echo "qt5-dev-tools installed!"
else
  echo "qt5-dev-tools already installed!"
fi


#
# PHP 5
#
php5dev_test=`dpkg -s php5-dev | grep Status`

if [ "$php5dev_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install  php5-dev
  valid $? "Error: could not install php5-dev! Please, install PHP5 support: sudo apt-get -y install php5-dev"
  echo "php5-dev installed!"
else
  echo "php5-dev already installed!"
fi


#
# CMake
#
cmake_test=`dpkg -s cmake | grep Status`

if [ "$cmake_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install cmake cmake-qt-gui
  valid $? "Error: could not install CMake! Please, install CMake: sudo apt-get -y install cmake"
  echo "CMake installed!"
else
    if [ ! command -v cmake --version >/dev/null 2>&1 ]; then
      valid 1 "CMake already installed but not found in PATH!"
    else
      echo "CMake already installed!"
    fi
fi


#
# liblog4cxx10-dev
#
log4cxx_test=`dpkg -s liblog4cxx10-dev | grep Status`

if [ "$log4cxx_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install liblog4cxx10-dev
  valid $? "Error: could not install liblog4cxx10-dev! Please, install liblog4cxx10-dev: sudo apt-get -y install liblog4cxx10-dev" 
  echo "liblog4cxx10-dev installed!"
else
  echo "liblog4cxx10-dev already installed!"
fi


#
# libkml
#
libkml_test=`dpkg -s libkml-dev | grep Status`

if [ "$libkml_test" != "Status: install ok installed" ]; then
  sudo apt-get -y install libkml-dev
  valid $? "Error: could not install libkml-dev! Please, install libkml-dev: sudo apt-get -y install libkml-dev"
  echo "libkml-dev installed!"
else
  echo "libkml-dev already installed!"
fi


#
# Check for terralib-3rdparty-linux-ubuntu-14.04.tar.gz
#
if [ ! -f ./terralib-3rdparty-linux-ubuntu-14.04.tar.gz ]; then
  echo "Please, make sure to have terralib-3rdparty-linux-ubuntu-14.04.tar.gz in the current directory!"
  echo ""
  exit
fi


#
# Extract packages
#
echo "extracting packages..."
echo ""
sleep 1s

tar xzvf terralib-3rdparty-linux-ubuntu-14.04.tar.gz
valid $? "Error: could not extract 3rd party libraries (terralib-3rdparty-linux-ubuntu-14.04.tar.gz)"

echo "packages extracted!"
echo ""
sleep 1s


#
# Go to 3rd party libraries dir
#
cd terralib-3rdparty-linux-ubuntu-14.04
valid $? "Error: could not enter 3rd-party libraries dir (terralib-3rdparty-linux-ubuntu-14.04)"


#
# Check installation dir
#
if [ "$TERRALIB_DEPENDENCIES_DIR" == "" ]; then
  TERRALIB_DEPENDENCIES_DIR="/opt/terralib"
fi

export PATH="$PATH:$TERRALIB_DEPENDENCIES_DIR/bin"
export LD_LIBRARY_PATH="$PATH:$TERRALIB_DEPENDENCIES_DIR/lib"
export LDFLAGS=-Wl,-rpath=$TERRALIB_DEPENDENCIES_DIR/lib,--enable-new-dtags

echo "installing 3rd-party libraries to '$TERRALIB_DEPENDENCIES_DIR' ..."
echo ""
sleep 1s


#
# PCRE
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libpcre.a" ]; then
  echo "installing PCRE..."
  echo ""
  sleep 1s

  tar xzvf pcre-8.37.tar.gz
  valid $? "Error: could not uncompress pcre-8.37.tar.gz!"

  cd pcre-8.37
  valid $? "Error: could not enter pcre-8.37 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure PCRE!"

  make -j 4
  valid $? "Error: could not make PCRE!"

  make install
  valid $? "Error: Could not install PCRE!"

  cd ..
fi


#
# SWIG version 3.0.5
# Site: http://www.swig.org
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/bin/swig" ]; then
  echo "installing SWIG..."
  echo ""
  sleep 1s

  tar xzvf swig-3.0.5.tar.gz
  valid $? "Error: could not uncompress swig-3.0.5.tar.gz!"

  cd swig-3.0.5
  valid $? "Error: could not enter swig-3.0.5 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --with-pcre-prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure SWIG!"

  make -j 4
  valid $? "Error: could not make SWIG!"

  make install
  valid $? "Error: Could not install SWIG!"

  cd ..
fi


#
# FreeXL version 1.0.1
# Site: https://www.gaia-gis.it/fossil/freexl/index
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libfreexl.so" ]; then
  echo "installing FreeXL..."
  sleep 1s

  tar xzvf freexl-1.0.1.tar.gz
  valid $? "Error: could not uncompress freexl-1.0.1.tar.gz!"

  cd freexl-1.0.1
  valid $? "Error: could not enter freexl-1.0.1 dir!"

  CPPFLAGS=-I$TERRALIB_DEPENDENCIES_DIR/include LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure FreeXL!"

  make -j 4
  valid $? "Error: could not make FreeXL!"

  make install
  valid $? "Error: Could not install FreeXL!"

  cd ..
fi


#
# OOSP-UUID
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libuuid.so" ]; then
  echo "installing OOSP-UUID..."
  echo ""
  sleep 1s

  tar xvf uuid-1.6.2.tar
  valid $? "Error: could not uncompress uuid-1.6.2.tar!"

  cd uuid-1.6.2
  valid $? "Error: could not enter uuid-1.6.2 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --with-cxx
  valid $? "Error: could not configure OOSP-UUID!"

  make -j 4
  valid $? "Error: could not make OOSP-UUID!"

  make install
 valid $? "Error: Could not install OOSP-UUID!"

  cd ..
fi


#
# BZIP2
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libbz2.a" ]; then
  echo "installing bzip2..."
  echo ""
  sleep 1s

  tar xzvf bzip2-1.0.6-ubuntu.tar.gz
  valid $? "Error: could not uncompress bzip2-1.0.6-ubuntu.tar.gz!"

  cd bzip2-1.0.6
  valid $? "Error: could not enter bzip2-1.0.6 dir!"

  make
  valid $? "Error: could not make BZIP2!"

  make install PREFIX=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: Could not install BZIP2!"

  cd ..
fi


#
# Proj4 version 4.9.1 (with proj-datumgrid version 1.5)
# Site: https://trac.osgeo.org/proj/
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libproj.so" ]; then
  echo "installing Proj4..."
  sleep 1s

  tar xzvf proj-4.9.1.tar.gz
  valid $? "Error: could not uncompress proj-4.9.1.tar.gz!"

  cd proj-4.9.1
  valid $? "Error: could not enter proj-4.9.1 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure Proj4!"

  make -j 4
  valid $? "Error: could not make Proj4!"

  make install
  valid $? "Error: Could not install Proj4!"

  cd ..
fi


#
# GEOS
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libgeos.so" ]; then
  echo "installing GEOS..."
  echo ""
  sleep 1s

  tar xjvf geos-3.4.2.tar.bz2
  valid $? "Error: could not uncompress geos-3.4.2.tar.bz2!"

  cd geos-3.4.2
  valid $? "Error: could not enter geos-3.4.2 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure GEOS!"

  make -j 4
  valid $? "Error: could not make GEOS!"

  make install
  valid $? "Error: Could not install GEOS!"

  cd ..
fi


#
# libPNG
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libpng.so" ]; then
  echo "installing libPNG..."
  echo ""
  sleep 1s

  tar xzvf libpng-1.5.17.tar.gz
  valid $? "Error: could not uncompress libpng-1.5.17.tar.gz!"

  cd libpng-1.5.17
  valid $? "Error: could not enter libpng-1.5.17 dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure libPNG!"

  make -j 4
  valid $? "Error: could not make libPNG!"

  make install
 valid $? "Error: Could not install libPNG!"

  cd ..
fi


#
# Independent JPEG Group version v9a
# Site: http://www.ijg.org
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libjpeg.so" ]; then
  echo "installing Independent JPEG Group Library..."
  sleep 1s

  tar xzvf jpegsrc.v9a.tar.gz
  valid $? "Error: could not uncompress jpegsrc.v9a.tar.gz!"

  cd jpeg-9a
  valid $? "Error: could not enter jpeg-9a dir!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure JPEG!"

  make -j 4
  valid $? "Error: could not make JPEG!"

  make install
  valid $? "Error: Could not install JPEG!"

  cd ..
fi


#
# TIFF
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libtiff.so" ]; then
  echo "installing TIFF..."
  echo ""
  sleep 1s

  tar xzvf tiff-4.0.3.tar.gz
  valid $? "Error: could not uncompress tiff-4.0.3.tar.gz!"

  cd tiff-4.0.3
  valid $? "Error: could not enter tiff-4.0.3!"

  ./configure --enable-cxx --with-jpeg-include-dir=$TERRALIB_DEPENDENCIES_DIR/include --with-jpeg-lib-dir=$TERRALIB_DEPENDENCIES_DIR/lib --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure TIFF!"

  make -j 4
  valid $? "Error: could not make TIFF!"

  make install
  valid $? "Error: Could not install TIFF!"

  cd ..
fi


#
# GeoTIFF
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libgeotiff.so" ]; then
  echo "installing GeoTIFF..."
  echo ""
  sleep 1s

  tar xzvf libgeotiff-1.4.0.tar.gz
  valid $? "Error: could not uncompress libgeotiff-1.4.0.tar.gz!"

  cd libgeotiff-1.4.0
  valid $? "Error: could not enter libgeotiff-1.4.0!"

  ./configure --with-jpeg=$TERRALIB_DEPENDENCIES_DIR --with-zlib --with-libtiff=$TERRALIB_DEPENDENCIES_DIR --with-proj=$TERRALIB_DEPENDENCIES_DIR --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure GeoTIFF!"

  make -j 4
  valid $? "Error: could not make GeoTIFF!"

  make install
  valid $? "Error: Could not install GeoTIFF!"

  cd ..
fi


#
# SZIP
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libsz.so" ]; then
  echo "installing SZIP..."
  echo ""
  sleep 1s

  tar xzvf szip-2.1.tar.gz
  valid $? "Error: could not uncompress szip-2.1.tar.gz!"

  cd szip-2.1
  valid $? "Error: could not enter szip-2.1!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure SZIP!"

  make -j 4
  valid $? "Error: could not make SZIP!"

  make install
  valid $? "Error: Could not install SZIP!"

  cd ..
fi


#
# CURL version 7.42.1
# Site: http://curl.haxx.se/libcurl/
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libcurl.so" ]; then
  echo "installing CURL..."
  sleep 1s

  tar xzvf curl-7.42.1.tar.gz
  valid $? "Error: could not uncompress curl-7.42.1.tar.gz!"

  cd curl-7.42.1
  valid $? "Error: could not enter curl-7.42.1!"

  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure CURL!"

  make -j 4
  valid $? "Error: could not make CURL!"

  make install
  valid $? "Error: Could not install CURL!"

  cd ..
fi


#
# ICU
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libicuuc.so" ]; then
  echo "installing ICU..."
  echo ""
  sleep 1s

  tar xzvf icu4c-52_1-src.tgz
  valid $? "Error: could not uncompress icu4c-52_1-src.tgz!"

  cd icu/source
  valid $? "Error: could not enter icu/source!"

  chmod +x runConfigureICU configure install-sh
  valid $? "Error: could not set runConfigureICU to execute mode!"

  CPPFLAGS="-DU_USING_ICU_NAMESPACE=0 -DU_CHARSET_IS_UTF8=1 -DU_NO_DEFAULT_INCLUDE_UTF_HEADERS=1" ./runConfigureICU Linux/gcc --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not runConfigureICU!"

  make -j 4
  valid $? "Error: could not make ICU!"

  #make check
  #valid $? "Error: could not check ICU build!"

  make install
  valid $? "Error: Could not install ICU!"

  cd ../..
fi


#
# Xerces-c
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libxerces-c.so" ]; then
  echo "installing Xerces..."
  echo ""
  sleep 1s

  tar xzvf xerces-c-3.1.1.tar.gz
  valid $? "Error: could not uncompress icu4c-52_1-src.tgz!"

  cd xerces-c-3.1.1
  valid $? "Error: could not enter icu/source!"

  CPPFLAGS=-I$TERRALIB_DEPENDENCIES_DIR/include LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --enable-netaccessor-curl --disable-static --enable-msgloader-icu --with-icu=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure Xerces-c!"

  make -j 4
  valid $? "Error: could not make Xerces-c!"

  make install
  valid $? "Error: Could not install Xerces-c!"

  cd ..
fi


#
# libxml2
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libxml2.so" ]; then
  echo "installing libxml2..."
  echo ""
  sleep 1s

  tar xzvf libxml2-2.9.1.tar.gz
  valid $? "Error: could not uncompress libxml2-2.9.1.tar.gz!"

  cd libxml2-2.9.1
  valid $? "Error: could not enter libxml2-2.9.1!"

  CPPFLAGS=-I$TERRALIB_DEPENDENCIES_DIR/include LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --with-icu --without-python
  valid $? "Error: could not configure libxml2!"

  make -j 4
  valid $? "Error: could not make libxml2"

  make install
  valid $? "Error: Could not install libxml2"

  cd ..
fi


#
# libxslt
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libxslt.so" ]; then
  echo "installing libxslt..."
  echo ""
  sleep 1s

  tar xzvf libxslt-1.1.28.tar.gz
  valid $? "Error: could not uncompress libxslt-1.1.28.tar.gz!"

  cd libxslt-1.1.28
  valid $? "Error: could not enter libxslt-1.1.28!"

  CPPFLAGS=-I$TERRALIB_DEPENDENCIES_DIR/include LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --with-libxml-prefix=$TERRALIB_DEPENDENCIES_DIR --without-debug
  valid $? "Error: could not configure libxslt!"

  make -j 4
  valid $? "Error: could not make libxslt"

  make install
  valid $? "Error: Could not install libxslt"

  cd ..
fi


#
# Boost
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libboost_thread.so" ]; then
  echo "installing boost..."
  echo ""
  sleep 1s

  tar xzvf boost_1_60_0.tar.gz
  valid $? "Error: could not uncompress boost_1_60_0.tar.gz!"

  cd boost_1_60_0
  valid $? "Error: could not enter boost_1_60_0!"

  ./bootstrap.sh
  valid $? "Error: could not configure Boost!"

  ./b2 runtime-link=shared link=shared variant=release threading=multi --prefix=$TERRALIB_DEPENDENCIES_DIR -sICU_PATH=$TERRALIB_DEPENDENCIES_DIR -sICONV_PATH=/usr -sBZIP2_INCLUDE=$TERRALIB_DEPENDENCIES_DIR/include -sBZIP2_LIBPATH=$TERRALIB_DEPENDENCIES_DIR/lib install
  valid $? "Error: could not make boost"

  cd ..
fi


#
# PostgreSQL
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/pgsql/lib/libpq.so" ]; then
  echo "installing PostgreSQL..."
  echo ""
  sleep 1s

  tar xjvf postgresql-9.4.1.tar.bz2
  valid $? "Error: could not uncompress postgresql-9.4.1.tar.bz2!"

  cd postgresql-9.4.1
  valid $? "Error: could not enter postgresql-9.4.1!"

  CPPFLAGS="-I$TERRALIB_DEPENDENCIES_DIR/include -I$TERRALIB_DEPENDENCIES_DIR/include/libxml2" LDFLAGS="-lstdc++ -L$TERRALIB_DEPENDENCIES_DIR/lib" ./configure --with-libxml2 --with-libxslt --with-ossp-uuid --with-openssl --prefix=$TERRALIB_DEPENDENCIES_DIR/pgsql --with-includes=$TERRALIB_DEPENDENCIES_DIR/include --with-libraries=$TERRALIB_DEPENDENCIES_DIR/lib
  valid $? "Error: could not configure postgresql!"

  make -j 4
  valid $? "Error: could not make postgresql"

  make install
  valid $? "Error: Could not install postgresql"

  cd contrib/uuid-ossp
  valid $? "Error: could not enter postgresql-9.4.1/contrib/uuid-ossp!"

  make
  valid $? "Error: could not make postgresql-9.4.1/contrib/uuid-ossp"

  make install
  valid $? "Error: Could not install postgresql-9.4.1/contrib/uuid-ossp"

  cd ../../..
fi


#
# HDF4
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libmfhdf.a" ]; then
  echo "installing HDF4..."
  echo ""
  sleep 1s

  tar xzvf hdf-4.2.9.tar.gz
  valid $? "Error: could not uncompress hdf-4.2.9.tar.gz!"

  cd hdf-4.2.9
  valid $? "Error: could not enter hdf-4.2.9!"

  CFLAGS=-fPIC ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --with-szlib=$TERRALIB_DEPENDENCIES_DIR --with-zlib --with-jpeg=$TERRALIB_DEPENDENCIES_DIR --enable-netcdf --disable-fortran
  valid $? "Error: could not configure hdf-4!"

  make -j 4
  valid $? "Error: could not make hdf-4"

  make install
  valid $? "Error: Could not install hdf-4"

  cd ..
fi


#
# SQLite version 3.8.10.1
# Site: https://www.sqlite.org
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libsqlite3.so" ]; then
  echo "installing SQLite..."
  sleep 1s

  tar xzvf sqlite-autoconf-3081001.tar.gz
  valid $? "Error: could not uncompress sqlite-autoconf-3081001.tar.gz!"

  cd sqlite-autoconf-3081001
  valid $? "Error: could not enter sqlite-autoconf-3081001!"

  CFLAGS="-Os -DSQLITE_ENABLE_COLUMN_METADATA -DSQLITE_ENABLE_FTS4 -DSQLITE_ENABLE_RTREE -DSQLITE_SOUNDEX -DSQLITE_OMIT_AUTOINIT" ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure sqlite!"

  make -j 4
  valid $? "Error: could not make sqlite"

  make install
  valid $? "Error: Could not install sqlite"

  cd ..
fi


#
# SpatiaLite version 4.2.0
# Site: https://www.gaia-gis.it/fossil/libspatialite
# Obs.: In the future we should turn on libxml2 support.
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libspatialite.so" ]; then
  echo "installing SpatiaLite..."
  sleep 1s

  tar xzvf libspatialite-4.2.0.tar.gz
  valid $? "Error: could not uncompress libspatialite-4.2.0.tar.gz!"

  cd libspatialite-4.2.0
  valid $? "Error: could not enter libspatialite-4.2.0!"

  CPPFLAGS="-I$TERRALIB_DEPENDENCIES_DIR -I$TERRALIB_DEPENDENCIES_DIR/include -I$TERRALIB_DEPENDENCIES_DIR/include/libxml2 -I$TERRALIB_DEPENDENCIES_DIR/include/libxml2/libxml" LDFLAGS="-L$TERRALIB_DEPENDENCIES_DIR/lib"  ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR --enable-proj --enable-geos --enable-geosadvanced --enable-iconv --enable-freexl --enable-geocallbacks --enable-epsg --enable-gcov --enable-mathsql --enable-libxml2=no --enable-geopackage --with-geosconfig=$TERRALIB_DEPENDENCIES_DIR/bin/geos-config
  valid $? "Error: could not configure libspatialite!"

  make -j 4
  valid $? "Error: could not make libspatialite"

  make install
  valid $? "Error: Could not install libspatialite"

  cd ..
fi


#
# GDAL/OGR 1.11.2
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/gdal1/lib/libgdal.so" ]; then
  echo "installing GDAL/OGR..."
  echo ""
  sleep 1s

  tar xzvf gdal-1.11.2.tar.gz
  valid $? "Error: could not uncompress gdal-1.11.2.tar.gz!"

  cd gdal-1.11.2
  valid $? "Error: could not enter gdal-1.11.2!"

  CPPFLAGS="-I$TERRALIB_DEPENDENCIES_DIR/include -I$TERRALIB_DEPENDENCIES_DIR/include/libxml2" LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --with-pg=$TERRALIB_DEPENDENCIES_DIR/pgsql/bin/pg_config --with-png=$TERRALIB_DEPENDENCIES_DIR --with-libtiff=$TERRALIB_DEPENDENCIES_DIR --with-geotiff=$TERRALIB_DEPENDENCIES_DIR --with-jpeg=$TERRALIB_DEPENDENCIES_DIR  --with-gif --with-ecw=yes --with-xerces=$TERRALIB_DEPENDENCIES_DIR --with-expat=yes --with-curl=$TERRALIB_DEPENDENCIES_DIR/bin/curl-config --with-sqlite3=$TERRALIB_DEPENDENCIES_DIR --with-geos=$TERRALIB_DEPENDENCIES_DIR/bin/geos-config --with-threads --with-spatialite=$TERRALIB_DEPENDENCIES_DIR --with-freexl=$TERRALIB_DEPENDENCIES_DIR --without-python --prefix=$TERRALIB_DEPENDENCIES_DIR/gdal1 --with-xml2=$TERRALIB_DEPENDENCIES_DIR/bin/xml2-config --with-libkml --with-hdf4=$TERRALIB_DEPENDENCIES_DIR --without-netcdf 
  valid $? "Error: could not configure gdal!"

  make -j 4 -s
  valid $? "Error: could not make gdal"

  make install
  valid $? "Error: Could not install gdal"

  cd ..
fi

#
# GDAL/OGR 2.0.1
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/gdal2/lib/libgdal.so" ]; then
  echo "installing GDAL/OGR..."
  echo ""
  sleep 1s

  tar xzvf gdal-2.0.1.tar.gz
  valid $? "Error: could not uncompress gdal-2.0.1.tar.gz!"

  cd gdal-2.0.1
  valid $? "Error: could not enter gdal-2.0.1!"

  CPPFLAGS="-I$TERRALIB_DEPENDENCIES_DIR/include -I$TERRALIB_DEPENDENCIES_DIR/include/libxml2" LDFLAGS=-L$TERRALIB_DEPENDENCIES_DIR/lib ./configure --with-pg=$TERRALIB_DEPENDENCIES_DIR/pgsql/bin/pg_config --with-png=$TERRALIB_DEPENDENCIES_DIR --with-libtiff=$TERRALIB_DEPENDENCIES_DIR --with-geotiff=$TERRALIB_DEPENDENCIES_DIR --with-jpeg=$TERRALIB_DEPENDENCIES_DIR  --with-gif --with-ecw=yes --with-xerces=$TERRALIB_DEPENDENCIES_DIR --with-expat=yes --with-curl=$TERRALIB_DEPENDENCIES_DIR/bin/curl-config --with-sqlite3=$TERRALIB_DEPENDENCIES_DIR --with-geos=$TERRALIB_DEPENDENCIES_DIR/bin/geos-config --with-threads --with-spatialite=$TERRALIB_DEPENDENCIES_DIR --with-freexl=$TERRALIB_DEPENDENCIES_DIR --without-python --prefix=$TERRALIB_DEPENDENCIES_DIR/gdal2 --with-xml2=$TERRALIB_DEPENDENCIES_DIR/bin/xml2-config --with-libkml --with-hdf4=$TERRALIB_DEPENDENCIES_DIR --without-netcdf
  valid $? "Error: could not configure gdal!"

  make -j 4 -s
  valid $? "Error: could not make gdal"

  make install
  valid $? "Error: Could not install gdal"

  cd ..
fi


#
# CppUnit
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libcppunit.so" ]; then
  echo "installing CppUnit.."
  echo ""
  sleep 1s

  tar xzvf cppunit-1.12.1.tar.gz
  valid $? "Error: could not uncompress cppunit-1.12.1.tar.gz!"

  cd cppunit-1.12.1
  valid $? "Error: could not enter cppunit-1.12.1!"

  LDFLAGS="-ldl" ./configure --prefix=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not configure cppunit!"

  make -j 4
  valid $? "Error: could not make cppunit"

  make install
  valid $? "Error: Could not install cppunit"

  cd ..
fi


#
# Qt Property Browser
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libqt_property_browser.so" ]; then
  echo "installing Qt Property Browser..."
  echo ""
  sleep 1s

  tar xzvf qtpropertybrowser.tar.gz
  valid $? "Error: could not uncompress qtpropertybrowser.tar.gz!"

  cd qtpropertybrowser
  valid $? "Error: could not change dir to qtpropertybrowser!"

  qmake "TERRALIB_DIR=$TERRALIB_DEPENDENCIES_DIR"
  valid $? "Error: could not run qmake for qt-property-browser!"

  make -j 4
  valid $? "Error: could not make qt-property-browser!"

  make install
  valid $? "Error: Could not install qt-property-browser!"

  cd ..
fi


#
# QScintilla
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libqscintilla2.so" ]; then
  echo "installing QScintilla..."
  echo ""
  sleep 1s

  tar xzvf QScintilla-gpl-2.8.tar.gz
  valid $? "Error: could not uncompress QScintilla-gpl-2.8.tar.gz!"

  cd QScintilla-gpl-2.8/Qt4Qt5
  valid $? "Error: could not change dir to QScintilla-gpl-2.8/Qt4Qt5!"

  qmake "TERRALIB_DIR=$TERRALIB_DEPENDENCIES_DIR"
  valid $? "Error: could not prepare QScintilla build with qmake!"

  make -j 4
  valid $? "Error: could not make QScintilla!"

  make install
  valid $? "Error: Could not install QScintilla!"

  cd ../..
fi


#
# Lua
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/liblua.so" ]; then
  echo "installing Lua..."
  echo ""
  sleep 1s

  tar xzvf lua-5.3.3.tar.gz
  valid $? "Error: could not uncompress lua-5.3.3.tar.gz!"

  cd lua-5.3.3
  valid $? "Error: could not change dir to lua-5.3.3!"

 # echo 'MYCFLAGS= -DLUA_USE_LINUX -DLUA_USE_DLOPEN'
 # echo 'CFLAGS+= -DLUA_COMPAT_5_2 $(SYSCFLAGS) $(MYCFLAGS) -fPIC' >> src/Makefile    
 # echo 'LUA_SO=liblua.so' >> src/Makefile
 # echo 'ALL_T= $(LUA_A) $(LUA_T) $(LUAC_T) $(LUA_SO)' >> src/Makefile
 # echo '$(LUA_SO): $(CORE_O) $(LIB_O)' >> src/Makefile
 # echo -e '\t$(CC) -shared -ldl -Wl,-soname,$(LUA_SO) -o $@ $? -lm $(LDFLAGS)' >> src/Makefile

  make INSTALL_TOP=$TERRALIB_DEPENDENCIES_DIR
  valid $? "Error: could not make dynamic Lua!"

  make linux install INSTALL_TOP=$TERRALIB_DEPENDENCIES_DIR TO_LIB='liblua.so'
  valid $? "Error: could not install Lua!"

  cd ..
fi
 
 
#
# QtLua
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libqtlua.so" ]; then
  echo "installing QtLua..."
  echo ""
  sleep 1s
 
  tar xzvf libqtlua-2.0.tar.gz
  valid $? "Error: could not uncompress libqtlua-2.0.tar.gz!"

  cd libqtlua-2.0
  valid $? "Error: could not change dir to libqtlua-2.0!"

  mkdir cmake-build
  cd cmake-build

  cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="Release" -DCMAKE_INSTALL_PREFIX=${TERRALIB_DEPENDENCIES_DIR} -DCMAKE_PREFIX_PATH=${TERRALIB_DEPENDENCIES_DIR}/lib -DLUA_INCLUDE_DIR=${TERRALIB_DEPENDENCIES_DIR}/include ..
  valid $? "Error: could not configure QtLua!"

  make -j 4
  valid $? "Error: could not make QtLua!"

  make install
  valid $? "Error: could not install QtLua!"

  cd ..

  cp -r src/internal $TERRALIB_DEPENDENCIES_DIR/include/QtLua/
  valid $? "Error: could not copy QtLua internal folder!"

  cd ..
fi


#
# Qwt version 
# Site: http://qwt.sourceforge.net
#
if [ ! -f "$TERRALIB_DEPENDENCIES_DIR/lib/libqwt.so" ]; then
  echo "installing Qwt..."
  sleep 1s

  tar xjvf qwt-6.1.2.tar.bz2
  valid $? "Error: could not uncompress qwt-6.1.2.tar.bz2!"

  cd qwt-6.1.2
  valid $? "Error: could not change dir to qwt-6.1.2!"

  qmake qwt.pro "QWT_INSTALL_PREFIX_TARGET=$TERRALIB_DEPENDENCIES_DIR"
  valid $? "Error: could not configure Qwt!"

  make -j 4
  valid $? "Error: could not make Qwt!"

  make install
  valid $? "Error: could not copy Qwt internal folder!"

  cd ..
fi


#
# Finished!
#
clear
echo "*****************************************************************"
echo "* TerraLib 3rd-party Libraries Installer for Linux Ubuntu 14.04 *"
echo "*****************************************************************"
echo ""
echo "finished successfully!"

