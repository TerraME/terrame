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


#include <cstdarg>

#ifdef __GNUC__
#include <cxxabi.h>
#endif

extern "C" {
#include <lua.h>
}

#include <QtLua/UserData>
#include <QtLua/Value>
#include <QtLua/State>
#include <QtLua/String>

namespace QtLua {

void UserData::push_ud(lua_State *st)
{
  // allocate lua user data to store reference to 'this'
  new (lua_newuserdata(st, sizeof (UserData::ptr))) UserData::ptr(*this);

  // attach metatable
  lua_pushlightuserdata(st, &State::_key_item_metatable);
  lua_rawget(st, LUA_REGISTRYINDEX);
  lua_setmetatable(st, -2);
}

template <bool pop>
inline QtLua::Ref<UserData> UserData::get_ud_(lua_State *st, int i)
{
#ifndef QTLUA_NO_USERDATA_CHECK
  if (lua_getmetatable(st, i))
    {
      lua_pushlightuserdata(st, &State::_key_item_metatable);
      lua_rawget(st, LUA_REGISTRYINDEX);

      if (lua_rawequal(st, -2, -1))
	{
	  lua_pop(st, 2);
#endif
	  UserData::ptr	*item = static_cast<UserData::ptr *>(lua_touserdata(st, i));

	  if (pop)
	    lua_pop(st, 1);

	  return *item;
#ifndef QTLUA_NO_USERDATA_CHECK
	}

      lua_pop(st, 1);
    }

  lua_pop(st, 1);

  if (pop)
    lua_pop(st, 1);

  QTLUA_THROW(QtLua::UserData, "The `lua::userdata' value is not a `QtLua::UserData'.");
#endif
}

QtLua::Ref<UserData> UserData::get_ud(lua_State *st, int i)
{
  return get_ud_<false>(st, i);
}

QtLua::Ref<UserData> UserData::pop_ud(lua_State *st)
{
  return get_ud_<true>(st, -1);
}

String UserData::get_type_name() const
{
#ifdef __GNUC__
  int s;
  return abi::__cxa_demangle(typeid(*this).name(), 0, 0, &s);
#else
  return typeid(*this).name();
#endif
}

String UserData::get_value_str() const
{
  return QString().sprintf("%p", this);
}

Value UserData::meta_operation(State *ls, Value::Operation op,
			       const Value &a, const Value &b) 
{
  QTLUA_THROW(QtLua::UserData, "The operation `%' is not handled by the `%' class.",
	      .arg((int)op).arg(get_type_name()));
};

void UserData::meta_newindex(State *ls, const Value &key, const Value &value) 
{
  QTLUA_THROW(QtLua::UserData, "The table newindex operation not is handled by the `%' class.",
	      .arg(get_type_name()));
};

Value UserData::meta_index(State *ls, const Value &key) 
{
  QTLUA_THROW(QtLua::UserData, "The table index operation is not handled by the `%' class.",
	      .arg(get_type_name()));
};

bool UserData::meta_contains(State *ls, const Value &key)
{
  try {
    return !meta_index(ls, key).is_nil();
  } catch (String &e) {
    return false;
  }
}

Value::List UserData::meta_call(State *ls, const Value::List &args) 
{
  QTLUA_THROW(QtLua::UserData, "The call operation is not handled by the `%' class.",
	      .arg(get_type_name()));
};

Ref<Iterator> UserData::new_iterator(State *ls)
{
  QTLUA_THROW(QtLua::UserData, "Table iteration is not handled by the `%' class",
	      .arg(get_type_name()));
}

bool UserData::support(Value::Operation c) const
{
  return false;
}

void UserData::meta_call_check_args(const Value::List &args,
				    int min_count, int max_count, ...) 
{
  int i;
  va_list ap;
  bool lua_vaarg = max_count < 0;

  if (lua_vaarg)
    max_count = -max_count;

  if (args.count() < min_count)
    switch (min_count)
      {
      case 1:
	QTLUA_THROW(QtLua::UserData, "Missing call argument, at least 1 argument is expected.",
		    .arg(min_count));
      default:
	QTLUA_THROW(QtLua::UserData, "Missing call arguments, at least % arguments are expected.",
		    .arg(min_count));
      }

  if (!lua_vaarg && max_count && args.count() > max_count)
    switch (max_count)
      {
      case 1:
	QTLUA_THROW(QtLua::UserData, "Too many call arguments, a single argument is allowed.",
		    .arg(max_count));
      default:
	QTLUA_THROW(QtLua::UserData, "Too many call arguments, at most % arguments are allowed.",
		    .arg(max_count));
      }

  va_start(ap, max_count);

  Value::ValueType	type = Value::TNone;

  for (i = 0; i < args.size(); i++)
    {
      if (i < min_count || i < max_count)
	type = (Value::ValueType)va_arg(ap, int);

      if (type != Value::TNone && type != args[i].type())
	{
	  va_end(ap);
	  QTLUA_THROW(QtLua::UserData, "Bad value type for call argument %, `lua::%' expected instead of `%'.",
		      .arg(i+1).arg(lua_typename(0, type)).arg(args[i].type_name()));
	}
    }

  va_end(ap);
}

bool UserData::operator==(const UserData &ud)
{
  return this == &ud;
}

bool UserData::operator<(const UserData &ud)
{
  return this < &ud;
}

void UserData::completion_patch(String &path, String &entry, int &offset)
{
}

Value UserData::yield(State *ls) const
{
  lua_State *lst = ls->_lst;

  if (ls->_mst == lst)
    return Value(ls);
  ls->_yield_on_return = true;
#if LUA_VERSION_NUM < 501
  // get thread from a weak metatable, substitute for lua_pushthread
  lua_pushlightuserdata(lst, &State::_key_threads);
  lua_rawget(lst, LUA_REGISTRYINDEX);
  lua_pushlightuserdata(lst, lst);
  lua_rawget(lst, -2);
  lua_remove(lst, -2);
  if (lua_isnil(lst, -1))
    {
      lua_pop(lst, 1);
      lua_pushboolean(lst, 1);
    }
#else
  int r = lua_pushthread(lst);
  assert(r != 1);
#endif
  Value res(-1, ls);
  lua_pop(lst, 1);
  return res;
}

}

