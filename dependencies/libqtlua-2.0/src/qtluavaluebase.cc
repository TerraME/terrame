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

#include <cstdlib>
#include <cassert>

#include <QDebug>
#include <QMetaMethod>

#include <QtLua/Value>
#include <QtLua/ValueRef>
#include <QtLua/UserData>
#include <QtLua/String>
#include <QtLua/State>

#include <internal/QObjectWrapper>
#include <internal/TableIterator>
#include <internal/QMetaValue>

extern "C" {
#include <lua.h>
#if LUA_VERSION_NUM < 501
# include <lauxlib.h>
#endif
}

namespace QtLua {

#if LUA_VERSION_NUM < 502
double ValueBase::_id_counter = 0;
#else
double ValueBase::_id_counter = LUA_RIDX_LAST + 1;
#endif

void ValueBase::check_state() const
{
  if (!_st)
    QTLUA_THROW(QtLua::ValueBase, "The associated State object has been destroyed.");
}

bool ValueBase::connect(QObject *obj, const char *signal)
{
  check_state();
  try {
    QObjectWrapper::ptr qow = QObjectWrapper::get_wrapper(_st, obj);
    QByteArray ns(QMetaObject::normalizedSignature(signal));
    const QMetaObject *mo = obj->metaObject();
    int sigid = mo->indexOfMethod(ns.constData());

    if (sigid < 0 || mo->method(sigid).methodType() != QMetaMethod::Signal)
      return false;

    qow->_lua_connect(sigid, *this);

  } catch (const String &e) {
    return false;
  }
  return true;
}

bool ValueBase::disconnect(QObject *obj, const char *signal)
{
  check_state();
  QObjectWrapper::ptr qow = QObjectWrapper::get_wrapper(_st, obj);
  QByteArray ns(QMetaObject::normalizedSignature(signal));
  const QMetaObject *mo = obj->metaObject();
  int sigid = mo->indexOfMethod(ns.constData());

  if (sigid < 0 || mo->method(sigid).methodType() != QMetaMethod::Signal)
    return false;

  return qow->_lua_disconnect(sigid, *this);
}

Value::List ValueBase::call(const List &args) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  int t = lua_type(lst, -1);

  switch (t)
    {
    case TFunction: {
      int oldtop = lua_gettop(lst);

      try {
	if (!lua_checkstack(lst, args.size()))
	  QTLUA_THROW(QtLua::ValueBase, "Unable to extend the lua stack to handle % arguments.",
		      .arg(args.size()));

	foreach(const Value &v, args)
	  v.push_value(lst);
      } catch (...) {
	lua_settop(lst, oldtop - 1);
	throw;
      }

      if (lua_pcall(lst, args.size(), LUA_MULTRET, 0))
	{
	  String err(lua_tostring(lst, -1));
	  lua_pop(lst, 1);
	  throw err;
	}

      Value::List res;

      for (int i = oldtop; i <= lua_gettop(lst); i++)
	res += Value(i, _st);

      lua_settop(lst, oldtop - 1);
      return res;
    }

    case TUserData: {
      UserData::ptr ud = UserData::pop_ud(lst);

      if (!ud.valid())
	QTLUA_THROW(QtLua::ValueBase, "Can not call a null `QtLua::UserData' value.");

      return ud->meta_call(_st, args);
    }

    case TThread: {
      lua_State *th = lua_tothread(lst, -1);
      lua_pop(lst, 1);

      if (!lua_checkstack(th, args.size()))
	QTLUA_THROW(QtLua::ValueBase, "Unable to extend the coroutine stack to handle % arguments", .arg(args.size()));

#if LUA_VERSION_NUM >= 501
      if ((lua_status(th) != 0 || lua_gettop(th) == 0) && (lua_status(th) != LUA_YIELD))
	QTLUA_THROW(QtLua::ValueBase, "Can not resume a dead coroutine.");
#endif

      int oldtop_th = lua_gettop(th);

      try {
	foreach(const Value &v, args)
	  v.push_value(th);

	_st->_lst = th; // switch current thread State pointer
#if LUA_VERSION_NUM < 502
	int r = lua_resume(th, args.size());
#else
	int r = lua_resume(th, _st->_lst, args.size());
#endif
	_st->_lst = lst;

	switch (r)
	  {
#if LUA_VERSION_NUM >= 501
	  case LUA_YIELD: 
#endif
	  case 0: {
	    Value::List res;
	    int oldtop = lua_gettop(lst);
	    lua_xmove(th, lst, lua_gettop(th));
	    for (int i = oldtop + 1; i <= lua_gettop(lst); i++)
	      res += Value(i, _st);
	    lua_settop(lst, oldtop);

	    return res;
	  }

	  default: { /* error */
	    String err(lua_tostring(th, -1));
	    throw err;
	  }
	  }
      } catch (...) {
	lua_settop(th, oldtop_th);
	throw;
      }

    }

    default:
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can not call a `lua::%' value.", .arg(lua_typename(lst, t)));
    }
}

bool ValueBase::is_dead() const
{
#if LUA_VERSION_NUM < 501
  return false;
#else
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  if (lua_type(lst, -1) != TThread)
    {
      lua_pop(lst, 1);
      return false;
    }

  lua_State *th = lua_tothread(lst, -1);
  lua_pop(lst, 1);

  return ((lua_status(th) != 0 || lua_gettop(th) == 0) && (lua_status(th) != LUA_YIELD));
#endif
}

Value ValueBase::at(const Value &key) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  int t = lua_type(lst, -1);

  switch (t)
    {
    case TUserData: {
      UserData::ptr ud = UserData::pop_ud(lst);

      if (!ud.valid())
	QTLUA_THROW(QtLua::ValueBase, "Can not index a null `QtLua::UserData' value.");

      return ud->meta_index(_st, key);
    }

