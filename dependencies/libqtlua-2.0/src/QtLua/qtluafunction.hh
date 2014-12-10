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


#ifndef QTLUAFUNCTION_HH_
#define QTLUAFUNCTION_HH_

#include "qtluauserdata.hh"
#include "qtluavalue.hh"
#include "qtluaplugin.hh"

namespace QtLua {

  class State;

  /** 
   * @short Functions like objects base class
   * @header QtLua/Function
   * @module {Base}
   *
   * This class is a convenient base class for exposing functions like
   * objects to lua scripts. It's based on the @ref UserData class and
   * is handled by lua as an userdata value with redefined call operation.
   *
   * Basic argument checking can be done using the @ref
   * QtLua::UserData::meta_call_check_args function. More argument
   * checking and conversion can be performed with the @ref __get_arg1__
   * family of functions. See @xref{Qt/Lua types conversion} for supported
   * types and conversion operations.
   *
   * The @ref #QTLUA_FUNCTION macro is provided to easily declare a
   * @ref Function sub class:
   *
   * @example examples/cpp/userdata/function.cc:1|6
   *
   * @ref Function objects can be exposed as a lua values:
   *
   * @example examples/cpp/userdata/function.cc:3
   *
   * A convenience constructor is provided to register functions as
   * global lua variables:
   *
   * @example examples/cpp/userdata/function.cc:2
   *
   * Functions can also be registered on a @ref Plugin objects.
   */

  class Function : public UserData
  {
  public:
    QTLUA_REFTYPE(Function);

    /** @internal */
    void register_(State *ls, const String &path);

    /** @internal @see Plugin */
    void register_(Plugin &plugin, const String &name);

    /** This function may be reimplemented to return a short
	description of the function. */
    virtual String get_description() const;

    /** This function may be reimplemented to return a function usage
	help string. */
    virtual String get_help() const;

    /** @This contains class declaration for @ref #QTLUA_FUNCTION.
	@showcontent
    */
#define QTLUA_FUNCTION_DECL(name)					\
    class QtLua_Function_##name : public QtLua::Function		\
    {									\
      QtLua::Value::List meta_call(QtLua::State *ls, const QtLua::Value::List &args); \
      QtLua::String get_description() const;				\
      QtLua::String get_help() const;					\
    public:								\
      QtLua_Function_##name();						\
      QtLua_Function_##name(QtLua::State *ls, const QtLua::String &path); \
    };

    /** @This contains functions definition for @ref #QTLUA_FUNCTION.
	@showcontent
    */
#define QTLUA_FUNCTION_BODY(name, description, help)			\
    QtLua::String QtLua_Function_##name					\
    ::get_description() const { return description; }			\
									\
    QtLua::String QtLua_Function_##name					\
    ::get_help() const { return help; }					\
									\
    QtLua_Function_##name						\
    ::QtLua_Function_##name() { }					\
    									\
    QtLua_Function_##name						\
    ::QtLua_Function_##name(QtLua::State *ls, const QtLua::String &path)\
    { register_(ls, path); }						\
									\
    QtLua::Value::List QtLua_Function_##name				\
    ::meta_call(QtLua::State *ls, const QtLua::Value::List &args)

    /** This macro declares a new a @ref Function class named
	@tt{QtLua_Function_}@em{name} with functions to handle
	description, help and function call. User provided code is
	used for reimplementation of the @ref UserData::meta_call
	function.

	@example examples/cpp/userdata/function.cc:1|6
	@showcontent
    */
#define QTLUA_FUNCTION(name, description, help)				\
    QTLUA_FUNCTION_DECL(name)						\
    QTLUA_FUNCTION_BODY(name, description, help)

    /** @This declares and registers a @ref Function object on a QtLua
	@ref State object as a global variable.  @showcontent */
#define QTLUA_FUNCTION_REGISTER(state, prefix, name)	\
  static QtLua_Function_##name name(state, prefix #name)

    /** @This declares and registers a @ref Function object on a QtLua
	@ref State object as a global variable.  @showcontent */
#define QTLUA_FUNCTION_REGISTER2(state, path, name)	\
  static QtLua_Function_##name name(state, path)

  protected:

    virtual Value::List meta_call(State *ls, const Value::List &args) = 0;

  public:

    /**
     * This function may be called from the @ref meta_call function to
     * perform lua to C++ argument conversion and checking.
     *
     * It checks if the argument is available and tries to convert
     * argument to @tt X type and throw if conversion fails. A default
     * value is returned if no argument exists at specified index.
     *
     * @param args arguments list
     * @param n argument index in list
     * @param default_ default value to return if no argument available
     * @returns C++ converted value
     *
     * Example:
     * @example examples/cpp/userdata/function.cc:1|5
     *
     * @xsee{Qt/Lua types conversion}
     * @see __get_arg2__
     * @alias get_arg1
     */
    template <class X>
    static inline X get_arg(const Value::List &args, int n, const X & default_);

    /**
     * This function does the same as the @ref __get_arg1__ function
     * but throws if the argument is not available instead of returning a
     * default value.
     *
     * @see __get_arg1__
     * @see get_arg_ud
     * @alias get_arg2
     */
    template <class X>
    static inline X get_arg(const Value::List &args, int n);

    /**
     * This function may be called from the @ref meta_call function to
     * perform lua to C++ argument conversion and checking.
     *
     * It checks if the argument is available and if it is an @ref
     * UserData object and tries to cast it using the @ref
     * Value::to_userdata_cast function.
     *
     * @param args arguments list
     * @param n argument index in list
     * @returns @ref Ref pointer to @tt X type.
     *
     * @xsee{Qt/Lua types conversion}
     * @see __get_arg2__
     */
    template <class X>
    static inline Ref<X> get_arg_ud(const Value::List &args, int n);

    /**
     * This function may be called from the @ref meta_call function to
     * perform lua to C++ argument conversion and checking.
     *
     * It checks if the argument is available and if it is an @ref
     * UserData object and tries to @tt dynamic_cast it to the
     * specified class. This function throws an exception if the
     * result is null.
     *
     * @param args arguments list
     * @param n argument index in list
     * @returns pointer to @tt X type.
     *
     * @xsee{Qt/Lua types conversion}
     * @see __get_arg2__
     */
    template <class X>
    static inline X* get_arg_cl(const Value::List &args, int n);

    /**
     * This function may be called from the @ref meta_call function to
     * perform lua to C++ argument conversion and checking.
     *
     * It checks if the argument is available and if it is a @ref
     * QObject wrapper and tries to cast to the requested @ref QObject
     * based class using the @ref Value::to_qobject_cast function.
     *
     * @param args arguments list
     * @param n argument index in list
     * @returns pointer to @tt X type.
     *
     * @xsee{Qt/Lua types conversion}
     * @see __get_arg2__
     */
    template <class X>
    static inline X* get_arg_qobject(const Value::List &args, int n);

  private:
    String get_value_str() const;
    String get_type_name() const;
    bool support(Value::Operation c) const;
    void completion_patch(String &path, String &entry, int &offset);
  };

}

#endif

