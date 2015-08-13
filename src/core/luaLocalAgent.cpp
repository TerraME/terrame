/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright  2001-2007 INPE and Tecgraf/PUC-Rio.

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

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/agentObserverMap.h"
#include "../observer/types/agentObserverImage.h"
#include "../observer/types/observerStateMachine.h"


/// < Gobal variabel: Lua stack used for comunication with C++ modules.
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
    notNotify = false;
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
    float time = LocalAgent::getLastChangeTime();
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

/// Sets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent 
/// object will traverse its internal
/// luaTrajectory objects
/// parameter: boolean
int luaLocalAgent::setActionRegionStatus( lua_State* L)
{
    bool status = lua_toboolean( L, -1);
    LocalAgent::setActionRegionStatus( status );
    return 0;
}

/// Gets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent 
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
        qFatal( "Error: you must add a control mode to the agent before use "
            "it as a jump condition targert..." );
        return 0;
    }
    return 0;
}

int luaLocalAgent::createObserver( lua_State *L )
{
    // recupero a referencia da celula
    Reference<luaAgent>::getReference(luaL);
        
    // flags para a defini(C)(C)o do uso de compress(C)o
    // na transmiss(C)o de datagramas e da visibilidade
    // dos observadores Udp Sender 
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de atributos da celula
    int top = lua_gettop(luaL);

    // No modifica em nada a pilha recupera o enum
    // referente ao tipo do observer
    int typeObserver = (int)luaL_checkinteger(luaL, 1); //top - 3);

    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        bool isGraphicType = (typeObserver == TObsDynamicGraphic)
            || (typeObserver == TObsGraphic);

        //------------------------
        QStringList allAttribs, obsAttribs;
        QList<QPair<QString, QString> > allStates;

        // Pecorre a pilha lua recuperando
        // todos os atributos celula
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

            // Recupero os estados do TeState
            if (isudatatype(luaL, -1, "TeState") )
            {
                ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                QString state, transition;
                state.append(lcm->getControlModeName().c_str());

                // Adiciona o estado do atributo na lista de parametros
                // allAttribs.push_back( state );

                // Recupero a transi(C)(C)o dos estados
                ProcessCompositeInterf::iterator prIt;
                prIt = lcm->ProcessCompositeInterf::begin();

                JumpCompositeInterf::iterator jIt;
                jIt = prIt->JumpCompositeInterf::begin();

                while (jIt != prIt->JumpCompositeInterf::end())
                {
                    transition = QString( (*jIt)->getTargetControlModeName().c_str());
                    jIt++;
                }

                // cria um par (estado, transi(C)(C)o) e adiciona na lista de estados
                allStates.push_back(qMakePair(state, transition));
            }
            allAttribs.push_back(key);
            lua_pop(luaL, 1);
        }

        // Adiciono o currentState no observador
        allAttribs.push_back("currentState"); // insere o estado atual

        //------------------------
        // pecorre a pilha lua recuperando
        // os atributos celula que se quer observar
        lua_settop(luaL, top - 1);
        top = lua_gettop(luaL);

        // Verificao da sintaxe da tabela Atributos
        if(! lua_istable(luaL, top) )
        {
            qFatal("Error: Attributes table not found. Incorrect sintax.\n");
            return -1;
        }

        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1 ) != 0)
        {
            QString key = luaL_checkstring(luaL, -1);

            // Verifica se o atributo informado existe
            // ou pode ter sido digitado errado
            if (allAttribs.contains(key))
            {
                obsAttribs.push_back(key);
                if (! observedAttribs.contains(key))
                    observedAttribs.push_back(key);
            }
            else
            {
                if ( ! key.isNull() || ! key.isEmpty())
                {
					string err_out = string("Error: Attribute name '" ) + string (qPrintable(key)) + string("' not found.");
					lua_getglobal(L, "customError");
					lua_pushstring(L,err_out.c_str());
					lua_pushnumber(L,4);
					lua_call(L,2,0);
                    return -1;
                }
            }
            lua_pop(luaL, 1);
        }
        //------------------------

        // Adiciono o currentState no observador
        if ((obsAttribs.empty() ) && (! isGraphicType))
        {
            obsAttribs = allAttribs;
            observedAttribs = allAttribs;
        }
            
        //------------------------
        if(! lua_istable(luaL, top) )
        {
            qFatal("Error: Parameter table not found. Incorrect sintax.\n");
            return -1;
        }

        QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda
        QStringList cols;
        bool isLegend = false;

        // Recupera a tabela de parametros
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
            
            // Recupera a celula que se deseja observar o automato
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

        // Caso no seja definido nenhum parametro e o observador no TextScreen entao
        // lanca uma falha
        if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
        {
            if (execModes != Quiet ){
                string err_out = string("Warning: The parameter table is empty.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,5);
                lua_call(L,2,0);
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
                qWarning("Warning: In this context, the code '%s' does not correspond to a "
                "valid type of Observer.",  getObserverName(typeObserver) );
            }
            return 0;
        }

        /// Define alguns parametros do observador instanciado -------------------------------------
        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);

            if (cols.at(0).isNull() || cols.at(0).isEmpty())
            {
                if (execModes != Quiet )
                {
                    qWarning("Warning: Filename was not specified, using a "
                        "default \"%s\".", qPrintable(DEFAULT_NAME));
                }
                obsLog->setFileName(DEFAULT_NAME + ".csv");
            }
            else
            {
                obsLog->setFileName(cols.at(0));
            }

            // caso no seja definido, utiliza o default ";"
            if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet )
                    qWarning("Warning: Separator not defined, using \";\".");
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
                    qWarning("Warning: Column title not defined.");
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
                    qWarning("Warning: Port not defined.");
            }
            else
            {
                obsUDPSender->setPort(cols.at(0).toInt());
            }

            // broadcast
            if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
            {
                if (execModes != Quiet ){
                    string err_out = string("Warning: Observer will send broadcast.");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L,err_out.c_str());
                    lua_pushnumber(L,5);
                    lua_call(L,2,0);
                }
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

        // Recupera os parametros
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            // Recupera o ID do observer map
            if ( (lua_isnumber(luaL, -1) && (! getObserverID)) )
            {
                // obsID = lua_tonumber(luaL, paramTop - 1);
                obsID = luaL_checknumber(luaL, -1);
                getObserverID = true;
                isLegend = true;
            }

            // recupera o espao celular
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

        QString errorMsg = QString("\nError: The Observer ID \"%1\" was not found. "
            "Check the declaration of this observer.\n").arg(obsID);

        if (! cellSpace)
            qFatal("%s", qPrintable(errorMsg));

        QStringList allAttribs, obsAttribs;

        // Recupera todos os atributos do agente
        // buscando apenas o classe do agente
        lua_pushnil(luaL);
        while(lua_next(luaL, top ) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                QString key;
                key = QString(luaL_checkstring(luaL, -2));

                if (key == "class")
                    attrClassName = QString(luaL_checkstring(luaL, -1));
            }
            lua_pop(luaL, 1);
        }

        attrClassName.push_front(" (");
        attrClassName.push_back(")");

        if (typeObserver == TObsMap)
        {
            obsMap = (AgentObserverMap *)cellSpace->getObserver(obsID);

            if (! obsMap)
                qFatal("%s", qPrintable(errorMsg));

            obsMap->registry(this, attrClassName);
        }
        else
        {
            obsImage = (AgentObserverImage *)cellSpace->getObserver(obsID);

            if (! obsImage)
                qFatal("%s", qPrintable(errorMsg));

            obsImage->registry(this, attrClassName);
        }

        // Recupera os atributos
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
                observedAttribs.push_back(obsAttribs.at(i));
        }

        if (typeObserver == TObsMap)
        {
            // ao definir os valores dos atributos do agente,
            // redefino o tipo do atributos na super classe ObserverMap
            obsMap->setAttributes(obsAttribs, obsParams, obsParamsAtribs);
            obsMap->setSubjectAttributes(obsAttribs, TObsAutomaton, attrClassName);
        }
        else // (typeObserver == obsImage)
        {
            obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs);
            obsImage->setSubjectAttributes(obsAttribs, TObsAutomaton, attrClassName);
        }
        lua_pushnumber(luaL, obsID);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaLocalAgent::getType()
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
QDataStream& luaLocalAgent::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaLocalAgent::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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
        // if (execModes == Quiet )
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
        break;

    case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
        // serverSession->setState(observerId, 0);
        // if (execModes == Quiet )
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
        break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

