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

#include <QtLua/UserObject>

								/* anchor 1 */
class Test : public QtLua::UserObject<Test>
{
  QTLUA_USEROBJECT(Test);

  QTLUA_PROPERTY(int, _value);

public:
  Test(int value)
    : _value(value)
  {
  }

};

QTLUA_PROPERTIES_TABLE(Test,
  QTLUA_PROPERTY_ENTRY(Test, "value", _value)
);
/* anchor end */

#include <QtLua/State>
#include <QtLua/Function>

int main()
{
  try {

    QtLua::State state;
    state.openlib(QtLua::QtLuaLib);
    state.enable_qdebug_print(true);

    state["foo"] = QTLUA_REFNEW(Test, 21);
    state["bar"] = QTLUA_REFNEW(Test, 42);

    state.exec_statements("for key, value in each(foo) do print(key, value) end");
  } catch (QtLua::String &e) {
    std::cerr << e.constData() << std::endl;
  }


  return 0;
}
