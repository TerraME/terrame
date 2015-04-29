/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C)  2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaLocalAgent.h
\brief This file definitions for the luaLocalAgent objects.
\author Tiago Garcia de Senna Carneiro
*/

#include "luaLocalAgent.h"

#include "luaUtils.h"
#include "luaControlMode.h"
#include "luaCell.h"
#include "luaCellularSpace.h"

#include "terrameGlobals.h"

#include <QtCore/QBuffer>
#include <QtCore/QByteArray>
#include <QtCore/QMutex>

#include "observerTextScreen.h"
#include "observerGraphic.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"
#include "agentObserverMap.h"
#include "agentObserverImage.h"
#include "observerStateMachine.h"

#include "protocol.pb.h"

/// < Global variable: Lua stack used for communication with C++ modules.
extern lua_State * L; 

/// < true - TerraME runs in verbose mode and warning messages to the user;
/// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

/// Constructor
luaLocalAgent::luaLocalAgent(lua_State *L)
{
    // Antonio
    luaL = L;
    subjectType = TObsAutomaton;
    whereCell = 0;
    attrClassName = "";
    cellSpace = 0;
    observedAttribs.clear();
}

///Destructor
luaLocalAgent::~luaLocalAgent(void)
{
    // luaL_unref( L, LUA_REGISTRYINDEX, ref);
}

/// Gets the simulation time elapsed since the last change in the luaLocalAgent internal discrete state
int luaLocalAgent::getLatency( lua_State *L)
{
    double time = LocalAgent::getLastChangeTime();
    lua_pushnumber(L, time);
    return 1;
}

/// Adds a new luaControlMod to the luaLocalAgent object
int luaLocalAgent::add(lua_State *L) {
    //void *ud;

    if( isudatatype(L, -1, "TeState") )
    {
        //cout << "aqui" << endl;
        ControlMode* lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
        ControlMode &cm = *lcm;
        LocalAgent::add( cm );
    }
    else
    {
        if( isudatatype(L, -1, "TeTrajectory") )
        {
            luaRegion& actRegion = *(( luaRegion* ) Luna<luaTrajectory>::check(L, -1));
            ActionRegionCompositeInterf& actRegions = luaLocalAgent::getActionRegions();
            actRegions.add( actRegion );
        }
    }
    return 0;
}

/// Executes the luaLocalAgent object
/// parameter: luaEvent
int luaLocalAgent::execute( lua_State* L){ 
    luaEvent* ev = Luna<luaEvent>::check(L, -1);
    LocalAgent::execute( *ev );
    return 0;
}

/// Sets the luaLocalAgent "Action Region" status to true, than luaLocalAgent
/// object will traverse its internal
/// luaTrajectory objects
/// parameter: boolean
int luaLocalAgent::setActionRegionStatus( lua_State* L)
{
    bool status = lua_toboolean( L, -1);
    LocalAgent::setActionRegionStatus( status );
    return 0;
}

/// Gets the luaLocalAgent "Action Region" status to true, than luaLocalAgent
/// object will traverse its internal
/// luaTrajectory objects
/// parameter: boolean
int luaLocalAgent::getActionRegionStatus( lua_State* L)
{
    bool status = LocalAgent::getActionRegionStatus( );
    lua_pushboolean(L,status);
    return 1;
}
/// Builds the luaLocalAgent object
int luaLocalAgent::build( lua_State *){ 
    if( ! Agent::build() )
    {
		string errorMsg = string("You must add a state to the agent before use "
								 "it as a jump condition targert...");
		lua_getglobal(L, "customError");
		lua_pushstring(L,errorMsg.c_str());
		//lua_pushnumber(L,5);
		lua_call(L,1,0);
        return 0;
    }
    return 0;
}

