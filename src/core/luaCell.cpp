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

/*! \file luaCell.cpp
    \brief This file contains the implementation for the luaCell objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaCell.h"
#include "luaNeighborhood.h"
#include "terrameGlobals.h"

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/observerTCPSender.h"
// #include "../observer/types/observerScheduler.h"
#include "../observer/types/agentObserverMap.h"
#include "luaUtils.h"
#include "LuaSystem.h"
#include "LuaBindingDelegate.h"

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;

extern ExecutionModes execModes;

/// Constructor
luaCell::luaCell(lua_State *L)
{
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    it = nhgs.begin();

    luaL = L;
    subjectType = TObsCell;
    observedAttribs.clear();

    attrNeighName = "";

	lua = terrame::lua::LuaSystem::getInstance().getLuaApi();
}

/// Returns the current internal state of the LocalAgent (Automaton) within the cell and received as parameter
int luaCell::getCurrentStateName(lua_State *L)
{
    luaLocalAgent *agent = terrame::lua::LuaBindingDelegate<luaLocalAgent>::getInstance().check(L, -1);
    ControlMode* controlMode = getControlMode((LocalAgent*)agent);

    if (controlMode) lua->pushString(L, controlMode->getControlModeName().c_str());
    else lua->pushNil(L);

    return 1;
}

/// Puts the iterator in the beginning of the luaNeighborhood composite.
int luaCell::first(lua_State *L){
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    it = nhgs.begin();
    return 0;
}

/// Puts the iterator in the end of the luaNeighborhood composite.
int luaCell::last(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    it = nhgs.end();
    return 1;
}

/// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure
/// no parameters
int luaCell::isFirst(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    lua->pushBoolean(L, it == nhgs.begin());
    return  1;
}

/// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure
/// no parameters
int luaCell::isLast(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    lua->pushBoolean(L, it == nhgs.end());
    return  1;
}

/// Returns true if the Neighborhood is empty.
/// no parameters
int luaCell::isEmpty(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    lua->pushBoolean(L, nhgs.empty());
    return 1;
}

/// Clears all the Neighborhood content
/// no parameters
int luaCell::clear(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    nhgs.clear();
    return 0;
}

/// Returns the number of Neighbors cells in the Neighborhood
int luaCell::size(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    lua->pushNumber(L, nhgs.size());
    return 1;
}

/// Fowards the Neighborhood iterator to the next Neighbor cell
// no parameters
int luaCell::next(lua_State *)
{
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    if (it != nhgs.end()) it++;
    return 0;
}

/// destructor
// @DANIEL:
// Controle de recursos de memoria (destrutor C++ e Lua Garbage Collector) nao devem ser misturados
// luaCell::~luaCell( void ) { luaL_unref( L, LUA_REGISTRYINDEX, ref); }
luaCell::~luaCell(void) { }

/// Sets the Cell latency
int luaCell::setLatency(lua_State *L) { 
	Cell::setLatency(lua->getNumberAtTop(L)); 
	return 0; 
}

/// Gets the Cell latency
int luaCell::getLatency(lua_State *L) { 
	lua->pushNumber(L, Cell::getLatency()); 
	return 1; 
}

/// Sets the neighborhood
int luaCell::setNeighborhood(lua_State *L) {
    //	luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
    return 0;
}

/// Gets the current active luaNeighboorhood
int luaCell::getCurrentNeighborhood(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods();
    if (it !=  nhgs.end())
    {
        luaNeighborhood* neigh =(luaNeighborhood*) it->second;

        if (neigh != NULL)
            neigh->getReference(L);
        else
            lua->pushNil(L);
    }
    else
        lua->pushNil(L);

    return 1;
}

/// Returns the Neihborhood graph which name has been received as a parameter
int luaCell::getNeighborhood(lua_State *L) {
    NeighCmpstInterf& neighs = Cell::getNeighborhoods();

    // Get and test parameters
    const char* charIndex = lua->getStringAtTop(L).c_str();
    string index = string(charIndex);
    if (neighs.empty()) 
		lua->pushNil(L); // return nil
    else
    {
        // Get the cell	neighborhood
        NeighCmpstInterf::iterator location = neighs.find(index);
        if (location == neighs.end())
        {
            lua->pushNil(L);
            return 1;
        }

        luaNeighborhood* neigh =(luaNeighborhood*) location->second;

        if (neigh != NULL)
            neigh->getReference(L);
        else
            lua->pushNil(L);
    }

    return 1;
}

/// Adds a new luaNeighborhood graph to the Cell
/// parameters: identifier, luaNeighborhood
int luaCell::addNeighborhood(lua_State *L)
{
    luaNeighborhood* neigh = terrame::lua::LuaBindingDelegate<luaNeighborhood>::getInstance().check(L, -1);
    string id(lua->getStringAt(L, -2));	
    NeighCmpstInterf& neighs = Cell::getNeighborhoods();
    pair< string, CellNeighborhood*> pStrNeigh;
    neigh->CellNeighborhood::setID(id);

    //@RAIAN: setting the neighborhood parent
    neigh->CellNeighborhood::setParent(this);
    //@RAIAN: FIM

    pStrNeigh.first = id;
    pStrNeigh.second = neigh;
    neighs.erase(id);
    neighs.add(pStrNeigh);
    it = neighs.begin();
    return 0;
}

/// Synchronizes the luaCell
int luaCell::synchronize(lua_State *L) {
    Cell::synchronize(sizeof(luaCell)); // parametro nao testado
    return 0;
}

// @DANIEL:
// Movido para a classe Reference
/// Registers the luaCell object in the Lua stack
int luaCell::setReference(lua_State* L)
{
    //ref = luaL_ref(L, LUA_REGISTRYINDEX);
    //return 0;
	return terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setReference(L);
}

// @DANIEL:
// Movido para a classe Reference
/// Gets the luaCell object reference
int luaCell::getReference(lua_State *L)
{
//    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//    return 1;
	return terrame::lua::LuaBindingDelegate<luaCell>::getInstance().getReference(L);
}

int luaCell::getID(lua_State *L)
{
	lua->pushString(L, objectId_);
    return 1;
}

const char* luaCell::getID()
{
    return this->objectId_.c_str();
}

int luaCell::setID(lua_State *L)
{
    objectId_ = lua->getStringAtTop(L);
    return 0;
}

int luaCell::setIndex(lua_State *L)
{
    this->idx.second = lua->getNumberAtTop(L);
    this->idx.first = lua->getNumberAt(L, -2);
    return 0;
}

//Raian
/// Gets the cell index (x,y)
/// \author Raian Vargas Maretto
CellIndex luaCell::getIndex()
{
    return this->idx;
}

/// Creates several types of observers
/// parameters: observer type, observeb attributes table, observer type parameters
// verif. ref (endereco na pilha lua)
// olhar a classe event
int luaCell::createObserver(lua_State *)
{
    // recupero a referencia da celula
    // @DANIEL
    // Responsabilidade da classe Reference
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    
	getReference(luaL);

    // flags para a defini??o do uso de compress?o
    // na transmiss?o de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua->getTopIndex(luaL);

    // Nao modifica em nada a pilha
    // recupera o enum referente ao tipo
    // do observer
    int typeObserver = lua->getNumberAt(luaL, -4);

    //@RAIAN
    // Para o Observer do tipo Neighbohrood
    if (typeObserver != TObsNeigh)
    {
        bool isGraphicType =(typeObserver == TObsDynamicGraphic) ||(typeObserver == TObsGraphic);

        //------------------------
        QStringList allAttribs, obsAttribs;

        // Pecorre a pilha lua recuperando todos os atributos celula
        lua->pushNil(luaL);
        while (lua->nextAt(luaL, top) != 0)
        {
            QString key(lua->getStringAt(luaL, -2).c_str());

            allAttribs.push_back(key);
            lua->popOneElement(luaL);
        }

        //------------------------
        // pecorre a pilha lua recuperando
        // os atributos celula que se quer observar
        lua->setTop(luaL, top - 1);
        top = lua->getTopIndex(luaL);

        // Verificacao da sintaxe da tabela Atributos
        if (!lua->isTableAt(luaL, top))
        {
            lua->callError(luaL, "Error: Attribute table not found. Incorrect sintax.");
			return -1;
        }

        bool attribTable = false;

        lua->pushNil(luaL);
        while (lua->nextAt(luaL, top - 1) != 0)
        {
            QString key(lua->getStringAtTop(luaL).c_str());
            attribTable = true;

            // Verifica se o atributo informado n?o existe deve ter sido digitado errado
            if (allAttribs.contains(key))
            {
                obsAttribs.push_back(key);
                if (!observedAttribs.contains(key))
                    observedAttribs.push_back(key);
            }
            else
            {
                if (!key.isNull() || !key.isEmpty())
                {
                    lua->callError(luaL, "Error: Attribute '"+ key.toStdString() +"' not found.");
					return -1;
                }
            }

            lua->popOneElement(luaL);
        }

        if (obsAttribs.empty())
        {
            obsAttribs = allAttribs;
            observedAttribs = allAttribs;
        }

        //if (! lua_istable(luaL, top))
        //{
        //    qWarning("Warning: Parameter table not found. Incorrect sintax.");
        //    return 0;
        //}

        QStringList cols, obsParams;

        // Recupera a tabela de parametros os observadores do tipo Table e Graphic
        // caso nao seja um tabela a sintaxe do metodo esta incorreta
        lua->pushNil(luaL);
        while (lua->nextAt(luaL, top) != 0)
        {
            QString key;
            if(lua->isStringAt(luaL, -2))
                key = QString(lua->getStringAt(luaL, -2).c_str());
			
			int luaType = lua->getTypeAt(luaL, -1);

			if(lua->isString(luaType))
			{
				QString value(lua->getStringAtTop(luaL).c_str());
				cols.push_back(value);
			}
			else if(lua->isBoolean(luaType))
			{
				bool val = lua->toBooleanAt(luaL, -1);
				if (key == "visible")
					obsVisible = val;
				else // if (key == "compress")
					compressDatagram = val;
			}
			else if(lua->isTable(luaType))
			{
				int tableTop = lua->getTopIndex(luaL);

				lua->pushNil(luaL);
				while (lua->nextAt(luaL, tableTop) != 0)
				{
					if (lua->isStringAt(luaL, -2))
						obsParams.append(lua->getStringAt(luaL, -2).c_str());
					
					luaType = lua->getTypeAt(luaL, -1);

					if (lua->isNumber(luaType))
					{
						cols.append(QString::number(lua->getNumberAtTop(luaL)));
					}
					else if (lua->isString(luaType))
					{
						cols.append(lua->getStringAtTop(luaL).c_str());
					}

					lua->popOneElement(luaL);
				}
			}

			lua->popOneElement(luaL);
        }

        ObserverTextScreen *obsText = 0;
        ObserverTable *obsTable = 0;
        ObserverGraphic *obsGraphic = 0;
        ObserverLogFile *obsLog = 0;
        ObserverUDPSender *obsUDPSender = 0;
        ObserverTCPSender *obsTCPSender = 0;

        int obsId = -1;

        switch (typeObserver)
        {
			case TObsTextScreen:
				obsText =(ObserverTextScreen*)
						CellSubjectInterf::createObserver(TObsTextScreen);
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
				obsLog =(ObserverLogFile*)
						CellSubjectInterf::createObserver(TObsLogFile);
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
				obsTable =(ObserverTable *)
						CellSubjectInterf::createObserver(TObsTable);
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
				obsGraphic =(ObserverGraphic *)
						CellSubjectInterf::createObserver(TObsDynamicGraphic);
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
				obsGraphic =(ObserverGraphic *)
						CellSubjectInterf::createObserver(TObsGraphic);
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

			case TObsUDPSender:
				obsUDPSender =(ObserverUDPSender *)
						CellSubjectInterf::createObserver(TObsUDPSender);
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

			case TObsTCPSender:
				obsTCPSender =(ObserverTCPSender *)
				CellSubjectInterf::createObserver(TObsTCPSender);
				if (obsTCPSender)
				{
					obsId = obsTCPSender->getId();
					obsTCPSender->setCompress(compressDatagram);

					if (obsVisible)
						obsTCPSender->show();
				}
				else
				{
					if (execModes != Quiet) { // TODO(avancinirodrigo): review this warn
						QString str = QString(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
						lua->pushGlobalByName(L, "customWarning");
						lua->pushString(L, str.toLatin1().constData());
						lua->call(L, 1, 0);
					}
				}
			break;
			case TObsMap:
			default:
				if (execModes != Quiet)
				{
					string errOut = string("Warning: In this context, the code '")
							+ string(getObserverName(typeObserver))
							+ string("' does not correspond to a valid type of Observer.");
					lua->callWarning(luaL, errOut);
				}
				return 0;
        }

        /// Define alguns parametros do observador instanciado ---------------------------------------------------

        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);
            obsLog->setFileName(cols.at(0));
            obsLog->setSeparator(cols.at(1));
			obsLog->setWriteMode(cols.at(2));

            lua->pushNumber(luaL, obsId);
            lua->pushLightUserdata(luaL, (void*) obsLog);
            return 2;
        }

        if (obsText)
        {
            obsText->setAttributes(obsAttribs);
            lua->pushNumber(luaL, obsId);
            lua->pushLightUserdata(luaL, (void*) obsText);

            return 2;
        }

        if (obsTable)
        {
            obsTable->setColumnHeaders(cols);
            obsTable->setAttributes(obsAttribs);

            lua->pushNumber(luaL, obsId);
            lua->pushLightUserdata(luaL, (void*) obsTable);

            return 2;
        }

        if (obsGraphic)
        {
            obsGraphic->setLegendPosition();

            // Takes titles of three first locations
            obsGraphic->setTitles(cols.at(0), cols.at(1), cols.at(2));
            cols.removeFirst(); // remove graphic title
            cols.removeFirst(); // remove axis x title
            cols.removeFirst(); // remove axis y title

            // Splits the attribute labels in the cols list
            obsGraphic->setAttributes(obsAttribs, cols.takeFirst().split(";", QString::SkipEmptyParts),
                                      obsParams, cols);

            lua->pushNumber(luaL, obsId);
			lua->pushLightUserdata(luaL, (void*) obsGraphic);

			return 2;
        }

        if (obsUDPSender)
        {
            obsUDPSender->setAttributes(obsAttribs);

            obsUDPSender->setPort(cols.at(0).toInt());

            // broadcast
            if ((cols.size() == 1) ||((cols.size() == 2) && cols.at(1).isEmpty()))
            {
                obsUDPSender->addHost(BROADCAST_HOST);
            }
            else
            {
                // multicast or unicast
                for (int i = 1; i < cols.size(); i++){
                    if (!cols.at(i).isEmpty())
                        obsUDPSender->addHost(cols.at(i));
                }
            }

            lua->pushNumber(luaL, obsId);
            lua->pushLightUserdata(luaL, (void*) obsUDPSender);

            return 2;
        }
    }
    //@RAIAN
    // Comeca a criacao do Observer do tipo Neighborhood
    else
    {
        QStringList obsParams, obsParamsAtribs;

        bool getObserverID = false, isLegend = false;
        int obsID = -1;

        AgentObserverMap *obsMap = 0;
        luaCellularSpace *cellSpace = 0;

        // Recupera os parametros
        lua->pushNil(luaL);
        while (lua->nextAt(luaL, top - 1) != 0)
        {
            // Recupera o ID do observer map
            if (lua->isNumberOrStringNumberAt(luaL, -1) && (!getObserverID))
            {
                obsID = lua->getNumberAtTop(luaL);
                getObserverID = true;
                isLegend = true;
            }

            //Recupera o espaco celular e a legenda
            if (lua->isTableAt(luaL, -1))
            {
                int paramTop = lua->getTopIndex(luaL);

                lua->pushNil(luaL);
                while (lua->nextAt(luaL, paramTop) != 0)
                {
                    if (lua->isUserdataAt(luaL, -1, "TeCellularSpace"))
                    {
                        cellSpace = terrame::lua::LuaBindingDelegate<luaCellularSpace>::getInstance().check(L, -1);
                    }
                    else
                    {
                        if (isLegend)
                        {
                            QString key(lua->getStringAt(luaL, -2).c_str());
                            obsParams.push_back(key);

                            bool boolAux; // TODO(avancinirodrigo): review this vars
                            double numAux;
                            QString strAux;
							
							int luaType = lua->getTypeAt(luaL, -1);
                            if(lua->isBoolean(luaType))
                            {
                                boolAux = lua->toBooleanAt(luaL, -1);
							}
							else if(lua->isNumber(luaType))
                            {
                                numAux = lua->getNumberAtTop(luaL);
                                obsParamsAtribs.push_back(QString::number(numAux));
                            }
							else if(lua->isString(luaType))
                            {
                                strAux = lua->getStringAtTop(luaL).c_str();
                                obsParamsAtribs.push_back(QString(strAux));
                            }
                        }
                    }

                    lua->popOneElement(luaL);
                }
            }

            lua->popOneElement(luaL);
        }

        QString errorMsg = QString("Error: The Observer ID '%1' was not found. "
                                   "Check the declaration of this observer.\n").arg(obsID);

        if (!cellSpace)
		{
			lua->callError(luaL, errorMsg.toStdString());
        }

        QStringList neighIDs;
        QString exhibitionName;

        // Recupera os IDs das Vizinhancas a serem observadas
        lua->pushNil(luaL);
        while (lua->nextAt(luaL, top - 2) != 0)
        {
            const char* key = lua->getStringAtTop(luaL).c_str();
            this->attrNeighName.append(key);
            exhibitionName = QString("neighborhood(%1)").arg(this->attrNeighName);

            neighIDs.push_back(exhibitionName);
            observedAttribs.push_back(exhibitionName);

#ifdef TME_BLACK_BOARD
            // Solucao provisoria para o observer do tipo Neighbohrood
            observedAttribs.push_front("@getNeighborhoodState");
#endif
            lua->popOneElement(luaL);
        }

        if (typeObserver == TObsNeigh)
        {
            obsMap =(AgentObserverMap *)cellSpace->getObserver(obsID);

            if (!obsMap)
			{
				lua->callError(luaL, errorMsg.toStdString());
            }

            obsMap->registry(this, exhibitionName);
            obsMap->setAttributes(neighIDs, obsParams, obsParamsAtribs);
            obsMap->setSubjectAttributes(neighIDs, TObsNeighborhood, this->attrNeighName);
        }

        // @RAIAN: Acrescentei estas linhas para retornar o ID do observer, que estava faltando
        lua->pushNumber(luaL, obsID);
        return 1;
    }
    //@RAIAN - FIM
    return 0;
}

const TypesOfSubjects luaCell::getType()
{
    return subjectType;
}

/// Notifies observers about changes in the luaCell internal state
int luaCell::notify(lua_State *L)
{
    double time = lua->getNumberAtTop(L);

    CellSubjectInterf::notify(time);
    return 0;
}

QString luaCell::getAll(QDataStream & /*in*/, int /*observerId*/, QStringList& attribs)
{
    // @DANIEL
    // Responsabilidade da classe Reference
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua

	getReference(luaL);
    return pop(luaL, attribs);
}

