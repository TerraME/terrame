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

    Copyright (C) 2011, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef MYOBJECT_HH_
#define MYOBJECT_HH_

#include <QObject>
#include <QMainWindow>

#include <QtLua/MetaType>
#include <QtLua/State>
#include <QDebug>

							/* anchor 3 */
struct Mystruct
{
  int a;
  int b;
};

							/* anchor end */

							/* anchor 1 */
QTLUA_METATYPE(MyStructConvert, Mystruct);

QtLua::Value MyStructConvert::qt2lua(QtLua::State *ls, const Mystruct *qtvalue)
{
  QtLua::Value luavalue(QtLua::Value::new_table(ls));
  luavalue[1] = qtvalue->a;
  luavalue[2] = qtvalue->b;
  return luavalue;
}

bool MyStructConvert::lua2qt(Mystruct *qtvalue, const QtLua::Value &luavalue)
{
  qtvalue->a = luavalue.at(1);
  qtvalue->b = luavalue.at(2);
  return true;
}
							/* anchor end */

							/* anchor 2 */
QTLUA_METATYPE_QOBJECT(MyQMainwindowConvert, QMainWindow);
							/* anchor end */

							/* anchor 3 */
class MyQObject : public QObject
{
  Q_OBJECT;
  Q_PROPERTY(Mystruct mystruct READ mystruct WRITE setMystruct);
  Q_PROPERTY(QMainWindow* mainwindow READ mainwindow WRITE setMainwindow);
							/* anchor end */

 public:

  void setMystruct(Mystruct m)
  {
    my = m;
  }

  Mystruct mystruct() const
  {
    return my;
  }

  void setMainwindow(QMainWindow *m)
  {
    mw = m;
  }

  QMainWindow* mainwindow() const
  {
    return mw;
  }

private:
  QMainWindow *mw;
  Mystruct my;
};

#endif

