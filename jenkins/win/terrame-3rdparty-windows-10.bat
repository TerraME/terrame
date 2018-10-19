::
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

:: turn off|on system messages
@echo %_ECHO_ENABLED%

echo | set /p="Cleaning up old builds ... "<nul
rmdir %_TERRALIB_TARGET_3RDPARTY_DIR% /s /q
rmdir %_TERRAME_TARGET_3RDPARTY_DIR% /s /q

mkdir %_TERRALIB_TARGET_3RDPARTY_DIR% %_TERRAME_TARGET_3RDPARTY_DIR%
echo done.
echo.

cd %_TERRALIB_TARGET_3RDPARTY_DIR%

echo | set /p="Cloning TerraLib ... "<nul
rmdir %_TERRALIB_GIT_DIR% /s /q
mkdir %_TERRALIB_GIT_DIR%

git clone -b %_TERRALIB_BRANCH% https://gitlab.dpi.inpe.br/rodrigo.avancini/terralib.git %_TERRALIB_GIT_DIR% --quiet

echo done.
echo.

echo | set /p="Downloading TerraLib 3rdparty ... "<nul
set "_CURL_DIR=C:\curl"
set "PATH=%PATH%;%_CURL_DIR%"

set "_TERRALIB_3RDPARTY_NAME=terralib-3rdparty-msvc17"
set "_TERRALIB_TARGET_URL=http://www.dpi.inpe.br/terralib5-devel/3rdparty/src/%_TERRALIB_VERSION%/%_TERRALIB_3RDPARTY_NAME%.zip"

curl -L -s -O %_TERRALIB_TARGET_URL%
echo done.
echo.

"C:\Program Files\7-Zip\7z.exe" x "%_TERRALIB_3RDPARTY_NAME%.zip" -y

echo.

echo | set /p="Cofiguring Install Variables ... "<nul
:: Where to install the third-parties
set "TERRALIB_DEPENDENCIES_DIR=%_TERRALIB_TARGET_3RDPARTY_DIR%\libs"

:: Where is qmake.exe
set "QMAKE_FILEPATH=%_QMAKE_DIR%"

set "TERRALIB_X64=1"

set "VCVARS_FILEPATH=%PROGRAMFILES(x86)%\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build"

:: Where is cmake.exe
set "CMAKE_FILEPATH=%PROGRAMFILES(x86)%\CMake\bin"

:: Where is the TerraLib5 codebase
set TERRALIB5_CODEBASE_PATH=%_TERRALIB_GIT_DIR%

echo done.
echo.

dir
echo.

:: Enter directory containing codebase of the third parties.
cd %_TERRALIB_3RDPARTY_NAME%

dir
echo.

echo | set /p="Calling the script on TerraLib5 ... "<nul
call %TERRALIB5_CODEBASE_PATH%\install\install-3rdparty-msvc17.bat
echo done.
echo.

dir %TERRALIB_DEPENDENCIES_DIR%

echo | set /p="TerraME Dependencies ... "<nul
cd %_TERRAME_TARGET_3RDPARTY_DIR%
echo.

echo | set /p="Downloading Protobuf ... "<nul
set "_PROTOBUF_VERSION=3.1.0"
set "_PROTOBUF_NAME=protobuf-cpp-%_PROTOBUF_VERSION%.zip"
curl -O -J -L https://github.com/google/protobuf/releases/download/v%_PROTOBUF_VERSION%/%_PROTOBUF_NAME% --silent

echo done.
echo.

"C:\Program Files\7-Zip\7z.exe" x %_PROTOBUF_NAME% -y
rename protobuf-%_PROTOBUF_VERSION% protobuf

echo | set /p="Downloading Luacheck ... "<nul
set "_LUACHECK_VERSION=0.17.0"
set "_LUACHECK_NAME=%_LUACHECK_VERSION%.zip"
curl -L -s -O https://github.com/mpeterv/luacheck/archive/0.17.0.zip

echo done.
echo.

"C:\Program Files\7-Zip\7z.exe" x %_LUACHECK_NAME% -y
rename luacheck-%_LUACHECK_VERSION% luacheck


echo | set /p="Buinding and installing TerraME dependencies ... "<nul
copy %_TERRAME_GIT_DIR%\build\scripts\win\terrame-deps-conf.bat .

call terrame-deps-conf.bat

echo done.
echo.

dir %_TERRAME_TARGET_3RDPARTY_DIR%\install

exit %ERRORLEVEL%
