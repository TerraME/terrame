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
#include <QTreeView>
#include <QTableView>
#include <QHeaderView>

#include <QtLua/TableTreeModel>
#include <QtLua/ItemViewDialog>

#include <internal/TableTreeKeys>

namespace QtLua {

#define QTLUA_PROTECT(...)					\
  try {								\
    __VA_ARGS__;						\
  } catch (const String &e) {					\
    qDebug() << "TableTreeModel::" << __func__ << ": " << e;	\
  }

  void TableTreeModel::check_state() const
  {
    if (!_st)
      QTLUA_THROW(QtLua::TableTreeModel, "The associated State object has been destroyed.");
  }

  TableTreeModel::TableTreeModel(const Value &root, Attributes attr, QObject *parent)
    : QAbstractItemModel(parent),
      _st(root.get_state())
  {
    check_state();
    _table = new TableTreeKeys(root, attr);
  }

  TableTreeModel::~TableTreeModel()
  {
    delete _table;
  }

  enum TableTreeModel::ColumnId TableTreeModel::get_column_id(int col, Attributes attr) const
  {
    if (attr & HideKey)
      col++;
    if (col >= 1 && (attr & HideValue))
      col++;
    if (col >= 2 && (attr & HideType))
      col++;
    return col >= 3 ? ColNone : (ColumnId)col;
  }

  void TableTreeModel::update()
  {
    _table->clear();
#if QT_VERSION < 0x050000
    reset();
#else
    beginResetModel();
    endResetModel();
#endif
  }

