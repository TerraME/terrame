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

#include <QDebug>
#include <QTableView>

#include <QtLua/TableGridModel>
#include <QtLua/ItemViewDialog>

namespace QtLua {

#define QTLUA_PROTECT(...)					\
  try {								\
    __VA_ARGS__;						\
  } catch (const String &e) {					\
    qDebug() << "TableGridModel::" << __func__ << ": " << e;	\
  }

  void TableGridModel::check_state() const
  {
    if (!_st)
      QTLUA_THROW(TableGridModel, "The associated State object has been destroyed.");
  }

  TableGridModel::TableGridModel(const Value &table, Attributes attr,
				 bool find_keys, QObject *parent)
    : QAbstractItemModel(parent),
      _st(table.get_state()),
      _attr(attr),
      _table(table),
      _num_row_count(0),
      _num_col_count(0)
  {
    check_state();

    if (find_keys)
      {
	fetch_all_row_keys();
	fetch_all_column_keys();
      }
  }

  TableGridModel::TableGridModel(const Value &table, int row_count, int col_count,
				 Attributes attr, QObject *parent)
    : QAbstractItemModel(parent),
      _st(table.get_state()),
      _attr(attr),
      _table(table),
      _num_row_count(row_count),
      _num_col_count(col_count)
  {
    check_state();

    _attr |= Attributes(NumKeysCols | NumKeysRows);
  }

  TableGridModel::~TableGridModel()
  {
  }

  void TableGridModel::fetch_all_row_keys()
  {
    check_state();

    try {
      if (_attr & NumKeysRows)
	{
	  _num_row_count = _table.len();
	}
      else
	{
	  _row_keys.clear();
	  for (Value::const_iterator i = _table.begin(); i != _table.end(); i++)
	    _row_keys.push_back(i.key());
	}
    } catch (const String &e) {
    }
  }

  void TableGridModel::fetch_all_column_keys()
  {
    check_state();

    Value first(_st);

    try {
      if (_attr & NumKeysRows)
	{
	  first = _table.at(1);
	}
      else
	{
	  if (_row_keys.empty())
	    return;
	  first = _table.at(_row_keys[0]);
	}

      if (_attr & NumKeysCols)
	{
	  _num_col_count = first.len();
	}
      else
	{
	  _col_keys.clear();

	  if (!first.is_nil())
	    for (Value::const_iterator i = first.begin(); i != first.end(); i++)
	      _col_keys.push_back(i.key());
	}
    } catch (const String &e) {
    }
  }

  void TableGridModel::set_row_count(int c)
  {
    check_state();

    _attr |= NumKeysRows;
    _num_row_count = c;
  }

  void TableGridModel::set_col_count(int c)
  {
    check_state();

    _attr |= NumKeysCols;
    _num_col_count = c;
  }

  void TableGridModel::add_row_key(const Value &k)
  {
    check_state();

    _attr &= ~NumKeysRows;
    _row_keys.push_back(k);
  }

  void TableGridModel::add_row_key(const String &k)
  {
    check_state();

    _attr &= ~NumKeysRows;
    _row_keys.push_back(Value(_st, k));
  }

  void TableGridModel::add_column_key(const Value &k)
  {
    check_state();

    _attr &= ~NumKeysCols;
    _col_keys.push_back(k);
  }

  void TableGridModel::add_column_key(const String &k)
  {
    check_state();

    _attr &= ~NumKeysCols;
    _col_keys.push_back(Value(_st, k));
  }

  QModelIndex TableGridModel::index(int row, int column, const QModelIndex &parent) const
  {
    if (parent.isValid() || !_st)
      return QModelIndex();

    if ((_attr & RowColSwap ? column : row) >= row_count())
      return QModelIndex();

    if ((_attr & RowColSwap ? row : column) >= column_count())
      return QModelIndex();

    return createIndex(row, column, (void*)0);
  }

  QModelIndex TableGridModel::parent(const QModelIndex &index) const
  {
    return QModelIndex();
  }

  int TableGridModel::row_count() const
  {
    return _attr & NumKeysRows ? _num_row_count : _row_keys.count();
  }

  int TableGridModel::column_count() const
  {
    return _attr & NumKeysCols ? _num_col_count : _col_keys.count();
  }

  int TableGridModel::rowCount(const QModelIndex &parent) const
  {
    if (!_st)
      return 0;

    return _attr & RowColSwap ? column_count() : row_count();
  }

  int TableGridModel::columnCount(const QModelIndex &parent) const
  {
    if (!_st)
      return 0;

    return _attr & RowColSwap ? row_count() : column_count();
  }

