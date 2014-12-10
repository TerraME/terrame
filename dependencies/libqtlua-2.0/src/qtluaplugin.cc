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

    Copyright (C) 2008, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/


#include <QtLua/Plugin>
#include <QtLua/String>

#include "config.hh"

#define STR(n) STR_(n)
#define STR_(n) #n

namespace QtLua {

Plugin::Plugin(const String &filename)
  : _loader(QTLUA_REFNEW(Loader, filename))
{
  set_container(&_map);
  api<PluginInterface>()->register_members(*this);
}

Plugin::~Plugin()
{
  for (plugin_map_t::const_iterator i = _map.begin(); i != _map.end(); i++)
    delete *i;
}

Plugin::Loader::Loader(const String &filename)
  : QPluginLoader(filename.to_qstring())
{
  if (!load())
    QTLUA_THROW(Plugin::Loader, "Error loading plugin `%': %",
		.arg(filename).arg(errorString()));
}

Plugin::Loader::~Loader()
{
  unload();
}

Value Plugin::to_table(State *ls) const
{
  return Value(ls, _map);
}

const String & Plugin::get_plugin_ext()
{
  static const String s(STR(SHLIBEXT));
  return s;
}

void Plugin::completion_patch(String &path, String &entry, int &offset)
{
  entry += ".";
}

}

