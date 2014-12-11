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


#ifndef QTLUAUSERDATA_HH_
#define QTLUAUSERDATA_HH_

#include <iostream>

#include <QList>
#include <QHash>

#include "qtluaref.hh"
#include "qtluavalue.hh"

struct lua_State;

namespace QtLua {

class String;
class State;
class Value;
class UserData;
class Iterator;

/**
 * @short Lua userdata objects base class
 * @header QtLua/UserData
 * @module {Base}
 *
 * This class is the base class for C++ objects which may be exposed
 * to lua script as a lua userdata value.
 *
 * All lua meta operations on userdata values are mapped to virtual
 * functions in this class which may be reimplemented in derived
 * classes. Lua errors can be raised from these functions by throwing
 * a @ref QtLua::String type exception. See @xref{Error handling and exceptions}.
 *
 * Objects derived from this class are subject to lua garbage
 * collection and must be handled by the @ref QtLua::Ref smart pointer
 * class in C++ code.
 *
 * @ref UserData base class declaration example:
 * @example examples/cpp/userdata/ref.cc:1
 *
 * @ref UserData objects allocation examples:
 * @example examples/cpp/userdata/ref.cc:3|5
 */

class UserData : public QtLua::Refobj<UserData>
{
  friend class State;
  friend class ValueBase;
  friend class Value;
  friend class ValueRef;
  friend uint qHash(const Value &lv);

public:
  QTLUA_REFTYPE(UserData);

  virtual inline ~UserData();

  /** Get a bare C++ typename from type */
  template <class X>
  static String type_name();

  /**
   * This function is called when a lua operator is used with a @ref
   * UserData object. The default implementation throws an error
   * message. The @ref support function must be reimplemented along
   * with this function.
   *
   * @param op Specify invoked lua operator (see @ref Value::Operation).
   * @param a First value involved in operation.
   * @param b Second value involved in operation for binary operators.
   * @returns Operation result value.
   */
  virtual Value meta_operation(State *ls, Value::Operation op, const Value &a, const Value &b);

  /** 
   * This function is called when a table read access operation is
   * attempted on a userdata object. The default implementation throws
   * an error message. The @ref support function must be
   * reimplemented along with this function to report @ref
   * Value::OpIndex as supported.
   * 
   * @param key Value used as table index.
   * @returns Table access result value.
   */
  virtual Value meta_index(State *ls, const Value &key);

  /**
   * This function is called when a table write access operation is
   * attempted on a userdata object. The default implementation throws
   * an error message. The @ref support function must be
   * reimplemented along with this function to report @ref
   * Value::OpNewindex as supported.
   *
   * @param key Value used as table index.
   * @param value Value to put in table.
   */
  virtual void meta_newindex(State *ls, const Value &key, const Value &value);

  /**
   * This function returns @tt true if either the @ref Value::OpIndex
   * operation or the @ref Value::OpNewindex operation is supported and
   * an entry is associated to the given key.
   *
   * The default implementation returns @tt{!meta_index(ls,
   * key).is_nil()} or @tt false if @ref meta_index throws.
   */
  virtual bool meta_contains(State *ls, const Value &key);

  /**
   * This function is called when a function invokation operation is
   * performed on a userdata object. The default implementation throws
   * an error message. The @ref support function must be
   * reimplemented along with this function to report @ref Value::OpCall as
   * supported.
   *
   * @param args List of passed arguments.
   * @returns List of returned values.
   */
  virtual Value::List meta_call(State *ls, const Value::List &args);

  /**
   * This function may return an @ref Iterator object used to iterate
   * over an userdata object. The default implementation throws an
   * error message. The @ref support function must be reimplemented
   * along with this function to report @ref Value::OpIterate as
   * supported.
   *
   * @returns an @ref Iterator based iterator object.
   */
  virtual Ref<Iterator> new_iterator(State *ls);

  /**
   * This function returns an object type name. The default
   * implementation returns the C++ object type name. This is used
   * for error messages and pretty printing.
   *
   * @returns Pretty print object type.
   */
  virtual String get_type_name() const;

  /**
   * This function returns an string value describing object value or
   * content. The default implementation returns an hexadecimal
   * object pointer. This is used for mainly for pretty printing.
   */
  virtual String get_value_str() const;

  /** Check given operation support. @see Value::support */
  virtual bool support(enum Value::Operation c) const;

  /** Userdata compare for equality, default implementation compares the @tt this pointers */
  virtual bool operator==(const UserData &ud);

  /** Userdata compare less than, default implementation compares the @tt this pointers */
  virtual bool operator<(const UserData &ud);

  /**
   * This helper function can be used to check arguments types passed
   * to the @ref meta_call functions. This function throw an error
   * message if checking fails.
   *
   * More advanced arguments checking and conversion features are
   * available in the @ref QtLua::Function base class which may be
   * more appropriate when a userdata object is to be used as a
   * function.
   *
   * @param args list of passed arguments.
   * @param min_count Minimum expected arguments count.
   * @param max_count Maximum expected arguments count or 0 if no limit.
   * @param ... List of @ref QtLua::Value::ValueType matching expected 
   *   arguments type. At least @tt{max(min_count, abs(max_count))}
   *   types must be passed. @ref QtLua::Value::TNone may be 
   *   used as wildcard. A negative value can be used for @tt max_count
   *   to indicate a unlimited number of lua arguments with a type list
   *   longer than @tt min_count. Last specified type is expected for
   *   all arguments above @tt{max(min_count, -max_count)}.
   */
  static void meta_call_check_args(const Value::List &args, int min_count, int max_count, ...);

protected:

  /**
   * When @this is invoked from the @ref meta_call function, QtLua
   * will request lua to @em yield when the @ref meta_call function
   * returns.
   *
   * The current lua thread value is returned. The Value::call family
   * of functions can be used on a lua thread value to resume the
   * coroutine from C++ code. The @tt nil value is returned if not
   * currently running inside a coroutine.
   *
   * When the @ref State::lua_version function returns a value less
   * than 501, this function is not able to return the current thread
   * value if it has not been created using the @ref Value::new_thread
   * function. If the current thread has been created by any other
   * mean (like call to the @tt {coroutine.create} lua 5.0 function) a
   * boolean @tt true value is returned instead of the thread value.
   */
  Value yield(State *ls) const;

  /**
   * This function may be reimplemented to further modify completion
   * result on console line when completed to a @ref UserData
   * value. This is usefull to append a dot or a pair of brackets
   * access operator to the userdata value name for instance.
   *
   * @param path Completion result tables path to userdata value.
   * @param entry Completion result userdata name. May append to this string directly.
   * @param offset Cursor offset. May be decreased to place cursor between inserted brackets for instance.
   */
  virtual void completion_patch(String &path, String &entry, int &offset);

private:

  template <bool pop>
  static QtLua::Ref<UserData> get_ud_(lua_State *st, int i);
  /** Get @ref QtLua::UserData reference from lua stack element. */
  static QtLua::Ref<UserData> get_ud(lua_State *st, int i);
  /** Get @ref QtLua::UserData reference from lua stack element and pop stack */
  static QtLua::Ref<UserData> pop_ud(lua_State *st);
  /** Push a reference to QtLua::UserData on lua stack. */
  void push_ud(lua_State *st);
};

}

Q_DECLARE_METATYPE(QtLua::UserData::ptr);

#endif

