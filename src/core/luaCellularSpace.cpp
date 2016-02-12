/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright ? 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaCellularSpace.cpp
\brief This file contains implementations for the luaCellularSpace objects.
\author Tiago Garcia de Senna Carneiro
\author Ant?nio Rodrigues
\author Rodrigo Reis Pereira
*/

#include "luaCellIndex.h"
#include "luaCellularSpace.h"
#include "luaNeighborhood.h"
#include "terrameGlobals.h"

// Observadores
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/agentObserverMap.h"
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/observerShapefile.h"

// #define DISABLE_SHAPE_FILE
#ifndef DISABLE_SHAPE_FILE
#include "../../dependencies/shapelib/shapefil.h"
#include "../../dependencies/shapelib/findCentroid.h"
#endif

#include "luaUtils.h"

// #include "terralibFacade.h" // issue #319
// #include "cellularSpaceMapper.h" // issue #319
// #include "cellMapper.h" // issue #319

#include <fstream>
#include <algorithm>

#ifndef WIN32
#define stricmp strcasecmp
#define strnicmp strncasecmp
#endif

#ifndef luaL_checkbool
#define luaL_checkbool(L, i) (lua_isboolean(L, i) ? lua_toboolean(L, i) : luaL_checkint(L, i))
#endif


///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L; 

///< true - TerrME runs in verbose mode and warning messages to the user; 
// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

using namespace TerraMEObserver;

/// constructor
luaCellularSpace::luaCellularSpace(lua_State *L) 
{  
    dbType = "mysql";
    host = "localhost";
    dbName = "";
    user = "";
    pass = "";
    inputLayerName = "";
    inputThemeName = "";
    // Antonio
    luaL = L;
    subjectType = TObsCellularSpace;
    observedAttribs.clear();
    port = -1;
}

int luaCellularSpace::setPort(lua_State *L){
    int p =   lua_tointeger(L, -1);
    port = p;
    return 0;
}

