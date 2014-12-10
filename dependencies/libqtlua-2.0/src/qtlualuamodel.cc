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

#include <QModelIndex>
#include <QDebug>

#include <QtLua/Value>
#include <QtLua/LuaModel>
#include <internal/QMetaValue>

// #define QTLUA_LUAMODEL_DEBUG

namespace QtLua {

  LuaModel::LuaModel(const Value &get_func,
		       const Value &set_func,
		       const Value &insert_rows_func,
		       const Value &remove_rows_func,
		       const Value &insert_cols_func,
		       const Value &remove_cols_func,
		       QObject *parent)
  : QAbstractItemModel(parent),
    _get(get_func),
    _set(set_func),
    _insert_rows(insert_rows_func),
    _remove_rows(remove_rows_func),
    _insert_cols(insert_cols_func),
    _remove_cols(remove_cols_func)
  {
  }

  void LuaModel::error(const String &err) const
  {
    qDebug() << "QtLua::LuaModel error, model disabled: " << err;

    LuaModel *this_ = const_cast<LuaModel*>(this);
    this_->_get = Value();
    this_->_set = Value();
    this_->_insert_rows = Value();
    this_->_remove_rows = Value();
    this_->_insert_cols = Value();
    this_->_remove_cols = Value();
  }

  void LuaModel::cached_get(intptr_t item_id, int child_row, int child_col) const
  {
    State *ls = _get.get_state();

    if (_item_id != item_id || _child_row != child_row || _child_col != child_col)
      {
	Value::List r = _get(Value(ls), Value(ls, (double)item_id),
			     Value(ls, child_row), Value(ls, child_col));
	_rsize = r.size();

	for (int i = 0; i < std::min(7, _rsize); i++)
	  _res[i] = r[i].to_integer();

	_item_id = item_id;
	_child_row = child_row;
	_child_col = child_col;
      }
  }

  QModelIndex LuaModel::index(int row, int column, const QModelIndex &parent) const
  {
    if (_get.is_nil())
      return QModelIndex();

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << row << column << parent;
#endif

    try {
      int p;

      if (!parent.isValid())
	p = 0;
      else
	p = (intptr_t)parent.internalPointer();

      cached_get(p, row + 1, column + 1);

      if (_rsize < 3)
	{
	  error("index: lua code must return at least 3 values");
	  return QModelIndex();
	}

      int child_id = _res[2];
      if (child_id == p)
	{
	  error("index: child_id returned by lua code is the same has its parent (item_id)");
	  return QModelIndex();
	}

      return createIndex(row, column, (void*)(intptr_t)child_id);

    } catch (const String &err) {
      error(String("lua error in index(): ") + err);
      return QModelIndex();
    }
  }

  QModelIndex LuaModel::parent(const QModelIndex &index) const
  {
    if (_get.is_nil())
      return QModelIndex();

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << index;
#endif

    if (!index.isValid())
      return QModelIndex();

    try {
      int item_id = (intptr_t)index.internalPointer();

      cached_get(item_id, index.row() + 1, index.column() + 1);

      if (_rsize < 6)
	return QModelIndex();

      int parent_id = _res[3];
      if (!parent_id)
	return QModelIndex();

      if (parent_id == item_id)
	{
	  error("parent: parent_id returned by lua code is the same has its child (item_id)");
	  return QModelIndex();
	}

      return createIndex(_res[4], _res[5], (void*)(intptr_t)parent_id);

    } catch (const String &err) {
      error(String("lua error in parent(): ") + err);
      return QModelIndex();
    }
  }

  int LuaModel::rowCount(const QModelIndex &index) const
  {
    if (_get.is_nil())
      return 0;

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << index;
#endif

    try {
      int p;

      if (!index.isValid())
	p = 0;
      else
	p = (intptr_t)index.internalPointer();

      cached_get(p, index.row() + 1, index.column() + 1);

      if (_rsize < 3)
	return 0;
      return _res[0];

    } catch (const String &err) {
      error(String("lua error in rowCount(): ") + err);
      return 0;
    }
  }

  int LuaModel::columnCount(const QModelIndex &index) const
  {
    if (_get.is_nil())
      return 0;

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << index;
#endif

    try {
      int p;

      if (!index.isValid())
	p = 0;
      else
	p = (intptr_t)index.internalPointer();

      cached_get(p, index.row() + 1, index.column() + 1);

      if (_rsize < 3)
	return 0;
      return _res[1];

    } catch (const String &err) {
      error(String("lua error in columnCount(): ") + err);
      return 0;
    }
  }

  Qt::ItemFlags LuaModel::flags(const QModelIndex &index) const
  {
    if (_get.is_nil())
      return 0;

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << index;
#endif

    try {
      int p;

      if (!index.isValid())
	p = 0;
      else
	p = (intptr_t)index.internalPointer();

      cached_get(p, index.row() + 1, index.column() + 1);

      int f = Qt::ItemIsEnabled | Qt::ItemIsSelectable;

      if (_rsize >= 7)
	f = _res[6];
      else if (!_set.is_nil())
	f |= Qt::ItemIsEditable;

      return (Qt::ItemFlag)f;

    } catch (const String &err) {
      error(String("lua error in flags(): ") + err);
      return 0;
    }
  }

