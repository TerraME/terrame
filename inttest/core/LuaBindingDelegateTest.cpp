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

#include "LuaBindingDelegateTest.h"

#include "core/LuaBindingDelegate.h"
#include "core/LuaBinding.h"
//#include "core/luaCell.h"

//#include "LuaBindingMock.h"
#include "LuaApiMock.h"

void LuaBindingDelegateTest::SetUp()
{
	terrame::lua::LuaApi* luaApi = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApi);
}

void LuaBindingDelegateTest::TearDown()
{
	terrame::lua::LuaSystem::getInstance().destroy();
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().dispose();
}

TEST_F(LuaBindingDelegateTest, Check)
{
	bindmock = new LuaBindingMock<luaCell>();
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setBinding(bindmock);
	luaCell* cell;
	
	EXPECT_CALL(*bindmock, check(testing::_, testing::_))
		.Times(1)		
		.WillOnce(testing::Return(cell));	

	ASSERT_EQ(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().check(L, 1), cell);

	delete bindmock;
}

TEST_F(LuaBindingDelegateTest, SetReference)
{
	bindmock = new LuaBindingMock<luaCell>();
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setBinding(bindmock);

	EXPECT_CALL(*bindmock, setReference(testing::_))
		.Times(1)
		.WillOnce(testing::Return(1));	

	ASSERT_EQ(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setReference(L), 1);

	delete bindmock;
}

TEST_F(LuaBindingDelegateTest, GetReference)
{
	bindmock = new LuaBindingMock<luaCell>();
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setBinding(bindmock);

	EXPECT_CALL(*bindmock, getReference(testing::_))
		.Times(1)
		.WillOnce(testing::Return(1));	

	ASSERT_EQ(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().getReference(L), 1);

	delete bindmock;
}

TEST_F(LuaBindingDelegateTest, CheckWithoutSetBinding)
{
	ASSERT_ANY_THROW(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().check(L, 1));
}

TEST_F(LuaBindingDelegateTest, SetReferenceWithoutSetBinding)
{
	ASSERT_ANY_THROW(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setReference(L));
}

TEST_F(LuaBindingDelegateTest, GetReferenceWithoutSetBinding)
{
	ASSERT_ANY_THROW(terrame::lua::LuaBindingDelegate<luaCell>::getInstance().getReference(L));
}