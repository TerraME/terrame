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

#include <QVBoxLayout>
#include <QPushButton>
#include <QTreeView>
#include <QTableView>
#include <QResizeEvent>
#include <QMessageBox>

#include <QtLua/ItemViewDialog>
#include <QtLua/TableTreeModel>
#include <QtLua/TableGridModel>

namespace QtLua {

  ItemViewDialog::ItemViewDialog(EditActions edit,
				 QAbstractItemModel *model,
				 QAbstractItemView *view,
				 QWidget *parent)
    : QDialog(parent),
      _edit(0),
      _model(model),
      _view(view),
      _eb(0), _ach(0),
      _rb(0), _ab(0), _ib(0), _iba(0),
      _rc(0), _ac(0), _ic(0), _ica(0),
      _resize_on_expand(true),
      _column_margin_factor(1.15f)
  {
    _buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok);
    connect(_buttonBox, SIGNAL(accepted()), this, SLOT(accept()));

    _view->setModel(_model);

    _view->setParent(this);
    _model->setParent(this);

    connect(_view->selectionModel(), SIGNAL(currentChanged(const QModelIndex&, const QModelIndex&)),
	    this, SLOT(current_item_changed(const QModelIndex&)));

    if (TableTreeModel *tm = dynamic_cast<TableTreeModel*>(_model))
      connect(tm, SIGNAL(edit_error(const QString&)),
	      this, SLOT(edit_error(const QString&)));

    if (TableGridModel *gm = dynamic_cast<TableGridModel*>(_model))
      connect(gm, SIGNAL(edit_error(const QString&)),
	      this, SLOT(edit_error(const QString&)));

    if (QTreeView *tv = dynamic_cast<QTreeView*>(_view))
      connect(tv, SIGNAL(expanded(const QModelIndex&)),
	      this, SLOT(tree_expanded()));

    QVBoxLayout *layout = new QVBoxLayout;
    layout->addWidget(_view);
    layout->addWidget(_buttonBox);
    setLayout(layout);

