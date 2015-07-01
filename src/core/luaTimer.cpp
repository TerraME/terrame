#include "luaTimer.h"
#include "luaEvent.h"
#include "luaMessage.h"
#include "terrameGlobals.h"

// Observadores
#include "../observer/types/observerTextScreen.h"
#include "../observer/types/observerLogFile.h"
#include "../observer/types/observerTable.h"
#include "../observer/types/observerUDPSender.h"
#include "../observer/types/observerScheduler.h"

///< Global variable: Lua stack used for comunication with C++ modules.
extern lua_State * L; 

///< true - TerrME runs in verbose mode and warning messages to the user; 
/// false - it runs in quite node and no messages are shown to the user.
extern ExecutionModes execModes;

luaTimer::luaTimer(lua_State *L)
{
    // Antonio
    luaL = L;
    subjectType = TObsTimer;
    observedAttribs.clear();
}

/// Desctructor
luaTimer::~luaTimer(void)
{
    // @DANIEL
    // não misturar gerência de memória de C++ com o lado Lua
    // luaL_unref( L, LUA_REGISTRYINDEX, ref);
}

/// Executes the luaTimer object
/// parameter: finalTime
int luaTimer::execute(lua_State *L)
{
    float finalTime = luaL_checknumber(L, -1);
    //float finalExecutedTime =
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

/// Gets the object reference in the Lua stack
// @DANIEL
// Movido para a classe Reference
//int luaTimer::setReference( lua_State* L)
//{
//    ref = luaL_ref(L, LUA_REGISTRYINDEX );
//    return 0;
//}

/// Sets the object reference in the Lua stack
// @DANIEL
// Movido para a classe Reference
//int luaTimer::getReference( lua_State *L )
//{
//    lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//    return 1;
//}

int luaTimer::createObserver( lua_State *luaL)
{
#ifdef DEBUG_OBSERVER
    luaStackToQString(7);
    stackDump(luaL);
#endif

    // recupero a referencia da celula
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);
    Reference<luaTimer>::getReference(luaL);

    // flags para a defini��o do uso de compress�o
    // na transmiss�o de datagramas e da visibilidade
    // dos observadores Udp Sender 
    bool compressDatagram = false, obsVisible = true;

    // recupero a tabela de
    // atributos da celula
    int top = lua_gettop(luaL);

    // Não modifica em nada a pilha recupera o enum referente ao tipo
    // do observer
    int typeObserver = (int)luaL_checkinteger(luaL, top - 3);
    bool isGraphicType = (typeObserver == TObsDynamicGraphic)
            || (typeObserver == TObsGraphic);


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


#ifdef DEBUG_OBSERVER
        printf("\t%s \n", qPrintable(key));
#endif
        if (typeObserver != TObsScheduler)
            allAttribs.push_back(key);
        
        lua_pop(luaL, 1);
    }

    //------------------------
    // pecorre a pilha lua recuperando
    // os atributos celula que se quer observar
    //lua_settop(luaL, top - 1);
    //top = lua_gettop(luaL);

    // Verificação da sintaxe da tabela Atributos
    if(! lua_istable(luaL, top) )
    {
        string err_out = string("Error: Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customErrorMsg");
        lua_pushstring(L,err_out.c_str());
        lua_pushnumber(L,4);
        lua_call(L,2,0);
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

    if ((obsAttribs.empty() ) && (! isGraphicType))
    {
        obsAttribs = allAttribs;
        observedAttribs = allAttribs;
    }
        
#ifdef DEBUG_OBSERVER
    printf("\n----\n");
    printf("obsAttribs.size(): %i\n", obsAttribs.size());
    for (int i = 0; i < obsAttribs.size(); i++)
        printf("\tobsAttribs.at(%i): %s\n", i, obsAttribs.at(i).toAscii().constData());

    printf("\n");

    printf("allAttribs.size(): %i\n", allAttribs.size());
    for (int i = 0; i < allAttribs.size(); i++)
        printf("\tallAttribs.at(%i): %s\n", i, allAttribs.at(i).toAscii().constData());

    printf("----\n");
#endif

    //------------------------

    if(! lua_istable(luaL, top) )
    {
        string err_out = string("Error: Attribute table not found. Incorrect sintax.");
        lua_getglobal(L, "customErrorMsg");
        lua_pushstring(L,err_out.c_str());
        lua_pushnumber(L,5);
        lua_call(L,2,0);
        return 0;
    }

    QStringList cols;

#ifdef DEBUG_OBSERVER
    printf("\n*pos table: %i\nRecuperando a tabela Parametros\n", top);
#endif

    // Recupera a tabela de parametros os observadores do tipo Table e Graphic
    // caso não seja um tabela a sintaxe do metodo esta incorreta
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

    // Caso não seja definido nenhum parametro,
    // e o observador não é TextScreen então
    // lança um warning
    if ((cols.isEmpty()) && (typeObserver != TObsTextScreen))
    {
        if (execModes != Quiet ){
            string err_out = string("Warning: Attribute table not found. Incorrect sintax.");
            lua_getglobal(L, "customWarningMsg");
            lua_pushstring(L,err_out.c_str());
            lua_pushnumber(L,4);
            lua_call(L,2,0);
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
                string err_out = string("Warning: In this context, the code '") + string(getObserverName(typeObserver)) + string("' does not correspond to a valid type of Observer.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
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
                string err_out = string("Warning: Filename was not specified, using a default '") + string(qPrintable(DEFAULT_NAME)) + string("'");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
            }
            obsLog->setFileName(DEFAULT_NAME + ".csv");
        }
        else
        {
            obsLog->setFileName(cols.at(0));
        }

        // caso não seja definido, utiliza o default ";"
        if ((cols.size() < 2) || cols.at(1).isNull() || cols.at(1).isEmpty())
        {
            if (execModes != Quiet ){
                string err_out = string("Warning: Separator not defined, using ';'.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
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
            if (execModes != Quiet ){
                string err_out = string("Warning: Column title not defined.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
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
            if (execModes != Quiet ){
                string err_out = string("Warning: Port not defined.");
                lua_getglobal(L, "customWarningMsg");
                lua_pushstring(L,err_out.c_str());
                lua_pushnumber(L,4);
                lua_call(L,2,0);
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

const TypesOfSubjects luaTimer::getType()
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

//@RODRIGO
QString luaTimer::getAll(QDataStream& /*in*/, int /*observerId*/, QStringList& attribs)
{
    // @DANIEL
    // lua_rawgeti(luaL, LUA_REGISTRYINDEX, ref);	// recupero a referencia na pilha lua
    Reference<luaTimer>::getReference(luaL);
    return pop(luaL, attribs);
}

QString luaTimer::pop(lua_State *luaL, QStringList& attribs)
{

#ifdef DEBUG_OBSERVER
    printf("\ngetState\n\nobsAttribs.size(): %i\n", obsAttribs.size());
    luaStackToQString(12);
    qDebug() << attribs;
#endif

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

        // Caso o indice não seja um string causava erro
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
    return getAll(in,observerId,attribs);
}

#ifdef TME_BLACK_BOARD
QDataStream& luaTimer::getState(QDataStream& in, Subject *, int observerId, QStringList & /* attribs */)
#else
QDataStream& luaTimer::getState(QDataStream& in, Subject *, int observerId, QStringList &  attribs )
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
