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


#include <QtLua/Value>
#include <QtLua/UserListItem>
#include <QtLua/UserItemModel>
#include <QtLua/String>

#include <internal/ListIterator>

namespace QtLua {

Value UserListItem::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
{
  switch (op)
    {
    case Value::OpLen:
      return Value(ls, get_child_count());
    default:
      return UserData::meta_operation(ls, op, a, b);
    }
}

void UserListItem::meta_newindex(State *ls, const Value &key, const Value &value)
  
{
  UserItem::ptr old;
  Value::ValueType t = key.type();
  unsigned int c = 0;

  switch (t)
    {
    case Value::TString:
      old = get_child(key.to_string());
      break;

    case Value::TNumber: {
      const QList<Ref<UserItem> > &l = get_list();
      c = key.to_integer();
      if (c > 0 && c <= (unsigned int)l.size())
	old = l[c - 1];
      break;
    }

    default:
      QTLUA_THROW(QtLua::UserListItem, "Bad item key type, a `lua::string' or a `lua::number' value is expected.");
    }

  switch (value.type())
    {
    case Value::TNil:
      if (old.valid())
	{
	  if (!old->is_remove_allowed())
	    QTLUA_THROW(QtLua::UserListItem, "Removing the `%' item is not permitted.", .arg(old->get_name()));
	  old->remove();
	}
      break;

    case Value::TUserData: {
      UserItem::ptr kbml = value.to_userdata_cast<UserItem>();

      if (in_parent_path(kbml.ptr()))
	QTLUA_THROW(QtLua::UserListItem, "The `%' item can not have one of its parent as a child.", .arg(kbml->get_name()));

      // remove item with same key if it already exists
      if (old.valid())
	{
	  if (!old->is_replace_allowed())
	    QTLUA_THROW(QtLua::UserListItem, "Replacing the `%' item with the `%' item  is not permitted.",
			.arg(old->get_name()).arg(kbml->get_name()));
	  old->remove();
	}

      if (kbml->_parent == this && t != Value::TNumber)
	{
	  // rename
	  if (!kbml->is_rename_allowed())
	    QTLUA_THROW(QtLua::UserListItem, "Renaming the `%' item is not permitted.", .arg(kbml->get_name()));
	  kbml->set_name(key.to_string());
	  break;
	}

      if (kbml->_parent != this)
	{
	  if (!kbml->is_move_allowed())
	    QTLUA_THROW(QtLua::UserListItem, "Moving the `%' item to an other parent is not permitted.", .arg(kbml->get_name()));

	  if (!accept_child(kbml))
	    QTLUA_THROW(QtLua::UserListItem, "The parent item `%' doesn't accept the `%' item as child.",
			.arg(get_name()).arg(kbml->get_name()));
	}

      // remove item from parent if needed
      if (kbml->_parent)
	kbml->remove();

      switch (t)
	{
	case Value::TString:
	  // rename and insert
	  kbml->set_name(key.to_string());
	  kbml->insert(*this);
	  break;
	case Value::TNumber:
	  // insert
	  kbml->insert(*this, c - 1);
	  break;
	default:
	  abort();
	}

    } break;

    default:
      QTLUA_THROW(QtLua::UserListItem, "A value of type `%' can not be stored in model.",
		  .arg(value.type_name_u()));
    }
}

Value UserListItem::meta_index(State *ls, const Value &key)
  
{
  switch (key.type())
    {
    case Value::TString: {
      UserItem::ptr item = get_child(key.to_string());
      if (item.valid())
	return Value(ls, item);
      break;
    }

    case Value::TNumber: {
      const QList<Ref<UserItem> > &l = get_list();
      unsigned int c = key.to_integer();
      if (c > 0 && c <= (unsigned int)l.size())
	return Value(ls, l[c - 1]);
      break;
    }

    default:
      break;
    }

  return Value(ls);
}

bool UserListItem::meta_contains(State *ls, const Value &key)
{
  switch (key.type())
    {
    case Value::TString:
      return get_child(key.to_string()).valid();

    case Value::TNumber: {
      const QList<Ref<UserItem> > &l = get_list();
      unsigned int c = key.to_integer();
      return c > 0 && c <= (unsigned int)l.size();
    }

    default:
      return false;
    }
}

Iterator::ptr UserListItem::new_iterator(State *ls)
{
  return QTLUA_REFNEW(ListIterator, ls, UserListItem::ptr(*this));
}

bool UserListItem::support(Value::Operation c) const
{
  switch (c)
    {
    case Value::OpIndex:
    case Value::OpNewindex:
    case Value::OpIterate:
    case Value::OpLen:
      return true;
    default:
      return false;
    }
}

void UserListItem::change_indexes(int first)
{
  for (int i = first; i < get_child_count(); i++)
    {
      const UserItem::ptr &item = _child_list[i];

      if (_model)
	{
	  QModelIndex old(item->get_model_index());
	  _child_list[i]->set_row(i);
	  _model->changePersistentIndex(old, item->get_model_index());
	}
      else
	{
	  _child_list[i]->set_row(i);
	}
    }
}

void UserListItem::remove_child(UserItem *item)
{
  assert(item->_parent == this);

  _child_hash.remove(item->_name);
  _child_list.removeAt(item->_row);
  change_indexes(item->_row);
  item->_parent = 0;
  item->_row = -1;
}

void UserListItem::insert_child(UserItem *item, int row)
{
  _child_list.insert(row, *item);
  item->_parent = this;
  item->_row = row;
  change_indexes(row + 1);
}

void UserListItem::insert_name(UserItem *item, int row)
{
  QString name = item->_name;

  if (name.size() == 0)
    name = default_child_name(row);

  name = name.replace(QRegExp("[^A-Za-z0-9_]"), "_");

  if (_child_hash.contains(name))
    {
      String basename = name.remove(QRegExp("_[0-9]+$"));
      do {
	name = QString().sprintf("%s_%u", basename.constData(), _id_counter++);
      } while (_child_hash.contains(name));
    }

  item->_name = name;

  _child_hash.insert(name, item);
}

bool UserListItem::accept_child(const UserItem::ptr &item) const
{
  return true;
}

int UserListItem::get_column_count() const
{
  return 1;
}

UserListItem::UserListItem()
  : _id_counter(1)
{
}

UserListItem::~UserListItem()
{
  foreach(const UserItem::ptr &tmp, _child_list)
    {
      assert(!tmp->_model);
      tmp->_parent = 0;
      tmp->_row = -1;
    }
}

void UserListItem::set_model(UserItemModel* model)
{
  if (_model == model)
    return;

  foreach(const UserItem::ptr &tmp, _child_list)
    tmp->set_model(model);

  UserItem::set_model(model);
}

void UserListItem::completion_patch(String &path, String &entry, int &offset)
{
  entry += ".";
}

void UserListItem::child_changed()
{
}

String UserListItem::default_child_name(int row) const
{
  return "noname";
}

}

