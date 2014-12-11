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
class Test : public QtLua::UserData
{
  QTLUA_USEROBJECT(Test);

  QtLua::UserObject<Test> _uo;
  int _value;

  QtLua::Value meta_index(QtLua::State *ls, const QtLua::Value &key)
  {
    return _uo.meta_index(ls, key);
  }

  bool meta_contains(QtLua::State *ls, const QtLua::Value &key)
  {
    return _uo.meta_contains(ls, key); 
  }

  void meta_newindex(QtLua::State *ls, const QtLua::Value &key, const QtLua::Value &value)
  {
    return _uo.meta_newindex(ls, key, value);
  }

  QtLua::Ref<QtLua::Iterator> new_iterator(QtLua::State *ls)
  {
    return _uo.new_iterator(ls);
  }

  bool support(QtLua::Value::Operation c) const
  {
    return _uo.support(c) || QtLua::UserData::support(c);
  }

  QtLua::Value lua_get_value(QtLua::State *ls)
  {
    return QtLua::Value(ls, _value);
  }

  void lua_set_value(QtLua::State *ls, const QtLua::Value &value)
  {
    _value = value;
  }

public:
  Test(int value)
    : _uo(this),	// pass pointer to the object which holds properties
      _value(value)
  {
    _uo.ref_delegate(this);
  }

};

QTLUA_PROPERTIES_TABLE(Test,
  QTLUA_PROPERTY_ENTRY_U(Test, "value", lua_get_value, lua_set_value)
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
