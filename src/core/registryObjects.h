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
  \file registryObjects.h
  \brief Registry objects in Lua environment
  \author
*/

#ifndef REGISTRY_OBJECT_H
#define REGISTRY_OBJECT_H

extern "C"
{
	#include <lua.h>
}

#include "luna.h"
#include "luaRandomUtils.h"

//------------------------------------------------------------------------------------
#define method(class, name) {#name, &class::name}

//----------------------------------------------------------------------------------------------
/* Pop-up a Windows message box with your choice of message and caption */
//int lua_msgbox(lua_State* L)
//{
//  const char* message = luaL_checkstring(L, 1);
//   const char* caption = luaL_optstring(L, 2, "");
//  int result = MessageBox(NULL, message, caption, MB_OK);
//   lua_pushnumber(L, result);
//   return 1;
//}


//****************************** RANDOM UTIL ******************************************//
//----------------------------------------------------------------------------------------------
const char LuaRandomUtil::className[] = "RandomUtil";

Luna<LuaRandomUtil>::RegType LuaRandomUtil::methods[] = {
	method(LuaRandomUtil, random),
	method(LuaRandomUtil, randomInteger),
	method(LuaRandomUtil, reseed),
	method(LuaRandomUtil, getReference),
	method(LuaRandomUtil, setReference),
	{0, 0}
};

//****************************** SPACE **********************************************//
//----------------------------------------------------------------------------------------------
const char luaCellIndex::className[] = "TeCoord";

