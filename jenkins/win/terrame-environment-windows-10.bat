
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


:::::::::::::::::::::::::::::::::::::::::: TerraME Environment
:: Cleaning last directories
rmdir %_TERRAME_BUILD_BASE%\solution /s /q
rmdir %_TERRAME_REPOSITORY_DIR% /s /q
rmdir %_TERRAME_TEST_DIR% /s /q
rmdir %_TERRAME_EXECUTION_DIR% /s /q


:: Creating TerraME Test directories
mkdir %_TERRAME_BUILD_BASE%\solution %_TERRAME_REPOSITORY_DIR% %_TERRAME_TEST_DIR% %_TERRAME_EXECUTION_DIR%

:: Copying TerraME compilation scripts to TerraME Solution directory
xcopy %_TERRAME_GIT_DIR%\build\scripts\win\terrame-conf.* %_TERRAME_BUILD_BASE%\solution /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-build-windows-10.bat %_TERRAME_BUILD_BASE%\solution /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-installer-windows-10.bat %_TERRAME_BUILD_BASE%\solution /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-repository-test-windows-10.bat %_TERRAME_REPOSITORY_DIR% /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-test-execution-windows-10.bat %_TERRAME_EXECUTION_DIR% /i /h /e /y

:: Copying TerraME test and config file to Test folder
xcopy %_TERRAME_GIT_DIR%\jenkins\all\*.lua %_TERRAME_TEST_DIR% /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-unittest-windows-10.bat %_TERRAME_TEST_DIR% /i /h /e /y

xcopy %_TERRAME_GIT_DIR%\jenkins\win\terrame-doc-windows-10.bat %_TERRAME_TEST_DIR% /i /h /e /y

:: Copying TerraME Git Repository to Test Repository Folder
xcopy %_TERRAME_GIT_DIR%\repository\* %_TERRAME_REPOSITORY_DIR% /i /h /e /y

:: Copying TerraME Git Test Execution to Test Execution Folder
xcopy %_TERRAME_GIT_DIR%\test\* %_TERRAME_EXECUTION_DIR% /i /h /e /y

cmake -version