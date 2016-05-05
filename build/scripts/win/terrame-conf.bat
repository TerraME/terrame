:: TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
:: Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org
::
:: This code is part of the TerraME framework.
:: This framework is free software; you can redistribute it and/or
:: modify it under the terms of the GNU Lesser General Public
:: License as published by the Free Software Foundation; either
:: version 2.1 of the License, or (at your option) any later version.
::
:: You should have received a copy of the GNU Lesser General Public
:: License along with this library.
::
:: The authors reassure the license terms regarding the warranties.
:: They specifically disclaim any warranties, including, but not limited to,
:: the implied warranties of merchantability and fitness for a particular purpose.
:: The framework provided hereunder is on an "as is" basis, and the authors have no
:: obligation to provide maintenance, support, updates, enhancements, or modifications.
:: In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
:: indirect, special, incidental, or consequential damages arising out of the use
:: of this software and its documentation.

cd D:\terrame\build-cmake

:: -----------------
:: Setting up the environment variables: change the values of the above
:: variables to reflect you environment.
:: -----------------
:: Location of the builded 3rd-parties.
set _TERRALIB_3RDPARTY_DIR=D:\terralib\3rdparty\terralib5-3rdparty-msvc-2013-win64
set _TERRAME_DEPENDS_DIR=D:\terrame\dependencies\install
set _TERRALIB_MODULES_DIR=D:\terralib\build-cmake\install
set _Qt5_DIR=C:\Qt\5.5\msvc2013_64
set _MSYS_DIR=C:\MinGW\msys\1.0\bin

:: Location to install TerraLib
set _TERRAME_INSTALL_PATH=%CD%\install

:: Build location (where is tha Makefile)
set _TERRAME_OUT_DIR=%CD%\build

:: -----------------
:: Configuring output folder
:: -----------------
mkdir %_TERRAME_OUT_DIR%
:: copy terralib.conf.cmake %TE_OUT_DIR%

:: -----------------
:: Entering the output folder
:: -----------------
cd %_TERRAME_OUT_DIR%

:: -----------------
:: Calling CMake
:: -----------------
cmake -G "Visual Studio 12 2013 Win64" -C ./../terrame-conf.cmake ./../../git/terrame/build/cmake


echo "TerraME VS2013 builded!"
pause