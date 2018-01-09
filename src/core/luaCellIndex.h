/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

/*! \file luaCellIndex.h
    \brief This file definitions for the luaCellIndex objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUACELLINDEX_H
#define LUACELLINDEX_H

extern "C"
{
#include <lua.h>
}
#include "luna.h"

#include "reference.h"

/**
* \brief
*  Implementation for a luaCellIndex object.
*
*/
class luaCellIndex : Reference<luaCellIndex>
{
    // @DANIEL:
    // Movido para a classe Reference
    //int ref; ///< The position of the object in the Lua stack

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<luaCellIndex>::RegType methods[];

public:
    int x, y; /// The luaCell coordenates(2D)

    /// Constructor
    luaCellIndex(lua_State *L)
    {
        x = y = 0;
        if (lua_istable(L, -1))
        {
            lua_pushstring(L, "x"); lua_gettable(L, -2);
            x =(int) luaL_checknumber(L, -1); lua_pop(L, 1);

            lua_pushstring(L, "y"); lua_gettable(L, -2);
            y =(int) luaL_checknumber(L, -1); lua_pop(L, 1);
        }
    }

    /// Stes the luaCellIndex value
    int set(lua_State *L)
    {
        x =(int)luaL_checknumber(L, -2);
        y =(int) luaL_checknumber(L, -1);
        return 0;
        }

    /// Gets the luaCellIndex value
    int get(lua_State *L)
    {
        lua_pushnumber(L, x);
        lua_pushnumber(L, y);
        return 2;
    }

    // @DANIEL:
    // Movido para a classe Reference
    /// Sets the luaCellIndex object reference. This registers the Lua object position in the Lua stack.
//    int setReference(lua_State* L)
//    {
//        ref = luaL_ref(L, LUA_REGISTRYINDEX);
//        return 0;
//    }

    // @DANIEL:
    // Movido para a classe Reference
    /// Gets the luaCellIndex object reference.
//    int getReference(lua_State *L)
//    {
//        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//        return 1;
//    }
};

#endif
