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
/*! \file luaAgent.h
    \brief This file definitions for the luaAgent objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUAAGENT_H )
#define LUAAGENT_H

extern "C"
{
#include <lua.h>
}
#include "luna.h"
#include "reference.h"
extern lua_State * L; ///< Gobal variabel: Lua stack used for comunication with C++ modules.

/**
* \brief  
*  Implementation for a luaAgent object.
*
*/
class luaAgent : public Reference<luaAgent>
{
private:
    // @DANIEL
    // Movido para a classe Reference
    //int ref; ///< The position of the object in the Lua stack

protected:
    // @DANIEL
//    int getRef()
//    {
//        return ref;
//    }

public:

    ///  Destructor
    virtual ~luaAgent(void)
    {
        // @DANIEL
        // n?o misturar ger?ncia de mem?ria da camada C++ com a camada Lua
        // luaL_unref( L, LUA_REGISTRYINDEX, ref);
    }

    /// Registers the luaAgent object in the Lua stack
    //virtual
    // @DANIEL
    // Movido para a classe Reference
//    int setReference( lua_State* L) //= 0;
//    {
//        ref = luaL_ref(L, LUA_REGISTRYINDEX );
//        return 0;
//    }

    // virtual
    /// Gets the luaAgent object reference.
    // @DANIEL
    // Movido para a classe Reference
//    int getReference( lua_State *L ) // = 0;
//    {
//        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//        return 1;
//    }

};

#endif