    case TTable: {
      try {
	key.push_value(lst);
      } catch (...) {
	lua_pop(lst, 1);
	throw;
      }

      try {
	State::lua_pgettable(lst, -2);
      } catch (...) {
	lua_pop(lst, 2);
	throw;
      }

      Value res(-1, _st);
      lua_pop(lst, 2);
      return res;
    }

    default:
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can not index a `lua::%' value.", .arg(lua_typename(lst, t)));
    }
}

bool ValueBase::is_empty() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  int t = lua_type(lst, -1);

  switch (t)
    {
    case TTable: {
      try {
	lua_pushnil(lst);
	if (State::lua_pnext(lst, -2))
	  {
	    lua_pop(lst, 3);
	    return false;
	  }
	lua_pop(lst, 1);
	return true;
      } catch (...) {
	lua_pop(lst, 2);
	throw;
      }
    }

    case TUserData: {
      UserData::ptr ptr = UserData::pop_ud(lst);
      return ptr->meta_operation(_st, ValueBase::OpLen, *this, *this).to_integer() == 0;
    }

    default:
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can not test emptiness of a `lua::%' value.", .arg(lua_typename(lst, t)));
    }
}

void ValueBase::table_shift(int pos, int count, const Value &init, int len)
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  if (lua_type(lst, -1) != LUA_TTABLE)
    {
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can only shift values inside a `lua::table' value.");
    }

  int i;
  if (len < 0)
#if LUA_VERSION_NUM < 501
    len = luaL_getn(lst, -1);
#elif LUA_VERSION_NUM < 502
    len = lua_objlen(lst, -1);
#else
    len = lua_rawlen(lst, -1);
#endif

  if (count > 0)
    {
      try {
	init.push_value(lst);
      } catch (...) {
	lua_pop(lst, 1);
	throw;
      }

      // insert
      for (i = len; i >= pos; i--)
	{
	  lua_rawgeti(lst, -2, i);
	  lua_rawseti(lst, -3, i + count);
	}
      for (i = std::min(pos, len + 1); i < pos + count; i++)
	{
	  lua_pushvalue(lst, -1);
	  lua_rawseti(lst, -3, i);
	}

      lua_pop(lst, 1);
    }
  else if (count < 0)
    {
      // remove
      if (count > len - pos)
	count = len - pos;
      for (i = pos; i <= len - count; i++)
	{
	  lua_rawgeti(lst, -1, i - count);
	  lua_rawseti(lst, -2, i);
	  if (i >= len + count)
	    {
	      lua_pushnil(lst);
	      lua_rawseti(lst, -2, i - count);
	    }
	}
    }

  lua_pop(lst, 1);
}

Ref<Iterator> ValueBase::new_iterator() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  switch (int t = lua_type(lst, -1))
    {
    case TUserData: {
      UserData::ptr ud = UserData::pop_ud(lst);

      if (!ud.valid())
	QTLUA_THROW(QtLua::ValueBase, "Can not iterate on a null `QtLua::UserData' value.");

      return ud->new_iterator(_st);
    }

    case TTable: {
      try {
	Iterator::ptr it = QTLUA_REFNEW(TableIterator, _st, -1);
	lua_pop(lst, 1);
	return it;
      } catch (...) {
	lua_pop(lst, 1);
	throw;
      }
    }

    default:
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can not iterate on a `lua::%' value.", .arg(lua_typename(lst, t)));
    }
}

ValueBase::Bool ValueBase::to_boolean() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);
  Bool res = (Bool)lua_toboolean(lst, -1);
  lua_pop(lst, 1);
  return res;
}

ValueBase::ValueType ValueBase::type() const
{
  if (!_st)
    return TNil;

  lua_State *lst = _st->_lst;
  push_value(lst);
  int res = lua_type(lst, -1);
  lua_pop(lst, 1);
  return (ValueBase::ValueType)res;
}

String ValueBase::type_name() const
{
  return String("lua::") + lua_typename(NULL, type());
}

String ValueBase::type_name(enum ValueBase::ValueType v)
{
  return String("lua::") + lua_typename(NULL, v);
}

String ValueBase::type_name_u() const
{
  if (!_st)
    return "lua::nil";

  String res;
  lua_State *lst = _st->_lst;
  push_value(lst);
  int t = lua_type(lst, -1);

  if (t == TUserData)
    {
      try {
	UserData::ptr ud = UserData::get_ud(lst, -1);
	if (ud.valid())
	  res = ud->get_type_name();
      } catch (const String &e) {
      }
    }

  if (res.isNull())
    res = String("lua::") + lua_typename(lst, t); 

  lua_pop(lst, 1);
  return res;
}

void ValueBase::convert_error(ValueType type) const
{
  lua_State *lst = _st->_lst;

  int type_b = lua_type(lst, -1);

  lua_pop(lst, 1);

  QTLUA_THROW(QtLua::ValueBase, "Can not convert a `lua::%' value to a `lua::%' value.",
	      .arg(lua_typename(lst, type_b)).arg(lua_typename(lst, (int)type)));
}