int luaLocalAgent::createObserver( lua_State *L )
{
#ifdef DEBUG_OBSERVER
    luaStackToQString(12);
    stackDump(luaL);
#endif

    // retrieve the reference of the cell
    Reference<luaAgent>::getReference(luaL);
        
    // flags for the definition of the use of compression
    // in the datagram transmission and visibility
    // of observers Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // retrieve the attribute table of the cell
    int top = lua_gettop(luaL);

    // In no way changes the stack
    // retrieves the enum for the type
    // of observer
    int typeObserver = (int)luaL_checkinteger(luaL, 1); //top - 3);

    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        bool isGraphicType = (typeObserver == TObsDynamicGraphic)
            || (typeObserver == TObsGraphic);

        //------------------------
        QStringList allAttribs, obsAttribs;
        QList<QPair<QString, QString> > allStates;

#ifdef DEBUG_OBSERVER
        stackDump(luaL);
        printf("\npos table: %i\nRecuperando todos os atributos:\n", top);
#endif

        // // Runs the Lua stack recovering all cell attributes
        lua_pushnil(luaL);
        while(lua_next(luaL, top ) != 0)
        {
            QString key;

            switch (lua_type(luaL, -2))
            {
            case LUA_TSTRING:
                key = QString(luaL_checkstring(luaL, -2));
                break;

            case LUA_TNUMBER:
                {
                    char aux[100];
                    double number = luaL_checknumber(luaL, -2);
                    sprintf(aux, "%g", number);
                    key = QString(aux);
                    break;
                }
            default:
                break;
            }

            // Recover the states of TeState
            if (isudatatype(luaL, -1, "TeState") )
            {
                ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                QString state, transition;
                state.append(lcm->getControlModeName().c_str());

                // Adds the state attribute in the parameter list
                // allAttribs.push_back( state );

                // Recover the transition states
                ProcessCompositeInterf::iterator prIt;
                prIt = lcm->ProcessCompositeInterf::begin();

                JumpCompositeInterf::iterator jIt;
                jIt = prIt->JumpCompositeInterf::begin();

                while (jIt != prIt->JumpCompositeInterf::end())
                {
                    transition = QString( (*jIt)->getTargetControlModeName().c_str());
                    jIt++;
                }

                // creates a pair (state, transition) and adds in the list of states
                allStates.push_back(qMakePair(state, transition));
            }
            allAttribs.push_back(key);
            lua_pop(luaL, 1);
        }

        // Add the currentState in the observer
        allAttribs.push_back("currentState"); // inserts the current state

        //------------------------
        // runs the moon stack recovering the
        // attributes cell that wants to observe
        lua_settop(luaL, top - 1);
        top = lua_gettop(luaL);

        // Syntax checking Attributes table
        if(! lua_istable(luaL, top) )
        {
            string errorMsg = string("Attributes table not found. Incorrect sintax.");
			lua_getglobal(L, "customError");
			lua_pushstring(L,errorMsg.c_str());
			//lua_pushnumber(L,5);
			lua_call(L,1,0);
			return 0;
        }

#ifdef DEBUG_OBSERVER
        printf("\npos table: %i\nRetrieving the Attributes table:\n", top - 1);
        stackDump(luaL);
#endif

        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1 ) != 0)
        {
            QString key = luaL_checkstring(luaL, -1);

            // Checks if the given attribute exists or
            // may have been mistyped
            if (allAttribs.contains(key))
            {
                obsAttribs.push_back(key);
                if (! observedAttribs.contains(key))
                    // observedAttribs.push_back(key);
                    observedAttribs.insert(key, "");
            }
            else
            {
                if ( ! key.isNull() || ! key.isEmpty())
                {
					string err_out = string("Attribute name '" ) + string (qPrintable(key)) + string("' not found.");
					lua_getglobal(L, "customError");
					lua_pushstring(L,err_out.c_str());
					//lua_pushnumber(L,4);
					lua_call(L,1,0);
                    return -1;
                }
            }
            lua_pop(luaL, 1);
        }
        //------------------------

        // Add the currentState in the observer
        if ((obsAttribs.empty() ) && (! isGraphicType))
        {
            obsAttribs = allAttribs;
            // observedAttribs = allAttribs;
            
            foreach(const QString &key, allAttribs)
                observedAttribs.insert(key, "");  
        }
            
        //------------------------
        if(! lua_istable(luaL, top) )
        {
            string errorMsg = string("Parameter table not found. Incorrect sintax.");
			lua_getglobal(L, "customError");
			lua_pushstring(L,errorMsg.c_str());
			//lua_pushnumber(L,5);
			lua_call(L,1,0);
			return 0;
        }

