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
/*! \file luaEvent.cpp
    \brief This file contains implementation for the luaEvent objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaEvent.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

#include "observerTextScreen.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"

#include "protocol.pb.h"

///< Global variable: Lua stack used for communication with C++ modules.
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
    double priority = luaL_checknumber(L, -1);
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
#ifdef DEBUG_OBSERVER
    stackDump(luaL);
#endif

    // retrieve the reference of the cell
    Reference<luaEvent>::getReference(luaL);

    
    // flags for the definition of the use of compression
    // in the datagram transmission and visibility
    // of observers Udp Sender
    bool compressDatagram = false, obsVisible = true;

    int top = lua_gettop(luaL);
    int typeObserver = (int)luaL_checkinteger(luaL, 1);

    QStringList allAttribs, cols;

    allAttribs.push_back("Time");
    allAttribs.push_back("Periodicity");
    allAttribs.push_back("Priority");

    // Retrieves the parameters table
    //if(! lua_istable(luaL, top - 1))
    //{
    //    if (execModes == Quiet)
    //        qWarning("Warning: Parameter table not found.");
    //}
    //else
    //{
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 1) != 0)
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
    // }

    if (cols.isEmpty())
    {
        if (execModes != Quiet){
            string err_out = string("The parameter table is empty.");
            lua_getglobal(L, "customWarning");
            lua_pushstring(L, err_out.c_str());
            lua_call(L, 1, 0);
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
            obsText = (ObserverTextScreen*) EventSubjectInterf::createObserver(TObsTextScreen);
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
            obsLog = (ObserverLogFile*) EventSubjectInterf::createObserver(TObsLogFile);
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
            obsTable = (ObserverTable *) EventSubjectInterf::createObserver(TObsTable);
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
            obsUDPSender = (ObserverUDPSender *) EventSubjectInterf::createObserver(TObsUDPSender);
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
    // observedAttribs = allAttribs;

    foreach(const QString &key, allAttribs)
        observedAttribs.insert(key, 0.0);

    /// Defines some parameters of the instantiated observer ---------------------------------------------------

    if (obsLog)
    {
        obsLog->setAttributes(obsAttribs);

        if (cols.at(0).isNull() || cols.at(0).isEmpty())
        {
            if (execModes != Quiet)
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

        // if not defined, use the default ";"
        if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (execModes != Quiet)
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
            if (execModes != Quiet)
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

        if (cols.isEmpty())
        {
            if (execModes != Quiet)
                qWarning("Warning: Port not defined.");
        }
        else
        {
            obsUDPSender->setPort(cols.at(0).toInt());
        }

        // broadcast
        if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()))
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
    return 0;
}

const TypesOfSubjects luaEvent::getType() const
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
#ifdef DEBUG_OBSERVER
    printf("\nevent::notifyObservers\n");
    luaStackToQString(12);
    stackDump(luaL);
#endif
    
    double time = luaL_checknumber(luaL, -1);
    EventSubjectInterf::notify(time);
    return 0;
}

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaEvent::getAll(QDataStream& /*in*/, const QStringList& attribs)
{
//    lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// I retrieve the reference in the stack lua
    Reference<luaEvent>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute evSubj;
    return pop(luaL, attribs, &evSubj, 0);
}

QByteArray luaEvent::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}

QByteArray luaEvent::pop(lua_State * /*L*/, const QStringList& /*attribs*/, 
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
    bool valueChanged = false;

    QByteArray key;
    double valueTmp = 0.0;
    ObserverDatagramPkg::RawAttribute *raw = 0;

    // Time event
    key = "Time";
    valueTmp = Event::getTime();
    if (observedAttribs.value(key) != valueTmp)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        raw = currSubj->add_rawattributes();
        raw->set_key(key);
        raw->set_number((double)valueTmp);

        valueChanged = true;
        observedAttribs.insert(key, valueTmp);
    }

    // Periodicity
    key = "Periodicity";
    valueTmp = Event::getPeriod();
    if (observedAttribs.value(key) != valueTmp)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        raw = currSubj->add_rawattributes();
        raw->set_key(key);
        raw->set_number((double)valueTmp);

        valueChanged = true;
        observedAttribs.insert(key, valueTmp);
    }

    // Priority
    key = "Priority";
    valueTmp = (double) Event::getPriority();
    if (observedAttribs.value(key) != valueTmp)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        raw = currSubj->add_rawattributes();
        raw->set_key(key);
        raw->set_number((double)valueTmp);

        valueChanged = true;
        observedAttribs.insert(key, valueTmp);
    }
            
    if (valueChanged)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

    	// id
        currSubj->set_id(getId());

        // subjectType
        currSubj->set_type(ObserverDatagramPkg::TObsEvent);

        // #attrs
        currSubj->set_attribsnumber(currSubj->rawattributes_size());

        // #elements
        currSubj->set_itemsnumber(currSubj->internalsubject_size());

        if (! parentSubj)
        {
            QByteArray byteArray(currSubj->SerializeAsString().c_str(), currSubj->ByteSize());

#ifdef DEBUG_OBSERVER
            std::cout << currSubj->DebugString();
            std::cout.flush();
#endif
            return byteArray;
        }
    }
    return QByteArray();
}

#else

QByteArray luaEvent::getAll(QDataStream& /*in*/, int /*observerId*/, const QStringList& attribs)
{
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recover the reference on the stack lua
    Reference<luaEvent>::getReference(luaL);
    return pop(luaL, attribs);
}

QByteArray luaEvent::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

QByteArray luaEvent::pop(lua_State *, const QStringList &)
{
    QByteArray msg, attrs;

    // id
    msg.append(QByteArray::number(getId())); // QString("%1").arg(this->ref));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append("5"); //QByteArray::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int attrCounter = 3;
    // int position = lua_gettop(luaL);

    attrs.append("EventTime");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(Event::getTime()));
    attrs.append(PROTOCOL_SEPARATOR);

    attrs.append("Periodicity");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(Event::getPeriod()));
    attrs.append(PROTOCOL_SEPARATOR);

    attrs.append("Priority");
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(TObsNumber));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(Event::getPriority()));
    attrs.append(PROTOCOL_SEPARATOR);

    // #attrs
    msg.append(QByteArray::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR);

    // #elements
    msg.append("0");
    msg.append(PROTOCOL_SEPARATOR);

    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

#endif

#ifdef TME_BLACK_BOARD

QDataStream& luaEvent::getState(QDataStream& in, Subject *, int /*observerId*/, const QStringList & /* attribs */)
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
            // if (! QUIET_MODE)
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
            content = getChanges(in, observedAttribs.keys());
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

#else

QDataStream& luaEvent::getState(QDataStream& in, Subject *, int observerId, const QStringList &  attribs)
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
            // if (! QUIET_MODE)
            // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
        content = getChanges(in, observerId, attribs);
            // serverSession->setState(observerId, 0);
            // if (! QUIET_MODE)
            // qWarning(QString("Observer %1 it went to the state %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#endif

int luaEvent::kill(lua_State *luaL)
{
    // retrieve the reference of the cell
    Reference<luaEvent>::getReference(luaL);

    int top = lua_gettop(luaL);;
    int id = -1;
    bool result = false;

    // checks if the parameter is a table
    // or own id Observer
    if (! lua_istable(luaL, top - 1))
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
        while(lua_next(luaL, top - 1) != 0)
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