  bool TableGridModel::hasChildren(const QModelIndex & parent) const
  {
    return false;
  }

  ValueRef TableGridModel::get_value_ref(const QModelIndex &index) const
  {
    check_state();

    int row = index.row();
    int col = index.column();

    if (_attr & RowColSwap)
      std::swap(row, col);

    // check column bounds
    if (_attr & NumKeysCols)
      {
	if (col >= _num_col_count)
	  goto bound_err;
      }
    else
      {
	if (col >= _col_keys.count())
	  goto bound_err;
      }

    // check row bounds and build valueref
    if (_attr & NumKeysRows)
      {
	if (row >= _num_row_count)
	  goto bound_err;

	if (_attr & NumKeysCols)
	  return ValueRef(_table.at(row + 1), col + 1);
	else
	  return ValueRef(_table.at(row + 1), _col_keys[col]);
      }
    else
      {
	if (row >= _row_keys.count())
	  goto bound_err;

	if (_attr & NumKeysCols)
	  return ValueRef(_table.at(_row_keys[row]), col + 1);
	else
	  return ValueRef(_table.at(_row_keys[row]), _col_keys[col]);
      }

  bound_err:
    QTLUA_THROW(QtLua::TableGridModel, "Index out of bounds (row %, column %).", .arg(row).arg(col));
  }

  QVariant TableGridModel::data(const QModelIndex &index, int role) const
  {
    if (!index.isValid() || !_st)
      return QVariant();

    switch (role)
      {
      case Qt::DisplayRole:
	try {
	  return QVariant(get_value_ref(index).value()
			  .to_string_p(!(_attr & UnquoteValues)));
	} catch (const String &e) {
	  return QVariant();	  
	}

      default:
	return QVariant();
      }
  }

  bool TableGridModel::set_value_ref(const ValueRef &ref, const QByteArray &input)
  {
    try {
      Value::ValueType oldtype = ref.value().type();
      Value newvalue(_st->eval_expr(_attr & EditLuaEval, input));
      Value::ValueType newtype = newvalue.type();

      // check type change
      if ((_attr & EditFixedType) &&
	  (oldtype != Value::TNil) && (oldtype != newtype))
	QTLUA_THROW(TableGridModel, "The entry value type is `%' and can not be changed.",
		    .arg(Value::type_name(oldtype)));

      ref = newvalue;

      return true;

    } catch (const String &s) {
      emit edit_error(QString("Value update error: ") + s.to_qstring());
      return false;
    }
  }

  bool TableGridModel::setData(const QModelIndex & index, const QVariant & value, int role)
  {
    if (!index.isValid() || !_st)
      return false;

    if (role != Qt::EditRole || !value.canConvert(QVariant::ByteArray))
      return false;

    bool changed = set_value_ref(get_value_ref(index), value.toByteArray());
    if (changed)
      emit dataChanged(index, index);
    return changed;
  }

  QVariant TableGridModel::headerData(int section, Qt::Orientation orientation, int role) const
  {
    if (role != Qt::DisplayRole || !_st)
      return QVariant();

    if (_attr & RowColSwap)
      {
	if (orientation == Qt::Vertical)
	  orientation = Qt::Horizontal;
	else
	  orientation = Qt::Vertical;
      }

    switch (orientation)
      {
      case Qt::Vertical:
	if (_attr & NumKeysRows)
	  return QVariant(section + 1);
	else if (section < _row_keys.count())
	  return QVariant(_row_keys[section].to_string_p(!(_attr & UnquoteHeader)));
	break;

      case Qt::Horizontal:
	if (_attr & NumKeysCols)
	  return QVariant(section + 1);
	else if (section < _col_keys.count())
	  return QVariant(_col_keys[section].to_string_p(!(_attr & UnquoteHeader)));
	break;
      }

    return QVariant();
  }

