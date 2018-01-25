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
	\brief LuaFacade is a Singleton that implements LuaApi inteface.
*/

#ifndef LUA_FACADE_H
#define LUA_FACADE_H

#include <string>

class lua_State;

#include "LuaApi.h"

namespace terrame
{
	namespace lua
	{
		class LuaFacade : public LuaApi
		{
			public:
				static LuaFacade* getInstance();

				void pushString(lua_State* L, const std::string& str);
				void pushNumber(lua_State* L, double number);
				void pushNil(lua_State* L);
				void pushLightUserdata(lua_State* L, void* pointer);
				void pushBoolean(lua_State* L, bool b);

				int pushGlobalByName(lua_State* L, const std::string& name);
				int pushTableAt(lua_State* L, int index);

				void pop(lua_State* L, int numberOfElements);
				void popOneElement(lua_State* L);
				void setTop(lua_State* L, int index);
				void call(lua_State* L, int numberOfArguments, int numberOfResults);

				std::string getStringAt(lua_State* L, int index);
				std::string getStringAtTop(lua_State* L);

				double getNumberAt(lua_State* L, int index);
				double getNumberAtTop(lua_State* L);

				long long getIntegerAt(lua_State* L, int index);

				int getTopIndex(lua_State* L);
				int nextAt(lua_State* L, int index);
				int getTypeAt(lua_State* L, int index);

				bool isStringAt(lua_State* L, int index);
				bool isNumberAt(lua_State* L, int index);
				bool isBooleanAt(lua_State* L, int index);
				bool isTableAt(lua_State* L, int index);
				bool isUserdataAt(lua_State* L, int index, const std::string& type);
				bool isStringOrNumberAt(lua_State* L, int index);
				bool isNumberOrStringNumberAt(lua_State* L, int index);

				bool isString(int type);
				bool isNumber(int type);
				bool isBoolean(int type);
				bool isTable(int type);
				bool isUserdata(int type);
				bool isFunction(int type);

				bool toBooleanAt(lua_State* L, int index);
				const void* toPointerAt(lua_State* L, int index);
				long long toIntegerAt(lua_State* L, int index);
				std::string toStringAt(lua_State* L, int index);

				void callError(lua_State* L, const std::string& msg);
				void callWarning(lua_State* L, const std::string& msg);

				int createWeakTable(lua_State *L);

				void setReference(lua_State* L, int ref, const void* p);
				void getReference(lua_State* L, int ref, const void* p);

				void stack(lua_State* L);

			private:
				static LuaFacade* instance;

				LuaFacade() {}
				LuaFacade(const LuaFacade& old);
				const LuaFacade &operator=(const LuaFacade& old);
				~LuaFacade() {}

				int getStringType();
				int getNumberType();
				int getBooleanType();
				int getTableType();
				int getUserdataType();
				int getFunctionType();
		};
	} // namespace lua
} // namespace terrame

#endif // LUA_FACADE_H
