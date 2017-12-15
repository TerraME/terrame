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

#include "LuaSystemTest.h"

#include "core/LuaSystem.cpp"
#include "LuaApiMock.h"


TEST_F(LuaSystemTest, SetAndGetLuaApi)
{
	terrame::lua::LuaApi* luaApi = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApi);
	ASSERT_NO_THROW(terrame::lua::LuaSystem::getInstance().getLuaApi());
	terrame::lua::LuaSystem::getInstance().destroy();
}

TEST_F(LuaSystemTest, GetLuaApiWithoutSetIt)
{
	ASSERT_ANY_THROW(terrame::lua::LuaSystem::getInstance().getLuaApi());
}

TEST_F(LuaSystemTest, GetLuaApiAfterRemoveIt)
{
	terrame::lua::LuaApi* luaApi = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApi);
	terrame::lua::LuaSystem::getInstance().destroy();
	ASSERT_ANY_THROW(terrame::lua::LuaSystem::getInstance().getLuaApi());
}
