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

#include <cassert>

#ifndef QTLUA_TABLE_HXX_
#define QTLUA_TABLE_HXX_

namespace QtLua {

  const Value & TableTreeKeys::get_key(int n) const
  {
    assert(n < _entries.size());
    return _entries[n]._key;
  }

  void TableTreeKeys::set_key(int n, const Value &key)
  {
    assert(n < _entries.size());
    _entries[n]._key = key;
  }

  Value TableTreeKeys::get_value(int n) const
  {
    assert(n < _entries.size());
    return _value.at(_entries[n]._key);
  }

  void TableTreeKeys::set_value(int n, const Value &value)
  {
    assert(n < _entries.size());
    _value[_entries[n]._key] = value;
    _entries[n]._table_chk = false;
  }

  bool TableTreeKeys::is_table(int n) const
  {
    assert(n < _entries.size());
    return _entries[n]._table != 0;
  }

  size_t TableTreeKeys::count() const
  {
    return _entries.count();
  }

  TableTreeKeys::Entry::Entry(const Value &key)
    : _key(key),
      _table(0),
      _table_chk(false)
  {
  }

  bool TableTreeKeys::Entry::operator<(const Entry &e) const
  {
    return _key < e._key;
  }

}

#endif

