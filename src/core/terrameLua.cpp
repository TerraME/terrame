/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright © 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.

Author: Tiago Garcia de Senna Carneiro
Raian Vargas Maretto
Rodrigo Reis Pereira
*************************************************************************************/
#include "terrameLua.h"
#include "TeVersion.h"

#include "../observer/components/player/player.h"
#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../observer/statistic/statistic.h"
#include <QFile>
#endif

extern "C"
{
#include <lua.h>
}
#include "luna.h"

#include "RandomLib/Random.hpp"

#include <QtGui/QApplication>
#include <QtCore/QSystemLocale>

//------------------------------------------------------------------------------------
#define method(class, name) {#name, &class::name}

//----------------------------------------------------------------------------------------------
/* Pop-up a Windows message box with your choice of message and caption */
//int lua_msgbox(lua_State* L)
//{
//  const char* message = luaL_checkstring(L, 1);
//   const char* caption = luaL_optstring(L, 2, "");
//  int result = MessageBox(NULL, message, caption, MB_OK);
//   lua_pushnumber(L, result);
//   return 1;
//}

#include "reference.h"

//****************************** RANDOM NUMBERS **********************************************//
class RandomUtil : public Reference<RandomUtil>
{
    RandomLib::Random r;

    // @DANIEL
    // Movido para a classe Reference
    // int ref;
public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<RandomUtil>::RegType methods[];
public:
    RandomUtil(lua_State *L)
    {
        // @DANIEL
        // O objeto Lua não está sendo utilizado. Porque colocá-lo na pilha?
        // this->ref = 0;
        // lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        // int top = lua_gettop(L);

        // int seed = (int) luaL_checkinteger(L, top - 1);
        int seed = (int) luaL_checkinteger(L, -1);
        r.Reseed(seed);
    }

    // redistribute(string s)
/*
    int redistribute(lua_State *L){
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        int top = lua_gettop(L);
        QString distribution = luaL_checkstring(L, top - 1);

        if(distribution == "normal"){
            qDebug() << "-->> normal";
        }
        else {
            qDebug() << "-->> not normal";
        }
        return 1;
    }
*/
    // reseed(int v)
    int reseed(lua_State *L){
        // @DANIEL
        // O objeto Lua não está sendo utilizado. Porque colocá-lo na pilha?
        // lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        // int top = lua_gettop(L);
        // int v = (int)luaL_checkinteger(L, top - 1);
        int v = (int)luaL_checkinteger(L, -1);
        this->r.Reseed(v);
        return 1;
    }

    // random()
    // random(a)
    // random(a,b)
    int random(lua_State *L){
        // @DANIEL
        // O objeto Lua não está sendo utilizado. Porque colocá-lo na pilha?
        // lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        // int top = lua_gettop(L);

        // int arg2 = (int)luaL_checkinteger(L, top - 1);
        // int arg = (int)luaL_checkinteger(L, top - 2);
        int arg2 = (int)luaL_checkinteger(L, -1);
        int arg = (int)luaL_checkinteger(L, -2);

        int v;
        double dV;
        if(arg < 0){
            // condition arg < 0 and arg2 < 0 with random() semantics
            if(arg2 < 0){
                dV = this->r.Float();

                lua_pushnumber(L, dV);
                return 1;
            }
            else {
                v = this->r.IntegerC(arg2);
            }
        }
        else
            v = this->r.IntegerC(arg,arg2);
        lua_pushnumber(L, v);
        return 1;
    }

    // random(a)
    // random(a,b)
    int randomInteger(lua_State *L){
        // @DANIEL
        // O objeto Lua não está sendo utilizado. Porque colocá-lo na pilha?
        // lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
        // int top = lua_gettop(L);

        // int arg2 = (int)luaL_checkinteger(L, top - 1);
        // int arg = (int)luaL_checkinteger(L, top - 2);
        int arg2 = (int)luaL_checkinteger(L, -1);
        int arg = (int)luaL_checkinteger(L, -2);
        int v;
                v = this->r.IntegerC(arg,arg2);
        lua_pushnumber(L, v);
        return 1;
    }

    /// Registers the RandomUtil object in the Lua stack
    // @DANIEL
    // Movido para a classe Reference
//    int setReference( lua_State* L)
//    {
//        ref = luaL_ref(L, LUA_REGISTRYINDEX );
//        return 0;
//    }