QString luaLocalAgent::getAll(QDataStream& /*in*/, int /*observerId*/, QStringList& attribs)
{
    Reference<luaAgent>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaLocalAgent::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

QString luaLocalAgent::pop(lua_State *luaL, QStringList& attribs)
{
    QString msg;

    if (notNotify)
        return msg;

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int position = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements; 

    QStringList coordList = QStringList() << "x" << "y";

    // Percorre as celulas do espa(C)o recuperando o
    // estado do automato
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
                    cell = (luaCell*)Luna<luaCell>::check(L, -1);
                    lua_pop(luaL, 1); // lua_pushstring

                    // luaCell->popCell(...) requer uma celula no topo da pilha
                    QString cellMsg = cell->pop(L, coordList);

                    ControlMode *ctrlMode = cell->getControlMode(this);

                    if (ctrlMode)
                    {
                        cellMsg.append("currentState" + attrClassName);
                        cellMsg.append(PROTOCOL_SEPARATOR);
                        cellMsg.append(QString::number(TObsText));
                        cellMsg.append(PROTOCOL_SEPARATOR);

                        cellMsg.append(ctrlMode->getControlModeName().c_str());
                        cellMsg.append(PROTOCOL_SEPARATOR);

                        // Adiciona o atributo currentState no protocolo
                        int idx = cellMsg.indexOf(PROTOCOL_SEPARATOR);
                        QString attNum = QString(cellMsg[idx + 3]);
                        cellMsg.replace(idx + 3, 1, attNum.setNum(attNum.toInt() + 1));

                        elements.append(cellMsg);
                        elementCounter++;
                    }
                    else
                    {
                        notNotify = true;
                        
                        if (execModes != Quiet)
                        {
                            string err_out = string("Warning: Failed on retrieve Automaton subject state!!");
                            lua_getglobal(L, "customWarning");
                            lua_pushstring(L, err_out.c_str());
                            lua_pushnumber(L,4);
                            lua_call(L,2,0);
                        }
                        return QString();
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
        // Caso o indice no seja um string causava erro
        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key = QString(luaL_checkstring(luaL, -2));
        }
        else
        {
            if (lua_type(luaL, -2) == LUA_TNUMBER)
            {
                char aux[100];
                double number = luaL_checknumber(luaL, -2);
                sprintf(aux, "%g", number);
                key = QString(aux);
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
                attrs.append(QString::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(lua_toboolean(luaL, -1));
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
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua Address(TB): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                }
                break;

            case LUA_TUSERDATA:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );

                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(UD): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    //if (isudatatype(luaL, -1, "TeState"))
                    //{
                    //    ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                    //    QString state(lcm->getControlModeName().c_str());
                    //    attrCounter++;
                    //    attrs.append(state);
                    //    attrs.append(PROTOCOL_SEPARATOR);
                    //    attrs.append(QString::number(TObsText));
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

    if (attribs.contains("currentState"))
    {
        QString currState;

        attrCounter++;
        attrs.append("currentState");
        attrs.append(PROTOCOL_SEPARATOR);
        attrs.append(QString::number(TObsText));
        attrs.append(PROTOCOL_SEPARATOR);

        currState = "Where?";
        if (whereCell)
        {
            ControlMode *cm = whereCell->getControlMode(this);
            if (cm)
            {
                currState= QString(cm->getControlModeName().c_str());
            }
            else
            {
                if (execModes != Quiet){
                    string err_out = string("Warning: Could not find the Automaton inside an Environment object.");
                    lua_getglobal(L, "customWarning");
                    lua_pushstring(L,err_out.c_str());
                    lua_pushnumber(L,5);
                    lua_call(L,2,0);
                }
            }
        }

        attrs.append(currState);
        attrs.append(PROTOCOL_SEPARATOR);
    }

    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(QString::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

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
