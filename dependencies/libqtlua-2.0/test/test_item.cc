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

#include "test.hh"

#include <QtLua/State>
#include <QtLua/Value>
#include <QtLua/UserItem>
#include <QtLua/UserListItem>

using namespace QtLua;

int main()
{
  try {

  {
    QtLua::State ls;

    ls.openlib(QtLuaLib);

    UserListItem::ptr li = QTLUA_REFNEW(UserListItem, );

    QTLUA_REFNEW(UserItem, "A")->insert(li);
    QTLUA_REFNEW(UserItem, "B")->insert(li);
    QTLUA_REFNEW(UserItem, "C")->insert(li);

    //ls.set_global("l", Value(ls, li));
    ls["l"] = li;

    ASSERT(ls.exec_statements("i=0; r={}; for key, value in each(l) do r[key]=value; i=i+1 end; return i").at(0).to_integer() == 3);

    for (const char *s = "A\0B\0C\0\0"; *s; s += 2)
      ASSERT(ls.at("r").at(s).to_userdata_cast<UserItem>()->get_name() == s);
  }

  } catch (String &e) {
    std::cout << e.constData() << std::endl;
    ASSERT(0);
  }

  return 0;
}

