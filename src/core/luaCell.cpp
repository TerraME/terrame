/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaCell.cpp
    \brief This file contains the implementation for the luaCell objects.
        \author Tiago Garcia de Senna Carneiro
*/

#include "luaCell.h"
#include "luaNeighborhood.h"
#include "terrameGlobals.h"

#include "observerTextScreen.h"
#include "observerGraphic.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"
#include "observerTCPSender.h"
#include "agentObserverMap.h"

#include "observerLua.h"
#include "luaUtils.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Estatisticas de desempenho
	#include "statistic.h"
#endif

#ifdef TME_PROTOCOL_BUFFERS
#include "protocol.pb.h"
#endif

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;

extern ExecutionModes execModes;

/// Constructor
luaCell::luaCell(lua_State *L)
{
#ifdef TME_STATISTIC
    static bool msgShow = true;
    if (msgShow)
        qDebug() << "flag TME_STATISTIC enabled in the class luaCell";
    msgShow = false;
#endif

    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.begin();

    luaL = L;
    subjectType = TObsCell;
    // observedAttribs.clear();

    //@RODRIGO
    // serverSession = new ServerSession();
}

/// Returns the current internal state of the LocalAgent (Automaton) within the cell and received as parameter
int luaCell::getCurrentStateName( lua_State *L )
{
    luaLocalAgent *agent = Luna<luaLocalAgent>::check(L, -1);
    ControlMode* controlMode = getControlMode((LocalAgent*)agent);

    if( controlMode) lua_pushstring( L, controlMode->getControlModeName( ).c_str() );
    else lua_pushnil(L);

    return 1;
}

/// Puts the iterator in the beginning of the luaNeighborhood composite.
int luaCell::first(lua_State *){
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.begin();
    return 0;
}

/// Puts the iterator in the end of the luaNeighborhood composite.
int luaCell::last(lua_State *) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    it = nhgs.end();
    return 1;
}

/// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure
/// no parameters
int luaCell::isFirst(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, it == nhgs.begin());
    return  1;
}

/// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure
/// no parameters
int luaCell::isLast(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, it == nhgs.end());
    return  1;
}

/// Returns true if the Neighborhood is empty.
/// no parameters
int luaCell::isEmpty(lua_State *L) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushboolean(L, nhgs.empty() );
    return 1;
}

/// Clears all the Neighborhood content
/// no parameters
int luaCell::clear(lua_State *) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    nhgs.clear( );
    return 0;
}

/// Returns the number of Neighbors cells in the Neighborhood
int luaCell::size(lua_State *) {
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    lua_pushnumber(L,nhgs.size( ));
    return 1;
}

/// Fowards the Neighborhood iterator to the next Neighbor cell
// no parameters
int luaCell::next( lua_State * )
{
    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    if( it != nhgs.end() ) it++;
    return 0;
}

/// destructor
luaCell::~luaCell( void ) { }

/// Sets the Cell latency
int luaCell::setLatency(lua_State *L) { Cell::setLatency(luaL_checknumber(L, 1)); return 0; }

/// Gets the Cell latency
int luaCell::getLatency(lua_State *L) { lua_pushnumber(L, Cell::getLatency()); return 1; }

/// Sets the neighborhood
int luaCell::setNeighborhood(lua_State *) {
    //	luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
    return 0;
}

/// Gets the current active luaNeighboorhood
int luaCell::getCurrentNeighborhood(lua_State *L) {

    NeighCmpstInterf& nhgs = Cell::getNeighborhoods( );
    if( it !=  nhgs.end() )
    {
        luaNeighborhood* neigh = (luaNeighborhood*) it->second;

        if( neigh != NULL )
            neigh->getReference(L);
        else
            lua_pushnil( L );

    }
    else
        lua_pushnil( L );

    return 1;
}

/// Returns the Neihborhood graph which name has been received as a parameter
int luaCell::getNeighborhood(lua_State *L) {

    NeighCmpstInterf& neighs = Cell::getNeighborhoods();

    // Get and test parameters
    const char* charIndex = luaL_checkstring(L, -1);
    string index = string( charIndex );
    if( neighs.empty() ) lua_pushnil(L); // return nil
    else
    {
        // Get the cell	neighborhood
        NeighCmpstInterf::iterator location = neighs.find( index );
        if ( location == neighs.end())
        {
            lua_pushnil( L );
            return 1;
        }
        luaNeighborhood* neigh = (luaNeighborhood*) location->second;

        if( neigh != NULL )
            neigh->getReference(L);
        else
            lua_pushnil( L );
    }

    return 1;
}

