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

#include <cstring>

#include <internal/QObjectWrapper>

#include <internal/Method>
#include <internal/QMetaValue>
#include <internal/qtluapoolarray.hh>

namespace QtLua {

  Method::Method(const QMetaObject *mo, int index)
    : Member(mo, index)
  { 
  }

  Value::List Method::meta_call(State *ls, const Value::List &lua_args)
  {
    if (lua_args.size() < 1)
      QTLUA_THROW(QtLua::Method, "Can't call method without object. (use ':' instead of '.')");

    QObjectWrapper::ptr qow = lua_args[0].to_userdata_cast<QObjectWrapper>();

    if (!qow.valid())
      QTLUA_THROW(QtLua::Method, "The method first argument must be a QObject. (use ':' instead of '.')");

    QObject &obj = qow->get_object();

    if (!check_class(obj.metaObject()))
      QTLUA_THROW(QtLua::Method, "The method doesn't belong to the class of the passed QObject.");

    QMetaMethod mm = _mo->method(_index);

    if (mm.methodType() != QMetaMethod::Slot
#if QT_VERSION >= 0x040500
	&& mm.methodType() != QMetaMethod::Method
#endif
	)
      QTLUA_THROW(QtLua::Method, "The QMetaMethod `%' is not callable.",
#if QT_VERSION < 0x050000
		  .arg(mm.signature()));
#else
		  .arg(mm.methodSignature()));
#endif

    PoolArray<QMetaValue, 11> args;
    void *qt_args[11];

    // return value
    if (*mm.typeName())
      qt_args[0] = args.create(QMetaType::type(mm.typeName())).get_data();
    else
      qt_args[0] = 0;

    int i = 1;

    QList<QByteArray> pt = mm.parameterTypes();

    if (pt.size() != lua_args.size() - 1)
      QTLUA_THROW(QtLua::Method, "Wrong number of arguments for the `%' QMetaMethod.",
#if QT_VERSION < 0x050000
		 .arg(mm.signature()));
#else
		 .arg(mm.methodSignature()));
#endif

    // parameters
    foreach (const QByteArray &pt, pt)
      {
	assert(i < 11);

	//	if (i <= lua_args.size())
	  qt_args[i] = args.create(QMetaType::type(pt.constData()), lua_args[i]).get_data();

	  //	else
	  //	  qt_args[i] = args.create(QMetaType::type(pt.constData())).get_data();
	i++;
      }

    // actual invocation
    if (!obj.qt_metacall(QMetaObject::InvokeMetaMethod, _index, qt_args))
      QTLUA_THROW(QtLua::Method, "Error on invocation of the `%' Qt method.",
#if QT_VERSION < 0x050000
		  .arg(mm.signature()));
#else
		  .arg(mm.methodSignature()));
#endif

    if (qt_args[0])
      return args[0].to_value(ls);
    else
      return Value::List();
  }

  String Method::get_type_name() const
  {
    switch (_mo->method(_index).methodType())
      {
      case QMetaMethod::Signal:
	return Member::get_type_name() + "<signal>";
      case QMetaMethod::Slot:
	return Member::get_type_name() + "<slot>";
      default:
	return Member::get_type_name();
      }
  }

  String Method::get_value_str() const
  {
    QMetaMethod mm = _mo->method(_index);
    const char * t = mm.typeName();

    return String(*t ? t : "void") + " " + _mo->className() + "::"
#if QT_VERSION < 0x050000
      + mm.signature();
#else
      + mm.methodSignature();
#endif
  }

  bool Method::support(Value::Operation c) const
  {
    switch (c)
      {
      case Value::OpCall:
	return true;
      default:
	return false;
      }
  }

  void Method::completion_patch(String &path, String &entry, int &offset)
  {
    switch (_mo->method(_index).methodType())
      {
      case QMetaMethod::Slot:
	// force method invokation operator
	if (!path.isEmpty())
	  path[path.size() - 1] = ':';

	entry += "()";
	offset--;

      default:
	break;

      }
  }

}

