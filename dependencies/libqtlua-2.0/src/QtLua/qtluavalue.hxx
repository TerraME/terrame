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


#ifndef QTLUAVALUE_HXX_
#define QTLUAVALUE_HXX_

#include <typeinfo>

#include "qtluavaluebase.hxx"

namespace QtLua {

  Value::Value()
    : ValueBase(0)
    , _id(_id_counter++)
  {
  }

  Value::Value(const State *ls)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
  }

  Value::Value(const State *ls, Bool n)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = n;
  }

  Value::Value(const State *ls, float n)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = n;
  }

  Value::Value(const State *ls, double n)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = n;
  }

  Value::Value(const State *ls, int n)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = (double)n;
  }

  Value::Value(const State *ls, unsigned int n)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = (double)n;
  }

  Value::Value(const State *ls, const String &str)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = str;
  }

  Value::Value(const State *ls, const QString &str)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = String(str);
  }

  Value::Value(const State *ls, const char *str)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = String(str);
  }

  Value::Value(const State *ls, const Ref<UserData> &ud)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = ud;
  }

  Value::Value(const State *ls, UserData *ud)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = *ud;
  }

  Value::Value(const State *ls, QObject *obj)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = obj;
  }

  Value::Value(const State *ls, const QVariant &qv)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = qv;
  }

  Value::~Value()
  {
    if (_st)
      cleanup();
  }

#ifdef Q_COMPILER_RVALUE_REFS
  Value::Value(Value &&lv)
    : ValueBase(lv._st)
    , _id(lv._id)
  {
    lv._st = 0;
  }

  Value::Value(const State *ls, Value &&lv)
    : ValueBase(ls)
    , _id(lv._id)
  {
    assert(lv._st == ls);
    lv._st = 0;
  }

  Value & Value::operator=(Value &&lv)
  {
    if (_st)
      cleanup();    
    _st = lv._st;
    _id = lv._id;
    lv._st = 0;

    return *this;
  }
#endif

  Value & Value::operator=(int n)
  {
    *this = (double)n;
    return *this;
  }

  Value & Value::operator=(float n)
  {
    *this = (double)n;
    return *this;
  }

  Value & Value::operator=(unsigned int n)
  {
    *this = (double)n;
    return *this;
  }

  Value & Value::operator=(const QString &str)
  {
    *this = String(str);
    return *this;
  }

  Value & Value::operator=(const char *str)
  {
    *this = String(str);
    return *this;
  }

  Value & Value::operator=(UserData *ud)
  {
    *this = *ud;
    return *this;
  }

  inline Value Value::value() const
  {
    return *this;
  }

  Value Value::new_global_env(const State *ls)
  {
    Value t(ls);
    t.init_global();
    return t;
  }

  Value Value::new_table(const State *ls)
  {
    Value t(ls);
    t.init_table();
    return t;
  }

  Value Value::new_thread(const State *ls, const Value &main)
  {
    Value t(ls);
    t.init_thread(main);
    return t;
  }

  template <typename ListContainer>
  inline void Value::from_list(const State *ls, const ListContainer &list)
  {
    *this = new_table(ls);
    for (int i = 0; i < list.size(); i++)
      (*this)[i+1] = list.at(i);
  }

  template <typename X>
  inline Value::Value(const State *ls, const QList<X> &list)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_list<const QList<X> >(ls, list);
  }

  template <typename X>
  inline Value::Value(const State *ls, QList<X> &list)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_list<QList<X> >(ls, list);
  }

  template <typename X>
  inline Value::Value(const State *ls, const QVector<X> &vector)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_list<const QVector<X> >(ls, vector);
  }

  template <typename X>
  inline Value::Value(const State *ls, QVector<X> &vector)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_list<QVector<X> >(ls, vector);
  }

  template <typename X>
  inline Value::Value(const State *ls, unsigned int size, const X *array)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    *this = new_table(ls);
    for (unsigned int i = 0; i < size; i++)
      (*this)[i+1] = array[i];
  }

  template <typename HashContainer>
  inline void Value::from_hash(const State *ls, const HashContainer &hash)
  {
    *this = new_table(ls);
    for (typename HashContainer::const_iterator i = hash.begin(); i != hash.end(); i++)
      (*this)[i.key()] = Value(ls, i.value());
  }

  template <typename HashContainer>
  inline void Value::from_hash(const State *ls, HashContainer &hash)
  {
    *this = new_table(ls);
    for (typename HashContainer::iterator i = hash.begin(); i != hash.end(); i++)
      (*this)[i.key()] = Value(ls, i.value());
  }

  template <typename Key, typename Val>
  inline Value::Value(const State *ls, const QHash<Key, Val> &hash)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_hash<const QHash<Key, Val> >(ls, hash);
  }

  template <typename Key, typename Val>
  inline Value::Value(const State *ls, const QMap<Key, Val> &map)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_hash<const QMap<Key, Val> >(ls, map);
  }

  template <typename Key, typename Val>
  inline Value::Value(const State *ls, QHash<Key, Val> &hash)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_hash<QHash<Key, Val> >(ls, hash);
  }

  template <typename Key, typename Val>
  inline Value::Value(const State *ls, QMap<Key, Val> &map)
    : ValueBase(ls)
    , _id(_id_counter++)
  {
    from_hash<QMap<Key, Val> >(ls, map);
  }

}

#endif

