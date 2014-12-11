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

    Copyright (C) 2011, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef QTLUAMETATYPE_HXX_
#define QTLUAMETATYPE_HXX_

#include "qtluavalue.hxx"
#include "internal/qtluaqobjectwrapper.hxx"

namespace QtLua {

  template <typename X>
  MetaType<X>::MetaType(const char *name)
    {
      if ((_type = QMetaType::type(name)))
	{
	  if (types_map.contains(_type))
	    QTLUA_THROW(QtLua::MetaType, "A lua conversion handler is already registered for the `%' type.", .arg(_type));
	}
      else
	{
	  _type = qRegisterMetaType<X>(name);
	}

      types_map.insert(_type, reinterpret_cast<metatype_void_t*>(this));
    }

  template <typename X>
  MetaType<X>::MetaType(int type)
    {
      _type = type;

      if (types_map.contains(type))
	QTLUA_THROW(QtLua::MetaType, "A lua conversion handler is already registered for type handle `%'.", .arg(_type));

      types_map.insert(type, reinterpret_cast<metatype_void_t*>(this));
    }

  template <typename X>
  MetaType<X>::~MetaType()
    {
      types_map.remove(_type);
    }

  template <typename X>
  int MetaType<X>::get_type()
  {
    return _type;
  }

  template <class X>
  QtLua::Value MetaTypeQObjectStar<X>::qt2lua(QtLua::State *ls, X* const * qtvalue)
  {
    return Value(ls, QObjectWrapper::get_wrapper(ls, *qtvalue));
  }

  template <class X>
  bool MetaTypeQObjectStar<X>::lua2qt(X** qtvalue, const QtLua::Value &luavalue)
  {
    QObject *obj = &luavalue.to_userdata_cast<QObjectWrapper>()->get_object();
    X *w = qobject_cast<X*>(obj);
    if (!w)
      QTLUA_THROW(QtLua::MetaType, "Can not convert from lua value, QObject is not a `%'.",
		  .arg(QMetaType::typeName(MetaType<X*>::get_type())));
    *qtvalue = w;
    return true;
  }

}

#endif