    /// Gets the RandomUtil object reference
    // @DANIEL
    // Movido para a classe Reference
//    int getReference( lua_State *L )
//    {
//        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
//        return 1;
//    }
};

const char RandomUtil::className[] = "RandomUtil";

Luna<RandomUtil>::RegType RandomUtil::methods[] = {
    method(RandomUtil, random),
    method(RandomUtil, randomInteger),
    method(RandomUtil, reseed),
    method(RandomUtil, getReference),
    method(RandomUtil, setReference),
    {0,0}
};

//****************************** SPACE **********************************************//
//----------------------------------------------------------------------------------------------
const char luaCellIndex::className[] = "TeCoord";

Luna<luaCellIndex>::RegType luaCellIndex::methods[] = {
    method(luaCellIndex, get),
    method(luaCellIndex, set),
    method(luaCellIndex, getReference),
    method(luaCellIndex, setReference),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaNeighborhood::className[] = "TeNeighborhood";

Luna<luaNeighborhood>::RegType luaNeighborhood::methods[] = {
    method(luaNeighborhood, addCell),
    method(luaNeighborhood, eraseCell),
    method(luaNeighborhood, getCellWeight),
    method(luaNeighborhood, setCellWeight),
    method(luaNeighborhood, getWeight),
    method(luaNeighborhood, setWeight),
    method(luaNeighborhood, getCellNeighbor ),
    method(luaNeighborhood, getNeighbor ),
    //method(luaNeighborhood, getNeighbor_ ), // for debugging
    method(luaNeighborhood, first),
    method(luaNeighborhood, last),
    method(luaNeighborhood, isFirst),
    method(luaNeighborhood, isLast),
    method(luaNeighborhood, next),
    method(luaNeighborhood, getCoord),
    method(luaNeighborhood, isEmpty),
    method(luaNeighborhood, clear),
    method(luaNeighborhood, size),
    method(luaNeighborhood, getReference),
    method(luaNeighborhood, setReference),
    method(luaNeighborhood, getID),
    method(luaNeighborhood, addNeighbor),
    method(luaNeighborhood, eraseNeighbor),
    method(luaNeighborhood, setNeighWeight),
	method(luaNeighborhood, getNeighWeight), //Raian
    method(luaNeighborhood, isNeighbor),
    method(luaNeighborhood, getParent), //RAIAN
    method(luaNeighborhood, previous), //RAIAN
    {0,0}
};
//----------------------------------------------------------------------------------------------
//@RODRIGO
const char luaSociety::className[] = "TeSociety";

Luna<luaSociety>::RegType luaSociety::methods[] = {
    method(luaSociety, getReference),
    method(luaSociety, setReference),
    method(luaSociety, createObserver),
    method(luaSociety, notify),
    method(luaSociety, kill),
    //method(luaSociety, setSize),
    //method(luaSociety, getSize),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaCell::className[] = "TeCell";

Luna<luaCell>::RegType luaCell::methods[] = {
    method(luaCell, setLatency),
    method(luaCell, getLatency),
    method(luaCell, setNeighborhood),
    method(luaCell, getNeighborhood),
    method(luaCell, synchronize),
    method(luaCell, getReference),
    method(luaCell, setReference),
    method(luaCell, addNeighborhood),
    method(luaCell, first),
    method(luaCell, last),
    method(luaCell, getID),
    method(luaCell, setID),
    method(luaCell, isFirst),
    method(luaCell, isLast),
    method(luaCell, next),
    method(luaCell, getCurrentNeighborhood),
    method(luaCell, size),
    method(luaCell, getCurrentStateName),
	//Raian
	method(luaCell, setIndex),
    // ANTONIO
    method(luaCell, createObserver),
    method(luaCell, notify),
    method(luaCell, kill),
    {0,0}
};
//----------------------------------------------------------------------------------------------//////////////////////////////
const char luaCellularSpace::className[] = "TeCellularSpace";

Luna<luaCellularSpace>::RegType luaCellularSpace::methods[] = {
    method(luaCellularSpace, setDBType ),
    method(luaCellularSpace, setHostName ),
    method(luaCellularSpace, setDBName ),
    method(luaCellularSpace, getDBName ),
    method(luaCellularSpace, setUser ),
    method(luaCellularSpace, setPassword ),
    method(luaCellularSpace, setLayer ),
    method(luaCellularSpace, setTheme ),
    method(luaCellularSpace, clearAttrName ),
    method(luaCellularSpace, addAttrName ),
    method(luaCellularSpace, load ),
    method(luaCellularSpace, loadShape ),
    method(luaCellularSpace, saveShape ),
    method(luaCellularSpace, save ),
    method(luaCellularSpace, clear ),
    method(luaCellularSpace, size ),
    method(luaCellularSpace, addCell ),
    method(luaCellularSpace, setWhereClause ),
    method(luaCellularSpace, loadNeighborhood ),
    method(luaCellularSpace, loadTerraLibGPM ),
    method(luaCellularSpace, getReference),
    method(luaCellularSpace, setReference),
    method(luaCellularSpace, getCell),
    method(luaCellularSpace, setPort),

    // ANTONIO
    method(luaCellularSpace, createObserver),
    method(luaCellularSpace, notify),
    method(luaCellularSpace, kill),
	// @RAIAN
	method(luaCellularSpace, getLayerName),
	method(luaCellularSpace, getCellByID),
    {0,0}
};
//****************************** BEHAVIOR *******************************************//
//----------------------------------------------------------------------------------------------
const char luaJumpCondition::className[] = "TeJump";

Luna<luaJumpCondition>::RegType luaJumpCondition::methods[] = {
    method(luaJumpCondition, setTargetControlModeName),
    method(luaJumpCondition, getReference),
    method(luaJumpCondition, setReference),
    {0,0}
};
//----------------------------------------------------------------------------------------------
const char luaFlowCondition::className[] = "TeFlow";

Luna<luaFlowCondition>::RegType luaFlowCondition::methods[] = {
    method(luaFlowCondition, getReference),
    method(luaFlowCondition, setReference),
    {0,0}
};
//----------------------------------------------------------------------------------------------
const char luaControlMode::className[] = "TeState";

Luna<luaControlMode>::RegType luaControlMode::methods[] = {
    method(luaControlMode, add),
    method(luaControlMode, addFlow),
    method(luaControlMode, addJump),
    method(luaControlMode, getName),
    method(luaControlMode, config),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaGlobalAgent::className[] = "TeGlobalAutomaton";

Luna<luaGlobalAgent>::RegType luaGlobalAgent::methods[] =
{
    method(luaGlobalAgent, add),
    method(luaGlobalAgent, getLatency ),
    method(luaGlobalAgent, build ),
    method(luaGlobalAgent, setActionRegionStatus ),
    method(luaGlobalAgent, getActionRegionStatus ),
    method(luaGlobalAgent, execute ),
    method(luaGlobalAgent, getControlModeName ),
    method(luaGlobalAgent, getReference),
    method(luaGlobalAgent, setReference),

    // ANTONIO
    method(luaGlobalAgent, createObserver),
    method(luaGlobalAgent, notify),
    method(luaGlobalAgent, kill),
    {0,0}
};
//----------------------------------------------------------------------------------------------
const char luaLocalAgent::className[] = "TeLocalAutomaton";

Luna<luaLocalAgent>::RegType luaLocalAgent::methods[] =
{
    method(luaLocalAgent, add),
    method(luaLocalAgent, getLatency ),
    method(luaLocalAgent, build ),
    method(luaLocalAgent, setActionRegionStatus ),
    method(luaLocalAgent, execute),
    method(luaLocalAgent, getReference),
    method(luaLocalAgent, setReference),

    // ANTONIO
    method(luaLocalAgent, createObserver),
    method(luaLocalAgent, notify),
    method(luaLocalAgent, kill),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaTrajectory::className[] = "TeTrajectory";

Luna<luaTrajectory>::RegType luaTrajectory::methods[] = {
    method(luaTrajectory, add),
    method(luaTrajectory, clear ),
    method(luaTrajectory, getReference),
    method(luaTrajectory, setReference),

    // ANTONIO
    method(luaTrajectory, createObserver),
    method(luaTrajectory, notify),
    method(luaTrajectory, kill),
    {0,0}
};

//****************************** TIME ***********************************************//
//----------------------------------------------------------------------------------------------
const char luaMessage::className[] = "TeMessage";

Luna<luaMessage>::RegType luaMessage::methods[] = {
    method(luaMessage, config),
    method(luaMessage, getReference),
    method(luaMessage, setReference),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaEvent::className[] = "TeEvent";

Luna<luaEvent>::RegType luaEvent::methods[] =
{
    method(luaEvent, config),
    method(luaEvent, getTime),
    method(luaEvent, getPeriod),
    method(luaEvent, setPriority),
    method(luaEvent, getPriority),
    method(luaEvent, getReference),
    method(luaEvent, setReference),

    //Antonio
    method(luaEvent, createObserver),
    method(luaEvent, notify),
    method(luaEvent, getType),
    method(luaEvent, kill),
    {0,0}
};

//----------------------------------------------------------------------------------------------
const char luaTimer::className[] = "TeTimer";

Luna<luaTimer>::RegType luaTimer::methods[] =
{
    method(luaTimer, add),
    method(luaTimer, getTime),
    method(luaTimer, isEmpty),
    method(luaTimer, reset),
    method(luaTimer, execute),
    //method(luaTimer, execute),

    //Antonio
    method(luaTimer, getReference),
    method(luaTimer, setReference),
    method(luaTimer, createObserver),
    method(luaTimer, notify),
    method(luaTimer, kill),
    {0,0}
};
//****************************** ENVIRONMENT ****************************************//
//----------------------------------------------------------------------------------------------
const char luaEnvironment::className[] = "TeScale";

Luna<luaEnvironment>::RegType luaEnvironment::methods[] =
{
    method(luaEnvironment, config),
    method(luaEnvironment, execute),
    method(luaEnvironment, add),
    method(luaEnvironment, addTimer),
    method(luaEnvironment, addCellularSpace),
    method(luaEnvironment, addGlobalAgent),
    method(luaEnvironment, addLocalAgent),

    //Antonio
    method(luaEnvironment, getReference),
    method(luaEnvironment, setReference),
    method(luaEnvironment, createObserver),
    method(luaEnvironment, notify),
    method(luaEnvironment, kill),
    {0,0}
};

//////////////////////////////////////////////////////////////////////////////
//// Percorre a lista de widget fechando cada um deles
//// Método responsável por evitar a mensagem abaixo na tela
//// "QObject::killTimers: timers cannot be stopped from another thread"
//void closeAllWidgets()
//{
//  int i = 0;
//  foreach (QWidget *widget, QApplication::allWidgets()){
//    widget->close();
//    i++;
//    printf("%i", i);
//  }
//}

////////////////////////////////////////////////////////////////////////////
// Percorre a lista de widget verificando se
// algum widget foi inicializado
bool existWindows()
{
    foreach (QWidget *widget, QApplication::allWidgets())
    {
        if (widget) // && widget->isVisible())
            return true;
    }
    return false;
}

void outputHandle(QtMsgType type, const char *msg)
{
    // ModelConsole &console = ModelConsole::getInstance();
    //if(! console.isVisible())
    //    console.show();

    Player &player = Player::getInstance();

    //in this function, you can write the message to any stream!
    switch (type) {
        case QtDebugMsg:
            player.appendMessage("Debug: " + QString(msg));
            break;

        case QtWarningMsg:
            player.appendMessage(QString(msg));
            break;

        case QtCriticalMsg:
            player.appendMessage("Critical: " + QString(msg));
            break;

        case QtFatalMsg:
            player.appendMessage("Fatal: " + QString(msg));
            fprintf(stderr, "Fatal: %s\n", msg);
            abort();

        default:
            fprintf(stdout, "%s\n", msg);
            break;
    }
}

// Shows the usage of TerraME
void usage()
{
    qWarning("\nUsage: TerraME [[-gui] | [-mode=normal|debug|strict|quiet]] modelFile1.lua");
    qWarning("\t  or TerraME [-version]");
    qWarning("\n Options: ");
    qWarning("\t -gui     \t Show the player for the application; ");
    qWarning("\t          \t Only when an Environment and/or a Timer objects are used.");
    qWarning("\t -mode=normal (default)  \t Warnings disabled");
	qWarning("\t -mode=debug   \t\t\t Warnings enabled");    
	qWarning("\t -mode=stric   \t\t\t All warnings treated as errors");    
	qWarning("\t -mode=quiet   \t\t\t Information messages disabled");
    qWarning("\t -version \t\t\t TerraME general information");

    //fprintf(stderr, "\nYou should provide, at least, a model file as parameter.\n");
    //fprintf(stderr, "\nUsage examples: ");
    //fprintf(stderr, "\n\tTerraME [-gui] [-quiet] myModel1.lua [myModel2.lua .. myModelN.lua]\n");
    //fprintf(stderr, "\n\tTerraME -version\n");
}

// Shows the TerraMe and dependecies versions
void versions()
{
    //qWarning("\nTerraLab -- Earth System Modelling and Simulation Laboratory");
    qWarning("\nTerraME - Terra Modelling Environment");
    qWarning("    Version: %s ", TME_VERSION);     // macro in the file "terrameLua5_1.h"
    // string buffer = "TME_PATH_";

    QString tmeVersion = QString("%1").arg(TME_VERSION);
    // buffer.append(tmeVersion.replace(QString("."),QString("_")).toAscii().constData());
    // qWarning("        Location: '%s' ", getenv(buffer.c_str()));
    qWarning("        Location (TME_PATH): '%s' ", getenv(TME_PATH));

    qWarning("\nCompiled with: ");
    qWarning("    %s ", LUA_RELEASE);                  // macro in the file "lua.h"
    qWarning("    Qt %s ", qVersion());                // Qt version method
    qWarning("    Qwt %s ", QWT_VERSION_STR);          // macro in the file "qwt_global.h"                   
    qWarning("    TerraLib %s (Database version: %s) ", 
        TERRALIB_VERSION,       // macro in the file "TeVersion.h"
        TeDBVERSION.c_str());   // macro in the file "TeDefines.h" linha 221

    qWarning("\nFor more information, please visit: www.terrame.org\n");
}

/// Opens Lua environment and Lua libraries 
void openLuaEnvironment()
{
    // tentando utilizar um tipo meu em lua
    //L = lua_open();
    L = luaL_newstate();

#if defined( TME_LUA_5_0 )
    luaopen_base(L);             // opens the basic library
    luaopen_table(L);            // opens the table library
    luaopen_io(L);               // opens the I/O library
    luaopen_string(L);           // opens the string lib.
    luaopen_math(L);             // opens the math lib.
#else
    luaL_openlibs(L);  // open libraries
#endif
}

/// Records TerraME classes into Lua environment
void registerClasses()
{
    //lua_register(L, "msgbox",  lua_msgbox);

    Luna<luaCellIndex>::Register(L);

    Luna<luaCell >::Register(L);
    Luna<luaNeighborhood >::Register(L);
    Luna<luaCellularSpace >::Register(L);

    Luna<luaFlowCondition >::Register(L);
    Luna<luaJumpCondition >::Register(L);
    Luna<luaControlMode >::Register(L);
    Luna<luaLocalAgent >::Register(L);
    Luna<luaGlobalAgent >::Register(L);

    Luna<luaTimer >::Register(L);
    Luna<luaEvent >::Register(L);
    Luna<luaMessage >::Register(L);

    Luna<luaEnvironment > ::Register(L);

    Luna<luaTrajectory > ::Register(L);    

    //@RODRIGO
    Luna<RandomUtil > ::Register(L);
    Luna<luaSociety > ::Register(L);
}


extern ExecutionModes execModes;

#ifndef TME_RECEIVER_MODE
int main ( int argc, char *argv[] )
{
    Q_INIT_RESOURCE(observerResource);

    // TODO
    // retrive lua version from TerraME.lua
    TME_VERSION = "1.3.0";
    TME_PATH = "TME_PATH_1_3_0";

    QApplication app(argc, argv);
    //app.setQuitOnLastWindowClosed(true);

#ifdef TME_STATISTIC
    Statistic::getInstance();
#endif

    execModes = Normal;
    SHOW_GUI = false;
    paused = false;
    step = false;

    // Register the message handle of Observer Player
    if ((argc > 2) && (! strcmp(argv[1], "-gui")) )
    {
        SHOW_GUI = true;

        qInstallMsgHandler(outputHandle);
        Player::getInstance().show();
        Player::getInstance().setEnabled(false);

        qWarning("Warning: The TerraME Player will be able to execute only when "
            "an Environment and/or a Timer object are used in the model file.");
        app.processEvents();
    }    

    // Loads the TerrME constructors for LUA
    QString tmePath(getenv(TME_PATH));

    if (tmePath.isEmpty())
    {
        qFatal("%s environment variable should exist and point to TerraME "
            "installation folder.", TME_PATH);
    }

    openLuaEnvironment();  // Opens Lua environment and libraries
    registerClasses();      // records TerraME Classes in Lua environment

#if defined ( TME_WIN32 )
    tmePath.append("\\bin\\Lua\\Utils.lua");
#else
    tmePath.append("/bin/Lua/Utils.lua");
#endif

    //char buff[256];

    // runs the lua core files 
    int error = luaL_loadfile(L, tmePath.toAscii().constData()) || lua_pcall(L, 0, 0, 0);
    if (error)
    {
        fprintf(stderr, "\n%s", lua_tostring(L, -1));
        lua_pop(L, 1);  // pop error message from the stack
        lua_close( L );
        return -1;
    }

    // Execute the lua files passe
    if( argc < 2)
    {
        qWarning("\nYou should provide, at least, a model file as parameter.");
        usage();
        qWarning("\nPlease, try again...");
        lua_close( L );
        return -1;
    }

    int argument = 1;
    while( argument < argc )
    {
        if ( argv[argument][0] == '-')
        {
            if ( ! strcmp(argv[argument],"-version") )
            {
                versions();
            }
            else
            {
                if ( ! strcmp(argv[argument],"-mode=quiet") )
                {
                    execModes = Quiet;
                }
                else {
                    if(! strcmp(argv[argument],"-mode=strict")){
                        execModes = Strict;
                    }
                    else
                    {
                        if(! strcmp(argv[argument],"-mode=normal")){
                            execModes = Normal;
                        }
                        else {
                            if(! strcmp(argv[argument],"-mode=debug")){
                                execModes = Debug;
                            }
                            else {
                                // argv[argument] is not "-gui"
                                if ( strcmp(argv[argument],"-gui") )
                                {
                                    qWarning("\nInvalid argument.");
                                    usage();
                                    return -1;
                                }
                            }
                        }
                    }
                }
            }

			if (argc < 3)
			{
				usage();
				return -1;
			}
        }
        else
        {
            // creates the "TME_MODE" variable in the Lua namespace
            lua_pushnumber(L, execModes);
            lua_setglobal(L, "TME_MODE");

#ifdef TME_STATISTIC
            float t = Statistic::getInstance().startTime();
#endif
            // runs the lua files received as paremeters
            error =  luaL_loadfile(L, argv[argument] ) || lua_pcall(L, 0, 0, 0);

#ifdef TME_STATISTIC
            t = Statistic::getInstance().startTime() - t;
            qDebug() << "total simulation time (ms): " << t;
#endif

            if (error)
            {
                fprintf(stderr, "\n%s\n", lua_tostring(L, -1));
                lua_pop(L, 1);  // pop error message from the stack
                lua_close( L );
                return false;
            }
        }
        argument++;

    }
    //// Lua interpreter line-by-line
    //while (fgets(buff, sizeof(buff), stdin) != NULL)
    //{
    //error = luaL_loadbuffer(L, buff, strlen(buff), "line") ||lua_pcall(L, 0, 0, 0);
    //if (error)
    //{
    //   fprintf(stderr, "%s", lua_tostring(L, -1));
    //   lua_pop(L, 1);  // pop error message from the stack
    //}
    //}

    lua_close( L );

    // Caso no exista nenhum janela entao finaliza
    // a aplicacao
    if (! existWindows()){
        app.exit();
        return 0;
    }

    // Percorre uma lista fechando todos os widgets
    //closeAllWidgets();

    //int ret = app.exec();
    //return ret;

#ifdef TME_STATISTIC
    Statistic::getInstance().collectMemoryUsage();
    Statistic::getInstance().saveData();
    QFile::copy(app.applicationDirPath() + "/output_MemoryUsage.txt",
        app.applicationDirPath() + "/memoryUsage_"
                        + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
                        + "_.csv");

    QFile statFile(app.applicationDirPath() + "/output_MemoryUsage.txt");
    if (statFile.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&statFile);
        out << "Name                Pid      VM      WS    Priv Priv Pk   Faults   NonP Page";
    }
    else
        qDebug() << "erro ao abrir arquivo";

    exit(0);
#endif

    return app.exec();
}
#else

#include "../observer/components/receiver/receiver.h"


int main ( int argc, char *argv[] )
{
    Q_INIT_RESOURCE(observerResource);
    QApplication app(argc, argv);

    qDebug() << "Running in receiver mode....";
    
    Receiver receiver;
    receiver.show();

    int ret = app.exec();

#ifdef TME_STATISTIC
    Statistic::getInstance().collectMemoryUsage();
    Statistic::getInstance().saveData();
#endif
    return ret;
}    

#endif
