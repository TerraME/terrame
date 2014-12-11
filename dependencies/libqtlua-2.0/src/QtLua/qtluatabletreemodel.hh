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

// __moc_flags__ -fQtLua/TableTreeModel

#ifndef QTLUA_TABLETREEMODEL_HH_
#define QTLUA_TABLETREEMODEL_HH_

#include <QAbstractItemModel>
#include <QPointer>

#include "qtluavalue.hh"

namespace QtLua {

  class TableTreeKeys;

  /**
   * @short Qt Model/View lua table model class
   * @header QtLua/TableTreeModel
   * @module {Model/View}
   *
   * This class can be used to expose lua tables content to Qt view
   * widgets in a flat or hierarchical manner.
   *
   * Lua tables and @ref UserData objects with valid table operations
   * are handled.
   *
   * Lua tables can be edited from Qt views using this model. The
   * @ref Attribute flags can be used to control which editing
   * actions are allowed. User input may be evaluated as a lua
   * expression when editing a table entry.
   *
   * Lua tables change may @b not update the model on the fly and the
   * @ref update function must be called to refresh views on heavy
   * modifications. This is partially due to lack of lua mechanism to
   * implement efficient table change event. If you need to edit the
   * underlying data from lua and have the views updated
   * automatically, you might use the @ref UserItemModel approach
   * instead.
   *
   * Usage example:
   * @example examples/cpp/mvc/tabletreeview.cc:1
   *
   * @image qtlua_tabletreemodel.png
   *
   * @see ItemViewDialog
   */

  class TableTreeModel : public QAbstractItemModel
  {
    Q_OBJECT;
    Q_ENUMS(Attribute);
    Q_FLAGS(Attributes);

  public:

    /** Specifies @ref TableTreeModel behavior for a given lua table @showvalue */
    enum Attribute
      {
	Recursive	= 0x00000001,	//< Expose nested tables too.
	UserDataIter	= 0x00000002,	//< Iterate over UserData objects too.
	HideKey	        = 0x00000020,	//< Do not show key column.
	HideValue	= 0x00000040,	//< Do not show value column.
	HideType	= 0x00000004,	//< Do not show value type column.
	UnquoteKeys	= 0x00000008,	//< Strip double quotes from string keys
	UnquoteValues	= 0x00000010,	//< Strip double quotes from string values

	Editable	= 0x00001000,	//< Allow editing exposed lua tables.
	EditFixedType	= 0x00002000,	//< Prevent value type change when editing.
	EditLuaEval	= 0x00004000,	//< Evaluate user input as a lua expression.
	EditInsert	= 0x00008000,	//< Allow insertion of new entries.
	EditRemove	= 0x00010000,	//< Allow deletion of existing entries.
	EditKey		= 0x00020000,	//< Allow entry key update.
	EditAll		= 0x00039000,	//< Editable, EditInsert, EditRemove and EditKey allowed
      };

    Q_DECLARE_FLAGS(Attributes, Attribute);

    /** Create a new lua table model. */
    TableTreeModel(const Value &root, Attributes attr, QObject *parent = 0);

    ~TableTreeModel();

    /** Clear cached table content and reset model. */
    void update();

    /** Get lua value at given model index */
    Value get_value(const QModelIndex &index) const;

    /** Get supported operations for entry at given @ref QModelIndex */
    Attributes get_attr(const QModelIndex &index) const;

    /**
     * @multiple {2}
     * Shortcut function to display a modal lua table dialog.
     *
     * @param parent parent widget
     * @param title dialog window title
     * @param table lua table to expose
     * @param attr model attributes, control display and edit options
     */
    static void tree_dialog(QWidget *parent, const QString &title, const Value &table, 
			    Attributes attr = Recursive);

    static void table_dialog(QWidget *parent, const QString &title, const Value &table, 
			     Attributes attr = Recursive);

    /** @internal Columns ids */
    enum ColumnId
      {
	ColKey,
	ColValue,
	ColType,
	ColNone,
      };

  signals:

    void edit_error(const QString &message);

  protected:
    /** @multiple @internal */
    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    QModelIndex parent(const QModelIndex &index) const;
    QModelIndex buddy(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent) const;
    bool hasChildren(const QModelIndex & parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    bool setData(const QModelIndex & index, const QVariant & value, int role);
    Qt::ItemFlags flags(const QModelIndex &index) const;
    bool removeRows(int row, int count, const QModelIndex &parent);
    bool insertRows(int row, int count, const QModelIndex &parent);
    /** */

  private:

    enum ColumnId get_column_id(int col, Attributes attr) const;

    void check_state() const;
    TableTreeKeys * table_from_index(const QModelIndex &index) const;

    QPointer<State> _st;
    TableTreeKeys *_table;
  };

  Q_DECLARE_OPERATORS_FOR_FLAGS(TableTreeModel::Attributes);

}

#endif

