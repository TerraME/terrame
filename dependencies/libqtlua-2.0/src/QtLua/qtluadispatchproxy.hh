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

#ifndef QTLUADISPATCHPROXY_HH_
#define QTLUADISPATCHPROXY_HH_

#include "qtluauserdata.hh"
#include "qtluaiterator.hh"

namespace QtLua {

  /**
   * @short Expose multiple UserData objects as a single composite object.
   * @header QtLua/DispatchProxy
   * @module {Base}
   *
   * This class may be used to dispatch operations to several
   * underlying @ref UserData objects.
   *
   * This can be used to create a composite object where different
   * operations are handled by different objects. Table operations are
   * handled in a special way which enables to expose table entries
   * from multiple objects as if all entries were merged in a single
   * table object.
   *
   * Order in which underlying objects are added to the dispatcher
   * object matters. See operation functions documentation in this
   * class for a detailed description of the associated behaviors.
   *
   * Please read the @xref{Members detail} section for details
   * about behavior of different operations.
   *
   * @example examples/cpp/proxy/dispatchproxy_string.cc:1|2
   */

class DispatchProxy : public UserData
{

public:
  QTLUA_REFTYPE(DispatchProxy);

  DispatchProxy();
  ~DispatchProxy();

  /** 
   * This function register a new target object which will be used to
   * provide support for some operations. It returns the position of
   * the new entry. The @tt mask parameter can be used to prevent use
   * of this object to provide support for some operations.
   *
   * Template argument may be used to force use of operation functions
   * from a specific class in the @ref UserData inheritance tree. When this
   * feature is used, a reimplementation of the @ref
   * UserData::meta_contains function must be available in the same class
   * if either the @ref UserData::meta_index function or the @ref
   * UserData::meta_newindex function is reimplemented.
   */
  template <class T>
  unsigned int add_target(T *t, Value::Operations mask = Value::OpAll,
			  bool new_keys = true);

  /**
   * This function performs the same way as the @ref add_target
   * function but inserts the new target entry at specified position.
   */
  template <class T>
  unsigned int insert_target(T *t, unsigned int pos = 0,
			     Value::Operations mask = Value::OpAll,
			     bool new_keys = true);

  /**
   * This function removes an entry from target objects list.
   */
  template <class T>
  void remove_target(T *t);

  /** 
   * This function handles the requested operation by relying on the
   * first registered object which @ref UserData::support {supports}
   * the operation and had associated operations enabled when
   * registered with the @ref add_target function.
   */
  Value meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b);

  /** 
   * This function handles the @ref Value::OpIndex operation by
   * querying all registered objects which @ref UserData::support
   * {support} this operation and had this operation enabled when
   * registered with the @ref add_target function.
   */
  Value meta_index(State *ls, const Value &key);

  /**
   * This function handles the @ref Value::OpNewindex operation by
   * writing to the first registered object which @ref
   * UserData::support {supports} this operation and had this operation
   * enabled when registered with the @ref add_target function.
   *
   * If the @tt new_keys argument to the @ref add_target function was
   * @tt false on registration, the associated object is skipped if it
   * does not already contains the passed @tt key (according to object
   * @ref meta_contains function).
   *
   * If a previous object contains an entry for the passed key but only
   * supports the @ref Value::OpIndex table access operation and had
   * this operation enabled when registered, an exception is thrown
   * before the call to @ref meta_newindex is forwarded. This avoids
   * shadowing a table entry.
   */
  void meta_newindex(State *ls, const Value &key, const Value &value);

  /** 
   * This function queries all registered object which @ref
   * UserData::support {support} the @ref Value::OpIndex or @ref
   * Value::OpNewindex operations and had one of these operations
   * enabled when registered with the @ref add_target function.
   */
  bool meta_contains(State *ls, const Value &key);

  /** 
   * This function handles the @ref Value::OpCall operation by relying
   * on the first registered object which @ref UserData::support
   * {supports} this operation and had this operation enabled when
   * registered with the @ref add_target function.
   */
  Value::List meta_call(State *ls, const Value::List &args);

  /**
   * This function handles the @ref Value::OpIterate operation by
   * relying on all registered objects which @ref UserData::support
   * {support} this operation and had this operation enabled when
   * registered with the @ref add_target function. Iterators for
   * underlying objects are created in registration order to expose
   * all entries.
   */
  Ref<Iterator> new_iterator(State *ls);

  /**
   * This function check if one of the underlying objects can handle
   * the specified operation and had this operation enabled when
   * registered with the @ref add_target function.
   */
  bool support(enum Value::Operation c) const;

private:

  struct TargetBase
  {
    inline TargetBase(UserData *ud, Value::Operations ops, bool new_keys);
    virtual inline ~TargetBase();

    virtual Value _meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b) const = 0;
    virtual Value _meta_index(State *ls, const Value &key) const = 0;
    virtual bool _meta_contains(State *ls, const Value &key) const = 0;
    virtual void _meta_newindex(State *ls, const Value &key, const Value &value) const = 0;
    virtual Value::List _meta_call(State *ls, const Value::List &args) const = 0;
    virtual Ref<Iterator> _new_iterator(State *ls) const = 0;
    virtual bool _support(enum Value::Operation c) const = 0;

    UserData *        _ud;
    Value::Operations _ops;
    bool              _new_keys;
  };

  template <class T>
  struct Target : public TargetBase
  {
    inline Target(UserData *ud, Value::Operations ops, bool new_keys);

    /** @override */
    Value _meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b) const;
    /** @override */
    Value _meta_index(State *ls, const Value &key) const;
    /** @override */
    bool _meta_contains(State *ls, const Value &key) const;
    /** @override */
    void _meta_newindex(State *ls, const Value &key, const Value &value) const;
    /** @override */
    Value::List _meta_call(State *ls, const Value::List &args) const;
    /** @override */
    Ref<Iterator> _new_iterator(State *ls) const;
    /** @override */
    bool _support(enum Value::Operation c) const;
  };

  class ProxyIterator : public Iterator
  {
    friend class DispatchProxy;

    inline ProxyIterator(State *ls, const DispatchProxy &dp);

    bool _more();
    bool more() const;
    void next();
    Value get_key() const;
    Value get_value() const;
    ValueRef get_value_ref();

    QPointer<State> _state;
    const DispatchProxy &_dp;
    int _index;
    Ref<Iterator> _cur;
  };

  friend class ProxyIterator;

  QList<TargetBase*> _targets;

};

}

#endif

