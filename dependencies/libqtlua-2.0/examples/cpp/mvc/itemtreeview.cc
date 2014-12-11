
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

#include <QApplication>

#include "itemtreeview.hh"

MainWindow::MainWindow()
  : QMainWindow()
{
							/* anchor 1 */
  state = new QtLua::State();

  // Create tree root node
  QtLua::UserListItem::ptr root = QTLUA_REFNEW(QtLua::UserListItem, );

  // Set as lua global
  (*state)["root"] = root;

  // Insert 2 new nodes
  QTLUA_REFNEW(QtLua::UserItem, "foo")->insert(root);
  QTLUA_REFNEW(QtLua::UserItem, "foo2")->insert(root);

  // Create Qt view widget and set model
  model = new QtLua::UserItemModel(root);

  treeview = new QTreeView(0);
  treeview->setModel(model);
  setCentralWidget(treeview);

  // Rename node from lua script
  state->exec_statements("root.bar = root.foo2");
							/* anchor end */
}

MainWindow::~MainWindow()
{
  treeview->setModel(0);
  delete model;
  delete state;
}

int main(int argc, char *argv[])
{
  QApplication app(argc, argv);
  MainWindow mainWin;

  mainWin.show();
  return app.exec();
}


