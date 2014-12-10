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

#include <QObject>
#include <QMetaObject>
#include <QMetaMethod>

#include <internal/QMetaObjectWrapper>
#include <internal/QObjectIterator>
#include <internal/MetaCache>
#include <internal/QMetaValue>
#include <internal/qtluapoolarray.hh>

namespace QtLua {

  QMetaObjectWrapper::QMetaObjectWrapper(const QMetaObject *mo, qobject_creator *creator)
    : _mo(mo)
    , _creator(creator)
  {
  }

  QObject * QMetaObjectWrapper::create(const Value::List &lua_args) const
  {
    // try constructor without argument if available
    if (lua_args.size() <= 1 && _creator)
      return _creator();

#if QT_VERSION >= 0x040500
    QObject *obj;
    void *qt_args[11];
    qt_args[0] = &obj;

    // iterate over Q_INVOKABLE constructors
    for (int j = 0; j < _mo->constructorCount(); j++)
      {
	QMetaMethod mm = _mo->constructor(j);

	int i;

	QList<QByteArray> ptlist = mm.parameterTypes();

	if (ptlist.size() != lua_args.size() - 1)
	  continue;

	PoolArray<QMetaValue, 11> args;

	try {
	  // get argument types
	  for (i = 0; i < ptlist.size(); i++)
	    qt_args[i+1] = args.create(QMetaType::type(ptlist[i].constData()),
				     lua_args[i+1]).get_data();
	} catch (...) {
	  continue;
	}

	_mo->static_metacall(QMetaObject::CreateInstance, j, qt_args);

	return obj;
      }
#endif

    QTLUA_THROW(QtLua::QMetaObjectWrapper, "No invokable constructor found to create an object of the `%' class.", .arg(_mo->className()));
  }

  Value QMetaObjectWrapper::meta_index(State *ls, const Value &key)
  {
    const MetaCache &mc = MetaCache::get_meta(_mo);
    String name(key.to_string());

    Member::ptr m = mc.get_member(name);
    if (m.valid())
      return Value(ls, m);

    int enum_value = mc.get_enum_value(name);    
    if (enum_value >= 0)
      return Value(ls, enum_value);

    return Value(ls);
  }

  Ref<Iterator> QMetaObjectWrapper::new_iterator(State *ls)
  {
    return QTLUA_REFNEW(QObjectIterator, ls, _mo);
  }

  bool QMetaObjectWrapper::support(Value::Operation c) const
  {
    switch (c)
      {
      case Value::OpIndex:
      case Value::OpIterate:
	return true;
      default:
	return false;
      }
  }

  void QMetaObjectWrapper::completion_patch(String &path, String &entry, int &offset)
  {
    entry += ".";
  }

  String QMetaObjectWrapper::get_value_str() const
  {
    String res(_mo->className());

    if (_mo->superClass())
      res += String(" : public ") + _mo->superClass()->className();

    return res;
  }

};

