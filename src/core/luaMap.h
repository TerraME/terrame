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

/*! \file luaMap.h
\brief This file definitions for the luaMap objects.
\author Pedro R. Andrade

*/
#ifndef LUAMAP_H
#define LUAMAP_H

#include "observerMap.h"
#include "reference.h"
#include "luna.h"

/**
* \brief
*  Implementation for a luaMap object.
*
*/
class luaMap : public Reference<luaMap>
{
	lua_State *luaL;

public:
	///< Data structure issued by Luna<T>
	static const char className[];

	///< Data structure issued by Luna<T>
	static Luna<luaMap>::RegType methods[];

	/// constructor
	luaMap(lua_State* L);

	int setObserver(lua_State* L);

	/// destructor
	~luaMap(void);

	int save(lua_State* L);

    int setGridVisible(lua_State *L);

	int setTitle(lua_State *L);

public:
	ObserverMap* obs;
};

#endif

