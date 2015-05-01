/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C) 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/
/*! \file luaNeighborhood.cpp
    \brief This file contaisn implementations  for the luaNeighborhood objects.
        \author Tiago Garcia de Senna Carneiro
		\author Raian Vargas Maretto
*/

#include "luaNeighborhood.h"
#include "luaCellularSpace.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

#include "observerUDPSender.h"
#include "observerTCPSender.h"
#include "agentObserverMap.h"
#include "agentObserverImage.h"
#include "observerTextScreen.h"
#include "observerLogFile.h"
#include "observerTable.h"

#include "protocol.pb.h"

extern lua_State * L; ///< Global variable: Lua stack used for communication with C++ modules.
extern ExecutionModes execModes;

using namespace TerraMEObserver;

/// constructor
luaNeighborhood::luaNeighborhood(lua_State *L) { 

    it = CellNeighborhood::begin();
    itNext = false;

    luaL = L;
    subjectType = TObsNeighborhood;
    cellSpace = 0;
}

/// destructor
luaNeighborhood::~luaNeighborhood(void) { }

/// Adds a new cell to the luaNeigborhood
/// parameters: cell.y, cell.x,  cell, weight
/// return luaCell
int luaNeighborhood::addNeighbor(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCell *cell = Luna<luaCell>::check(L, -2);
    CellIndex cellIndex;
    cellIndex.second = luaL_checknumber(L, -3);
    cellIndex.first = luaL_checknumber(L, -4);
    if(cell != NULL) {
        CellNeighborhood::add(cellIndex, (Cell*)cell, weight);
        cell->getReference(L);
    }
    else lua_pushnil(L);
    return 1;
}

/// Removes a cell from the luaNeighborhood
/// parameters: cell.x, cell.y
/// \author Raian Vargas Maretto
int luaNeighborhood::eraseNeighbor(lua_State *L) {
//	luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
	CellIndex cellIndex; 
	cellIndex.second = luaL_checknumber(L, -2);
	cellIndex.first = luaL_checknumber(L, -3);
	
	if(CellNeighborhood::empty() || CellNeighborhood::find(cellIndex) == CellNeighborhood::end())
	{
		lua_pushboolean(L, false);
		return 1;
	}
	else
	{
		if(it != CellNeighborhood::end() && it->first == cellIndex){
			it++;
			itNext = true;
		}
		CellNeighborhood::erase(cellIndex);
		lua_pushboolean(L, true);
		return 1;
	}
}


/// Adds a new luaNeighbor cell into the luaNeighborhood
/// parameters: cell index,  cell, weight
/// return luaCell
int luaNeighborhood::addCell(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCellularSpace *cs = Luna<luaCellularSpace>::check(L, -2);
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -3);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = ::findCell(cs, cellIndex);
    if(cell != NULL) {
        CellNeighborhood::add(cellIndex, (Cell*)cell, weight);
        cell->getReference(L);
    }
    else lua_pushnil(L);
    return 1;
}

/// Removes the luaNeighbor cell from the luaNeighborhood
/// parameters: cell index
int luaNeighborhood::eraseCell(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    if(it != CellNeighborhood::end() && it->first == cellIndex){
        it++;
        itNext = true;
    }
    CellNeighborhood::erase(cellIndex);
    return 0;
}

/// Gets the luaNeighborhood relationship weight value for the luaNeighbor indexed by the 2D coordinates received
/// as parameter
/// parameters: cell index 
/// return weight
int luaNeighborhood::getCellWeight(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    lua_pushnumber(L, CellNeighborhood::getWeight(cellIndex));
    return 1;
}

/// Gets the luaNeighbor cell indexed by the 2D coordinates received as parameter
/// parameters: cell index, 
/// return luaCell
int luaNeighborhood::getCellNeighbor(lua_State *L) {  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = (luaCell*)(*CellNeighborhood::pImpl_)[ cellIndex ];
    if(cell) cell->getReference(L);
    else lua_pushnil(L);
    return 1;
}

