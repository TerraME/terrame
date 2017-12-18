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

#include "LuaCellTest.h"

// all application
#include "core/terrameGlobals.h"
#include "observer/observerInterf.cpp"
#include "observer/observerImpl.cpp"
#include "observer/protocol/decoder/decoder.cpp"
#include "observer/protocol/blackBoard/blackBoard.cpp"
#include "observer/components/legend/legendAttributes.cpp"
#include "observer/components/legend/legendColorUtils.cpp"
#include "observer/visualArrangement.cpp"
#include "observer/types/stateMachine/edge.cpp"
#include "observer/types/stateMachine/node.cpp"

// just LuaCell
#include "observer/cellSubjectInterf.cpp"
#include "observer/cellSpaceSubjectInterf.cpp"
#include "core/luaCellularSpace.cpp"
#include "core/luaNeighborhood.cpp"

#include "LuaApiMock.h"
#include "LuaBindingMock.h"

ExecutionModes execModes;
lua_State* L;

#include "core/luaCell.cpp"

void LuaCellTest::SetUp()
{
	execModes = ExecutionModes::Normal;
}

void LuaCellTest::TearDown()
{
}

TEST_F(LuaCellTest, Constructor)
{
	LuaApiMock* luaApi = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApi);
	luaCell* lc = new luaCell(L);
}

TEST_F(LuaCellTest, SetAndGetId)
{
	LuaApiMock* luaApiMock = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApiMock);
	luaCell* lc = new luaCell(L);

	EXPECT_CALL(*luaApiMock, getStringAtTop(testing::_))
		.Times(testing::AnyNumber())
		.WillRepeatedly(testing::Return(std::string("1")));

	lc->setID(L);
	std::string result(lc->getID());
	ASSERT_EQ(result, "1");

	delete luaApiMock;
}

TEST_F(LuaCellTest, CreateObserverAndKill)
{
	LuaApiMock* luaApiMock = new LuaApiMock();
	terrame::lua::LuaSystem::getInstance().setLuaApi(luaApiMock);
	LuaBindingMock<luaCell>* bindMock = new LuaBindingMock<luaCell>();
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setBinding(bindMock);

	luaCell* lc = new luaCell(L);

	EXPECT_CALL(*luaApiMock, getStringAtTop(testing::_))
		.Times(testing::AnyNumber())
		.WillRepeatedly(testing::Return(std::string("1")));

	lc->setID(L);

	EXPECT_CALL(*luaApiMock, getNumberAt(testing::_, -4))
		.Times(testing::AnyNumber())
		.WillRepeatedly(testing::Return(TerraMEObserver::TypesOfObservers::TObsDynamicGraphic));

	EXPECT_CALL(*luaApiMock, nextAt(testing::_, testing::_))
		.Times(8)
		.WillOnce(testing::Return(1))
		.WillOnce(testing::Return(0))
		.WillOnce(testing::Return(0))
		.WillOnce(testing::Return(3))
		.WillOnce(testing::Return(3))
		.WillOnce(testing::Return(3))
		.WillOnce(testing::Return(3))
		.WillRepeatedly(testing::Return(0));

	EXPECT_CALL(*luaApiMock, getStringAt(testing::_, -2))
		.Times(1)
		.WillOnce(testing::Return(std::string("status")));

	EXPECT_CALL(*luaApiMock, getStringAtTop(testing::_))
		.Times(4)
		.WillOnce(testing::Return(std::string("status")))
		.WillOnce(testing::Return(std::string("X")))
		.WillOnce(testing::Return(std::string("Y")))
		.WillOnce(testing::Return(std::string("status;X;Y")));

	EXPECT_CALL(*luaApiMock, getTopIndex(testing::_))
		.Times(2)
		.WillRepeatedly(testing::Return(1));

	EXPECT_CALL(*luaApiMock, isTableAt(testing::_, testing::_))
		.Times(1)
		.WillOnce(testing::Return(true));

	EXPECT_CALL(*luaApiMock, pushNil(testing::_))
		.Times(testing::AnyNumber());

	EXPECT_CALL(*luaApiMock, popOneElement(testing::_))
		.Times(testing::AnyNumber());

	EXPECT_CALL(*luaApiMock, setTop(testing::_, testing::_));

	EXPECT_CALL(*luaApiMock, getTypeAt(testing::_, testing::_))
		.Times(testing::AnyNumber());;

	EXPECT_CALL(*bindMock, getReference(testing::_))
		.Times(1)
		.WillOnce(testing::Return(1));

	EXPECT_CALL(*luaApiMock, isStringAt(testing::_, -2))
		.Times(testing::AnyNumber())
		.WillRepeatedly(testing::Return(false));

	EXPECT_CALL(*luaApiMock, isString(testing::_))
		.Times(4)
		.WillRepeatedly(testing::Return(true));

	EXPECT_CALL(*luaApiMock, pushLightUserdata(testing::_, testing::_));

	EXPECT_CALL(*luaApiMock, pushNumber(testing::_, testing::_));

	lc->createObserver(L);

	EXPECT_CALL(*luaApiMock, getNumberAt(testing::_, testing::_))
		.Times(1)
		.WillOnce(testing::Return(1));

	EXPECT_CALL(*luaApiMock, pushBoolean(testing::_, testing::_));

	lc->kill(L);

	delete luaApiMock;
	delete bindMock;
}