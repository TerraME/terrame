/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

#include <QApplication>
#include "../observer/observerImpl.h"
// #include <QSystemLocale>
#include <QFontDatabase>
#include <QMessageBox>
#include <QProcess>
#include <QLoggingCategory>

#include "Downloader.h"
#include "blackBoard.h"
#include "protocol.pb.h"

#ifndef TME_OBSERVER_CLIENT_MODE

#include "terrameLua.h"

#include <stdlib.h>

#ifndef TME_NO_TERRALIB
	// #include "TeVersion.h" // issue #319
#endif

#include "player.h"
#include "registryObjects.h"

#include "terrameVersion.h"

extern "C"
{
	#include "lfs.h"
}

#include "LuaSystem.h"
#include "LuaFacade.h"
#include "luna.h"
#include "LuaBindingDelegate.h"

QApplication* app;

//////////////////////////////////////////////////////////////////////////////
//// Runs through the widget list closing each
//// Method responsible for avoiding the below message on the screen
//// "QObject::killTimers: timers cannot be stopped from another thread"
//void closeAllWidgets()
//{
//  int i = 0;
//  foreach(QWidget *widget, QApplication::allWidgets()) {
//	widget->close();
//	i++;
//	printf("%i", i);
//  }
//}

bool existWindows()
{
	foreach(QWidget *widget, QApplication::allWidgets())
	{
		if (widget && widget->isVisible())
			return true;
	}
	return false;
}

void outputHandle(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
	QMessageBox msgBox;
	msgBox.setText("Debug: " + QString(msg.toLatin1().data()));

    switch (type) {
        case QtDebugMsg:
			msgBox.setIcon(QMessageBox::Information);
			msgBox.exec();
            break;
        case QtWarningMsg:
			msgBox.setIcon(QMessageBox::Warning);
			msgBox.exec();
            break;
        case QtCriticalMsg:
        case QtFatalMsg:
			msgBox.setIcon(QMessageBox::Critical);
			msgBox.exec();
            abort();
        default:
            break;
    }
}

/// Opens Lua environment and Lua libraries
void openLuaEnvironment()
{
	// trying to use one of my type in lua
	//L = lua_open();
	L = luaL_newstate();

#if defined(TME_LUA_5_0)
	luaopen_base(L);			 // opens the basic library
	luaopen_table(L);			// opens the table library
	luaopen_io(L);			   // opens the I/O library
	luaopen_string(L);		   // opens the string lib.
	luaopen_math(L);			 // opens the math lib.
#else
	luaL_openlibs(L);  // open libraries
#endif
}

/// Records TerraME classes into Lua environment
void registerClasses()
{
	//lua_register(L, "msgbox",  lua_msgbox);

	Luna<luaCellIndex>::getInstance()->setup(L);
	terrame::lua::LuaBindingDelegate<luaCellIndex>::getInstance().setBinding(Luna<luaCellIndex>::getInstance());

	Luna<luaCell>::getInstance()->setup(L);
	terrame::lua::LuaBindingDelegate<luaCell>::getInstance().setBinding(Luna<luaCell>::getInstance());

	Luna<luaNeighborhood>::getInstance()->setup(L);
	terrame::lua::LuaBindingDelegate<luaNeighborhood>::getInstance().setBinding(Luna<luaNeighborhood>::getInstance());

	Luna<luaCellularSpace>::getInstance()->setup(L);
	terrame::lua::LuaBindingDelegate<luaCellularSpace>::getInstance().setBinding(Luna<luaCellularSpace>::getInstance());

	Luna<luaFlowCondition>::getInstance()->setup(L);
	Luna<luaJumpCondition>::getInstance()->setup(L);
	Luna<luaControlMode>::getInstance()->setup(L);
	Luna<luaLocalAgent>::getInstance()->setup(L);
	terrame::lua::LuaBindingDelegate<luaLocalAgent>::getInstance().setBinding(Luna<luaLocalAgent>::getInstance());
	Luna<luaGlobalAgent>::getInstance()->setup(L);

	Luna<luaTimer>::getInstance()->setup(L);
	Luna<luaEvent>::getInstance()->setup(L);
	Luna<luaMessage>::getInstance()->setup(L);

	Luna<luaEnvironment>::getInstance()->setup(L);
	Luna<luaTrajectory>::getInstance()->setup(L);
	Luna<luaVisualArrangement>::getInstance()->setup(L);
	Luna<luaMap>::getInstance()->setup(L);
	Luna<luaChart>::getInstance()->setup(L);
	Luna<luaSociety>::getInstance()->setup(L);
	Luna<luaTextScreen>::getInstance()->setup(L);
	Luna<luaTable>::getInstance()->setup(L);
	Luna<luaLogFile>::getInstance()->setup(L);
	Luna<luaTcpSender>::getInstance()->setup(L);
	Luna<luaUdpSender>::getInstance()->setup(L);
}

