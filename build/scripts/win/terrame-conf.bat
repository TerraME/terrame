:: TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
:: Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org
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
::

if "%_TERRALIB_3RDPARTY_DIR%" == "" (
  set _TERRALIB_3RDPARTY_DIR=D:\terralib\3rdparty\libs
)

if "%_TERRAME_DEPENDS_DIR%" == "" (
  set _TERRAME_DEPENDS_DIR=D:\terrame\3rdparty\install
)

if "%_TERRALIB_MODULES_DIR%" == "" (
  set _TERRALIB_MODULES_DIR=D:\terralib\solution\install
)

if "%_Qt5_DIR%" == "" (
  set _Qt5_DIR=C:\Qt\5.10.1\msvc2017_64
)

if "%_MSYS_DIR%" == "" (
  set _MSYS_DIR=C:\msys64\usr\bin
)

if "%_TERRAME_INSTALL_PATH%" == "" (
  set _TERRAME_INSTALL_PATH=%CD%\install
)

if "%_TERRAME_OUT_DIR%" == "" (
  set _TERRAME_OUT_DIR=%CD%\build
)

if "%_TERRAME_GIT_DIR%" == "" (
  set _TERRAME_GIT_DIR=../../git/terrame
)

if "%_TERRAME_BUILD_AS_BUNDLE%" == "" (
  set _TERRAME_BUILD_AS_BUNDLE=ON
)

if "%_TERRAME_CREATE_INSTALLER%" == "" (
  set _TERRAME_CREATE_INSTALLER=OFF
)

if "%_TERRAME_BUILD_TYPE%" == "" (
  set _TERRAME_BUILD_TYPE=Release
)

if "%_TERRAME_VLD_DIR%" == "" (
  set "_TERRAME_VLD_DIR=C:/Program Files (x86)/Visual Leak Detector"
)

if "%_TERRAME_CPACK_GENERATOR%" == "" (
  set _TERRAME_CPACK_GENERATOR="NSIS"
)

mkdir %_TERRAME_OUT_DIR%
cd %_TERRAME_OUT_DIR%

cmake -G "Visual Studio 15 2017 Win64" -C %_TERRAME_GIT_DIR%/build/cmake/terrame-build-conf.cmake %_TERRAME_GIT_DIR%/build/cmake
cmake --build . --target INSTALL --config %_TERRAME_BUILD_TYPE%
