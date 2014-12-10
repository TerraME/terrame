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


#ifndef QTLUAITEM_HH_
#define QTLUAITEM_HH_

#include <QModelIndex>
#include <QIcon>

#include "qtluastring.hh"
#include "qtluauserdata.hh"
#include "qtluavalue.hh"
#include "qtluauseritemmodel.hh"

namespace QtLua {

class UserItemModel;
class UserListItem;

  /**
   * @short Qt Model/View item class
   * @header QtLua/UserItem
   * @module {Model/View}
   *
   * This class together with the @ref UserListItem and @ref UserItemModel
   * classes enable easy use of list or hierarchical data structures
   * that can be viewed and modified from lua script, Qt view widgets
   * and C++ code.
   *
   * This class implement the generic hierarchical data structure leaf
   * node. It must be used as a base class for objects which may be
   * exposed to Qt views via the @ref UserItemModel class.
   *
   * @ref UserItem objects can be inserted in and removed from @ref
   * UserListItem objects from the C++ code with the @ref insert and @ref
   * remove functions. 
   *
   * Each @ref UserItem object have a node name used for display in Qt
   * views and access from lua script. This name can be accessed from
   * C++ code with the @ref get_name and @ref set_name functions.
   *
   * Each data structure modification by lua script or user view
   * interaction may be allowed or denied by reimplemention of
   * @ref is_move_allowed, @ref is_rename_allowed, @ref
   * is_remove_allowed, and @ref is_replace_allowed functions.
   *
   * See @ref UserItemModel for example.
   */

class UserItem : public UserData
{
  friend class UserItemModel;
  friend class UserListItem;
  friend class UserItemSelectionModel;

public:

  QTLUA_REFTYPE(UserItem);

  /** Create a new UserItem with given name */
  UserItem(const String &name = "");

  UserItem(const UserItem &item);
  ~UserItem();

  /** The as @ref insert. */
  __attribute__((deprecated))
  void move(const Ref<UserListItem> &parent);

  /** Insert this item in parent container, remove from existing parent if any. */
  void insert(const Ref<UserListItem> &parent, int pos = -1);

  /** Remove this item from its container */
  void remove();

  /** Set item name. Name may be mangled to be a valid lua identifier. */
  void set_name(const String &name);

  /** Get item name */
  inline const String & get_name() const;

  /** Get pointer to parent container */
  inline UserListItem * get_parent() const;

  /** Get associated @ref UserItemModel */
  inline UserItemModel * get_model() const;

  /** Get @ref QModelIndex */
  inline QModelIndex get_model_index(int column = 0) const;

protected:

  /** Make model emit QAbstractItemModel::dataChanged signal for this item */
  void data_changed(int column = 0) const;

  /** May be reimplemented for @tt column > 0, see QAbstractItemModel::setData. */
  virtual bool set_data(int column, int role);

  /** May be reimplemented for @tt column > 0, see QAbstractItemModel::data. */
  virtual QVariant get_data(int column, int role) const;

  /** May be reimplemented for @tt column > 0, see QAbstractItemModel::flags. */
  virtual Qt::ItemFlags get_flags(int column) const;

  /** Must return icon decoration to use for this node. */
  virtual QIcon & get_icon() const;

  /** Must return true if item can change parent containers.
      (default is true) */
  virtual bool is_move_allowed() const;

  /** Must return true if item can renamed.
      (default is true) */
  virtual bool is_rename_allowed() const;

  /** Must return true if item can be removed from container.
      (default is true) */
  virtual bool is_remove_allowed() const;

  /** Must return true if item can be removed by replacement by an
      other item (default is is_remove_allowed()) */
  virtual bool is_replace_allowed() const;

  /** Get child position in parent item */
  inline int get_row() const;

private:
  const UserItem &operator=(const UserItem &);

  virtual void set_model(UserItemModel* model);
  bool in_parent_path(UserItem *item);
  void insert_name();
  inline void set_row(int row);
  virtual UserItem * get_child_row(int row) const;
  virtual int get_child_count() const;

  String _name;
  UserListItem *_parent;
  UserItemModel *_model;
  int _row;
};

}

#endif

