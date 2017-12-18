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

/*!
\file luaUtils.cpp
\brief This file contains implementations for the TerraME utilitary functions.
\author Tiago Garcia de Senna Carneiro
*/

#include "luaUtils.h"

#include <cstring>
#include <cstdlib>

extern "C"
{
	#include "lua.h"
	#include "lauxlib.h"
}

extern lua_State * L; ///< Gobal variabel: Lua stack used for comunication with C++ modules.

/// UTILIITARY FUNCTION - Print the Lua stack. Used for debugging purpose.
/// \param size is the number of position to be printed from the stack top
/// \author Antonio Rodrigues
void luaStackToQString(int size)
{
    lua_State *luaL = L;
    printf("\n");
    for (int i = 0; i < size; i++)
    {
        printf("%i - %s \t %p\n", i, lua_typename(luaL, lua_type(luaL, (i * -1))),
               lua_topointer(luaL, (i * -1)));
    }
    printf("\n");
}


int functionStackLevel(lua_State *L) {
    int i;
    int top = lua_gettop(L);
    for (i = 0; i <= top; i++) { /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { /* strings */
                //printf("idx: %i string: '%s' \t %p\n", i,
                //       lua_tostring(L, i), lua_topointer(L, i));
                // std::cout << lua_tostring(L, i) << std::endl;
                break;
            }
            case LUA_TBOOLEAN: { /* booleans */
                //printf("idx: %i bool: %s \t %p\n", i,
                //       lua_toboolean(L, i) ? "true" : "false", lua_topointer(L, i));
                //std::cout <<(lua_toboolean(L, i) ? "true" : "false") << std::endl;
                break;
            }
            case LUA_TNUMBER: { /* numbers */
                //printf("idx: %i number: %g \t %p\n", i, lua_tonumber(L, i), lua_topointer(L, i));
                //std::cout << lua_tonumber(L, i) << std::endl;
                break;
            }
            default: { /* other values */
                printf("idx: %i others: %s \t %p\n", i, lua_typename(L, t), lua_topointer(L, i));
                //std::cout << lua_typename(L, t) << std::endl;
                break;
            }
        }
    }
    return i;
}

void stackDump(lua_State *L) {
    int i;
    int top = lua_gettop(L);
    printf("pilha Lua - top: %i\n ", top);
    //for (i = top; i >= 0; i--) { /* repeat for each level */
    for (i = 0; i <= top; i++) { /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { /* strings */
                printf("idx: %i string: '%s' \t %p\n", i,
                       lua_tostring(L, i), lua_topointer(L, i));
                // std::cout << lua_tostring(L, i) << std::endl;
                break;
            }
            case LUA_TBOOLEAN: { /* booleans */
                printf("idx: %i bool: %s \t %p\n", i,
                       lua_toboolean(L, i) ? "true" : "false", lua_topointer(L, i));
                //std::cout <<(lua_toboolean(L, i) ? "true" : "false") << std::endl;
                break;
            }
            case LUA_TNUMBER: { /* numbers */
                printf("idx: %i number: %g \t %p\n", i, lua_tonumber(L, i), lua_topointer(L, i));
                //std::cout << lua_tonumber(L, i) << std::endl;
                break;
            }
            default: { /* other values */
                printf("idx: %i others: %s \t %p\n", i, lua_typename(L, t), lua_topointer(L, i));
                //std::cout << lua_typename(L, t) << std::endl;
                break;
            }
        }
        printf(" "); /* put a separator */
    }
    printf("\n\n"); /* end the listing */
}
/// UTILIITARY FUNCTION - Checks if the value located at index "idx" in the Lua stack "L" is of the
/// user defined type "name".
/// \param L is a Lua stack
/// \param idx is a Lua stack position index
/// \param name is an user defined Lua type name
/// \return A boolean value: true case positive, otherwise false.
int isudatatype(lua_State *L, int idx, const char *name)
{ // returns true if a userdata is of a certain type
    int res;
    if (lua_type(L, idx) != LUA_TUSERDATA) return 0;
    lua_getmetatable(L, idx);
    luaL_newmetatable(L, name);
    res = lua_compare(L, -2, -1, LUA_OPEQ);
    lua_pop(L, 2); // pop both tables(metatables) off
    return res;
}

/// UTILITARY FUNCTION - Converts a TerraLib object ID to (x,y) coordinates
/// \param objId is a "const char const *" containing the object ID
/// \param x is a natural number returned by this function
/// \param y is a natural number returned by this fucntion
// RODRIGO
void objectId2coords(const char *objId, int &x, int &y)
{
    char lin[32], col[32];
    char seps[] = "CL";
    char aux[255] = "";

    strncpy(aux, objId, strlen(objId));
    strcpy(col, strtok((char*)aux, seps));
    strcpy(lin,  strtok(NULL, seps));
    //cout << "{" << col <<","<< lin <<"}" << endl;
    x = atoi(col);
    y = atoi(lin);
}

void returnsCustomError(lua_State *L, int number, const string message)
{
    lua_getglobal(L, "customError");
    lua_pushstring(L, message.c_str());
    lua_pushnumber(L, number);
    lua_call(L, 2, 0);
}