int cpp_runcommand(lua_State *L)
{
    const char* command = lua_tostring(L, -1);
	QString cmd = QString::fromLocal8Bit(command);
	QProcess process;
	process.start(cmd);
	process.waitForFinished(-1); // will wait forever until finished

	QString out = QString::fromLocal8Bit(process.readAllStandardOutput());
	QString err = QString::fromLocal8Bit(process.readAllStandardError());

    out.remove(QRegExp("[\\r]"));
    err.remove(QRegExp("[\\r]"));

    lua_pushstring(L, out.toStdString().data());
    lua_pushstring(L, err.toStdString().data());
	return 2;
}

int cpp_informations(lua_State *L)
{
	lua_pushstring(L, TERRAME_VERSION_STRING);
	lua_pushstring(L, LUA_RELEASE);
	lua_pushstring(L, qVersion());
	lua_pushstring(L, QWT_VERSION_STR);

	return 4;
}

int cpp_version(lua_State *L)
{
	lua_pushstring(L, TERRAME_VERSION_STRING);

	return 1;
}

int cpp_imagesize(lua_State *L)
{
    const char* s = lua_tostring(L, -1);
	int width, height;

	imageSize(s, width, height);

	lua_pushnumber(L, width);
	lua_pushnumber(L, height);
	return 2;
}

int cpp_imagecompare(lua_State *L)
{
    const char* s1 = lua_tostring(L, -1);
    const char* s2 = lua_tostring(L, -2);

	QString f1(QString::fromLocal8Bit(s1));
	QString f2(QString::fromLocal8Bit(s2));

	double result = comparePerPixel(f1, f2);

	lua_pushnumber(L, result);
	return 1;
}

int cpp_listpackages(lua_State* L)
{
    const char* s1 = lua_tostring(L, -1);
	Downloader* d = new Downloader;
	QString str = d->listPackages(s1);

	lua_pushstring(L, str.toLatin1().constData());
	delete d;

	return 1;
}

int cpp_downloadpackage(lua_State* L)
{
    const char* repos = lua_tostring(L, -1);
    const char* file = lua_tostring(L, -2);
	Downloader* d = new Downloader;
	QString str = d->downloadPackage(file, repos);

	lua_pushstring(L, str.toLatin1().constData());
	delete d;
	return 1;
}

int cpp_loadfont(lua_State *L)
{
	QFontDatabase qfd;

    const char* s1 = lua_tostring(L, -1);
	int result = qfd.addApplicationFont(s1);

	lua_pushnumber(L, result);
	return 1;
}

int cpp_hasfont(lua_State *L)
{
	QFontDatabase qfd;

    const char* s1 = lua_tostring(L, -1);
	int result = qfd.font(s1, QString(), 10).family() == QString(s1);

	lua_pushnumber(L, result);
	return 1;
}

int cpp_setdefaultfont(lua_State *L)
{
#ifdef Q_OS_MAC
	app->setFont(QFont("Ubuntu", 12));
#else
	app->setFont(QFont("Ubuntu", 9));
#endif

	return 0;
}

int cpp_restartobservercounter(lua_State *L)
{
	restartObserverCounter();
	return 0;
}

int cpp_putenv(lua_State* L)
{
	std::string path = lua_tostring(L, -1);

#ifdef WIN32
	std::string p(getenv("TME_PATH"));
	p.append(";");
	p.append(path);
	p.append(";");
	p.append(getenv("PATH"));
	_putenv_s("PATH", p.c_str());
#endif

	return 0;
}

int cpp_getOsName(lua_State* L)
{
	#ifdef _WIN64
		lua_pushstring(L, "windows");
	#elif __APPLE__
		lua_pushstring(L, "mac");
	#elif __linux__
		lua_pushstring(L, "linux");
	#endif

	return 1;
}

