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

#ifndef QTLUADISPATCHPROXY_HXX_
#define QTLUADISPATCHPROXY_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class T>
  unsigned int DispatchProxy::add_target(T *t, Value::Operations mask, bool new_keys)
  {
    _targets.push_back(new Target<T>(t, mask, new_keys)); 
    return _targets.size() - 1;
  }

  template <class T>
  unsigned int DispatchProxy::insert_target(T *t, unsigned int pos,
					    Value::Operations mask, bool new_keys)
  {
    _targets.insert(pos, new Target<T>(t, mask, new_keys)); 
    return pos;
  }

  template <class T>
  void DispatchProxy::remove_target(T *t)
  {
    for (unsigned int i = 0; i < _targets.size(); )
      {
	TargetBase *b = _targets[i];
	if (b->_ud == t && dynamic_cast<Target<T>*>(b))
	  _targets.removeAt(i);
	else
	  i++;
      }
  }

  DispatchProxy::TargetBase::TargetBase(UserData *ud, Value::Operations ops, bool new_keys)
    : _ud(ud)
    , _ops(ops)
    , _new_keys(new_keys)
  {
  }

  DispatchProxy::TargetBase::~TargetBase()
  {
  }

  template <class T>
  DispatchProxy::Target<T>::Target(UserData *ud, Value::Operations ops, bool new_keys)
    : TargetBase(ud, ops, new_keys)
  {
  }

  template <class T>
  Value DispatchProxy::Target<T>::_meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b) const
  {
    return static_cast<T*>(_ud)->T::meta_operation(ls, op, a, b);
  }

  template <class T>
  Value DispatchProxy::Target<T>::_meta_index(State *ls, const Value &key) const
  {
    return static_cast<T*>(_ud)->T::meta_index(ls, key);
  }

  template <class T>
  bool DispatchProxy::Target<T>::_meta_contains(State *ls, const Value &key) const
  {
    return static_cast<T*>(_ud)->T::meta_contains(ls, key);
  }

  template <class T>
  void DispatchProxy::Target<T>::_meta_newindex(State *ls, const Value &key, const Value &value) const
  {
    return static_cast<T*>(_ud)->T::meta_newindex(ls, key, value);
  }

  template <class T>
  Value::List DispatchProxy::Target<T>::_meta_call(State *ls, const Value::List &args) const
  {
    return static_cast<T*>(_ud)->T::meta_call(ls, args);
  }

  template <class T>
  Ref<Iterator> DispatchProxy::Target<T>::_new_iterator(State *ls) const
  {
    return static_cast<T*>(_ud)->T::new_iterator(ls);
  }

  template <class T>
  bool DispatchProxy::Target<T>::_support(enum Value::Operation c) const
  {
    return static_cast<T*>(_ud)->T::support(c);
  }

  DispatchProxy::ProxyIterator::ProxyIterator(State *ls, const DispatchProxy &dp)
    : _state(ls),
      _dp(dp),
      _index(0)
  {
  }

}

#endif