lua_Number ValueBase::to_number() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  switch (lua_type(lst, -1))
    {
    case LUA_TBOOLEAN:
    case LUA_TNUMBER: {
      lua_Number res = lua_tonumber(lst, -1);
      lua_pop(lst, 1);
      return res;
    }

    case LUA_TSTRING: {
      char *end;
      lua_Number res = strtod(lua_tostring(lst, -1), &end);
      lua_pop(lst, 1);

      if (!*end)
	return res;
    }

    }

  convert_error(TNumber);
  std::abort();
}

String ValueBase::to_string() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  const char	*str = lua_tostring(lst, -1);

  if (str)
    {
#if LUA_VERSION_NUM < 501
      String res(lua_tostring(lst, -1), lua_strlen(lst, -1));
#else
      size_t len;
      const char *s = lua_tolstring(lst, -1, &len);
      String res(s, len);
#endif
      lua_pop(lst, 1);
      return res;
    }

  convert_error(TString);
  std::abort();
}

String ValueBase::to_string_p(bool quote_string) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  String res(to_string_p(lst, -1, quote_string));
  lua_pop(lst, 1);
  return res;
}

String ValueBase::to_string_p(lua_State *st, int index, bool quote_string)
{
  switch (lua_type(st, index))
    {
    case TNone:
      return "(none)";

    case TNil:
      return "(nil)";

    case TBool: {
      String res(lua_toboolean(st, index) ? "true" : "false");
      return res;
    }

    case TNumber: {
      String res;
      res.setNum(lua_tonumber(st, index));
      return res;
    }

    case TString:
      if (quote_string)
	return String("\"") + lua_tostring(st, index) + "\"";
      else
	return String(lua_tostring(st, index));

    case TUserData: {
      try {
	UserData::ptr ud = UserData::get_ud(st, index);
	String res(ud.valid() ? ud->get_value_str() : ud->UserData::get_value_str());
	return res;
      } catch (const String &e) {
	// goto default
      }
    }

    default: {
      String res;
      res.setNum((qulonglong)lua_topointer(st, index), 16);
      return String("(%:%)").arg(lua_typename(NULL, lua_type(st, index))).arg(res);
    }

    }
}

UserData::ptr ValueBase::to_userdata() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  switch (lua_type(lst, -1))
    {
    case LUA_TUSERDATA:
      return UserData::pop_ud(lst);

    case LUA_TNIL:
      lua_pop(lst, 1);
      break;

    default:
      convert_error(TUserData);
    }

  return UserData::ptr();
}

QObject *ValueBase::to_qobject() const
{
  QObjectWrapper::ptr ow = to_userdata_cast<QObjectWrapper>();

  if (!ow.valid())
    QTLUA_THROW(QtLua::ValueBase, "Can not convert a `%' lua value to a QObject.", .arg(type_name()));

  return &ow->get_object();
}

