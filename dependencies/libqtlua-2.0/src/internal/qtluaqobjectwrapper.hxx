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


#ifndef QTLUAQOBJECTWRAPPER_HXX_
#define QTLUAQOBJECTWRAPPER_HXX_

#include <QtLua/qtluauserdata.hxx>

namespace QtLua {

  QObject & QObjectWrapper::get_object()
  {
    if (!_obj)
      QTLUA_THROW(QtLua::QObjectWrapper, "The wrapper has no associated QObject.");

    return *_obj;
  }

  void QObjectWrapper::set_reparent(bool reparent)
  {
    _reparent = reparent;
  }

  void QObjectWrapper::set_delete(bool delete_)
  {
    _delete = delete_;
  }

  bool QObjectWrapper::valid() const
  {
    return _obj;
  }

  State * QObjectWrapper::get_state()
  {
    return _ls;
  }

  QObjectWrapper::LuaSlot::LuaSlot(const Value &v, int sigindex)
    : _value(v),
      _sigindex(sigindex)
  {
  }

}

#endif

