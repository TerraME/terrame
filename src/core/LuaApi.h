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
	\brief	LuaApi is a interface abstract that encapsulates the methods called from Lua API.
			The system must call a concrete class that implements this interface,
			and must never call Lua API directly.
			This allows a low coupling between Lua and the system.
*/

#ifndef LUA_API_H
#define LUA_API_H

#include <string>

class lua_State;

namespace terrame
{
	namespace lua
	{
		class LuaApi
		{
			public:
				virtual void pushString(lua_State* L, const std::string& str) = 0;
				virtual void pushNumber(lua_State* L, double number) = 0;
				virtual void pushNil(lua_State* L) = 0;
				virtual void pushLightUserdata(lua_State* L, void* pointer) = 0;
				virtual void pushBoolean(lua_State* L, bool b) = 0;

				virtual int pushGlobalByName(lua_State* L, const std::string& name) = 0;
				virtual int pushTableAt(lua_State* L, int index) = 0;

				virtual void pop(lua_State* L, int numberOfElements) = 0;
				virtual void popOneElement(lua_State* L) = 0;
				virtual void setTop(lua_State* L, int index) = 0;
				virtual void call(lua_State* L, int numberOfArguments, int numberOfResults) = 0;

				virtual std::string getStringAt(lua_State* L, int index) = 0;
				virtual std::string getStringAtTop(lua_State* L) = 0;

				virtual double getNumberAt(lua_State* L, int index) = 0;
				virtual double getNumberAtTop(lua_State* L) = 0;

				virtual long long getIntegerAt(lua_State* L, int index) = 0;

				virtual int getTopIndex(lua_State* L) = 0;
				virtual int nextAt(lua_State* L, int index) = 0;
				virtual int getTypeAt(lua_State* L, int index) = 0;
				virtual int getRefNilValue() = 0;

				virtual bool isStringAt(lua_State* L, int index) = 0;
				virtual bool isNumberAt(lua_State* L, int index) = 0;
				virtual bool isBooleanAt(lua_State* L, int index) = 0;
				virtual bool isTableAt(lua_State* L, int index) = 0;
				virtual bool isUserdataAt(lua_State* L, int index, const std::string& type) = 0;
				virtual bool isStringOrNumberAt(lua_State* L, int index) = 0;
				virtual bool isNumberOrStringNumberAt(lua_State* L, int index) = 0;

				virtual bool isString(int type) = 0;
				virtual bool isNumber(int type) = 0;
				virtual bool isBoolean(int type) = 0;
				virtual bool isTable(int type) = 0;
				virtual bool isUserdata(int type) = 0;
				virtual bool isFunction(int type) = 0;

				virtual bool toBooleanAt(lua_State* L, int index) = 0;
				virtual const void* toPointerAt(lua_State* L, int index) = 0;
				virtual long long toIntegerAt(lua_State* L, int index) = 0;
				virtual std::string toStringAt(lua_State* L, int index) = 0;

				virtual void callError(lua_State* L, const std::string& msg) = 0;
				virtual void callWarning(lua_State* L, const std::string& msg) = 0;

				virtual int createWeakTable(lua_State *L) = 0;

				virtual void setReference(lua_State* L, int ref, const void* p) = 0;
				virtual void getReference(lua_State* L, int ref, const void* p) = 0;

				virtual void stack(lua_State* L) = 0;
		};
	} // namespace lua
} // namespace terrame

#endif // LUA_API_H
