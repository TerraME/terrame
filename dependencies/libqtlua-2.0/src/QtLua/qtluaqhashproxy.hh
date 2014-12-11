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

#ifndef QTLUAQHASHPROXY_HH_
#define QTLUAQHASHPROXY_HH_

#include <QPointer>

#include "qtluauserdata.hh"
#include "qtluaiterator.hh"

namespace QtLua {

  /** @module {Container proxies} @internal */
  template <typename T>
  struct QHashProxyKeytype
  {
    static inline void completion_patch(String &path, String &entry, int &offset);
  };

  /** @module {Container proxies} @internal */
  template <>
  struct QHashProxyKeytype<String>
  {
    static inline void completion_patch(String &path, String &entry, int &offset);
  };

  /**
   * @short QHash and QMap read only access wrapper for lua script
   * @header QtLua/QHashProxy
   * @module {Container proxies}
   *
   * This template class may be used to expose an attached @ref QHash
   * or @ref QMap container object to lua script for read access. The
   * @ref QHashProxy class may be used for read/write access.
   *
   * See @ref QHashProxy class documentation for details and examples.
   */

template <class Container>
class QHashProxyRo : public UserData
{
public:
  QTLUA_REFTYPE(QHashProxyRo);

  /** Create a @ref QHashProxy object with no attached container */
  QHashProxyRo();
  /** Create a @ref QHashProxy object and attach given container */
  QHashProxyRo(Container &hash);

  /** Attach or detach container. argument may be NULL */
  void set_container(Container *hash);

  Value meta_index(State *ls, const Value &key);
  bool meta_contains(State *ls, const Value &key);
  Ref<Iterator> new_iterator(State *ls);
  Value meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b);
  bool support(Value::Operation c) const;

private:
  void completion_patch(String &path, String &entry, int &offset);
  String get_type_name() const;

  /**
   * @short QHashProxyRo iterator class
   * @internal
   */
  class ProxyIterator : public Iterator
  {
  public:
    QTLUA_REFTYPE(ProxyIterator);
    ProxyIterator(State *ls, const Ref<QHashProxyRo> &proxy);

  private:
    bool more() const;
    void next();
    Value get_key() const;
    Value get_value() const;
    ValueRef get_value_ref();

    QPointer<State> _ls;
    Ref<QHashProxyRo> _proxy;
    typename Container::iterator _it;
  };

protected:
  /** @internal */
  Container *_hash;
};

  /**
   * @short QHash and QMap access wrapper for lua script
   * @header QtLua/QHashProxy
   * @module {Container proxies}
   *
   * This template class may be used to expose an attached @ref QHash
   * or @ref QMap container object to lua script for read and write
   * access. The @ref QHashProxyRo class may be used for read only
   * access.
   *
   * Containers may be attached and detached from the wrapper object
   * to solve cases where we want to destroy the container when lua
   * still holds references to the wrapper object. When no container
   * is attached access will raise an error.
   *
   * Lua @tt nil value is returned if no such entry exists on table
   * read. A @tt nil value write will delete entry at access index.
   *
   * Lua operator @tt # returns the container entry count. Lua
   * operator @tt - returns a lua table copy of the container.
   *
   * The following example show how a @ref QMap object indexed with
   * @ref String objects can be accessed from both C++ and lua script
   * directly:
   *
   * @example examples/cpp/proxy/qmapproxy_string.cc:1|2|3
   */

template <class Container>
class QHashProxy : public QHashProxyRo<Container>
{
  using QHashProxyRo<Container>::_hash;

public:
  QTLUA_REFTYPE(QHashProxy);

  /** Create a @ref QHashProxy object */
  QHashProxy();
  /** Create a @ref QHashProxy object */
  QHashProxy(Container &hash);

  void meta_newindex(State *ls, const Value &key, const Value &value);
  bool support(enum Value::Operation c);
};

}

#endif

