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

#ifndef QTLUAVALUE_HH_
#define QTLUAVALUE_HH_

#include "qtluavaluebase.hh"

namespace QtLua {

  /**
   * @short Lua values wrapper class
   * @header QtLua/Value
   * @module {Base}
   *
   * This class exposes a lua value to C++ code. It provides
   * conversion functions, cast operators, access operators and
   * standard C++ iterators.
   *
   * Each @ref QtLua::Value object store its associated lua value in
   * the lua interpreter state registry table.
   * 
   * @xsee{Qt/Lua types conversion}
   * @see Iterator
   * @see iterator
   * @see const_iterator
   */

class Value : public ValueBase
{
  friend class State;
  friend class UserData;
  friend class TableIterator;
  friend class ValueRef;
  friend class ValueBase;
  friend uint qHash(const Value &lv);

public:
  /** Create a lua value object with no associated @ref State */
  inline Value();

  /** Create a "nil" lua value. @multiple */
  inline Value(const State *ls);

  /** Create a lua value copy. @multiple */
  Value(const Value &lv);
  Value(const State *ls, const Value &lv);
#ifdef Q_COMPILER_RVALUE_REFS
  inline Value(Value &&lv);
  inline Value(const State *ls, Value &&lv);
#endif

  /** Create a lua value. @multiple */
  inline Value(const State *ls, Bool n);

  /** Create a number lua value. @multiple */
  inline Value(const State *ls, float n);
  inline Value(const State *ls, double n);
  inline Value(const State *ls, int n);
  inline Value(const State *ls, unsigned int n);

  /** Create a string lua value. @multiple */
  inline Value(const State *ls, const String &str);
  inline Value(const State *ls, const QString &str);
  inline Value(const State *ls, const char *str);

  /**
   * Create a lua userdata value.  @multiple
   */
  inline Value(const State *ls, const Ref<UserData> &ud);
  inline Value(const State *ls, UserData *ud);

  /**
   * Create a wrapped @ref QObject lua value. @multiple
   * @xsee{QObject wrapping}
   * @see __Value_qobject__
   */
  inline Value(const State *ls, QObject *obj);

  /**
   * Create a lua value from a @ref QVariant object.
   * @xsee {Qt/Lua types conversion} @multiple
   */
  inline Value(const State *ls, const QVariant &qv);

  /**
   * Create a @ref QObject lua value and update associated
   * wrapper ownership flags for this @ref QObject.
   * @xsee{QObject wrapping}
   * @alias Value_qobject
   */
  Value(State *ls, QObject *obj, bool delete_, bool reparent);

  /** Create a new lua global environment value */
  static inline Value new_global_env(const State *ls);

  /** Create a new lua table value */
  static inline Value new_table(const State *ls);

  /** Create a new coroutine value with given entry point lua function. */
  static inline Value new_thread(const State *ls, const Value &main);

  /**
   * Create a lua table indexed from 1 with elements from a @ref QList.
   * @xsee{Qt/Lua types conversion}
   * @multiple
   */
  template <typename X>
  inline Value(const State *ls, const QList<X> &list);
  template <typename X>
  inline Value(const State *ls, QList<X> &list);

  /**
   * Create a lua table indexed from 1 with elements from a @ref QVector.
   * @xsee{Qt/Lua types conversion}
   * @multiple
   */
  template <typename X>
  inline Value(const State *ls, const QVector<X> &vector);
  template <typename X>
  inline Value(const State *ls, QVector<X> &vector);

  /**
   * Create a lua table indexed from 1 with elements from a C array.
   * @xsee{Qt/Lua types conversion}
   */
  template <typename X>
  inline Value(const State *ls, unsigned int size, const X *array);

  /**
   * Create a lua table with elements from @ref QHash.
   * @xsee{Qt/Lua types conversion}
   * @multiple
   */
  template <typename Key, typename Val>
  inline Value(const State *ls, const QHash<Key, Val> &hash);
  template <typename Key, typename Val>
  inline Value(const State *ls, QHash<Key, Val> &hash);

  /**
   * Create a lua table with elements from @ref QMap.
   * @xsee{Qt/Lua types conversion}
   * @multiple
   */
  template <typename Key, typename Val>
  inline Value(const State *ls, const QMap<Key, Val> &map);
  template <typename Key, typename Val>
  inline Value(const State *ls, QMap<Key, Val> &map);

  /** Remove lua value from lua state registry. */
  inline ~Value();

  /** Copy a lua value. */
  Value & operator=(const Value &lv);
#ifdef Q_COMPILER_RVALUE_REFS
  inline Value & operator=(Value &&lv);
#endif

  /** Assign a boolean to lua value. */
  Value & operator=(Bool n);

  /** Assign a number to lua value. @multiple */
  Value & operator=(double n);
  inline Value & operator=(float n);
  inline Value & operator=(int n);
  inline Value & operator=(unsigned int n);

  /** Assign a string to lua value. @multiple */
  Value & operator=(const String &str);
  inline Value & operator=(const QString &str);
  inline Value & operator=(const char *str);

  /** 
   * Assign a userdata to lua value. The value will hold a @ref Ref
   * reference to the @ref UserData object which will be dropped later
   * by the lua garbage collector.
   */
  Value & operator=(const Ref<UserData> &ud);
  inline Value & operator=(UserData *ud);

  /**
   * Assign a QObject to lua value.
   * @xsee{QObject wrapping}
   */
  Value & operator=(QObject *obj);

  /**
   * Convert a @ref QVariant to lua value.
   * @xsee {Qt/Lua types conversion}
   */
  Value & operator=(const QVariant &qv);

#if 0 && defined(Q_COMPILER_RVALUE_REFS) // FIXME rvalue ref not supported in gcc 4.7

#ifdef __GNUC__
# define QTLUA_TEMP_VALUE_ASSIGN __attribute__((deprecated("Assignment to temporary Value object")))
#else
# define QTLUA_TEMP_VALUE_ASSIGN
#endif

  /** @multiple @internal This functions is not implemented, its
      declaration prevents a common pitfall of assignment to
      temporary @ref Value instead of @ref ValueRef object. */

  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(Bool n) &&;

  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(double n) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(float n) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(int n) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(unsigned int n) &&;

  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(const String &str) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(const QString &str) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(const char *str) &&;

  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(const Ref<UserData> &ud) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(UserData *ud) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(QObject *obj) &&;
  QTLUA_TEMP_VALUE_ASSIGN Value & operator=(const QVariant &qv) &&;
#endif

private:
  template <typename HashContainer>
  inline void from_hash(const State *ls, const HashContainer &hash);

  template <typename HashContainer>
  inline void from_hash(const State *ls, HashContainer &hash);

  template <typename ListContainer>
  inline void from_list(const State *ls, const ListContainer &list);

  /** push value on lua stack. */
  void push_value(lua_State *st) const;
  inline Value value() const;

  /** set value to nil in registry, _st must not be NULL */
  void cleanup();

  /** construct from value on lua stack. */
  Value(int index, const State *st);

  void init_global();
  void init_table();
  void init_thread(const Value &main);

  static int empty_fcn(lua_State *st);

  double _id;
};

}

#endif