Luna<luaCellIndex>::RegType luaCellIndex::methods[] = {
	method(luaCellIndex, get),
	method(luaCellIndex, set),
	method(luaCellIndex, getReference),
	method(luaCellIndex, setReference),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaNeighborhood::className[] = "TeNeighborhood";

Luna<luaNeighborhood>::RegType luaNeighborhood::methods[] = {
	method(luaNeighborhood, addCell),
	method(luaNeighborhood, eraseCell),
	method(luaNeighborhood, getCellWeight),
	method(luaNeighborhood, setCellWeight),
	method(luaNeighborhood, getWeight),
	method(luaNeighborhood, setWeight),
	method(luaNeighborhood, getCellNeighbor ),
	method(luaNeighborhood, getNeighbor ),
	//method(luaNeighborhood, getNeighbor_ ), // for debugging
	method(luaNeighborhood, first),
	method(luaNeighborhood, last),
	method(luaNeighborhood, isFirst),
	method(luaNeighborhood, isLast),
	method(luaNeighborhood, next),
	method(luaNeighborhood, getX),
	method(luaNeighborhood, getY),
	method(luaNeighborhood, getCoord),
	method(luaNeighborhood, isEmpty),
	method(luaNeighborhood, clear),
	method(luaNeighborhood, size),
	method(luaNeighborhood, getReference),
	method(luaNeighborhood, setReference),
	method(luaNeighborhood, getID),
	method(luaNeighborhood, addNeighbor),
	method(luaNeighborhood, eraseNeighbor),
	method(luaNeighborhood, setNeighWeight),
	method(luaNeighborhood, getNeighWeight),
	method(luaNeighborhood, isNeighbor),
	method(luaNeighborhood, getParent),
	method(luaNeighborhood, previous),
	method(luaNeighborhood, createObserver),
	method(luaNeighborhood, notify),
	method(luaNeighborhood, kill),
	{0, 0}
};
//----------------------------------------------------------------------------------------------
const char luaSociety::className[] = "TeSociety";

Luna<luaSociety>::RegType luaSociety::methods[] = {
	method(luaSociety, getReference),
	method(luaSociety, setReference),
	method(luaSociety, createObserver),
	method(luaSociety, notify),
	method(luaSociety, kill),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaCell::className[] = "TeCell";

Luna<luaCell>::RegType luaCell::methods[] = {
	method(luaCell, setLatency),
	method(luaCell, getLatency),
	method(luaCell, setNeighborhood),
	method(luaCell, getNeighborhood),
	method(luaCell, synchronize),
	method(luaCell, getReference),
	method(luaCell, setReference),
	method(luaCell, addNeighborhood),
	method(luaCell, first),
	method(luaCell, last),
	method(luaCell, getID),
	method(luaCell, setID),
	method(luaCell, isFirst),
	method(luaCell, isLast),
	method(luaCell, next),
	method(luaCell, getCurrentNeighborhood),
	method(luaCell, size),
	method(luaCell, getCurrentStateName),
	method(luaCell, setIndex),
	method(luaCell, createObserver),
	method(luaCell, notify),
	method(luaCell, kill),
	{0, 0}
};
//----------------------------------------------------------------------------------------------//////////////////////////////
const char luaCellularSpace::className[] = "TeCellularSpace";

Luna<luaCellularSpace>::RegType luaCellularSpace::methods[] = {
	method(luaCellularSpace, setDBType ),
	method(luaCellularSpace, setHostName ),
	method(luaCellularSpace, setDBName ),
	method(luaCellularSpace, getDBName ),
	method(luaCellularSpace, setUser ),
	method(luaCellularSpace, setPassword ),
	method(luaCellularSpace, setLayer ),
	method(luaCellularSpace, setTheme ),
	method(luaCellularSpace, clearAttrName ),
	method(luaCellularSpace, addAttrName ),
	method(luaCellularSpace, load ),
	method(luaCellularSpace, loadShape ),
	method(luaCellularSpace, saveShape ),
	method(luaCellularSpace, clear ),
	method(luaCellularSpace, size ),
	method(luaCellularSpace, addCell ),
	method(luaCellularSpace, setWhereClause ),
	method(luaCellularSpace, loadNeighborhood ),

#ifndef TME_NO_TERRALIB
	method(luaCellularSpace, save ),
	method(luaCellularSpace, loadTerraLibGPM ),
#endif #ifndef TME_NO_TERRALIB

	method(luaCellularSpace, getReference),
	method(luaCellularSpace, setReference),
	method(luaCellularSpace, getCell),
	method(luaCellularSpace, setPort),
	
	method(luaCellularSpace, createObserver),
	method(luaCellularSpace, notify),
	method(luaCellularSpace, kill),

	method(luaCellularSpace, getLayerName),
	method(luaCellularSpace, getCellByID),
	{0, 0}
};

//****************************** BEHAVIOR *******************************************//
//----------------------------------------------------------------------------------------------
const char luaJumpCondition::className[] = "TeJump";

Luna<luaJumpCondition>::RegType luaJumpCondition::methods[] = {
	method(luaJumpCondition, setTargetControlModeName),
	method(luaJumpCondition, getReference),
	method(luaJumpCondition, setReference),
	{0, 0}
};
//----------------------------------------------------------------------------------------------
const char luaFlowCondition::className[] = "TeFlow";

Luna<luaFlowCondition>::RegType luaFlowCondition::methods[] = {
	method(luaFlowCondition, getReference),
	method(luaFlowCondition, setReference),
	{0, 0}
};
//----------------------------------------------------------------------------------------------
const char luaControlMode::className[] = "TeState";

Luna<luaControlMode>::RegType luaControlMode::methods[] = {
	method(luaControlMode, add),
	method(luaControlMode, addFlow),
	method(luaControlMode, addJump),
	method(luaControlMode, getName),
	method(luaControlMode, config),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaGlobalAgent::className[] = "TeGlobalAutomaton";

Luna<luaGlobalAgent>::RegType luaGlobalAgent::methods[] =
{
	method(luaGlobalAgent, add),
	method(luaGlobalAgent, getLatency ),
	method(luaGlobalAgent, build),
	method(luaGlobalAgent, setActionRegionStatus),
	method(luaGlobalAgent, getActionRegionStatus),
	method(luaGlobalAgent, execute),
	method(luaGlobalAgent, getControlModeName),
	method(luaGlobalAgent, getReference),
	method(luaGlobalAgent, setReference),
	
	method(luaGlobalAgent, createObserver),
	method(luaGlobalAgent, notify),
	method(luaGlobalAgent, kill),
	{0, 0}
};
//----------------------------------------------------------------------------------------------
const char luaLocalAgent::className[] = "TeLocalAutomaton";

Luna<luaLocalAgent>::RegType luaLocalAgent::methods[] =
{
	method(luaLocalAgent, add),
	method(luaLocalAgent, getLatency),
	method(luaLocalAgent, build),
	method(luaLocalAgent, setActionRegionStatus),
	method(luaLocalAgent, execute),
	method(luaLocalAgent, getReference),
	method(luaLocalAgent, setReference),
	
	method(luaLocalAgent, createObserver),
	method(luaLocalAgent, notify),
	method(luaLocalAgent, kill),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaTrajectory::className[] = "TeTrajectory";

Luna<luaTrajectory>::RegType luaTrajectory::methods[] = {
	method(luaTrajectory, add),
	method(luaTrajectory, clear),
	method(luaTrajectory, getReference),
	method(luaTrajectory, setReference),
	
	method(luaTrajectory, createObserver),
	method(luaTrajectory, notify),
	method(luaTrajectory, kill),
	{0, 0}
};

const char luaVisualArrangement::className[] = "TeVisualArrangement";

Luna<luaVisualArrangement>::RegType luaVisualArrangement::methods[] = {
	method(luaVisualArrangement, setFile),
	method(luaVisualArrangement, addPosition),
	method(luaVisualArrangement, addSize),
	{0, 0}
};

const char luaChart::className[] = "TeChart";

Luna<luaChart>::RegType luaChart::methods[] = {
	method(luaChart, save),
	method(luaChart, setObserver),
	{0, 0}
};

const char luaMap::className[] = "TeMap";

Luna<luaMap>::RegType luaMap::methods[] = {
	method(luaMap, save),
	method(luaMap, setObserver),
	{0, 0}
};


//****************************** TIME ***********************************************//
//----------------------------------------------------------------------------------------------
const char luaMessage::className[] = "TeMessage";

Luna<luaMessage>::RegType luaMessage::methods[] = {
	method(luaMessage, config),
	method(luaMessage, getReference),
	method(luaMessage, setReference),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaEvent::className[] = "TeEvent";

Luna<luaEvent>::RegType luaEvent::methods[] =
{
	method(luaEvent, config),
	method(luaEvent, getTime),
	method(luaEvent, getPeriod),
	method(luaEvent, setPriority),
	method(luaEvent, getPriority),
	method(luaEvent, getReference),
	method(luaEvent, setReference),
	
	method(luaEvent, createObserver),
	method(luaEvent, notify),
	method(luaEvent, getType),
	method(luaEvent, kill),
	{0, 0}
};

//----------------------------------------------------------------------------------------------
const char luaTimer::className[] = "TeTimer";

Luna<luaTimer>::RegType luaTimer::methods[] =
{
	method(luaTimer, add),
	method(luaTimer, getTime),
	method(luaTimer, isEmpty),
	method(luaTimer, reset),
	method(luaTimer, execute),
	
	method(luaTimer, getReference),
	method(luaTimer, setReference),
	method(luaTimer, createObserver),
	method(luaTimer, notify),
	method(luaTimer, kill),
	{0, 0}
};
//****************************** ENVIRONMENT ****************************************//
//----------------------------------------------------------------------------------------------
const char luaEnvironment::className[] = "TeScale";

Luna<luaEnvironment>::RegType luaEnvironment::methods[] =
{
	method(luaEnvironment, config),
	method(luaEnvironment, execute),
	method(luaEnvironment, add),
	method(luaEnvironment, addTimer),
	method(luaEnvironment, addCellularSpace),
	method(luaEnvironment, addGlobalAgent),
	method(luaEnvironment, addLocalAgent),
	
	method(luaEnvironment, getReference),
	method(luaEnvironment, setReference),
	method(luaEnvironment, createObserver),
	method(luaEnvironment, notify),
	method(luaEnvironment, kill),
	{0, 0}
};

#endif // REGISTRY_OBJECT_H