/// Gets the luaNeighborhood relationship weight value for the luaNeighbor indexed by the 2D coordinates received
/// as parameter.
/// no parameters
int luaNeighborhood::getWeight(lua_State *L)
{
    CellIndex cellIndex;
    if(it != CellNeighborhood::end()){
        cellIndex = it->first;
        double weight = CellNeighborhood::getWeight(cellIndex);
        lua_pushnumber(L, weight);
        return 1;
    }
    return 0;
}

/// Gets the luaNeighbor cell pointed by the Neighborhood iterator.
/// no parameters
int luaNeighborhood::getNeighbor(lua_State *L)
{
    CellIndex cellIndex;
    if(it != CellNeighborhood::end()){
        cellIndex = it->first;
        luaCell *cell = (luaCell*) it->second; //dynamic_cast<luaCell*>(it->second);
        cell->getReference(L);
        return 1;
    }
    lua_pushnil(L);
    return 1;
}


/// Gets luaNeighbor identifier
/// no parameters
int luaNeighborhood::getID(lua_State *L)
{
    const char *str = this->CellNeighborhood::getID().c_str();
    if(str) lua_pushstring(L, str);
    else lua_pushnil(L);
    return 1;
}

/// Sets the weight of a neighborhood relationship
/// parameters: cell.x, cell.y, weight
/// \author Raian Vargas Maretto
int luaNeighborhood::setNeighWeight(lua_State *L) {  
	double weight = luaL_checknumber(L, -1);
//	luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -2);
	CellIndex cellIndex; 
	cellIndex.second = luaL_checknumber(L, -3); 
	cellIndex.first = luaL_checknumber(L, -4);
	
	if(CellNeighborhood::empty() || CellNeighborhood::find(cellIndex) == CellNeighborhood::end())
		lua_pushboolean(L, false);
	else
	{
		CellNeighborhood::setWeight(cellIndex, weight);
		lua_pushboolean(L, true);
	}
	return 1;
}

/// Gets the weight of a neighborhood relationship
/// parameters: cell.x, cell.y
/// \author Raian Vargas Maretto
int luaNeighborhood::getNeighWeight(lua_State *L) {
	
	//luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
	CellIndex cellIndex;
	cellIndex.second = luaL_checknumber(L, -2);
	cellIndex.first = luaL_checknumber(L, -3);
	
	if(CellNeighborhood::empty() || CellNeighborhood::find(cellIndex) == CellNeighborhood::end())
	{
		lua_pushnil(L);
		return 1;
	}
	else
	{
		double weight = CellNeighborhood::getWeight(cellIndex);
		lua_pushnumber(L, weight);
		return 1;
	}
	return 0;
}

/// Sets the weight for the neighborhood relationship with the cell indexed by the coordinates
/// received as parameter.
/// parameters: cell index, weight
int luaNeighborhood::setCellWeight(lua_State *L) {  
    double weight = luaL_checknumber(L, -1);
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -2);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    CellNeighborhood::setWeight(cellIndex, weight);
    return 0;
}

/// Sets the weight for the neighborhood relationship with the Neighbor pointed by the Neighborhood iterator.
/// parameters: weight
int luaNeighborhood::setWeight(lua_State *L) {
    double weight = luaL_checknumber(L, -1);
    CellIndex cellIndex;
    if(it != CellNeighborhood::end()){
        cellIndex = it->first;
        CellNeighborhood::setWeight(cellIndex, weight);
    }
    return 0;
}

/// Puts the Neighborhood iterator in the beginning of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::first(lua_State *)
{
    it = CellNeighborhood::begin();
    return 0;
}

/// Puts the Neighborhood iterator in the end of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::last(lua_State *)
{
    it = CellNeighborhood::end();
    it--;
    return 0;
}

/// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure  
/// no parameters
int luaNeighborhood::isFirst(lua_State *L)
{
    lua_pushboolean(L, it == CellNeighborhood::begin());
    return 1;
}

/// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure  
/// no parameters
int  luaNeighborhood::isLast(lua_State *L)
{
    lua_pushboolean(L, it == CellNeighborhood::end());
    return  1;
}

