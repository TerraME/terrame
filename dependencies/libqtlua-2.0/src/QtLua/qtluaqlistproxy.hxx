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

#ifndef QTLUAQLISTPROXY_HXX_
#define QTLUAQLISTPROXY_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class Container>
  QListProxyRo<Container>::QListProxyRo()
    : _list(0)
  {
  }

  template <class Container>
  QListProxyRo<Container>::QListProxyRo(Container &list)
    : _list(&list)
  {
  }

  template <class Container>
  QListProxy<Container>::QListProxy()
    : QListProxyRo<Container>()
  {
  }

  template <class Container>
  QListProxy<Container>::QListProxy(Container &list)
    : QListProxyRo<Container>(list)
  {
  }

  template <class Container>
  void QListProxyRo<Container>::set_container(Container *list)
  {
    _list = list;
  }

  template <class Container>
  Value QListProxyRo<Container>::meta_index(State *ls, const Value &key)
  {
    if (!_list)
      return Value(ls);

    int index = (unsigned int)key.to_number() - 1;

    if (index >= 0 && index < _list->size())
      return Value(ls, _list->at(index));
    else
      return Value(ls);
  }

  template <class Container>
  bool QListProxyRo<Container>::meta_contains(State *ls, const Value &key)
  {
    try {
      int index = (unsigned int)key.to_number() - 1;

      return index >= 0 && index < _list->size();
    } catch (String &e) {
      return false;
    }
  }

  template <class Container>
  Value QListProxyRo<Container>::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
  {
    switch (op)
      {
      case Value::OpLen:
	return Value(ls, _list ? _list->size() : 0);
      case Value::OpUnm:
	return _list ? Value(ls, *_list) : Value(ls);
      default:
	return UserData::meta_operation(ls, op, a, b);
      }
  }

  template <class Container>
  bool QListProxyRo<Container>::support(Value::Operation c) const
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
  bool QListProxy<Container>::support(enum Value::Operation c)
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
  String QListProxyRo<Container>::get_type_name() const
  {
    return type_name<Container>();
  }

  template <class Container>
  void QListProxyRo<Container>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += "[]";
    offset--;
  }

  template <class Container>
  void QListProxy<Container>::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    if (!_list)
      QTLUA_THROW(QtLua::QListProxy, "Can not index a null container.");

    unsigned int index = (unsigned int)key.to_number() - 1;

    if (index > (unsigned int)_list->size())
      QTLUA_THROW(QtLua::QListProxy, "Index % is out of bounds.", .arg(index));

    if (value.type() == Value::TNil)
      {
	if (index < (unsigned int)_list->size())
	  _list->removeAt(index);
      }
    else
      {
	if (index == (unsigned int)_list->size())
	  _list->insert(index, value);
	else
	  (*_list)[index] = value;
      }
  }

  template <class Container>
  Ref<Iterator> QListProxyRo<Container>::new_iterator(State *ls)
  {
    if (!_list)
      QTLUA_THROW(QtLua::QListProxyRo, "Can not iterate on a null container.");

    return QTLUA_REFNEW(ProxyIterator, ls, *this);
  }

  template <class Container>
  QListProxyRo<Container>::ProxyIterator::ProxyIterator(State *ls, const Ref<QListProxyRo> &proxy)
    : _ls(ls),
      _proxy(proxy),
      _it(_proxy->_list->begin()),
      _i(1)
  {
  }

  template <class Container>
  bool QListProxyRo<Container>::ProxyIterator::more() const
  {
    return _proxy->_list && _it != _proxy->_list->end();
  }

  template <class Container>
  void QListProxyRo<Container>::ProxyIterator::next()
  {
    _it++;
    _i++;
  }

  template <class Container>
  Value QListProxyRo<Container>::ProxyIterator::get_key() const
  {
    return Value(_ls, (int)_i);
  }

  template <class Container>
  Value QListProxyRo<Container>::ProxyIterator::get_value() const
  {
    return Value(_ls, *_it);
  }

  template <class Container>
  ValueRef QListProxyRo<Container>::ProxyIterator::get_value_ref()
  {
    return ValueRef(Value(_ls, _proxy), Value(_ls, (double)_i));
  }

}

#endif