QString luaCell::pop(lua_State *luaL, QStringList& attribs)
{
    double num = 0;
    bool boolAux = false;

    QString msg, attrs, key, text;

    int attrCounter = 0;
    int cellsPos = lua->getTopIndex(luaL);
    // int type = lua_type(luaL, cellsPos);

    // @RAIAN: Serializa a vizinhanca
    if (attribs.contains("@getNeighborhoodState"))
    {
#ifndef TME_BLACK_BOARD
        // solucao provisoria
        attribs.pop_back();
#endif

        QString elements;

        NeighCmpstInterf neighborhoods = this->getNeighborhoods();
        NeighCmpstInterf::iterator itAux = neighborhoods.begin();

        while (itAux != neighborhoods.end())
        {
            QString neighborhoodID(itAux->first.c_str());

            if (attribs.contains(QString("neighborhood(") + neighborhoodID + QString(")")))
            {
                // Neighborhood ID
                msg.append(QString("neighborhood(") + neighborhoodID + QString(")"));
                msg.append(PROTOCOL_SEPARATOR);

                // subject TYPE
                msg.append(QString::number(TObsNeighborhood));
                msg.append(PROTOCOL_SEPARATOR);

                // Pega as informacoe da ce'lula central(this)
                QString cellMsg = this->pop(luaL, QStringList() << "x" << "y");

                elements.append(cellMsg);

                CellNeighborhood *neigh = itAux->second;
                CellNeighborhood::iterator itNeigh = neigh->begin();
                int neighSize = neigh->size();

                //Number of Attributes - VARIFICAR SE ESTA CERTO
                msg.append(QString::number(0));
                msg.append(PROTOCOL_SEPARATOR);

                // Number of internal subjects
                msg.append(QString::number(neighSize + 1));
                msg.append(PROTOCOL_SEPARATOR);
                msg.append(PROTOCOL_SEPARATOR);

                while (itNeigh != neigh->end())
                {
                    luaCell* neighbor =(luaCell*)itNeigh->second;
                    CellIndex neighIdx =(CellIndex)itNeigh->first;
                    double weight = neigh->getWeight(neighIdx);

                    int ref = neighbor->getReference(luaL);
                    cellMsg = neighbor->pop(luaL, QStringList() << "x" << "y" << "@getWeight");
                    lua->setTop(luaL, 0);
				
                    cellMsg.append(QString::number(TObsNumber));
                    cellMsg.append(PROTOCOL_SEPARATOR);
                    cellMsg.append(QString::number(weight));
                    cellMsg.append(PROTOCOL_SEPARATOR);
                    cellMsg.append(PROTOCOL_SEPARATOR);

                    elements.append(cellMsg);

                    itNeigh++;
                }
            }
            itAux++;
        }

        msg.append(elements);
        msg.append(PROTOCOL_SEPARATOR);
    }// @RAIAN: FIM
    else
    {
        // id
        msg.append(QString::number(getId())); // QString("%1").arg(this->ref));
        msg.append(PROTOCOL_SEPARATOR);

        // subjectType
        msg.append(QString::number(subjectType));
        msg.append(PROTOCOL_SEPARATOR);


        lua->pushNil(luaL);
        while (lua->nextAt(luaL, cellsPos) != 0)
        {
            key = QString(lua->getStringAt(luaL, -2).c_str());

            if (attribs.contains(key))
            {
                attrCounter++;
                attrs.append(key);
                attrs.append(PROTOCOL_SEPARATOR);
				
				int luaType = lua->getTypeAt(luaL, -1);

				if(lua->isBoolean(luaType))
				{
                    boolAux = lua->toBooleanAt(luaL, -1);
                    attrs.append(QString::number(TObsBool));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString::number(boolAux));
                    attrs.append(PROTOCOL_SEPARATOR);
				}
				else if(lua->isNumber(luaType))
				{
                    num = lua->getNumberAtTop(luaL);
                    doubleToQString(num, text, 20);
                    attrs.append(QString::number(TObsNumber));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(text);
                    attrs.append(PROTOCOL_SEPARATOR);
				}
				else if(lua->isString(luaType))
				{
                    text = QString(lua->getStringAtTop(luaL).c_str());
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append((text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text));
                    attrs.append(PROTOCOL_SEPARATOR);
				}
				else if(lua->isTable(luaType))
                {
                    char result[100];
                    sprintf(result, "%p", lua->toPointerAt(luaL, -1));
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(TB): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                }
				else if(lua->isUserdata(luaType))
                {
                    char result[100];
                    sprintf(result, "%p", lua->toPointerAt(luaL, -1));
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(UD): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                }
				else if(lua->isFunction(luaType))
                {
                    char result[100];
                    sprintf(result, "%p", lua->toPointerAt(luaL, -1));
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(FT): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                }
				else
                {
                    char result[100];
                    sprintf(result, "%p", lua->toPointerAt(luaL, -1));
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(O): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }
            }

            lua->popOneElement(luaL);
        }

        //@RAIAN: Para uso na serializacao da Vizinhanca
        if (attribs.contains("@getWeight"))
        {
            attrCounter++;
            attrs.append("@getWeight");
            attrs.append(PROTOCOL_SEPARATOR);
        }
        //@RAIAN: FIM

        // #attrs
        msg.append(QString::number(attrCounter));
        msg.append(PROTOCOL_SEPARATOR);

        // #elements
        msg.append(QString::number(0));
        msg.append(PROTOCOL_SEPARATOR);

        msg.append(attrs);

        //@RAIAN: Para uso na serializacao da Vizinhanca
        if (!attribs.contains("@getWeight"))
            msg.append(PROTOCOL_SEPARATOR);
        //@RAIAN: FIM
    }

    return msg;
}