QVariant ValueBase::to_qvariant() const
{
  switch (type())
    {
    case TNone:
    case TNil:
      return QVariant();
    case TBool:
      return QVariant(to_boolean());
    case TNumber:
      return QVariant(to_number());
    case TString:
      return QVariant(to_string());

    default:
      QTLUA_THROW(QtLua::ValueBase, "Can not convert a `%' lua value to a QVariant.", .arg(type_name()));
    }
}

QVariant ValueBase::to_qvariant(int qt_type) const
{
  return QMetaValue(qt_type, *this).to_qvariant();
}

static int lua_writer(lua_State *L, const void* p, size_t sz, void* pv)
{
  QByteArray *ba = (QByteArray*)pv;
  ba->append((const char*)p, (int)sz);
  return 0;
}

QByteArray ValueBase::to_bytecode() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  if (lua_type(lst, -1) == LUA_TFUNCTION)
    {
      QByteArray bytecode;
      int status = lua_dump(lst, &lua_writer, &bytecode);	
      lua_pop(lst, 1);
      if (status)
	QTLUA_THROW(QtLua::ValueBase, "Unable to dump function bytecode (status=%)", .arg(status));
      return bytecode;
    }

  convert_error(TUserData);
  std::abort();
}

int ValueBase::len() const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);
  size_t res;

  int t = lua_type(lst, -1);

  switch (t)
    {
#if LUA_VERSION_NUM < 501
    case TString:
      res = lua_strlen(lst, -1);
      lua_pop(lst, 1);
      return res;

    case TTable:
      res = luaL_getn(lst, -1);
      lua_pop(lst, 1);
      return res;
#else
    case TString:
    case TTable:
# if LUA_VERSION_NUM < 502
      res = lua_objlen(lst, -1);
# else
      res = lua_rawlen(lst, -1);
# endif
#endif
      lua_pop(lst, 1);
      return res;

    case TUserData: {
      UserData::ptr ptr = UserData::pop_ud(lst);
      return ptr->meta_operation(_st, ValueBase::OpLen, *this, *this).to_integer();
    }

    default:
      lua_pop(lst, 1);
      QTLUA_THROW(QtLua::ValueBase, "Can not evaluate length of a `lua::%' value.", .arg(lua_typename(lst, t)));
    }

}

bool ValueBase::support(Operation c) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);
  bool res = false;

  switch (lua_type(lst, -1))
    {
    case TNone:
    case TNil:
      res = false;
      break;

    case TBool:
      switch (c)
	{
	case ValueBase::OpEq:
	  res = true;
	  break;
	default:
	  res = false;
	  break;
	}
      break;

    case TNumber:
      switch (c)
	{
	case ValueBase::OpAdd:
	case ValueBase::OpSub:
	case ValueBase::OpMul:
	case ValueBase::OpDiv:
	case ValueBase::OpMod:
	case ValueBase::OpPow:
	case ValueBase::OpUnm:
	case ValueBase::OpEq:
	case ValueBase::OpLt:
	case ValueBase::OpLe:
	  res = true;
	  break;
	default:
	  res = false;
	  break;
	}
      break;

    case TString:
      switch (c)
	{
	case ValueBase::OpLen:
	case ValueBase::OpConcat:
	case ValueBase::OpEq:
	case ValueBase::OpLt:
	case ValueBase::OpLe:
	  res = true;
	  break;
	default:
	  res = false;
	  break;
	}
      break;

    case TTable:
      switch (c)
	{
	case ValueBase::OpEq:
	case ValueBase::OpLen:
	case ValueBase::OpIterate:
	case ValueBase::OpIndex:
	case ValueBase::OpNewindex:
	  res = true;
	  break;
	default:
	  res = false;
	  break;
	}
      break;

    case TFunction:
      switch (c)
	{
	case ValueBase::OpEq:
	case ValueBase::OpCall:
	  res = true;
	  break;
	default:
	  res = false;
	  break;
	}
      break;

    case TUserData:
      try {
	UserData::ptr ptr = UserData::get_ud(lst, -1);
	res = ptr->support(c);
      } catch (const String &s) {
	res = false;
      }
      break;
    }

  lua_pop(lst, 1);
  return res;
}

