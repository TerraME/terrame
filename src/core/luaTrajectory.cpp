#include "luaTrajectory.h"

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerGraphic.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/agentObserverMap.h"
#include "../observer/types/agentObserverImage.h"

#include "luaCellularSpace.h"
#include "luaUtils.h"
#include "terrameGlobals.h"

extern ExecutionModes execModes;

luaTrajectory::luaTrajectory(lua_State* L)
{
    subjectType = TObsTrajectory;
    luaL = L;
    cellSpace = 0;
    observedAttribs.clear();
}

luaTrajectory::~luaTrajectory(void)
{
    luaRegion::clear();
}

int luaTrajectory::add( lua_State* L)
{
    int i = luaL_checknumber(L, -2);
    luaCell *cell = (luaCell*)Luna<luaCell>::check(L,-1);
    CellIndex idx;
    idx.first = i;
    idx.second = 0;
    luaRegion::add( idx, cell);

    return 0;
}

int luaTrajectory::clear( lua_State *)
{
    luaRegion::clear();
    return 0;
}

int luaTrajectory::createObserver( lua_State *L )
{
    // recupero a referencia da celula
    Reference<luaTrajectory>::getReference(luaL);

    // flags para a defini??o do uso de compress?o
    // na transmiss?o de datagramas e da visibilidade
    // dos observadores Udp Sender 
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de atributos da celula
    int top = lua_gettop(luaL);

    // N?o modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, 1);

    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        QStringList allAttribs, obsAttribs, obsParams, cols;

        // qDebug() << "Recupera a tabela de parametros";
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            QString key;
            
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);
            }
            //else
            //{
            //    if (lua_type(luaL, -2) == LUA_TNUMBER)
            //    {
            //        char aux[100];
            //        double number = luaL_checknumber(luaL, -2);
            //        sprintf(aux, "%g", number);
            //        key = aux;
            //    }
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
                            obsParams.append( luaL_checkstring(luaL, -2) );
                        }

                        switch (lua_type(luaL, -1))
                        {
                        case LUA_TSTRING:
                            k = QString(luaL_checkstring(luaL, -1));
                            break;

                        case LUA_TNUMBER:
                            {
                                char aux[100];
                                double number = luaL_checknumber(luaL, -1);
                                sprintf(aux, "%g", number);
                                k = QString(aux);
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

        // qDebug() << "Recupera a tabela de atributos";
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            if (lua_type(luaL, -1) == LUA_TSTRING)
            {
                // QString key( luaL_checkstring(luaL, -1) );
                obsAttribs.push_back(luaL_checkstring(luaL, -1));
            }
            lua_pop(luaL, 1);
        }

        // Retrieves all subject attributes
        lua_pushnil(luaL);
        while(lua_next(luaL, top) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
                allAttribs.append( luaL_checkstring(luaL, -2) );
            lua_pop(luaL, 1);
        }

        if (obsAttribs.empty())
        {
		    obsAttribs = allAttribs;
		    observedAttribs = allAttribs;
        }
        else
        {
            // Verifica se o atributo informado realmente existe na celula
            for (int i = 0; i < obsAttribs.size(); i++)
            {
                if (! observedAttribs.contains(obsAttribs.at(i)) )
                    observedAttribs.push_back(obsAttribs.at(i));
        
                if (! allAttribs.contains(obsAttribs.at(i)))
                {
					string err_out = string("Error: Attribute name '" ) + string (qPrintable(obsAttribs.at(i))) + string("' not found.");
					lua_getglobal(L, "customError");
					lua_pushstring(L,err_out.c_str());
					lua_pushnumber(L,5);
					lua_call(L,2,0);
                    return -1;
                }
            }
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
            obsText = (ObserverTextScreen*) 
                TrajectorySubjectInterf::createObserver(TObsTextScreen);
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
                TrajectorySubjectInterf::createObserver(TObsLogFile);
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
                TrajectorySubjectInterf::createObserver(TObsTable);
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
                TrajectorySubjectInterf::createObserver(TObsDynamicGraphic);
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
                TrajectorySubjectInterf::createObserver(TObsGraphic);
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
                TrajectorySubjectInterf::createObserver(TObsUDPSender);
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
                char str[12];
                sprintf(str, "%d", typeObserver);
                string err_out = string("Warning: In this context, the code '")
                        + string(str) + string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarning");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
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
		    if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
		    {
		        obsUDPSender->addHost(BROADCAST_HOST);
		    }
		    else
		    {
		        // multicast or unicast
		        for(int i = 1; i < cols.size(); i++)
                {
		            if (! cols.at(i).isEmpty())
		                obsUDPSender->addHost(cols.at(i));
		        }
		    }
		    lua_pushnumber(luaL, obsId);
		    return 1;
		}
    }  
    //   ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    // Creation of spatial observers
    else
    {
        QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda

        bool getObserverId = false, isLegend = false;
        int obsId = -1;

        AgentObserverMap *obsMap = 0;
        AgentObserverImage *obsImage = 0;

        // Recupera os parametros
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1) != 0)
        {
            // Recupera o ID do observer map
            if ( (lua_isnumber(luaL, -1) && (! getObserverId)) )
            {
                obsId = luaL_checknumber(luaL, -1);
                getObserverId = true;
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
            "Check the declaration of this observer.\n").arg(obsId);

        if (! cellSpace)
            qFatal("%s", qPrintable(errorMsg));

        if (typeObserver == TObsMap)
        {
            obsMap = (AgentObserverMap *)cellSpace->getObserver(obsId);

            if (! obsMap)
                qFatal("%s", qPrintable(errorMsg));

            obsMap->registry(this);
        }
        else
        {
            obsImage = (AgentObserverImage *)cellSpace->getObserver(obsId);

            if (! obsImage)
                qFatal("%s", qPrintable(errorMsg));

            obsImage->registry(this);
        }

        QStringList allAttribs, obsAttribs;

        // Recupera os atributos
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            const char * key = luaL_checkstring(luaL, -1);
            obsAttribs.push_back(QString(key));
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
            obsMap->setSubjectAttributes(obsAttribs, TObsTrajectory);
        }
        else
        {
            obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs);
            obsImage->setSubjectAttributes(obsAttribs, TObsTrajectory);
        }
        lua_pushnumber(luaL, obsId);
        return 1;
    }

    return 0;
}

