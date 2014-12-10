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

    Copyright (C) 2009, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#include <QtLua/UserItemSelectionModel>
#include <QtLua/UserItemModel>
#include <QtLua/UserItem>
#include <QtLua/UserListItem>

namespace QtLua {

  void UserItemSelectionModel::select(const QModelIndex &index, QItemSelectionModel::SelectionFlags command)
  {
    select(QItemSelection(index, index), command);
  }

  void UserItemSelectionModel::select_childs(const QModelIndex &index, QItemSelection &selection)
  { 
    UserItem *i = static_cast<UserItem*>(index.internalPointer());

    if (UserListItem *l = dynamic_cast<UserListItem*>(i))
      foreach(const UserItem::ptr &c, l->get_list())
	{
	  selection.select(c->get_model_index(), c->get_model_index());
	  select_childs(c->get_model_index(), selection);
	}
  }

  void UserItemSelectionModel::select_parents(const QModelIndex &index, QItemSelection &selection)
  {
    UserItem *i = static_cast<UserItem*>(index.internalPointer());

    while (UserItem *p = i->get_parent())
      {
	selection.select(p->get_model_index(), p->get_model_index());
	i = p;
      }
  }

  void UserItemSelectionModel::select(const QItemSelection &selection, QItemSelectionModel::SelectionFlags command)
  {
    if (command & QItemSelectionModel::Clear)
      {
	QItemSelectionModel::select(selection, QItemSelectionModel::Clear);
	command &= ~QItemSelectionModel::Clear;
      }

    if (command & (QItemSelectionModel::Select | QItemSelectionModel::Toggle))
      {
	QItemSelection sel;

	sel.merge(selection, QItemSelectionModel::ClearAndSelect);

	// Remove all selected child items of selected parents from new selection
	foreach (const QModelIndex &index, selection.indexes())
	  {
	    if (!index.isValid())
	      continue;
	    QItemSelection rm;
	    select_childs(index, rm);
	    sel.merge(rm, QItemSelectionModel::Deselect);
	  }

	// Deselect all parents and childs items of newly selected items
	QItemSelection desel;

	foreach (const QModelIndex &index, sel.indexes())
	  {
	    if (!index.isValid())
	      continue;
	    select_childs(index, desel);
	    select_parents(index, desel);
	  }

	// FIXME QItemSelectionModel::select is called twice
	QItemSelectionModel::select(sel, command);
	QItemSelectionModel::select(desel, QItemSelectionModel::Deselect);
      }
    else
      {
	QItemSelectionModel::select(selection, command);
      }
  }

}