#ifdef DEBUG_OBSERVER
        printf("\n*pos table: %i\nRecuperando a tabela Parametros\n", top);
        stackDump(luaL);
#endif

        QStringList obsParams, obsParamsAtribs; // parameters/attributes of the legend
        QStringList cols;
        bool isLegend = false;

        // Retrieves the parameters table
        lua_pushnil(luaL);
        while(lua_next(luaL, top) != 0)
        {
            QString key;
            if (lua_type(luaL, -2) == LUA_TSTRING)
                key = QString(luaL_checkstring(luaL, -2));

            switch (lua_type(luaL, -1))
            {
            case LUA_TSTRING:
            {
                QString value(luaL_checkstring(luaL, -1));
                cols.push_back(value);
                break;
            }
            case LUA_TBOOLEAN:
            {
                bool val = lua_toboolean(luaL, -1);
                if (key == "visible") 
                    obsVisible = val;
                else // if (key == "compress")
                    compressDatagram = val;
                break;
            }
            
            // Retrieves the cell you want to watch the automaton
            case LUA_TTABLE:
                {
                    int paramTop = lua_gettop(luaL);
                    QString value;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, paramTop) != 0)
                    {
                        if (lua_type(luaL, -2) == LUA_TSTRING)
                        {
                            value = QString(luaL_checkstring(luaL, -2));

                            if (value == "cObj_")
                            {
                                //int cellTop = lua_gettop(luaL);
                                //lua_pushstring(luaL, "cObj_");
                                //lua_gettable(luaL, cellTop);

                                whereCell = (luaCell*)Luna<luaCell>::check(L, -1);
                                // lua_pop(luaL, 1); // lua_pushstring
                            }

                            if (isLegend)
                            {
                                // bool boolAux;
                                const char *strAux;
                                double numAux = -1;

                                obsParams.push_back(value);

                                switch( lua_type(luaL, -1) )
                                {
                                case LUA_TBOOLEAN:
                                    // boolAux = lua_toboolean(luaL, -1);
                                    // obsParamsAtribs.push_back(QString::number(boolAux));
                                    break;

                                case LUA_TNUMBER:
                                    numAux = luaL_checknumber(luaL, -1);
                                    obsParamsAtribs.push_back(QString::number(numAux));
                                    break;

                                case LUA_TSTRING:
                                    strAux = luaL_checkstring(luaL, -1);
                                    obsParamsAtribs.push_back(QString(strAux));
                                    break;

                                case LUA_TNIL:
                                case LUA_TTABLE:
                                default:
                                    break;
                                }
                            }
                        }
                        lua_pop(luaL, 1);
                    }
                    isLegend = true;
                }
            default:
                break;
            }
            lua_pop(luaL, 1);
        }

        // If not set any parameters and the
        // observer are not TextScreen then
        // launches a warning
        if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
        {
            if (execModes != Quiet ){
                string err_out = string("The parameter table is empty.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,5);
                lua_call(L,1,0);
            }
        }
        //------------------------

        ObserverTextScreen *obsText = 0;
        ObserverTable *obsTable = 0;
        ObserverGraphic *obsGraphic = 0;
        ObserverLogFile *obsLog = 0;
        ObserverUDPSender *obsUDPSender = 0;
        ObserverStateMachine *obsStateMachine = 0;

        int obsId = -1;
        // QStringList attrs;

        switch (typeObserver)
        {
        case TObsTextScreen:
            obsText = (ObserverTextScreen *) 
                LocalAgentSubjectInterf::createObserver(TObsTextScreen);
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
            obsLog = (ObserverLogFile *) 
                LocalAgentSubjectInterf::createObserver(TObsLogFile);
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
                LocalAgentSubjectInterf::createObserver(TObsTable);
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

        case TObsUDPSender:
            obsUDPSender = (ObserverUDPSender *) 
                LocalAgentSubjectInterf::createObserver(TObsUDPSender);
            if (obsUDPSender)
            {
                obsId = obsUDPSender->getId();
                obsUDPSender->setCompress(compressDatagram);

                if (obsVisible)
                    obsUDPSender->show();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsStateMachine:
            obsStateMachine = (ObserverStateMachine *) 
                LocalAgentSubjectInterf::createObserver(TObsStateMachine);
            if (obsStateMachine)
            {
                obsId = obsStateMachine->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case TObsDynamicGraphic:
            obsGraphic = (ObserverGraphic *) 
                LocalAgentSubjectInterf::createObserver(TObsDynamicGraphic);
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
                LocalAgentSubjectInterf::createObserver(TObsGraphic);
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

        default:
            if (execModes != Quiet )
            {
                qWarning("In this context, the code '%s' does not correspond to a "
                "valid type of Observer.",  getObserverName(typeObserver) );
            }
            return 0;
        }

        /// Defines some parameters of the instantiated observer -------------------------------------
        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);

            if (cols.at(0).isNull() || cols.at(0).isEmpty())
            {
                if (execModes != Quiet )
                {
                    qWarning("Filename was not specified, using a "
                        "default \"%s\".", qPrintable(DEFAULT_NAME));
                }
                obsLog->setFileName(DEFAULT_NAME + ".csv");
            }
            else
            {
                obsLog->setFileName(cols.at(0));
            }

            // if not defined, use the default ";"
            if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet )
                    qWarning("Separator not defined, using \";\".");
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
            if ((cols.size() < 1) || (cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
                || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet )
                    qWarning("Column title not defined.");
            }
            obsTable->setColumnHeaders(cols);
            obsTable->setAttributes(obsAttribs);

            lua_pushnumber(luaL, obsId);
            return 1;
        }

        if (obsUDPSender)
        {
            obsUDPSender->setAttributes(obsAttribs);

            // if(cols.at(0).isEmpty())
            if (cols.isEmpty())
            {
                if (execModes != Quiet )
                    qWarning("Port not defined.");
            }
            else
            {
                obsUDPSender->setPort(cols.at(0).toInt());
            }

            // broadcast
            if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
            {
                obsUDPSender->addHost(BROADCAST_HOST);
            }
            else
            {
                // multicast or unicast
                for(int i = 1; i < cols.size(); i++){
                    if (! cols.at(i).isEmpty())
                        obsUDPSender->addHost(cols.at(i));
                }
            }
            lua_pushnumber(luaL, obsId);
            return 1;
        }

        if (obsGraphic)
        {
            obsGraphic->setLegendPosition();

            // if (obsAttribs.contains("currentState"))
            //    obsGraphic->setCurveStyle();

            // Takes titles of three first locations
            obsGraphic->setTitles(cols.at(0), cols.at(1), cols.at(2));   
            cols.removeFirst(); // remove graphic title
            cols.removeFirst(); // remove axis x title
            cols.removeFirst(); // remove axis y title

            // Splits the attribute labels in the cols list
            obsGraphic->setAttributes(obsAttribs, cols.takeFirst().split(";", QString::SkipEmptyParts), 
                obsParams, obsParamsAtribs);

            lua_pushnumber(luaL, obsId);
            return 1;
        }

        ///////////////////////////////////////////

        if (obsStateMachine)
        {
            obsStateMachine->addState(allStates);
            obsStateMachine->setAttributes(obsAttribs, obsParams, obsParamsAtribs);

            lua_pushnumber(luaL, obsId);
            return 1;
        }
    } // typeObserver !=  TerraMEObserver::TObsMap)
    else
    {
        QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda

        bool getObserverID = false, isLegend = false;
        int obsID = -1;

        AgentObserverMap *obsMap = 0;
        AgentObserverImage *obsImage = 0;

        // Retrieves the parameters
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            // Retrieves the observer map ID
            if ( (lua_isnumber(luaL, -1) && (! getObserverID)) )
            {
                // obsID = lua_tonumber(luaL, paramTop - 1);
                obsID = luaL_checknumber(luaL, -1);
                getObserverID = true;
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

                            switch( lua_type(luaL, -1) )
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

        QString errorMsg = QString("The Observer ID \"%1\" was not found. "
            "Check the declaration of this observer.\n").arg(obsID);

        if (! cellSpace)
		{
			lua_getglobal(L, "customError");
			lua_pushstring(L,errorMsg.toLatin1().data());
			//lua_pushnumber(L,5);
			lua_call(L,1,0);
			return 0;
		}

        QStringList allAttribs, obsAttribs;

        // Retrieves all agent attributes
        // seeking only the agent class
        lua_pushnil(luaL);
        while(lua_next(luaL, top ) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                QString key;
                key = QString(luaL_checkstring(luaL, -2));

                if (key == "class")
                    attrClassName = luaL_checkstring(luaL, -1);
            }
            lua_pop(luaL, 1);
        }

        attrClassName.push_front(" (");
        attrClassName.push_back(")");

        if (typeObserver == TObsMap)
        {
            obsMap = (AgentObserverMap *)cellSpace->getObserver(obsID);

            if (! obsMap)
			{
				lua_getglobal(L, "customError");
				lua_pushstring(L,errorMsg.toLatin1().data());
				//lua_pushnumber(L,5);
				lua_call(L,1,0);
				return 0;
			}

            obsMap->registry(this, attrClassName);
        }
        else
        {
            obsImage = (AgentObserverImage *)cellSpace->getObserver(obsID);

            if (! obsImage)
			{
				lua_getglobal(L, "customError");
				lua_pushstring(L,errorMsg.toLatin1().data());
				//lua_pushnumber(L,5);
				lua_call(L,1,0);
				return 0;
			}

            obsImage->registry(this, attrClassName);
        }

        // Retrieves the attributes
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            QString key = QString(luaL_checkstring(luaL, -1));

            if (key == "currentState")
                obsAttribs.push_back(key + attrClassName);
            else
                obsAttribs.push_back(key);

            lua_pop(luaL, 1);
        }
        
        for(int i = 0; i < obsAttribs.size(); i++)
        {
            if (! observedAttribs.contains(obsAttribs.at(i)) )
                // observedAttribs.push_back(obsAttribs.at(i));
                observedAttribs.insert(obsAttribs.at(i), "");
        }

        if (typeObserver == TObsMap)
        {
            // to set the values of the agent attributes,
        	// redefine the type of attributes in the super class ObserverMap
            obsMap->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsAutomaton);
            obsMap->setSubjectAttributes(obsAttribs, getId(), attrClassName);
        }
        else // (typeObserver == obsImage)
        {
            obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsAutomaton);
            obsImage->setSubjectAttributes(obsAttribs, getId(), attrClassName);
        }
        lua_pushnumber(luaL, obsID);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaLocalAgent::getType() const
{
    return subjectType;
}

