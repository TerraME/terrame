/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright © 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.
*************************************************************************************/
/*!
  \file terrameLua.h
  \brief This file contains definitions about the TerraME API for Lua programmers.
   It contains definitions about the Lua Integration TerraME software layer
  \author Tiago Garcia de Senna Carneiro
*/

#if ! defined( TERRAME_LUA )

#define TERRAME_LUA
#if defined( TME_LUA_5_0 )
#include "terrameLua5_0.h"
#else 
#include "terrameLua5_1.h"
#endif

#endif
