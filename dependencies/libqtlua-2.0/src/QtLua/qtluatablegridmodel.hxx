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

    Copyright (C) 2010, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/


#ifndef QTLUA_TABLEGRIDMODEL_HXX_
#define QTLUA_TABLEGRIDMODEL_HXX_

#include "qtluavalue.hxx"
#include "qtluavalueref.hxx"

namespace QtLua {

  const QList<Value> & TableGridModel::row_keys() const
  {
    return _row_keys;
  }

  const QList<Value> & TableGridModel::column_keys() const
  {
    return _col_keys;
  }

}

#endif

