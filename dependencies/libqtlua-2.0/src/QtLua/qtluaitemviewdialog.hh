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

// __moc_flags__ -fQtLua/ItemViewDialog

#ifndef QTLUA_TABLEDIALOG_HH_
#define QTLUA_TABLEDIALOG_HH_

#include <QAbstractItemView>
#include <QDialog>
#include <QDialogButtonBox>

#include "qtluatabletreemodel.hh"
#include "qtluatablegridmodel.hh"

namespace QtLua {

  /**
   * @short Qt Model/View dialog
   * @header QtLua/ItemViewDialog
   * @module {Model/View}
   *
   * This class provides a generic dialog to view and edit data in a
   * model.
   *
   * Some edit buttons can be made available depending on the value of
   * the @ref edit_actions attribute.
   *
   * Some @xref {QObject related functions}{lua functions} can be used
   * to create and invoke these dialogs from lua script.
   *
   * @see TableTreeModel @see TableGridModel
   */

  class ItemViewDialog : public QDialog
  {
    Q_OBJECT;
    Q_PROPERTY(bool resize_on_expand READ get_resize_on_expand WRITE set_resize_on_expand);
    Q_PROPERTY(float column_margin_factor READ get_column_margin_factor WRITE set_column_margin_factor);
    Q_PROPERTY(int edit_actions READ get_edit_actions WRITE set_edit_actions_);
    Q_ENUMS(EditAction);

  public:

    enum EditAction
      {
	EditData              = 0x00001,
	EditDataOnNewRow      = 0x00002,
	EditAddChild          = 0x00004,

	EditInsertRow         = 0x00010,
	EditInsertRowAfter    = 0x00020,
	EditAddRow            = 0x00040,
	EditRemoveRow         = 0x00080,
        EditRowAll            = 0x000f0,

	EditInsertColumn      = 0x00100,
	EditInsertColumnAfter = 0x00200,
	EditAddColumn         = 0x00400,
	EditRemoveColumn      = 0x00800,
        EditColumnAll         = 0x00f00,
      };

    Q_DECLARE_FLAGS(EditActions, EditAction);

    /**
     * Create a table dialog.
     *
     * @param table lua table to expose
     * @param type dialog type
     * @param model mvc model to use, a default model is created if @tt NULL.
     * @param attr model attributes, control display and edit options
     *
     * @see TableTreeModel::tree_dialog
     * @see TableTreeModel::table_dialog
     * @see TableGridModel::table_dialog
     */
    ItemViewDialog(EditActions edit,
		   QAbstractItemModel *model,
		   QAbstractItemView *view = 0,
		   QWidget *parent = 0);

    void set_edit_actions(EditActions edit);
    inline EditActions get_edit_actions() const;

    /** Return pointer to model */
    inline QAbstractItemModel *get_model() const;
    /** Return pointer to view */
    inline QAbstractItemView *get_view() const;

    /** Set keys column resize to content on node expand */
    void set_resize_on_expand(bool roe);
    /** Get current resize on expand state */
    bool get_resize_on_expand() const;

    /** Set additionnal column width factor */
    void set_column_margin_factor(float cmf);
    /** Get additionnal column width factor */
    float get_column_margin_factor() const;

  private slots:
    void edit() const;
    void edit_error(const QString &message);
    void current_item_changed(const QModelIndex & index) const;
    void tree_expanded() const;
    void add_child() const;

    void insert_row() const;
    void insert_row_after() const;
    void add_row() const;
    void remove_row() const;

    void insert_column_after() const;
    void insert_column() const;
    void add_column() const;
    void remove_column() const;

  protected:
    virtual QSize sizeHint() const;

  private:

    inline void set_edit_actions_(int edit);
    void new_row(const QModelIndex &parent, int row) const;

    EditActions _edit;
    QAbstractItemModel *_model;
    QAbstractItemView *_view;
    QDialogButtonBox *_buttonBox;
    QPushButton *_eb, *_ach;
    QPushButton *_rb, *_ab, *_ib, *_iba;
    QPushButton *_rc, *_ac, *_ic, *_ica;
    bool _resize_on_expand;
    float _column_margin_factor;
  };

  Q_DECLARE_OPERATORS_FOR_FLAGS(ItemViewDialog::EditActions);

}

#endif

