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

#include "test.hh"
#include "test_qobject_arg.hh"

int main(int argc, char **argv)
{
  QApplication app(argc, argv);

  try {
  {
    QtLua::State ls;

    MyObjectUD *myobj = new MyObjectUD();

    ls.exec_statements("function f(obj, ud) v = ud; end");

    ASSERT(ls.at("f").connect(myobj, "ud_arg(QtLua::UserData::ptr)"));
    ls.check_empty_stack();

    ASSERT(ls.at("v").type() == Value::TNil);
    ls.check_empty_stack();

    myobj->send(QTLUA_REFNEW(MyData, 18));
    ls.check_empty_stack();

    ASSERT(ls.at("v").type() == Value::TUserData);
    ls.check_empty_stack();

    ASSERT(ls.at("v").at(0).to_number() == 18);
    ls.check_empty_stack();

    ASSERT(ls.at("f").disconnect(myobj, "ud_arg(QtLua::UserData::ptr)"));
    ls.check_empty_stack();

    ls["o"] = myobj;

    ASSERT(!myobj->_ud.valid());
    ls.check_empty_stack();

    ls.exec_statements("o:ud_slot(v)");

    ASSERT(myobj->_ud.dynamiccast<MyData>()->_data == 18);
    ls.check_empty_stack();
  }

  {
    QtLua::State ls;

    MyObjectQO *myobj = new MyObjectQO();

    ls.exec_statements("function f(obj, qo) v = qo; end");
    ls.check_empty_stack();

    ASSERT(ls.at("f").connect(myobj, "qo_arg(QObject*)"));
    ls.check_empty_stack();

    ASSERT(ls.at("v").type() == Value::TNil);
    ls.check_empty_stack();

    QObject *qo = new QObject();
    qo->setObjectName("qo");
    myobj->send(qo);

    ASSERT(ls.at("v").type() == Value::TUserData);
    ls.check_empty_stack();

    ASSERT(ls.at("v").at("objectName").to_string() == "qo");
    ls.check_empty_stack();

    //    ASSERT(ls["f"].disconnect(myobj, "qo_arg(QtLua::UserData::ptr)"));

    ls["o"] = myobj;

    ASSERT(!myobj->_qo);
    ls.exec_statements("o:qo_slot(v)");
    ASSERT(myobj->_qo == qo);
  }

#if QT_VERSION >= 0x040500
  {
    QtLua::State ls;

    ls.openlib(QtLua::QtLib);
    ls.register_qobject_meta<MyObjectUD>();

    QtLua::Value::List r = ls.exec_statements("a = qt.new_qobject(qt.meta.MyObjectUD, 42, nil); return a;");
    ASSERT(r[0].type() == Value::TUserData);

    r = ls.exec_statements("return a:foo(2)");
    ASSERT(r[0].to_number() == 84);
  }
#endif

  } catch (QtLua::String &e) {
    std::cout << e.constData() << std::endl;
    ASSERT(0);
  }

  return 0;
}

