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


#ifndef QTLUA_TABLEDIALOG_HXX_
#define QTLUA_TABLEDIALOG_HXX_

#include "qtluatabletreemodel.hxx"
#include "qtluatablegridmodel.hxx"

namespace QtLua {

  QAbstractItemModel * ItemViewDialog::get_model() const
  {
    return _model;
  }

  QAbstractItemView * ItemViewDialog::get_view() const
  {
    return _view;
  }

  ItemViewDialog::EditActions ItemViewDialog::get_edit_actions() const
  {
    return _edit;
  }

  void ItemViewDialog::set_edit_actions_(int edit)
  {
    set_edit_actions((EditAction)edit);
  }

}

#endif

