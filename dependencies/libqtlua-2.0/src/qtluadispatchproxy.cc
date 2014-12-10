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

#include <cstdarg>

#include <QtLua/DispatchProxy>

namespace QtLua {

  DispatchProxy::DispatchProxy()
  {
  }

  DispatchProxy::~DispatchProxy()
  {
    foreach(TargetBase *t, _targets)
      delete t;
  }

  Value DispatchProxy::meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b)
  {
    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & op) && t->_support(op))
	  return t->_meta_operation(ls, op, a, b);
      }

    return UserData::meta_operation(ls, op, a, b);
  }

  Value DispatchProxy::meta_index(State *ls, const Value &key)
  {
    bool supported = false;

    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & Value::OpIndex) && t->_support(Value::OpIndex))
	  {
	    supported = true;

	    if (t->_meta_contains(ls, key))
	      return t->_meta_index(ls, key);
	  }
      }

    return supported ? Value(ls) : UserData::meta_index(ls, key);
  }

  void DispatchProxy::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    bool shadow = false;

    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & Value::OpNewindex) && t->_support(Value::OpNewindex))
	  {
	    bool c = t->_meta_contains(ls, key);

	    if (t->_new_keys || c)
	      {
		if (!c && shadow)
		  QTLUA_THROW(QtLua::DispatchProxy, "Can not write to the `%' read-only index.",
			      .arg(key.to_string_p(false)));

		return t->_meta_newindex(ls, key, value);
	      }
	  }
	else if ((t->_ops & Value::OpIndex) && t->_support(Value::OpIndex))
	  {
	    if (t->_meta_contains(ls, key))
	      shadow = true;
	  }
      }

    return UserData::meta_newindex(ls, key, value);
  }

  bool DispatchProxy::meta_contains(State *ls, const Value &key)
  {
    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & (Value::OpIndex | Value::OpNewindex)) &&
	    (t->_support(Value::OpIndex) || t->_support(Value::OpNewindex)) && 
	    t->_meta_contains(ls, key))
	  return true;
      }

    return false;
  }

  Value::List DispatchProxy::meta_call(State *ls, const Value::List &args)
  {
    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & Value::OpCall) && t->_support(Value::OpCall))
	  return t->_meta_call(ls, args);
      }

    return UserData::meta_call(ls, args);
  }

  Ref<Iterator> DispatchProxy::new_iterator(State *ls)
  {
    return QTLUA_REFNEW(ProxyIterator, ls, *this);
  }

  bool DispatchProxy::support(enum Value::Operation c) const
  {
    foreach (const TargetBase *t, _targets)
      {
	if ((t->_ops & c) && t->_support(c))
	  return true;
      }

    return false;
  }

  bool DispatchProxy::ProxyIterator::_more()
  {
    while (1)
      {
	for (; !_cur.valid(); _index++)
	  {
	    if (_index == _dp._targets.size())
	      return false;

	    if (!_dp._targets[_index]->_support(Value::OpIterate))
	      continue;

	    _cur = _dp._targets[_index]->_new_iterator(_state);
	  }

	if (_cur->more())
	  return true;

	_cur = Iterator::ptr();
      }
  }

  bool DispatchProxy::ProxyIterator::more() const
  {
    if (!_state)
      return false;

    return const_cast<ProxyIterator*>(this)->_more();
  }

  void DispatchProxy::ProxyIterator::next()
  {
    assert(_cur.valid());
    _cur->next();
  }

  Value DispatchProxy::ProxyIterator::get_key() const
  {
    return _cur->get_key();
  }

  Value DispatchProxy::ProxyIterator::get_value() const
  {
    return _cur->get_value();
  }

  ValueRef DispatchProxy::ProxyIterator::get_value_ref()
  {
    return _cur->get_value_ref();
  }

}

