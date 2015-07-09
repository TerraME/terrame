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

    Fork
    Copyright (C) 2015 (Li, Kwue-Ron) <likwueron@gmail.com>
*/

#include "config.hh"

#include <cstdlib>

#include <QStringList>
#include <QDebug>

#include <QtLua/State>
#include <QtLua/UserData>
#include <QtLua/Value>
#include <QtLua/ValueRef>
#include <QtLua/Iterator>
#include <QtLua/String>
#include <QtLua/Function>
#include <QtLua/Console>
#include <internal/QObjectWrapper>

#include "qtluaqtlib.hh"

extern "C" {
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
}

namespace QtLua {

char State::_key_threads;
char State::_key_item_metatable;
char State::_key_this;

  /* save current thread lua_State and set new lua_State */
#define QTLUA_SWITCH_THREAD(this_, st)	     \
    lua_State *prev_th = this_->_lst; \
    this_->_lst = st;

  /* restore old thread State */
#define QTLUA_RESTORE_THREAD(this_)     \
    this_->_lst = prev_th;

/************************************************************************
	lua c functions
************************************************************************/

int State::lua_cmd_iterator(lua_State *st)
{
  State		*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {
    Iterator::ptr	i = Value(1, this_).to_userdata_cast<Iterator>();

    if (i->more())
      {
	i->get_key().push_value(st);
	i->get_value().push_value(st);
	i->next();
	QTLUA_RESTORE_THREAD(this_);
	return 2;
      }
    else
      {
	lua_pushnil(st);
	QTLUA_RESTORE_THREAD(this_);
	return 1;
      }

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  std::abort();
}

int State::lua_cmd_each(lua_State *st)
{
  State               *this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  int idx = 1;

  try {
    Value		table;

    if (lua_gettop(st) < 1)
      table = Value::new_global_env(this_);
    else
      table = Value(idx, this_);

    Iterator::ptr	i = table.new_iterator();

    lua_pushcfunction(st, lua_cmd_iterator);
    i->push_ud(st);
    lua_pushnil(st);

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  return 3;
}

int State::lua_cmd_print(lua_State *st)
{
  State *this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {
    for (int i = 1; i <= lua_gettop(st); i++)
      {
	String s = Value::to_string_p(st, i, true);
	if (this_->_debug_output)
	  qDebug() << s; //"QtLua print:%s", s.constData());
	this_->output_str(s + "\n");
      }

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  return 0;
}

int State::lua_cmd_plugin(lua_State *st)
{
  State	*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {

    if (lua_gettop(st) < 1 || !lua_isstring(st, 1))
      {
	this_->output_str("Usage: plugin(\"library_filename_without_ext\")\n");
	QTLUA_RESTORE_THREAD(this_);
	return 0;
      }

    QTLUA_REFNEW(Plugin, String(lua_tostring(st, 1)) + Plugin::get_plugin_ext())->push_ud(st);
    QTLUA_RESTORE_THREAD(this_);
    return 1;

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  std::abort();
}

int State::lua_cmd_list(lua_State *st)
{
  State	*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {
    Value		table;

    if (lua_gettop(st) < 1)
      table = Value::new_global_env(this_);
    else
      table = Value(1, this_);

    for (Value::const_iterator i = table.begin(); i != table.end(); i++)
      {
	try {
	  this_->output_str(String("\033[18m") + i.value().type_name_u() + "\033[2m " +
			    i.key().to_string_p(false) + " = " + i.value().to_string_p(true) + "\n");
	} catch (String &e) {
	  this_->output_str(String("\033[18m[Error]\033[2m " +
				   i.key().to_string_p(false) + " = " + e + "\n"));
	}
      }

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  return 0;
}

int State::lua_cmd_help(lua_State *st)
{
  State *this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  if (lua_gettop(st) < 1)
    {
      this_->output_str("Usage: help(QtLua::Function object)\n");
      QTLUA_RESTORE_THREAD(this_);
      return 0;
    }

  Value v(1, this_);

  if (v.type() == Value::TUserData)
    {
      Function::ptr cmd = v.to_userdata().dynamiccast<Function>();

      if (cmd.valid())
	{
	  this_->output_str(cmd->get_help() + "\n");
	  QTLUA_RESTORE_THREAD(this_);
	  return 0;
	}
    }

  this_->output_str("Help is only available for QtLua::Function objects\n");

  QTLUA_RESTORE_THREAD(this_);
  return 0;
}

int State::lua_cmd_qtype(lua_State *st)
{
  State *this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  if (lua_gettop(st) < 1)
    {
      this_->output_str("Usage: qtype(value)\n");
      QTLUA_RESTORE_THREAD(this_);
      return 0;
    }

  Value v(1, this_);
  String type(v.type_name_u());
  lua_pushstring(st, type.constData());

  QTLUA_RESTORE_THREAD(this_);
  return 1;
}

// lua item metatable methods

#define LUA_META_2OP_FUNC(n, op)					\
									\
int State::lua_meta_item_##n(lua_State *st)				\
{									\
  int		x = lua_gettop(st);					\
  State		*this_ = get_this(st);					\
  QTLUA_SWITCH_THREAD(this_, st);					\
									\
  try {									\
    Value	a(1, this_);						\
    Value	b(2, this_);						\
									\
    if (a.type() == Value::TUserData)					\
      a.to_userdata()->meta_operation(this_, op, a, b).push_value(st);	\
    else if (b.type() == Value::TUserData)				\
      b.to_userdata()->meta_operation(this_, op, a, b).push_value(st);	\
    else								\
      std::abort();							\
									\
  } catch (String &e) {							\
    QTLUA_RESTORE_THREAD(this_);					\
    luaL_error(st, "%s", e.constData());				\
  }									\
									\
  QTLUA_RESTORE_THREAD(this_);						\
  return lua_gettop(st) - x;						\
}

#define LUA_META_1OP_FUNC(n, op)					\
									\
int State::lua_meta_item_##n(lua_State *st)				\
{									\
  int		x = lua_gettop(st);					\
  State		*this_ = get_this(st);					\
  QTLUA_SWITCH_THREAD(this_, st);					\
									\
  try {									\
    Value	a(1, this_);						\
									\
     a.to_userdata()->meta_operation(this_, op, a, a).push_value(st);	\
									\
  } catch (String &e) {							\
    QTLUA_RESTORE_THREAD(this_);					\
    luaL_error(st, "%s", e.constData());				\
  }									\
									\
  QTLUA_RESTORE_THREAD(this_);						\
  return lua_gettop(st) - x;						\
}

LUA_META_2OP_FUNC(add, Value::OpAdd)
LUA_META_2OP_FUNC(sub, Value::OpSub)
LUA_META_2OP_FUNC(mul, Value::OpMul)
LUA_META_2OP_FUNC(div, Value::OpDiv)
LUA_META_2OP_FUNC(mod, Value::OpMod)
LUA_META_2OP_FUNC(pow, Value::OpPow)
LUA_META_1OP_FUNC(unm, Value::OpUnm)
LUA_META_2OP_FUNC(concat, Value::OpConcat)
LUA_META_1OP_FUNC(len, Value::OpLen)
LUA_META_2OP_FUNC(eq, Value::OpEq)
LUA_META_2OP_FUNC(lt, Value::OpLt)
LUA_META_2OP_FUNC(le, Value::OpLe)

int State::lua_meta_item_index(lua_State *st)
{
  int		x = lua_gettop(st);
  State		*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {
    UserData::ptr ud = UserData::get_ud(st, 1);

    if (!ud.valid())
      QTLUA_THROW(QtLua::UserData, "Can not index a null `QtLua::UserData' value.");

    Value	op(2, this_);

    Value v = ud->meta_index(this_, op);
    v.push_value(st);

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  return lua_gettop(st) - x;
}

int State::lua_meta_item_newindex(lua_State *st)
{
  int		x = lua_gettop(st);
  State		*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  try {
    UserData::ptr ud = UserData::get_ud(st, 1);

    if (!ud.valid())
      QTLUA_THROW(QtLua::UserData, "Can not index a null `QtLua::UserData' value.");

    Value	op1(2, this_);
    Value	op2(3, this_);

    ud->meta_newindex(this_, op1, op2);

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  return lua_gettop(st) - x;
}

int State::lua_meta_item_call(lua_State *st)
{
  int		n = lua_gettop(st);
  State		*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);
  bool          yield = false;

  try {
    UserData::ptr ud = UserData::get_ud(st, 1);

    if (!ud.valid())
      QTLUA_THROW(QtLua::UserData, "Can not call a null `QtLua::UserData' value.");

    Value::List	args;

    for (int i = 2; i <= lua_gettop(st); i++)
      args.append(Value(i, this_));

    bool oy = this_->_yield_on_return;
    this_->_yield_on_return = false;
    args = ud->meta_call(this_, args);
    yield = this_->_yield_on_return;
    this_->_yield_on_return = oy;

    if (!lua_checkstack(st, args.size()))
      QTLUA_THROW(QtLua::State, "Unable to extend the lua stack to handle % return values",
		  .arg(args.size()));

    foreach(const Value &v, args)
      v.push_value(st);

  } catch (String &e) {
    QTLUA_RESTORE_THREAD(this_);
    luaL_error(st, "%s", e.constData());
  }

  QTLUA_RESTORE_THREAD(this_);
  int nresults = lua_gettop(st) - n;
  return yield ? lua_yield(st, nresults) : nresults;
}

int State::lua_meta_item_gc(lua_State *st)
{
  State		*this_ = get_this(st);
  QTLUA_SWITCH_THREAD(this_, st);

  UserData::get_ud(st, 1).~Ref<UserData>();

  QTLUA_RESTORE_THREAD(this_);
  return 0;
}

/************************************************************************/

static int lua_gettable_wrapper(lua_State *st)
{
  lua_gettable(st, 1);
  return 1;
}

void State::lua_pgettable(lua_State *st, int index)
{
  if (lua_type(st, index) == LUA_TTABLE)
    {
      if (!lua_getmetatable(st, index))
	return lua_rawget(st, index);
      lua_pop(st, 1);
    }

  lua_pushcfunction(st, lua_gettable_wrapper);
  if (index < 0
#if LUA_VERSION_NUM < 502
      && index != LUA_GLOBALSINDEX
#endif
      )
    index--;
  lua_pushvalue(st, index);  // table
  lua_pushvalue(st, -3);     // key
  if (lua_pcall(st, 2, 1, 0))
    {
      String err(lua_tostring(st, -1));
      lua_pop(st, 1);
      throw err;
    }
  lua_remove(st, -2);     // replace key by value
}

static int lua_settable_wrapper(lua_State *st)
{
  lua_settable(st, 1);
  return 0;
}

void State::lua_psettable(lua_State *st, int index)
{
  if (lua_type(st, index) == LUA_TTABLE)
    {
      if (!lua_getmetatable(st, index))
	return lua_rawset(st, index);
      lua_pop(st, 1);
    }

  lua_pushcfunction(st, lua_settable_wrapper);
  if (index < 0
#if LUA_VERSION_NUM < 502
      && index != LUA_GLOBALSINDEX
#endif
      )
    index--;
  lua_pushvalue(st, index);  // table
  lua_pushvalue(st, -4);     // key
  lua_pushvalue(st, -4);     // value
  if (lua_pcall(st, 3, 0, 0))
    {
      String err(lua_tostring(st, -1));
      lua_pop(st, 1);
      throw err;
    }
  lua_pop(st, 2);     // remove key/value
}

static int lua_next_wrapper(lua_State *st)
{
  return lua_next(st, 1) ? 2 : 0;
}

/** Protected lua_next, same behavior as lua_next. On error this
    function throw an exception and leave the lua stack untouched (the
    key is not poped). */
int State::lua_pnext(lua_State *st, int index)
{
  lua_pushcfunction(st, lua_next_wrapper);
  if (index < 0
#if LUA_VERSION_NUM < 502
      && index != LUA_GLOBALSINDEX
#endif
      )
    index--;
  lua_pushvalue(st, index);  // table
  lua_pushvalue(st, -3);     // key
  if (lua_pcall(st, 2, 2, 0))
    {
      String err(lua_tostring(st, -1));
      lua_pop(st, 1);
      throw err;
    }
  lua_remove(st, -3);	     // remove key
  if (lua_isnil(st, -2))
    {
      lua_pop(st, 2);
      return 0;
    }
  return 1;
}

/************************************************************************/

void State::set_global_r(const String &name, const Value &value, int tblidx)
{
  int len = name.indexOf('.', 0);

  if (len < 0)
    {
      // set value in table if last
      lua_pushstring(_lst, name.constData());

      try {
	value.push_value(_lst);
      } catch (...) {
	lua_pop(_lst, 1);
	throw;
      }

      try {
	lua_psettable(_lst, tblidx);
      } catch (...) {
	lua_pop(_lst, 2);
	throw;
      }
    }
  else
    {
      // find intermediate value in path
      String prefix(name.mid(0, len));

      lua_pushstring(_lst, prefix.constData());

      try {
	lua_pgettable(_lst, tblidx);
      } catch (...) {
	lua_pop(_lst, 1);
	throw;
      }

      if (lua_isnil(_lst, -1))
	{
	  // create intermediate table
	  lua_pop(_lst, 1);
	  lua_pushstring(_lst, prefix.constData());
	  lua_newtable(_lst);

	  try {
	    set_global_r(name.mid(len + 1), value, lua_gettop(_lst));
	    lua_psettable(_lst, tblidx);
	  } catch (...) {
	    lua_pop(_lst, 2);
	    throw;
	  }
	}
      else if (lua_istable(_lst, -1))
	{
	  // use existing intermediate table
	  try {
	    set_global_r(name.mid(len + 1), value, lua_gettop(_lst));
	    lua_pop(_lst, 1);
	  } catch (...) {
	    lua_pop(_lst, 1);
	    throw;
	  }
	}
      else
	{
	  // bad existing intermediate value
	  lua_pop(_lst, 1);
	  QTLUA_THROW(QtLua::State, "Can not set the global, the `%' key already exists.", .arg(name));
	}
    }
}

void State::set_global(const String &name, const Value &value)
{
#if LUA_VERSION_NUM < 502
  set_global_r(name, value, LUA_GLOBALSINDEX);
#else
  try {
    lua_pushglobaltable(_lst);
    set_global_r(name, value, lua_gettop(_lst));
    lua_pop(_lst, 1);
  } catch (...) {
    lua_pop(_lst, 1);
    throw;
  }
#endif
}

void State::get_global_r(const String &name, Value &value, int tblidx) const
{
  int len = name.indexOf('.', 0);

  if (len < 0)
    {
      // get value from table if last
      lua_pushstring(_lst, name.constData());

      try {
	lua_pgettable(_lst, tblidx);
      } catch (...) {
	lua_pop(_lst, 1);
	throw;
      }

      value = Value(-1, this);
      lua_pop(_lst, 1);
    }
  else
    {
      // find intermediate value in path
      String prefix(name.mid(0, len));

      lua_pushstring(_lst, prefix.constData());

      try {
	lua_pgettable(_lst, tblidx);
      } catch (...) {
	lua_pop(_lst, 1);
	throw;
      }

      if (!lua_istable(_lst, -1))
	{
	  lua_pop(_lst, 1);
	  QTLUA_THROW(QtLua::State, "Can not get the global, `%' is not a table.", .arg(prefix));
	}

      try {
	get_global_r(name.mid(len + 1), value, lua_gettop(_lst));
      } catch (...) {
	lua_pop(_lst, 1);
	throw;
      }

      lua_pop(_lst, 1);
    }
}

Value State::get_global(const String &path) const
{
  Value res(const_cast<State*>(this));

#if LUA_VERSION_NUM < 502
  get_global_r(path, res, LUA_GLOBALSINDEX);
#else
  try {
    lua_pushglobaltable(_lst);
    get_global_r(path, res, lua_gettop(_lst));
    lua_pop(_lst, 1);
  } catch (...) {
    lua_pop(_lst, 1);
    throw;
  }
#endif

  return res;
}

Value State::at(const Value &key) const
{
#if LUA_VERSION_NUM < 502
  key.push_value(_lst);
  try {
    lua_pgettable(_lst, LUA_GLOBALSINDEX);
  } catch (...) {
    lua_pop(_lst, 1);
    throw;
  }

  Value res(-1, this);
  lua_pop(_lst, 1);
#else

  try {
    lua_pushglobaltable(_lst);
    key.push_value(_lst);
  } catch (...) {
    lua_pop(_lst, 1);
    throw;
  }

  try {
    lua_pgettable(_lst, -2);
  } catch (...) {
    lua_pop(_lst, 2);
    throw;
  }

  Value res(-1, this);
  lua_pop(_lst, 2);
#endif

  return res;
}

ValueRef State::operator[] (const Value &key)
{
  return ValueRef(Value::new_global_env(this), key);
}

void State::check_empty_stack() const
{
  assert(!lua_gettop(_lst));
}

State::State()
  : _state_ownership(true)
{
#if LUA_VERSION_NUM < 501
  lua_State	*L = lua_open();
#else
  lua_State	*L = luaL_newstate();
#endif
  init(L);
}

State::State(lua_State	*L)
  : _state_ownership(false)
{
  init(L);
}

State::~State()
{
  // disconnect all Qt slots while associated Value objects are still valid
  foreach(QObjectWrapper *w, _whash)
    w->_lua_disconnect_all();

  // lua state close
  if(_state_ownership)
    lua_close(_mst);

  // wipe QObjectWrapper objects
  wrapper_hash_t::const_iterator i;

  while ((i = _whash.begin()) != _whash.end())
    i.value()->_drop();
}

Value State::eval_expr(bool use_lua, const String &expr)
{
  // Use lua to transform user input to lua value
  if (use_lua)
    {
      Value::List res = exec_statements(String("return ") + expr);

      if (res.empty())
	QTLUA_THROW(QtLua::State, "The lua expression `%' returned no value.", .arg(expr));

      return res[0];
    }

    // Do not use lua, only handle string and number cases
    else
      {
	bool ok = false;
	double number = expr.toDouble(&ok);

	if (ok)
	  return Value(this, number);
	else
	  {
	    // strip double quotes if any
	    if (expr.size() > 1 && expr.startsWith('"') && expr.endsWith('"'))
	      return Value(this, String(expr.mid(1, expr.size() - 2)));
	    else
	      return Value(this, expr);
	  }
      }
}

struct lua_reader_state_s
{
  QIODevice *_io;
  QByteArray _read_buf;
};

static const char * lua_reader(lua_State *st, void *data, size_t *size)
{
  struct lua_reader_state_s *rst = (struct lua_reader_state_s *)data;

  rst->_read_buf = rst->_io->read(4096);
  *size = rst->_read_buf.size();
  return rst->_read_buf.constData();
}

Value::List State::exec_chunk(QIODevice &io)
{
  struct lua_reader_state_s rst;
  rst._io = &io;

#if LUA_VERSION_NUM < 502
  if (lua_load(_lst, &lua_reader, &rst, ""))
#else
  if (lua_load(_lst, &lua_reader, &rst, "", NULL))
#endif
    {
      String err(lua_tostring(_lst, -1));
      lua_pop(_lst, 1);
      throw err;
    }

  int oldtop = lua_gettop(_lst);

  if (lua_pcall(_lst, 0, LUA_MULTRET, 0))
    {
      String err(lua_tostring(_lst, -1));
      lua_pop(_lst, 1);
      throw err;
    }

  Value::List res;
  for (int i = oldtop; i <= lua_gettop(_lst); i++)
    res += Value(i, this);
  lua_pop(_lst, lua_gettop(_lst) - oldtop + 1);

  return res;
}

Value::List State::exec_statements(const String & statement)
{
  if (luaL_loadbuffer(_lst, statement.constData(), statement.size(), ""))
    {
      String err(lua_tostring(_lst, -1));
      lua_pop(_lst, 1);
      throw err;
    }

  int oldtop = lua_gettop(_lst);

  if (lua_pcall(_lst, 0, LUA_MULTRET, 0))
    {
      String err(lua_tostring(_lst, -1));
      lua_pop(_lst, 1);
      throw err;
    }

  Value::List res;
  for (int i = oldtop; i <= lua_gettop(_lst); i++)
    res += Value(i, this);
  lua_pop(_lst, lua_gettop(_lst) - oldtop + 1);

  return res;
}

void State::exec(const QString &statement)
{
  try {
    exec_statements(statement);

  } catch (QtLua::String &e) {
    output_str(String("\033[7merror\033[2m: ") + e.constData() + "\n");
  }

  gc_collect();
}

void State::gc_collect()
{
#ifdef HAVE_LUA_GC
  lua_gc(_lst, LUA_GCCOLLECT, 0);
#else
  lua_setgcthreshold(_lst, 0);
#endif
}

void State::reg_c_function(const char *name, lua_CFunction f)
{
  lua_pushcfunction(_lst, f);
  lua_setglobal(_lst, name);
}

State * State::get_this(lua_State *st)
{
  void *data;

  lua_pushlightuserdata(st, &_key_this);
  lua_rawget(st, LUA_REGISTRYINDEX);
  data = lua_touserdata(st, -1);
  lua_pop(st, 1);

  return static_cast<State*>(data);
}

#if LUA_VERSION_NUM < 502
# define QTLUA_LUA_CALL(st, f, modname)	\
  lua_pushcfunction(st, f);		\
  lua_call(st, 0, 0);
#else
# define QTLUA_LUA_CALL(st, f, modname)	\
  luaL_requiref(st, modname, f, 1);     \
  lua_pop(st, 1);
#endif

bool State::openlib(Librarys lib)
{
    bool hasSetted = false;
    if(lib & CoroutineLib) {
#if LUA_VERSION_NUM >= 502
      QTLUA_LUA_CALL(_lst, luaopen_coroutine, "coroutine");
      hasSetted = true;
#else
      lib |= BaseLib;
#endif
    }
    if(lib & BaseLib) {
        QTLUA_LUA_CALL(_lst, luaopen_base, "_G");
        hasSetted = true;
    }
#ifdef HAVE_LUA_PACKAGELIB
    if(lib & PackageLib) {
      QTLUA_LUA_CALL(_lst, luaopen_package, "package");
      hasSetted = true;
    }
#endif
    if(lib & StringLib) {
      QTLUA_LUA_CALL(_lst, luaopen_string, "string");
      hasSetted = true;
    }
    if(lib & TableLib) {
      QTLUA_LUA_CALL(_lst, luaopen_table, "table");
      hasSetted = true;
    }
    if(lib & MathLib) {
      QTLUA_LUA_CALL(_lst, luaopen_math, "math");
      hasSetted = true;
    }
    if(lib & IoLib) {
      QTLUA_LUA_CALL(_lst, luaopen_io, "io");
      hasSetted = true;
    }
#ifdef HAVE_LUA_OSLIB
    if(lib & OsLib) {
      QTLUA_LUA_CALL(_lst, luaopen_os, "os");
      hasSetted = true;
    }
#endif
    if(lib & DebugLib) {
      QTLUA_LUA_CALL(_lst, luaopen_debug, "debug");
      hasSetted = true;
    }
#if LUA_VERSION_NUM >= 502
    if(lib & Bit32Lib) {
      QTLUA_LUA_CALL(_lst, luaopen_bit32, "bit32");
      hasSetted = true;
    }
#endif
#ifdef HAVE_LUA_JITLIB
    if(lib & JitLib) {
      QTLUA_LUA_CALL(_lst, luaopen_jit, "jit");
      hasSetted = true;
    }
#endif
#ifdef HAVE_LUA_FFILIB
    if(lib & FfiLib) {
      QTLUA_LUA_CALL(_lst, luaopen_ffi, "ffi");
      hasSetted = true;
    }
#endif
    if(lib & QtLuaLib) {
      reg_c_function("print", lua_cmd_print);
      reg_c_function("list", lua_cmd_list);
      reg_c_function("each", lua_cmd_each);
      reg_c_function("help", lua_cmd_help);
      reg_c_function("plugin", lua_cmd_plugin);
      reg_c_function("qtype", lua_cmd_qtype);
      hasSetted = true;
    }
    if(lib & QtLib) {
      qtluaopen_qt(this);
      hasSetted = true;
    }

    return hasSetted;
}

bool State::openlib(Library lib)
{
  switch (lib)
    {
    case CoroutineLib:
 #if LUA_VERSION_NUM >= 502
       QTLUA_LUA_CALL(_lst, luaopen_coroutine, "coroutine");
       return true;
 #endif
    case BaseLib:
      QTLUA_LUA_CALL(_lst, luaopen_base, "_G");
      return true;
 #ifdef HAVE_LUA_PACKAGELIB
    case PackageLib:
       QTLUA_LUA_CALL(_lst, luaopen_package, "package");
       return true;
 #endif
    case StringLib:
       QTLUA_LUA_CALL(_lst, luaopen_string, "string");
       return true;
    case TableLib:
       QTLUA_LUA_CALL(_lst, luaopen_table, "table");
       return true;
    case MathLib:
       QTLUA_LUA_CALL(_lst, luaopen_math, "math");
       return true;
    case IoLib:
       QTLUA_LUA_CALL(_lst, luaopen_io, "io");
       return true;
 #ifdef HAVE_LUA_OSLIB
    case OsLib:
      QTLUA_LUA_CALL(_lst, luaopen_os, "os");
      return true;
 #endif
    case DebugLib:
      QTLUA_LUA_CALL(_lst, luaopen_debug, "debug");
      return true;

#if LUA_VERSION_NUM >= 502
    case Bit32Lib:
      QTLUA_LUA_CALL(_lst, luaopen_bit32, "bit32");
      return true;
#endif

#ifdef HAVE_LUA_JITLIB
    case JitLib:
      QTLUA_LUA_CALL(_lst, luaopen_jit, "jit");
      return true;
#endif
#ifdef HAVE_LUA_FFILIB
    case FfiLib:
      QTLUA_LUA_CALL(_lst, luaopen_ffi, "ffi");
      return true;
#endif

    case AllLibs:
#if LUA_VERSION_NUM >= 502
      QTLUA_LUA_CALL(_lst, luaopen_coroutine, "coroutine");
      QTLUA_LUA_CALL(_lst, luaopen_bit32, "bit32");
#endif
#ifdef HAVE_LUA_OSLIB
      QTLUA_LUA_CALL(_lst, luaopen_os, "os");
#endif
#ifdef HAVE_LUA_PACKAGELIB
      QTLUA_LUA_CALL(_lst, luaopen_package, "package");
#endif
      QTLUA_LUA_CALL(_lst, luaopen_base, "_G");
      QTLUA_LUA_CALL(_lst, luaopen_string, "string");
      QTLUA_LUA_CALL(_lst, luaopen_table, "table");
      QTLUA_LUA_CALL(_lst, luaopen_math, "math");
      QTLUA_LUA_CALL(_lst, luaopen_io, "io");
      QTLUA_LUA_CALL(_lst, luaopen_debug, "debug");
#ifdef HAVE_LUA_JITLIB
      QTLUA_LUA_CALL(_lst, luaopen_jit, "jit");
#endif
#ifdef HAVE_LUA_FFILIB
      QTLUA_LUA_CALL(_lst, luaopen_ffi, "ffi");
#endif
      qtluaopen_qt(this);

    case QtLuaLib:
      reg_c_function("print", lua_cmd_print);
      reg_c_function("list", lua_cmd_list);
      reg_c_function("each", lua_cmd_each);
      reg_c_function("help", lua_cmd_help);
      reg_c_function("plugin", lua_cmd_plugin);
      reg_c_function("qtype", lua_cmd_qtype);
      return true;

    case QtLib:
      qtluaopen_qt(this);
      return true;

    default:
      return false;
    }
 }

int State::lua_version() const
{
#if LUA_VERSION_NUM < 501
  return 500;
#else
  return LUA_VERSION_NUM;
#endif
}

void State::lua_do(void (*func)(lua_State *st))
{
  func(_lst);
}

void State::fill_completion_list_r(String &path, const String &prefix,
				   QStringList &list, const Value &tbl,
				   int &cursor_offset)
{
  int len = strcspn(prefix.constData(), ":.");

  if (len == prefix.size())
    {
      String lastentry, tpath(path);

      // enumerate table object
      for (Value::const_iterator i = tbl.begin(); i != tbl.end(); i++)
	{
	  const Value &k = i.key();

	  if (list.size() >= QTLUA_MAX_COMPLETION)
	    return;

	  // ignore non string keys
	  if (k.type() != Value::TString)
	    continue;

	  String entry = k.to_string();

	  if (entry.startsWith(prefix))
	    {
	      try {
		const Value &v = i.value();

		// add operator for known types
		switch (v.type())
		  {
		  case Value::TTable:

		    try {
		      v.push_value(_lst);
		      try {
			lua_pushnil(_lst);
			if (lua_pnext(_lst, -2))
			  {
			    if (lua_type(_lst, -2) == Value::TString)
			      entry += ".";
			    else
			      {
				entry += "[]";
				cursor_offset = -1;
			      }
			    lua_pop(_lst, 2);  // pop key/value
			  }
		      } catch (...) {
			lua_pop(_lst, 1);  // pop key on pnext error
		      }
		      lua_pop(_lst, 1);    // pop table
		    } catch (...) {
		    }
		    check_empty_stack();

		    break;

		  case Value::TFunction:
		    entry += "()";
		    cursor_offset = -1;
		    break;

		  case Value::TUserData:
		    v.to_userdata()->completion_patch(tpath, entry, cursor_offset);
		  default:
		    break;
		  }
	      } catch (String &e) {
		/* can not access value */
	      }

	      lastentry = entry;
	      list.push_back(path.to_qstring() + entry.to_qstring());
	    }
	}

      // apply path patch only if single match
      if (list.size() == 1)
	list[0] = tpath.to_qstring() + lastentry.to_qstring();
    }

  if (list.empty())
    {
      // find intermediate values in path
      String next = prefix.mid(0, len);

      try {
	path += next;
	if (len < prefix.size())
	  path += prefix[len];
	fill_completion_list_r(path, prefix.mid(len + 1), list,
			       tbl.at(next), cursor_offset);
      } catch (...) {
      }

    }
}

void State::fill_completion_list(const QString &prefix, QStringList &list, int &cursor_offset)
{
  String path;

  fill_completion_list_r(path, prefix, list, Value::new_global_env(this), cursor_offset);
}

void State::init(lua_State *L)
{
  assert(Value::TNone == LUA_TNONE);
  assert(Value::TNil == LUA_TNIL);
  assert(Value::TBool == LUA_TBOOLEAN);
  assert(Value::TNumber == LUA_TNUMBER);
  assert(Value::TString == LUA_TSTRING);
  assert(Value::TTable == LUA_TTABLE);
  assert(Value::TFunction == LUA_TFUNCTION);
  assert(Value::TUserData == LUA_TUSERDATA);
  assert(Value::TThread == LUA_TTHREAD);
  create_qmeta_object_table();
  _mst = _lst = L;

  if (!_mst)
    throw std::bad_alloc();

  // creat metatable for UserData events

  lua_pushlightuserdata(_mst, &_key_item_metatable);
  lua_newtable(_mst);

#define LUA_META_BIND(n)			\
  lua_pushstring(_mst, "__" #n);			\
  lua_pushcfunction(_mst, lua_meta_item_##n);	\
  lua_rawset(_mst, -3);

  LUA_META_BIND(add);
  LUA_META_BIND(sub);
  LUA_META_BIND(mul);
  LUA_META_BIND(div);
  LUA_META_BIND(mod);
  LUA_META_BIND(pow);
  LUA_META_BIND(unm);
  LUA_META_BIND(concat);
  LUA_META_BIND(len);
  LUA_META_BIND(eq);
  LUA_META_BIND(lt);
  LUA_META_BIND(le);
  LUA_META_BIND(index);
  LUA_META_BIND(newindex);
  LUA_META_BIND(call);
  LUA_META_BIND(gc);

  lua_rawset(_mst, LUA_REGISTRYINDEX);

  // pointer to this

  lua_pushlightuserdata(_mst, &_key_this);
  lua_pushlightuserdata(_mst, this);
  lua_rawset(_mst, LUA_REGISTRYINDEX);

#if LUA_VERSION_NUM < 501
  // create a weak table for threads, substitute for lua_pushthread
  lua_pushlightuserdata(_mst, &_key_threads);
  lua_newtable(_mst);

  lua_newtable(_mst);    // metatable for weak table mode
  lua_pushstring(_mst, "__mode");
  lua_pushstring(_mst, "v");
  lua_rawset(_mst, -3);
  lua_setmetatable(_mst, -2);

  lua_rawset(_mst, LUA_REGISTRYINDEX);
#endif

  _debug_output = false;
  _yield_on_return = false;
}

}

