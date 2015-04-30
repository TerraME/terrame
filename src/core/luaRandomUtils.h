/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2008 INPE and TerraLAB/UFOP.

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
  \file randomUtils.h
  \brief 
  \author
*/

#ifndef LUA_RANDOM_UTIL_H
#define LUA_RANDOM_UTIL_H

#include "RandomLib/Random.hpp"

#include "reference.h"

//****************************** RANDOM NUMBERS **********************************************//
class LuaRandomUtil : public Reference<LuaRandomUtil>
{
    RandomLib::Random r;

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<LuaRandomUtil>::RegType methods[];
public:
    LuaRandomUtil(lua_State *L)
    {
        int seed = (int) luaL_checkinteger(L, -1);
        r.Reseed(seed);
    }

    // redistribute(string s)
/*
    int redistribute(lua_State *L){
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        int top = lua_gettop(L);
        QString distribution = luaL_checkstring(L, top - 1);

        if(distribution == "normal"){
            qDebug() << "-->> normal";
        }
        else {
            qDebug() << "-->> not normal";
        }
        return 1;
    }
*/
    // reseed(int v)
    int reseed(lua_State *L){
        int v = (int)luaL_checkinteger(L, -1);
        this->r.Reseed(v);
        return 1;
    }

    // random()
    // random(a)
    // random(a,b)
    int random(lua_State *L){

        // int arg2 = (int)luaL_checkinteger(L, top - 1);
        // int arg = (int)luaL_checkinteger(L, top - 2);
        int arg2 = (int)luaL_checkinteger(L, -1);
        int arg = (int)luaL_checkinteger(L, -2);
        
        int v;
        double dV;
        if(arg < 0){
            // condition arg < 0 and arg2 < 0 with random() semantics
            if(arg2 < 0){
                dV = this->r.Float();

                lua_pushnumber(L, dV);
                return 1;
            }
            else {
                v = this->r.IntegerC(arg2);
            }
        }
        else
            v = this->r.IntegerC(arg,arg2);
        lua_pushnumber(L, v);
        return 1;
    }

    // random(a)
    // random(a,b)
    int randomInteger(lua_State *L){

        // int arg2 = (int)luaL_checkinteger(L, top - 1);
        // int arg = (int)luaL_checkinteger(L, top - 2);
        int arg2 = (int)luaL_checkinteger(L, -1);
        int arg = (int)luaL_checkinteger(L, -2);
        int v;
                v = this->r.IntegerC(arg,arg2);
        lua_pushnumber(L, v);
        return 1;
    }
};

#endif // LUA_RANDOM_UTIL_H
