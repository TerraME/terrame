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

::
:: It performs TerraME compilation. It does not create installer or even build as bundle.'
::
::
:: USAGE:
:: terrame-build-windows-10.bat
::

:: Turn off system messages

::@echo off

::set "_CURL_DIR=C:\curl"
::set "PATH=%PATH%;%_CURL_DIR%"

:: echo ""
:: echo "TerraME Dependencies compilation on Windows 10"
:: echo ""

:: set "_TERRALIB_3RDPARTY_NAME=terralib5-3rdparty-msvc12.zip"
:: set "_TERRALIB_TARGET_URL=http://www.dpi.inpe.br/terralib5-devel/3rdparty/src/$_TERRALIB_3RDPARTY_NAME"
:: set "_TERRAME_3RDPARTY_DIR=C:\MyDevel\terrame\daily-build\terrame\3rdparty"
:: set "_BUILD_PATH=C:\tme-3rdparty"
:: TerraLib 3rdparty variables
:: set "TERRALIB_X64=1"
:: set "_config=x64"
:: set "QMAKE_FILEPATH=C:\Qt\5.6\msvc2013_64\bin"
:: set "TERRALIB_DEPENDENCIES_DIR=C:\MyDevel\terrame\daily-build\terralib\3rdparty\5.2"
:: set "TERRALIB5_CODEBASE_PATH=%CD%\terralib"
:: set "VCVARS_FILEPATH=%PROGRAMFILES(x86)%\Microsoft Visual Studio 12.0\VC"

:: Configuring VStudio
:: echo | set /p="Configuring visual studio... "<nul

:: call "%VCVARS_FILEPATH%"\vcvarsall.bat %_config%

:: echo done.

:: echo | set /p="Cleaning up old builds ... "<nul
echo Cleaning up old builds ...
rmdir %_TERRALIB_TARGET_3RDPARTY_DIR% /s /q
rmdir %_TERRAME_TARGET_3RDPARTY_DIR% /s /q

mkdir %_TERRALIB_TARGET_3RDPARTY_DIR% %_TERRAME_TARGET_3RDPARTY_DIR%

cd %_TERRALIB_TARGET_3RDPARTY_DIR%
::rmdir %_BUILD_PATH% /s /q >nul 2>nul
:: rmdir %TERRALIB_DEPENDENCIES_DIR% /s /q >nul 2>nul
:: rmdir %TERRALIB5_CODEBASE_PATH% /s /q >nul 2>nul
:: rmdir %_TERRAME_3RDPARTY_DIR% /s /q >nul 2>nul
:: mkdir %TERRALIB5_CODEBASE_PATH% /s /q >nul 2>nul
:: mkdir %_TERRAME_3RDPARTY_DIR% /s /q >nul 2>nul
:: echo done.

echo Downloading GitLab TerraLib
:: echo | set /p="Downloading TerraLib ... "<nul
rmdir %_TERRALIB_GIT_DIR% /s /q
mkdir %_TERRALIB_GIT_DIR%

git clone -b %_TERRALIB_BRANCH% https://gitlab.dpi.inpe.br/rodrigo.avancini/terralib.git %_TERRALIB_GIT_DIR% --quiet

set "_CURL_DIR=C:\curl"
set "PATH=%PATH%;%_CURL_DIR%"

set "_TERRALIB_3RDPARTY_NAME=terralib-3rdparty-msvc12.zip"
set "_TERRALIB_TARGET_URL=http://www.dpi.inpe.br/terralib5-devel/3rdparty/src/%_TERRALIB_3RDPARTY_NAME%"

:: echo done.
:: Downloading TerraME
:: echo | set /p="Downloading TerraME ... "<nul
:: git clone https://github.com/TerraME/terrame.git terrame --quiet
:: echo done.

echo Downloading TerraLib 3rdparty
:: echo | set /p="Downloading TerraLib 3rdparty ... "<nul
curl -L -s -O %_TERRALIB_TARGET_URL%
:: echo done.

"C:\Program Files\7-Zip\7z.exe" x %_TERRALIB_3RDPARTY_NAME% -y

echo Cofiguring Install Variables
:: Where to install the third-parties
set "TERRALIB_DEPENDENCIES_DIR=%_TERRALIB_TARGET_3RDPARTY_DIR%\5.2"

