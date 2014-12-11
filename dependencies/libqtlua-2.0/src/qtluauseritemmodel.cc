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

#include <QIcon>
#include <QSet>

#include <QtLua/UserItem>
#include <QtLua/UserListItem>
#include <QtLua/UserItemModel>

namespace QtLua {

UserItemModel::UserItemModel(UserListItem::ptr root, QObject *parent)
  : QAbstractItemModel(parent),
    _root(root)
{
  assert(!_root->get_model());
  _root->set_model(this);
}

UserItemModel::~UserItemModel()
{
  _root->set_model(0);
}

UserItem::ptr UserItemModel::get_item(const QModelIndex &index)
{
  return *static_cast<UserItem*>(index.internalPointer());
}

QVariant UserItemModel::data(const QModelIndex &index, int role) const
{
  if (!index.isValid())
    return QVariant();

  UserItem *item = static_cast<UserItem*>(index.internalPointer());

  if (index.column())
    return item->get_data(index.column(), role);

  switch (role)
    {
    case Qt::DisplayRole:
      return QVariant(item->get_name());

    case Qt::DecorationRole:
      return item->get_icon();

    default:
      return QVariant();
    }
}

Qt::ItemFlags UserItemModel::flags(const QModelIndex &index) const
{
  if (!index.isValid())
    return Qt::ItemIsDropEnabled;

  UserItem *item = static_cast<UserItem*>(index.internalPointer());

  if (index.column())
    return item->get_flags(index.column());

  Qt::ItemFlags res = Qt::ItemIsEnabled | Qt::ItemIsSelectable;

  if (item->is_rename_allowed())
    res |= Qt::ItemIsEditable;

  if (item->is_move_allowed())
    res |= Qt::ItemIsDragEnabled;

  if (dynamic_cast<UserListItem*>(item))
    res |= Qt::ItemIsDropEnabled;

  return res;
}

UserItem::ptr UserItemModel::from_mimedata(const QMimeData *data)
{
  return UserItem::ptr();
}

bool UserItemModel::dropMimeData(const QMimeData *data, Qt::DropAction action,
			     int row, int column, const QModelIndex &parent)
{
  UserListItem *pi = parent.isValid()
    ? static_cast<UserListItem*>(parent.internalPointer())
    : _root.ptr();

  if (!pi)		// parent is not a UserListItem ?
    return false;

  if (row < 0)
    row = 0;

  const ItemQMimeData *d = dynamic_cast<const ItemQMimeData*>(data);

  if (!d)
    // external mime object drop
    {
      UserItem::ptr i = from_mimedata(data);

      if (i.valid())
	{
	  i->insert(*pi, row);
	  return true;
	}
    }

  else
    // internal existing items drop
    {
      switch (action)
	{
	case Qt::IgnoreAction:
	  return true;

	case Qt::MoveAction: {

	  QSet<UserListItem*> changed;

	  emit layoutAboutToBeChanged();

	  foreach(UserItem::ptr i, d->_itemlist)
	    {
	      if (!i->is_move_allowed() || !pi->accept_child(i))
		continue;

	      UserListItem *p = i->_parent;

	      // handle case where deleted item shifts row offset
	      if (pi == p && row > i->_row)
		row--;

	      assert(row <= pi->get_child_count());

	      p->remove_child(i.ptr());

	      pi->insert_child(i.ptr(), row);
	      pi->insert_name(i.ptr(), row++);

	      changed.insert(p);
	      if (p != pi)
		changed.insert(pi);
	    }

	  emit layoutChanged();

	  foreach(UserListItem *li, changed)
	    li->child_changed();

	  return true;
	}

	default:
	  break;
	}
    }

  return false;
}

QStringList UserItemModel::mimeTypes() const
{
  QStringList types;
  types << QString("application/qtlua.item");
  return types;
}

QMimeData * UserItemModel::mimeData(const QModelIndexList &indexes) const
{
  ItemQMimeData *r = new ItemQMimeData();

  foreach(const QModelIndex &index, indexes)
    r->_itemlist.push_back(*static_cast<UserItem*>(index.internalPointer()));

  r->setData("application/qtlua.item", "");

  return r;
}

Qt::DropActions UserItemModel::supportedDropActions() const
{
  return Qt::MoveAction /* | Qt::CopyAction*/;
}

QVariant UserItemModel::headerData(int section, Qt::Orientation orientation, int role) const
{
  return QVariant();
}

QModelIndex UserItemModel::index(int row, int column, const QModelIndex &parent) const
{
  UserListItem *p;

  if (!parent.isValid())
    p = _root.ptr();
  else
    p = static_cast<UserListItem*>(parent.internalPointer());

  int c = p->get_column_count();
  assert(c > 0);

  if (column >= 0 && column < c && row >= 0 && row < p->_child_list.size())
    return createIndex(row, column, p->_child_list[row].ptr());
  else
    return QModelIndex();
}

QModelIndex UserItemModel::parent(const QModelIndex &index) const
{
  if (!index.isValid())
    return QModelIndex();

  UserItem *c = static_cast<UserItem*>(index.internalPointer());
  UserListItem *p = c->get_parent();

  if (!p || p == _root.ptr())
    return QModelIndex();

  return createIndex(p->get_row(), 0, p);
}

int UserItemModel::rowCount(const QModelIndex &parent) const
{
  UserItem *p;

  if (!parent.isValid())
    p = _root.ptr();
  else
    p = static_cast<UserItem*>(parent.internalPointer());

  return p->get_child_count();
}

int UserItemModel::columnCount(const QModelIndex &parent) const
{
  UserListItem *p;

  if (!parent.isValid())
    p = _root.ptr();
  else
    p = static_cast<UserListItem*>(parent.internalPointer());

  return p->get_column_count();
}

bool UserItemModel::setData(const QModelIndex & index, const QVariant & value, int role)
{
  if (!index.isValid())
    return false;

  UserItem *item = static_cast<UserItem*>(index.internalPointer());

  if (index.column())
    return item->set_data(index.column(), role);

  switch (role)
    {
    case Qt::EditRole:
      item->set_name(value.toString());
      return true;

    default:
      return false;
    }
}

Value UserItemModel::get_selection(State *ls, const QAbstractItemView &view)
{
  assert(dynamic_cast<UserItemModel*>(view.model()));
  QItemSelectionModel *sm = view.selectionModel();

  if (!sm || !sm->hasSelection())
    return Value(ls);

  Value table(Value::new_table(ls));

  int i = 1;
  foreach(const QModelIndex &index, sm->selectedIndexes())
    {
      Value entry(ls, *static_cast<UserItem*>(index.internalPointer()));

      table[i++] = entry;
    }

  return table;
}

}

