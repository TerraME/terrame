#include "luaGlobalAgent.h"

#include "luaControlMode.h"
#include "luaCellularSpace.h"
#include "terrameGlobals.h"

#include "observerTextScreen.h"
#include "observerGraphic.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"
#include "agentObserverMap.h"
#include "agentObserverImage.h"
#include "observerStateMachine.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Estatisticas de desempenho
	#include "statistic.h"
#endif

#ifdef TME_PROTOCOL_BUFFERS
	#include "protocol.pb.h"
#endif

///< true - TerrME runs in verbose mode and warning messages to the user; 
/// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

luaGlobalAgent::luaGlobalAgent(lua_State *L)
{
    // Antonio
    luaL = L;
    subjectType = TObsAgent;
    attrClassName = "";
    cellSpace = 0;
    
    observedAttribs.clear();
}

luaGlobalAgent::~luaGlobalAgent(void){ }

int luaGlobalAgent::getLatency( lua_State *L)
{
    double time = GlobalAgent::getLastChangeTime();
    lua_pushnumber(L, time);
    return 1;
}

int luaGlobalAgent::add(lua_State *L)
{
    //void *ud;
    if( isudatatype(L, -1, "TeState") )
    {
        ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
        ControlMode &cm = *lcm;
        GlobalAgent::add( cm );
    }
    else
    {
        if( isudatatype(L, -1, "TeTrajectory") )
        {
            luaRegion& actRegion = *(( luaRegion* ) Luna<luaTrajectory>::check(L, -1));
            ActionRegionCompositeInterf& actRegions = luaGlobalAgent::getActionRegions();
            actRegions.add( actRegion );
        }
    }
    return 0;
}

int luaGlobalAgent::setActionRegionStatus( lua_State* L)
{
    bool status = lua_toboolean( L, -1);
    GlobalAgent::setActionRegionStatus( status );
    return 0;
}

int luaGlobalAgent::getActionRegionStatus( lua_State* L)
{
    bool status = GlobalAgent::getActionRegionStatus( );
    lua_pushboolean(L,status);
    return 1;
}

int luaGlobalAgent::execute( lua_State* L)
{
    luaEvent* ev = Luna<luaEvent>::check(L, -1);
    GlobalAgent::execute( *ev );
    return 0;
}

int luaGlobalAgent::build( lua_State *)
{
    if( ! Agent::build() )
    {
        string err_out = string("A control mode must be added to the agent before use it as a jump condition target.");
        lua_getglobal(L, "customError");
        lua_pushstring(L,err_out.c_str());
        //lua_pushnumber(L,4);
        lua_call(L,1,0);
    }
    return 0;
}

int luaGlobalAgent::getControlModeName( lua_State* L)
{
    lua_pushstring( L, GlobalAgent::getControlModeName().c_str() );
    return 1;
}


