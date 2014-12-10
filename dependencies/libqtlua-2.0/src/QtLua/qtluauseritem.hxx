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

#ifndef QTLUAITEM_HXX_
#define QTLUAITEM_HXX_

#include <cassert>

#include "qtluastring.hxx"
#include "qtluauserdata.hxx"
#include "qtluavalue.hxx"
#include "qtluauseritemmodel.hxx"

namespace QtLua {

QModelIndex UserItem::get_model_index(int column) const
{
  assert(_model);
  return _model->createIndex(_row, column, (void*)this);
}

void UserItem::set_row(int row)
{
  _row = row;
}

int UserItem::get_row() const
{
  return _row;
}

UserListItem * UserItem::get_parent() const
{
  return _parent;
}

const String & UserItem::get_name() const
{
  return _name;
}

UserItemModel * UserItem::get_model() const
{
  return _model;
}

}

#endif

