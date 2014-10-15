/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright 2001-2008 INPE and TerraLAB/UFOP.

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

Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*************************************************************************************//*!
\file terrameLua5_1.h
\brief This file contains definitions about the TerraME API for Lua programmers.
\author Tiago Garcia de Senna Carneiro
*/

#ifndef TERRAME_LUA_5_1_H
#define TERRAME_LUA_5_1_H

#ifndef TME_NO_TERRALIB
	#include <TeDatabase.h>
#endif

#include "environment.h"
#include "agent.h"
#include "cellularSpace.h"
#include "scheduler.h"
#include "region.h"
#include "terrameGlobals.h"

#include <QtCore/QBuffer>
#include <QtCore/QByteArray>
#include <QtCore/QMutex>

#include "observerTextScreen.h"
#include "observerGraphic.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerMap.h"
#include "observerUDPSender.h"
#include "observerScheduler.h"


extern "C"
{
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}
#include "luna.h"


static char* TME_VERSION;
static char* TME_PATH;

/**
* \brief 
* luaCellIndex
*
* Represents an Index for a Cell. A TerraME Cell may have any representation in a geographic
* database. In raster data, each pixel is loaded as one Cell. In vector data, each geometry (point, 
* polyline, or polygon is one Cell. In cellular spaces from TerraLib database, each cell is
* a TerraME Cell.
*/

lua_State * L; ///< Gobal variabel: Lua stack used for comunication with C++ modules.

ExecutionModes execModes;

/// Shows the TerraME Player
bool SHOW_GUI;

int WORKERS_NUMBER;

/// Pause the simulation execution
/// false - (default) the simulation executes without pauses; 
/// true - pause the simulation until the user press play on de Observer Player
bool paused; 

/// Execute step by step the simulation
/// false - (default)
/// true - 
bool step;


class luaCell;

void getReference( lua_State *L, luaCell *cell );

class luaCell;
class luaCellularSpace;

luaCell * findCell( luaCellularSpace*, CellIndex& );


// SPACE REPRESENATION
#include "luaNeighborhood.h"
#include "luaCell.h"
#include "luaCellularSpace.h"

// TIME REPRESENATION
#include "luaEvent.h"
#include "luaMessage.h"
#include "luaTimer.h"

// BEHAVIOR REPRESENATION

#include "luaAgent.h"
#include "luaTrajectory.h"
#include "luaGlobalAgent.h"
#include "luaLocalAgent.h"
#include "luaRule.h"
#include "luaJumpCondition.h"
#include "luaFlowCondition.h"
#include "luaControlMode.h"

#include "luaSociety.h"

// ENVIRONMENT
#include "luaEnvironment.h"

#endif // TERRAME_LUA_5_1_H