int luaGlobalAgent::createObserver( lua_State *L )
{
#ifdef DEBUG_OBSERVER
    luaStackToQString(12);
    stackDump(luaL);
#endif

    // recupero a referencia da celula
    Reference<luaAgent>::getReference(luaL);
        
    // flags para a definicao do uso de compressao
    // na transmissao de datagramas e da visibilidade
    // dos observadores Udp Sender 
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // Nao modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, 1);

    if ((typeObserver !=  TObsMap) && (typeObserver !=  TObsImage))
    {
        bool isGraphicType = (typeObserver ==  TObsDynamicGraphic)
            || (typeObserver ==  TObsGraphic);

        //------------------------
        QStringList allAttribs, obsAttribs;
        QList<QPair<QString, QString> > allStates;

#ifdef DEBUG_OBSERVER
        stackDump(luaL);
        printf("\npos table: %i\nRecuperando todos os atributos:\n", top);
#endif

        // Pecorre a pilha lua recuperando
        // todos os atributos
        lua_pushnil(luaL);
        while(lua_next(luaL, top ) != 0)
        {
            QString key;

            switch (lua_type(luaL, -2))
            {
            case LUA_TSTRING:
                key = luaL_checkstring(luaL, -2);
                break;

            case LUA_TNUMBER:
                {
                    char aux[100];
                    double number = luaL_checknumber(luaL, -2);
                    sprintf(aux, "%g", number);
                    key = aux;
                    break;
                }
            default:
                break;
            }

            // Recupero os estados do TeState
            if ( isudatatype(luaL, -1, "TeState") )
            {
                ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);

                QString state, transition;
                state.append(lcm->getControlModeName().c_str());

                // Adiciona o estado do atributo na lista de parametros
                // allAttribs.push_back( state );

                // Recupero a transicao dos estados
                ProcessCompositeInterf::iterator prIt;
                prIt = lcm->ProcessCompositeInterf::begin();

                JumpCompositeInterf::iterator jIt;
                jIt = prIt->JumpCompositeInterf::begin();

                while (jIt != prIt->JumpCompositeInterf::end())
                {
                    transition = QString( (*jIt)->getTargetControlModeName().c_str());
                    jIt++;
                }

                // cria um par (estado, transicao) e adiciona na lista de estados
                allStates.push_back(qMakePair(state, transition));
            }
            allAttribs.push_back(key);
            lua_pop(luaL, 1);
        }

        // Adiciono o currentState no observador
        allAttribs.push_back("currentState");

        //------------------------
        // pecorre a pilha lua recuperando
        // os atributos celula que se quer observar
        lua_settop(luaL, top - 1);
        top = lua_gettop(luaL);

        // Verificacao da sintaxe da tabela Atributos
        if(! lua_istable(luaL, top) )
        {
            string err_out = string("Attributes table not found. Incorrect sintax");
            lua_getglobal(L, "customError");
            lua_pushstring(L,err_out.c_str());
            //lua_pushnumber(L,4);
            lua_call(L,1,0);
            return -1;
        }

#ifdef DEBUG_OBSERVER
        printf("\npos table: %i\nRecuperando a tabela Atributos:\n", top - 1);
#endif

        lua_pushnil(luaL);
        while(lua_next(luaL, top - 1 ) != 0)
        {
            QString key(luaL_checkstring(luaL, -1));

            // Verifica se o atributo informado existe
            // ou pode ter sido digitado errado
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
                    string err_out = string("Attribute '" ) + string (key.toStdString()) + string("' not found");
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
            if (execModes != Quiet)
                qWarning("Warning: Parameter table not found. Incorrect sintax.");
        }

        QStringList obsParams, obsParamsAtribs; // parametros/atributos da legenda
        QStringList cols;

#ifdef DEBUG_OBSERVER
        printf("\n*pos table: %i\nRecuperando a tabela Parametros\n", top);
        stackDump(luaL);
#endif

        // Recupera a tabela de parametros dos observadores do tipo table e Graphic
        // caso nao seja um tabela a sintaxe do metodo esta incorreta
        lua_pushnil(luaL);
        while(lua_next(luaL, top) != 0)
        {
            QString key, value;

            if (lua_type(luaL, -2) == LUA_TSTRING)
                key = luaL_checkstring(luaL, -2);

            switch ( lua_type(luaL, -1) )
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
                value = QString(luaL_checkstring(luaL, -1));
                break;

            case LUA_TNUMBER:
                {
                    char aux[100];
                    double number = luaL_checknumber(luaL, -1); // -2);
                    sprintf(aux, "%g", number);
                    value = aux;
                    break;
                }               

            // percorre a tabela de parametros
            case LUA_TTABLE:
                {
                    int legTop = lua_gettop(luaL);
                    // bool boolAux;
                    const char *strAux;
                    double numAux = -1;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, legTop) != 0)
                    {
                        QString k;

                        switch (lua_type(luaL, -2))
                        {
                        case LUA_TSTRING:
                            k = luaL_checkstring(luaL, -2);
                            break;

                        case LUA_TNUMBER:
                            {
                                char aux[100];
                                double number = luaL_checknumber(luaL, -2);
                                sprintf(aux, "%g", number);
                                k = aux;
                                break;
                            }
                        default:
                            break;
                        }

                        obsParams.push_back(k);

                        switch( lua_type(luaL, -1) )
                        {
                        // case LUA_TBOOLEAN:
                            // boolAux = lua_toboolean(luaL, -1);
                            // obsParamsAtribs.push_back(QString::number(boolAux));
                            // break;

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

                        lua_pop(luaL, 1);
                    }
                    break;
                }
            }
            cols.push_back(value);
            lua_pop(luaL, 1);
        }

        // Caso nao seja definido nenhum parametro e o observador nao e 
        // TextScreen entao lanca um warning
        if ((cols.isEmpty()) && (typeObserver !=  TObsTextScreen))
        {
            if (execModes != Quiet ){
                string err_out = string("The parameter table is empty.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,5);
                lua_call(L,1,0);
            }
        }

        //------------------------
#ifdef DEBUG_OBSERVER
        qDebug() << "allAttribs.size(): " << allAttribs.size();
        qDebug() << allAttribs;
        qDebug() << "\nobsAttribs.size(): " << obsAttribs.size();
        qDebug() << obsAttribs;
        qDebug() << "\nobsParams.size(): " << obsParams.size();
        qDebug() << obsParams;
        qDebug() << "\ncols.size(): " << cols.size();
        qDebug() << cols;
        qDebug() << "\nobsParamsAtribs.size(): " << obsParamsAtribs.size();
        qDebug() << obsParamsAtribs;
#endif

        ObserverTextScreen *obsText = 0;
        ObserverTable *obsTable = 0;
        ObserverGraphic *obsGraphic = 0;
        ObserverLogFile *obsLog = 0;
        ObserverUDPSender *obsUDPSender = 0;
        ObserverStateMachine *obsStateMachine = 0;

        int obsId = -1;
        QStringList attrs;

        switch (typeObserver)
        {
        case  TObsTextScreen:
            obsText = (ObserverTextScreen *) 
                GlobalAgentSubjectInterf::createObserver( TObsTextScreen);
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

        case  TObsLogFile:
            obsLog = (ObserverLogFile *) 
                GlobalAgentSubjectInterf::createObserver( TObsLogFile);
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

        case  TObsTable:
            obsTable = (ObserverTable *) 
                GlobalAgentSubjectInterf::createObserver( TObsTable);
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

        case  TObsUDPSender:
            obsUDPSender = (ObserverUDPSender *) 
                GlobalAgentSubjectInterf::createObserver( TObsUDPSender);
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
                GlobalAgentSubjectInterf::createObserver( TObsStateMachine);
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

        case  TObsDynamicGraphic:
            obsGraphic = (ObserverGraphic *) 
                GlobalAgentSubjectInterf::createObserver( TObsDynamicGraphic);
            if (obsGraphic)
            {
                obsGraphic->setObserverType( TObsDynamicGraphic);
                obsId = obsGraphic->getId();
            }
            else
            {
                if (execModes != Quiet)
                    qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
            }
            break;

        case  TObsGraphic:
            obsGraphic = (ObserverGraphic *) 
                GlobalAgentSubjectInterf::createObserver( TObsGraphic);
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
            if (execModes != Quiet)
            {
                qWarning("Warning: In this context, the code '%s' does not correspond to a "
                    "valid type of Observer.",  getObserverName(typeObserver) );
            }
            return 0;
        }

        /// Define alguns parametros do observador instanciado ---------------------------------------------------
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

            // caso nao seja definido, utiliza o default ";"
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

            // if(cols.at(0).isEmpty())
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
            if ((cols.size() == 1) || ((cols.size() == 2) && cols.at(1).isEmpty()) )
            {
                if (execModes != Quiet){
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
                for(int i = 1; i < cols.size(); i++)
                {
                    if (! cols.at(i).isEmpty())
                        obsUDPSender->addHost(cols.at(i));
                }
            }
            lua_pushnumber(luaL, obsId);
            return 1;
        }
        ///////////////////////////////////////////

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
                obsParams, obsParamsAtribs); // cols);

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

    }	// termina o if (typeObserver !=  TerraMEObserver::TObsMap)
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

            // recupera o espaco celular
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
                            QString key(luaL_checkstring(luaL, -2));
                            obsParams.append(key);

                            // bool boolAux;
                            double numAux;
                            QString strAux;

                            switch( lua_type(luaL, -1) )
                            {
                            case LUA_TBOOLEAN:
                                // boolAux = lua_toboolean(luaL, -1);
                                // obsParamsAtribs.append(QString::number(boolAux));
                                break;

                            case LUA_TNUMBER:
                                numAux = luaL_checknumber(luaL, -1);
                                obsParamsAtribs.append(QString::number(numAux));
                                break;

                            case LUA_TSTRING:
                                strAux = luaL_checkstring(luaL, -1);
                                obsParamsAtribs.append(strAux);
                                break;

                            case LUA_TNIL:
                            case LUA_TTABLE:
                            default:
                                ;
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
			lua_pushstring(L,errorMsg.toAscii().data());
			//lua_pushnumber(L,5);
			lua_call(L,1,0);
			return 0;
		}

        QStringList allAttribs, obsAttribs;
        QString key;

        // Recupera todos os atributos do agente
        // buscando apenas a classe do agente
        lua_pushnil(luaL);
        while(lua_next(luaL, top ) != 0)
        {
            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);
                allAttribs.append(key);

                if (key == "class")
				{
					attrClassName.append(" (");
					attrClassName.append( luaL_checkstring(luaL, -1) );
					attrClassName.append(")");
				}
			}
            lua_pop(luaL, 1);
        }

        if (typeObserver == TObsMap)
        {
            obsMap = (AgentObserverMap *)cellSpace->getObserver(obsID);

            if (! obsMap)
			{
				lua_getglobal(L, "customError");
				lua_pushstring(L,errorMsg.toAscii().data());
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
				lua_pushstring(L,errorMsg.toAscii().data());
				//lua_pushnumber(L,5);
				lua_call(L,1,0);
				return 0;
			}

            obsImage->registry(this, attrClassName);
        }
        
        // Adiciono o currentState no observador
        allAttribs.push_back("currentState" + attrClassName);

        // Recupera os atributos
        lua_pushnil(luaL);
        while(lua_next(luaL, top - 2) != 0)
        {
            key = luaL_checkstring(luaL, -1);

            if (key == "currentState")
                key += attrClassName;

            obsAttribs.append(key);

            if (! allAttribs.contains(key))
            {
				string err_out = string("Attribute name '" ) + string (qPrintable(key)) + string("' not found.");
				lua_getglobal(L, "customError");
				lua_pushstring(L,err_out.c_str());
				//lua_pushnumber(L,4);
				lua_call(L,1,0);
                return 0;
            }
            
            if (! observedAttribs.contains(key) )
                // observedAttribs.append(key);
                observedAttribs.insert(key, "");

            lua_pop(luaL, 1);
        }
        
        if (typeObserver == TObsMap)
        {
            // ao definir os valores dos atributos do agente,
            // redefino o tipo do atributos na super classe ObserverMap
            obsMap->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsAgent);
            obsMap->setSubjectAttributes(obsAttribs, getId(), attrClassName);
        }
        else // (typeObserver == obsImage)
        {
            obsImage->setAttributes(obsAttribs, obsParams, obsParamsAtribs, TObsAgent);
            obsImage->setSubjectAttributes(obsAttribs, getId(), attrClassName);
        }
        lua_pushnumber(luaL, obsID);
        return 1;
    }
    return 0;
}

