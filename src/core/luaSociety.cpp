/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright © 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaSociety.cpp
    \brief This file contains the implementation for the luaSociety objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaSociety.h"
//#include "luaNeighborhood.h"

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/agentObserverMap.h"
#include "../observer/types/agentObserverImage.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
// Estatisticas de desempenho
#include "../observer/statistic/statistic.h"
#endif

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;
extern ExecutionModes execModes;

/// Constructor
luaSociety::luaSociety(lua_State *L)
{
    luaL = L;
    subjectType = TObsSociety;
    observedAttribs.clear();

    attrNeighName = "";
}

/// destructor
// @DANIEL
// não misturar gerência de memória de C++ com o lado Lua
// luaSociety::~luaSociety( void ) { luaL_unref( L, LUA_REGISTRYINDEX, ref); }
luaSociety::~luaSociety( void ) { }

/// Registers the luaSociety object in the Lua stack
// @DANIEL
// Movido para clsse Reference
//int luaSociety::setReference( lua_State* L)
//{
//    ref = luaL_ref(L, LUA_REGISTRYINDEX );
//    return 0;
//}

/// Gets the luaSociety object reference
// @DANIEL
// Movido para clsse Reference
//int luaSociety::getReference( lua_State *L )
//{
//    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//    return 1;
//}

/// Gets the luaSociety identifier
int luaSociety::getID( lua_State *L )
{
    lua_pushstring(L, objectId_.c_str() );
    return 1;
}

/// Sets the luaSociety identifier
int luaSociety::setID( lua_State *L )
{
    const char* id = luaL_checkstring( L , -1);
    objectId_ = string( id );
    return 0;
}