  TableTreeKeys * TableTreeModel::table_from_index(const QModelIndex &index) const
  {
    if (!index.isValid())
      return _table;

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());
    return t->set_table(index.row());
  }

  QModelIndex TableTreeModel::index(int row, int column, const QModelIndex &parent) const
  {
    if (!_st)
      return QModelIndex();

    TableTreeKeys *t = table_from_index(parent);

    if (!t)
      return QModelIndex();

    t->update();

    if ((unsigned)row < t->count())
      return createIndex(row, column, t);
    else
      return QModelIndex();
  }

  QModelIndex TableTreeModel::parent(const QModelIndex &index) const
  {
    if (!index.isValid() || !_st)
      return QModelIndex();

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());
    assert(t);

    if (t->_parent != NULL)
      return createIndex(t->_row, 0, t->_parent);
    else
      return QModelIndex();
  }

  int TableTreeModel::rowCount(const QModelIndex &parent) const
  {
    if (!_st)
      return 0;

    TableTreeKeys *t = table_from_index(parent);

    if (t == NULL)
      return 0;

    t->update();
    return t->count();
  }

  bool TableTreeModel::hasChildren(const QModelIndex &parent) const
  {
    if (!_st)
      return false;

    TableTreeKeys *t = table_from_index(parent);

    return t != NULL;
  }

  int TableTreeModel::columnCount(const QModelIndex &parent) const
  {
    if (!_st)
      return 0;

    return !(_table->_attr & HideKey) + !(_table->_attr & HideValue) + !(_table->_attr & HideType);
  }

  QVariant TableTreeModel::data(const QModelIndex &index, int role) const
  {
    if (!index.isValid() || !_st)
      return QVariant();

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());

    try {

      switch (role)
	{
	case Qt::DisplayRole: {
	  switch (get_column_id(index.column(), t->_attr))
	    {
	    case ColKey:
	      return QVariant(t->get_key(index.row()).to_string_p(!(t->_attr & UnquoteKeys)));
	    case ColValue:
	      return QVariant(t->get_value(index.row()).to_string_p(!(t->_attr & UnquoteValues)));
	    case ColType:
	      return QVariant(t->get_value(index.row()).type_name_u());
	    default:
	      return QVariant();
	    }
	}

	default:
	  return QVariant();
	}

    } catch (const String &e) {
      return QVariant();
    }
  }

  Value TableTreeModel::get_value(const QModelIndex &index) const
  {
    check_state();

    if (!index.isValid())
      return Value(_st);

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());

    switch (get_column_id(index.column(), t->_attr))
      {
      case ColKey:
	return t->get_key(index.row());
      case ColValue:
	return t->get_value(index.row());
      default:
	return Value(_st);
      }
  }

  TableTreeModel::Attributes TableTreeModel::get_attr(const QModelIndex &index) const
  {
    check_state();

    if (!index.isValid())
      return Attributes();

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());
    return t->_attr;
  }

  Qt::ItemFlags TableTreeModel::flags(const QModelIndex &index) const
  {
    if (!index.isValid() || !_st)
      return 0;

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());

    Qt::ItemFlags res = (Qt::ItemFlag)(Qt::ItemIsEnabled | Qt::ItemIsSelectable);

    if (t->_attr & Editable)
      {
	switch (get_column_id(index.column(), t->_attr))
	  {
	  case ColValue:
	    if (!t->is_table(index.row()))		// prevent edit if already explored table
	      res = res | Qt::ItemIsEditable;
	    break;

	  case ColKey:
	    if (t->_attr & EditKey || t->get_key(index.row()).is_nil())
	      res = res | Qt::ItemIsEditable;
	    break;

	  default:
	    break;
	  }
      }

    if (t->_attr & EditRemove)
      res |= Qt::ItemIsSelectable;

    return res;
  }

  bool TableTreeModel::setData(const QModelIndex & index, const QVariant & value, int role)
  {
    if (!index.isValid() || !_st)
      return false;

    if (role != Qt::EditRole)
      return false;

    if (!value.canConvert(QVariant::ByteArray))
      return false;

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());

    String input = value.toString();

    try {

      Value oldvalue(t->get_value(index.row()));
      Value::ValueType oldtype = oldvalue.type();
      Value newvalue(_st->eval_expr(t->_attr & EditLuaEval, input));
      Value::ValueType newtype = newvalue.type();

      switch (get_column_id(index.column(), t->_attr))
	{
	case ColValue: {

	  if (!(t->_attr & EditRemove) && newvalue.is_nil())
	    QTLUA_THROW(QtLua::TableTreeModel, "Can not change the entry value to nil.");

	  // check type change
	  if ((t->_attr & EditFixedType) &&
	      (oldtype != Value::TNil) && (oldtype != newtype))
	    QTLUA_THROW(QtLua::TableGridModel, "The entry value type is `%' and can not be changed.",
			.arg(Value::type_name(oldtype)));

	  t->set_value(index.row(), newvalue);
	  emit dataChanged(index, index);
	  emit layoutAboutToBeChanged();
	  emit layoutChanged();
	  return true;
	}

	case ColKey: {

	  if (newvalue.is_nil())
	    QTLUA_THROW(QtLua::TableTreeModel, "The entry key can not be a nil value.");

	  if (!t->_value.at(newvalue).is_nil())
	    QTLUA_THROW(QtLua::TableTreeModel, "An entry with the same key already exists.");

	  Value old = t->get_value(index.row());
	  t->set_value(index.row(), Value(_st));
	  t->set_key(index.row(), newvalue);
	  t->set_value(index.row(), old);
	  emit dataChanged(index, index);
	  return true;
	}

	default:
	  ;
	}

    } catch (const String &s) {
      emit edit_error(QString("Value update error: ") + s.to_qstring());
    }

    return false;
  }

  bool TableTreeModel::removeRows(int row, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    TableTreeKeys *t = table_from_index(parent);

    if (!t || !(t->_attr & EditRemove))
      return false;

    beginRemoveRows(parent, row, row + count - 1);

    // set lua table to nil and delete nested tables
    for (int i = row; i < row + count; i++)
      {
	QTLUA_PROTECT(t->set_value(i, Value(_st)));

	if (TableTreeKeys *c = t->_entries[i]._table)
	  delete c;
      }

    // update tail rows indexes
    for (int i = row + count; i < (int)t->count(); i++)
      if (TableTreeKeys *c = t->_entries[i]._table)
	c->_row -= count;

    t->_entries.erase(t->_entries.begin() + row,
		      t->_entries.begin() + row + count);

    endRemoveRows();

    return true;
  }

  bool TableTreeModel::insertRows(int row, int count, const QModelIndex &parent)
  {
    if (!_st)
      return false;

    TableTreeKeys *t = table_from_index(parent);

    if (!t || !(t->_attr & EditInsert))
      return false;

    beginInsertRows(parent, row, row + count - 1);

    for (int i = 0; i < count; i++)
      t->_entries.insert(row, TableTreeKeys::Entry(Value(_st)));

    for (int i = row + count; i < (int)t->count(); i++)
      if (TableTreeKeys *c = t->_entries[i]._table)
	c->_row += count;

    endInsertRows();

    return true;
  }

  QVariant TableTreeModel::headerData(int section, Qt::Orientation orientation, int role) const
  {
    if (role != Qt::DisplayRole || !_st)
      return QVariant();

    if (orientation == Qt::Vertical)
      return QVariant(section + 1);

    switch (get_column_id(section, _table->_attr))
      {
      case ColKey:
	return QVariant("key");
      case ColValue:
	return QVariant("Value");
      case ColType:
	return QVariant("Type");
      default:
	return QVariant();
      }
  }

  QModelIndex TableTreeModel::buddy(const QModelIndex &index) const
  {
    if (!index.isValid() || !_st)
      return index;

    TableTreeKeys *t = static_cast<TableTreeKeys*>(index.internalPointer());

    switch (get_column_id(index.column(), t->_attr))
      {
      default:
      case ColValue:
	return index;

      case ColKey:
	if (t->_attr & EditKey)
	  return index;

      case ColType:
	return createIndex(index.row(), t->_attr & HideKey ? 0 : 1, t);
      }
  }

  void TableTreeModel::tree_dialog(QWidget *parent, const QString &title, const Value &table, 
				   TableTreeModel::Attributes attr)
  {
    TableTreeModel *model = new TableTreeModel(table, attr, 0);
    QTreeView *view = new QTreeView();

    ItemViewDialog::EditActions a = 0;

    if (attr & Editable)
      a |= ItemViewDialog::EditData | ItemViewDialog::EditDataOnNewRow;
    if (attr & EditInsert)
      a |= ItemViewDialog::EditInsertRow | ItemViewDialog::EditInsertRowAfter;
    if (attr & EditRemove)
      a |= ItemViewDialog::EditRemoveRow;

    ItemViewDialog d(a, model, view, parent);
    d.setWindowTitle(title);

    view->setRootIsDecorated(attr & Recursive);

    connect(view, SIGNAL(expanded(const QModelIndex&)),
	    &d, SLOT(tree_expanded()));

    d.exec();
  }

  void TableTreeModel::table_dialog(QWidget *parent, const QString &title, const Value &table, 
				    TableTreeModel::Attributes attr)
  {
    TableTreeModel *model = new TableTreeModel(table, attr, 0);
    QTableView *view = new QTableView();

    ItemViewDialog::EditActions a = 0;

    if (attr & Editable)
      a |= ItemViewDialog::EditData | ItemViewDialog::EditDataOnNewRow;
    if (attr & EditInsert)
      a |= ItemViewDialog::EditInsertRow | ItemViewDialog::EditInsertRowAfter;
    if (attr & EditRemove)
      a |= ItemViewDialog::EditRemoveRow;

    ItemViewDialog d(a, model, view, parent);
    d.setWindowTitle(title);

    view->verticalHeader()->hide();

    d.exec();
  }



}