const TypesOfSubjects luaGlobalAgent::getType() const
{
    return subjectType;
}

int luaGlobalAgent::notify(lua_State *luaL)
{
    double time = luaL_checknumber(luaL, -1);

#ifdef DEBUG_OBSERVER
    printf("\n GlobalAgentSubjectInterf::notify \t time: %g\n", time);
    stackDump(luaL);
#endif

#ifdef TME_STATISTIC
   double t = Statistic::getInstance().startTime();

   GlobalAgentSubjectInterf::notify(time);
   
   t = Statistic::getInstance().endTime() - t;
   Statistic::getInstance().addElapsedTime("resposta total agent", t);
   Statistic::getInstance().collectMemoryUsage();
#else
    GlobalAgentSubjectInterf::notify(time);
#endif

    return 0;
}

#ifdef TME_BLACK_BOARD

QDataStream& luaGlobalAgent::getState(QDataStream& in, Subject *, int /*observerId*/, 
    const QStringList & /* attribs */)
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
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toAscii().constData());
        break;

    case 1:
        content = getChanges(in, observedAttribs.keys());
        // serverSession->setState(observerId, 0);
        // if (! QUIET_MODE )
        // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toAscii().constData());
        break;
    }
    // cleans the stack
    lua_settop(luaL, 0);

    in << content;
    return in;
}