/// Adds a new luaNeighborhood graph to the Cell
/// parameters: identifier, luaNeighborhood
int luaCell::addNeighborhood( lua_State *L )
{
    string id = string( luaL_checkstring(L, -2) );
    luaNeighborhood* neigh = Luna<luaNeighborhood>::check(L, -1);
    NeighCmpstInterf& neighs = Cell::getNeighborhoods();
    pair< string, CellNeighborhood*> pStrNeigh;
    neigh->CellNeighborhood::setID(id);

	// setting the neighborhood parent
    neigh->CellNeighborhood::setParent(this);

    pStrNeigh.first = id;
    pStrNeigh.second = neigh;
    neighs.erase(id );
    neighs.add( pStrNeigh );
    it = neighs.begin();
    return 0;
}

/// Synchronizes the luaCell
int luaCell::synchronize(lua_State *) {
    Cell::synchronize( sizeof(luaCell) ); // parametro nao testado
    return 0;
}

/// Gets the luaCell identifier
int luaCell::getID( lua_State *L )
{
    lua_pushstring(L, objectId_.c_str() );
    return 1;
}

/// Gets the luaCell identifier
/// \author Raian Vargas Maretto
const char* luaCell::getID( )
{
    return this->objectId_.c_str();
}

/// Sets the luaCell identifier
int luaCell::setID( lua_State *L )
{
    const char* id = luaL_checkstring( L , -1);
    objectId_ = string( id );
    return 0;
}

/// Sets the cell index (x,y)
/// Parameters: cell.x, cell.y
/// \author Raian Vargas Maretto
int luaCell::setIndex(lua_State *L)
{
    this->idx.second = luaL_checknumber(L, -1);
    this->idx.first = luaL_checknumber(L, -2);
    return 0;
}

void luaCell::setIndex(const CellIndex& index)
{
    this->idx.second = index.second;
    this->idx.first = index.first;
    //return 0;
}

/// Gets the cell index (x,y)
/// \author Raian Vargas Maretto
const CellIndex & luaCell::getIndex() const
{
    return this->idx;
}

