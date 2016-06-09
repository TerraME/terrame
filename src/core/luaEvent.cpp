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

/*! \file luaEvent.cpp
    \brief This file contains implementation for the luaEvent objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaEvent.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"

extern lua_State * L;

///< true - TerrME runs in verbose mode and warning messages to the user;
/// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

/// constructor
luaEvent::luaEvent(lua_State *L)
{
    subjectType = TObsEvent;
    luaL = L;
    observedAttribs.clear();
}

/// destructor
luaEvent::~luaEvent(void)
{
}

/// Constructor - creates a luaEvent object from a Event object
/// \param event is the copied Event object
luaEvent::luaEvent(Event &event)
{
    Event::config(event.getTime(), event.getPeriod(), event.getPriority());
}

/// Configures the luaEvent object
int luaEvent::config(lua_State *L)
{
    double time = luaL_checknumber(L, -3);
    double period = luaL_checknumber(L, -2);
    double priority = luaL_checknumber(L, -1);
    Event::config(time, period, priority);
    return 0;
}

/// Gets the luaEvent time
int luaEvent::getTime(lua_State *L)
{
    double time = Event::getTime();
    lua_pushnumber(L, time);
    return 1;
}

/// Gets the luaEvent priority
int luaEvent::getPriority(lua_State *L)
{
    double priority = Event::getPriority();
    lua_pushnumber(L, priority);
    return 1;
}

/// Sets the luaEvent priority
/// parameters: number
int luaEvent::setPriority(lua_State *L)
{
    int priority = luaL_checknumber(L, -1);
    Event::setPriority(priority);
    return 0;
}

/// Gets the luaEvent periodicity
int luaEvent::getPeriod(lua_State *L)
{
    double time = Event::getPeriod();
    lua_pushnumber(L, time);
    return 1;
}

/// Creates an observer
int luaEvent::createObserver(lua_State *luaL)
{
    Reference<luaEvent>::getReference(luaL);

    // flags para a defini??o do uso de compress?o
    // na transmiss?o de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

    int top = lua_gettop(luaL);
    int typeObserver =(int)luaL_checkinteger(luaL, 1);

    QStringList allAttribs, cols;

    allAttribs.push_back("EventTime");
    allAttribs.push_back("Periodicity");
    allAttribs.push_back("Priority");

    lua_pushnil(luaL);
    while (lua_next(luaL, top - 1) != 0)
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
        default:
            break;
        }
        lua_pop(luaL, 1);
    }

    if (cols.isEmpty())
    {
        if (execModes != Quiet){
            string err_out = string("Warning: The parameter table is empty.");
            lua_getglobal(L, "customWarning");
            lua_pushstring(L, err_out.c_str());
            lua_pushnumber(L, 5);
            lua_call(L, 2, 0);
        }
        cols << "" << "";
    }

    ObserverTextScreen *obsText = 0;
    ObserverTable *obsTable = 0;
    ObserverLogFile *obsLog = 0;
    ObserverUDPSender *obsUDPSender = 0;

    int obsId = -1;

    switch (typeObserver)
    {
        case TObsTextScreen:
            obsText =(ObserverTextScreen*) EventSubjectInterf::createObserver(TObsTextScreen);
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
            obsLog =(ObserverLogFile*) EventSubjectInterf::createObserver(TObsLogFile);
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
            obsTable =(ObserverTable *) EventSubjectInterf::createObserver(TObsTable);
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
            obsUDPSender =(ObserverUDPSender *) EventSubjectInterf::createObserver(TObsUDPSender);
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
                qWarning("Error: In this context, the code '%s' does not "
                    "correspond to a valid type of Observer.",  getObserverName(typeObserver));
            }
            return 0;
    }

    QStringList obsAttribs;
    obsAttribs = allAttribs;
    observedAttribs = allAttribs;

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

        obsLog->setFileName(cols.at(0));

        // caso n?o seja definido, utiliza o default ";"
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
        lua_pushnumber(luaL, obsId);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaEvent::getType()
{
    return subjectType;
}

int luaEvent::getType(lua_State *L)
{
    lua_pushnumber(L, subjectType);
    return 1;
}

/// Notifies observers
int luaEvent::notify(lua_State *luaL)
{
    double time = luaL_checknumber(luaL, -1);
    EventSubjectInterf::notify(time);
    return 0;
}

QString luaEvent::pop(lua_State *, QStringList &)
{
    QString msg, attrs;

    // id
    msg.append(QString::number(getId())); // QString("%1").arg(this->ref));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int attrCounter = 3;
    // int position = lua_gettop(luaL);

    attrs.append("EventTime");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(Event::getTime()));
    attrs.append(PROTOCOL_SEPARATOR);

    attrs.append("Periodicity");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(Event::getPeriod()));
    attrs.append(PROTOCOL_SEPARATOR);

    attrs.append("Priority");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(Event::getPriority()));
    attrs.append(PROTOCOL_SEPARATOR);

    // #attrs
    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR);

    // #elements
    msg.append(QString::number(0));
    msg.append(PROTOCOL_SEPARATOR);

    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

QString luaEvent::getAll(QDataStream& /*in*/, int /*observerId*/, QStringList& attribs)
{
    Reference<luaEvent>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaEvent::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

/// Get the object internal state (serialization)
#ifdef TME_BLACK_BOARD
QDataStream& luaEvent::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaEvent::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs)
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
            break;
        case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
            break;
    }
    in << content;
    return in;
}

int luaEvent::kill(lua_State *luaL)
{
    Reference<luaEvent>::getReference(luaL);

    int top = lua_gettop(luaL);;
    int id = -1;
    bool result = false;

    if (!lua_istable(luaL, top - 1))
    {
        id = luaL_checknumber(luaL, top - 1);
        result = EventSubjectInterf::kill(id);
        lua_pushboolean(luaL, result);
        return 1;
    }
    else
    {
        QString key;
        lua_pushnil(luaL);
        while (lua_next(luaL, top - 1) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);

                if (key == "id")
                {
                    id = luaL_checknumber(luaL, -1);
                    result = EventSubjectInterf::kill(id);
                    // break;

                    lua_pushboolean(luaL, result);
                    return 1;
                }
            }
            lua_pop(luaL, 1);
        }
    }

    lua_pushboolean(luaL, result);
    return 1;
}

