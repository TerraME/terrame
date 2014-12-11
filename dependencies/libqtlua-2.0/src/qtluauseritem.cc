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

#include <QtLua/UserListItem>
#include <QtLua/String>
#include <QtLua/UserItem>
#include <QtLua/UserItemModel>

namespace QtLua {

bool UserItem::in_parent_path(UserItem *item)
{
  UserItem *	my_path = this;

  while (my_path)
    {
      if (item == my_path)
	return true;
      my_path = my_path->_parent;
    }

  return false;
}

UserItem::UserItem(const String &name)
  : UserData(), _name(name), _parent(0), _model(0), _row(-1)
{
}

UserItem::UserItem(const UserItem &item)
  : UserData(item), _name(item._name), _parent(0), _model(0), _row(-1)
{
}

UserItem::~UserItem()
{
  assert(!_parent);
  assert(!_model);
}

void UserItem::move(const Ref<UserListItem> &parent)
{
  insert(parent);
}

void UserItem::insert(const Ref<UserListItem> &parent, int pos)
{
  if (_parent)
    remove();

  set_model(parent->_model);

  int row = pos < 0 || pos > parent->get_child_count()
    ? parent->get_child_count() : pos;

  if (_model)
    emit _model->layoutAboutToBeChanged();

  parent->insert_child(this, row);
  parent->insert_name(this, row);

  if (_model)
    emit _model->layoutChanged();

  parent->child_changed();
}

void UserItem::remove()
{
  assert(_parent);
  UserItem::ptr this_ = *this;

  UserItemModel *model = _model;
  UserListItem *parent = _parent;

  if (model)
    emit model->layoutAboutToBeChanged();

  set_model(0);
  _parent->remove_child(this);

  if (model)
    emit model->layoutChanged();

  parent->child_changed();
}

void UserItem::set_model(UserItemModel* model)
{
  if (_model && _model != model)
    _model->changePersistentIndex(get_model_index(), QModelIndex());

  _model = model;
}

void UserItem::set_name(const String &name)
{
  if (_parent)
    _parent->remove_name(this);

  _name = name;

  if (_parent)
    {
      _parent->insert_name(this, _row);
      _parent->child_changed();
    }

  if (_model)
    emit _model->dataChanged(get_model_index(), get_model_index());
}

void UserItem::data_changed(int column) const
{
  if (_model)
    emit _model->dataChanged(get_model_index(column), get_model_index(column));  
}

UserItem * UserItem::get_child_row(int row) const
{
  return 0;
}

inline int UserItem::get_child_count() const
{
  return 0;
}

bool UserItem::is_move_allowed() const
{
  return is_rename_allowed();
}

bool UserItem::is_rename_allowed() const
{
  return true;
}

bool UserItem::is_remove_allowed() const
{
  return true;
}

bool UserItem::is_replace_allowed() const
{
  return is_remove_allowed();
}

QIcon &	UserItem::get_icon() const
{
  static QIcon i = QIcon();

  return i;
}

bool UserItem::set_data(int column, int role)
{
  return false;
}

QVariant UserItem::get_data(int column, int role) const
{
  return QVariant();
}

Qt::ItemFlags UserItem::get_flags(int column) const
{
  return Qt::ItemIsEnabled;
}

}