/// Sets the database type: MySQL, ADO, etc.
int luaCellularSpace::setDBType(lua_State *L )
{
    dbType =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the host name.
int luaCellularSpace::setHostName(lua_State *L )
{
    host =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the database name.
int luaCellularSpace::setDBName(lua_State *L )
{
    dbName =  string(lua_tostring(L, -1));
    return 0;
}

/// Get the database name.
int luaCellularSpace::getDBName(lua_State *L)
{
    lua_pushstring(L, this->dbName.c_str());
    return 1;
}

/// Sets the user name.
int luaCellularSpace::setUser(lua_State *L )
{
    user = string(lua_tostring(L, -1));
    return 0;
}

/// Sets the password name.
int luaCellularSpace::setPassword(lua_State *L )
{
    pass =  string(lua_tostring(L, -1));
    return 0;
}

/// Sets the geographical database layer name 
int luaCellularSpace::setLayer(lua_State *L )
{
    inputLayerName = string(lua_tostring(L, -1));
    return 0;
}

/// Sets the geographical database theme name
int luaCellularSpace::setTheme(lua_State *L)
{
    inputThemeName = string(lua_tostring(L, -1));
    return 0;
}

/// Clears the cellular space attributes names
int luaCellularSpace::clearAttrName(lua_State *)
{
    attrNames.clear();
    return 0;
}

/// Adds a new attribute name to the CellularSpace attributes table used in the load function
int luaCellularSpace::addAttrName( lua_State *L)
{
    attrNames.push_back( lua_tostring(L, -1) );
    return 0;
}

/// Sets the SQL WHERE CLAUSE to the string received as parameter
int luaCellularSpace::setWhereClause(lua_State *L)
{
    whereClause =  string(lua_tostring(L,-1));
    return 0;
}

/// Clear all luaCellularSpace object content (cells)
int luaCellularSpace::clear(lua_State *)
{
    CellularSpace::clear();
    return 0;
}

/// Adds a the luaCell received as parameter to the luaCellularSpace object
/// parameters: x, y, luaCell
int luaCellularSpace::addCell( lua_State *L)	 
{ 
    CellIndex indx;
    luaCell *cell = Luna<luaCell>::check(L,-1);
    indx.second = luaL_checknumber(L, -2);
    indx.first = luaL_checknumber(L, -3);
    CellularSpace::add( indx, cell);

    return 0;
}

/// Gets the luaCell object within the CellularSpace identified by the coordenates received as parameter
/// parameters: cell index
int luaCellularSpace::getCell(lua_State *L)
{  
    luaCellIndex *cI = Luna<luaCellIndex>::check(L, -1);
    CellIndex cellIndex; cellIndex.first = cI->x; cellIndex.second = cI->y;
    luaCell *cell = ::findCell( this, cellIndex );
    if( cell != NULL )
        cell->getReference(L);
    else
        lua_pushnil( L );
    return 1;
}

/// Returns the number of cells of the CellularSpace object
/// no parameters
int luaCellularSpace::size(lua_State* L)
{
    lua_pushnumber(L, CellularSpace::size());
    return 1;
}

/// Sets the name of the TerraLib layer related to the CellularSpace object
/// parameter: layerName is a string containing the new layerName
/// \author Raian Vargas Maretto
void luaCellularSpace::setLayerName( string layerName )
{
    this->inputLayerName = layerName;
}

/// Gets the name of the TerraLib layer related to the CellularSpace object
/// no parameters
/// \author Raian Vargas Maretto
string luaCellularSpace::getLayerName( )
{
    return this->inputLayerName;
}

/// Gets the name of the TerraLib layer related to the CellularSpace object
/// parameter: a pointer to the Lua Stack
/// \author Raian Vargas Maretto
int luaCellularSpace::getLayerName(lua_State *L)
{
    lua_pushstring(L, this->inputLayerName.c_str());
    return 1;
}

/// Creates several types of observers to the luaCellularSpace object
/// parameters: observer type, observeb attributes table, observer type parameters
int luaCellularSpace::createObserver(lua_State * luaL)
{
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    Reference<luaCellularSpace>::getReference(luaL);

    getSpaceDimensions = false;

    // flags para a definicao do uso de compressao
    // na transmissao de datagramas e da visibilidade
    // dos observadores Udp Sender e Image
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de atributos da celula
    int top = lua_gettop(luaL);

    // Nao modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, top - 5);

    //if (! lua_istable(luaL, top - 3) )
    //{
    //    qFatal("\nError: The Attribute table not found. Incorrect sintax.\n");
    //    return -1;
    //}
    
    QStringList allCellSpaceAttribs, allCellAttribs, obsAttribs;
    QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda
    QStringList imagePath; //diretorio onde as imagens do ObsImage serao salvas
    
    const char *strAux;
    double numAux = -1;
    //int cellsNumber = 0;
    bool boolAux = false;

    lua_pushnil(luaL);
    while(lua_next(luaL, top) != 0)
    {
        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            QString key = luaL_checkstring(luaL, -2);
            allCellSpaceAttribs.append(key);

            if (key == "cells")
            {
                int cellstop = lua_gettop(luaL);
                int stop = false;

                lua_pushnil(luaL);
                while ((! stop) && (lua_next(luaL, cellstop) != 0))
                {
                    int cellTop = lua_gettop(luaL);
                    // lua_pushstring(luaL, "cObj_");
                    lua_pushnumber(luaL, 1);
                    lua_gettable(luaL, cellTop);

                    lua_pushnil(luaL);
                    while(lua_next(luaL, cellTop) != 0)
                    {
                        if (lua_type(luaL, -2) == LUA_TSTRING)
                            allCellAttribs.append(luaL_checkstring(luaL, -2));
                        stop = true;
                        lua_pop(luaL, 1);
                    }
                    lua_pop(luaL, 1); // lua_pushnumber/lua_pushstring
                    lua_pop(luaL, 1); // lua_pushnil
                    lua_pop(luaL, 1); // breaks the loop
                }
            } // (key == "cells")
        } // lua_type == LUA_TSTRING
        lua_pop(luaL, 1);
    }

    // Recupera a tabela de parametros
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 2) != 0)
    {
        lua_pushstring(luaL, "Minimum");
        lua_gettable(luaL, -1);

        //********************************************************************************
        int firstLegPos = lua_gettop(luaL);
        int iAux = 1;

        // percorre cada item da tabela parametros
        lua_pushnil(luaL);

        if (! lua_istable(luaL, firstLegPos - 1) )
        {
            // ---- Observer Image: Recupera o path/nome dos arquivos de imagem
            if (typeObserver == TObsImage)
            {
                if (lua_type(luaL, firstLegPos - 1) == LUA_TSTRING)
                {
                    // recupera o path para o arquivo
                    QString k( luaL_checkstring(luaL, firstLegPos - 1));
                    imagePath.push_back(k);
                }
                else
                {
                    if (lua_type(luaL, firstLegPos - 1) == LUA_TBOOLEAN)
                        obsVisible = lua_toboolean(luaL, firstLegPos - 1);
                }
                iAux = 4;
            }
            else
            {
                // Recupera os valores da tabela parametros
                if (lua_type(luaL, firstLegPos - 1) == LUA_TSTRING)
                    obsParamsAtribs.append( luaL_checkstring(luaL, firstLegPos - 1) );
            }
            lua_pop(luaL, 1); // lua_pushnil
        }
        else
        {
            while (lua_next(luaL, firstLegPos - iAux) != 0)
            {
                QString key;

                if (lua_type(luaL, -2) == LUA_TSTRING)
                {
                    key = luaL_checkstring(luaL, -2);
                }
                else
                {
                    if (lua_type(luaL, -2) == LUA_TNUMBER)
                    {
                        char aux[100];
                        double number = luaL_checknumber(luaL, -2);
                        sprintf(aux, "%g", number);
                        key = aux;
                    }
                }
                obsParams.push_back(key);

                switch( lua_type(luaL, -1) )
                {
                case LUA_TBOOLEAN:
                    boolAux = lua_toboolean(luaL, -1);
                    //obsParamsAtribs.push_back(boolAux ? "true" : "false");
                    // Recupera o valor do paramentro
                    if (key == "compress")
                        compressDatagram = boolAux;

                    // Recupera o valor do paramentro
                    if (key == "visible")
                        obsVisible = boolAux;
                    break;

                case LUA_TNUMBER:
                    numAux = luaL_checknumber(luaL, -1);
                    obsParamsAtribs.push_back(QString::number(numAux));
                    break;

                case LUA_TSTRING:
                    strAux = luaL_checkstring(luaL, -1);
                    obsParamsAtribs.push_back(strAux);
                    break;

                case LUA_TNIL:
                case LUA_TTABLE:
                default:
                    break;
                }
                lua_pop(luaL, 1); // lua_pushnil
            }
        }
        //********************************************************************************
        lua_pop(luaL, 1); // lua_pushstring
        lua_pop(luaL, 1); // lua_pushnil
    }

    // Recupera a tabela de atributos
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 3) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );
        obsAttribs.push_back(key);
        lua_pop(luaL, 1);
    }

    if ((typeObserver == TObsImage) || (typeObserver == TObsMap) || (typeObserver == TObsShapefile))
    {
        // LEGEND_ITENS esta definido dentro do observer.h
        if (obsAttribs.size() * LEGEND_ITENS < obsParams.size())
        {
        }
    }

    QList<int> obsDim;

    // Recupera a tabela de dimensoes
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 4) != 0)
    {
        int v = luaL_checknumber(luaL, -1);

        obsDim.push_back(v);
        lua_pop(luaL, 1);
    }

    int width, height;
    if (! obsDim.isEmpty())
    {
        width = obsDim.at(0);
        height = obsDim.at(1);
        if (( width > 0) && (height > 0))
            getSpaceDimensions = true;
    }

    if ((typeObserver == TObsMap) || (typeObserver == TObsImage) || (typeObserver == TObsShapefile))
    {
        if (obsAttribs.isEmpty())
        {
            obsAttribs = allCellAttribs;
            observedAttribs = allCellAttribs;
        }
        else
        {
            // posicao da celula no espaco celular
            obsAttribs.push_back("x");
            obsAttribs.push_back("y");
            if(typeObserver == TObsShapefile) obsAttribs.push_back("objectId_");

            // Verifica se o atributo informado realmente existe na celula
            for (int i = 0; i < obsAttribs.size(); i++)
            {
                // insere na lista de atributos do cellspace o atributo recuperado
                if (! observedAttribs.contains(obsAttribs.at(i)) )
                    observedAttribs.push_back(obsAttribs.at(i));

                if (! allCellAttribs.contains(obsAttribs.at(i)) )
                {
                  
                    string err_out = string("Error: Attribute name '" ) + string (qPrintable(obsAttribs.at(i))) + string("' not found.");
					lua_getglobal(L, "customError");
					lua_pushstring(L,err_out.c_str());
					lua_pushnumber(L,5);
					lua_call(L,2,0);
                    return 0;
                }
            }
        }
    }
    else
    {
        if (obsAttribs.isEmpty())
        {
            obsAttribs = allCellSpaceAttribs;
            observedAttribs = allCellSpaceAttribs;
        }
        else
        {
            for (int i = 0; i < obsAttribs.size(); i++)
            {
                // insere na lista de atributos do cellspace o atributo recuperado
                if (! observedAttribs.contains(obsAttribs.at(i)) )
                    observedAttribs.push_back(obsAttribs.at(i));
                
                if (! allCellSpaceAttribs.contains(obsAttribs.at(i)) )
                {
                    string err_out = string("Error: Attribute name '") + string(qPrintable(obsAttribs.at(i))) + string("' not found or not belongs to this subject.");
                    lua_getglobal(L, "customError");
                    lua_pushstring(L,err_out.c_str());
                    lua_pushnumber(L,5);
                    lua_call(L,2,0);

                    return 0;
                }
            }
        }
    }

    AgentObserverMap *obsMap = 0;
    ObserverUDPSender *obsUDPSender = 0;
    ObserverTextScreen *obsText = 0;
    ObserverTable *obsTable = 0;
    ObserverGraphic *obsGraphic = 0;
    ObserverLogFile *obsLog = 0;
    ObserverShapefile *obsShape = 0;

    int obsId = -1;

    switch (typeObserver)
    {
    case TObsTextScreen:
        obsText = (ObserverTextScreen*)
                CellSpaceSubjectInterf::createObserver(TObsTextScreen);
        if (obsText)
        {
            obsId = obsText->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;

    case TObsLogFile:
        obsLog = (ObserverLogFile*)
                CellSpaceSubjectInterf::createObserver(TObsLogFile);
        if (obsLog)
        {
            obsId = obsLog->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;

    case TObsTable:
        obsTable = (ObserverTable *)
                CellSpaceSubjectInterf::createObserver(TObsTable);
        if (obsTable)
        {
            obsId = obsTable->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;

    case TObsDynamicGraphic:
        obsGraphic = (ObserverGraphic *)
                CellSpaceSubjectInterf::createObserver(TObsDynamicGraphic);

        if (obsGraphic)
        {
            obsGraphic->setObserverType(TObsDynamicGraphic);
            obsId = obsGraphic->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;

    case TObsGraphic:
        obsGraphic = (ObserverGraphic *)
                CellSpaceSubjectInterf::createObserver(TObsGraphic);
        if (obsGraphic)
        {
            obsId = obsGraphic->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;

    case TObsMap:
        obsMap = (AgentObserverMap *) CellSpaceSubjectInterf::createObserver(TObsMap);
        if (obsMap)
        {
            obsId = obsMap->getId();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;
    case TObsShapefile:
    {
        obsShape = (ObserverShapefile*)CellSpaceSubjectInterf::createObserver(TObsShapefile);
        if(obsShape)
        {
            obsShape->loadShape(dbName);
            obsId = obsShape->getId();
            //if (obsVisible)
            //obsShape->show();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;
    }
    case TObsUDPSender:
        obsUDPSender = (ObserverUDPSender *) CellSpaceSubjectInterf::createObserver(TObsUDPSender);
        if (obsUDPSender)
        {
            obsId = obsUDPSender->getId();
            obsUDPSender->setCompressDatagram(compressDatagram);

            if (obsVisible)
                obsUDPSender->show();
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
        break;
    default:
        if (execModes != Quiet )
        {
            qWarning("Warning: In this context, the code '%s' does not "
                     "correspond to a valid type of Observer.",  getObserverName(typeObserver) );
        }
        return 0;
    }

    if (obsLog)
    {
        obsLog->setAttributes(obsAttribs);
        obsLog->setFileName(obsParamsAtribs.at(0));
        obsLog->setSeparator(obsParamsAtribs.at(1));
        obsLog->setWriteMode(obsParamsAtribs.at(2));

        lua_pushnumber(luaL, obsId);
        lua_pushlightuserdata(luaL, (void*) obsLog);

        return 2;
    }

    if (obsText)
    {
        obsText->setAttributes(obsAttribs);
        lua_pushnumber(luaL, obsId);
        lua_pushlightuserdata(luaL, (void*) obsText);

        return 2;
    }

    if (obsTable)
    {
        obsTable->setColumnHeaders(obsParamsAtribs);
        obsTable->setAttributes(obsAttribs);

        lua_pushnumber(luaL, obsId);
        lua_pushlightuserdata(luaL, (void*) obsTable);

        return 2;
    }

    if (obsGraphic)
    {
        obsGraphic->setLegendPosition();

        // Takes titles of three first locations
        obsGraphic->setTitles(obsParamsAtribs.at(0), obsParamsAtribs.at(1), obsParamsAtribs.at(2));
        obsParamsAtribs.removeFirst(); // remove graphic title
        obsParamsAtribs.removeFirst(); // remove axis x title
        obsParamsAtribs.removeFirst(); // remove axis y title
        
        // Splits the attribute labels in the cols list
        obsGraphic->setAttributes(obsAttribs, obsParamsAtribs.takeFirst()
                                  .split(";", QString::SkipEmptyParts), obsParams, obsParamsAtribs);

        lua_pushnumber(luaL, obsId);
		lua_pushlightuserdata(luaL, (void*) obsGraphic);

		return 2;
    }

    if (obsMap)
    {
        if (getSpaceDimensions)
            obsMap->setCellSpaceSize(width, height);

        ((ObserverMap *)obsMap)->setAttributes(obsAttribs, obsParams, obsParamsAtribs);
        observersHash.insert(obsMap->getId(), obsMap);
        lua_pushnumber(luaL,  obsMap->getId());

		lua_pushlightuserdata(luaL, (void*) obsMap);

		return 2;
    }
    
    if (obsShape)
    {
        ((ObserverShapefile *)obsShape)->setAttributes(obsAttribs, obsParams, obsParamsAtribs);
        observersHash.insert(obsShape->getId(), obsShape);
        lua_pushnumber(luaL,  obsShape->getId());
        return 1;
    }

    if (obsUDPSender)
    {
        obsUDPSender->setAttributes(obsAttribs);

        obsUDPSender->setPort(obsParamsAtribs.at(0).toInt());

        // broadcast
        if ((obsParamsAtribs.size() == 1)
                || ((obsParamsAtribs.size() == 2) && obsParamsAtribs.at(1).isEmpty()) )
        {
            obsUDPSender->addHost(BROADCAST_HOST);
        }
        else
        {
            // multicast or unicast
            for(int i = 1; i < obsParamsAtribs.size(); i++)
            {
                if (! obsParamsAtribs.at(i).isEmpty())
                    obsUDPSender->addHost(obsParamsAtribs.at(i));
            }
        }

        lua_pushnumber(luaL, obsId);
        lua_pushlightuserdata(luaL, (void*) obsUDPSender);

        return 2;
    }

    return 0;
}

const TypesOfSubjects luaCellularSpace::getType()
{
    return subjectType;
}

/// Notifies the Observer objects about changes in the luaCellularSpace internal state
int luaCellularSpace::notify(lua_State * )
{
    double time = luaL_checknumber(L, -1);
    CellSpaceSubjectInterf::notify(time);
    return 0;
}

/// Returns the Agent Map Observers linked to this cellular space
Observer * luaCellularSpace::getObserver(int id)
{
    if (observersHash.contains(id))
        return observersHash.value(id);
    else
        return NULL;
}

QString luaCellularSpace::getAll(QDataStream& /*in*/, int /*observerId*/ , QStringList &attribs)
{
    Reference<luaCellularSpace>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaCellularSpace::getChanges(QDataStream& in, int observerId , QStringList &attribs)
{
    return getAll(in, observerId, attribs);
}

//------------
/// Serializes the luaCellularSpace object to the Observer objects
#ifdef TME_BLACK_BOARD
QDataStream& luaCellularSpace::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaCellularSpace::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
#endif
{
    int obsCurrentState = 0; //serverSession->getState(observerId);
    QString content;

    switch(obsCurrentState)
    {
    case 0:
#ifdef TME_BLACK_BOARD
        content = getAll(in, observerId, observedAttribs);
#else
        content = getAll(in, observerId, attribs);
#endif

        // serverSession->setState(observerId, 1);
        //if (execModes == Quiet )
        // 	qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
        break;

    case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif

        // serverSession->setState(observerId, 0);
        //if (execModes != Quiet )
        // 	qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

QString luaCellularSpace::pop(lua_State *luaL, QStringList& attribs)
{
    QString msg;

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    // recupero a referencia na pilha lua
    Reference<luaCellularSpace>::getReference(luaL);

    int cellSpacePos = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements;

    lua_pushnil(luaL);
    while(lua_next(luaL, cellSpacePos ) != 0)
    {
        key = QString(luaL_checkstring(luaL, -2));

        if ((attribs.contains(key)) || (key == "cells"))
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch( lua_type(luaL, -1) )
            {
            case LUA_TBOOLEAN:
                attrs.append(QString::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString::number( lua_toboolean(luaL, -1)));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                doubleToQString(num, text, 20);
                attrs.append(QString::number(TObsNumber));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(text);
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TSTRING:
                text = QString(luaL_checkstring(luaL, -1));
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append( (text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text) );
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TTABLE:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(TB): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);

                // Recupera a tabela de cells e delega a cada
                // celula sua serializacao
                // if(key == "cells")
                //{
                int top = lua_gettop(luaL);

                lua_pushnil(luaL);
                while(lua_next(luaL, top) != 0)
                {
                    int cellTop = lua_gettop(luaL);
                    lua_pushstring(luaL, "cObj_");
                    lua_gettable(luaL, cellTop);

                    luaCell*  cell;
                    cell = (luaCell*)Luna<luaCell>::check(L, -1);
                    lua_pop(luaL, 1);

                    // luaCell->pop(...) requer uma celula no topo da pilha
                    QString cellMsg = cell->pop(L, attribs);
                    elements.append(cellMsg);
                    elementCounter++;

                    lua_pop(luaL, 1);
                }
                break;
                //}
                //break;
            }

            case LUA_TUSERDATA	:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(UD): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }

            case LUA_TFUNCTION:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(FT): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }

            default:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                attrs.append(QString::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(O): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }
            }
        }
        lua_pop(luaL, 1);
    }

    // #attrs
    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );

    // #elements
    msg.append(QString::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(attrs);

    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

int luaCellularSpace::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = CellSpaceSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

/// Loads the CellularSpace from a Shapefile.
int luaCellularSpace::loadShape(lua_State *L)
{
#ifndef DISABLE_SHAPE_FILE
    string filename = dbName;

//    CellularSpaceMapper cellularSpace = TerraLibFacade::getInstance()->getCellularSpace(filename);

//    vector<CellMapper> cells = cellularSpace.getCells();

//    if (cells.size() > 0)
//    {
//        if (sendCells(cells))
//        {
//            return 5;
//        }
//    }
    
//    return 0;

    //open a shapefile
	int lastIndex = filename.find_last_of(".");
	string filePrefix = filename.substr(0, lastIndex); //TeGetName(filename.c_str()); // issue #319
    string shpFileN = filePrefix + ".shp";
    string dbfFileN = filePrefix + ".dbf";
    SHPHandle hSHP = SHPOpen(shpFileN.c_str(),"rb");
    DBFHandle hDBF = DBFOpen(dbfFileN.c_str(), "rb");
    
    if(!hSHP || !hDBF)
    {
        qFatal("It was not possible to open the shapefile %s", dbName.c_str());
    }

    double minBound[4];
    double maxBound[4];
    int shapeType;
    int nEntities;
    SHPGetInfo(hSHP, &nEntities, &shapeType, minBound, maxBound);
    int fieldCount = DBFGetFieldCount(hDBF);
    int shapeCount = DBFGetRecordCount(hDBF);
    
    // puts a table for represent the whole cellular space on the top of the stack
    lua_newtable(L);
    int tabPos = lua_gettop(L);
    
    long int cont = 0;
    
    //get a shape size
    
    double width__ = abs(maxBound[0] - minBound[0]);
    double height__ = abs(maxBound[1] - minBound[1]);

    double minCol = (int) (minBound[0] - minBound[0]);// + (long)width__;
    double maxCol = (int) (fabs(maxBound[0] - minBound[0]));
    double minLin = (int) (minBound[1] - minBound[1]);
    double maxLin = (int) (fabs(maxBound[1] - minBound[1]));
    
    //get a shape size
    
    // get all attributes name from shapefile

    vector<string> attrsHeaders;
    for(int i = 0; i < fieldCount; i++){
        char nome[256];
        int w,dec;
        DBFGetFieldInfo(hDBF,i,nome,&w,&dec);
        attrsHeaders.push_back(nome);
    }
    
    for(int i = 0; i < shapeCount; i++){

        // get lin and col from shapefile
        
        SHPObject *obj = SHPReadObject(hSHP,i);
        
        char cellId[20];
        strcpy(cellId,QString::number(i).toStdString().c_str());
        
        // get lin and col

        double dx = minBound[0]*-1;
        double dy = minBound[1]*-1;
        QPoint p = getCentroid(obj,dx,dy);
        
        int col = p.x();//min(max(minCol,xc),maxCol);
        int lin = p.y();//min(max(minLin,yc),maxLin);
        // puts the index for the new cell on the stack
        lua_pushnumber(L, cont + 1);

        // puts the Cell constructor on the top of the lua stack
        lua_getglobal(L, "Cell" );
        if( !lua_isfunction(L, -1))
        {
            string err_out = string("Error: Event constructor not found!\n");
            qFatal( "%s", err_out.c_str() );

            return 0;
        };
        
        // creates a attribute table for the new cell of the cellular space
        lua_newtable(L);

        // puts the cell's coords on the table
        lua_pushstring(L, "x");
        lua_pushnumber(L, col );
        lua_settable(L, -3);
        lua_pushstring(L, "y");
        lua_pushnumber(L, lin );
        lua_settable(L, -3);

        // puts id
        lua_pushstring(L, "id");
        lua_pushstring(L, cellId );
        lua_settable(L, -3);
        
        // puts the cell's objectId'
        lua_pushstring(L, "objectId_");
        lua_pushstring(L, cellId );
        lua_settable(L, -3);
        
        for(int j = 0; j < fieldCount; j++){
            string attr(DBFReadStringAttribute(hDBF,i,j));
            char typeAttr = DBFGetNativeFieldType(hDBF,j);
            lua_pushstring(L, attrsHeaders[j].c_str());
            switch(typeAttr)
            {
            case 'F': lua_pushnumber(L, atof(attr.c_str())); break;
            case 'N': lua_pushnumber(L, atoi(attr.c_str())); break;
            default: lua_pushstring(L, attr.c_str()); break;
            }
            lua_settable(L, -3);
        }
        
        // calls the Cell constructor
        
        if( lua_pcall( L, 1, 1, 0) != 0 )
        {
            cont++;
            return 0;
        }
        
        lua_settable(L, tabPos);

        cont++;
        SHPDestroyObject(obj);
    }
    
    lua_pushnumber( L, minCol );
    lua_pushnumber( L, minLin );
    lua_pushnumber( L, maxCol );
    lua_pushnumber( L, maxLin );
    
    //put default legend
    
    //lua_pushnil(L);
    //lua_pushstring(L, "");
    
    SHPClose(hSHP);
    DBFClose(hDBF);
    
    return 5;

#else
    string err_out = string("Warning: Failed on load shapefile: Method is disabled in compilation time.");
    lua_getglobal(L, "customWarning");
    lua_pushstring(L,err_out.c_str());
    lua_pushnumber(L,5);
    lua_call(L,2,0);

    return 0;
#endif
    
}

// issue #319
//bool luaCellularSpace::sendCells(vector<CellMapper> cells)
//{
//    // puts a table for represent the whole cellular space on the top of the stack
//    lua_newtable(L);
//    int luaTopbPos = lua_gettop(L);
//
//    int minX = 0, minY = 0;
//    int maxX = 0, maxY = 0;
//    minX = cells.at(0).getX();
//    minY = cells.at(0).getY();
//
//    for (int i = 0; i < cells.size(); i++)
//    {
//        minX = min(cells.at(i).getX(), minX);
//        minY = min(cells.at(i).getY(), minY);
//        maxX = max(cells.at(i).getX(), maxX);
//        maxY = max(cells.at(i).getY(), maxY);
//
//        // puts the index for the new cell on the stack
//        lua_pushnumber(L, i + 1);
//
//        // puts the Cell constructor on the top of the lua stack
//        lua_getglobal(L, "Cell" );
//        if(!lua_isfunction(L, -1))
//        {
//            string err = string("Error: Event constructor not found.'");
//            returnsCustomError(L, 4, err);
//
//            return false;
//        };
//
//        // creates a attribute table for the new cell of the cellular space
//        lua_newtable(L);
//
//        // puts the cell's coords on the table
//        lua_pushstring(L, "x");
//        lua_pushnumber(L, cells.at(i).getX());
//        lua_settable(L, -3);
//        lua_pushstring(L, "y");
//        lua_pushnumber(L, cells.at(i).getY());
//        lua_settable(L, -3);
//
//        // puts the cell's id on the table
//        lua_pushstring(L, "id");
//        lua_pushstring(L, cells.at(i).getId().c_str());
//        lua_settable(L, -3);
//
//        // puts the cell's id on the table
//        lua_pushstring(L, "objectId_");
//        lua_pushstring(L, cells.at(i).getId().c_str());
//        lua_settable(L, -3);
//
//        vector<Attribute> attributes =
//                cells.at(i).getAttributes();
//        for (int a = 0; a < attributes.size(); a++)
//        {
//            lua_pushstring(L, attributes.at(a).getName().c_str());
//
//            switch(attributes.at(a).getType())
//            {
//                case Attribute::STRING:
//                case Attribute::DATETIME:
//                case Attribute::CHARACTER:
//                    lua_pushstring(L, attributes.at(a).getValue().c_str());
//                    break;
//
//                case Attribute::REAL:
//                    lua_pushnumber(L, atof(attributes.at(a).getValue().c_str()));
//                    break;
//
//                case Attribute::INT:
//                    lua_pushnumber(L, atoi(attributes.at(a).getValue().c_str()));
//                    break;
//
//                case Attribute::BLOB:
//                case Attribute::OBJECT:
//                case Attribute::UNKNOWN:
//                default:
//                    lua_pushstring(L, attributes.at(a).getValue().c_str());
//            }
//
//            lua_settable(L, -3);
//        }
//
//        // calls the Cell constructor
//        if(lua_pcall(L, 1, 1, 0) != 0)
//        {
//            return false;
//        }
//        // insert the new cell into the cellular space table
//        lua_settable(L, luaTopbPos);
//    }
//
//    // returns values to the attributes minCol, minRow, maxCol and maxRow
//    // of the lua cellularSpace
//    lua_pushnumber(L, minX);
//    lua_pushnumber(L, minY);
//    lua_pushnumber(L, maxX);
//    lua_pushnumber(L, maxY);
//
//    return true;
//}

int luaCellularSpace::saveShape(lua_State *L)
{
	string filename = dbName;
	int lastIndex = filename.find_last_of(".");
	string filePrefix = filename.substr(0, lastIndex); //string filePrefix = TeGetName(dbName.c_str()); // issue #319
    string dbfFileN = filePrefix + ".dbf";
    DBFHandle hDBF = DBFOpen(dbfFileN.c_str(), "rb+");
    if(hDBF == NULL) return 0;
    int top = lua_gettop(L);
    int cellId = lua_tonumber(L,top-3);
    string cellAttrName = lua_tostring(L,top-2);
    int index = DBFGetFieldIndex(hDBF,cellAttrName.c_str());
    if(index==-1) return 0; // attribute unknow
    int cellAttrType = lua_tonumber(L,top-4);
    if(cellAttrType==1){
        double cellAttrValue = lua_tonumber(L,top-1);
        DBFWriteDoubleAttribute(hDBF,cellId, index, cellAttrValue);
    }
    else if(cellAttrType==2){
        string cellAttrValue = lua_tostring(L,top-1);
        DBFWriteStringAttribute(hDBF,cellId-1, index, cellAttrValue.c_str());
    }

    DBFClose(hDBF);
    return 0;
}

/// Loads the CellularSpace from a TerraLib database.
int luaCellularSpace::load(lua_State *L)
{
// issue #319
//    try
//    {
//        if (TerraLibFacade::getInstance()->connect(TerraLibFacade::MYSQL, host, user, pass, dbName, 0))
//        {
//            CellularSpaceMapper cellularSpace;
//
//            if (inputLayerName.empty())
//            {
//                cellularSpace = TerraLibFacade::
//                            getInstance()->getCellularSpace(inputThemeName,
//                                                            attrNames, whereClause);
//
//                if (TerraLibFacade::getInstance()->getLastError() ==
//                         TerraLibFacade::NONERROR)
//                {
//                    setLayerName(cellularSpace.getLayerName());
//                }
//            }
//            else
//            {
//                cellularSpace = TerraLibFacade::
//                            getInstance()->getCellularSpace(inputLayerName, inputThemeName,
//                                                            attrNames, whereClause);
//            }
//
//            vector<CellMapper> cells = cellularSpace.getCells();
//
//            if (!cells.empty())
//            {
//
//                if (!sendCells(cells))
//                {
//                    return 0;
//                }
//                // carrega legendas do banco
//
////                QString dbLegend;
////                loadLegendsFromDatabase(db, inputTheme, dbLegend);
////                //qDebug() << dbLegend << "\n\n";
//
//
////                // debugging
////                //cout << dbLegend.toLatin1().constData() << endl; cout.flush();
////                //int response = -1;
////                if (! dbLegend1.isEmpty()) {
////                    //response = luaL_dostring(L, dbLegend.toLatin1().constData());
////                    lua_pushstring(L, dbLegend.toLatin1().constData());
////                }
////                else {
//                lua_pushstring(L, "");
////                }
//
//                return 6;
//            }
//            else
//            {
//                if (TerraLibFacade::getInstance()->getLastError() ==
//                        TerraLibFacade::DB_VERSION_ERROR)
//                {
//                    string err = TerraLibFacade::
//                            getInstance()->getLastErrorMessage();
//                    returnsCustomError(L, 5, err);
//                }
//                else if (TerraLibFacade::getInstance()->getLastError() ==
//                         TerraLibFacade::THEME_LOAD_ERROR)
//                {
//                    string err = string("Can't load input theme '") + string(inputThemeName) + string("'.");
//                    returnsCustomError(L, 4, err);
//                }
//                else if (TerraLibFacade::getInstance()->getLastError() ==
//                         TerraLibFacade::LAYER_LOAD_ERROR)
//                {
//                    string err = string("Can't load input layer '") + string(inputLayerName) + string("'.");
//                    returnsCustomError(L, 4, err);
//                }
//                else if (TerraLibFacade::getInstance()->getLastError() ==
//                         TerraLibFacade::UNKNOWN_ERROR)
//                {
//                    string err = "Unknown Error!";
//                    returnsCustomError(L, 4, err);
//                }
//                else if (TerraLibFacade::getInstance()->getLastError() ==
//                         TerraLibFacade::NONERROR)
//                {
//                    string err = "Unknown Error!";
//                    returnsCustomError(L, 4, err);
//                }
//
//                return 0;
//            }
//        }
//        else
//        {
//            string err = TerraLibFacade::
//                    getInstance()->getLastErrorMessage() + string(".");
//            returnsCustomError(L, 5, err);
//        }
//
//        /* TODO
//          - transformar dbLegend em membro da classe
//          - criar metodo  exportado ... para verificar a existencia de legenda
//          - criar metodo exportado para Lua para conter o resultado (legenda vinda do banco)
//          - antes inferir legenda para observer verifica se existe legenda disponivel no espaco celular carregado
//
//        */
//    }
//    catch(...)
//    {
//        string err = string("Error: It is not possible to load the TerraLib database '")
//                + TerraLibFacade::getInstance()->getLastErrorMessage()
//                + string("'.");
//        returnsCustomError(L, 4, err);
//    }
//
    return 0;
}

/// Saves celular space.
int luaCellularSpace::save(lua_State *L)
{
	// issue #319
    //// get the 3 parameters:
    //// the simulation time(year, day, etc) that will be concatened to the attribute names,
    //// the output table name,
    //// table of names of attributes to be saved
    //char val[255];
    //const char *key, *value, *objId;
    //double v;
    //char attName[255];
    //vector<string> attNameList;
    //const char* outputTableName = luaL_checkstring(L, -3);
    //char outputTable[100];

    //// Convert time value to string ********
    //const float time = luaL_checknumber(L, -4);
    //char aux[100], *ch;

    //if( (time - floor(time)) > 0 )
    //    sprintf(aux, "%f", time);
    //else
    //    sprintf(aux, "%.0f", time);

    //ch = aux;

    //for( unsigned int i= 0; i < strlen(aux); i++)
    //{
    //    if( ch[i] == '.' || ch[i] ==',' )
    //        ch[i] = '_';
    //}

    //strcpy(outputTable, outputTableName);
    //strcat(outputTable, aux);

    //if( ! lua_istable(L, -2) )
    //{
    //    string err = string("Error: attribute names table not found.");
    //    returnsCustomError(L, 4, err);

    //    return false;
    //}

    //if( ! lua_istable(L, -1) )
    //{
    //    string err = string("Error: cells not found.");
    //    returnsCustomError(L, 4, err);

    //    return false;
    //}

    //vector<CellMapper> cellsSchemas;
    //CellMapper cell;

    ////  get the cellular space position *********
    //int cellsPos = lua_gettop(L);
    //lua_pushnumber(L, 1);
    //lua_gettable(L, cellsPos );
    //int firstCellPos = lua_gettop(L);

    //cell.addAttribute("object_id_", "", Attribute::STRING, true, 255);
    //cellsSchemas.push_back(cell);

    //lua_pushnil(L);

    //while(lua_next(L, cellsPos - 1 ) != 0)
    //{
    //    // "index" is at index -2 and "value(attribute name)" at index -1
    //    cell = CellMapper();

    //    key = luaL_checkstring(L, -1); // gets the cell attribute name
    //    strcpy( attName, key );
    //    attNameList.push_back( key);

    //    lua_pushstring(L, key);
    //    lua_gettable(L, firstCellPos);

    //    switch( lua_type(L, -1) )
    //    {
    //        case LUA_TNUMBER:
    //        case LUA_TBOOLEAN:
    //            cell.addAttribute(attName, "", Attribute::REAL, false, 0);
    //            break;

    //        case LUA_TSTRING:
    //            cell.addAttribute(attName, "", Attribute::STRING, false, 255);
    //            break;

    //        default:
    //            cell.addAttribute(attName, "", Attribute::STRING, false, 255);
    //            break;

    //    }

    //    cellsSchemas.push_back(cell);

    //    lua_pop(L, 1); // remove the attribute value
    //    lua_pop(L, 1); // removes the cell attribute name
    //}

    //vector<CellMapper> cells;

    //// Save data on the attribute table *****************
    //// tranverse the table(cells)
    //lua_pushnil(L); // first key

    //while (lua_next(L, cellsPos) != 0)
    //{	// "key" is at index -2 and "value(luaCell)" at index -1

    //    // build a table row for the cell at the top of the lua stack
    //    // Raian: Gets the cell's Id
    //    lua_pushstring(L, "objectId_");
    //    lua_gettable( L, -2);
    //    objId = luaL_checkstring(L, -1);
    //    lua_pop(L, 1);

    //    CellMapper cell(objId);

    //    vector<string>::iterator itName = attNameList.begin();

    //    for (int i = 1; i < cellsSchemas.size(); i++)
    //    {
    //        string attrName(itName->c_str());
    //        lua_pushstring(L, attrName.c_str());
    //        lua_gettable(L, -2);

    //        vector<Attribute> attrs = cellsSchemas.at(i).getAttributes();

    //        switch(attrs.at(0).getType())
    //        {
    //            case Attribute::REAL:
    //                // always save numbers as double
    //                v = lua_tonumber(L, -1);
    //                sprintf( val, "%f", v);
    //                value = val;
    //                cell.addAttribute(attrName, value, Attribute::REAL);
    //                break;

    //            case Attribute::STRING:
    //                value = lua_tostring(L, -1);
    //                cell.addAttribute(attrName, value, Attribute::STRING);
    //                break;

    //            default:
    //                value = lua_tostring(L, -1);
    //                cell.addAttribute(attrName, value, Attribute::STRING);
    //                break;

    //        }

    //        lua_pop(L, 1); // removes the cell attribute value

    //        itName++;
    //    }

    //    cells.push_back(cell);

    //    lua_pop(L, 1); // removes "value (cell)"; keeps "key" for next iteration
    //}

    //if (TerraLibFacade::getInstance()->connect(TerraLibFacade::MYSQL, host, user, pass, dbName, 0))
    //{
    //    if (inputLayerName.empty())
    //    {
    //        if (TerraLibFacade::getInstance()->
    //                save(inputThemeName, outputTable, whereClause, cellsSchemas, cells))
    //            return true;
    //        else
    //        {
    //            returnsCustomError(L, 4,
    //                               TerraLibFacade::getInstance()->getLastErrorMessage());
    //            return false;
    //        }
    //    }
    //    else
    //    {
    //        if(TerraLibFacade::getInstance()->
    //                save(inputLayerName, inputThemeName, outputTable,
    //                     whereClause, cellsSchemas, cells))
    //            return true;
    //        else
    //        {
    //            returnsCustomError(L, 4,
    //                               TerraLibFacade::getInstance()->getLastErrorMessage());
    //            return false;
    //        }
    //    }
    //}
    //else
    //{
    //    string err = string("Error: ")
    //            + TerraLibFacade::getInstance()->getLastErrorMessage()
    //            + string(".");
    //    returnsCustomError(L, 4, err);

    //    return false;
    //}

    return false;
}

//@RAIAN: novo loadNeighborhood
/// This method loads a neighborhood from a file. Extensions supported: .GAL, .GWT, .txt
/// \author  Raian Vargas Maretto
int luaCellularSpace::loadNeighborhood(lua_State *L){
	bool check = luaL_checkbool(L, -1);
	const char* neighName = luaL_checkstring(L, -2);
	const char* fileName = luaL_checkstring(L, -3);

	char aux[255], extension[255], shortFileName[255];
	char *auxExt;
	string wrngMsg = string();

	strcpy(aux, const_cast<char*>(fileName));
	auxExt = strtok(aux, ".");

	while(auxExt != NULL)
	{
		strcpy(extension, auxExt);
		auxExt = strtok(NULL, ".");
	}

	strcpy(aux, const_cast<char*>(fileName));
#if defined (TME_WIN32)
	auxExt = strtok(aux, "\\");
#else
	auxExt = strtok(aux, "/");
#endif

	while(auxExt != NULL)
	{
		strcpy(shortFileName, auxExt);
#if defined (TME_WIN32)
		auxExt = strtok(NULL, "\\");
#else
		auxExt = strtok(NULL, "/");
#endif
	}

	if(strcmp(extension, "gpm") == 0)
	{
		/*
		if(execModes != Quiet) {
			wrngMsg += string("from the GPM file '") +  string(shortFileName) + string("'...");
			lua_getglobal(L, "print");
			lua_pushstring(L, wrngMsg.c_str());
			lua_call(L, 1, 0);
		}
		*/
		return loadNeighborhoodGPMFile(L, fileName, neighName, check);
	}
	else
	{
		if(stricmp(extension, "gal") == 0)
		{
			/*
			if(execModes != Quiet) {
				wrngMsg += string("from the GAL file '") +  string(shortFileName) + string("'...");
				lua_getglobal(L, "print");
				lua_pushstring(L, wrngMsg.c_str());
				lua_call(L, 1, 0);
			}
			*/
			return loadNeighborhoodGALFile(L, fileName, neighName, check);
		}
		else
		{
			if(stricmp(extension, "gwt") == 0)
			{
				/*
				if(execModes != Quiet) {
					wrngMsg += string("from the GWT file '") +  string(shortFileName) + string("'...");
					lua_getglobal(L, "print");
					lua_pushstring(L, wrngMsg.c_str());
					lua_call(L, 1, 0);
				}
				*/
				return loadNeighborhoodGWTFile(L, fileName, neighName, check);
			}
			else
			{
				if(stricmp(extension, "txt") == 0)
				{
					if(execModes != Quiet) {
						wrngMsg += string(" from the TXT file '") +  string(shortFileName) + string("'...");
						lua_getglobal(L, "print");
						lua_pushstring(L, wrngMsg.c_str());
						lua_call(L, 1, 0);
					}
					return loadTXTNeighborhood(L, fileName, neighName, check);
				}
				else
				{
					string err_out = string("The file extension '")
									+ string(extension) + string("' is not suported.");
					lua_getglobal(L, "customError");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
					return false;
				}

			}
		}
	}

	return 0;
}

/// Loads a neighborhood from a .gpm file.
/// \author  Raian Vargas Maretto
int luaCellularSpace::loadNeighborhoodGPMFile(lua_State *L, const char* fileName,
											const char* neighName, bool check) {
	char aux[255], layer1Id[50], layer2Id[50], weightName[30];
	int numAttributes;
	double defaultWeight = 1;
	ifstream file;

	file.open(fileName, ios::in);

	if(!file.is_open())
	{
		string err_out = string("Failed to open neighborhood file '")
						+ string(fileName) + string("'.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
	}

	file.seekg(0, ios::beg);

	// Gets the number of attributes of the GPM
	file >> numAttributes;

	// Gets the name of the two layers of the GPM
	file >> layer1Id >> layer2Id;
	//cout << "'" << layer1Id << "' '"<< layer2Id << "'" << endl;
	if(strcmp(layer1Id, layer2Id) != 0)
	{
		file.close();
		string err_out = string("This function cannot load neighborhood between two layers. ") +
				string("Use 'Environment:loadNeighborhood()' instead.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}

	if(strcmp(layer1Id, this->getLayerName().c_str()) != 0 && check)
	{
		file.close();
		string err_out = string("Neighborhood file '") + string(fileName)
				+ string("' was not built for this CellularSpace. ")
				+ string("CellularSpace layer: '")
				+ string(this->getLayerName().c_str()) + string("', ")
				+ string("GPM file layer: '") + string(layer1Id) + string("'.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}

	// Gets the name of the attribute used as weight
	if(numAttributes > 1)
	{
		file.close();
		string err_out = string("The GPM must have exatly zero or one attributes. Currently, TerraME does not support neighborhoods with more than one attribute.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}
	else
	{
		for(int countAttribs = 1; countAttribs <= numAttributes; countAttribs++)
		{
			file >> weightName;
		}
	}

	while(!file.eof())
	{
		luaCell *cell, *neighbor;
		char cellId[20], neighId[20];
		int numNeighbors;

		// Gets the cell Id and the number of neighbors
		file >> cellId >> numNeighbors;

		if(strcmp(cellId, "") != 0 && !file.eof())
		{
			// Gets the cell
			cell = this->findCellByID(cellId);
			if(cell == NULL)
			{
				file.close();
				string err_out = string("Cell '") + string(cellId)
						+ string("' in file '") + string(fileName)
						+ string("' was not found in the CellularSpace.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
			}

			// creates the neighborhood and adds it to the cell's set of neighborhoods
			NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
			luaNeighborhood* neighborhood = new luaNeighborhood(L);
			pair<string, CellNeighborhood*> pairStrNeigh;
			pairStrNeigh.first = neighName;
			pairStrNeigh.second = neighborhood;
			string strNeighName = string(neighName);
			neighborhood->setID(strNeighName);
			neighborhoods.erase(neighName);
			//@RAIAN
			neighborhood->setParent(cell);
			//@RAIAN: END
			neighborhoods.add(pairStrNeigh);

			lua_getglobal(L, "Neighborhood");
			if(!lua_isfunction(L, -1))
			{
				file.close();
				string err_out = string("Neighborhood constructor not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
			}

			// puts the neighborhood on the stack top
			lua_newtable(L);
			lua_pushstring(L, "cObj_");
			typedef struct {luaNeighborhood *pT;} userdataType;
			userdataType *ud = static_cast<userdataType*>(
									lua_newuserdata(L, sizeof(userdataType)));
			ud->pT = neighborhood; // store pointer to object in userdata
			luaL_getmetatable(L, luaNeighborhood::className);
			lua_setmetatable(L, -2);
			lua_settable(L, -3);

			// puts the neighbohrood id on the stack
			lua_pushstring(L, "id");
			lua_pushstring(L, neighName);
			lua_settable(L, -3);

			// Calls the Neighborhood constructor
			if(lua_pcall(L, 1, 1, 0) != 0)
			{
				file.close();
				string err_out = string("Neighborhood constructor was not found in the stack.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
			}

			// Gets the neighbors and add them to the neighborhood
			for(int countNeigh = 1; countNeigh <= numNeighbors; countNeigh++)
			{
				double weight;
				file >> neighId;
				neighbor = this->findCellByID(neighId);
				if(neighbor == NULL)
				{
					file.close();
					string err_out = string("Cell Id '") + string(neighId)
									+ string("' found in the file '")
									+ string(fileName)
									+ string("' was not found in the Cellular Space. Probably the file is corrupted or was made for another Cellular Space.");
					lua_getglobal(L, "customError");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
					lua_pushnil(L);
					return 1;
				}

				if(numAttributes == 1)
					file >> weight;
				else
					weight = defaultWeight;

				// CAST de luaCell* para Cell*
				// funciona no msvc, nao funciona g++
				// neighborhood->add(neighbor->getIndex(), neighbor, weight);
				CellIndex auxIndex = neighbor->getIndex();
				neighborhood->add(auxIndex, (Cell*) neighbor, weight);

				// Add the neighborhood in the Lua table

				// get cell.neighborhoods
				int top = lua_gettop(L);
				cell->getReference(L);
				lua_pushstring(L, "neighborhoods");
				lua_gettable(L, -2);

				if(lua_isnil(L, -1))
				{
					lua_pop(L, 1);
					lua_pushstring(L, "neighborhoods");
					lua_newtable(L);
					lua_rawset(L, -3);

					lua_pushstring(L, "neighborhoods");
					lua_gettable(L, -2);
				}

				lua_pushstring(L, neighName);
				neighborhood->getReference(L);
				lua_rawset(L, -3);
				lua_settop(L, top);
			}
		}
	}

	file.close();
	return 0;
}

/// Loads GAL Neighborhood files
/// \author Raian Vargas Maretto
int luaCellularSpace::loadNeighborhoodGALFile(lua_State *L, const char* fileName,
											const char* neighName, bool check) {
	char aux[255], layerId[50];
	int cellQtde;
	double defaultWeight = 1;
	CellularSpace::iterator itAux;

	ifstream file;
	file.open(fileName, ios::in);

	if(!file.is_open())
	{
		string err_out = string("Failed to open neighborhood file '")
						+ string(fileName) + string("'");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}

	file.seekg(0, ios::beg);

	// Gets the first field of the GAL file ("0"). It will not be used.
	file >> aux;

	// gets the total amount of cells
	file >> cellQtde;

	// gets the layer name
	file >> layerId;

	if(strcmp(layerId, this->getLayerName().c_str()) && check)
	{
		file.close();

		string err_out = string("Neighborhood file '") + string(fileName)
						+ string("' was not built for this CellularSpace. ")
						+ string("CellularSpace layer: '")
						+ string(this->getLayerName().c_str()) + string("', ")
						+ string("GAL file layer: '") + string(layerId) + string("'.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}

	// gets the name of the key variable (it either will not be used)
	file >> aux;

	int numCell = 1;
	for(; numCell <= cellQtde && !file.eof(); numCell++)
	{
		char cellId[20];
		int numNeigh;
		luaCell *cell;

		// get the cell ID and the amount of neighbors
		file >> cellId >> numNeigh;

		// creates the neighborhood
		if(strcmp(cellId, "") != 0 && !file.eof())
		{
			// gets the cell
			cell = findCellByID(cellId);
			if(cell == NULL)
			{
				file.close();
				string err_out = string("Cell Id '") + string(cellId)
								+ string("' found in the file '") + string(fileName)
								+ string("' was not found in the Cellular Space. Probably the file is corrupted or was made for another Cellular Space.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
			}

			// creates the neighborhood and add it to the cell's set of neighborhoods
			NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
			luaNeighborhood* neighborhood = new luaNeighborhood(L);
			pair< string, CellNeighborhood* > pairStrNeigh;
			pairStrNeigh.first = neighName;
			pairStrNeigh.second = neighborhood;
			string strNeighName = string(neighName);
			neighborhood->setID(strNeighName);
			neighborhoods.erase(neighName);
			//@RAIAN
			neighborhood->setParent(cell);
			//@RAIAN: END
			neighborhoods.add(pairStrNeigh);

			lua_getglobal(L, "Neighborhood");
			if(!lua_isfunction(L, -1))
			{
				file.close();
				string err_out = string("Neighborhood constructor not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
				return 0;
			}

			//puts the neighborhood on the stack top
			lua_newtable(L);
			lua_pushstring(L, "cObj_");
			typedef struct {luaNeighborhood *pT; } userdataType;
			userdataType *ud = static_cast<userdataType*>(
										lua_newuserdata(L, sizeof(userdataType)));
			ud->pT = neighborhood; // store pointer to object in userdata
			luaL_getmetatable(L, luaNeighborhood::className);
			lua_setmetatable(L, -2);
			lua_settable(L, -3);

			// puts the neighbohrood id on the stack
			lua_pushstring(L, "id");
			lua_pushstring(L, neighName);
			lua_settable(L, -3);

			// Calls the Neighborhood constructor
			if(lua_pcall(L, 1, 1, 0) != 0)
			{
				file.close();
				string err_out = string("Neighborhood constructor not found in the stack.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
				return 0;
			}

			// get the neighbors and add them to the neighborhood
			for(int countNeigh = 1; countNeigh <= numNeigh; countNeigh++)
			{
				char neighId[20];
				luaCell *neighbor;

				file >> neighId;
				neighbor = findCellByID(neighId);
				if(neighbor == NULL)
				{
					file.close();
					string err_out = string("Cell Id '") + string(neighId)
									+ string("' found in the file '") + string(fileName)
									+ string("' was not found in the Cellular Space. Probably the file is corrupted or was made for another Cellular Space.");
					lua_getglobal(L, "customError");
					lua_pushstring(L, err_out.c_str());
					//lua_pushnumber(L, 4);
					lua_call(L, 1, 0);
				}

				// Add the new neighbor to the neighborhood
				CellIndex auxIndex = neighbor->getIndex();
				neighborhood->add(auxIndex, neighbor, defaultWeight);

				int top = lua_gettop(L);
				cell->getReference(L);
				lua_pushstring(L, "neighborhoods");
				lua_gettable(L, -2);

				if(lua_isnil(L, -1))
				{
					lua_pop(L, 1);
					lua_pushstring(L, "neighborhoods");
					lua_newtable(L);
					lua_rawset(L, -3);

					lua_pushstring(L, "neighborhoods");
					lua_gettable(L, -2);
				}

				lua_pushstring(L, neighName);
				neighborhood->getReference(L);
				lua_rawset(L, -3);
				lua_settop(L, top);
			}
		}
	}
	// The file ends before it was expected
	if((numCell - 1) != cellQtde)
	{
		file.close();
		string err_out = string("Unexpected end of file! Probably it is corrupted.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}
	file.close();
	return 0;
}

/// Loads GWT Neighborhood files
/// \author Raian Vargas Maretto
int luaCellularSpace::loadNeighborhoodGWTFile(lua_State *L, const char* fileName,
											const char* neighName, bool check)
{
	ifstream file;
	char aux[255], layerId[50];
	char cellId[20];
	int cellQtde;

	file.open(fileName, ios::in);

	if(!file.is_open())
	{
		string err_out = string("Failed to open neighborhood file '")
						+ string(fileName) + string("'.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
		return false;
	}

	file.seekg(0, ios::beg);

	// Gets the first field of the GWT file ("0"). It will not be used.
	file >> aux;

	// Gets the total amount of cells
	file >> cellQtde;

	// Gets the layer name
	file >> layerId;

	if(strcmp(layerId, this->getLayerName().c_str()) && check)
	{
		file.close();

		string err_out = string("Neighborhood file '") + string(fileName)
						+ string("' was not built for this CellularSpace. ")
						+ string("CellularSpace layer: '")
						+ string(this->getLayerName().c_str()) + string("', ")
						+ string("GWT file layer: '") + string(layerId) + string("'.");

		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		//lua_pushnumber(L, 4);
		lua_call(L, 1, 0);
	}

	// gets the name of the key variable (it either will not be used).
	file >> aux;

	file >> cellId;
	strcpy(aux, cellId);

	int numCell = 1;
	for(; numCell <= cellQtde && !file.eof(); numCell++)
	{
		if(strcmp(cellId, aux) != 0)
		{
			strcpy(cellId, aux);
		}

		if(strcmp(cellId, "") != 0)
		{
			luaCell *cell = findCellByID(cellId);
			if(cell == NULL)
			{
				file.close();
				string err_out = string("Cell Id '") + string(cellId)
								+ string("' found in the file '") + string(fileName)
								+ string("' was not found in the Cellular Space. Probably the file is corrupted or was made for another Cellular Space.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
			}

			// Creates a neighborhood and add it to the cell's set of neighborhoods
			NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
			luaNeighborhood* neighborhood = new luaNeighborhood(L);
			pair<string, CellNeighborhood*> pairStrNeigh;
			pairStrNeigh.first = neighName;
			pairStrNeigh.second = neighborhood;
			string strNeighName = string(neighName);
			neighborhood->setID(strNeighName);
			neighborhoods.erase(neighName);
			neighborhood->setParent(cell);
			neighborhoods.add(pairStrNeigh);

			lua_getglobal(L, "Neighborhood");

			// Verify ifthe Neighborhood constructor is in the LUA Stack
			if(!lua_isfunction(L, -1))
			{
				file.close();

				string err_out = string("Neighborhood constructor not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				//lua_pushnumber(L, 4);
				lua_call(L, 1, 0);
				return 0;
			}

			// puts the neighborhood on the stack top
			lua_newtable(L);
			lua_pushstring(L, "cObj_");
			typedef struct {luaNeighborhood *pT;} userdataType;
			userdataType *ud = static_cast<userdataType*>(
										lua_newuserdata(L, sizeof(userdataType)));
			ud->pT = neighborhood; // store pointer to object in userdata
			luaL_getmetatable(L, luaNeighborhood::className);
			lua_setmetatable(L, -2);
			lua_settable(L, -3);

			// puts the neighbohrood id on the stack
			lua_pushstring(L, "id");
			lua_pushstring(L, neighName);
			lua_settable(L, -3);

			// calls the neighborhood constructor
			if(lua_pcall(L, 1, 1, 0) != 0)
			{
				file.close();
				string err_out = string("Neighborhood constructor not found in the stack.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				lua_call(L, 1, 0);
				return 0;
			}

			// get the neighbors and add them to the neighborhood
			while(strcmp(cellId, aux) == 0 && !file.eof())
			{
				double weight;
				char neighId[20], aux1[100];
				luaCell *neighbor;

				file >> neighId >> weight;

				neighbor = findCellByID(neighId);
				if(neighbor == NULL)
				{
					file.close();
					string err_out = string("Cell Id '") + string(neighId)
									+ string("' found in the file '") + string(fileName)
									+ string("' was not found in the Cellular Space. Probably the file is corrupted or was made for another Cellular Space.");
					lua_getglobal(L, "customError");
					lua_pushstring(L, err_out.c_str());
					lua_call(L, 1, 0);
				}

				// Add the new neighbor to the neighborhood
				CellIndex auxIndex = neighbor->getIndex();
				neighborhood->add(auxIndex, neighbor, weight);

				int top = lua_gettop(L);
				cell->getReference(L);
				lua_pushstring(L, "neighborhoods");
				lua_gettable(L, -2);

				if(lua_isnil(L, -1))
				{
					lua_pop(L, 1);
					lua_pushstring(L, "neighborhoods");
					lua_newtable(L);
					lua_rawset(L, -3);

					lua_pushstring(L, "neighborhoods");
					lua_gettable(L, -2);
				}

				lua_pushstring(L, neighName);
				neighborhood->getReference(L);
				lua_rawset(L, -3);
				lua_settop(L, top);

				file >> aux;
			}

		}

	}
	// The file ends before it was expected
	if((numCell - 1) != cellQtde)
	{
		file.close();

		string err_out = string("Unexpected end of file! Probably it is corrupted.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		lua_call(L, 1, 0);
		return false;
	}
	file.close();
	return 0;
}

/// Loads TXT Neighborhood file.
/// \author Raian Vargas Maretto
int luaCellularSpace::loadTXTNeighborhood(lua_State *L, const char* fileName,
										const char* neighName, bool check)
{
	ifstream file;
	char aux[500], aux1[255];
	char* aux2;
	vector<char*> idNeighbors;
	char cellId[20], neighId[20];
	int cellQtde, neighQtde, numCell, numNeigh;
	int cellX, cellY, neighX, neighY;
	int weight, defaultWeight = 1;
	CellIndex cellIndx, neighIndx;
	luaCell *cell, *neighbor;
	CellularSpace::iterator itAux;

	file.open(fileName, ios::in);

	if(!file)
	{
		string err_out = string("Failed to open neighborhood file '")
						+ string(fileName) + string("'.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		lua_call(L, 1, 0);
	}

	// gets the total number of cells
	file.seekg(ios::beg);
	file.getline(aux1, 255);

	aux2 = strtok(aux1, " \t\n");
	int count = 0;
	while(aux2 != NULL)
	{
		if(count == 0)
			strcpy(aux1, aux2);
		aux2 = strtok(NULL, " \t\n");
		count++;
	}
	cellQtde = atoi(aux1);

	for(numCell = 1; numCell <= cellQtde && !file.eof(); numCell++)
	{
		file.getline(aux, 500);
		aux2 = strtok(aux, " \t\n");
		neighQtde = 0;
		while(aux2 != NULL)
		{
			if(neighQtde == 0)
				strcpy(cellId, aux2);
			else
				idNeighbors.push_back(aux2);

			aux2 = strtok(NULL, " \t\n");
			neighQtde++;
		}

		objectId2coords(cellId, cellX, cellY);
		cellIndx.first = cellX;
		cellIndx.second = cellY;

		itAux = CellularSpace::find(cellIndx);

		// Creates the neighborhood
		if(itAux != CellularSpace::end())
		{
			cell = (luaCell*) itAux->second;

			// creates the neighborhood and add it to the cell's set of neighborhoods
			NeighCmpstInterf& neighborhoods = cell->getNeighborhoods();
			luaNeighborhood* neighborhood = new luaNeighborhood(L);
			pair<string, CellNeighborhood*> pairStrNeigh;
			pairStrNeigh.first = neighName;
			pairStrNeigh.second = neighborhood;
			string strNeighName = string(neighName);
			neighborhood->setID(strNeighName);
			neighborhoods.erase(neighName);
			neighborhood->setParent(cell);
			neighborhoods.add(pairStrNeigh);

			lua_getglobal(L, "Neighborhood");
			if(!lua_isfunction(L, -1))
			{
				file.close();
				string err_out = string("Neighborhood constructor not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				lua_call(L, 1, 0);
				return 0;
			}

			//puts the neighborhood on the stack top
			lua_newtable(L);
			lua_pushstring(L, "cObj_");
			typedef struct {luaNeighborhood *pT;} userdataType;
			userdataType *ud = static_cast<userdataType*>(
										lua_newuserdata(L, sizeof(userdataType)));
			ud->pT = neighborhood; //store the pointer to object in userdata
			luaL_getmetatable(L, luaNeighborhood::className);
			lua_setmetatable(L, -2);
			lua_settable(L, -3);

			// puts the neighbohrood id on the stack
			lua_pushstring(L, "id");
			lua_pushstring(L, neighName);
			lua_settable(L, -3);

			// Calls the Neighborhood constructor
			if(lua_pcall(L, 1, 1, 0) != 0)
			{
				file.close();
				string err_out = string("Neighborhood constructor not found in the stack.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				lua_call(L, 1, 0);
				return 0;
			}

			// get the neighbors and add them to the neighborhood
			for(numNeigh = 0; numNeigh < neighQtde - 1; numNeigh++)
			{
				strcpy(neighId, idNeighbors.at(numNeigh));
				objectId2coords(neighId, neighX, neighY);
				neighIndx.first = neighX;
				neighIndx.second = neighY;
				neighbor = (luaCell*) CellularSpace::operator [](neighIndx);
				weight = defaultWeight;
				//Add the new neighbor to the neighborhood
				neighborhood->add(neighIndx, neighbor, weight);
			}
			idNeighbors.clear();
		}
	}

	// The file ends before it was expected
	if((numCell - 1) != cellQtde)
	{
		file.close();
		string err_out = string("Unexpected end of file! Probably it is corrupted.");
		lua_getglobal(L, "customError");
		lua_pushstring(L, err_out.c_str());
		lua_call(L, 1, 0);
		return false;
	}
	file.close();
	return 0;
}





/// Find a cell given a cell ID
/// \author Raian Vargas Maretto
luaCell * luaCellularSpace::findCellByID(const char* cellID)
{
    luaCell *cell;
    CellularSpace::iterator it = this->begin();
    const char *idAux;
    while( it != this->end() )
    {
        cell = (luaCell*)it->second;
        idAux = cell->getID();
        if(strcmp(idAux, cellID) == 0)
        {
            return cell;
        }
        it++;
    }
    return NULL;
    //return (luaCell*)0;
}

/// Gets the luaCell object within the CellularSpace identified by the cell ID received as parameter
/// \author Raian Vargas Maretto
int luaCellularSpace::getCellByID(lua_State *L)
{
    const char *cellID = luaL_checkstring(L, -1);
    const char *idAux;
    luaCell *cell;
    CellularSpace::iterator it = this->begin();
    while( it != this->end() )
    {
        cell = (luaCell*)it->second;
        if(cell != NULL)
        {
            idAux = cell->getID();
            if(strcmp(idAux, cellID) == 0)
            {
                cell->getReference(L);
                return 1;
            }
        }
        it++;
    }
    lua_pushnil( L );
    return 1;
}

//@RAIAN: Fim.
/// Find a cell given a luaCellularSpace object and a luaCellIndex object
luaCell * findCell( luaCellularSpace* cs, CellIndex& cellIndex)
{
    Region_<CellIndex>::iterator it = cs->find( cellIndex );
    if( it != cs->end() ) return (luaCell*)it->second;
    return (luaCell*)0;
}

#if defined( TME_MSVC ) && defined( TME_WIN32 )
void configureADO(){
    // begin - copy from tview
    //verify what is the decimal separator
    HKEY    hk;
    DWORD	DataSize = 2;
    DWORD   Type = REG_SZ;
    char    buf[2];

    string key = "Control Panel\\International";
    string sepDecimal = "sDecimal";
    string sepDecimalResult = "";

    if (RegOpenKeyExA(HKEY_CURRENT_USER, key.c_str(), 0, KEY_READ, &hk) == ERROR_SUCCESS)
    {
        memset (buf, 0, 2);
        DataSize = 2;
        //decimal separator
        if (RegQueryValueExA(hk, sepDecimal.c_str(), NULL, &Type, (LPBYTE)buf, &DataSize) == ERROR_SUCCESS)
            sepDecimalResult = buf;

        RegCloseKey (hk);
    }

    if((!sepDecimalResult.empty()) && (sepDecimalResult==","))
    {
        if (RegOpenKeyExA(HKEY_CURRENT_USER, key.c_str(), 0, KEY_SET_VALUE, &hk) == ERROR_SUCCESS)
        {
            memset (buf, 0, 2);
            buf[0] = '.';
            DataSize = 2;

            RegSetValueExA(hk, sepDecimal.c_str(), NULL, Type, (LPBYTE)buf, DataSize);
            RegCloseKey (hk);
        }
    }
    // end - copy from tview
}
#endif
