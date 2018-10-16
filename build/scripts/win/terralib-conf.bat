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

:: -----------------
:: Script for building a TerraLib5 customized for TerraME
:: -----------------

:: -----------------
:: Setting up the environment variables: change the values of the above
:: variables to reflect you environment.
:: -----------------
:: Location of the built 3rd-parties.
:: Checking terralib 3rdparty dir
if "%_TERRALIB_3RDPARTY_DIR%" == "" (
  set _TERRALIB_3RDPARTY_DIR=D:\terralib\3rdparty\libs
)

:: Location to install TerraLib
if "%_TERRALIB_INSTALL_PATH%" == "" (
  set _TERRALIB_INSTALL_PATH=%CD%\install
)

:: Build location (where is tha Makefile)
if "%_TERRALIB_OUT_DIR%" == "" (
  set _TERRALIB_OUT_DIR=%CD%\build
)

:: Checking Terralib git dir. Path to terralib codebase
if "%_TERRALIB_GIT_DIR%" == "" (
  set _TERRALIB_GIT_DIR=../../git/terralib
)

:: -----------------
:: Configuring output folder
:: -----------------
mkdir %_TERRALIB_OUT_DIR%

:: Copying terralib cmake cache to output dir
copy terralib-conf.cmake %_TERRALIB_OUT_DIR%

:: -----------------
:: Entering the output folder
:: -----------------
cd %_TERRALIB_OUT_DIR%

:: -----------------
:: Calling CMake
:: -----------------
cmake -G "Visual Studio 15 2017 Win64" -C terralib-conf.cmake %_TERRALIB_GIT_DIR%/build/cmake

:: Building and installing
cmake --build . --target INSTALL --config Release
