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

#include <QtLua/Value>
#include <internal/TableTreeKeys>

namespace QtLua {

  TableTreeKeys::TableTreeKeys(const Value &val, TableTreeModel::Attributes attr)
    : _value(val),
      _parent(0),
      _attr(attr)
  {
  }

  TableTreeKeys::~TableTreeKeys()
  {
    clear();
  }

  void TableTreeKeys::clear()
  {
    while (!_entries.empty())
      {
	const Entry &e = _entries.takeLast();
	if (e._table)
	  delete e._table;
      }
  }

  TableTreeKeys * TableTreeKeys::set_table(int n)
  {
    if (!(_attr & TableTreeModel::Recursive))
      return NULL;

    if (n >= _entries.count())
      return NULL;

    Entry *e = &_entries[n];

    if (e->_table_chk)
      return e->_table;

    TableTreeKeys *res = 0;

    try {
      Value value = get_value(n);
      TableTreeModel::Attributes attr_mask = 0;

      switch (value.type())
	{
	case Value::TUserData:
	  if (!(_attr & TableTreeModel::UserDataIter))
	    break;

	  try {
	    UserData::ptr ud(value.to_userdata());

	    if (!ud->support(Value::OpIterate))
	      break;
	    if (!ud->support(Value::OpIndex))
	      break;

	    if (!ud->support(Value::OpNewindex))
	      attr_mask |= TableTreeModel::EditAll;

	  } catch (const String &e) {
	    // not a QtLua::UserData userdata
	    break;
	  }

	case Value::TTable:
	  res = new TableTreeKeys(value, _attr & ~attr_mask);
	  res->_parent = this;
	  res->_row = n;
	  e->_table = res;

	default:
	  break;
	}

    } catch (const String &e) {
    }

    e->_table_chk = true;

    return res;
  }

  void TableTreeKeys::update()
  {
    if (!_entries.empty())
      return;

    Value::const_iterator i;

    try {
      for (i = _value.begin(); i != _value.end(); i++)
	_entries.push_back(Entry(i.key()));
    } catch (const String &e) {
    }

    qSort(_entries.begin(), _entries.end());
  }

}

