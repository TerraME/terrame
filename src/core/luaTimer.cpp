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

#include "luaTimer.h"
#include "luaEvent.h"
#include "luaMessage.h"
#include "terrameGlobals.h"

#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"

///< Global variable: Lua stack used for comunication with C++ modules.
extern lua_State * L;

///< true - TerrME runs in verbose mode and warning messages to the user;
/// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

luaTimer::luaTimer(lua_State *L)
{
    luaL = L;
    subjectType = TObsTimer;
    observedAttribs.clear();
}

/// Desctructor
luaTimer::~luaTimer(void)
{
}

/// Executes the luaTimer object
/// parameter: finalTime
int luaTimer::execute(lua_State *L)
{
    double finalTime = luaL_checknumber(L, -1);
    Scheduler::execute(finalTime);
    return 1;
}

/// Gets the luaTimer internal clock value
int luaTimer::getTime(lua_State *L)
{
    lua_pushnumber(L, Scheduler::getTime());
    return 1;
}

/// Return true if the luaTimer object is empty and has no luaEvents to execute
int luaTimer::isEmpty(lua_State *L)
{
    lua_pushnumber(L, Scheduler::empty());
    return 1;
}

/// Inserts a luaEvent - luaMessage pair in the luaTimer queue
/// parameters: luaEvent, luaMessage
int luaTimer::add(lua_State *L)
{
    luaEvent* event = Luna<luaEvent>::check(L, -2);
    luaMessage* message = Luna<luaMessage>::check(L, -1);
    Scheduler::add( *event, message );
    return 0;
}

/// Resets the luaTimer
int luaTimer::reset(lua_State *)
{
    Scheduler::reset();
    return 0;
}

