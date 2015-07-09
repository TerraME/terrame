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

    Fork
    Copyright (C) 2015 (Li, Kwue-Ron) <likwueron@gmail.com>
*/

// __moc_flags__ -fQtLua/State

#ifndef QTLUASTATE_HH_
#define QTLUASTATE_HH_

#include <QIODevice>
#include <QObject>
#include <QHash>

#include "qtluafunctionsignature.hh"
#include "qtluastring.hh"
#include "qtluavalue.hh"
#include "qtluavalueref.hh"

struct lua_State;

namespace QtLua {

  /** @internal */
  typedef QObject * qobject_creator();

  /** @internal */
  template <class QObject_T>
  static inline QObject * create_qobject();

  /** @internal */
  void qtlib_register_meta(const QMetaObject *mo, qobject_creator *creator);

  void qtlib_register_meta(const QMetaObject *mo, const QMetaObject *supreme_mo, bool auto_property, qobject_creator *creator);
  
  void qtlib_enable_meta_auto_property(const QMetaObject *mo, bool enable);

  void qtlib_register_static_method(const QMetaObject *mo, const String &name, FunctionSignature func, const QList<String> &argv);

  class UserData;
  class QObjectWrapper;
  class TableIterator;

  /** @internal */
  typedef QHash<QObject *, QObjectWrapper *> wrapper_hash_t;

  /** Specify lua standard libraries and QtLua lua libraries to load
      with the @ref State::openlib function. */
  enum Library
    {
      BaseLib = 0x1,      //< standard lua base library
      CoroutineLib = 0x2, //< standard lua coroutine library, included in base before lua 5.2
      PackageLib = 0x4,   //< standard lua package library
      StringLib = 0x8,    //< standard lua string library
      TableLib = 0x10,    //< standard lua table library
      MathLib = 0x20,     //< standard lua math library
      IoLib = 0x40,       //< standard lua io library
      OsLib = 0x80,       //< standard lua os library
      DebugLib = 0x100,   //< standard lua debug library
      Bit32Lib = 0x200,   //< standard lua bit library
      JitLib = 0x400,     //< luajit jit library
      FfiLib = 0x800,     //< luajit ffi library
      QtLuaLib = 0x1000,  //< lua library with base functions, see the @xref{Predefined lua functions} section.
      QtLib = 0x2000,     //< lua library with wrapped Qt functions, see the @xref{Qt related functions} section.
      AllLibs =           //< All libraries wildcard
                BaseLib | CoroutineLib |
                PackageLib | StringLib | TableLib | MathLib |
                IoLib | OsLib | DebugLib | Bit32Lib |
                JitLib | FfiLib |
                QtLuaLib | QtLib,
    };
  Q_DECLARE_FLAGS(Librarys, Library);

  /**
   * @short Lua interpreter state wrapper class
   * @header QtLua/State
   * @module {Base}
   *
   * This class wraps the lua interpreter state.
   * 
   * This class provides various functions to execute lua code, access
   * lua variables from C++ and load lua libraries.
   *
   * Some functions in this class may throw an exception to handle lua
   * errors, see @xref{Error handling and exceptions}.
   *
   * This class provides Qt slots and signals for use with the @ref
   * Console widget. This enables table names completion and error
   * messages reporting on user console.
   */

class State : public QObject
{
  Q_OBJECT

  friend class QObjectWrapper;
  friend class UserData;
  friend class ValueBase;
  friend class Value;
  friend class ValueRef;
  friend class TableIterator;
  friend uint qHash(const Value &lv);

public:

  State();

  State(lua_State	*L);
  /** 
   * Lua interpreter state is checked for remaining @ref Value objects
   * with references to @ref UserData objects when destroyed.
   *
   * Program is aborted if such references are found because these
   * objects would try to access the destroyed @ref State later and
   * probably crash.
   *
   * QtLua takes care of clearing all global variables before
   * performing this sanity check.
   */
  ~State();

  /** 
   * Execute a lua chuck read from @ref QIODevice .
   * @xsee{Error handling and exceptions}
   */
  Value::List exec_chunk(QIODevice &io);

  /**
   * Execute a lua script string.
   * @xsee{Error handling and exceptions}
   */
  Value::List exec_statements(const String &statements);

  /** Initiate a garbage collection cycle. This is useful to ensure
      all unused @ref UserData based objects are destroyed. */
  void gc_collect();

  /** Set a global variable. If path contains '.', intermediate tables
      will be created on the fly. The @ref __operator_sqb2__ function may be
      used if no intermediate table access is needed. */
  void set_global(const String &path, const Value &value);

  /** Get global variable. If path contains '.', intermediate tables
      will be accessed. The @ref __operator_sqb1__ function may be used if no
      intermediate table access is needed. */
  Value get_global(const String &path) const;

  /**
   * Index operation on global table. This function return a @ref
   * Value object which is a @strong copy of the requested global
   * variable. This value can be modified but will not change the
   * original lua variable.
   *
   * @example examples/cpp/value/global.cc:i1|i2|1
   * @alias operator_sqb1 @see __at_value__
   */
  inline Value operator[] (const Value &key) const;

  /**
   * Index operation on global table.
   * @see __operator_sqb1__ @alias at_value
   */
  Value at(const Value &key) const;

  /**
   * Index operation on global table, shortcut for string key access.
   * @see __operator_sqb1__ @alias at_string
   */
  inline Value at(const String &key) const;