int luaLocalAgent::notify(lua_State *luaL)
{
    double time = luaL_checknumber(luaL, -1);
    LocalAgentSubjectInterf::notify(time);
    return 0;
}

#ifdef TME_BLACK_BOARD

QDataStream& luaLocalAgent::getState(QDataStream& in, Subject *, int /*observerId*/, const QStringList & /* attribs */)
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
        content = getAll(in, observedAttribs.keys());
        // serverSession->setState(observerId, 1);
        // if (! QUIET_MODE )
        // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(1).toLatin1().constData());
        break;

    case 1:
        content = getChanges(in, observedAttribs.keys());
        // serverSession->setState(observerId, 0);
        // if (! QUIET_MODE )
        // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(0).toLatin1().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#else // TME_BLACK_BOARD

QDataStream& luaLocalAgent::getState(QDataStream& in, Subject *, int observerId, const QStringList &  attribs )
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
        // if (execModes == Quiet )
        // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(1).toLatin1().constData());
        break;

    case 1:
        content = getChanges(in, observerId, attribs);
        // serverSession->setState(observerId, 0);
        // if (execModes == Quiet )
        // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(0).toLatin1().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#endif // TME_BLACK_BOARD

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaLocalAgent::getAll(QDataStream& /*in*/, const QStringList& attribs)
{
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, getRef());	// I retrieve the reference in the stack lua
	Reference<luaAgent>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute autSubj;
    return pop(luaL, attribs, &autSubj, 0);
}

