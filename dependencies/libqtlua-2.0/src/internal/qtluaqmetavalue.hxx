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

    Copyright (C) 2008-2012, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef QTLUAQMETAVALUE_HXX_
#define QTLUAQMETAVALUE_HXX_

#include <QtLua/qtluametatype.hxx>
#include <QtLua/qtluavalue.hxx>

namespace QtLua {

  void QMetaValue::init(int type)
  {
    _type = type;
    if (type == QMetaType::Void)
      {
        _data = 0;
        return;
      }
#if QT_VERSION < 0x050000
    _data = QMetaType::construct(_type);
#else
    _data = QMetaType::create(_type, 0);
#endif
    if (!_data)
      QTLUA_THROW(QtLui::QMetaValue, "Failed to construct an object of type `%' using the QMetaType API.",
		  .arg(QMetaType::typeName(_type)));
  }

  QMetaValue::QMetaValue(int type, const Value &value)
  {
    init(type);
    try {
      raw_set_object(_type, _data, value);
    } catch (...) {
      QMetaType::destroy(_type, _data);
      throw;
    }
  }

  QVariant QMetaValue::to_qvariant() const
  {    
    return _type != QMetaType::Void ? QVariant(_type, _data) : QVariant();
  }

  QMetaValue::QMetaValue(int type)
  {
    init(type);
  }

  Value QMetaValue::to_value(State *ls) const
  {
    return raw_get_object(ls, _type, _data);
  }

  QMetaValue::~QMetaValue()
  {
    if (_type != QMetaType::Void)
      QMetaType::destroy(_type, _data);
  }

  void * QMetaValue::get_data() const
  {
    return _data;
  }

}

#endif

