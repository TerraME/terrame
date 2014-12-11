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

    Copyright (C) 2012, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef QTLUAARRAYPROXY_HXX_
#define QTLUAARRAYPROXY_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class T>
  ArrayProxyRo<T>::ArrayProxyRo()
    : _array(0)
  {
  }

  template <class T>
  ArrayProxyRo<T>::ArrayProxyRo(const T *array, unsigned int size)
    : _array(array),
      _size(size)
  {
  }

  template <class T>
  ArrayProxy<T>::ArrayProxy()
    : ArrayProxyRo<T>()
  {
  }

  template <class T>
  ArrayProxy<T>::ArrayProxy(T *array, unsigned int size)
    : ArrayProxyRo<T>(array, size)
  {
  }

  template <class T>
  void ArrayProxyRo<T>::set_container(const T *array, unsigned int size)
  {
    _array = array;
    _size = size;
  }

  template <class T>
  void ArrayProxy<T>::set_container(T *array, unsigned int size)
  {
    _array = array;
    _size = size;
  }

  template <class T>
  Value ArrayProxyRo<T>::meta_index(State *ls, const Value &key)
  { 
    if (!_array)
      return Value(ls);

    unsigned int index = (unsigned int)key.to_number() - 1;

    if (index < _size)
      return Value(ls, _array[index]);
    else
      return Value(ls);
  }

  template <class T>
  bool ArrayProxyRo<T>::meta_contains(State *ls, const Value &key)
  {
    try {
      unsigned int index = (unsigned int)key.to_number() - 1;

      return index < _size;
    } catch (String &e) {
      return false;
    }
  }

  template <class T>
  Value ArrayProxyRo<T>::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
  {
    switch (op)
      {
      case Value::OpLen:
	return Value(ls, _array ? _size : 0);
      case Value::OpUnm:
	return _array ? Value(ls, _size, _array) : Value(ls);
      default:
	return UserData::meta_operation(ls, op, a, b);
      }
  }

  template <class T>
  bool ArrayProxyRo<T>::support(Value::Operation c) const
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

  template <class T>
  bool ArrayProxy<T>::support(enum Value::Operation c)
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

  template <class T>
  String ArrayProxyRo<T>::get_type_name() const
  {
    return type_name<T>() + "[" + String::number(_size) + "]";
  }

  template <class T>
  void ArrayProxy<T>::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    if (!_array)
      QTLUA_THROW(QtLua::ArrayProxy, "Can not index a null array.");

    unsigned int index = (unsigned int)key.to_number() - 1;

    if (index >= _size)
      QTLUA_THROW(QtLua::ArrayProxy, "Array index `%' is out of bounds.", .arg(index));

    const_cast<T*>(_array)[index] = value;
  }

  template <class T>
  Ref<Iterator> ArrayProxyRo<T>::new_iterator(State *ls)
  {
    if (!_array)
      QTLUA_THROW(QtLua::ArrayProxy, "Can not iterate on a null array.");

    return QTLUA_REFNEW(ProxyIterator, ls, *this);
  }

  template <class T>
  ArrayProxyRo<T>::ProxyIterator::ProxyIterator(State *ls, const Ref<ArrayProxyRo> &proxy)
    : _ls(ls),
      _proxy(proxy),
      _it(0)
  {
  }

  template <class T>
  bool ArrayProxyRo<T>::ProxyIterator::more() const
  {
    return _proxy->_array && _it < (unsigned int)_proxy->_size;
  }

  template <class T>
  void ArrayProxyRo<T>::ProxyIterator::next()
  {
    _it++;
  }

  template <class T>
  Value ArrayProxyRo<T>::ProxyIterator::get_key() const
  {
    return Value(_ls, (int)_it + 1);
  }

  template <class T>
  Value ArrayProxyRo<T>::ProxyIterator::get_value() const
  {
    return Value(_ls, _proxy->_array[_it]);
  }

  template <class T>
  ValueRef ArrayProxyRo<T>::ProxyIterator::get_value_ref()
  {
    return ValueRef(Value(_ls, _proxy), Value(_ls, (double)_it + 1));
  }

  template <class T>
  void ArrayProxyRo<T>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += "[]";
    offset--;
  }

}

#endif

