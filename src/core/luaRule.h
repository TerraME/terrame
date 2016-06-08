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

/*! \file luaRule.h
    \brief This file definitions for the luaRule objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUARULE_H
#define LUARULE_H

/**
* \brief  
*  Implementation for a luaRule object.
*
*/
class luaRule
{
protected:
    int ref; ///< The position of the object in the Lua stack

public:

    /// Destructor
    ~luaRule(void)
    {
        luaL_unref(L, LUA_REGISTRYINDEX, ref);
    }

    /// Registers the luaRule object in the Lua stack
    int setReference(lua_State* L)
    {
        ref = luaL_ref(L, LUA_REGISTRYINDEX);
        return 0;
    }

    /// Gets the luaRule object position in the Lua stack
    int getReference(lua_State *L)
    {
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        return 1;
    }

};


#endif