    set_edit_actions(edit);
  }

  void ItemViewDialog::set_edit_actions(EditActions edit)
  {
    EditActions e_add = ~_edit & edit;
    EditActions e_remove = _edit & ~edit;

    if (e_add & EditData)
      {
	_eb = _buttonBox->addButton(tr("Edit"), QDialogButtonBox::ActionRole);
	_eb->setEnabled(false);
	connect(_eb, SIGNAL(clicked()), this, SLOT(edit()));
      }
    else if (e_remove & EditData)
      {
	delete _eb;
	_eb = 0;
      }

    ///////////////////////////////

    if (e_add & EditRemoveRow)
      {
	_rb = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	_rb->setEnabled(false);
	connect(_rb, SIGNAL(clicked()), this, SLOT(remove_row()));
      }
    else if (e_remove & EditRemoveRow)
      {
	delete _rb;
	_rb = 0;
      }
    if (_rb)
      {
	_rb->setText(edit & EditColumnAll ? tr("Remove row") : tr("Remove"));
      }

    ///////////////////////////////

    if (e_add & EditInsertRow)
      {
	_ib = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_ib, SIGNAL(clicked()), this, SLOT(insert_row()));
      }
    else if (e_remove & EditInsertRow)
      {
	delete _ib;
	_ib = 0;
      }
    if (_ib)
      {
	_ib->setText(edit & EditInsertRowAfter
		     ? (edit & EditColumnAll ? tr("Insert row before") : tr("Insert before"))
		     : (edit & EditColumnAll ? tr("Insert row") : tr("Insert")));
      }

    ///////////////////////////////

    if (e_add & EditInsertRowAfter)
      {
	_iba = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_iba, SIGNAL(clicked()), this, SLOT(insert_row_after()));
      }
    else if (e_remove & EditInsertRowAfter)
      {
	delete _iba;
	_iba = 0;
      }
    if (_iba)
      {
	_iba->setText(edit & EditInsertRow
		      ? (edit & EditColumnAll ? tr("Insert row after") : tr("Insert after"))
		      : (edit & EditColumnAll ? tr("Insert row") : tr("Insert")));
      }

    ///////////////////////////////

    if (e_add & EditAddRow)
      {
	_ab = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_ab, SIGNAL(clicked()), this, SLOT(add_row()));
      }
    else if (e_remove & EditAddRow)
      {
	delete _ab;
	_ab = 0;
      }
    if (_ab)
      {
	_ab->setText(edit & EditColumnAll ? tr("Add row") : tr("Add"));
      }

    ///////////////////////////////

    if (e_add & EditRemoveColumn)
      {
	_rc = _buttonBox->addButton(tr("Remove column"), QDialogButtonBox::ActionRole);
	connect(_rc, SIGNAL(clicked()), this, SLOT(remove_column()));
      }
    else if (e_remove & EditRemoveColumn)
      {
	delete _rc;
	_rc = 0;
      }

    ///////////////////////////////

    if (e_add & EditInsertColumn)
      {
	_ic = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_ic, SIGNAL(clicked()), this, SLOT(insert_column()));
      }
    else if (e_remove & EditInsertColumn)
      {
	delete _ic;
	_ic = 0;
      }
    if (_ic)
      {
	_ic->setText(edit & EditInsertColumnAfter ? tr("Insert column before") : tr("Insert column"));
      }

    ///////////////////////////////

    if (e_add & EditInsertColumnAfter)
      {
	_ica = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_ica, SIGNAL(clicked()), this, SLOT(insert_column_after()));
      }
    else if (e_remove & EditInsertColumnAfter)
      {
	delete _ica;
	_ica = 0;
      }
    if (_ica)
      {
	_ica->setText(edit & EditInsertColumn ? tr("Insert column after") : tr("Insert column"));
      }

    ///////////////////////////////

    if (e_add & EditAddColumn)
      {
	_ac = _buttonBox->addButton("", QDialogButtonBox::ActionRole);
	connect(_ac, SIGNAL(clicked()), this, SLOT(add_column()));
      }
    if (e_remove & EditAddColumn)
      {
	delete _ac;
	_ac = 0;
      }
    if (_ac)
      {
	_ac->setText(edit & EditColumnAll ? tr("Add column") : tr("Add"));
      }

    ///////////////////////////////

    if (e_add & EditAddChild)
      {
	_ach = _buttonBox->addButton("Add child", QDialogButtonBox::ActionRole);
	connect(_ach, SIGNAL(clicked()), this, SLOT(add_child()));
      }
    if (e_remove & EditAddChild)
      {
	delete _ach;
	_ach = 0;
      }

    _edit = edit;
  }

  void ItemViewDialog::edit() const
  {
    QModelIndex index = _view->currentIndex();

    if (index.isValid())
      {
	_view->scrollTo(index);
	_view->edit(index);
      }
  }

  void ItemViewDialog::edit_error(const QString &message)
  {
    QMessageBox::critical(this, "Error", message);
  }

  void ItemViewDialog::current_item_changed(const QModelIndex &index) const
  {
    if (_rb)
      _rb->setEnabled(index.isValid());

    if (_ach)
      _ach->setEnabled(index.isValid());

    if (_ib)
      _ib->setEnabled(index.isValid() || (!_ab && !_model->hasChildren()));

    if (_iba)
      _iba->setEnabled(index.isValid() || (!_ab && !_model->hasChildren()));

    if (_rc)
      _rc->setEnabled(index.isValid());

    if (_ic)
      _ic->setEnabled(index.isValid() || (!_ac && !_model->columnCount()));

    if (_ica)
      _ica->setEnabled(index.isValid() || (!_ac && !_model->columnCount()));

    if (_eb)
      _eb->setEnabled(index.isValid() && (_model->flags(index) & Qt::ItemIsEditable));
  }

  void ItemViewDialog::tree_expanded() const
  {
    QTreeView *tv = static_cast<QTreeView*>(_view);

    if (_resize_on_expand)
      {
	for (int i = 0; i <= TableTreeModel::ColValue; i++)
	  {
	    tv->resizeColumnToContents(i);

	    if (_column_margin_factor > 1)
	      tv->setColumnWidth(i, tv->columnWidth(i) *
				 _column_margin_factor);
	  }
      }
  }

  void ItemViewDialog::add_child() const
  {
    QModelIndex index = _view->currentIndex();

    new_row(index, _model->rowCount(index));
  }

  void ItemViewDialog::insert_row() const
  {
    QModelIndex index = _view->currentIndex();
    QModelIndex parent;
    int row = _model->rowCount(parent);

    if (index.isValid())
      {
	parent = _model->parent(index);
	row = index.row();
      }

    new_row(parent, row);
  }

  void ItemViewDialog::insert_row_after() const
  {
    QModelIndex index = _view->currentIndex();
    QModelIndex parent;
    int row = _model->rowCount(parent);

    if (index.isValid())
      {
	parent = _model->parent(index);
	row = index.row() + 1;
      }

    new_row(parent, row);
  }

  void ItemViewDialog::add_row() const
  {
    QModelIndex parent;
    int row = _model->rowCount(parent);
    new_row(parent, row);
  }

  void ItemViewDialog::new_row(const QModelIndex &parent, int row) const
  {
    if (!_model->insertRow(row, parent))
      return;

    if (!(_edit & EditDataOnNewRow))
      return;

    for (int col = 0; col < _model->columnCount(parent); col++)
      {
	QModelIndex index = _model->index(row, col, parent);
	if (index.isValid() && (_model->flags(index) & Qt::ItemIsEditable))
	  {
	    _view->scrollTo(index);
	    _view->edit(index);
	    break;
	  }
      }
  }

  void ItemViewDialog::remove_row() const
  {
    QModelIndex index = _view->currentIndex();

    if (!index.isValid())
      return;

    QModelIndex parent = _model->parent(index);
    int row = index.row();

    if (index.isValid())
      _model->removeRow(row, parent);
  }

  void ItemViewDialog::insert_column_after() const
  {
    QModelIndex index = _view->currentIndex();
    QModelIndex parent;
    int col = _model->columnCount(parent);

    if (index.isValid())
      {
	parent = _model->parent(index);
	col = index.column() + 1;
      }

    _model->insertColumn(col, parent);
  }

  void ItemViewDialog::insert_column() const
  {
    QModelIndex index = _view->currentIndex();
    QModelIndex parent;
    int col = _model->columnCount(parent);

    if (index.isValid())
      {
	parent = _model->parent(index);
	col = index.column();
      }

    _model->insertColumn(col, parent);
  }

  void ItemViewDialog::add_column() const
  {
    QModelIndex parent;
    int col = _model->columnCount(parent);
    _model->insertColumn(col, parent);
  }

  void ItemViewDialog::remove_column() const
  {
    QModelIndex index = _view->currentIndex();

    if (!index.isValid())
      return;

    QModelIndex parent = _model->parent(index);
    int col = index.column();

    if (index.isValid())
      _model->removeColumn(col, parent);
  }

  QSize ItemViewDialog::sizeHint() const
  {
    int colcount = _model->columnCount(QModelIndex());
    QSize hint(0, 640);

    if (QTreeView *tv = dynamic_cast<QTreeView*>(_view))
      {
	for (int i = 0; i < colcount; i++)
	  {
	    tv->resizeColumnToContents(i);
	    // Leave room for expand
	    if (_column_margin_factor > 1)
	      tv->setColumnWidth(i, tv->columnWidth(i) * _column_margin_factor);

	    hint.rwidth() += tv->columnWidth(i);
	  }
      }
    else if (QTableView *tv = dynamic_cast<QTableView*>(_view))
      {
	for (int i = 0; i < colcount; i++)
	  {
	    tv->resizeColumnToContents(i);
	    if (_column_margin_factor > 1)
	      tv->setColumnWidth(i, tv->columnWidth(i) * _column_margin_factor);
	    hint.rwidth() += tv->columnWidth(i);
	  }
      }

    return hint;
  }

  void ItemViewDialog::set_resize_on_expand(bool roe)
  {
    _resize_on_expand = roe;
  }

  bool ItemViewDialog::get_resize_on_expand() const
  {
    return _resize_on_expand;
  }

  void ItemViewDialog::set_column_margin_factor(float cmf)
  {
    _column_margin_factor = cmf;
  }

  float ItemViewDialog::get_column_margin_factor() const
  {
    return _column_margin_factor;
  }

}

