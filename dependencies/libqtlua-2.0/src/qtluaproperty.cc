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

#include <cstring>

#include <internal/QObjectWrapper>

#include <internal/QMetaValue>
#include <internal/Property>

namespace QtLua {

  Property::Property(const QMetaObject *mo, int index)
    : Member(mo, index)
  { 
  }

  void Property::assign(QObjectWrapper &qow, const Value &value)
  {
    QMetaProperty mp = _mo->property(_index);
    QObject &obj = qow.get_object();

    // Try to reset property if assign nil
    if (value.type() == Value::TNil && mp.isResettable())
      {
	if (!mp.reset(&obj))
 	  QTLUA_THROW(QtLua::Property, "Can't reset QObject property `%'.", .arg(mp.name()));
	return;
      }

    if (!mp.isWritable())
      QTLUA_THROW(QtLua::Property, "QObject property `%' is read only.", .arg(mp.name()));

    if (!mp.write(&obj, QMetaValue(mp.userType(), value).to_qvariant()))
      QTLUA_THROW(QtLua::Property, "Unable to set value of the `%' QObject property.", .arg(mp.name()));
  }

  Value Property::access(QObjectWrapper &qow)
  {
    QMetaProperty mp = _mo->property(_index);
    QObject &obj = qow.get_object();

    if (!mp.isReadable())
      QTLUA_THROW(QtLua::Property, "QObject property `%' is not readable.", .arg(mp.name()));

    QVariant variant = mp.read(&obj);

    if (!variant.isValid())
      QTLUA_THROW(QtLua::Property, "Unable to read a valid value from the `%' QObject property.", .arg(mp.name()));

    return Value(qow.get_state(), variant);
  }

  String Property::get_value_str() const
  {
    return String(_mo->className()) + "::" + _mo->property(_index).name();
  }

  String Property::get_type_name() const
  {
    QMetaProperty mp = _mo->property(_index);
    return Member::get_type_name() + "<" + mp.typeName() + ">";
  }

}