QByteArray luaLocalAgent::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}

QByteArray luaLocalAgent::pop(lua_State * /*luaL*/, const QStringList& attribs, 
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
	const QStringList coordList = QStringList() << "x" << "y";
    
    bool valueChanged = false;
    char result[20];
    double num = 0.0;

    // I retrieve the reference in the stack lua
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    int position = lua_gettop(luaL);

    QByteArray key, valueTmp;
    const QByteArray currState = "currentState" + attrClassName;
    ObserverDatagramPkg::RawAttribute *raw = 0;
    
    // Runs through the cells of the space
    // retrieving the state automaton
    if (lua_istable(luaL, position - 1))
    {
        lua_pushnil(luaL);
        while ( lua_next(luaL, position - 1) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
                key = luaL_checkstring(luaL, -2);

            if (key == "cells")
            {
                int top = lua_gettop(luaL);

                lua_pushnil(luaL);
                while(lua_next(luaL, top) != 0)
                {
                    int cellTop = lua_gettop(luaL);
                    lua_pushstring(luaL, "cObj_");
                    lua_gettable(luaL, cellTop);

                    luaCell*  cell;
                    cell = (luaCell*)Luna<luaCell>::check(luaL, -1);
                    lua_pop(luaL, 1); // lua_pushstring

                    // luaCell->popCell(...) It requires a cell on top of the stack
                    //int internalCount = currSubj->internalsubject_size();
                    //cell->pop(L, attribs, 0, currSubj);

                    // qDebug() << "automaton pop()" << cell->getId() << "... " 
                    //      << internalCount << currSubj->internalsubject_size();
                    
                    ControlMode *ctrlMode = cell->getControlMode(this);
                        
                    if (ctrlMode)
                    {
                        valueTmp = ctrlMode->getControlModeName().c_str();

                        // if (observedAttribs.value(currState) != valueTmp)
                        {
                            if ((parentSubj) && (! currSubj))
                                currSubj = parentSubj->add_internalsubject();

                            ObserverDatagramPkg::SubjectAttribute *cellSubj = currSubj->add_internalsubject();

                            raw = cellSubj->add_rawattributes();
                            raw->set_key(currState);
                            raw->set_text(valueTmp);

                            cellSubj->set_id( cell->getId() );
                            cellSubj->set_type( ObserverDatagramPkg::TObsCell ); 
                            cellSubj->set_attribsnumber( cellSubj->rawattributes_size() );
                            cellSubj->set_itemsnumber( cellSubj->internalsubject_size() );
                            
                            valueChanged = true;
                            // observedAttribs.insert(currState, valueTmp);
                        }
                    }
                    else
                    {
                        if (execModes != Quiet ){
                            QString str = QString("Could not find the Automaton inside an Environment object.");
                            lua_getglobal(L, "customWarning");
                            lua_pushstring(L,str.toLatin1().constData());
                            //lua_pushnumber(L,5);
                            lua_call(L,1,0);
                        }
                    }

                    lua_pop(luaL, 1);
                }
            }
            lua_pop(luaL, 1);
        }
    }

    lua_pushnil(luaL);
    while(lua_next(luaL, position) != 0)
    {
        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key = luaL_checkstring(luaL, -2);
        }
        else
        {
            if (lua_type(luaL, -2) == LUA_TNUMBER)
            {
                sprintf(result, "%g", luaL_checknumber(luaL, -2) );
                key = result;
            }
        }

        if (attribs.contains(key))
        {
            switch( lua_type(luaL, -1) )
            {
            case LUA_TBOOLEAN:
                valueTmp = QByteArray::number( lua_toboolean(luaL, -1) );

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_number(valueTmp.toDouble());

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                doubleToText(num, valueTmp, 20);

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_number(num);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TSTRING:
                valueTmp = luaL_checkstring(luaL, -1);

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;

            case LUA_TTABLE:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_TABLE + valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }

            case LUA_TUSERDATA:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_USER_DATA + valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }

                //if (isudatatype(luaL, -1, "TeState"))
                //{
                //    ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                //    QByteArray state(lcm->getControlModeName().c_str());
                //    attrCounter++;
                //    attrs.append(state);
                //    attrs.append(PROTOCOL_SEPARATOR);
                //    attrs.append(QByteArray::number(TObsText));
                //    attrs.append(PROTOCOL_SEPARATOR);
                //    attrs.append(state);
                //    attrs.append(PROTOCOL_SEPARATOR);
                //}
                break;
            }

            case LUA_TFUNCTION:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_FUNCTION + valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }

            default:
            {
                sprintf(result, "%p", lua_topointer(luaL, -1) );
                valueTmp = result;

                if (observedAttribs.value(key) != valueTmp)
                {
                    if ((parentSubj) && (! currSubj))
                        currSubj = parentSubj->add_internalsubject();

                    raw = currSubj->add_rawattributes();
                    raw->set_key(key);
                    raw->set_text(LUA_ADDRESS_OTHER + valueTmp);

                    valueChanged = true;
                    observedAttribs.insert(key, valueTmp);
                }
                break;
            }
            }
        }
        lua_pop(luaL, 1);
    }

    key = "currentState";
    if (attribs.contains(key))
    {
        valueTmp = "Where?";
        if (whereCell)
        {
            ControlMode *ctrlMode = whereCell->getControlMode(this);
            if (ctrlMode)
            {
                valueTmp = ctrlMode->getControlModeName().c_str();
            }
            else
            {
                if (execModes != Quiet ){
                    QString str = QString("Could not find the Automaton inside an Environment object.");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L,str.toLatin1().constData());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
            }
        }

        if (observedAttribs.value(key) != valueTmp)
        {
            if ((parentSubj) && (! currSubj))
                currSubj = parentSubj->add_internalsubject();

            raw = currSubj->add_rawattributes();
            raw->set_key(key.constData());
            raw->set_text(valueTmp);

            valueChanged = true;
            observedAttribs.insert(key, valueTmp);
        }
    }

    if (valueChanged)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        // id
        currSubj->set_id(getId());

        // subjectType
        currSubj->set_type(ObserverDatagramPkg::TObsAutomaton);

        // #attrs
        currSubj->set_attribsnumber( currSubj->rawattributes_size() );

        // #elements
        currSubj->set_itemsnumber( currSubj->internalsubject_size() );

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

