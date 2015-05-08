/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C) 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
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