/// Verifies if a cell is a neighbor 
/// parameters: cell.x, cell.y
/// return: true if cell is within the luaNeighborhood, otherwise retuens false
/// \author Raian Vargas Maretto
int luaNeighborhood::isNeighbor(lua_State *L)
{
	luaCell *cell = (luaCell*)Luna<luaCell>::check(L, -1);
	CellIndex cellIndex; 
	cellIndex.second = luaL_checknumber(L, -2);
	cellIndex.first = luaL_checknumber(L, -3);
	
	CellNeighborhood::iterator it = CellNeighborhood::find(cellIndex);
	
	if(CellNeighborhood::empty() || it == CellNeighborhood::end())
		lua_pushboolean(L, false);
	else
	{
		if (it->first == cellIndex && it->second == cell)
			lua_pushboolean(L, true);
		else
			lua_pushboolean(L, false);
	}
	
	return 1;
}

/// Fowards the Neighborhood iterator to the next Neighbor cell
/// no parameters
int luaNeighborhood::next(lua_State *)
{
    if(itNext){
        itNext = false;
        return 0;
    }
    else{
        if(it != CellNeighborhood::end()) it++;
    }
    return 0;
}

//@RAIAN
/// Fowards the Neighborhood iterator to the previous Neighbor cell
/// no parameters
int luaNeighborhood::previous(lua_State *)
{
    if(it != CellNeighborhood::begin()) it--;
    return 0;
}
//@RAIAN: FIM

/// Gets the X coordinate of the Neighbor cell pointed by the Neighborhood iterator
/// no parameters
int luaNeighborhood::getX(lua_State *L)
{
    int x = 0;
    if (it != CellNeighborhood::end())
    {
        x = it->first.first;
    }
    lua_pushnumber(L, x);
    return 1;
}

/// Gets the Y coordinate of the Neighbor cell pointed by the Neighborhood iterator
/// no parameters
int luaNeighborhood::getY(lua_State *L)
{
    int y = 0;
    if (it != CellNeighborhood::end())
    {
        y = it->first.second;
    }
    lua_pushnumber(L, y);
    return 1;
}

/// Gets the coordenates of the Neighbor cell pointed by the Neighborhood iterator
/// no parameters
int luaNeighborhood::getCoord(lua_State *L)
{
    int x = 0, y = 0;
    if (it != CellNeighborhood::end())
    {
        x = it->first.first;
        y = it->first.second;
    }
    lua_pushnumber(L, y);
    lua_pushnumber(L, x);
    return 2;
}

/// Returns true if the Neighborhood is empty.
/// no parameters
int luaNeighborhood::isEmpty(lua_State *L) {  
    lua_pushboolean(L, CellNeighborhood::empty());
    return 1;
}

/// Clears all the Neighborhood content
/// no parameters
int luaNeighborhood::clear(lua_State *) {  
    CellNeighborhood::clear();
    return 0;
}

/// Returns the number of Neighbors cells in the Neighborhood
/// no parameters
int luaNeighborhood::size(lua_State *L) {  
    lua_pushnumber(L, CellNeighborhood::size());
    return 1;
}

/// Gets the Neighborhood Parent, i. e., the "central" cell in the neighborhood graph.
/// no parameters
/// \author Raian Vargas Maretto
int luaNeighborhood::getParent(lua_State *L)
{
    luaCell* parent = (luaCell*) CellNeighborhood::getParent();
    if(parent)
        parent->getReference(L);
    else
        lua_pushnil(L);

    return 1;
}

