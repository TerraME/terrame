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

#ifndef QTLUAQHASHPROXY_HXX_
#define QTLUAQHASHPROXY_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class Container>
  QHashProxyRo<Container>::QHashProxyRo()
    : _hash(0)
  {
  }

  template <class Container>
  QHashProxyRo<Container>::QHashProxyRo(Container &hash)
    : _hash(&hash)
  {
  }

  template <class Container>
  QHashProxy<Container>::QHashProxy()
    : QHashProxyRo<Container>()
  {
  }

  template <class Container>
  QHashProxy<Container>::QHashProxy(Container &hash)
    : QHashProxyRo<Container>(hash)
  {
  }

  template <class Container>
  void QHashProxyRo<Container>::set_container(Container *hash)
  {
    _hash = hash;
  }

  template <class Container>
  Value QHashProxyRo<Container>::meta_index(State *ls, const Value &key)
  {
    if (!_hash)
      return Value(ls);

    typename Container::iterator i = _hash->find(key);

    if (i == _hash->end())
      return Value(ls);
    else
      return Value(ls, i.value());
  }

  template <class Container>
  bool QHashProxyRo<Container>::meta_contains(State *ls, const Value &key)
  {
    return _hash->contains(key);
  }

  template <class Container>
  Value QHashProxyRo<Container>::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
  {
    switch (op)
      {
      case Value::OpLen:
	return Value(ls, _hash ? _hash->size() : 0);
      case Value::OpUnm:
	return _hash ? Value(ls, *_hash) : Value(ls);
      default:
	return UserData::meta_operation(ls, op, a, b);
      }
  }

  template <class Container>
  bool QHashProxyRo<Container>::support(Value::Operation c) const
  {
    switch (c)
      {
      case Value::OpIndex:
      case Value::OpIterate:
      case Value::OpLen:
      case Value::OpUnm:
	return true;
      default:
	return false;
      }
  }

  template <class Container>
  bool QHashProxy<Container>::support(enum Value::Operation c)
  {
    switch (c)
      {
      case Value::OpIndex:
      case Value::OpNewindex:
      case Value::OpIterate:
      case Value::OpLen:
      case Value::OpUnm:
	return true;
      default:
	return false;
      }
  }

  template <class Container>
  void QHashProxy<Container>::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    if (!_hash)
      QTLUA_THROW(QtLua::QHashProxy, "Can not index a null container.");

    else if (value.type() == Value::TNil)
      _hash->remove(key);
    else
      _hash->insert(key, value);
  }

  template <class Container>
  Ref<Iterator> QHashProxyRo<Container>::new_iterator(State *ls)
  {
    if (!_hash)
      QTLUA_THROW(QtLua::QHashProxyRo, "Can not iterate on a null container.");

    return QTLUA_REFNEW(ProxyIterator, ls, *this);
  }

  template <class Container>
  QHashProxyRo<Container>::ProxyIterator::ProxyIterator(State *ls, const Ref<QHashProxyRo> &proxy)
    : _ls(ls),
      _proxy(proxy),
      _it(_proxy->_hash->begin())
  {
  }

  template <class Container>
  bool QHashProxyRo<Container>::ProxyIterator::more() const
  {
    return _proxy->_hash && _it != _proxy->_hash->end();
  }

  template <class Container>
  void QHashProxyRo<Container>::ProxyIterator::next()
  {
    _it++;
  }

  template <class Container>
  Value QHashProxyRo<Container>::ProxyIterator::get_key() const
  {
    return Value(_ls, _it.key());
  }

  template <class Container>
  Value QHashProxyRo<Container>::ProxyIterator::get_value() const
  {
    return Value(_ls, _it.value());
  }

  template <class Container>
  ValueRef QHashProxyRo<Container>::ProxyIterator::get_value_ref()
  {
    return ValueRef(Value(_ls, _proxy), Value(_ls, _it.key()));
  }

  template <typename T>
  void QHashProxyKeytype<T>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += "[]";
    offset--;
  }

  void QHashProxyKeytype<String>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += ".";
  }

  template <class Container>
  void QHashProxyRo<Container>::completion_patch(String &path, String &entry, int &offset)
  {
    QHashProxyKeytype<typename Container::key_type>::completion_patch(path, entry, offset);
  }

  template <class Container>
  String QHashProxyRo<Container>::get_type_name() const
  {
    return type_name<Container>();
  }

}

#endif

