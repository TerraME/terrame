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

    Copyright (C) 2012, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/


#ifndef QTLUAQMETAVALUE_HH_
#define QTLUAQMETAVALUE_HH_

#include <QObject>
#include <QPointer>

#include <QtLua/qtluametatype.hh>
#include <QtLua/qtluavalue.hh>

namespace QtLua {

/**
 * @short Qt/lua value conversion
 * @header internal/QMetaValue
 * @module {Base}
 * @internal
 */
  class QMetaValue
  {
    int _type;
    void *_data;

    inline void init(int type);

  public:
    static Value raw_get_object(State *ls, int type, const void *data);
    static void raw_set_object(int type, void *data, const Value &v);

  public:

    inline void * get_data() const;

    inline QMetaValue(int type, const Value &value);
    inline QVariant to_qvariant() const;

    inline QMetaValue(int type);
    inline Value to_value(State *ls) const;

    inline ~QMetaValue();
  };

}

#endif

