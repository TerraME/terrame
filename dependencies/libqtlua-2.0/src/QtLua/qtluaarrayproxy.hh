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

#ifndef QTLUAARRAYPROXY_HH_
#define QTLUAARRAYPROXY_HH_

#include <QPointer>

#include "qtluauserdata.hh"
#include "qtluaiterator.hh"

namespace QtLua {

  /**
   * @short C array read only access wrapper for lua script
   * @header QtLua/ArrayProxy
   * @module {Container proxies}
   *
   * This template class may be used to expose a C array to lua script
   * for read access. The @ref ArrayProxy class may be used for
   * read/write access.
   *
   * See @ref ArrayProxy class documentation for details and examples.
   */

template <class T>
class ArrayProxyRo : public UserData
{
public:
  QTLUA_REFTYPE(ArrayProxyRo);

  /** Create a @ref ArrayProxy object with no attached array */
  ArrayProxyRo();
  /** Create a @ref ArrayProxy object and attach given array */
  ArrayProxyRo(const T *array, unsigned int size);

  /** Attach or detach container. argument may be NULL */
  void set_container(const T *array, unsigned int size);

  Value meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b);
  Value meta_index(State *ls, const Value &key);
  bool meta_contains(State *ls, const Value &key);
  Ref<Iterator> new_iterator(State *ls);
  bool support(Value::Operation c) const;

private:
  void completion_patch(String &path, String &entry, int &offset);
  String get_type_name() const;

  /**
   * @short ArrayProxyRo iterator class
   * @internal
   */
  class ProxyIterator : public Iterator
  {
  public:
    QTLUA_REFTYPE(ProxyIterator);
    ProxyIterator(State *ls, const Ref<ArrayProxyRo> &proxy);

  private:
    bool more() const;
    void next();
    Value get_key() const;
    Value get_value() const;
    ValueRef get_value_ref();

    QPointer<State> _ls;
    Ref<ArrayProxyRo> _proxy;
    unsigned int _it;
  };

protected:
  const T *_array;
  unsigned int _size;
};

  /**
   * @short C array access wrapper for lua script
   * @header QtLua/ArrayProxy
   * @module {Container proxies}
   *
   * This template class may be used to expose a C array to lua script
   * for read and write access. The @ref ArrayProxyRo class may be
   * used for read only access.
   *
   * Arrays may be attached and detached from the wrapper object
   * to solve cases where we want to destroy the array when lua
   * still holds references to the wrapper object. When no container
   * is attached access will raise an exception.
   *
   * First entry has index 1. Lua @tt nil value is returned if index
   * is above array size.
   *
   * Lua operator @tt # returns the array size. Lua
   * operator @tt - returns a lua table copy of the container.
   *
   * The following example show how anarray can be
   * accessed from both C++ and lua script directly:
   *
   * @example examples/cpp/proxy/arrayproxy_string.cc:1|2|3
   */

template <class T>
class ArrayProxy : public ArrayProxyRo<T>
{
  using ArrayProxyRo<T>::_array;
  using ArrayProxyRo<T>::_size;

public:
  QTLUA_REFTYPE(ArrayProxy);

  /** Create a @ref ArrayProxy object */
  ArrayProxy();
  /** Create a @ref ArrayProxy object */
  ArrayProxy(T *array, unsigned int size);

  /** Attach or detach associated array. argument may be NULL */
  void set_container(T *array, unsigned int size);

  void meta_newindex(State *ls, const Value &key, const Value &value);
  bool support(enum Value::Operation c);
};

}

#endif

