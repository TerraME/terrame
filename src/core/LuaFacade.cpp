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

#include "LuaFacade.h"

extern "C"
{
	#include <lua.h>
	#include <lauxlib.h>
}

terrame::lua::LuaFacade* terrame::lua::LuaFacade::instance = 0;

terrame::lua::LuaFacade* terrame::lua::LuaFacade::getInstance()
{
	if(!instance)
	{
		instance = new terrame::lua::LuaFacade();
	}

	return instance;
}

void terrame::lua::LuaFacade::pushString(lua_State* L, const std::string& str)
{
    lua_pushstring(L, str.c_str());
}

void terrame::lua::LuaFacade::pushNumber(lua_State* L, double number)
{
    lua_pushnumber(L, number);
}

void terrame::lua::LuaFacade::pushNil(lua_State* L)
{
	lua_pushnil(L);
}

void terrame::lua::LuaFacade::pushLightUserdata(lua_State* L, void* pointer)
{
	lua_pushlightuserdata(L, pointer);
}

void terrame::lua::LuaFacade::pushBoolean(lua_State* L, bool b)
{
	lua_pushboolean(L, b);
}

int terrame::lua::LuaFacade::pushTableAt(lua_State* L, int index)
{
	return lua_gettable(L, index);
}

void terrame::lua::LuaFacade::pop(lua_State* L, int numberOfElements)
{
	lua_pop(L, numberOfElements);
}

void terrame::lua::LuaFacade::popOneElement(lua_State* L)
{
	pop(L, 1);
}

void terrame::lua::LuaFacade::setTop(lua_State* L, int index)
{
	lua_settop(L, index);
}

void terrame::lua::LuaFacade::call(lua_State* L, int numberOfArguments, int numberOfResults)
{
	lua_call(L, numberOfArguments, numberOfResults);
}

std::string terrame::lua::LuaFacade::getStringAt(lua_State* L, int index)
{
	const char* str = luaL_checkstring(L , index);
	return std::string(str);
}

std::string terrame::lua::LuaFacade::getStringAtTop(lua_State* L)
{
	return getStringAt(L, -1);
}

double terrame::lua::LuaFacade::getNumberAt(lua_State* L, int index)
{
	return luaL_checknumber(L, index);
}

double terrame::lua::LuaFacade::getNumberAtTop(lua_State* L)
{
	return getNumberAt(L, -1);
}

long long terrame::lua::LuaFacade::getIntegerAt(lua_State* L, int index)
{
	return luaL_checkinteger(L, index);
}

int terrame::lua::LuaFacade::getTopIndex(lua_State* L)
{
	return (int)lua_gettop(L);
}

int terrame::lua::LuaFacade::nextAt(lua_State* L, int index)
{
	return (int)lua_next(L, index);
}

int terrame::lua::LuaFacade::pushGlobalByName(lua_State* L, const std::string& name)
{
	return lua_getglobal(L, name.c_str());
}

int terrame::lua::LuaFacade::getTypeAt(lua_State* L, int index)
{
	return lua_type(L, index);
}

bool terrame::lua::LuaFacade::isStringAt(lua_State* L, int index)
{
	return lua_type(L, index) == getStringType();
}

bool terrame::lua::LuaFacade::isNumberAt(lua_State* L, int index)
{
	return lua_type(L, index) == getNumberType();
}

bool terrame::lua::LuaFacade::isBooleanAt(lua_State* L, int index)
{
	return lua_isboolean(L, index);
}

bool terrame::lua::LuaFacade::isTableAt(lua_State* L, int index)
{
	return lua_istable(L, index);
}

bool terrame::lua::LuaFacade::isUserdataAt(lua_State* L, int index, const std::string& type)
{
    if (lua_type(L, index) != LUA_TUSERDATA)
		return false;

    lua_getmetatable(L, index);
    luaL_newmetatable(L, type.c_str());
    int result = lua_compare(L, -2, -1, LUA_OPEQ);
    lua_pop(L, 2); // pop both tables(metatables) off
    return result;
}

bool terrame::lua::LuaFacade::isStringOrNumberAt(lua_State* L, int index)
{
	return lua_isstring(L, index);
}

bool terrame::lua::LuaFacade::isNumberOrStringNumberAt(lua_State* L, int index)
{
	return lua_isnumber(L, index);
}

bool terrame::lua::LuaFacade::toBooleanAt(lua_State* L, int index)
{
	return lua_toboolean(L, index);
}

long long terrame::lua::LuaFacade::toIntegerAt(lua_State* L, int index)
{
	return lua_tointeger(L, index);
}

std::string terrame::lua::LuaFacade::toStringAt(lua_State* L, int index)
{
	const char* str = lua_tostring(L , index);
	return std::string(str);
}

bool terrame::lua::LuaFacade::isString(int type)
{
	return type == getStringType();
}

bool terrame::lua::LuaFacade::isNumber(int type)
{
	return type == getNumberType();
}

bool terrame::lua::LuaFacade::isBoolean(int type)
{
	return type == getBooleanType();
}

bool terrame::lua::LuaFacade::isTable(int type)
{
	return type == getTableType();
}

bool terrame::lua::LuaFacade::isUserdata(int type)
{
	return type == getUserdataType();
}

bool terrame::lua::LuaFacade::isFunction(int type)
{
	return type == getFunctionType();
}

const void* terrame::lua::LuaFacade::toPointerAt(lua_State* L, int index)
{
	return lua_topointer(L, index);
}

int terrame::lua::LuaFacade::getStringType()
{
	return (int)LUA_TSTRING;
}

int terrame::lua::LuaFacade::getNumberType()
{
	return (int)LUA_TNUMBER;
}

int terrame::lua::LuaFacade::getBooleanType()
{
	return (int)LUA_TBOOLEAN;
}

int terrame::lua::LuaFacade::getTableType()
{
	return (int)LUA_TTABLE;
}

int terrame::lua::LuaFacade::getUserdataType()
{
	return (int)LUA_TUSERDATA;
}

int terrame::lua::LuaFacade::getFunctionType()
{
	return (int)LUA_TUSERDATA;
}



void terrame::lua::LuaFacade::callError(lua_State *L, const std::string& msg)
{
    pushGlobalByName(L, "customError");
    pushString(L, msg);
    pushNumber(L, 3);
    call(L, 2, 0);
}

void terrame::lua::LuaFacade::callWarning(lua_State *L, const std::string& msg)
{
	pushGlobalByName(L, "customWarning");
	pushString(L, msg);
	pushNumber(L, 5);
	call(L, 2, 0);
}

int terrame::lua::LuaFacade::createWeakTable(lua_State *L)
{
    lua_newtable(L);
    lua_newtable(L);
    lua_pushstring(L, "__mode");
    lua_pushstring(L, "kv");
    lua_rawset(L, -3);
    lua_setmetatable(L, -2);

    return luaL_ref(L, LUA_REGISTRYINDEX);
}

void terrame::lua::LuaFacade::stack(lua_State *L)
{
	int top = lua_gettop(L);
	for (int i = 1; i <= top; i++)
	{
		int t = lua_type(L, i);
		switch (t)
		{
			case LUA_TSTRING:
			printf("`%s'", lua_tostring(L, i));
			break;

			case LUA_TBOOLEAN:
			printf(lua_toboolean(L, i) ? "true" : "false");
			break;

			case LUA_TNUMBER:
			printf("%g", lua_tonumber(L, i));
			break;

			default:
			printf("%s", lua_typename(L, t));
			break;
		}
		printf("  ");
	}
	printf("\n");
}
