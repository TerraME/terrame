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

#ifndef QTLUAQMETAOBJECTWRAPPER_HH_
#define QTLUAQMETAOBJECTWRAPPER_HH_

#include <QMetaObject>

#include <QtLua/qtluastate.hh>
#include <QtLua/qtluauserdata.hh>

namespace QtLua {

  struct meta_object_table_s
  {
    const QMetaObject *_mo;
    qobject_creator *_creator;
  };

  /** @internal */
  extern const meta_object_table_s meta_object_table[];

/**
 * @short QMetaObject wrapper class
 * @header internal/QMetaObjectWrapper
 * @module {QObject wrapping}
 * @internal
 *
 * This internal class implements a QMetaObject wrapper which
 * expose meta members of a given @ref QMetaObject object.
 *
 * @see QObjectWrapper
 */

  class QMetaObjectWrapper : public UserData
  {
  public:
    QTLUA_REFTYPE(QMetaObjectWrapper);

    QMetaObjectWrapper(const QMetaObject *mo, qobject_creator *creator = 0);

    /** @This invoke constructor of QObject. Class constructors which
	can be invoked with no arguments and constructors which are
	declared with the @tt Q_INVOKABLE modifier can be used. */
    QObject *create(const Value::List &lua_args) const;

  private:
    Value meta_index(State *ls, const Value &key);
    Ref<Iterator> new_iterator(State *ls);
    bool support(Value::Operation c) const;

    void completion_patch(String &path, String &entry, int &offset);
    String get_value_str() const;

    const QMetaObject *_mo;
    qobject_creator *_creator;
  };

};

#endif

