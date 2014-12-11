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


#ifndef QTLUAVALUEBASE_HXX_
#define QTLUAVALUEBASE_HXX_

#include <typeinfo>

#include "qtluastring.hxx"

#include "Iterator"
#include "ValueRef"
#include "String"
#include "UserData"

namespace QtLua {

  ValueBase::ValueBase(const State *ls)
    : _st(const_cast<State*>(ls))
  {
  }

  ValueBase::~ValueBase()
  {
  }

  template <typename ListContainer>
  ListContainer ValueBase::to_list() const
  {
    ListContainer result;

    for (int i = 1; ; i++)
      {
	Value v(at(i));
	if (v.is_nil())
	  break;
	result.push_back(v);
      }

    return result;
  }

  ValueBase::operator Value() const
  {
    return value();
  }

  template <typename X>
  QList<X> ValueBase::to_qlist() const
  {
    return to_list<QList<X> >();
  }

  template <typename X>
  ValueBase::operator QList<X> () const
  {
    return to_qlist<X>();
  }

  template <typename X>
  QVector<X> ValueBase::to_qvector() const
  {
    return to_list<QVector<X> >();
  }

  template <typename X>
  ValueBase::operator QVector<X> () const
  {
    return to_qvector<X>();
  }

  template <typename HashContainer>
  HashContainer ValueBase::to_hash() const
  {
    HashContainer result;
    for (ValueBase::const_iterator i = begin(); i != end(); i++)
      result[i.key()] = i.value();
    return result;
  }

  template <typename Key, typename Val>
  QHash<Key, Val> ValueBase::to_qhash() const
  {
    return to_hash<QHash<Key, Val> >();
  }

  template <typename Key, typename Val>
  ValueBase::operator QHash<Key, Val> () const
  {
    return to_qhash<Key, Val>();
  }

  template <typename Key, typename Val>
  QMap<Key, Val> ValueBase::to_qmap() const
  {
    return to_hash<QMap<Key, Val> >();
  }

  template <typename Key, typename Val>
  ValueBase::operator QMap<Key, Val> () const
  {
    return to_qmap<Key, Val>();
  }

  bool ValueBase::is_nil() const
  {
    return type() == TNil;
  }

  ValueBase::operator String () const
  {
    return to_string();
  }

  ValueBase::operator QString () const
  {
    return to_string().to_qstring();
  }

  QString ValueBase::to_qstring() const
  {
    return to_string().to_qstring();
  }

  ValueBase::operator double () const
  {
    return to_number();
  }

  ValueBase::operator float () const
  {
    return to_number();
  }

  ValueBase::operator signed char () const
  {
    return (signed char)to_number();
  }

  ValueBase::operator unsigned char () const
  {
    return (unsigned char)to_number();
  }

  ValueBase::operator signed short () const
  {
    return (signed short)to_number();
  }

  ValueBase::operator unsigned short () const
  {
    return (unsigned short)to_number();
  }

  ValueBase::operator signed int () const
  {
    return (signed int)to_number();
  }

  ValueBase::operator unsigned int () const
  {
    return (unsigned int)to_number();
  }

  ValueBase::operator signed long () const
  {
    return (signed long)to_number();
  }

  ValueBase::operator unsigned long () const
  {
    return (unsigned long)to_number();
  }

  ValueBase::operator Bool () const
  {
    return to_boolean();
  }

  ValueBase::List::List(const QList<Value> &list)
    : QList<Value>(list)
  {
  }

  ValueBase::operator QVariant () const
  {
    return to_qvariant();
  }

  template <typename X>
  ValueBase::List::List(const State *ls, const typename QList<X>::const_iterator &begin,
		    const typename QList<X>::const_iterator &end)
  {
    for (typename QList<X>::const_iterator i = begin; i != end; i++)
      push_back(Value(ls, *i));
  }

  template <typename X>
  ValueBase::List::List(const State *ls, const QList<X> &list)
  {
    foreach(const X &i, list)
      push_back(Value(ls, i));
  }

  template <typename X>
  QList<X> ValueBase::List::to_qlist(const const_iterator &begin, const const_iterator &end)
  {
    QList<X> res;
    for (const_iterator i = begin; i != end; i++)
      res.push_back(*i);
    return res;
  }

  template <typename X>
  QList<X> ValueBase::List::to_qlist() const
  {
    return to_qlist<X>(constBegin(), constEnd());
  }

