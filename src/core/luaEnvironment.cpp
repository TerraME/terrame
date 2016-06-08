/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

#include "luaEnvironment.h"
#include "luaTimer.h"
#include "luaCellularSpace.h"
#include "luaGlobalAgent.h"
#include "terrameGlobals.h"

// Observadores
#include "../observer/types/observerTable.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerUDPSender.h"

extern ExecutionModes execModes;

luaEnvironment::luaEnvironment(lua_State *L)
{
    id = lua_tostring(L, -1);
    Environment::envId = id;

    // Antonio
    luaL = L;
    subjectType = TObsEnvironment;
    observedAttribs.clear();
}

int luaEnvironment::add(lua_State *L)
{
    void *ud;
    if (isudatatype(L, -1, "TeTimer"))
    {
        pair<Event, Scheduler>  timeSchedulerPair;
        Scheduler* pTimer = Luna<luaTimer>::check(L, -1);

        timeSchedulerPair.first = pTimer->getEvent();
        timeSchedulerPair.second = *pTimer;

        Environment::add(timeSchedulerPair);
    }
    else
        if (isudatatype(L, -1, "TeCellularSpace"))
        {
            CellularSpace* pCS = Luna<luaCellularSpace>::check(L, -1);
            Environment::add(*pCS);
        }
        else
            if (isudatatype(L, -1, "TeLocalAutomaton"))
            {
                LocalAgent* pAg = Luna<luaLocalAgent>::check(L, -1);
                Environment::add(*pAg);
            }
            else
                if (isudatatype(L, -1, "TeGlobalAutomaton"))
                {
                    GlobalAgent* pAg = Luna<luaGlobalAgent>::check(L, -1);
                    Environment::add(*pAg);
                }
                else
                    if ((ud = luaL_checkudata(L, -1, "TeScale")) != NULL)
                    {
                        pair<Event, Environment>  timeEnvPair;
                        Environment* pEnv = Luna<luaEnvironment>::check(L, -1);

                        timeEnvPair.first = pEnv->getEvent();
                        timeEnvPair.second = *pEnv;

                        Environment::add(timeEnvPair);
                    }
    return 0;
}

int luaEnvironment::addTimer(lua_State *L)
{
    pair<Event, Scheduler>  timeSchedulerPair;
    Scheduler* pTimer = Luna<luaTimer>::check(L, -1);

    timeSchedulerPair.first = lua_tonumber(L, -2);
    timeSchedulerPair.second = *pTimer;

    Environment::add(timeSchedulerPair);

    return 0;
}

int luaEnvironment::addCellularSpace(lua_State *L)
{
    CellularSpace* pCS = Luna<luaCellularSpace>::check(L, -1);
    Environment::add(*pCS);

    return 0;
}

int luaEnvironment::addLocalAgent(lua_State *L) {
    LocalAgent* pAg = Luna<luaLocalAgent>::check(L, -1);
    Environment::add(*pAg);

    return 0;
};

int luaEnvironment::addGlobalAgent(lua_State *L)
{
    GlobalAgent* pAg = Luna<luaGlobalAgent>::check(L, -1);
    Environment::add(*pAg);

    return 0;
};

int luaEnvironment::config(lua_State *L)
{
    float finalTime = lua_tonumber(L, -1);
    Environment::config(finalTime);

    return 0;
}

int luaEnvironment::execute(lua_State *)
{
    Environment::execute();
    return 0;
}

// @DANIEL
// Movido para classe Reference
//int luaEnvironment::setReference(lua_State* L)
//{
//    ref = luaL_ref(L, LUA_REGISTRYINDEX);
//    return 0;
//}
//
//int luaEnvironment::getReference(lua_State *L)
//{
//    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//    return 1;
//}