int luaTimer::createObserver(lua_State *luaL)
{
    // recupero a referencia da celula
    Reference<luaTimer>::getReference(luaL);

    // flags para a defini(C)(C)o do uso de compress(C)o
    // na transmiss(C)o de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // Nao modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, top - 3);
    bool isGraphicType = (typeObserver == TObsDynamicGraphic)
            || (typeObserver == TObsGraphic);

    //------------------------
    QStringList allAttribs, obsAttribs;
    //QList<Triple> eventList;

    allAttribs.push_back(TIMER_KEY); // insere a chave TIMER_KEY atual
    // int eventsCount = 0;

    lua_pushnil(luaL);

    while(lua_next(luaL, top) != 0)
    {
        QString key;

        if (lua_type(luaL, -2) == LUA_TSTRING)
        {
            key = QString( luaL_checkstring(luaL, -2) );
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

        //---------------------------------------------------------------------------------------
        // recuperando o tipo Event que esta em uma subtabela
        // de Pair
        if (lua_type(luaL, -1) == LUA_TTABLE)
        {
            int pairTop = lua_gettop(luaL);
            //lua_gettable(luaL, pairTop);

            lua_pushnil(luaL);
            while(lua_next(luaL, pairTop) != 0)
            {
                const char* eventKey = "-";

                if (lua_type(luaL, -2) == LUA_TSTRING)
                {
                    eventKey = luaL_checkstring(luaL, -2);
                }
                else
                {
                    if (lua_type(luaL, -2) == LUA_TNUMBER)
                    {
                        char aux[100];
                        double number = luaL_checknumber(luaL, -2);
                        sprintf(aux, "%g", number);
                        eventKey = aux;
                    }
                }

                if ( (typeObserver == TObsScheduler) && (isudatatype(luaL, -1, "TeEvent")) )
                {
                    // QString ev(EVENT_KEY + QString::number(eventsCount));
                    QString ev("@");
                    ev.append(key);
                    allAttribs.push_back(ev);
                    // eventsCount++;
                }
                lua_pop(luaL, 1);
            }
        }
        //---------------------------------------------------------------------------------------

        if (typeObserver != TObsScheduler)
            allAttribs.push_back(key);

        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    //lua_settop(luaL, top - 1);
    //top = lua_gettop(luaL);

    // Verificacao da sintaxe da tabela Atributos
    if(!lua_istable(luaL, top))
    {
        string err_out = string("Error: Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customError");
        lua_pushstring(L, err_out.c_str());
        lua_pushnumber(L, 4);
        lua_call(L, 2, 0);
        return -1;
    }

    lua_pushnil(luaL);

    while(lua_next(luaL, top - 2 ) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );

        // Verifica se o atributo informado nao existe deve ter sido digitado errado
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
                string err_out = string("Error: Attribute name '" ) + string (qPrintable(key)) + string("' not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L, err_out.c_str());
				lua_pushnumber(L, 4);
				lua_call(L, 2, 0);
                return -1;
            }
        }
        lua_pop(luaL, 1);
    }

    if ((obsAttribs.empty() ) && (!isGraphicType))
    {
        obsAttribs = allAttribs;
        observedAttribs = allAttribs;
    }

    if(!lua_istable(luaL, top))
    {
        string err_out = string("Error: Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customError");
        lua_pushstring(L, err_out.c_str());
        lua_pushnumber(L, 5);
        lua_call(L, 2, 0);
        return 0;
    }

    QStringList cols;

    // Recupera a tabela de parametros os observadores do tipo Table e Graphic
    // caso nao seja um tabela a sintaxe do metodo esta incorreta
    lua_pushnil(luaL);
    while(lua_next(luaL, top - 1) != 0)
    {
        QString key;
        if (lua_type(luaL, -2) == LUA_TSTRING)
            key = QString( luaL_checkstring(luaL, -2));

        switch (lua_type(luaL, -1))
        {
        case LUA_TSTRING:
            {
                QString value( luaL_checkstring(luaL, -1));
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

    // Caso nao seja definido nenhum parametro,
    // e o observador nao e' TextScreen entao
    // lanca um warning
    if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
    {
        if (execModes != Quiet ){
            string err_out = string("Warning: Attribute table not found. Incorrect sintax.");
            lua_getglobal(L, "customWarning");
            lua_pushstring(L, err_out.c_str());
            lua_pushnumber(L, 4);
            lua_call(L, 2, 0);
        }
    }

    ObserverTextScreen *obsText = 0;
    ObserverTable *obsTable = 0;
    ObserverLogFile *obsLog = 0;
    ObserverUDPSender *obsUDPSender = 0;
    ObserverScheduler *obsScheduler = 0;

    int obsId = -1;

    switch (typeObserver)
    {
        case TObsTextScreen			:
            obsText = (ObserverTextScreen*)
                SchedulerSubjectInterf::createObserver(TObsTextScreen);
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
                SchedulerSubjectInterf::createObserver(TObsLogFile);
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
                SchedulerSubjectInterf::createObserver(TObsTable);
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

        case TObsUDPSender			:
            obsUDPSender = (ObserverUDPSender *)
                SchedulerSubjectInterf::createObserver(TObsUDPSender);
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

        case TObsScheduler			:
            obsScheduler = (ObserverScheduler *)
                SchedulerSubjectInterf::createObserver(TObsScheduler);
            if (obsScheduler)
            {
                obsId = obsScheduler->getId();
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
                string err_out = string("Warning: In this context, the code '")
                        + string(getObserverName(typeObserver))
                        + string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L, err_out.c_str());
                lua_pushnumber(L, 4);
                lua_call(L, 2, 0);
            }
            return 0;
    }

    /// Define alguns parametros do observador instanciado ---------------------------------------------------

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

        // caso nao seja definido, utiliza o default ";"
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
        if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
        {
            obsUDPSender->addHost(BROADCAST_HOST);
        }
        else
        {
            // multicast or unicast
            for(int i = 1; i < cols.size(); i++){
                if (!cols.at(i).isEmpty())
                    obsUDPSender->addHost(cols.at(i));
            }
        }
        lua_pushnumber(luaL, obsId);
        return 1;
    }

    if (obsScheduler)
    {
        obsScheduler->setAttributes(obsAttribs);
        lua_pushnumber(luaL, obsId);
        lua_pushlightuserdata(luaL, (void*) obsScheduler);

        return 2;
    }

    //printf("createObserver( lua_State *L ) performed\n");
    return 0;
}

const TypesOfSubjects luaTimer::getType()
{
    return this->subjectType;
}

int luaTimer::notify(lua_State *luaL)
{
    double time = luaL_checknumber(luaL, -1);
    SchedulerSubjectInterf::notify(time);
    return 0;
}

QString luaTimer::getAll(QDataStream& /*in*/, int /*observerId*/, QStringList& attribs)
{
    Reference<luaTimer>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaTimer::pop(lua_State *luaL, QStringList& attribs)
{
    double num = 0, minimumTime = 100000.0;
    int eventsCount = 0;
    bool boolAux = false;

    QString msg, attrs, key, text;

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int attrCounter = 0;
    // int attrParam = 0;
    int position = lua_gettop(luaL);

    lua_pushnil(luaL);
    while(lua_next(luaL, position ) != 0)
    {
        QString key;

        // Caso o indice nao seja um string causava erro
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

        // bool contains = attribs.contains(QString(key));
        if( attribs.contains(key) || attribs.contains("@" + key) )
        {
            attrCounter++;
            attrs.append(key);
            attrs.append(PROTOCOL_SEPARATOR);

            switch( lua_type(luaL, -1) )
            {
                case LUA_TBOOLEAN:
                    boolAux = lua_toboolean(luaL, -1);
                    attrs.append(QString::number(TObsBool));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString::number(boolAux));
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
                    attrs.append( (text.isEmpty() || text.isNull() ? VALUE_NOT_INFORMED : text) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;

                case LUA_TTABLE:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QString("Lua-Address(TB): ") + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    // Recuperando o objeto TeEvent
                    //{
                    int top = lua_gettop(luaL);

                    lua_pushnil(luaL);
                    while(lua_next(luaL, top) != 0)
                    {
                        QString eventKey;

                        if (lua_type(luaL, -2) == LUA_TSTRING)
                        {
                            eventKey = luaL_checkstring(luaL, -2);
                        }
                        else
                        {
                            if (lua_type(luaL, -2) == LUA_TNUMBER)
                            {
                                char aux[100];
                                double number = luaL_checknumber(luaL, -2);
                                sprintf(aux, "%g", number);
                                eventKey = aux;
                            }

                            // QString eventKey( QString(EVENT_KEY + QString::number(eventsCount)) );
                            eventKey = "@" + ( key );

                            if (isudatatype(luaL, -1, "TeEvent"))
                            {
                                Event* ev = (Event*)Luna<luaEvent>::check(L, -1);

                                double time = ev->getTime();
                                minimumTime = min(minimumTime, time);

                                attrCounter++;
                                attrs.append(eventKey);
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(time));
                                attrs.append(PROTOCOL_SEPARATOR);

                                attrCounter++;
                                attrs.append(eventKey);
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(ev->getPeriod()));
                                attrs.append(PROTOCOL_SEPARATOR);

                                attrCounter++;
                                attrs.append(eventKey);
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QString::number(ev->getPriority()));
                                attrs.append(PROTOCOL_SEPARATOR);

                                eventsCount++;
                            }
                        }
                        lua_pop(luaL, 1);
                    }
                    break;
                }
                case LUA_TUSERDATA:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText));
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

    attrCounter++;
    attrs.append(TIMER_KEY);
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(TObsText));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QString::number(minimumTime));
    attrs.append(PROTOCOL_SEPARATOR);

    // #attrs
    msg.append(QString::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );

    // #elements
    msg.append(QString::number(0));
    msg.append(PROTOCOL_SEPARATOR );

    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

QString luaTimer::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaTimer::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaTimer::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
            break;

        case 1:
#ifdef TME_BLACK_BOARD
        content = getChanges(in, observerId, observedAttribs);
#else
        content = getChanges(in, observerId, attribs);
#endif
            // serverSession->setState(observerId, 0);
            //if (execModes == Quiet )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

int luaTimer::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = SchedulerSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

int luaTimer::setObserver(lua_State* L)
{
    ObserverScheduler *obss = (ObserverScheduler*) lua_touserdata(L, -1);
    obs = obss;
    return 0;
}

int luaTimer::save(lua_State* L)
{
    std::string e = luaL_checkstring(L, -1);
    std::string f = luaL_checkstring(L, -2);
    obs->save(f, e);

    return 0;
}

