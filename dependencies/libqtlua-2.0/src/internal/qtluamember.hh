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


#ifndef QTLUAMEMBER_HH_
#define QTLUAMEMBER_HH_

#include <QObject>
#include <QPointer>

#include <QtLua/qtluauserdata.hh>
#include <QtLua/qtluametatype.hh>

namespace QtLua {

  class QObjectWrapper;
  class Value;

/**
 * @short Qt meta member wrappers class
 * @header internal/Member
 * @module {QObject wrapping}
 * @internal
 *
 * This is the base class for @ref Method, @ref Property and @ref Enum
 * wrapper classes.
 */
  class Member : public UserData
  {
  public:
    QTLUA_REFTYPE(Member);

    inline Member(const QMetaObject *mo, int index);
    inline Member();

    inline int get_index() const;
    bool check_class(const QMetaObject *mo) const;

    virtual void assign(QObjectWrapper &qow, const Value &value);
    virtual Value access(QObjectWrapper &qow);

  protected:
    const QMetaObject *_mo;
    int _index;
  };

}

#endif

