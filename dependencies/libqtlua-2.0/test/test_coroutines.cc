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
#include <QtLua/Function>

using namespace QtLua;

QTLUA_FUNCTION(test, "", "")
{
  int a = args[1].to_integer();

  if (a == 42)
    throw String("bad value!");

  ASSERT(args[0] == yield(ls));

  return Value(ls, a * 2);
}

int main()
{
  try {

    {
      QtLua::State ls;
      ls.openlib(AllLibs);

      Value co = ls.exec_statements("return coroutine.create(function(a) while (a < 100) do a = coroutine.yield(a) end return a+1 end )").at(0);

      Value r = co(Value(&ls, 7)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 7);
      if (ls.lua_version() > 500)
	ASSERT(!co.is_dead());
      ls.check_empty_stack();

      r = co(Value(&ls, 22)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 22);
      if (ls.lua_version() > 500)
	ASSERT(!co.is_dead());
      ls.check_empty_stack();

      r = co(Value(&ls, 142)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 143);
      if (ls.lua_version() > 500)
	ASSERT(co.is_dead());
      ls.check_empty_stack();

      bool err = false;
      try {
	r = co(Value(&ls, 66)).at(0);
      } catch (...) {
	err = true;
      }
      ls.check_empty_stack();
      ASSERT(err);
    }

    {
      QtLua::State ls;
      ls.openlib(AllLibs);

      Value m = ls.exec_statements("return function(a) while (a < 100) do a = coroutine.yield(a) end return a+1 end").at(0);

      Value co = Value::new_thread(&ls, m);

      Value r = co(Value(&ls, 7)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 7);

      r = co(Value(&ls, 22)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 22);

      r = co(Value(&ls, 142)).at(0);
      ls.check_empty_stack();
      ASSERT(r.to_integer() == 143);
    }

    {
      QtLua_Function_test test;
      QtLua::State ls;
      ls.openlib(AllLibs);

      ls["test"] = test;
      Value m = ls.exec_statements("return function(a, b) while (true) do b = test(a, b) + 1 end end").at(0);
      Value co = Value::new_thread(&ls, m);

      ASSERT(ls["test"](Value(&ls), Value(&ls, 8)).at(0).to_integer() == 16);
      ls.check_empty_stack();

      ASSERT(co(co, Value(&ls, 7)).at(0).to_integer() == 14);
      ls.check_empty_stack();

      String err;
      try {
	co(Value(&ls, 41));
      } catch (const String &s) {
	err = s;
      }
      ls.check_empty_stack();
      ASSERT(err.endsWith(String("bad value!")));
    }

    {
      QtLua_Function_test test;
      QtLua::State ls;
      ls.openlib(AllLibs);

      ls["test"] = test;
      Value co = ls.exec_statements("return coroutine.create(function(a, b) while (true) do b = test(a, b) + 1 end end)").at(0);

      if (ls.lua_version() > 500)
	{
	  ASSERT(co(co, Value(&ls, 7)).at(0).to_integer() == 14);
	}
      else
	{
	  ASSERT(co(Value(&ls, Value::True), Value(&ls, 7)).at(0).to_integer() == 14);
	}
      ls.check_empty_stack();
    }

  } catch (QtLua::String &e) {
    std::cout << e.constData() << std::endl;
    ASSERT(0);
  }

  return 0;
}

