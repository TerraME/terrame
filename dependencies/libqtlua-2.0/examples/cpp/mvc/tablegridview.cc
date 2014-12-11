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

#include <QApplication>

#include <QtLua/Value>

#include "tablegridview.hh"

MainWindow::MainWindow()
  : QMainWindow()
{
							/* anchor 1 */
  state = new QtLua::State();

  // 2 dimensions array using nested lua tables
  QtLua::Value table(state->exec_statements(
    "return { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 } }"
  )[0]);

  // Create a new model and expose lua table
  model = new QtLua::TableGridModel(table, QtLua::TableGridModel::Editable, true);

  // Create Qt view widget
  tableview = new QTableView(0);
  tableview->setModel(model);

  setCentralWidget(tableview);
							/* anchor end */
}

MainWindow::~MainWindow()
{
  tableview->setModel(0);
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


