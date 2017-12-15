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

#include <gmock/gmock.h>

#include "core/LuaApi.h"

class LuaApiMock : public terrame::lua::LuaApi
{
	public:
		LuaApiMock() {}
		MOCK_METHOD2(pushString, void(lua_State* L, const std::string& str));
		MOCK_METHOD2(pushNumber, void(lua_State* L, double number));
		MOCK_METHOD1(pushNil, void(lua_State* L));
		MOCK_METHOD2(pushLightUserdata, void(lua_State* L, void* pointer));
		MOCK_METHOD2(pushBoolean, void(lua_State* L, bool b));

		MOCK_METHOD2(pushGlobalByName, int(lua_State* L, const std::string& name));
		MOCK_METHOD2(pushTableAt, int(lua_State* L, int index));
				
		MOCK_METHOD2(pop, void(lua_State* L, int numberOfElements));
		MOCK_METHOD1(popOneElement, void(lua_State* L));
		MOCK_METHOD2(setTop, void(lua_State* L, int index));
		MOCK_METHOD3(call, void(lua_State* L, int numberOfArguments, int numberOfResults));

		MOCK_METHOD2(getStringAt, std::string(lua_State* L, int position));
		MOCK_METHOD1(getStringAtTop, std::string(lua_State* L));

		MOCK_METHOD2(getNumberAt, double(lua_State* L, int index));
		MOCK_METHOD1(getNumberAtTop, double(lua_State* L));

		MOCK_METHOD2(getIntegerAt, long long(lua_State* L, int index));

		MOCK_METHOD1(getTopIndex, int(lua_State* L));
		MOCK_METHOD2(nextAt, int(lua_State* L, int index));
		MOCK_METHOD2(getTypeAt, int(lua_State* L, int index));

		MOCK_METHOD2(isStringAt, bool(lua_State* L, int index));
		MOCK_METHOD2(isNumberAt, bool(lua_State* L, int index));
		MOCK_METHOD2(isBooleanAt, bool(lua_State* L, int index));
		MOCK_METHOD2(isTableAt, bool(lua_State* L, int index));
		MOCK_METHOD3(isUserdataAt, bool(lua_State* L, int index, const std::string& type));
		MOCK_METHOD2(isStringOrNumberAt, bool(lua_State* L, int index));
		MOCK_METHOD2(isNumberOrStringNumberAt, bool(lua_State* L, int index));

		MOCK_METHOD1(isString, bool(int type));
		MOCK_METHOD1(isNumber, bool(int type));
		MOCK_METHOD1(isBoolean, bool(int type));
		MOCK_METHOD1(isTable, bool(int type));
		MOCK_METHOD1(isUserdata, bool(int type));
		MOCK_METHOD1(isFunction, bool(int type));

		MOCK_METHOD2(toBooleanAt, bool(lua_State* L, int index));
		MOCK_METHOD2(toPointerAt, const void*(lua_State* L, int index));
		MOCK_METHOD2(toIntegerAt, long long(lua_State* L, int index));		
		MOCK_METHOD2(toStringAt, std::string(lua_State* L, int index));	

		MOCK_METHOD2(callError, void(lua_State* L, const std::string& msg));
		MOCK_METHOD2(callWarning, void(lua_State* L, const std::string& msg));

		MOCK_METHOD1(createWeakTable, int(lua_State* L));

		MOCK_METHOD1(stack, void(lua_State* L));
};