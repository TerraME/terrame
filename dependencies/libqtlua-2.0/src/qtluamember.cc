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

    Copyright (C) 2008-2011, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#include <internal/Member>
#include <internal/QObjectWrapper>

namespace QtLua {

  void Member::assign(QObjectWrapper &obj, const Value &value)
  {
    QTLUA_THROW(QtLua::Member, "Can not assign a value to the `%' member of the QObject.",
		.arg(get_type_name()));
  }

  Value Member::access(QObjectWrapper &qow)
  {
    return Value(qow.get_state(), *this);
  }

  bool Member::check_class(const QMetaObject *mo) const
  {
    const QMetaObject *m = mo;

    while (m)
      {
	if (!strcmp(_mo->className(), m->className()))
	  return true;
	m = m->superClass();
      }

    return false;
  }

}