  QVariant LuaModel::data(const QModelIndex &index, int role) const
  {
    if (!index.isValid())
      return QVariant();

#ifdef QTLUA_LUAMODEL_DEBUG
    qDebug() << __func__ << index << role;
#endif

    if (_get.is_nil())
      return QVariant();
    State *ls = _get.get_state();

    try {
      Value::List r = _get(Value(ls, role), Value(ls, (int)(intptr_t)index.internalPointer()));

      if (r.size() < 1)
	return QVariant();

      if (r.size() < 2)
	return r[0].to_qvariant();

      return r[0].to_qvariant(r[1].to_integer());
    } catch (const String &err) {
      qDebug() << String("lua error in data(): %").arg(err);
      return QVariant();
    }
  }

  bool LuaModel::setData(const QModelIndex &index, const QVariant &value, int role)
  {
    if (_set.is_nil())
      return false;
    State *ls = _set.get_state();

    if (!index.isValid())
      return false;

    try {
      int p = (intptr_t)index.internalPointer();

      Value::List r = _set(Value(ls, role), Value(ls, p),
			   QMetaValue::raw_get_object(ls, value.type(), value.constData()));

      if (r.size() < 1)
	return false;
      return r[0].to_boolean();

    } catch (const String &err) {
      qDebug() << String("lua error in data(): %").arg(err);
      return false;
    }
  }

  bool LuaModel::insertRows(int row, int count, const QModelIndex& parent)
  {
    if (_insert_rows.is_nil())
      return false;
    State *ls = _insert_rows.get_state();

    int p;

    if (!parent.isValid())
      p = 0;
    else
      p = (intptr_t)parent.internalPointer();

    Value parg(ls, p);
    Value rarg(ls, row + 1);
    Value carg(ls, count);

    try {
      Value::List l = _insert_rows(Value(ls, Value::True), parg, rarg, carg);
      if (l.size() < 1 || !l[0].to_boolean())
	return false;	

    } catch (const String &err) {
      error(String("lua error in insertRows(): ") + err);
      return false;
    }

    beginInsertRows(parent, row, row + count - 1);

    try {
      _insert_rows(Value(ls, Value::False), parg, rarg, carg);
    } catch (const String &err) {
      error(String("lua error in insertRows(): ") + err);
    }

    endInsertRows();
    return true;
  }

  bool LuaModel::removeRows(int row, int count, const QModelIndex& parent)
  {
    if (_remove_rows.is_nil())
      return false;
    State *ls = _remove_rows.get_state();

    int p;

    if (!parent.isValid())
      p = 0;
    else
      p = (intptr_t)parent.internalPointer();

    Value parg(ls, p);
    Value rarg(ls, row + 1);
    Value carg(ls, count);

    try {
      Value::List l = _remove_rows(Value(ls, Value::True), parg, rarg, carg);
      if (l.size() < 1 || !l[0].to_boolean())
	return false;	

    } catch (const String &err) {
      error(String("lua error in insertRows(): ") + err);
      return false;
    }

    beginRemoveRows(parent, row, row + count - 1);

    try {
      _remove_rows(Value(ls, Value::False), parg, rarg, carg);

    } catch (const String &err) {
      error(String("lua error in removeRows(): ") + err);
    }

    endRemoveRows();
    return true;
  }

  bool LuaModel::insertColumns(int col, int count, const QModelIndex& parent)
  {
    if (_insert_cols.is_nil())
      return false;
    State *ls = _insert_cols.get_state();

    int p;

    if (!parent.isValid())
      p = 0;
    else
      p = (intptr_t)parent.internalPointer();

    Value parg(ls, p);
    Value rarg(ls, col + 1);
    Value carg(ls, count);

    try {
      Value::List l = _insert_cols(Value(ls, Value::True), parg, rarg, carg);
      if (l.size() < 1 || !l[0].to_boolean())
	return false;	

    } catch (const String &err) {
      error(String("lua error in insertColumns(): ") + err);
      return false;
    }

    beginInsertColumns(parent, col, col + count - 1);

    try {
      _insert_cols(Value(ls, Value::False), parg, rarg, carg);
    } catch (const String &err) {
      error(String("lua error in insertColumns(): ") + err);
    }

    endInsertColumns();
    return true;
  }

  bool LuaModel::removeColumns(int col, int count, const QModelIndex& parent)
  {
    if (_remove_cols.is_nil())
      return false;
    State *ls = _remove_cols.get_state();

    int p;

    if (!parent.isValid())
      p = 0;
    else
      p = (intptr_t)parent.internalPointer();

    Value parg(ls, p);
    Value rarg(ls, col + 1);
    Value carg(ls, count);

    try {
      Value::List l = _remove_cols(Value(ls, Value::True), parg, rarg, carg);
      if (l.size() < 1 || !l[0].to_boolean())
	return false;	

    } catch (const String &err) {
      error(String("lua error in insertColumns(): ") + err);
      return false;
    }

    beginRemoveColumns(parent, col, col + count - 1);

    try {
      _remove_cols(Value(ls, Value::False), parg, rarg, carg);

    } catch (const String &err) {
      error(String("lua error in removeColumns(): ") + err);
    }

    endRemoveColumns();
    return true;
  }

}

