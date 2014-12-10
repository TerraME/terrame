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

#ifndef QTLUAQVECTORPROXY_HXX_
#define QTLUAQVECTORPROXY_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class Container, unsigned max_resize, unsigned min_resize>
  QVectorProxyRo<Container, max_resize, min_resize>::QVectorProxyRo()
    : _vector(0)
  {
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  QVectorProxyRo<Container, max_resize, min_resize>::QVectorProxyRo(Container &vector)
    : _vector(&vector)
  {
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  QVectorProxy<Container, max_resize, min_resize>::QVectorProxy()
    : QVectorProxyRo<Container, max_resize, min_resize>()
  {
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  QVectorProxy<Container, max_resize, min_resize>::QVectorProxy(Container &vector)
    : QVectorProxyRo<Container, max_resize, min_resize>(vector)
  {
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  void QVectorProxyRo<Container, max_resize, min_resize>::set_container(Container *vector)
  {
    _vector = vector;
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  Value QVectorProxyRo<Container, max_resize, min_resize>::meta_index(State *ls, const Value &key)
  { 
    if (!_vector)
      return Value(ls);

    int index = (unsigned int)key.to_number() - 1;

    if (index >= 0 && index < _vector->size())
      return Value(ls, _vector->at(index));
    else
      return Value(ls);
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  bool QVectorProxyRo<Container, max_resize, min_resize>::meta_contains(State *ls, const Value &key)
  {
    try {
      int index = (unsigned int)key.to_number() - 1;

      return index >= 0 && index < _vector->size();
    } catch (String &e) {
      return false;
    }
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  Value QVectorProxyRo<Container, max_resize, min_resize>::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
  {
    switch (op)
      {
      case Value::OpLen:
	return Value(ls, _vector ? _vector->size() : 0);
      case Value::OpUnm:
	return _vector ? Value(ls, *_vector) : Value(ls);
      default:
	return UserData::meta_operation(ls, op, a, b);
      }
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  bool QVectorProxyRo<Container, max_resize, min_resize>::support(Value::Operation c) const
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

  template <class Container, unsigned max_resize, unsigned min_resize>
  bool QVectorProxy<Container, max_resize, min_resize>::support(enum Value::Operation c)
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

  template <class Container, unsigned max_resize, unsigned min_resize>
  String QVectorProxyRo<Container, max_resize, min_resize>::get_type_name() const
  {
    return type_name<Container>();
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  void QVectorProxyRo<Container, max_resize, min_resize>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += "[]";
    offset--;
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  void QVectorProxy<Container, max_resize, min_resize>::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    if (!_vector)
      QTLUA_THROW(QtLua::QVectorProxy, "Can not write to a null vector.");

    bool has_resize = max_resize > min_resize;
    int index = (unsigned int)key.to_number() - 1;

    if (index < 0)
      goto oob;

    if (has_resize && value.type() == Value::TNil)
      {
	if (index < min_resize)
	  QTLUA_THROW(QtLua::QVectorProxy, "Can not reduce vector size below %.", .arg((int)min_resize));
	if (index < _vector->size())
	  _vector->resize(index);
      }
    else
      {
	if (index >= _vector->size())
	  {
	    if (has_resize)
	      {
		if ((unsigned int)index >= max_resize)
		  QTLUA_THROW(QtLua::QVectorProxy, "Can not increase vector size above %.", .arg((int)max_resize));
		_vector->resize(index + 1);
	      }
	    else
	      goto oob;
	  }
	(*_vector)[index] = value;
      }

    return;
  oob:
    QTLUA_THROW(QtLua::QVectorProxy, "Index `%' is out of bounds.", .arg(index));
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  Ref<Iterator> QVectorProxyRo<Container, max_resize, min_resize>::new_iterator(State *ls)
  {
    if (!_vector)
      QTLUA_THROW(QtLua::QVectorProxy, "Can not iterate on a null vector.");

    return QTLUA_REFNEW(ProxyIterator, ls, *this);
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::ProxyIterator(State *ls, const Ref<QVectorProxyRo> &proxy)
    : _ls(ls),
      _proxy(proxy),
      _it(0)
  {
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  bool QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::more() const
  {
    return _proxy->_vector && _it < (unsigned int)_proxy->_vector->size();
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  void QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::next()
  {
    _it++;
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  Value QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::get_key() const
  {
    return Value(_ls, (int)_it + 1);
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  Value QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::get_value() const
  {
    return Value(_ls, _proxy->_vector->at(_it));
  }

  template <class Container, unsigned max_resize, unsigned min_resize>
  ValueRef QVectorProxyRo<Container, max_resize, min_resize>::ProxyIterator::get_value_ref()
  {
    return ValueRef(Value(_ls, _proxy), Value(_ls, (double)_it + 1));
  }

}

#endif

