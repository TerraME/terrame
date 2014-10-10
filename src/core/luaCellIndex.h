/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright � 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaCellIndex.h
    \brief This file definitions for the luaCellIndex objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUACELLINDEX_H )
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

public:
    ///< Data structure issued by Luna<T>
    static const char className[]; 
    
    ///< Data structure issued by Luna<T>
    static Luna<luaCellIndex>::RegType methods[]; 
    
public:
    int x, y; /// The luaCell coordenates (2D)

    /// Constructor
    luaCellIndex(lua_State *L) 
    {
        x = y = 0;
        if( lua_istable(L,-1) )
        {
            lua_pushstring(L, "x"); lua_gettable(L, -2); 
            x = (int) luaL_checknumber(L, -1); lua_pop(L, 1);
            
            lua_pushstring(L, "y"); lua_gettable(L, -2); 
            y = (int) luaL_checknumber(L, -1); lua_pop(L, 1);
        }
    }

    /// Stes the luaCellIndex value
    int set(lua_State *L)
    {
        x = (int)luaL_checknumber(L, -2);  
        y = (int) luaL_checknumber(L, -1 ); 
        return 0;
        }

    /// Gets the luaCellIndex value
    int get(lua_State *L) 
    {
        lua_pushnumber(L, x); 
        lua_pushnumber(L, y); 
        return 2;
    }
};

#endif
