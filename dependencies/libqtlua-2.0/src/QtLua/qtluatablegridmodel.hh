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

// __moc_flags__ -fQtLua/TableGridModel

#ifndef QTLUA_TABLEGRIDMODEL_HH_
#define QTLUA_TABLEGRIDMODEL_HH_

#include <QAbstractItemModel>
#include <QPointer>

#include "qtluavalue.hh"
#include "qtluavalueref.hh"

namespace QtLua {

  class Table;

  /**
   * @short Qt Model/View lua table grid model class
   * @header QtLua/TableGridModel
   * @module {Model/View}
   *
   * This class can be used to expose 2 dimensionnal arrays stored as
   * nested lua tables to @ref QTableView widgets. Each row in the grid
   * matches an entry in the provided lua table, and each column
   * describe keys used to access nested tables.
   *
   * Column and row keys can be independently handled as numerical
   * indexes or as plain lua value. When in numerical key mode, all
   * keys are assumed to be numbers, first key is 1 and keys order is
   * preserved when inserting or deleting entries.
   *
   * Exposed keys can be defined in several ways:
   * @list
   *  @item all lua values can be automatically fetched from table keys, or
   *  @item keys can be user specified, or
   *  @item incremental numerical keys can be used.
   * @end list
   *
   * Lua tables and @ref UserData objects with valid table operations
   * are handled.
   *
   * Lua tables can be edited from Qt views using this model. The
   * @ref Attribute flags can be used to control which editing
   * actions are allowed. User input may be evaluated as a lua
   * expression when editing a table entry.
   *
   * Lua tables change may @b not update the model on the fly. This is
   * partially due to lack of lua mechanism to implement efficient
   * table change event.
   *
   * Usage example:
   * @example examples/cpp/mvc/tablegridview.cc:1
   *
   * @image qtlua_tablegridmodel.png
   *
   * @see ItemViewDialog
   */

  class TableGridModel : public QAbstractItemModel
  {
    Q_OBJECT;
    Q_ENUMS(Attribute);
    Q_FLAGS(Attributes);

  public:

    /** Specifies @ref TableGridModel behavior for a given lua table @showvalue */
    enum Attribute
      {
	NumKeysCols   = 0x00000001,	//< Columns use numeric keys
	NumKeysRows   = 0x00000002,	//< Rows use numeric keys
	RowColSwap    = 0x00000004,	//< Swap rows and columns in views
	UnquoteHeader = 0x00000008,	//< Strip double quote from string keys
	UnquoteValues = 0x00000010,	//< Strip double quote from string values

	Editable      = 0x00001000,	//< Allow editing exposed tables using views.
	EditFixedType = 0x00002000,	//< Prevent value type change when editing.
	EditLuaEval   = 0x00004000,	//< Evaluate user input as a lua expression.
	EditInsertRow = 0x00008000,	//< Allow insertion of new rows.
	EditInsertCol = 0x00010000,	//< Allow insertion of new columns.
	EditRemoveRow = 0x00020000,	//< Allow deletion of existing rows.
	EditRemoveCol = 0x00040000,	//< Allow deletion of existing columns.
      };

    Q_DECLARE_FLAGS(Attributes, Attribute);

    /** 
     * Create a new lua grid table model. 
     *
     * This constructor will determine rows and columns keys by
     * calling @ref fetch_all_row_keys and @ref fetch_all_column_keys
     * if @tt find_keys is true.
     */
    TableGridModel(const Value &table, Attributes attr,
		   bool find_keys, QObject *parent = 0);

    /** Create a new lua grid table model and use numerical keys with
	given bounds */
    TableGridModel(const Value &table, int row_count, int col_count,
		   Attributes attr, QObject *parent = 0);

    ~TableGridModel();

    /** Switch to numeric row keys and set row count */
    void set_row_count(int c);
    /** Switch to numeric column keys and set column count */
    void set_col_count(int c);

