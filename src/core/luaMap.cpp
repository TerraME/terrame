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

#include "luaMap.h"
#include "observerMap.h"
#include "luna.h"
#include "terrameGlobals.h"

luaMap::luaMap(lua_State* L)
{
	luaL = L;
}

int luaMap::setObserver(lua_State* L)
{
	ObserverMap * obsg = (ObserverMap*) lua_touserdata(L, -1);
	obs = obsg;
	return 0;
}

luaMap::~luaMap(void)
{
}

int luaMap::save(lua_State* L)
{
	std::string e = luaL_checkstring(L, -1);
	std::string f = luaL_checkstring(L, -2);

	obs->save(f, e);

	return 0;
}

int luaMap::setGridVisible(lua_State *L)
{
#if LUA_VERSION_NUM < 503
    int v = luaL_checkint(L, -1);
#else
    int v = luaL_checkinteger(L, -1);
#endif
    obs->setGridVisible(v);

	return 0;
}

