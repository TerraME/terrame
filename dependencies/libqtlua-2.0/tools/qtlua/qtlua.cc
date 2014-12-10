/*
    This file is part of LibQtLua.

    LibQtLua is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    LibQtLua is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with LibQtLua.  If not, see <http://www.gnu.org/licenses/>.

    Additional Terms 7.b of GPLv3 applies to this file: Requiring
    preservation of specified reasonable legal notices or author
    attributions in that material or in the Appropriate Legal Notices
    displayed by works containing it;

    Copyright (C) 2008, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#include "config.hh"

extern "C" {
#include <lua.h>
#ifdef HAVE_LUA_JITLIB
# include <luajit.h>
#endif
}

#include <QApplication>
#include <QFile>
#include <QDialog>
#include <QSettings>
#include <QPointer>

#include <QtLua/State>
#include <QtLua/Console>

#ifndef LUA_RELEASE
# define LUA_RELEASE LUA_VERSION
#endif

#ifndef LUAJIT_VERSION
# define QTLUA_USING "(using Qt " QT_VERSION_STR " and " LUA_RELEASE ")"
#else
# define QTLUA_USING "(using Qt " QT_VERSION_STR " and " LUA_RELEASE ", " LUAJIT_VERSION ")"
#endif

#define QTLUA_COPYRIGHT "QtLua " PACKAGE_VERSION " " QTLUA_USING "\n" \
                        "Copyright (C) 2008-2013, Alexandre Becoulet"

int main(int argc, char *argv[])
{
  try {
    QApplication app(argc, argv);
    QStringList args = app.arguments();
    QPointer<QtLua::Console> console(0);
    QSettings settings("QtLua", "qtlua tool");

    bool interactive = argc == 1;
    bool execute = interactive;

    QtLua::State state;
    state.enable_qdebug_print();
    state.openlib(QtLua::AllLibs);

    state["app"] = QtLua::Value(&state, &app, false, false);

    for (int i = 1; i < argc; i++)
      {
	QByteArray arg(argv[i]);

	if (arg[0] == '-')
	  {
	    // option
	    if (arg == "--interactive" || arg == "-i")
	      {
		execute = interactive = true;
	      }
	    else
	      {
		std::cerr
		  << QTLUA_COPYRIGHT << std::endl
		  << "usage: qtlua [options] luafiles ..." << std::endl
		  << "  -i --interactive    show a lua console dialog" << std::endl;
	      }
	  }
	else
	  {
	    // lua chunk file
	    QFile file(argv[i]);

	    if (!file.open(QIODevice::ReadOnly))
	      throw QtLua::String("Unable to open `%' file.").arg(argv[i]);

	    execute = true;

	    if(!file.readLine().startsWith("#!"))
	      file.seek(0);

	    state.exec_chunk(file);
	  }
      }

    if (interactive)
      {
	console = new QtLua::Console(0, ">>");

	console->load_history(settings);

	QObject::connect(console, SIGNAL(line_validate(const QString&)),
			 &state, SLOT(exec(const QString&)));

	QObject::connect(console, SIGNAL(get_completion_list(const QString &, QStringList &, int &)),
		&state, SLOT(fill_completion_list(const QString &, QStringList &, int &)));

	QObject::connect(&state, SIGNAL(output(const QString&)),
			 console, SLOT(print(const QString&)));

	console->print(QTLUA_COPYRIGHT "\n");
	console->print("You may type: help(), list() and use TAB completion.\n");
	console->show();
      }

    if (execute)
      app.exec();

    if (console)
      console->save_history(settings);

  } catch (QtLua::String &e) {
    std::cerr << e.constData() << std::endl;
  }
}