    /** Switch to non-numeric row keys and Add a row key that must
	appear in the table */
    void add_row_key(const Value &k);
    /** Switch to non-numeric row keys and Add a row key that must
	appear in the table */
    void add_row_key(const String &k);
    /** Switch to non-numeric column keys and Add a column key that
	must appear in the table */
    void add_column_key(const Value &k);
    /** Switch to non-numeric column keys and Add a column key that
	must appear in the table */
    void add_column_key(const String &k);

    /** Find all row keys or find maximum row numeric key */
    void fetch_all_row_keys();
    /** Find all column keys or find maximum row numeric key. Must be
	called with at least one available row */
    void fetch_all_column_keys();

    /** Return current non-numeric row keys */
    inline const QList<Value> & row_keys() const;

    /** Return current non-numeric column keys */
    inline const QList<Value> & column_keys() const;

    /** Get @ref ValueRef reference object to lua value at given @ref QModelIndex */
    ValueRef get_value_ref(const QModelIndex &index) const;

    /**
     * Convenience function to display a modal lua table dialog.
     *
     * @param parent parent widget
     * @param title dialog window title
     * @param table lua table to expose
     * @param attr model attributes, control display and edit options
     * @param colkeys list of lua value to use as column keys,
     *  use @ref TableGridModel::fetch_all_column_keys if @tt NULL.
     * @param rowkeys list of lua value to use as row keys,
     *  use @ref TableGridModel::fetch_all_row_keys if @tt NULL.
     */
    static void table_dialog(QWidget *parent, const QString &title, const Value &table,
                             TableGridModel::Attributes attr = TableGridModel::Attributes(),
                             const Value::List *colkeys = 0, const Value::List *rowkeys = 0);

  signals:

    void edit_error(const QString &message);

  protected:

    /** Return the initial value used when inserting new columns for
        cell at given position. The default implementation returns a @tt nil value. */
    virtual Value new_cell_value(State *st, int row, int col) const;

    /** Return the a new table for new row insertion. The default
	implementation returns a lua Value::TTable value filled with
	values provided by the @ref new_cell_value function. */
    virtual Value new_row_table(State *st, int row) const;

    /** Return a row key suitable for given row. This function is
        called when inserting a new row in non-numeric row key
        mode. The new key must no appear in the current list of row keys. */
    virtual Value new_row_key(State *st, int row) const; 

    /** Return a column key suitable for given column. This function is
        called when inserting a new column in non-numeric column key
        mode. The new key must no appear in the current list of column keys. */
    virtual Value new_column_key(State *st, int col) const; 

    /** @multiple @internal */
    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    QModelIndex parent(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent) const;
    bool hasChildren(const QModelIndex & parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    bool setData(const QModelIndex & index, const QVariant & value, int role);
    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role);
    Qt::ItemFlags flags(const QModelIndex &index) const;
    bool removeRows(int row, int count, const QModelIndex &parent);
    bool insertRows(int row, int count, const QModelIndex &parent);
    bool removeColumns(int column, int count, const QModelIndex &parent);
    bool insertColumns(int column, int count, const QModelIndex &parent);
    /** */

  private:
    void check_state() const;

    int row_count() const;
    int column_count() const;
    bool remove_rows(int row, int count, const QModelIndex &parent);
    bool insert_rows(int row, int count, const QModelIndex &parent);
    bool remove_columns(int column, int count, const QModelIndex &parent);
    bool insert_columns(int column, int count, const QModelIndex &parent);

    bool set_value_ref(const ValueRef &ref, const QByteArray &input);

    QPointer<State> _st;
    Attributes _attr;
    Value _table;
    QList<Value> _row_keys;
    int _num_row_count;
    QList<Value> _col_keys;
    int _num_col_count;
  };

  Q_DECLARE_OPERATORS_FOR_FLAGS(TableGridModel::Attributes);

}

#endif