/// Creates several types of observers
/// parameters: observer type, observeb attributes table, observer type parameters
// verif. ref (endereco na pilha lua)
// olhar a classe event
int luaSociety::createObserver( lua_State * )
{
    // recupero a referencia da celula
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    Reference<luaSociety>::getReference(luaL);

    // flags para a definição do uso de compressão
    // na transmissão de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // Nao modifica em nada a pilha
    // recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, -4);

    //@RAIAN
    // Para o Observer do tipo Neighbohrood
    bool isGraphicType = (typeObserver == TObsDynamicGraphic) || (typeObserver == TObsGraphic);

    //------------------------
    QStringList allAttribs, obsAttribs;

    // Pecorre a pilha lua recuperando todos os atributos celula
    lua_pushnil(luaL);
    while(lua_next(luaL, top) != 0)
    {
        QString key( luaL_checkstring(luaL, -2) );

        allAttribs.push_back(key);
        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    lua_settop(luaL, top - 1);
    top = lua_gettop(luaL);

    // Verificacao da sintaxe da tabela Atributos
    if(! lua_istable(luaL, top) )
    {
        qFatal("Error: Attributes table not found. Incorrect sintax.\n");
        return -1;
    }

    bool attribTable = false;

    lua_pushnil(luaL);
    while(lua_next(luaL, top - 1 ) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );
        attribTable = true;

        // Verifica se o atributo informado não existe deve ter sido digitado errado
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
				lua_getglobal(L, "customErrorMsg");
				lua_pushstring(L,err_out.c_str());
				lua_pushnumber(L,4);
				lua_call(L,2,0);
                return -1;
            }
        }
        lua_pop(luaL, 1);
    }
    //------------------------

    // if ((obsAttribs.empty() ) && (! isGraphicType))
    if (obsAttribs.empty())
    {
        obsAttribs = allAttribs;
        observedAttribs = allAttribs;
    }

    QStringList cols, obsParams;

    // Recupera a tabela de parametros os observadores do tipo Table e Graphic
    // caso não seja um tabela a sintaxe do metodo esta incorreta
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
            break;
        }

        case LUA_TTABLE:
        {
            int tableTop = lua_gettop(luaL);

            lua_pushnil(luaL);
            while(lua_next(luaL, tableTop) != 0)
            {
                if (lua_type(luaL, -2) == LUA_TSTRING)
                    obsParams.append(luaL_checkstring(luaL, -2));

                switch (lua_type(luaL, -1))
                {
                case LUA_TNUMBER:
                    cols.append(QString::number(luaL_checknumber(luaL, -1)) );
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


        // Caso não seja definido nenhum parametro,
        // e o observador não é TextScreen então
        // lança um warning
        if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
        {
            if (execModes != Quiet ){
                string err_out = string("Warning: The parameter table is empty.");
                lua_getglobal(L, "customWarningMsg");
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

        int obsId = -1;

        switch (typeObserver)
        {
        case TObsTextScreen:
            obsText = (ObserverTextScreen*)
                    SocietySubjectInterf::createObserver(TObsTextScreen);
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
                    SocietySubjectInterf::createObserver(TObsLogFile);
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
                    SocietySubjectInterf::createObserver(TObsTable);
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
                    SocietySubjectInterf::createObserver(TObsDynamicGraphic);
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
                    SocietySubjectInterf::createObserver(TObsGraphic);
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
            obsUDPSender = (ObserverUDPSender *)
                    SocietySubjectInterf::createObserver(TObsUDPSender);
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

        case TObsMap:
        default:
            if (execModes != Quiet )
            {
                qWarning("Warning: In this context, the code '%s' does not correspond to a "
                         "valid type of Observer.",  getObserverName(typeObserver) );
            }
            return 0;
        }

#ifdef DEBUG_OBSERVER
        qDebug() << "luaCell";
        qDebug() << "obsParams: " << obsParams;
        qDebug() << "obsAttribs: " << obsAttribs;
        qDebug() << "allAttribs: " << allAttribs;
        qDebug() << "cols: " << cols;
#endif

        //@RODRIGO
        //serverSession->add(obsKey);

        /// Define alguns parametros do observador instanciado ---------------------------------------------------

        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);

            if (cols.at(0).isNull() || cols.at(0).isEmpty())
            {
                if (execModes != Quiet )
                    qWarning("Warning: Filename was not specified, using a "
                             "default \"%s\".", qPrintable(DEFAULT_NAME));
                obsLog->setFileName(DEFAULT_NAME + ".csv");
            }
            else
            {
                obsLog->setFileName(cols.at(0));
            }

            // caso não seja definido, utiliza o default ";"
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
            if ((cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
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

        if(obsUDPSender)
        {
            obsUDPSender->setAttributes(obsAttribs);

            // if (cols.at(0).isEmpty())
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
                    lua_getglobal(L, "customWarningMsg");
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


    return 0;
}

const TypesOfSubjects luaSociety::getType()
{
    return subjectType;
}

/// Notifies observers about changes in the luaSociety internal state
int luaSociety::notify(lua_State *L )
{
#ifdef DEBUG_OBSERVER
    printf("\ncell::notifyObservers\n");
    luaStackToQString(12);
# endif

    double time = luaL_checknumber(L, -1);

#ifdef TME_STATISTIC
    double t = Statistic::getInstance().startTime();

    SocietySubjectInterf::notifyObservers(time);

    t = Statistic::getInstance().endTime() - t;
    Statistic::getInstance().addElapsedTime("Total Response Time - cell", t);
    Statistic::getInstance().collectMemoryUsage();
#else
    SocietySubjectInterf::notify(time);
#endif
    return 0;
}

QString luaSociety::getAll(QDataStream & /*in*/, int /*observerId*/, QStringList& attribs)
{
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
    Reference<luaSociety>::getReference(luaL);
    return pop(luaL, attribs);
}


QString luaSociety::pop(lua_State *luaL, QStringList& attribs)
{
#ifdef DEBUG_OBSERVER
    qDebug() << "\ngetState - Society";
    luaStackToQString(12);

    qDebug() << attribs;
#endif

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
    Reference<luaSociety>::getReference(luaL);

    int societyPos = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements;

    lua_pushnil(luaL);
    while(lua_next(luaL, societyPos ) != 0)
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
                break;
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

#ifdef DEBUG_OBSERVER
    qDebug() << this->getId() << msg.split(PROTOCOL_SEPARATOR);
#endif
    return msg;
}

QString luaSociety::getChanges(QDataStream& in, int observerId, QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaSociety::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaSociety::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
#endif

{

#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
#endif

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

int luaSociety::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = SocietySubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

/// Gets the luaSociety position of the luaSociety in the Lua stack
/// \param L is a pointer to the Lua stack
/// \param cell is a pointer to the cell within the Lua stack
void getReference( lua_State *L, luaSociety *cell )
{
    cell->getReference(L);
}