  /**
   * Index operation on global table, shortcut for string key access.
   * @see __operator_sqb1__ @see __at_string__
   */
  inline Value operator[] (const String &key) const;

  /**
   * Index operation on global table. This function return a @ref
   * ValueRef object which is a modifiable reference to requested
   * global variable. It can be assigned to modify original lua value:
   *
   * @example examples/cpp/value/global.cc:i1|2
   * @alias operator_sqb2 @see __at_value__
   */
  ValueRef operator[] (const Value &key);

  /**
   * Index operation on global table, shortcut for string key access.
   * @see __operator_sqb2__ @see __at_string__
   */
  inline ValueRef operator[] (const String &key);

  /** 
   * This function open a lua standard library or QtLua lua library.
   * The function returns true if the library is available.
   * @see QtLua::Library
   * @xsee{QtLua lua libraries}
   */
  bool openlib(Librarys lib);
  
  bool openlib(Library lib);

  /** 
   * Call given function pointer with internal @ref lua_State
   * pointer. Can be used to register extra libraries or access
   * internal lua interpreter directly.
   *
   * Use with care if you are nor familiar with the lua C API.
   */
  void lua_do(void (*func)(lua_State *st));

  /**
   * @This returns a pointer to the internal Lua state.
   */
  inline lua_State *get_lua_state() const;

  /**
   * @This adds a new entry to the @tt{qt.meta} lua table. This allows
   * lua script to access QObject members and create new objects of
   * this type using the @tt{qt.new_qobject} lua function.
   */
  template <class QObject_T>
  static inline void register_qobject_meta();
  template <class QObject_T, class Supreme_T>
  static inline void register_qobject_meta();

  template <class QObject_T>
  static inline void register_qobject_static_method(const String &name, FunctionSignature func, const QList<String> &argv);

  /**
   * @internal @This asserts internal lua stack is empty.
   */
  void check_empty_stack() const;

  /**
   * @this returns lua version. Result is 500 for lua pior to version 5.1.
   */
  int lua_version() const;

  /**
   * @This function may be used to enable forwarding of lua print
   * function output to Qt debug output. @xsee {Predefined lua functions}
   */
  inline void enable_qdebug_print(bool enabled = true);

public slots:

  /**
   * This slot function execute the given script string and initiate a
   * garbage collection cycle. It will catch and print lua
   * errors using the @ref output signal.
   * @see Console
   */
  void exec(const QString &statements);

  /**
   * Lua global variables completion handler. May be connected to
   * Console widget for default global variables completion behavior.
   */
  void fill_completion_list(const QString &prefix, QStringList &list, int &cursor_offset);

  /**
   * @internal This function return a lua value from an expression.
   */
  Value eval_expr(bool use_lua, const String &expr);

signals:

  /**
   * Text output signal. This signal is used to report errors and display output of the
   * lua @tt{print()} function. @xsee {Predefined lua functions}
   */
  void output(const QString &str);

private:

  void init(lua_State *L);	
  
  inline void output_str(const String &str);

  // get pointer to lua state object from lua state
  static State *get_this(lua_State *st);

  void fill_completion_list_r(String &path, const String &prefix,
			      QStringList &list, const Value &tbl,
			      int &cursor_offset);

  void set_global_r(const String &name, const Value &value, int tblidx);
  void get_global_r(const String &name, Value &value, int tblidx) const;

  void reg_c_function(const char *name, int (*fcn)(lua_State *));

  static void lua_pgettable(lua_State *st, int index);
  static void lua_psettable(lua_State *st, int index);
  static int lua_pnext(lua_State *st, int index);

  // lua c functions
  static int lua_cmd_iterator(lua_State *st);
  static int lua_cmd_each(lua_State *st);
  static int lua_cmd_print(lua_State *st);
  static int lua_cmd_list(lua_State *st);
  static int lua_cmd_help(lua_State *st);
  static int lua_cmd_plugin(lua_State *st);
  static int lua_cmd_qtype(lua_State *st);

  // lua meta methods functions
  static int lua_meta_item_add(lua_State *st);
  static int lua_meta_item_sub(lua_State *st);
  static int lua_meta_item_mul(lua_State *st);
  static int lua_meta_item_div(lua_State *st);
  static int lua_meta_item_mod(lua_State *st);
  static int lua_meta_item_pow(lua_State *st);
  static int lua_meta_item_unm(lua_State *st);
  static int lua_meta_item_concat(lua_State *st);
  static int lua_meta_item_len(lua_State *st);
  static int lua_meta_item_eq(lua_State *st);
  static int lua_meta_item_lt(lua_State *st);
  static int lua_meta_item_le(lua_State *st);
  static int lua_meta_item_index(lua_State *st);
  static int lua_meta_item_newindex(lua_State *st);
  static int lua_meta_item_call(lua_State *st);
  static int lua_meta_item_gc(lua_State *st);

  // static member addresses are used as lua registry table keys
  static char _key_threads;
  static char _key_item_metatable;
  static char _key_this;

  // QObjects wrappers are referenced here
  wrapper_hash_t _whash;

  lua_State	*_mst;      //< main thread state
  lua_State	*_lst;      //< current thread state
  bool          _yield_on_return;
  bool          _debug_output;
  bool _state_ownership;
};

}
Q_DECLARE_OPERATORS_FOR_FLAGS(QtLua::Librarys);

#endif
