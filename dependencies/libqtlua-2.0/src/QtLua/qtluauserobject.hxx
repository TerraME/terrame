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


#ifndef QTLUAUSEROBJECT_HXX_
#define QTLUAUSEROBJECT_HXX_

#include "qtluauserdata.hxx"
#include "qtluaiterator.hxx"

namespace QtLua {

  template <class T>
  UserObject<T>::UserObject()
  {
    _obj = static_cast<T*>(this);
  }

  template <class T>
  UserObject<T>::UserObject(T *obj)
  {
    _obj = obj;
  }

  template <class T>
  int UserObject<T>::get_entry(const String &name)
  {
    for (size_t i = 0; T::_qtlua_properties_table[i].name; i++)
      if (name == T::_qtlua_properties_table[i].name)
	return i;
    QTLUA_THROW(QtLua::UserObject, "No such property `%::%'.",
		.arg(UserData::type_name<T>()).arg(name));
  }

  template <class T>
  Value UserObject<T>::meta_index(State *ls, const Value &key)
  {
    String name = key.to_string();
    int index = get_entry(name);

    if (!T::_qtlua_properties_table[index].get)
      QTLUA_THROW(QtLua::UserObject, "The `%::%' property is write only.",
		  .arg(UserData::type_name<T>()).arg(name));

    return (_obj->*T::_qtlua_properties_table[index].get)(ls);
  }

  template <class T>
  bool UserObject<T>::meta_contains(State *ls, const Value &key)
  {
    try {
      get_entry(key.to_string());
      return true;
    } catch (String &e) {
      return false;
    }
  }

  template <class T>
  void UserObject<T>::meta_newindex(State *ls, const Value &key, const Value &value)
  {
    String name = key.to_string();
    int index = get_entry(name);

    if (!T::_qtlua_properties_table[index].set)
      QTLUA_THROW(QtLua::UserObject, "The `%::%' property is read only.",
		  .arg(UserData::type_name<T>())
		  .arg(T::_qtlua_properties_table[index].name));
    
    (_obj->*T::_qtlua_properties_table[index].set)(ls, value);
  }

  template <class T>
  Ref<Iterator> UserObject<T>::new_iterator(State *ls)
  {
    return QTLUA_REFNEW(UserObjectIterator, ls, *this);
  }

  template <class T>
  bool UserObject<T>::support(Value::Operation c) const
  {
    switch (c)
      {
      case Value::OpIndex:
      case Value::OpNewindex:
      case Value::OpIterate:
	return true;
      default:
	return false;
      }
  }

  template <class T>
  void UserObject<T>::completion_patch(String &path, String &entry, int &offset)
  {
    entry += ".";
  }

  template <class T>
  UserObject<T>::UserObjectIterator::UserObjectIterator(State *ls, const Ref<UserObject<T> > &obj)
    : _ls(ls),
      _obj(obj),
      _index(0)
  {
  }

  template <class T>
  bool UserObject<T>::UserObjectIterator::more() const
  {
    return T::_qtlua_properties_table[_index].name != 0;
  }

  template <class T>
  void UserObject<T>::UserObjectIterator::next()
  {
    _index++;
  }

  template <class T>
  Value UserObject<T>::UserObjectIterator::get_key() const
  {
    return Value(_ls, T::_qtlua_properties_table[_index].name);
  }

  template <class T>
  Value UserObject<T>::UserObjectIterator::get_value() const
  {
    if (!T::_qtlua_properties_table[_index].get)
      QTLUA_THROW(QtLua::UserObject, "The `%::%' property is write only.",
		  .arg(UserData::type_name<T>()).arg(T::_qtlua_properties_table[_index].name));

    if (!_ls)
      return QtLua::Value(_ls);

    return (_obj->_obj->*T::_qtlua_properties_table[_index].get)(_ls);
  }

  template <class T>
  ValueRef UserObject<T>::UserObjectIterator::get_value_ref()
  {
    return ValueRef(Value(_ls, *_obj->_obj),
		    Value(_ls, T::_qtlua_properties_table[_index].name));
  }

}

#endif