  /** return a lua table containing values from list */
  Value ValueBase::List::to_table(const State *ls, const const_iterator &begin, const const_iterator &end)
  {
    Value res(Value::new_table(ls));
    int j = 1;
    for (const_iterator i = begin; i != end; i++)
      res[j++] = *i;
    return res;
  }

  Value ValueBase::List::to_table(const State *ls) const
  {
    return to_table(ls, constBegin(), constEnd());
  }

  ValueBase::List::List()
  {
  }

  ValueBase::List::List(const List &vl)
    : QList<Value>(vl)
  {
  }

  ValueBase::List::List(const Value &v1)
  {
    *this << v1;
  }

  ValueBase::List::List(const Value &v1, const Value &v2)
  {
    *this << v1 << v2;
  }

  ValueBase::List::List(const Value &v1, const Value &v2, const Value &v3)
  {
    *this << v1 << v2 << v3;
  }

  ValueBase::List::List(const Value &v1, const Value &v2, const Value &v3, const Value &v4)
  {
    *this << v1 << v2 << v3 << v4;
  }

  ValueBase::List::List(const Value &v1, const Value &v2, const Value &v3, const Value &v4, const Value &v5)
  {
    *this << v1 << v2 << v3 << v4 << v5;
  }

  ValueBase::List::List(const Value &v1, const Value &v2, const Value &v3, const Value &v4, const Value &v5, const Value &v6)
  {
    *this << v1 << v2 << v3 << v4 << v5 << v6;
  }

  ValueBase::List ValueBase::operator() () const
  {
    return this->call(List());
  }

  ValueBase::List ValueBase::operator() (const Value &arg1) const
  {
    List args;
    args << arg1;
    return this->call(args);
  }

  ValueBase::List ValueBase::operator() (const Value &arg1, const Value &arg2) const
  {
    List args;
    args << arg1 << arg2;
    return this->call(args);
  }

  ValueBase::List ValueBase::operator() (const Value &arg1, const Value &arg2, const Value &arg3) const
  {
    List args;
    args << arg1 << arg2 << arg3;
    return this->call(args);
  }

  ValueBase::List ValueBase::operator() (const Value &arg1, const Value &arg2, const Value &arg3,
				 const Value &arg4) const
  {
    List args;
    args << arg1 << arg2 << arg3 << arg4;
    return this->call(args);
  }

  ValueBase::List ValueBase::operator() (const Value &arg1, const Value &arg2, const Value &arg3,
				 const Value &arg4, const Value &arg5) const
  {
    List args;
    args << arg1 << arg2 << arg3 << arg4 << arg5;
    return this->call(args);
  }

  ValueBase::List ValueBase::operator() (const Value &arg1, const Value &arg2, const Value &arg3,
				 const Value &arg4, const Value &arg5, const Value &arg6) const
  {
    List args;
    args << arg1 << arg2 << arg3 << arg4 << arg5 << arg6;
    return this->call(args);
  }

  template <typename T>
  Value ValueBase::at(const T &key) const
  {
    return at(Value(_st, key));
  }

#if 1
  Value ValueBase::operator[](const Value &key) const
  {
    return at(key);
  }

  template <typename T>
  Value ValueBase::operator[] (const T &key) const
  {
    return at(Value(_st, key));
  }
#endif

  ValueRef ValueBase::operator[] (const Value &key)
  {
    return ValueRef(value(), key);
  }

  template <typename T>
  ValueRef ValueBase::operator[] (const T &key)
  {
    return value()[Value(_st, key)];
  }

  inline int ValueBase::to_integer() const
  {
    return (int)to_number();
  }

  template <class X>
  inline X *ValueBase::to_qobject_cast() const
  {
    X *p = dynamic_cast<X*>(to_qobject());
    if(!p)
      QTLUA_THROW(QtLua::ValueBase, "Can not cast this QObject to the `%' class.",
		  .arg(X::staticMetaObject.className()));
    return p;
  }

  template <class X>
  inline QtLua::Ref<X> ValueBase::to_userdata_cast() const
  {
    Ref<UserData> ud = to_userdata();

    if (!ud.valid())
      QTLUA_THROW(QtLua::ValueBase, "The value contains a null `QtLua::UserData' reference.");

    Ref<X> ref = ud.dynamiccast<X>();

    if (!ref.valid())
      QTLUA_THROW(QtLua::ValueBase, "Can not convert from `%' type to `%'.",
		  .arg(ud->get_type_name()).arg(UserData::type_name<X>()));

    return ref;
  }