QString luaCell::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaCell::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaCell::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs)
#endif

{
    int obsCurrentState = 0; //serverSession->getState(observerId);
    QString content;

    switch (obsCurrentState)
    {
    case 0:
#ifdef TME_BLACK_BOARD
        content = getAll(in, observerId, observedAttribs);
#else
        content = getAll(in, observerId, attribs);
#endif
        // serverSession->setState(observerId, 1);
        // if (execModes == Quiet)
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
        break;

    case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
        // serverSession->setState(observerId, 0);
        // if (execModes == Quiet)
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}


int luaCell::kill(lua_State *luaL)
{
    int id = lua->getNumberAt(luaL, 1);

    bool result = CellSubjectInterf::kill(id);

    //@RAIAN: Para "matar" o observer Neighbohrood
    if (!result)
    {
        if (lua->isUserdataAt(luaL, 2, "TeCellularSpace"))
        {
            luaCellularSpace *cellSpace = terrame::lua::LuaBindingDelegate<luaCellularSpace>::getInstance().check(L, 2);

            if (cellSpace)
            {
                Observer *obs = cellSpace->getObserverById(id);
                if (obs)
                    result =((AgentObserverMap *)obs)->unregistry(this, this->attrNeighName);
            }
        }
    }
    //@RAIAN: FIM

    lua->pushBoolean(luaL, result);
    return 1;
}

/// Gets the luaCell position of the luaCell in the Lua stack
/// \param L is a pointer to the Lua stack
/// \param cell is a pointer to the cell within the Lua stack
// @DANIEL:
// Qual o motivo do encapsulamento?
//void getReference(lua_State *L, luaCell *cell)
//{
//    cell->getReference(L);
//}