#else // TME_PROTOCOL_BUFFERS 

QByteArray luaLocalAgent::getAll(QDataStream& /*in*/, int /*observerId*/, const QStringList& attribs)
{
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, getRef());	// recupero a referencia na pilha lua
	Reference<luaAgent>::getReference(luaL);
    return pop(luaL, attribs);
}

QByteArray luaLocalAgent::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

QByteArray luaLocalAgent::pop(lua_State *luaL, const QStringList& attribs)
{
    QByteArray msg;

	QStringList coordList = QStringList() << "x" << "y";

    // id
    msg.append(QByteArray::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append("7"); // QByteArray::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int position = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QByteArray text, key, attrs, elements;

    // Runs through the cells of the space
    // retrieving the state automaton
    if (lua_istable(luaL, position - 1))
    {
        lua_pushnil(luaL);
        while ( lua_next(luaL, position - 1) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
                key = luaL_checkstring(luaL, -2);

            if (key == "cells")
            {
                int top = lua_gettop(luaL);

                lua_pushnil(luaL);
                while(lua_next(luaL, top) != 0)
                {
                    int cellTop = lua_gettop(luaL);
                    lua_pushstring(luaL, "cObj_");
                    lua_gettable(luaL, cellTop);

                    luaCell*  cell;
                    cell = (luaCell*)Luna<luaCell>::check(luaL, -1);
                    lua_pop(luaL, 1); // lua_pushstring

                    // luaCell->popCell(...) requer uma celula no topo da pilha
#ifdef TME_PROTOCOL_BUFFERS
                    QByteArray cellMsg = cell->pop(luaL, coordList, 0, 0);
#else
                    QByteArray cellMsg = cell->pop(luaL, coordList);
#endif

                    cellMsg.append("currentState" + attrClassName);
                    cellMsg.append(PROTOCOL_SEPARATOR);
                    cellMsg.append(QByteArray::number(TObsText));
                    cellMsg.append(PROTOCOL_SEPARATOR);

                    ControlMode *ctrlMode = cell->getControlMode(this);

                    cellMsg.append(ctrlMode->getControlModeName().c_str());
                    cellMsg.append(PROTOCOL_SEPARATOR);

                    // Adiciona o atributo currentState no protocolo
                    int idx = cellMsg.indexOf(PROTOCOL_SEPARATOR);
                    QByteArray attNum = ((const char *)&cellMsg[idx + 3]);
                    cellMsg.replace(idx + 3, 1, attNum.setNum(attNum.toInt() + 1));

                    elements.append(cellMsg);
                    elementCounter++;
                        
                    lua_pop(luaL, 1);
                }
            }
            lua_pop(luaL, 1);
        }
    }

    lua_pushnil(luaL);
    while(lua_next(luaL, position) != 0)
    {
        // If the index is the one string causing error
        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key = luaL_checkstring(luaL, -2));
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

        bool contains = attribs.contains(key);

        if (contains)
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch( lua_type(luaL, -1) )
            {
            case LUA_TBOOLEAN:
                attrs.append(QByteArray::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(lua_toboolean(luaL, -1));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TNUMBER:
                num = luaL_checknumber(luaL, -1);
                doubleToText(num, text, 20);
                attrs.append(QByteArray::number(TObsNumber));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(text);
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TSTRING:
                text = luaL_checkstring(luaL, -1);
                attrs.append(QByteArray::number(TObsText) );
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append( (text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text) );
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TTABLE:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua Address(TB): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                }
                break;

            case LUA_TUSERDATA:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );

                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(UD): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    //if (isudatatype(luaL, -1, "TeState"))
                    //{
                    //    ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                    //    QByteArray state(lcm->getControlModeName().c_str());
                    //    attrCounter++;
                    //    attrs.append(state);
                    //    attrs.append(PROTOCOL_SEPARATOR);
                    //    attrs.append(QByteArray::number(TObsText));
                    //    attrs.append(PROTOCOL_SEPARATOR);
                    //    attrs.append(state);
                    //    attrs.append(PROTOCOL_SEPARATOR);
                    //}
                    break;
                }

            case LUA_TFUNCTION:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(FT): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            default:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(O): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }
            }
        }
        lua_pop(luaL, 1);
    }

    if (attribs.contains("currentState"))
    {
        QString currState;

        attrCounter++;
        attrs.append("currentState");
        attrs.append(PROTOCOL_SEPARATOR);
        attrs.append(QByteArray::number(TObsText));
        attrs.append(PROTOCOL_SEPARATOR);

        currState = "Where?";
        if (whereCell)
        {
            ControlMode *cm = whereCell->getControlMode(this);
            if (cm)
            {
                currState= cm->getControlModeName().c_str();
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string("Could not find the Automaton inside an Environment object.");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
            }
        }

        attrs.append(currState);
        attrs.append(PROTOCOL_SEPARATOR);
    }

    msg.append(QByteArray::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(QByteArray::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

#endif

int luaLocalAgent::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);
    bool result = false;

    result = LocalAgentSubjectInterf::kill(id);

    if (! result)
    {
        if (cellSpace)
        {
            Observer *obs = cellSpace->getObserverById(id);

            if (obs)
            {        
                if (obs->getType() == TObsMap)
                    result = ((AgentObserverMap *)obs)->unregistry(this, attrClassName);
                else
                    result = ((AgentObserverImage *)obs)->unregistry(this, attrClassName);
            }
        }
    }
    lua_pushboolean(luaL, result);
    return 1;
}