#else

QDataStream& luaGlobalAgent::getState(QDataStream& in, Subject *, int observerId, const QStringList &  attribs )
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
    lua_settop(luaL, 0);

    in << content;
    return in;
}

#endif // TME_BLACK_BOARD

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaGlobalAgent::getAll(QDataStream& /*in*/, const QStringList& attribs)
{
    //lua_rawgeti(luaL, LUA_REGISTRYINDEX, getRef());	// recupero a referencia na pilha lua
	Reference<luaAgent>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute agSubj;
    return pop(luaL, attribs, &agSubj, 0);
}

QByteArray luaGlobalAgent::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}

QByteArray luaGlobalAgent::pop(lua_State * /*luaL*/, const QStringList& attribs, 
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{          
    bool valueChanged = false;
    char result[20];
    double num = 0.0;

    // recupero a referencia na pilha lua
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    int position = lua_gettop(luaL);
 
    if (parentSubj && attrClassName.isEmpty())
    {
        bool getClassName = false;
        QString key;

        lua_pushnil(luaL);
        while (! getClassName && (lua_next(luaL, position ) != 0))
        {

            if (lua_type(luaL, -2) == LUA_TSTRING)
            {
                key = luaL_checkstring(luaL, -2);
                if (key == "class")
                {
                    getClassName = true;
                    attrClassName.append(" (");
                    attrClassName.append( luaL_checkstring(luaL, -1) );
                    attrClassName.append(")");
                    
                    lua_pop(luaL, 1); // Solves problem when the stop brutally iteration
                }
            }
            lua_pop(luaL, 1);
        }
    }

    QByteArray key, valueTmp;
    const QByteArray currState = "currentState" + attrClassName;
    ObserverDatagramPkg::RawAttribute *raw = 0;

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

        if (key == "cell")
        {
            int cellTop = lua_gettop(luaL);
            lua_pushstring(luaL, "cObj_");
            lua_gettable(luaL, cellTop);

            luaCell*  cell;
            cell = (luaCell*)Luna<luaCell>::check(luaL, -1);
            lua_pop(luaL, 1); // lua_pushstring

            //// luaCell->popCell(...) requer uma celula no topo da pilha
            //int internalCount = currSubj->internalsubject_size();
            //cell->pop(luaL, attribs, 0, currSubj);

            // const CellIndex &idx = cell->getIndex();
            // qDebug() << cell->getId() << idx.first << ", " << idx.second;


            // Location in the spacial where we found the agent
            valueTmp = QByteArray::number( cell->getId() );
            if (observedAttribs.value("location") != valueTmp)
            {
                if ((parentSubj) && (! currSubj))
                    currSubj = parentSubj->add_internalsubject();

                ObserverDatagramPkg::SubjectAttribute *cellSubj = currSubj->add_internalsubject();

                cellSubj->set_id( cell->getId() );
                cellSubj->set_type( ObserverDatagramPkg::TObsCell ); 
                cellSubj->set_attribsnumber( cellSubj->rawattributes_size() );
                cellSubj->set_itemsnumber( cellSubj->internalsubject_size() );      

                valueChanged = true;
                observedAttribs.insert("location", valueTmp);
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

                //// Recupera os valores dos estados
                //if ( isudatatype(luaL, -1, "TeState"))
                //{
                //    ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
                //    QString state(lcm->getControlModeName().c_str());

                //    bool containState = attribs.contains(state);

                //    // Apresenta no observador o nome do atributo e o valor como sendo
                //    // mesma coisa
                //    if (containState)
                //    {
                //        attrCounter++;
                //        attrs.append(state);
                //        attrs.append(PROTOCOL_SEPARATOR);
                //        attrs.append(QString::number(TObsText));
                //        attrs.append(PROTOCOL_SEPARATOR);
                //        attrs.append(state);
                //        attrs.append(PROTOCOL_SEPARATOR);
                //    }
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
                    raw->set_text(LUA_ADDRESS_FUNCTION.constData() + valueTmp);

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

    // Gets the current state of agent
    // key = "currentState" + attrClassName;
    key = currState;
    if (attribs.contains(key))
    {
        valueTmp = GlobalAgent::getControlModeName().c_str();

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
    }

    if (valueChanged)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        // id
        currSubj->set_id(getId());

        // subjectType
        currSubj->set_type(ObserverDatagramPkg::TObsAgent);

        // #attrs
        currSubj->set_attribsnumber( currSubj->rawattributes_size() );

        // #elements
        currSubj->set_itemsnumber( currSubj->internalsubject_size() );
        
#ifdef DEBUG_OBSERVER
        std::cout << "\n\nluaGlobalAgent::pop(): " << getId() << "\n";
        std::cout << currSubj->DebugString() << "\n";
        std::cout.flush();

        std::string parseCheck;
        if (! currSubj->SerializeToString(&parseCheck))
        {
            qDebug() << "\n\n SerializeToString FALHOU !!! \n\n";
            std::abort();
        }

        if (! currSubj->ParseFromString(parseCheck))
        {
            qDebug() << "\n\n ParseFromString FALHOU !!! \n\n";
            std::abort();
        }
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

QByteArray luaGlobalAgent::getAll(QDataStream& /*in*/, int /*observerId*/, const QStringList& attribs)
{
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, getRef());	// recupero a referencia na pilha lua
	Reference<luaAgent>::getReference(luaL);
    return pop(luaL, attribs);
}

QByteArray luaGlobalAgent::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

QByteArray luaGlobalAgent::pop(lua_State *luaL, const QStringList& attribs)
{
//#ifdef TME_STATISTIC 
//    double t = Statistic::getInstance().startMicroTime();
//#endif

    QByteArray msg;
    QStringList coordList = QStringList() << "x" << "y";

    // id
    msg.append( QByteArray::number(getId()) );
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append("8"); //QString::number(subjectType)); // TObsAgent
    msg.append(PROTOCOL_SEPARATOR);

    int position = lua_gettop(luaL);

    int attrCounter = 0;
    int elementCounter = 0;
    bool contains = false;
    double num = 0;
    QByteArray text, key, attrs, elements;

    // QString currState("currentState" + attrClassName);

    lua_pushnil(luaL);
    while(lua_next(luaL, position ) != 0)
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
                key = aux;
            }
        }

        if (key == "cell")
        {
            int cellTop = lua_gettop(luaL);
            lua_pushstring(luaL, "cObj_");
            lua_gettable(luaL, cellTop);

            luaCell* cell;
            cell = (luaCell*)Luna<luaCell>::check(luaL, -1);
            lua_pop(luaL, 1); // lua_pushstring

#ifdef TME_PROTOCOL_BUFFERS
            QByteArray cellMsg = cell->pop(luaL, coordList, 0, 0);
#else
            QByteArray cellMsg = cell->pop(luaL, coordList);
#endif

            elements.append(cellMsg);
            elementCounter++;
        }

        contains = attribs.contains(key);
        // bool containsReg = (attribs.indexOf(QRegExp("([A-Za-z_]+\\ \\()")) != -1);

        if (! contains)
        {
            key.append(attrClassName);
            contains = attribs.contains(key);
        }

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
                attrs.append(QByteArray::number( lua_toboolean(luaL, -1)));
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
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(TB): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
                    break;
                }

            case LUA_TUSERDATA:
                {
                    char result[100];
                    sprintf(result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText) );
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(UD): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);

                    //// Recupera os valores dos estados
                    //if ( isudatatype(luaL, -1, "TeState"))
                    //{
                    //    ControlMode*  lcm = (ControlMode*)Luna<luaControlMode>::check(L, -1);
                    //    QString state(lcm->getControlModeName().c_str());

                    //    bool containState = attribs.contains(state);

                    //    // Apresenta no observador o nome do atributo e o valor como sendo
                    //    // mesma coisa
                    //    if (containState)
                    //    {
                    //        attrCounter++;
                    //        attrs.append(state);
                    //        attrs.append(PROTOCOL_SEPARATOR);
                    //        attrs.append(QString::number(TObsText));
                    //        attrs.append(PROTOCOL_SEPARATOR);
                    //        attrs.append(state);
                    //        attrs.append(PROTOCOL_SEPARATOR);
                    //    }
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

    QByteArray currState("currentState" + attrClassName);

    if (attribs.contains(currState))
    {
        QByteArray state(GlobalAgent::getControlModeName().c_str());

        attrCounter++;
        attrs.append(currState);
        attrs.append(PROTOCOL_SEPARATOR);
        attrs.append(QByteArray::number(TObsText));
        attrs.append(PROTOCOL_SEPARATOR);
        attrs.append(state);
        attrs.append(PROTOCOL_SEPARATOR);
    }

    // #attrs
    msg.append(QByteArray::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(QByteArray::number(elementCounter));
    msg.append(PROTOCOL_SEPARATOR );
    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);
    msg.append(elements);
    msg.append(PROTOCOL_SEPARATOR);

//#ifdef TME_STATISTIC 
//    t = Statistic::getInstance().endMicroTime() - t;
//    Statistic::getInstance().addElapsedTime("recuperacao agent", t);
//    Statistic::getInstance().startVolatileTime();
//#endif
    
    return msg;
}

#endif

int luaGlobalAgent::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);
    bool result = false;

    result = GlobalAgentSubjectInterf::kill(id);

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
