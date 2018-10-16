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

set "_ROOT_DIR=%CD%"
set "_BUILD_TYPE=Release"

mkdir "build"
cd "build"
mkdir "protobuf-build"
cd "protobuf-build"

cmake -G "Visual Studio 15 2017 Win64" -DCMAKE_BUILD_TYPE=%_BUILD_TYPE% -DCMAKE_INSTALL_PREFIX=..\..\install -Dprotobuf_BUILD_SHARED_LIBS=ON -Dprotobuf_WITH_ZLIB=OFF -Dprotobuf_BUILD_TESTS=OFF ..\..\protobuf\cmake
cmake --build . --target INSTALL --config %_BUILD_TYPE%

cd %_ROOT_DIR%

mkdir %CD%\install\luacheck\src
xcopy luacheck\src %CD%\install\luacheck\src /S /E