bool ValueBase::operator==(const Value &lv) const
{
  if (!_st || lv._st != _st)
    return false;

  lua_State *lst = _st->_lst;
  try {
    lv.push_value(lst);
    try {
      push_value(lst);
    } catch (...) {
      lua_pop(lst, 1);
      return false;
    }
  } catch (...) {
    return false;
  }

  bool res;

  if (lua_type(lst, -1) != lua_type(lst, -2))
    {
      res = false;
    }
  else if (lua_type(lst, -1) == TUserData)
    {
      try {
	UserData::ptr a = UserData::get_ud(lst, -1);
	UserData::ptr b = UserData::get_ud(lst, -2);

	res = a.ptr() == b.ptr();
      } catch (const String &e) {
	res = lua_rawequal(lst, -1, -2);
      }
    }
  else
    {
      res = lua_rawequal(lst, -1, -2);
    }

  lua_pop(lst, 2);
  return res;
}

bool ValueBase::operator<(const Value &lv) const
{
  if (!_st || lv._st != _st)
    return _st < lv._st;

  lua_State *lst = _st->_lst;
  try {
    lv.push_value(lst);
    try {
      push_value(lst);
    } catch (...) {
      lua_pop(lst, 1);
      return false;
    }
  } catch (...) {
    return false;
  }

  bool res = false;
  int t1 = lua_type(lst, -1);
  int t2 = lua_type(lst, -2);

  if (t1 < t2)
    res = true;
  else if (t1 > t2)
    res = false;
  else
    switch (t1)
      {
      case TUserData:
#ifndef QTLUA_NO_USERDATA_CHECK
	try {
#endif
	  UserData::ptr a = UserData::get_ud(lst, -1);
	  UserData::ptr b = UserData::get_ud(lst, -2);

	  res = a.ptr() < b.ptr();
	  break;
#ifndef QTLUA_NO_USERDATA_CHECK
	} catch (const String &e) {
	}
#endif
      case LUA_TLIGHTUSERDATA:
      case TFunction:
      case TThread:
      case TTable:
	res = lua_topointer(lst, -1) < lua_topointer(lst, -2);
	break;

      case TNone:
      case TNil:
	res = false;
	break;

      case TBool:
      case TNumber:
      case TString:
#if LUA_VERSION_NUM < 502
	res = lua_lessthan(lst, -1, -2);
#else
	res = lua_compare(lst, -1, -2, LUA_OPLT);
#endif
	break;
      }

  lua_pop(lst, 2);
  return res;
}

bool ValueBase::operator==(const String &str) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  bool res = false;

  if (lua_isstring(lst, -1))
    {
#if LUA_VERSION_NUM < 501
      String s(lua_tostring(lst, -1), lua_strlen(lst, -1));
#else
      size_t len;
      const char *cs = lua_tolstring(lst, -1, &len);
      String s(cs, len);
#endif
      res = (str == s);
    }

  lua_pop(lst, 1);

  return res;
}

bool ValueBase::operator==(const char *str) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  bool res = false;

  if (lua_isstring(lst, -1))
    res = !strcmp(lua_tostring(lst, -1), str);

  lua_pop(lst, 1);

  return res;
}

bool ValueBase::operator==(double n) const
{
  check_state();
  lua_State *lst = _st->_lst;
  push_value(lst);

  bool res = false;

  if (lua_isnumber(lst, -1))
    res = lua_tonumber(lst, -1) == n;

  lua_pop(lst, 1);

  return res;
}

uint ValueBase::qHash(lua_State *lst, int index)
{
  switch (lua_type(lst, index))
    {
    case LUA_TBOOLEAN:
      return lua_toboolean(lst, index);

    case LUA_TNUMBER: {
      union {
	lua_Number n;
	uint u;
      };
      n = lua_tonumber(lst, index);
      return u;
    }

    case LUA_TSTRING: {
#if LUA_VERSION_NUM < 501
      String s(lua_tostring(lst, -1), lua_strlen(lst, -1));
#else
      size_t len;
      const char *cs = lua_tolstring(lst, -1, &len);
      String s(cs, len);
#endif
      return ::qHash(s);
    }

    case LUA_TUSERDATA: {
      try {
	QtLua::Ref<UserData> ud = UserData::get_ud(lst, index);
	return (uint)(long)ud.ptr();
      } catch (...) {
	return (uint)(long)lua_touserdata(lst, index);
      }
      break;
    }

    default:
      return (uint)(long)lua_topointer(lst, index);
    }
}

QDebug operator<<(QDebug dbg, const ValueBase &c)
{
  dbg.nospace() << "(" << c.type_name_u() << ", " << c.to_string_p() << ")";

  return dbg.space();
}

}