const TypesOfSubjects luaTrajectory::getType()
{
    return subjectType;
}

int luaTrajectory::notify(lua_State *L )
{
    double time = luaL_checknumber(L, -1);
    TrajectorySubjectInterf::notify(time);
    return 0;
}

QString luaTrajectory::getAll(QDataStream& /*in*/, int /*observerId*/ , QStringList &attribs)
{
    Reference<luaTrajectory>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaTrajectory::getChanges(QDataStream& in, int observerId , QStringList &attribs)
{
    return getAll(in, observerId, attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaTrajectory::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaTrajectory::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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

QString luaTrajectory::pop(lua_State *luaL, QStringList& attribs)
{
    QString msg;

    // id
    msg.append(QString::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append(QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int pos = lua_gettop(luaL);

    //------------
    int attrCounter = 0;
    int elementCounter = 0;
    // bool contains = false;
    double num = 0;
    QString text, key, attrs, elements;

    lua_pushnil(luaL);
    while(lua_next(luaL, pos ) != 0)
    {
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
                    attrs.append("Lua-Address(TB): " + QString(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    // Recupera a tabela de cells e delega a cada
                    // celula sua serializa??o
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
                            lua_pop(luaL, 1);

                            // luaCell->pop(...) requer uma celula no topo da pilha
                            QString cellMsg = cell->pop(L, QStringList() << "x" << "y");
                            elements.append(cellMsg);
                            elementCounter++;

                            lua_pop(luaL, 1);
                        }
                        // break;
                    }
                    break;
                }

            case LUA_TUSERDATA	:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QString::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(UD): " + QString(result));
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

int luaTrajectory::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);
    bool result = false;

    result = TrajectorySubjectInterf::kill(id);

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



#include <QFile>
#include <QTextStream>
void luaTrajectory::save(const QString &msg)
{
    QFile file("trajectoryPop.txt");
    if (!file.open(QIODevice::WriteOnly | QIODevice::Append))
        return;

    QStringList list = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);
    QTextStream out(&file);

    foreach(QString s, list)
        out << s << " ";
    out << "\n";
}
