/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

/*!
  \file core/terrameVersion.h

  \brief System versioning macros.
*/

#ifndef TERRAME_INTERNAL_TERRAME_VERSION_H
#define TERRAME_INTERNAL_TERRAME_VERSION_H

/*!
  \def TERRAME_VERSION_MAJOR

  \brief Major version of TerraME (or version).
 */
#define TERRAME_VERSION_MAJOR 2

/*!
  \def TERRAME_VERSION_MINOR

  \brief Minor version of TerraME (or revision). 
 */
#define TERRAME_VERSION_MINOR 0

/*!
  \def TERRAME_VERSION_PATCH

  \brief Patched version of TerraME (or patch).
 */
#define TERRAME_VERSION_PATCH 0

/*!
  \def TERRAME_VERSION_STATUS

  \brief
 */
#define TERRAME_VERSION_STATUS "beta-3.4"

/*!
  \def TERRAME_VERSION_STRING

  \brief This flag is used for versioning the TerraME code. If you have plugins and other tools
         that must check the TerraME version, you can test against this string.
 */
#define TERRAME_VERSION_STRING "2.0.0-beta-3.4"

/*!
  \def TERRAME_VERSION

  \brief This flag is used for versioning the TerraME code. If you have plugins and other tools
         that must check the TerraME version, you can test against this number.
 */
#define TERRAME_VERSION 0x020000

#endif  // TERRAME_INTERNAL_TERRAME_VERSION_H