#include <QDebug>

 int luaNeighborhood::createObserver(lua_State *)
 {
#ifdef DEBUG_OBSERVER
    // luaStackToQString(7);
    stackDump(luaL);
#endif

     // retrieve the reference of the cell
	Reference<luaNeighborhood>::getReference(luaL);
            
    // flags for the definition of the use of compression
    // in the datagram transmission and visibility
    // of observers Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // retrieve the attribute table
    int top = lua_gettop(luaL);
    
    // Retrieves the enum for the type of observer
    TypesOfObservers typeObserver = (TypesOfObservers)luaL_checkinteger(luaL, -4);

#ifdef DEBUG_OBSERVER
    qDebug() << "typeObserver" << getObserverName(typeObserver);
    luaStackToQString(12);

    if (lua_type(luaL, top -3)== LUA_TTABLE) qDebug() << -3 << "table"; else qDebug() << -3 << "not table";
    if (lua_type(luaL, top -2)== LUA_TTABLE) qDebug() << -2 << "table"; else qDebug() << -2 << "not table";
    if (lua_type(luaL, top -1)== LUA_TTABLE) qDebug() << -1 << "table"; else qDebug() << -1 << "not table";

    qDebug() << "\n";

    if (lua_type(luaL, top -3)== LUA_TNUMBER) qDebug() << -3 << "number"; else qDebug() << -3 << "not number";
    if (lua_type(luaL, top -2)== LUA_TNUMBER) qDebug() << -2 << "number"; else qDebug() << -2 << "not number";
    if (lua_type(luaL, top -1)== LUA_TNUMBER) qDebug() << -1 << "number"; else qDebug() << -1 << "not number";

    qDebug() << "\n";

    if (lua_type(luaL, top -3)== LUA_TSTRING) qDebug() << -3 << "string"; else qDebug() << -3 << "not string";
    if (lua_type(luaL, top -2)== LUA_TSTRING) qDebug() << -2 << "string"; else qDebug() << -2 << "not string";
    if (lua_type(luaL, top -1)== LUA_TSTRING) qDebug() << -1 << "string"; else qDebug() << -1 << "not string";
#endif


    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        QStringList obsAttribs, obsParams, obsParamsAtribs;
        QStringList cols;

        //lua_pushnil(luaL);
        //while(lua_next(luaL, top) != 0)
		// {
        //    // QString key(luaL_checkstring(luaL, -2));
        //    qDebug() << "top:" << top;

        //    if (lua_type(luaL, -1) == LUA_TSTRING)
        //        qDebug() << "lua_type(luaL, -1)" << luaL_checkstring(luaL, -1);
        //    else if (lua_type(luaL, -1) == LUA_TNUMBER)
        //        qDebug() << "lua_type(luaL, -1)"<< luaL_checknumber(luaL, -1);

        //    if (lua_type(luaL, -2) == LUA_TSTRING)
        //        qDebug() << "lua_type(luaL, -2)" << luaL_checkstring(luaL, -2);
        //    else if (lua_type(luaL, -2) == LUA_TNUMBER)
        //        qDebug() << "lua_type(luaL, -2)"<< luaL_checknumber(luaL, -2);


        //    // allAttribs.push_back(key);
        //    lua_pop(luaL, 1);
		// }

        // qDebug() << "Retrieves the parameters table";
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            QString key;
            
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);
            }
            //else
			// {
            //    if (lua_type(luaL, -2) == LUA_TNUMBER)
            //    {
            //        char aux[100];
            //        double number = luaL_checknumber(luaL, -2);
            //        sprintf(aux, "%g", number);
            //        key = aux;
			//	  }
            //}

            switch (lua_type(luaL, -1))
			{
            case LUA_TBOOLEAN:
                {
                    bool val = lua_toboolean(luaL, -1);
                    if (key == "visible")
                        obsVisible = val;
                    else // if (key == "compress")
                        compressDatagram = val;
                    break;
                }

            case LUA_TSTRING:
                {
                    const char *strAux = luaL_checkstring(luaL, -1);
                    cols.append(strAux);
                    break;
                }
            case LUA_TTABLE:
                {
                    int pos = lua_gettop(luaL);
                    QString k;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, pos) != 0)
                    {
                        if (lua_type(luaL, -2) == LUA_TSTRING)
                        {
                            obsParams.append(luaL_checkstring(luaL, -2));
                        }

                        switch (lua_type(luaL, -1))
                        {
                        case LUA_TSTRING:
                            k = luaL_checkstring(luaL, -1);
                            break;

                        case LUA_TNUMBER:
                            {
                                double number = luaL_checknumber(luaL, -1);
                                k = QString::number(number);
                                break;
                            }
                        default:
                            break;
                        }
                        cols.append(k);
                        lua_pop(luaL, 1);
                    }
                    break;
                }
            default:
                break;
            }
            lua_pop(luaL, 1);
        }

#ifdef DEBUG_OBSERVER
        qDebug() << obsParams;
        qDebug() << obsParamsAtribs;