int luaEnvironment::createObserver(lua_State *luaL)
{
    // recupero a referencia da celula
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    Reference<luaEnvironment>::getReference(luaL);

    // flags para a defini??o do uso de compress?o
    // na transmiss?o de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // N?o modifica em nada a pilha
    // recupera o enum referente ao tipo
    // do observer
    TypesOfObservers typeObserver =(TypesOfObservers)luaL_checkinteger(luaL, -4);
    bool isGraphicType =(typeObserver == TObsDynamicGraphic) ||(typeObserver == TObsGraphic);

    //------------------------
    QStringList allAttribs, obsAttribs;

    // Pecorre a pilha lua recuperando todos os atributos celula
    lua_pushnil(luaL);
    while (lua_next(luaL, top) != 0)
    {
        QString key;

        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key  = luaL_checkstring(luaL, -2);
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

        allAttribs.push_back(key);
        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    lua_settop(luaL, top - 1);
    top = lua_gettop(luaL);

    if (!lua_istable(luaL, top))
    {
        //printf("\nError: Attributes table not found. Incorrect sintax.\n");
        qFatal("Error: Attributes table not found. Incorrect sintax.\n");
        return -1;
    }

    lua_pushnil(luaL);
    while (lua_next(luaL, top - 1) != 0)
    {
        QString key;

        if (lua_type(luaL, -1) == LUA_TSTRING)
        {
            key = luaL_checkstring(luaL, -1);
        }
        else
        {
            if (lua_type(luaL, -1) == LUA_TNUMBER)
            {
                char aux[100];
                double number = luaL_checknumber(luaL, -1);
                sprintf(aux, "%g", number);
                key = aux;
            }
        }

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
                string err_out = string("Error: Attribute name '") + string(qPrintable(key)) + string("' not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				lua_pushnumber(L, 5);
				lua_call(L, 2, 0);
                return -1;
            }
        }
        lua_pop(luaL, 1);
    }

    if ((obsAttribs.empty()) && (!isGraphicType))
    {
        obsAttribs = allAttribs;
        observedAttribs = allAttribs;
    }

    if (!lua_istable(luaL, top))
    {
        qFatal("Error: Parameter table not found. Incorrect sintax.");
        return -1;
    }

    QStringList cols, obsParams;

    // Recupera a tabela de parametros os observadores do tipo Table e Graphic
    // caso n?o seja um tabela a sintaxe do metodo esta incorreta
    lua_pushnil(luaL);
    while (lua_next(luaL, top) != 0)
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
            }

		case LUA_TTABLE:
		    {
                int tableTop = lua_gettop(luaL);

		        lua_pushnil(luaL);
		        while (lua_next(luaL, tableTop) != 0)
                {
		            if (lua_type(luaL, -2) == LUA_TSTRING)
		                obsParams.append(luaL_checkstring(luaL, -2));

		            switch (lua_type(luaL, -1))
                    {
                        case LUA_TNUMBER:
                            cols.append(QString::number(luaL_checknumber(luaL, -1)));
                            break;

                        case LUA_TSTRING:
		                    cols.append(luaL_checkstring(luaL, -1));
                            break;
                    }
            		lua_pop(luaL, 1);
                }
            }

        default:
            break;
        }
        lua_pop(luaL, 1);
    }

    ObserverTextScreen *obsText = 0;
    ObserverTable *obsTable = 0;
    ObserverGraphic *obsGraphic = 0;
    ObserverLogFile *obsLog = 0;
    ObserverUDPSender *obsUDPSender = 0;

    int obsId = -1;

    switch (typeObserver)
    {
        case TObsTextScreen:
            obsText =(ObserverTextScreen*)
                EnvironmentSubjectInterf::createObserver(TObsTextScreen);
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
                EnvironmentSubjectInterf::createObserver(TObsLogFile);
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
                EnvironmentSubjectInterf::createObserver(TObsTable);
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
                EnvironmentSubjectInterf::createObserver(TObsDynamicGraphic);
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
                EnvironmentSubjectInterf::createObserver(TObsGraphic);
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
                EnvironmentSubjectInterf::createObserver(TObsUDPSender);
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
            if (execModes != Quiet)
            {
                qWarning("Warning: In this context, the code '%s' does not "
                         "correspond to a valid type of Observer.",  getObserverName(typeObserver));
            }
            return 0;
    }

    if (obsLog)
    {
        obsLog->setAttributes(obsAttribs);

        if (cols.at(0).isNull() || cols.at(0).isEmpty())
        {
            obsLog->setFileName(DEFAULT_NAME + ".csv");
        }
        else
        {
            obsLog->setFileName(cols.at(0));
        }

        if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
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
        obsTable->setColumnHeaders(cols);
        obsTable->setAttributes(obsAttribs);

        lua_pushnumber(luaL, obsId);
        return 1;
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

		lua_pushnumber(luaL, obsId);
		return 1;
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
            for (int i = 1; i < cols.size(); i++)
            {
                if (!cols.at(i).isEmpty())
                    obsUDPSender->addHost(cols.at(i));
            }
        }
        lua_pushnumber(luaL, obsId);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaEnvironment::getType()
{
    return subjectType;
}

int luaEnvironment::notify(lua_State *)
{
    double time = luaL_checknumber(luaL, -1);

    EnvironmentSubjectInterf::notify(time);
    return 0;
}

/// Destructor
luaEnvironment::~luaEnvironment(void)
{
    // @DANIEL
    // luaL_unref(L, LUA_REGISTRYINDEX, ref);
}

QString luaEnvironment::pop(lua_State *luaL, QStringList& /*attribs*/)
{
    QString msg;

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    // recupero a referencia na pilha lua
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    Reference<luaEnvironment>::getReference(luaL);

    int environPos = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements;

    lua_pushnil(luaL);
    while (lua_next(luaL, environPos) != 0)
    {
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

        attrCounter++;
        attrs.append(key);
        attrs.append(PROTOCOL_SEPARATOR);

        switch (lua_type(luaL, -1))
        {
            case LUA_TBOOLEAN:
                attrs.append(QString::number(TObsBool));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString::number(lua_toboolean(luaL, -1)));
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
                attrs.append(QString::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append((text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text));
                attrs.append(PROTOCOL_SEPARATOR);
                break;

            case LUA_TTABLE:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1));
                attrs.append(QString::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(TB): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);

                break;
            }

            case LUA_TUSERDATA:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1));
                attrs.append(QString::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(UD):") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }

            case LUA_TFUNCTION:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1));
                attrs.append(QString::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(FT): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }

            default:
            {
                char result[100];
                sprintf(result, "%p", lua_topointer(luaL, -1));
                attrs.append(QString::number(TObsText));
                attrs.append(PROTOCOL_SEPARATOR);
                attrs.append(QString("Lua-Address(O): ") + QString(result));
                attrs.append(PROTOCOL_SEPARATOR);
                break;
            }
        }

        lua_pop(luaL, 1);
    }


    // #attrs
    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR);

    // #elements
    msg.append(QString::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR);
    msg.append(attrs);

    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);
    return msg;
}

QString luaEnvironment::getAll(QDataStream& /*in*/, int /*observerId*/ , QStringList &attribs)
{
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
    Reference<luaEnvironment>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaEnvironment::getChanges(QDataStream& in, int observerId , QStringList &attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaEnvironment::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaEnvironment::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs)
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
            // if (! QUIET_MODE)
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
            // serverSession->setState(observerId, 0);
            // if (! QUIET_MODE)
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

int luaEnvironment::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = EnvironmentSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