  template <class X>
  inline QtLua::Ref<X> ValueBase::to_userdata_cast_null() const
  {
    Ref<UserData> ud = to_userdata();

    Ref<X> ref = ud.dynamiccast<X>();

    if (ud.valid() && !ref.valid())
      QTLUA_THROW(QtLua::ValueBase, "Can not convert from `%' type to `%'.",
		  .arg(ud->get_type_name()).arg(UserData::type_name<X>()));

    return ref;
  }

  template <class X>
  inline X* ValueBase::to_class_cast() const
  {
    Ref<UserData> ud = to_userdata();

    if (!ud.valid())
      QTLUA_THROW(QtLua::ValueBase, "The value contains a null `QtLua::UserData' reference.");

    X* ref = dynamic_cast<X*>(ud.ptr());

    if (!ref)
      QTLUA_THROW(QtLua::ValueBase, "Can not convert from `%' type to `%'.",
		  .arg(ud->get_type_name()).arg(UserData::type_name<X>()));

    return ref;
  }

  template <class X>
  inline X* ValueBase::to_class_cast_null() const
  {
    Ref<UserData> ud = to_userdata();

    X* ref = dynamic_cast<X*>(ud.ptr());

    if (ud.valid() && !ref)
      QTLUA_THROW(QtLua::ValueBase, "Can not convert from `%' type to `%'.",
		  .arg(ud->get_type_name()).arg(UserData::type_name<X>()));

    return ref;
  }

  template <class X>
  inline ValueBase::operator Ref<X> () const
  {
    return to_userdata_cast_null<X>();
  }

  State * ValueBase::get_state() const
  {
    return _st.data();
  }

  void ValueBase::table_shift(int pos, int count, int len)
  {
    return table_shift(pos, count, Value(), len);
  }

  ValueBase::iterator ValueBase::begin()
  {
    return iterator(new_iterator());
  }

  ValueBase::iterator ValueBase::end()
  {
    return iterator(Ref<Iterator>());
  }

  ValueBase::const_iterator ValueBase::begin() const
  {
    return const_iterator(new_iterator());
  }

  ValueBase::const_iterator ValueBase::end() const
  {
    return const_iterator(Ref<Iterator>());
  }

  ValueBase::const_iterator ValueBase::cbegin() const
  {
    return const_iterator(new_iterator());
  }

  ValueBase::const_iterator ValueBase::cend() const
  {
    return const_iterator(Ref<Iterator>());
  }

  ////////////////////////////////////////////////////
  //	ValueBase::value_iterator
  ////////////////////////////////////////////////////

  ValueBase::iterator_::iterator_()
  {
  }

  ValueBase::iterator_::iterator_(const Ref<Iterator> &i)
    : _i(i)
  {
  }

  ValueBase::iterator_ & ValueBase::iterator_::operator++()
  {
    _i->next();
    return *this;
  }

  ValueBase::iterator_ ValueBase::iterator_::operator++(int)
  {
    iterator_ tmp(*this);
    _i->next();
    return tmp;
  }

  bool ValueBase::iterator_::operator==(const iterator_ &i) const
  {
    return ((!i._i.valid() && !_i->more()) ||
	    (!_i.valid() && !i._i->more()));
  }

  bool ValueBase::iterator_::operator!=(const iterator_ &i) const
  {
    return !(*this == i);
  }

  Value ValueBase::iterator_::key() const
  {
    return _i->get_key();
  }

  ValueBase::const_iterator::const_iterator(const Ref<Iterator> &i)
    : iterator_(i)
  {
  }

  ValueBase::const_iterator::const_iterator(const iterator &i)
    : iterator_(i)
  {
  }

  ValueBase::const_iterator::const_iterator()
  {
  }

  Value ValueBase::const_iterator::operator* () const
  {
    return _i->get_value();
  }

  Value ValueBase::const_iterator::value() const
  {
    return _i->get_value();
  }

  ValueBase::iterator::iterator(const Ref<Iterator> &i)
    : iterator_(i)
  {
  }

  ValueBase::iterator::iterator()
  {
  }

  ValueRef ValueBase::iterator::operator* ()
  {
    return _i->get_value_ref();
  }

  ValueRef ValueBase::iterator::value()
  {
    return _i->get_value_ref();
  }

}

#endif

