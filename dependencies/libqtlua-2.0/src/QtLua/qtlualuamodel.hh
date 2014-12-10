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

// __moc_flags__ -fQtLua/LuaModel

#ifndef QTLUA_CALLMODEL_HH_
#define QTLUA_CALLMODEL_HH_

#include <QAbstractItemModel>

#include "qtluavalue.hh"

namespace QtLua {

  /**
     @short Qt Model/View lua model wrapper
     @header QtLua/UserItemModel
     @module {Model/View}

     This class allows defining a Qt model using lua code. Lua
     functions must be provided to the C++ model wrapper in order to
     implement the model.

     The @xref {qt.mvc.new_lua_model} lua function can be used to
     create such a model from lua script.

     @section {read-only lua model}

     At least one lua function must be provided to implement a
     read-only model. This mandatory function is responsible for
     exposing the model layout and data:

     @code
function get(role, item_id, child_row, child_col)
     @end code

     The get function may be first called multiple times by the
     wrapper with a @tt nil value in the @tt role parameter. In this
     case, the lua code must expose the data layout:

     @list
       @item @tt role is a @tt nil value.
       @item @tt item_id is the numerical id of the queried item. 0 is
         reserved for root.
       @item @tt child_row and @tt child_col are the row and column of
         a child item under the queried item, starting at 1.
     @end list

     The lua code must then return at least 3 values. This is enough if the
     queried item has no parent:

     @code
return (item_rows, item_cols, child_id, parent_id, item_row, item_col, flags)
     @end code

     @list
       @item @tt item_rows and @tt item_cols are the number of rows
         and columns under the item specified by item_id.
       @item @tt child_id is a numerical id for the child item at
         position specified by @tt child_row and @tt child_col
         under the queried item. A positive id must provided by
         the lua code and will be used to refer to this item
         later.
       @item @tt parent_id is the numerical id of the parent of the
         item specified by item_id. @tt nil or 0 can be returned for
         root.
       @item @tt item_row and @tt item_col give the position of the
         item specified by @tt item_id in its parent, starting at
         1. This is not used if @tt parent_id is @tt nil or 0.
       @item @tt flags is the @ref Qt::ItemFlag value to use for the
         queried item. A default value is used if @tt nil.
     @end list

     If the @tt role parameter is not a @tt nil value, the @tt get
     function must instead return the data associated with the
     specified the display role:
     
     @code
return (item_data, data_type)
     @end code

     If the lua code returns two values,
     the second value is a numeric Qt type handle which is used to
     perform the type conversion from the lua the value (see @xref
     {qt.meta_type}). The simple @ref Value::to_qvariant function is
     used to perform conversion when this hint is not present.

     @end section
     @section {editable lua model}

       Five other functions may be provided to implement an editable model.

       The @tt set function is responsible for updating the data of an
       item; it must return @tt true if the update was successful:

       @code
function set(role, item_id, value)
       @end code

       Four more function can be provided to support insertion and
       removal of items in the model:

       @code
function insert_rows(check, parent_id, pos, count)
function insert_cols(check, parent_id, pos, count)
function remove_rows(check, parent_id, pos, count)
function remove_cols(check, parent_id, pos, count)
       @end code

       When the @tt check parameter value is @tt true, the model must
       return a boolean value to indicate if the insert action is
       allowed. The insertion will takes place on the next call if
       the first call returns @tt {true}.
     @end section

     @section {Examples}
       Some examples of lua @sourcelink examples/lua/mvc/lua_model_list.lua {list
       model} and @sourcelink examples/lua/mvc/lua_model_tree.lua
       {tree model} are available in the QtLua tree.
     @end section
  */

  class LuaModel : public QAbstractItemModel
  {
    Q_OBJECT;
    Q_ENUMS(ItemDataRole);

  public:

    LuaModel(const Value &get_func,
	      const Value &set_func = Value(),
	      const Value &insert_rows_func = Value(),
	      const Value &remove_rows_func = Value(),
	      const Value &insert_cols_func = Value(),
	      const Value &remove_cols_func = Value(),
	      QObject *parent = 0);

    enum ItemDataRole
      {
	DisplayRole =               ::Qt::DisplayRole,
	DecorationRole =	    ::Qt::DecorationRole,
	EditRole =		    ::Qt::EditRole,
	ToolTipRole =		    ::Qt::ToolTipRole,
	StatusTipRole =	            ::Qt::StatusTipRole,
	WhatsThisRole =	            ::Qt::WhatsThisRole,

	// Metadata
	FontRole =		    ::Qt::FontRole,
	TextAlignmentRole =	    ::Qt::TextAlignmentRole,
	BackgroundColorRole =	    ::Qt::BackgroundColorRole,
	BackgroundRole =	    ::Qt::BackgroundRole,
	TextColorRole =	            ::Qt::TextColorRole,
	ForegroundRole =	    ::Qt::ForegroundRole,
	CheckStateRole =	    ::Qt::CheckStateRole,

	// Accessibility
	AccessibleTextRole =	    ::Qt::AccessibleTextRole,
	AccessibleDescriptionRole = ::Qt::AccessibleDescriptionRole,

	// More general purpose
	SizeHintRole =	            ::Qt::SizeHintRole,
	InitialSortOrderRole =      ::Qt::InitialSortOrderRole,

	UserRole =                  ::Qt::UserRole
      };

  private:

    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    QModelIndex parent(const QModelIndex &index) const;
    int rowCount(const QModelIndex &parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    Qt::ItemFlags flags(const QModelIndex &index) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);
    bool insertRows(int row, int count, const QModelIndex& parent);
    bool removeRows(int row, int count, const QModelIndex& parent);
    bool insertColumns(int col, int count, const QModelIndex& parent);
    bool removeColumns(int col, int count, const QModelIndex& parent);
    void error(const String &err) const;

    void cached_get(intptr_t item_id, int child_row, int child_col) const;

    mutable intptr_t _item_id;
    mutable int _child_row, _child_col, _rsize;
    mutable intptr_t _res[7];

    Value _get;
    Value _set;
    Value _insert_rows;
    Value _remove_rows;
    Value _insert_cols;
    Value _remove_cols;
  };

}

#endif