/// Creates several types of observers
/// parameters: observer type, observeb attributes table, observer type parameters
// verif. ref (endereco na pilha lua)
// olhar a classe event
int luaCell::createObserver( lua_State * )
{
#ifdef DEBUG_OBSERVER
    luaStackToQString(7);
    stackDump(luaL);
#endif

    // Gets cell reference
    Reference<luaCell>::getReference(luaL);

    // flags para a definicao do uso de compressao
    // na transmissao de datagramas e da visibilidade
    // dos observadores Udp Sender
    bool compressDatagram = false, obsVisible = true;

	// Getting the attribute table of the cell
    int top = lua_gettop(luaL);

	// Does not modify the Lua stack. Just recover the 'enum' of the observer type
    TypesOfObservers typeObserver = (TypesOfObservers)luaL_checkinteger(luaL, -4);

    // Observing the Neighborhood type
    if( typeObserver != TObsNeigh )
    {
		// bool isGraphicType = (typeObserver == TObsDynamicGraphic) || (typeObserver == TObsGraphic);

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
            string err_out = string("Attribute table not found. Incorrect sintax.");
            lua_getglobal(L, "customError");
            lua_pushstring(L,err_out.c_str());
            //lua_pushnumber(L,3);
            lua_call(L,1,0);
            return -1;
        }

        bool attribTable = false;

        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1 ) != 0)
        {
            QString key( luaL_checkstring(luaL, -1) );
            attribTable = true;

            // Verifica se o atributo informado nao existe deve ter sido digitado errado
            if (allAttribs.contains(key))
            {
                obsAttribs.push_back(key);
		        // if (! observedAttribs.contains(key))
		        //    observedAttribs.push_back(key);
                observedAttribs.insert(key, "");
            }
            else
            {
                if ( ! key.isNull() || ! key.isEmpty())
                {
                    string err_out = string("Attribute '"+ key.toStdString() +"' not found.");
                    lua_getglobal(L, "customError");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,3);
                    lua_call(L,1,0);
                    return -1;
                }
            }
            lua_pop(luaL, 1);
        }
		//------------------------

        if (obsAttribs.empty())
        {
            obsAttribs = allAttribs;
		    // observedAttribs = allAttribs;
            
            foreach(const QString &key, allAttribs)
                observedAttribs.insert(key, "");
        }

        //if(! lua_istable(luaL, top) )
        //{
        //    qWarning("Warning: Parameter table not found. Incorrect sintax.");
        //    return 0;
        //}

        QStringList cols, obsParams;

        // Recupera a tabela de parametros os observadores do tipo Table e Graphic
        // caso nao seja um tabela a sintaxe do metodo esta incorreta
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

        // Caso nao seja definido nenhum parametro,
        // e o observador nao e TextScreen entao
        // lanca um warning
        if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
        {
            if (execModes != Quiet){
                string err_out = string("Parameter table is empty.");
                lua_getglobal(L, "customWarningMsg");
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
        ObserverTCPSender *obsTCPSender = 0;

        int obsId = -1;

        switch (typeObserver)
        {
        case TObsTextScreen:
            obsText = (ObserverTextScreen*)
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
            obsLog = (ObserverLogFile*)
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
            obsTable = (ObserverTable *)
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
            obsGraphic = (ObserverGraphic *)
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
            obsGraphic = (ObserverGraphic *)
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
            obsUDPSender = (ObserverUDPSender *)
                    CellSubjectInterf::createObserver(TObsUDPSender);
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

            case TObsTCPSender:
                obsTCPSender = (ObserverTCPSender *) 
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
                    if (execModes != Quiet ){
                        QString str = QString(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
                        lua_getglobal(L, "customWarningMsg");
                        lua_pushstring(L,str.toAscii().constData());
                        //lua_pushnumber(L,5);
                        lua_call(L,1,0);
                    }
                }
                
                break;
                
        case TObsMap:
        default:
            if (execModes != Quiet )
            {
                string err_out = string("In this context, the code '") + string(getObserverName(typeObserver)) + string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,5);
                lua_call(L,1,0);
            }
            return 0;
        }

		/// Define alguns parametros do observador instanciado ---------------------------------------------------
        
#ifdef DEBUG_OBSERVER
        qDebug() << "luaCell";
        qDebug() << "obsParams: " << obsParams;
        qDebug() << "obsAttribs: " << obsAttribs;
        qDebug() << "allAttribs: " << allAttribs;
        qDebug() << "cols: " << cols;
#endif

#ifdef TME_STATISTIC
    Statistic::getInstance().setObserverCount(obsId);
#endif		

        if (obsLog)
        {
            obsLog->setAttributes(obsAttribs);

            if (cols.at(0).isNull() || cols.at(0).isEmpty())
            {
                if (execModes != Quiet ){
                    string err_out = string("Filename was not specified, using a '") + string(DEFAULT_NAME.toStdString()) + string("'.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
                obsLog->setFileName(DEFAULT_NAME + ".csv");
            }
            else
            {
                obsLog->setFileName(cols.at(0));
            }

            // caso nao seja definido, utiliza o default ";"
            if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
            {
                if (execModes != Quiet ){
                    string err_out = string("Parameter 'separator' not defined, using ';'.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
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
                if (execModes != Quiet ){
                    string err_out = string("Column title not defined.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
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
                if (execModes != Quiet ){
                    string err_out = string("Parameter 'port' not defined.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
            }
            else
            {
                obsUDPSender->setPort(cols.at(0).toInt());
            }

            // broadcast
            if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
            {
                if (execModes != Quiet ){
                    string err_out = string("Observer will send broadcast.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
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

        if(obsTCPSender)
    {
            quint16 port = (quint16) DEFAULT_PORT;
            obsTCPSender->setAttributes(obsAttribs);

            // if (cols.at(0).isEmpty())
            if (cols.isEmpty())
        	{
				if (execModes != Quiet ){
                    string err_out = string("Port not defined.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
            }
            else
            {
                port = (quint16) cols.at(0).toInt();
            }

            // broadcast
            if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
            {
				if (execModes != Quiet ){
                    string err_out = string("Observer will send to broadcast.");
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,err_out.c_str());
                    //lua_pushnumber(L,5);
                    lua_call(L,1,0);
                }
                obsTCPSender->addHost(LOCAL_HOST);
            }
            else
           	{
                // multicast or unicast
                for(int i = 1; i < cols.size(); i++)
                {
                    if (! cols.at(i).isEmpty())
                        obsTCPSender->addHost(cols.at(i));
                }
            }
            obsTCPSender->connectTo(port);
            lua_pushnumber(luaL, obsId);
            return 1;
        }
    }

    //
    // Comentado em 13/11/2013
    // Remover na proxima iteracao
    // 
//	//@RAIAN
//	// Comeca a criacao do Observer do tipo Neighborhood
//	else
//	{
//		QStringList obsParams, obsParamsAtribs;
//
//		bool getObserverID = false, isLegend = false;
//		int obsID = -1;
//
//		AgentObserverMap *obsMap = 0;
//		luaCellularSpace *cellSpace = 0;
//
//		// Recupera os parametros
//		lua_pushnil(luaL);
//		while(lua_next(luaL, top - 1) != 0)
//		{
//			// Recupera o ID do observer map
//			if( lua_isnumber(luaL, -1) && (!getObserverID) )
//			{
//				obsID = luaL_checknumber(luaL, -1);
//				getObserverID = true;
//				isLegend = true;
//			}
//
//			//Recupera o espaco celular e a legenda
//			if(lua_istable(luaL, -1))
//			{
//				int paramTop = lua_gettop(luaL);
//
//				lua_pushnil(luaL);
//				while(lua_next(luaL, paramTop) != 0)
//				{
//					if(isudatatype(luaL, -1, "TeCellularSpace"))
//					{
//						cellSpace = Luna<luaCellularSpace>::check(luaL, -1);
//					}
//					else
//					{
//						if(isLegend)
//						{
//							QString key(luaL_checkstring(luaL, -2));
//							obsParams.push_back(key);
//
//							bool boolAux;
//							double numAux;
//							QString strAux;
//
//							switch(lua_type(luaL, -1))
//							{
//							case LUA_TBOOLEAN:
//								boolAux = lua_toboolean(luaL, -1);
//								break;
//
//							case LUA_TNUMBER:
//								numAux = luaL_checknumber(luaL, -1);
//								obsParamsAtribs.push_back(QString::number(numAux));
//								break;
//
//							case LUA_TSTRING:
//								strAux = luaL_checkstring(luaL, -1);
//								obsParamsAtribs.push_back(QString(strAux));
//
//							case LUA_TNIL:
//							case LUA_TTABLE:
//							default:
//								;
//							}
//						}
//					}
//					lua_pop(luaL, 1);
//				}
//			}
//			lua_pop(luaL, 1);
//		}
//
//		QString errorMsg = QString("\nError: The Observer ID \"%1\" was not found. "
//			"Check the declaration of this observer.\n").arg(obsID);
//
//		if(!cellSpace)
//			qFatal("%s", qPrintable(errorMsg));
//
//		QStringList neighIDs;
//		QString className;
//
//		// Recupera os IDs das Vizinhancas a serem observadas
//		lua_pushnil(luaL);
//		while(lua_next(luaL, top - 2) != 0)
//		{
//			const char* key = luaL_checkstring(luaL, -1);
//			className.append(" (");
//			className.append(key);
//			className.append(")");
//
//			neighIDs.push_back(QString("neighborhood") + className);
//			// observedAttribs.push_back(QString("neighborhood") + className);
//            observedAttribs.insert("neighborhood" + className, "");
//#ifdef TME_BLACK_BOARD
//			// Solucao provisoria para o observer do tipo Neighbohrood
//			// observedAttribs.push_front("@getNeighborhoodState");
//			observedAttribs.insert("@getNeighborhoodState", "");
//#endif
//			lua_pop(luaL, 1);
//		}
//
//        if(typeObserver == TObsNeigh)
//		{
//			obsMap = (AgentObserverMap *)cellSpace->getObserver(obsID);
//			if(!obsMap)
//				qFatal("%s", qPrintable(errorMsg));
//			obsMap->registry(this, QString("neighborhood") + className);
//		
//        // TODO: Remocao Antonio
//        // o teste ja havia sido feito
//        // }
//        // if(typeObserver == TObsNeigh)
//		// {
//            obsMap->setAttributes(neighIDs, obsParams, obsParamsAtribs, TObsNeighborhood);
//			obsMap->setSubjectAttributes(neighIDs, className);
//		}
//	}
//	//@RAIAN - FIM

    return 0;
}

const TypesOfSubjects luaCell::getType() const
{
    return subjectType;
}

/// Notifies observers about changes in the luaCell internal state
int luaCell::notify(lua_State *L )
{
#ifdef TME_STATISTIC
    double t = Statistic::getInstance().startMicroTime();

    double time = luaL_checknumber(L, -1);
    CellSubjectInterf::notify(time);

    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("Total Response Time - cell", t);
    Statistic::getInstance().collectMemoryUsage();

#else
    double time = luaL_checknumber(L, -1);
    CellSubjectInterf::notify(time);
#endif
    return 0;
}

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaCell::pop(lua_State *luaL, const QStringList& attribs, 
    ObserverDatagramPkg::SubjectAttribute *cellSubj, 
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
#ifdef TME_STATISTIC 
    double t = Statistic::getInstance().startMicroTime();
#endif 

    QByteArray key, valueTmp;
    bool valueChanged = false;
    char result[20];
    double num = 0.0;

    int cellsPos = lua_gettop(luaL);

    ObserverDatagramPkg::RawAttribute *raw = 0;
    
/*	// @RAIAN: Serializa a vizinhanca
    if(attribs.contains("@getNeighborhoodState"))
    {
/ *
#ifndef TME_BLACK_BOARD
        // solucao provisoria
        attribs.pop_back();
#endif

        QString elements;

        NeighCmpstInterf neighborhoods = this->getNeighborhoods();
        NeighCmpstInterf::iterator itAux = neighborhoods.begin();

        while(itAux != neighborhoods.end())
        {
            QString neighborhoodID(itAux->first.c_str());

            if(attribs.contains(QString("neighborhood (") + neighborhoodID + QString(")")))
            {
                // Neighborhood ID
                msg.append(QString("neighborhood (") + neighborhoodID + QString(")"));
                msg.append(PROTOCOL_SEPARATOR);

                // subject TYPE
                msg.append(QString::number(TObsNeighborhood));
                msg.append(PROTOCOL_SEPARATOR);

                // Pega as informacoe da celula central (this)
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

                while(itNeigh != neigh->end())
                {
                    luaCell* neighbor = (luaCell*)itNeigh->second;
                    CellIndex neighIdx = (CellIndex)itNeigh->first;
                    double weight = neigh->getWeight(neighIdx);

                    int ref = neighbor->getReference(luaL);
                    cellMsg = neighbor->pop(luaL, QStringList() << "x" << "y" << "@getWeight");
                    lua_settop(luaL, 0);

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
        * /
    }// @RAIAN: FIM
	else */
    {
        lua_pushnil(luaL);
        while(lua_next(luaL, cellsPos ) != 0)
        {
            key = luaL_checkstring(luaL, -2);

            if( attribs.contains(key) )
            {
                //qDebug() << "cell attribs: " << attribs << "\n";

                switch( lua_type(luaL, -1) )
                {
                case LUA_TBOOLEAN:
                    valueTmp = QByteArray::number( lua_toboolean(luaL, -1) );

                    if (observedAttribs.value(key) != valueTmp)
                    {                       
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
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
#ifdef DEBUG_OBSERVER
                        qDebug() << getId() << qPrintable(key) << ": " 
                            << qPrintable(observedAttribs.value(key)) << " == " << qPrintable(valueTmp);
#endif
                    
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
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
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
                        raw->set_key(key);
                        raw->set_text(valueTmp);

                        valueChanged = true;
                        observedAttribs.insert(key, valueTmp);
                    }
                    break;

                case LUA_TTABLE:
                {
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                        valueTmp = result;

                        if (observedAttribs.value(key) != valueTmp)
                        {                    
                            if ((parentSubj) && (! cellSubj))
                                cellSubj = parentSubj->add_internalsubject();

                            raw = cellSubj->add_rawattributes();
                            raw->set_key(key);
                            raw->set_text( LUA_ADDRESS_TABLE + static_cast<const char*>(result) );
                            // raw->set_text( "LUA_ADDRESS_TABLE" + std::string(result) );

                            valueChanged = true;
                            observedAttribs.insert(key, valueTmp);
                        }
                    break;
                }

                case LUA_TUSERDATA:
                {
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    valueTmp = result;

                    if (observedAttribs.value(key) != valueTmp)
                    {                    
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
                        raw->set_key(key);
                        raw->set_text(LUA_ADDRESS_USER_DATA + static_cast<const char*>(result));
                        // raw->set_text("LUA_ADDRESS_USER_DATA" + std::string(result));

                        valueChanged = true;
                        observedAttribs.insert(key, valueTmp);
                    }
                    break;
                }

                case LUA_TFUNCTION:
                {
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    valueTmp = result;

                    if (observedAttribs.value(key) != valueTmp)
                    {                    
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
                        raw->set_key(key);
                        raw->set_text(LUA_ADDRESS_FUNCTION + static_cast<const char*>(result));
                        // raw->set_text("LUA_ADDRESS_FUNCTION" + std::string(result));

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
                        if ((parentSubj) && (! cellSubj))
                            cellSubj = parentSubj->add_internalsubject();

                        raw = cellSubj->add_rawattributes();
                        raw->set_key(key);
                        raw->set_text(LUA_ADDRESS_OTHER + static_cast<const char*>(result));
                        // raw->set_text("LUA_ADDRESS_OTHER" + std::string(result));

                        valueChanged = true;
                        observedAttribs.insert(key, valueTmp);
                    }
                    break;
                }
                }
            }
            lua_pop(luaL, 1);
        }

        if (valueChanged)
        {           
            if ((parentSubj) && (! cellSubj))
                cellSubj = parentSubj->add_internalsubject();                    

            // id
            cellSubj->set_id( getId() );

            // subjectType
            cellSubj->set_type(ObserverDatagramPkg::TObsCell); 

            // #attrs
            cellSubj->set_attribsnumber(cellSubj->rawattributes_size());

            // #elements
            cellSubj->set_itemsnumber(cellSubj->internalsubject_size());

            if (! parentSubj)
            {
                // QByteArray byteArray(cellSubj->SerializeAsString().c_str(), cellSubj->ByteSize());
                // return byteArray;
                return QByteArray(cellSubj->SerializeAsString().c_str(), cellSubj->ByteSize());
            }
        }
	}

#ifdef TME_STATISTIC 
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("pop lua - cell", t);
#endif 

    return QByteArray();
}

//@RODRIGO
QByteArray luaCell::getAll(QDataStream & /*in*/, const QStringList& attribs)
{
	// recupero a referencia na pilha lua
    Reference<luaCell>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute cellSubj;
    return pop(luaL, attribs, &cellSubj, 0);
}

QByteArray luaCell::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}

#else  // ifdef TME_PROTOCOL_BUFFERS

QByteArray luaCell::pop(lua_State *luaL, const QStringList& attribs)
{
#ifdef TME_STATISTIC 
    double t = Statistic::getInstance().startMicroTime();
#endif 

    QByteArray msg, attrs, key, text;
	
	int attrCounter = 0;
    int cellsPos = lua_gettop(luaL);
	
	// @RAIAN: Serializa a vizinhanca
	if(attribs.contains("@getNeighborhoodState"))
	{
#ifndef TME_BLACK_BOARD
		// solucao provisoria
		attribs.pop_back();
#endif

		QByteArray elements, neighborhoodID, cellMsg;

		NeighCmpstInterf neighborhoods = this->getNeighborhoods();
		NeighCmpstInterf::iterator itAux = neighborhoods.begin();

		while(itAux != neighborhoods.end())
		{
            neighborhoodID = "neighborhood (";
			neighborhoodID.append(itAux->first.c_str());
            neighborhoodID.append(")");

			if(attribs.contains(neighborhoodID))
			{
				// Neighborhood ID
				msg.append(neighborhoodID);
				msg.append(PROTOCOL_SEPARATOR);

				// subject TYPE
                msg.append(QString::number(TObsNeighborhood));
				msg.append(PROTOCOL_SEPARATOR);

				// Retrieve information about the central cell (this) 
				cellMsg = this->pop(luaL, QStringList() << "x" << "y");

				elements.append(cellMsg);

				CellNeighborhood *neigh = itAux->second;
				CellNeighborhood::iterator itNeigh = neigh->begin();
				int neighSize = neigh->size();

				//Number of Attributes - VARIFICAR SE ESTA CERTO
				msg.append("0"); // QString::number(0));
				msg.append(PROTOCOL_SEPARATOR);

				// Number of internal subjects
				msg.append(QString::number(neighSize + 1));
				msg.append(PROTOCOL_SEPARATOR);
				 // TODO: pq dois separadores em sequencia?
				msg.append(PROTOCOL_SEPARATOR); 

				while(itNeigh != neigh->end())
				{
					luaCell* neighbor = (luaCell*)itNeigh->second;
					CellIndex neighIdx = (CellIndex)itNeigh->first;
					double weight = neigh->getWeight(neighIdx);

                    			// TODO:  Raian, verif. se hia necessidade desta chamada
					// int ref = neighbor->getReference(luaL);
					neighbor->getReference(luaL);
					cellMsg = neighbor->pop(luaL, QStringList() << "x" << "y" << "@getWeight");
					lua_settop(luaL, 0);

                    cellMsg.append(QString::number(TObsNumber));
					cellMsg.append(PROTOCOL_SEPARATOR);
					cellMsg.append(QString::number(weight));
					cellMsg.append(PROTOCOL_SEPARATOR);
					// cellMsg.append(PROTOCOL_SEPARATOR);

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
        bool valueChanged = false;
        QByteArray valueTmp;
        
        msg = popLua(TObsCell, luaL, cellsPos, attribs, observerAttribs, valueChanged);
	
        if (valueChanged)
        {
            // id
            msg.append(QString::number( getId() ));
            msg.append(PROTOCOL_SEPARATOR);

            // subjectType
            msg.append("1"); // TObsCell as a char
            msg.append(PROTOCOL_SEPARATOR);

        //@RAIAN: Para uso na serializacao da Vizinhanca
        if(attribs.contains("@getWeight"))
        {
            attrCounter++;
            attrs.append("@getWeight");
            attrs.append(PROTOCOL_SEPARATOR);
        }
        //@RAIAN: FIM

        // #attrs
        msg.append(QString::number(attrCounter));
        msg.append(PROTOCOL_SEPARATOR );

        // #elements
            msg.append("0");
        msg.append(PROTOCOL_SEPARATOR );

        msg.append(attrs);

	// TODO: Porque essa verificacao
        //@RAIAN: Para uso na serializacao da Vizinhanca
        if(!attribs.contains("@getWeight"))
            msg.append(PROTOCOL_SEPARATOR);
        //@RAIAN: FIM
    }
        else
        {
            msg.clear();
        }
	}

#ifdef TME_STATISTIC 
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("pop lua - cell", t);
#endif 

    return msg;
}

QByteArray luaCell::getAll(QDataStream & /*in*/, int /*observerId*/, const QStringList& attribs)
{
	// recupero a referencia na pilha lua
	Reference<luaCell>::getReference(luaL);
	return pop(luaL, attribs);
}

QByteArray luaCell::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

#endif // ifdef TME_PROTOCOL_BUFFERS


#ifdef TME_BLACK_BOARD

QDataStream& luaCell::getState(QDataStream& in, Subject *, int /*observerId*/, const QStringList & /* attribs */)
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
#ifdef TME_PROTOCOL_BUFFERS
            content = getAll(in, (QStringList)observedAttribs.keys());
#else
            content = getAll(in, observerId, (QStringList)observedAttribs.keys());
#endif

        // serverSession->setState(observerId, 1);
        // if (execModes == Quiet )
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
        break;

    case 1:
#ifdef TME_PROTOCOL_BUFFERS
            content = getChanges(in, (QStringList) observedAttribs.keys());
#else
            content = getChanges(in, observerId, (QStringList) observedAttribs.keys());
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

#else

QDataStream& luaCell::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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
            // if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
            break;

        case 1:
            content = getChanges(in, observerId, attribs);

            // serverSession->setState(observerId, 0);
            // if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}
#endif


int luaCell::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = CellSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}