int cpp_getLocale(lua_State* L)
{
	std::locale loc("");
	lua_pushstring(L, loc.name().c_str());

	return 1;
}

extern ExecutionModes execModes;

int main(int argc, char *argv[])
{
	// Verify that the version of the library that we linked against is
	// compatible with the version of the headers we compiled against.
	GOOGLE_PROTOBUF_VERIFY_VERSION;

	Q_INIT_RESOURCE(observerResource);

	QLoggingCategory::setFilterRules("qt.network.ssl.warning=false");

	terrame::lua::LuaSystem::getInstance().setLuaApi(terrame::lua::LuaFacade::getInstance());

	TME_PATH = "TME_PATH";

#ifdef WIN32
	std::string p(getenv("TME_PATH"));
	p.append(";");
	p.append(getenv("PATH"));
	_putenv_s("PATH", p.c_str());
#endif

	app = new QApplication(argc, argv); // #79
	//app.setQuitOnLastWindowClosed(true);

	execModes = Normal;
	SHOW_GUI = false;
	WORKERS_NUMBER = 505;
	paused = false;
	step = false;

	// Register the message handle of Observer Player
	if ((argc > 2) && (!strcmp(argv[1], "-gui")))
	{
		SHOW_GUI = true;

        qInstallMessageHandler(outputHandle);
        Player::getInstance().show();
        Player::getInstance().setEnabled(false);

		app->processEvents();
	}

	// Loads the TerrME constructors for LUA
	QString tmePath(getenv(TME_PATH));

	if (tmePath.isEmpty())
	{
		qCritical("Error: %s environment variable should exist and point to TerraME "
			"installation directory.", TME_PATH);
		app->exit(1);
		exit(EXIT_FAILURE);
	}

	openLuaEnvironment();  // Opens Lua environment and libraries
	registerClasses();	  // records TerraME Classes in Lua environment

	// Loads lfs functions
	luaopen_lfs(L);

	tmePath.append("/lua/terrame.lua");

    // runs the lua core files
    int error = luaL_loadfile(L, tmePath.toLatin1().constData()) || lua_pcall(L, 0, 0, 0);
    if (error)
    {
        fprintf(stderr, "\n%s\n", lua_tostring(L, -1));
        lua_pop(L, 1);  // pop error message from the stack
        lua_close(L);
        return -1;
    }

	lua_pushcfunction(L, cpp_runcommand);
	lua_setglobal(L, "cpp_runcommand");

	lua_pushcfunction(L, cpp_listpackages);
	lua_setglobal(L, "cpp_listpackages");

	lua_pushcfunction(L, cpp_downloadpackage);
	lua_setglobal(L, "cpp_downloadpackage");

	lua_pushcfunction(L, cpp_informations);
	lua_setglobal(L, "cpp_informations");

	lua_pushcfunction(L, cpp_version);
	lua_setglobal(L, "cpp_version");

	lua_pushcfunction(L, cpp_imagecompare);
	lua_setglobal(L, "cpp_imagecompare");

	lua_pushcfunction(L, cpp_imagesize);
	lua_setglobal(L, "cpp_imagesize");

	lua_pushcfunction(L, cpp_loadfont);
	lua_setglobal(L, "cpp_loadfont");

	lua_pushcfunction(L, cpp_hasfont);
	lua_setglobal(L, "cpp_hasfont");

	lua_pushcfunction(L, cpp_setdefaultfont);
	lua_setglobal(L, "cpp_setdefaultfont");

	lua_pushcfunction(L, cpp_restartobservercounter);
	lua_setglobal(L, "cpp_restartobservercounter");

	lua_pushcfunction(L, cpp_putenv);
	lua_setglobal(L, "cpp_putenv");

	lua_pushcfunction(L, cpp_getOsName);
	lua_setglobal(L, "cpp_getOsName");

	lua_pushcfunction(L, cpp_getLocale);
	lua_setglobal(L, "cpp_getLocale");

	// Execute the lua files
	if (argc < 2)
	{
		lua_getglobal(L, "_Gtme");
		lua_getfield(L, -1, "execute");
		lua_pushnil(L);
		lua_call(L, 1, 0);
	}
	else
	{
		lua_getglobal(L, "_Gtme");
		lua_getfield(L, -1, "execute");
		lua_newtable(L);

		int argument = 1;
		while (argument < argc)
		{
			lua_pushnumber(L, argument);
			lua_pushstring(L, argv[argument]);
			lua_settable(L, -3);

			argument++;
		}

		lua_call(L, 1, 0);
	}

#ifdef NOCPP_RAIAN
		if (argv[argument][0] == '-')
		{
			if (!strcmp(argv[argument], "-draw-all-higher"))
			{
				bool ok = false;
				double time = QString(argv[argument + 1]).toDouble(&ok);
				if (ok) //  && (time >= 0 && time <= 100))
					BlackBoard::getInstance().setPercent(time * 0.01);
				else
					BlackBoard::getInstance().setPercent((double) 0.8);

				argument++;
			}
			else if (!strcmp(argv[argument], "-workers"))
			{
				bool ok = false;
				int number = QString(argv[argument + 1]).toInt(&ok);
				if (ok) WORKERS_NUMBER = number;

				argument++;
			}
			else if (strcmp(argv[argument], "-gui"))
			{
				qWarning("\nInvalid arguments.");
				usage();
				return -1;
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

			// runs the lua files received as parameters
			error =  luaL_loadfile(L, argv[argument]) || lua_pcall(L, 0, 0, 0);

			if (error)
			{
				fprintf(stderr, "\n%s\n", lua_tostring(L, -1));
				lua_pop(L, 1);  // pop error message from the stack
				lua_close(L);
				return false;
			}
		}
		argument++;

#endif //NOCPP_RAIAN
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

	if (!existWindows())
	{
        //lua_close(L); // issue #562
        app->exit();
		delete app;
        return 0;
	}

	//closeAllWidgets();

	//int ret = app.exec();
	//return ret;

	bool autoClose = false;
	lua_getglobal(L, "info_");
	int top = lua_gettop(L);
	if (lua_istable(L, top))
	{
		lua_getfield(L, top, "autoclose");
		top = lua_gettop(L);
		autoClose = lua_toboolean(L, top);
		lua_pop(L, 2);
	}

#ifndef __APPLE__
	lua_close(L);
#endif

	if (autoClose)
	{
		// app.processEvents();
		exit(0);
		qDebug() << "\ncloseAllWindows()"; std::cout.flush();
		return 0;
	}

	int returnv = app->exec();
	delete app;
	return returnv;
}
#else

extern ExecutionModes execModes;

int WORKERS_NUMBER = 0;
execModes = Normal;
bool step = false;
bool paused = false;

#include "receiverUDP.h"
#include "receiverTcpServer.h"

void receiverUsage()
{
	qWarning() << "You need to put the mode of receiver.";
	qWarning() << "Specific the mode: ";
	qWarning() << "   terrame -help				   \t Show this help and exit";
	qWarning() << "   terrame ";
	qWarning() << "   terrame -workers <value> [option] \t Show this helps";
	qWarning() << "\nOption";
	qWarning() << "	-tcp			  \t Receiver in mode TCP (default mode)";
	qWarning() << "	-udp			  \t Receiver in mode UDP";
	qWarning() << "";
}

int main(int argc, char *argv[])
{
	Q_INIT_RESOURCE(observerResource);
	QApplication app(argc, argv);

	int ret = -1;

	if (argc < 2)
	{
		qWarning() << "Running in receiver in mode TCP..";
		ReceiverTcpServer receiver;
		receiver.show();
		return app.exec();
	}
	else
	{
		QStringList argsList = app.arguments();

		int index = argsList.indexOf("-workers");
		if (index > 1)
		{
			bool ok = false;
			int number = argsList.at(index++).toInt(&ok);
			if (ok) WORKERS_NUMBER = number;
		}

		index = argsList.indexOf("-help");
		if (index > 1)
		{
			receiverUsage();
			return 0;
		}

		index = argsList.indexOf("-tcp");
		if (index > 1)
		{
			qWarning() << "Running in receiver in mode TCP..";
			ReceiverTcpServer receiver;
			receiver.show();

			ret = app.exec();
		}

		index = argsList.indexOf("-udp");
		if (index > 1)
		{
			qWarning() << "Running in receiver in mode UDP..";
			ReceiverUDP receiver;
			receiver.show();

			ret = app.exec();
		}
	}

	return ret;
}

#endif

