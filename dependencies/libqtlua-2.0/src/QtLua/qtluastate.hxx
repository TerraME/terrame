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

#ifndef QTLUASTATE_HXX_
#define QTLUASTATE_HXX_

#include "qtluastring.hxx"
#include "qtluavalue.hxx"
#include "qtluavalueref.hxx"

namespace QtLua {

  Value State::operator[] (const Value &key) const
  {
    return at(key);
  }

  Value State::operator[] (const String &key) const
  {
    return (*this)[Value(this, key)];
  }

  Value State::at(const String &key) const
  {
    return (*this)[key];
  }

  ValueRef State::operator[] (const String &key)
  {
    return (*this)[Value(this, key)];
  }

  void State::output_str(const String &str)
  {
    output(str.to_qstring());
  }

  lua_State * State::get_lua_state() const
  {
    return _lst;
  }

  template <class QObject_T>
  static inline QObject * create_qobject()
  {
    return new QObject_T();
  }

  template <class QObject_T>
  void State::register_qobject_meta()
  {
    qtlib_register_meta(&QObject_T::staticMetaObject, &create_qobject<QObject_T>);
  }

  void State::enable_qdebug_print(bool enabled)
  {
    _debug_output = enabled;
  }

}

#endif

