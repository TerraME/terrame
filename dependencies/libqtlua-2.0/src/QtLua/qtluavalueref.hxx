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


#ifndef QTLUAVALUEREF_HXX_
#define QTLUAVALUEREF_HXX_

#include <cassert>

#include "qtluavalue.hxx"

#include "State"

namespace QtLua {

  ValueRef::ValueRef(const ValueRef &ref)
    : ValueBase(ref._st)
    , _table_id(_id_counter++)
    , _key_id(_id_counter++)
  {
    copy_table_key(ref._table_id, ref._key_id);
  }

  ValueRef::ValueRef(const Value &table, const Value &key)
    : ValueBase(table._st)
    , _table_id(_id_counter++)
    , _key_id(_id_counter++)
  {
    assert(table._st == key._st);
    copy_table_key(table._id, key._id);
  }

#ifdef Q_COMPILER_RVALUE_REFS

  ValueRef::ValueRef(Value &&table, const Value &key)
    : ValueBase(table._st)
    , _table_id(table._id)
    , _key_id(_id_counter++)
  {
    assert(table._st == key._st);
    table._st = 0;
    copy_key(key._id);
  }

  template <typename T>
  ValueRef::ValueRef(Value &&table, const T &key)
    : ValueBase(table._st)
    , _table_id(table._id)
  {
    table._st = 0;
    Value k(_st, key);
    _key_id = k._id;
    k._st = 0;
  }

  ValueRef::ValueRef(const Value &table, Value &&key)
    : ValueBase(table._st)
    , _table_id(_id_counter++)
    , _key_id(key._id)
  {
    assert(table._st == key._st);
    key._st = 0;
    copy_table(table._id);
  }

  ValueRef::ValueRef(Value &&table, Value &&key)
    : ValueBase(table._st)
    , _table_id(table._id)
    , _key_id(key._id)
  {
    assert(table._st == key._st);
    table._st = 0;
    key._st = 0;
  }

  ValueRef::ValueRef(ValueRef &&ref)
    : ValueBase(ref._st)
    , _table_id(ref._table_id)
    , _key_id(ref._key_id)
  {
    ref._st = 0;
  }

#endif

  template <typename T>
  ValueRef::ValueRef(const Value &table, const T &key)
    : ValueBase(table._st)
    , _table_id(_id_counter++)
  {
    copy_table(table._id);
    Value k(table._st, key);
    _key_id = k._id;
    k._st = 0;
  }

  ValueRef::~ValueRef()
  {
    if (_st)
      cleanup();
  }

#if 0
  const ValueRef & ValueRef::operator=(const ValueRef &ref) const
  {
    table_set(ref._table[ref._key]);
    return *this;
  }
#endif

  const Value & ValueRef::operator=(const Value &v) const
  {
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(Bool n) const
  {
    Value v(_st, n);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(double n) const
  {
    Value v(_st, n);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(float n) const
  {
    Value v(_st, n);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(int n) const
  {
    Value v(_st, n);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(unsigned int n) const
  {
    Value v(_st, n);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(const String &str) const
  {
    Value v(_st, str);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(const QString &str) const
  {
    Value v(_st, str);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(const char *str) const
  {
    Value v(_st, str);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(const Ref<UserData> &ud) const
  {
    Value v(_st, ud);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(UserData *ud) const
  {
    Value v(_st, *ud);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(QObject *obj) const
  {
    Value v(_st, obj);
    table_set(v);
    return v;
  }

  Value ValueRef::operator=(const QVariant &qv) const
  {
    Value v(_st, qv);
    table_set(v);
    return v;
  }

}

#endif

