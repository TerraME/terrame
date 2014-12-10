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

#include <cassert>

#include <QtLua/Value>
#include <QtLua/State>
#include <QtLua/Iterator>

#include <internal/TableIterator>

extern "C" {
#include <lua.h>
}

namespace QtLua {
  
TableIterator::TableIterator(State *st, int index)
  : _st(st),
    _key(Value(st)),
    _value(Value(st)),
    _more(true)
{
  lua_State *lst = _st->_lst;
  lua_pushlightuserdata(lst, this);
  if (index < 0
#if LUA_VERSION_NUM < 502
      && index != LUA_GLOBALSINDEX
#endif
      )
    index--;
  lua_pushvalue(lst, index);
  assert(lua_type(lst, -1) == Value::TTable);
  lua_rawset(lst, LUA_REGISTRYINDEX);

  fetch();
}

TableIterator::~TableIterator()
{
  if (_st)
    {
      lua_pushlightuserdata(_st->_lst, this);
      lua_pushnil(_st->_lst);
      lua_rawset(_st->_lst, LUA_REGISTRYINDEX);
    }
}

bool TableIterator::more() const
{
  return _st && _more;
}

void TableIterator::next()
{
  fetch();
}

void TableIterator::fetch()
{
  if (!_st)
    return;

  assert(_more);

  lua_State *lst = _st->_lst;
  lua_pushlightuserdata(lst, this);
  lua_rawget(lst, LUA_REGISTRYINDEX);

  try {
    _key.push_value(lst);
  } catch (...) {
    lua_pop(lst, 1);
    throw;
  }

  try {
    if (State::lua_pnext(lst, -2))
      {
	_key = Value(-2, _st);
	_value = Value(-1, _st);
	lua_pop(lst, 2);
      }
    else
      {
	_more = false;
      }
  } catch (...) {
    lua_pop(lst, 2);
    throw;
  }

  lua_pop(lst, 1);
}

Value TableIterator::get_key() const
{
  return _key;
}

Value TableIterator::get_value() const
{
  return _value;
}

ValueRef TableIterator::get_value_ref()
{
  if (!_st)
    QTLUA_THROW(QtLua::TableIterator, "State object has been destoyed.");

  lua_pushlightuserdata(_st->_lst, this);
  lua_rawget(_st->_lst, LUA_REGISTRYINDEX);
  Value val(1, _st);
  ValueRef ref(val, _key);
  lua_pop(_st->_lst, 1);
  return ref;
}

}

