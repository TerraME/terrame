#include "luaTimer.h"
#include "luaEvent.h"
#include "luaMessage.h"
#include "terrameGlobals.h"

#include "observerTextScreen.h"
#include "observerLogFile.h"
#include "observerTable.h"
#include "observerUDPSender.h"
#include "observerScheduler.h"

#include "protocol.pb.h"

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
    Scheduler::execute( finalTime );
    return 1;
}

/// Gets the luaTimer internal clock value
int luaTimer::getTime(lua_State *L)
{
    lua_pushnumber(L, Scheduler::getEvent().getTime() );
    return 1;
}

/// Return true if the luaTimer object is empty and has no luaEvents to execute
int luaTimer::isEmpty(lua_State *L)
{
    lua_pushnumber(L, Scheduler::empty() );
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

int luaTimer::createObserver( lua_State *luaL)
{
#ifdef DEBUG_OBSERVER
    luaStackToQString(7);
    stackDump(luaL);
#endif

    // recupero a referencia da celula
    Reference<luaTimer>::getReference(luaL);

    // flags para a definicao do uso de compressao
    // na transmissao de datagramas e da visibilidade
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

    bool isSchedulerObserver = (typeObserver == TObsScheduler);

    //------------------------
    QStringList allAttribs, obsAttribs;
    //QList<Triple> eventList;

    allAttribs.push_back(TIMER_KEY); // insere a chave TIMER_KEY atual
    // int eventsCount = 0;

#ifdef DEBUG_OBSERVER
    printf("\npos table: %i\nRecuperando todos os atributos:\n", top);
    stackDump(luaL);
#endif

    // Pecorre a pilha lua recuperando todos os atributos celula
    lua_pushnil(luaL);

    while(lua_next(luaL, top) != 0)
    {
        QString key;

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

                if ( isSchedulerObserver && (isudatatype(luaL, -1, "TeEvent")) )
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


#ifdef DEBUG_OBSERVER
        printf("\t%s \n", qPrintable(key));
#endif
        if (! isSchedulerObserver)
            allAttribs.push_back(key);
        
        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    //lua_settop(luaL, top - 1);
    //top = lua_gettop(luaL);

    // Verificacao da sintaxe da tabela Atributos
    if(! lua_istable(luaL, top) )
    {
        string err_out = string("Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customError");
        lua_pushstring(L,err_out.c_str());
        //lua_pushnumber(L,4);
        lua_call(L,1,0);
        return -1;
    }

#ifdef DEBUG_OBSERVER
    printf("\npos table: %i\nRecuperando a tabela Atributos:\n", top - 1);
    //stackDump(luaL);
#endif

    lua_pushnil(luaL);

    while(lua_next(luaL, top - 2 ) != 0)
    {
        QString key( luaL_checkstring(luaL, -1) );

#ifdef DEBUG_OBSERVER
        printf("\t%s \n", qPrintable(key));
#endif

        // Verifica se o atributo informado nao existe deve ter sido digitado errado
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

    if ((obsAttribs.empty() ) && (! isGraphicType))
    {
        obsAttribs = allAttribs;
        // observedAttribs = allAttribs;
                    
        foreach(const QString &key, allAttribs)
            observedAttribs.insert(key, "");
    }
        
#ifdef DEBUG_OBSERVER
    printf("\n----\n");
    printf("obsAttribs.size(): %i\n", obsAttribs.size());
    for (int i = 0; i < obsAttribs.size(); i++)
        printf("\tobsAttribs.at(%i): %s\n", i, obsAttribs.at(i).toLatin1().constData());

    printf("\n");

    printf("allAttribs.size(): %i\n", allAttribs.size());
    for (int i = 0; i < allAttribs.size(); i++)
        printf("\tallAttribs.at(%i): %s\n", i, allAttribs.at(i).toLatin1().constData());

    printf("----\n");
#endif

    //------------------------

    if(! lua_istable(luaL, top) )
    {
        string err_out = string("Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customError");
        lua_pushstring(L,err_out.c_str());
        //lua_pushnumber(L,5);
        lua_call(L,1,0);
        return 0;
    }

    QStringList cols;

#ifdef DEBUG_OBSERVER
    printf("\n*pos table: %i\nRecuperando a tabela Parametros\n", top);
#endif

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
    // e o observador nao e TextScreen entao
    // lanca um warning
    if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
    {
        if (execModes != Quiet ){
            string err_out = string("Attribute table not found. Incorrect sintax.");
            lua_getglobal(L, "customWarningMsg");
            lua_pushstring(L,err_out.c_str());
            //lua_pushnumber(L,4);
            lua_call(L,1,0);
        }
    }
    //------------------------

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
                string err_out = string("In this context, the code '") + string(getObserverName(typeObserver)) + string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,4);
                lua_call(L,1,0);
            }
            return 0;
    }

    /// Define alguns parametros do observador instanciado ---------------------------------------------------

    if (obsLog)
    {
        obsLog->setAttributes(obsAttribs);

        if (cols.at(0).isNull() || cols.at(0).isEmpty())
        {
            if (execModes != Quiet )
            {
                string err_out = string("Filename was not specified, using a default '") + string(qPrintable(DEFAULT_NAME)) + string("'");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,4);
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
            if (execModes != Quiet )
			{
                string err_out = string("Separator not defined, using ';'.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,4);
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
        if ((cols.size() < 1) || (cols.size() < 2) || cols.at(0).isNull() || cols.at(0).isEmpty()
                || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (execModes != Quiet )
			{
                string err_out = string("Column title not defined.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,4);
                lua_call(L,1,0);
            }
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
			{
                string err_out = string("Port not defined.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                //lua_pushnumber(L,4);
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
            if (execModes != Quiet )
			{
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

    if (obsScheduler)
    {
        obsScheduler->setAttributes(obsAttribs);
        //obsScheduler->setEventList(eventList);

        lua_pushnumber(luaL, obsId);
        return 1;
    }

    //printf("createObserver( lua_State *L ) performed\n");
    return 0;
}

const TypesOfSubjects luaTimer::getType() const
{
    return this->subjectType;
}

int luaTimer::notify(lua_State *luaL )
{
    double time = luaL_checknumber(luaL, -1);

#ifdef DEBUG_OBSERVER
    printf("\n scheduler::notifyObservers \t time: %g\n", time);
    luaStackToQString(12);
#endif

    SchedulerSubjectInterf::notify(time);
    return 0;
}

#ifdef TME_BLACK_BOARD

QDataStream& luaTimer::getState(QDataStream& in, Subject *, int /*observerId*/, const QStringList & /* attribs */)
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
            //if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
            content = getChanges(in, observedAttribs.keys());
            // serverSession->setState(observerId, 0);
            //if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#else

QDataStream& luaTimer::getState(QDataStream& in, Subject *, int observerId, const QStringList &  attribs )
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
            //if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(1).toLatin1().constData());
            break;

        case 1:
            content = getChanges(in, observerId, attribs);
            // serverSession->setState(observerId, 0);
            //if (! QUIET_MODE )
            // qWarning(QString("Observer %1 passou ao estado %2").arg(observerId).arg(0).toLatin1().constData());
            break;
    }
    // cleans the stack
    // lua_settop(L, 0);

    in << content;
    return in;
}

#endif // TME_BLACK_BOARD

#ifdef TME_PROTOCOL_BUFFERS

QByteArray luaTimer::getAll(QDataStream& /*in*/, const QStringList& attribs)
{
    //lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
	Reference<luaTimer>::getReference(luaL);
    ObserverDatagramPkg::SubjectAttribute timeSubj;
    return pop(luaL, attribs, &timeSubj, 0);
}

QByteArray luaTimer::getChanges(QDataStream& in, const QStringList& attribs)
{
    return getAll(in, attribs);
}

QByteArray luaTimer::pop(lua_State *luaL, const QStringList& attribs, 
    ObserverDatagramPkg::SubjectAttribute *currSubj,
    ObserverDatagramPkg::SubjectAttribute *parentSubj)
{
#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
    qDebug() << attribs;
#endif

    bool valueChanged = false;
    char result[20];
    double num = 0.0;
    double minTime = (double) MAX_FLOAT;

    // recupero a referencia na pilha lua
    int position = lua_gettop(luaL);

    QByteArray key, valueTmp;
    ObserverDatagramPkg::RawAttribute *raw = 0;

    lua_pushnil(luaL);
    while(lua_next(luaL, position ) != 0)
    {
        // Caso o indice nao seja um string causava erro
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

        // bool contains = attribs.contains(QString(key));
        if( attribs.contains(key) || attribs.contains("@" + key) )
        {
            switch( lua_type(luaL, -1) )
            {
            case LUA_TBOOLEAN:
                {
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
                }

            case LUA_TNUMBER:
                {
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
                }

            case LUA_TSTRING:
                {
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
                }

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

                    // Recuperando o objeto TeEvent
                    //{
                    int top = lua_gettop(luaL);
                    QByteArray eventKey;
                    const QStringList emptyList;

                    lua_pushnil(luaL);
                    while(lua_next(luaL, top) != 0)
                    {
                        eventKey = "";
                        if (lua_type(luaL, -2) == LUA_TSTRING)
                        {
                            eventKey = luaL_checkstring(luaL, -2);
                        }
                        else
                        {
                            if (lua_type(luaL, -2) == LUA_TNUMBER)
                            {
                                sprintf(result, "%g", luaL_checknumber(luaL, -2) );
                                eventKey = result;
                            }

                            // QString eventKey( QString(EVENT_KEY + QString::number(eventsCount)) );
                            eventKey = "@" + ( key );

                            if (isudatatype(luaL, -1, "TeEvent"))
                            {
                                luaEvent* ev = (luaEvent*)Luna<luaEvent>::check(luaL, -1);
                                minTime = min(minTime, ((Event*) ev)->getTime());

                                int internalCount = currSubj->internalsubject_size();
                                ev->pop(luaL, emptyList, 0, currSubj);

                                if (currSubj->internalsubject_size() > internalCount)
                                {
                                    raw = currSubj->add_rawattributes();
                                    raw->set_key(eventKey);
                                    raw->set_number( (double) ev->getId());

                                    valueChanged = true;
                                }
                            }
                        }
                        lua_pop(luaL, 1);
                    }
                    // } //Event

                    break;
                }

            case LUA_TUSERDATA	:
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

    // Adds TIME_KEY
    doubleToText(minTime, valueTmp, 6);
    if (observedAttribs.value(key) != valueTmp)
    {
        if ((parentSubj) && (! currSubj))
            currSubj = parentSubj->add_internalsubject();

        raw = currSubj->add_rawattributes();
        raw->set_key(TIMER_KEY);
        raw->set_number(minTime);

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
        currSubj->set_type(ObserverDatagramPkg::TObsTimer);

        // #attrs
        currSubj->set_attribsnumber( currSubj->rawattributes_size() );

        // #elements
        currSubj->set_itemsnumber( currSubj->internalsubject_size() );

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

#else // TME_PROTOCOL_BUFFERS

QByteArray luaTimer::getAll(QDataStream& /*in*/, int /*observerId*/, const QStringList& attribs)
{
	// recupero a referencia na pilha lua
	Reference<luaTimer>::getReference(luaL);
    return pop(luaL, attribs);
}

QByteArray luaTimer::getChanges(QDataStream& in, int observerId, const QStringList& attribs)
{
    return getAll(in, observerId, attribs);
}

QByteArray luaTimer::pop(lua_State *luaL, const QStringList& attribs)
{

#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
    qDebug() << attribs;
#endif

    double num = 0, minimumTime = 100000.0;
    int eventsCount = 0;
    bool boolAux = false;

    QByteArray msg, attrs, key, text;
    
    // id
    msg.append(QByteArray::number(getId()));
    msg.append(PROTOCOL_SEPARATOR);

    // subjectType
    msg.append("4"); // QString::number(subjectType));
    msg.append(PROTOCOL_SEPARATOR);

    int attrCounter = 0;
    // int attrParam = 0;
    int position = lua_gettop(luaL);

    lua_pushnil(luaL);
    while(lua_next(luaL, position ) != 0)
    {
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
                    attrs.append(QByteArray::number(TObsBool));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append(QByteArray::number(boolAux));
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
                    attrs.append(QByteArray::number(TObsText));
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
                    attrs.append("Lua-Address(TB): " + QByteArray(result));
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
                                attrs.append(QByteArray::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QByteArray::number(time));
                                attrs.append(PROTOCOL_SEPARATOR);

                                attrCounter++;
                                attrs.append(eventKey);
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QByteArray::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QByteArray::number(ev->getPeriod()));
                                attrs.append(PROTOCOL_SEPARATOR);

                                attrCounter++;
                                attrs.append(eventKey);
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QByteArray::number(TObsNumber));
                                attrs.append(PROTOCOL_SEPARATOR);
                                attrs.append(QByteArray::number(ev->getPriority()));
                                attrs.append(PROTOCOL_SEPARATOR);

                                eventsCount++;

                                //if (containEventKey)
                                //{
                                //    char resultEvent[100];
                                //    sprintf( resultEvent, "%p", lua_topointer(luaL, -1) );

                                //    attrCounter++;
                                //    attrs.append(eventKey);
                                //    attrs.append(PROTOCOL_SEPARATOR);
                                //    attrs.append(QString::number(TObsText));
                                //    attrs.append(PROTOCOL_SEPARATOR);
                                //    attrs.append(QString("Lua-Address(UD):") + QString(resultEvent));
                                //    attrs.append(PROTOCOL_SEPARATOR);
                                //}

                            }
                        }
                        lua_pop(luaL, 1);
                    }
                    // } //Event

                    break;
                }
                case LUA_TUSERDATA	:
                {
                    char result[100];
                    sprintf( result, "%p", lua_topointer(luaL, -1) );
                    attrs.append(QByteArray::number(TObsText));
                    attrs.append(PROTOCOL_SEPARATOR);
                    attrs.append("Lua-Address(UD): " + QByteArray(result));
                    attrs.append(PROTOCOL_SEPARATOR);
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

    attrCounter++;
    attrs.append(TIMER_KEY);
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(TObsText));
    attrs.append(PROTOCOL_SEPARATOR);
    attrs.append(QByteArray::number(minimumTime));
    attrs.append(PROTOCOL_SEPARATOR);

    // #attrs
    msg.append(QByteArray::number(attrCounter));
    msg.append(PROTOCOL_SEPARATOR );

    // #elements
    msg.append("0"); // QByteArray::number(0));
    msg.append(PROTOCOL_SEPARATOR );

    msg.append(attrs);
    msg.append(PROTOCOL_SEPARATOR);

    return msg;
}

#endif

int luaTimer::kill(lua_State *luaL)
{
    int id = luaL_checknumber(luaL, 1);

    bool result = SchedulerSubjectInterf::kill(id);
    lua_pushboolean(luaL, result);
    return 1;
}