  bool TableGridModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role)
  {
    if (role != Qt::EditRole || !_st)
      return false;

    if (!value.canConvert(QVariant::ByteArray))
      return false;

    if (_attr & RowColSwap)
      {
	if (orientation == Qt::Vertical)
	  orientation = Qt::Horizontal;
	else
	  orientation = Qt::Vertical;
      }

    switch (orientation)
      {
      case Qt::Vertical: {
	bool changed;
	if (_attr & NumKeysRows)
	  changed = set_value_ref(ValueRef(_table, section + 1), value.toByteArray());
	else
	  changed = set_value_ref(ValueRef(_table, _row_keys[section]), value.toByteArray());
	if (changed)
	  emit headerDataChanged(orientation, section, section);
	return changed;
      }

      case Qt::Horizontal:
	// Not implemented yet
	break;
      }

    return false;
  }

  Qt::ItemFlags TableGridModel::flags(const QModelIndex &index) const
  {
    if (!index.isValid() || !_st)
      return Qt::ItemFlags();

    Qt::ItemFlags flags(Qt::ItemIsSelectable | Qt::ItemIsEnabled);

    if (_attr & Editable)
      flags |= Qt::ItemIsEditable;

    return flags;
  }

  bool TableGridModel::removeRows(int row, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    if (_attr & RowColSwap)
      return remove_columns(row, count, parent);
    else
      return remove_rows(row, count, parent);
  }

  bool TableGridModel::insertRows(int row, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    if (_attr & RowColSwap)
      return insert_columns(row, count, parent);
    else
      return insert_rows(row, count, parent);
  }

  bool TableGridModel::removeColumns(int column, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    if (_attr & RowColSwap)
      return remove_rows(column, count, parent);
    else
      return remove_columns(column, count, parent);
  }

  bool TableGridModel::insertColumns(int column, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    if (_attr & RowColSwap)
      return insert_rows(column, count, parent);
    else
      return insert_columns(column, count, parent);
  }

  bool TableGridModel::remove_rows(int row, int count, const QModelIndex &parent)
  {
    if (!(_attr & EditRemoveRow))
      return false;

    if (parent.isValid())
      return false;

    if (_attr & RowColSwap)
      beginRemoveColumns(parent, row, row + count - 1);
    else
      beginRemoveRows(parent, row, row + count - 1);

    if (_attr & NumKeysRows)
      {
	QTLUA_PROTECT(_table.table_shift(row + 1, -count, _num_row_count));
	_num_row_count -= count;
      }
    else
      {
	QTLUA_PROTECT(_table[_row_keys[row]] = Value(_st));
	_row_keys.removeAt(row);
      }

    if (_attr & RowColSwap)
      endRemoveColumns();
    else
      endRemoveRows();

    return true;
  }

  Value TableGridModel::new_cell_value(State *st, int row, int col) const
  {
#if 0
    QString s;
    s.sprintf("%i,%i", row, col);
    return Value(st, s);
#endif
    return Value(st);
  }

  Value TableGridModel::new_row_table(State *st, int row) const
  {
    Value t(Value::new_table(st));

    if (_attr & NumKeysCols)
      {
	for (int i = 0; i < _num_col_count; i++)
	  t[i + 1] = new_cell_value(st, row, i);
      }
    else
      {
	for (int i = 0; i < _col_keys.size(); i++)
	  t[_col_keys[i]] = new_cell_value(st, row, i);
      }

    return t;
  }

  Value TableGridModel::new_row_key(State *st, int row) const
  {
    int k = row;

    // find an unused row key
    bool done;
    do {
      done = true;
      foreach (const Value &v, _row_keys)
	{
	  QTLUA_PROTECT({
	      if (v.to_integer() == k)
		{
		  k++;
		  done = false;
		  break;
		}
	    });
	}
    } while (!done);

    return Value(st, k);
  }

  bool TableGridModel::insert_rows(int row, int count, const QModelIndex &parent)
  { 
    if (!(_attr & EditInsertRow))
      return false;

    if (parent.isValid())
      return false;

    if (_attr & RowColSwap)
      beginInsertColumns(parent, row, row + count - 1);
    else
      beginInsertRows(parent, row, row + count - 1);

    if (_attr & NumKeysRows)
      {
	// shift all tail rows
	QTLUA_PROTECT(_table.table_shift(row + 1, count, new_row_table(_st, row), _num_row_count));
	_num_row_count += count;
      }
    else
      {
	for (int i = 0; i < count; i++)
	  {
	    QTLUA_PROTECT({
		Value k(new_row_key(_st, row + i + 1));
		_row_keys.insert(row + i, k);
		_table[k] = new_row_table(_st, row);
	      });
	  }
      }

    if (_attr & RowColSwap)
      endInsertColumns();
    else
      endInsertRows();

    return true;
  }

  bool TableGridModel::remove_columns(int col, int count, const QModelIndex &parent)
  { 
    if (!(_attr & EditRemoveCol))
      return false;

    if (parent.isValid())
      return false;

    if (_attr & RowColSwap)
      beginRemoveRows(parent, col, col + count - 1);
    else
      beginRemoveColumns(parent, col, col + count - 1);

    if (_attr & NumKeysCols)
      {
	if (_attr & NumKeysRows)
	  {
	    for (int i = 1; i <= _num_row_count; i++)
	      QTLUA_PROTECT(_table[i].table_shift(col + 1, -count, _num_col_count));
	  }
	else
	  {
	    foreach (const Value &v, _row_keys)
	      QTLUA_PROTECT(_table[v].table_shift(col + 1, -count, _num_col_count));
	  }
	_num_col_count -= count;
      }
    else
      {
	if (_attr & NumKeysRows)
	  {
	    for (int i = 1; i <= _num_row_count; i++)
	      QTLUA_PROTECT(_table[i][_col_keys[col]] = Value(_st));
	  }
	else
	  {
	    foreach (const Value &v, _row_keys)
	      QTLUA_PROTECT(_table[v][_col_keys[col]] = Value(_st));
	  }
	_col_keys.removeAt(col);
      }

    if (_attr & RowColSwap)
      endRemoveRows();
    else
      endRemoveColumns();

    return true;
  }

  Value TableGridModel::new_column_key(State *st, int col) const
  {
    int k = col;

    // find an unused column key
    bool done;
    do {
      done = true;
      foreach (const Value &v, _col_keys)
	{
	  QTLUA_PROTECT({
	      if (v.to_integer() == k)
		{
		  k++;
		  done = false;
		  break;
		}
	    });
	}
    } while (!done);

    return Value(st, k);
  }

  bool TableGridModel::insert_columns(int col, int count, const QModelIndex &parent)
  {
    if (!(_attr & EditInsertCol))
      return false;

    if (parent.isValid())
      return false;

    if (_attr & RowColSwap)
      beginInsertRows(parent, col, col + count - 1);
    else
      beginInsertColumns(parent, col, col + count - 1);

    if (_attr & NumKeysCols)
      {
	if (_attr & NumKeysRows)
	  {
	    for (int i = 0; i < _num_row_count; i++)
	      QTLUA_PROTECT(_table[i + 1].table_shift(col + 1, count,
			       new_cell_value(_st, i, col), _num_col_count));
	  }
	else
	  {
	    for (int i = 0; i < _row_keys.size(); i++)
	      QTLUA_PROTECT(_table[_row_keys[i]].table_shift(col + 1, count,
                               new_cell_value(_st, i, col), _num_col_count));
	  }

	_num_col_count += count;
      }
    else
      {
	for (int i = 0; i < count; i++)
	  {
	    QTLUA_PROTECT(_col_keys.insert(col + i, new_column_key(_st, col + i + 1)));

	    if (_attr & NumKeysRows)
	      {
		for (int j = 0; j < _num_row_count; j++)
		  QTLUA_PROTECT(_table[j + 1][_col_keys[col + i]] = new_cell_value(_st, j, col));
	      }
	    else
	      {
		for (int j = 0; j < _row_keys.size(); j++)
		  QTLUA_PROTECT(_table[_row_keys[j]][_col_keys[col + i]] = new_cell_value(_st, j, col));
	      }
	  }
      }

    if (_attr & RowColSwap)
      endInsertRows();
    else
      endInsertColumns();

    return true;
  }

  void TableGridModel::table_dialog(QWidget *parent, const QString &title, const Value &table, 
				    TableGridModel::Attributes attr,
				    const Value::List *colkeys, const Value::List *rowkeys)
  {
    TableGridModel *model = new TableGridModel(table, attr, false, 0);

    if (rowkeys)
      foreach(const Value &k, *rowkeys)
	model->add_row_key(k);
    else
      model->fetch_all_row_keys();

    if (colkeys)
      foreach(const Value &k, *colkeys)
	model->add_column_key(k);
    else
      model->fetch_all_column_keys();

    QTableView *view = new QTableView();

    ItemViewDialog::EditActions a = 0;

    if (attr & Editable)
      a |= ItemViewDialog::EditData;
    if (attr & EditInsertRow)
      a |= ItemViewDialog::EditInsertRow | ItemViewDialog::EditInsertRowAfter;
    if (attr & EditInsertRow)
      a |= ItemViewDialog::EditRemoveRow;
    if (attr & EditInsertCol)
      a |= ItemViewDialog::EditInsertColumn | ItemViewDialog::EditInsertColumnAfter;
    if (attr & EditRemoveCol)
      a |= ItemViewDialog::EditRemoveColumn;

    ItemViewDialog d(a, model, view, parent);
    d.setWindowTitle(title);
    d.exec();
  }

}

