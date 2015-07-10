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

#include <internal/QObjectWrapper>
#include <internal/MetaCache>
#include <internal/StaticFunction>
#include <internal/QMetaValue>
#include <internal/qtluapoolarray.hh>

namespace QtLua {

  StaticFunction::StaticFunction(const QMetaObject *mo, 
                                 const String &name, FunctionSignature func, 
                                 const QMetaType::Type argt_array[], int argc)
    : Member(mo, -1), FunctionWrapperData(func, argt_array, argc), 
    _name(name)
  {
    
  }
  
  StaticFunction::StaticFunction(const QMetaObject *mo, 
                                 const String &name, FunctionSignature func, 
                                 const QList<String> &argv)
    : Member(mo, -1), FunctionWrapperData(func, argv), 
    _name(name)
  {
  }

  Value::List StaticFunction::meta_call(State *ls, const Value::List &lua_args)
  {
    return _func(ls, lua_args);
  }

  String StaticFunction::get_type_name() const
  {
	return "QtLua::Method<static>";
  }

  String StaticFunction::get_value_str() const
  {
    return _return_type_name + " " + MetaCache::get_meta_name(_mo) + "::" + _name + "(" + _argvs_type_name + ")";
  }

  bool StaticFunction::support(Value::Operation c) const
  {
    switch (c)
      {
      case Value::OpCall:
	return true;
      default:
	return false;
      }
  }

  void StaticFunction::completion_patch(String &path, String &entry, int &offset)
  {
	if (!path.isEmpty()) path[path.size() - 1] = '.';
	entry += "()";
	offset--;
  }

}