#endif

        // Runs the attribute table
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            if (lua_type(luaL, -1) == LUA_TSTRING)
                obsAttribs.append(luaL_checkstring(luaL, -1));
     
            lua_pop(luaL, 1);
        }

        if (! obsAttribs.contains("weight"))
            obsAttribs.append("weight");

        ObserverUDPSender *obsUDPSender = 0;
        ObserverTCPSender *obsTCPSender = 0;    
        ObserverTextScreen *obsText = 0;
        ObserverTable *obsTable = 0;
        // ObserverGraphic *obsGraphic = 0;
        ObserverLogFile *obsLog = 0;

        int obsId = -1;

        switch (typeObserver)
        {
        case TObsTextScreen:
            obsText = (ObserverTextScreen*)
                NeighborhoodSubjectInterf::createObserver(TObsTextScreen);
            if (obsText)
            {
                obsId = obsText->getId();
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
            }
            break;

        case TObsLogFile:
            obsLog = (ObserverLogFile*)
                    NeighborhoodSubjectInterf::createObserver(TObsLogFile);
            if (obsLog)
            {
                obsId = obsLog->getId();
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
            }
            break;

        case TObsTable:
            obsTable = (ObserverTable *)
                    NeighborhoodSubjectInterf::createObserver(TObsTable);
            obsId = obsTable->getId();
            break;

        //case TObsDynamicGraphic:
        //    obsGraphic = (ObserverGraphic *)
        //            NeighborhoodSubjectInterf::createObserver(TObsDynamicGraphic);

        //    if (obsGraphic)
        //    {
        //        obsGraphic->setObserverType(TObsDynamicGraphic);
        //        obsId = obsGraphic->getId();
        //    }
        //    else
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        //    }
        //    break;

        //case TObsGraphic:
        //    obsGraphic = (ObserverGraphic *)
        //            NeighborhoodSubjectInterf::createObserver(TObsGraphic);
        //    if (obsGraphic)
        //    {
        //        obsId = obsGraphic->getId();
        //    }
        //    else
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        //    }
        //    break;

        case TObsUDPSender:
            obsUDPSender = (ObserverUDPSender *) 
                NeighborhoodSubjectInterf::createObserver(TObsUDPSender);
            if (obsUDPSender)
            {
                obsId = obsUDPSender->getId();
                obsUDPSender->setCompress(compressDatagram);

                if (obsVisible)
                    obsUDPSender->show();
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
            }
            break;

        case TObsTCPSender:
            obsTCPSender = (ObserverTCPSender *) 
                NeighborhoodSubjectInterf::createObserver(TObsTCPSender);
            if (obsTCPSender)
            {
                obsId = obsTCPSender->getId();
                obsTCPSender->setCompress(compressDatagram);

                if (obsVisible)
                    obsTCPSender->show();
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
            }
            break;

        default:
            if (execModes != Quiet)
            {
                string err_out = string("In this context, the code ") + getObserverName(typeObserver) + string(" does not "
                                        "correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L, err_out.c_str());
                //lua_pushnumber(L, 5);
                lua_call(L, 1, 0);
            }
            return 0;
        }

        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);

            if (cols.at(0).isNull() || cols.at(0).isEmpty())
            {
                if (execModes != Quiet)
                {
                    string err_out = string("Filename was not specified. Using default '") + string(qPrintable(DEFAULT_NAME));
                                            lua_getglobal(L, "customWarning");
                                            lua_pushstring(L, err_out.c_str());
                                            //lua_pushnumber(L, 5);
                                            lua_call(L, 1, 0);
                }
                obsLog->setFileName(DEFAULT_NAME + ".csv");
            }
            else
            {
                obsLog->setFileName(cols.at(0));
            }

            // caso nao seja definido, utiliza o default ";"
            if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet)
                {
                    string err_out = string("Separator not defined, using \";\".");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
                obsLog->setSeparator();
            }
            else
            {
                obsLog->setSeparator(cols.at(1));
            }

            lua_pushnumber(luaL, obsId);
            return 1;
        }

        if (obsText)
        {
            obsText->setAttributes(obsAttribs);
            lua_pushnumber(luaL, obsId);
            return 1;
        }

        if (obsTable)
        {
            if ((cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
                || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet)
                {
                    string err_out = string("Column title not defined.");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L, err_out.c_str());
                    //lua_pushnumber(L, 5);
                    lua_call(L, 1, 0);
                }
            }

            obsTable->setColumnHeaders(cols);
            obsTable->setAttributes(obsAttribs);

            lua_pushnumber(luaL, obsId);
            return 1;
        }

        //if (obsGraphic)
        //{
        //    obsGraphic->setLegendPosition();

        //    // Takes titles of three first locations
        //    obsGraphic->setTitles(cols.at(0), cols.at(1), cols.at(2));   
        //    cols.removeFirst(); // remove graphic title
        //    cols.removeFirst(); // remove axis x title
        //    cols.removeFirst(); // remove axis y title

        //    // Splits the attribute labels in the cols list
        //    obsGraphic->setAttributes(obsAttribs, cols.takeFirst().split(";", QString::SkipEmptyParts),
        //        obsParams, cols);

        //    lua_pushnumber(luaL, obsId);
        //    return 1;
        //}

        //if(obsUDPSender)
        //{
        //    obsUDPSender->setAttributes(obsAttribs);

        //    // if (cols.at(0).isEmpty())
        //    if (cols.isEmpty())
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("Warning: Port not defined.");
        //    }
        //    else
        //    {
        //        obsUDPSender->setPort(cols.at(0).toInt());
        //    }

        //    // broadcast
        //    if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()))
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("Warning: Observer will send to broadcast.");
        //        obsUDPSender->addHost(BROADCAST_HOST);
        //    }
        //    else
        //    {
        //        // multicast or unicast
        //        for(int i = 1; i < cols.size(); i++){
        //            if (! cols.at(i).isEmpty())
        //                obsUDPSender->addHost(cols.at(i));
        //        }
        //    }
        //    lua_pushnumber(luaL, obsId);
        //    return 1;
        //}       

        //if(obsTCPSender)
        //{
        //    quint16 port = (quint16) DEFAULT_PORT;
        //    obsTCPSender->setAttributes(obsAttribs);

        //    // if (cols.at(0).isEmpty())
        //    if (cols.isEmpty())
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("Warning: Port not defined.");
        //    }
        //    else
        //    {
        //        port = (quint16) cols.at(0).toInt();
        //    }

        //    // broadcast
        //    if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()))
        //    {
        //        if (! QUIET_MODE)
        //            qWarning("Warning: Observer will send to broadcast.");
        //        obsTCPSender->addHost(LOCAL_HOST);
        //    }
        //    else
        //    {
        //        // multicast or unicast
        //        for(int i = 1; i < cols.size(); i++)
        //        {
        //            if (! cols.at(i).isEmpty())
        //                obsTCPSender->addHost(cols.at(i));
        //        }
        //    }
        //    obsTCPSender->connectTo(port);
        //    lua_pushnumber(luaL, obsId);
        //    return 1;
        //}
    }
    else //     if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        QStringList obsParams, obsParamsAtribs; // parameters/attributes of the legend

        bool getObserverId = false, isLegend = false;
        int obsId = -1;

        AgentObserverMap *obsMap = 0;
        AgentObserverImage *obsImage = 0;    

        // Retrieves the parameters
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            // Retrieves the observer map ID
            if ((lua_isnumber(luaL, -1) && (! getObserverId)))
            {
                obsId = luaL_checknumber(luaL, -1);
                getObserverId = true;
                isLegend = true;
            }

            // retrieves the celular space
            if (lua_istable(luaL, -1))
            {
                int paramTop = lua_gettop(luaL);

                lua_pushnil(luaL);
                while(lua_next(luaL, paramTop) != 0)
                {
                    if (isudatatype(luaL, -1, "TeCellularSpace"))
                    {
                        cellSpace = Luna<luaCellularSpace>::check(L, -1);
                    }
                    else
                    {
                        if (isLegend)
                        {
                            QString key = luaL_checkstring(luaL, -2);

                            obsParams.push_back(key);

                            bool boolAux;
                            double numAux;
                            QString strAux;

                            switch(lua_type(luaL, -1))
                            {
                            case LUA_TBOOLEAN:
                                boolAux = lua_toboolean(luaL, -1);
                                break;

                            case LUA_TNUMBER:
                                numAux = luaL_checknumber(luaL, -1);
                                obsParamsAtribs.push_back(QString::number(numAux));
                                break;

                            case LUA_TSTRING:
                                strAux = luaL_checkstring(luaL, -1);
                                obsParamsAtribs.push_back(QString(strAux));
                                break;

                            default:
                                break;
                            }
                        } // isLegend
                    }
                    lua_pop(luaL, 1);
                }
            }
            lua_pop(luaL, 1);
        }

        QString errorMsg = QString("Error: The Observer ID ") + QString(obsId) + QString(" was not found. ") +
                          QString("Check the declaration of this observer.");

        if (! cellSpace)
        {
            lua_getglobal(L, "customError");
            lua_pushstring(L, errorMsg.toLatin1().data());
            //lua_pushnumber(L, 5);
            lua_call(L, 1, 0);
        }

        if (typeObserver == TObsMap)
        {
            obsMap = (AgentObserverMap *)cellSpace->getObserver(obsId);

            if (! obsMap)
            {
                lua_getglobal(L, "customError");
                lua_pushstring(L, errorMsg.toLatin1().data());
                //lua_pushnumber(L, 5);
                lua_call(L, 1, 0);
            }

            obsMap->registry(this);
        }
        else
        {
            obsImage = (AgentObserverImage *)cellSpace->getObserver(obsId);

            if (! obsImage)
            {
                lua_getglobal(L, "customError");
                lua_pushstring(L, errorMsg.toLatin1().data());
                //lua_pushnumber(L, 5);
                lua_call(L, 1, 0);
            }

            obsImage->registry(this);
        }

        QStringList allAttribs, obsAttribs;
        QByteArray neighName(" (");
        neighName.append(CellNeighborhood::getID().c_str());
        neighName.append(")");

        // Retrieves the attributes
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            const char * key = luaL_checkstring(luaL, -1);
            obsAttribs.push_back(key + neighName);
            lua_pop(luaL, 1);
        }
        
        for(int i = 0; i < obsAttribs.size(); i++)
        {
            if (! observedAttribs.contains(obsAttribs.at(i)))
                // observedAttribs.push_back(obsAttribs.at(i));
                observedAttribs.insert(obsAttribs.at(i), "");
        }

        if (typeObserver == TObsMap)
        {
            // to set the values of the agent attributes,
        	// redefine the type of attributes in the super class ObserverMap
            obsMap->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsNeighborhood);
            obsMap->setSubjectAttributes(obsAttribs, getId());
        }
        else
        {
            obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsNeighborhood);
            obsImage->setSubjectAttributes(obsAttribs, getId());
        }
        lua_pushnumber(luaL, obsId);
        return 1;
    }

    // qFatal(".......");
    return 0;
 }

 int luaNeighborhood::notify(lua_State *)
 {
    double time = luaL_checknumber(luaL, -1);
    NeighborhoodSubjectInterf::notify(time);
    return 0;
 }
  