:: Where is qmake.exe
set "QMAKE_FILEPATH=%_QMAKE_DIR%"

set "TERRALIB_X64=1"

set "VCVARS_FILEPATH=%PROGRAMFILES(x86)%\Microsoft Visual Studio 12.0\VC"

:: Where is cmake.exe
set "CMAKE_FILEPATH=%PROGRAMFILES(x86)%\CMake\bin"

:: Where is win32.mak file of the system.
set "WIN32MAK_FILEPATH=%PROGRAMFILES(x86)%\Microsoft SDKs\Windows\v7.1A\Include"

:: Where is the TerraLib5 codebase
set TERRALIB5_CODEBASE_PATH=%_TERRALIB_GIT_DIR%
dir
:: Enter directory containing codebase of the third parties.
cd terralib-3rdparty-msvc12

dir

echo Configuring Visual Studio...

call "%VCVARS_FILEPATH%\vcvarsall.bat %_config%"

echo Calling the script on TerraLib5

call %TERRALIB5_CODEBASE_PATH%\install\install-3rdparty.bat

cd %_TERRAME_TARGET_3RDPARTY_DIR%

:: copy terrame\build\scripts\win\terrame-deps-conf.bat %_TERRAME_3RDPARTY_DIR%
:: Extracting TerraLib 3rdparty and moving short-named directory. It prevents Windows directory and filename limitation (255 chars)
:: "C:\Program Files\7-Zip\7z.exe" x terralib-3rdparty-msvc12.zip -y
:: mv terralib-3rdparty-msvc12 %_BUILD_PATH%
:: cd %_BUILD_PATH%\terralib-3rdparty-msvc12

:: Compile TerraLib 3rdparty Dependencies
:: start /wait %TERRALIB5_CODEBASE_PATH%\install\install-3rdparty.bat

:: cd %_TERRAME_3RDPARTY_DIR%

:: echo Downloading Protobuf ...
::set "_PROTOBUF_VERSION=3.1.0"
:: set "_PROTOBUF_NAME=protobuf-cpp-%_PROTOBUF_VERSION%.zip"
:: curl -O -J -L https://github.com/google/protobuf/releases/download/v%_PROTOBUF_VERSION%/%_PROTOBUF_NAME% --silent
:: "C:\Program Files\7-Zip\7z.exe" x %_PROTOBUF_NAME% -y
:: rename protobuf-%_PROTOBUF_VERSION% protobuf

:: echo "Downloading Luacheck ...
:: set "_LUACHECK_VERSION=0.17.0"
:: set "_LUACHECK_NAME=%_LUACHECK_VERSION%.zip"
:: curl -L -s -O https://github.com/mpeterv/luacheck/archive/0.17.0.zip
:: "C:\Program Files\7-Zip\7z.exe" x %_LUACHECK_NAME% -y
:: rename luacheck-%_LUACHECK_VERSION% luacheck

:: copy %_TERRAME_GIT_DIR%\build\scripts\win\terrame-deps-conf.bat .
:: call terrame-deps-conf.bat

:: echo Compiling Protobuf
:: cd protobuf\vsprojects
:: msbuild /t:libprotobuf /p:Configuration=Release /p:Platform=x64 protobuf.sln
:: msbuild /m protobuf.sln /target:libprotobuf-lite /p:Configuration=Release /p:Platform=x64 /maxcpucount:4
:: msbuild /m protobuf.sln /target:libprotoc /p:Configuration=Release /p:Platform=x64 /maxcpucount:4
:: msbuild /m protobuf.sln /target:protoc /p:Configuration=Release /p:Platform=x64 /maxcpucount:4

:: echo Copying Protobuf exec
:: copy x64\Release\protoc.exe

:: echo Copying Protobuf libs
:: xcopy x64\Release\libproto* %_TERRAME_TARGET_3RDPARTY_DIR%\install\lib /i /h /e /y

:: echo Extract Protobuf includes
:: call extract_includes.bat

:: echo Copying Protobuf includes
:: xcopy include %_TERRAME_TARGET_3RDPARTY_DIR%\install\include /i /h /e /y

tree /F /A %_TERRAME_TARGET_3RDPARTY_DIR%\install

:: exit %ERRORLEVEL%
:: exit %ERRORLEVEL%