const TypesOfSubjects luaNeighborhood::getType() const
{
    return subjectType;
}

#ifdef TME_BLACK_BOARD

QDataStream& luaNeighborhood::getState(QDataStream& in, Subject *, int /*observerId*/, const QStringList &attribs)
{
#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
#endif

    int obsCurrentState = 0; //serverSession->getState(observerId);
    QByteArray content;

    switch(obsCurrentState)
    {
        case 0:
            content = getAll(in, attribs);
            // serverSession->setState(observerId, 1);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
            content = getChanges(in, attribs);
            // serverSession->setState(observerId, 0);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}


#else // TME_BLACK_BOARD

QDataStream& luaNeighborhood::getState(QDataStream& in, Subject *, int observerId, const QStringList &attribs)
{
#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
#endif

    int obsCurrentState = 0; //serverSession->getState(observerId);
    QByteArray content;

    switch(obsCurrentState)
    {
        case 0:
            content = getAll(in, observerId, attribs);
            // serverSession->setState(observerId, 1);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
            content = getChanges(in, observerId, attribs);
            // serverSession->setState(observerId, 0);
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#endif

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaNeighborhood::pop(lua_State *, const QStringList &attribs, 
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
    bool valueChanged = false;
    // char result[20];
    double num = 0;
    ObserverDatagramPkg::RawAttribute *raw = 0;

    luaCell *cell = (luaCell *) CellNeighborhood::getParent();
    if (cell)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        ObserverDatagramPkg::SubjectAttribute *cellSubj = currSubj->add_internalsubject();
                        
        cellSubj->set_id(cell->getId());
        cellSubj->set_type(ObserverDatagramPkg::TObsCell); 
        cellSubj->set_attribsnumber(cellSubj->rawattributes_size());
        cellSubj->set_itemsnumber(cellSubj->internalsubject_size());
	}

    CellNeighborhood::iterator itAux = CellNeighborhood::begin();
    luaCell *neighbor = 0;
	while(itAux != CellNeighborhood::end())
	{
        neighbor = (luaCell *) itAux->second;
        CellIndex cellIdx = itAux->first;
        num = CellNeighborhood::getWeight(cellIdx); // gets the neighbor weight

        if (neighbor) // (observedAttribs.value(key) != valueTmp)
        {
            if ((parentSubj) && (! currSubj))
                currSubj = parentSubj->add_internalsubject();

            ObserverDatagramPkg::SubjectAttribute *cellNeighborSubj = currSubj->add_internalsubject();

            raw = cellNeighborSubj->add_rawattributes();


            raw->set_key("weight");
            // raw->set_key(attribs.first().toLatin1().constData());
            raw->set_number(num);

            cellNeighborSubj->set_id(neighbor->getId());
            cellNeighborSubj->set_type(ObserverDatagramPkg::TObsCell); 
            cellNeighborSubj->set_attribsnumber(cellNeighborSubj->rawattributes_size());
            cellNeighborSubj->set_itemsnumber(cellNeighborSubj->internalsubject_size());

            valueChanged = true;
            // observedAttribs.insert(key, valueTmp);
		}
        itAux++;
    }

    
    if (valueChanged)
	{
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        // id
        currSubj->set_id(getId());

        // subjectType
        currSubj->set_type(ObserverDatagramPkg::TObsNeighborhood);

        // #attrs
        currSubj->set_attribsnumber(currSubj->rawattributes_size());

        // #elements
        currSubj->set_itemsnumber(currSubj->internalsubject_size());

#ifdef DEBUG_OBSERVER
            std::cout << currSubj->DebugString();
            std::cout.flush();
#endif

        if (! parentSubj)
        {
            QByteArray byteArray(currSubj->SerializeAsString().c_str(), currSubj->ByteSize());
            return byteArray;
        }
    }

//#ifdef DEBUG_OBSERVER
//    dumpRetrievedState(msg, "out_protocol");
//#endif

    return QByteArray();
}

QByteArray luaNeighborhood::getAll(QDataStream &, const QStringList &attribs)
{
	Reference<luaNeighborhood>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute neighSubj;
    return pop(luaL, attribs, &neighSubj, 0);
}

QByteArray luaNeighborhood::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}


#else

QByteArray luaNeighborhood::pop(lua_State *, const QStringList &)
{
    return QByteArray();
}

QByteArray luaNeighborhood::getAll(QDataStream& /*in*/, int /*observerId*/, const QStringList& /*attribs*/)
{
    return QByteArray();
}

QByteArray luaNeighborhood::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#endif

int luaNeighborhood::kill(lua_State *)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = NeighborhoodSubjectInterf::kill(id);
    if (! result)
    {
        if (cellSpace)
        {
            Observer *obs = cellSpace->getObserverById(id);

            if (obs)
            {        
                if (obs->getType() == TObsMap)
                    result = ((AgentObserverMap *)obs)->unregistry(this);
                else
                    result = ((AgentObserverImage *)obs)->unregistry(this);
            }
        }
    }
    lua_pushboolean(luaL, result);
    return 1;
}
