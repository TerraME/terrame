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

#ifndef QTLUAUSEROBJECT_HH_
#define QTLUAUSEROBJECT_HH_

#include <QPointer>

#include "qtluauserdata.hh"
#include "qtluaiterator.hh"

namespace QtLua {

  /**
   * @short Lua userdata objects with properties
   * @header QtLua/UserObject
   * @module {Base}
   *
   * This base class can be used to create C++ objects with named
   * properties accessible from lua script. This is a lightweight
   * alternative to writting a @ref QObject based class when only @tt
   * set/get properties mechanism is needed. The class doesn't need to
   * be a @ref QObject and doesn't require @tt moc pre-processing.
   *
   * Each property must be described in a table and can have an
   * associated @tt lua_set* and/or @tt lua_get* accessor
   * function. Lua accessors functions must be able to convert between
   * a @ref QtLua::Value object and property field type. Property
   * members and lua accessor functions can be user defined or
   * declared using the @ref #QTLUA_PROPERTY family of macros as shown
   * in the example below:
   *
   * @example examples/cpp/userdata/userobject.cc:1
   *
   * In the next example our class already needs to inherit from an
   * other @ref UserData based class for some reasons. We declare the
   * @ref UserObject class as a member and forward table accesses to
   * it. This example also shows how to write lua accessors by hand:
   *
   * @example examples/cpp/userdata/userobject2.cc:1
   */
  template <class T>
  class UserObject : public UserData
  {
  public:
    QTLUA_REFTYPE(UserObject);

  private:
    /** @internal */
    class UserObjectIterator : public Iterator
    {
    public:
      QTLUA_REFTYPE(UserObjectIterator);
      UserObjectIterator(State *ls, const Ref<UserObject> &obj);

    private:
      bool more() const;
      void next();
      Value get_key() const;
      Value get_value() const;
      ValueRef get_value_ref();

      QPointer<State> _ls;
      Ref<UserObject> _obj;
      size_t _index;
    };

    friend class UserObjectIterator;

    int get_entry(const String &name);
    T *_obj;

    void completion_patch(String &path, String &entry, int &offset);

  public:

    /** This constructor must be used when the class which contains properties
	inherit from @ref UserObject. */
    inline UserObject();

    /** This constructor must be used when the class which contains
	properties does not inherit from @ref UserObject. Pointer to
	properties object must be provided. */
    inline UserObject(T *obj);

    /** @internal Property member entry */
    struct _qtlua_property_s
    {
      const char *name;		//< Lua property name
      void (T::*set)(State *ls, const Value &value); //< Pointer to property set accesor function for lua
      Value (T::*get)(State *ls); //< Pointer to property get accesor function for lua
    };

    Value meta_index(State *ls, const Value &key);
    bool meta_contains(State *ls, const Value &key);
    void meta_newindex(State *ls, const Value &key, const Value &value);
    Ref<Iterator> new_iterator(State *ls);
    bool support(Value::Operation c) const;

    /**
     * This macro must appears once in class body which holds property declarations.
     */
#define QTLUA_USEROBJECT(class_name)				\
    friend class QtLua::UserObject<class_name>;			\
    typedef QtLua::UserObject<class_name>::_qtlua_property_s _qtlua_property_s;	\
    static const _qtlua_property_s _qtlua_properties_table[];

    /**
     * This macro must be used once at global scope to list available
     * properties and specify allowed access.
     */
#define QTLUA_PROPERTIES_TABLE(class_name, ...)			\
    const class_name::_qtlua_property_s class_name::_qtlua_properties_table[] = { __VA_ARGS__, { 0 } };

    /** 
     * Define a lua get accessor function for the specified member
     * @showcontent
     */
#define QTLUA_PROPERTY_ACCESSOR_GET(member)		\
  inline QtLua::Value lua_get_##member(QtLua::State *ls)	\
  {						\
    return QtLua::Value(ls, member);		\
  }

    /** 
     * Define a lua set accessor function for the specified member
     * @showcontent
     */
#define QTLUA_PROPERTY_ACCESSOR_SET(member)				\
  inline void lua_set_##member(QtLua::State *ls, const QtLua::Value &value)\
  {								\
    member = value;						\
  }

    /** 
     * Define simple inline accessors function for the specified member
     * @showcontent
     */
#define QTLUA_PROPERTY_ACCESSORS(member)	\
    QTLUA_PROPERTY_ACCESSOR_GET(member)		\
    QTLUA_PROPERTY_ACCESSOR_SET(member)


    /** 
     * Define a lua get accessor function for the specified member
     * which relies on a regular C++ get accessor functions.  @showcontent
     */
#define QTLUA_PROPERTY_ACCESSOR_F_GET(member)			\
    inline QtLua::Value lua_get_##member(QtLua::State *ls)	\
    {								\
      return QtLua::Value(ls, get_##member());			\
    }

    /** 
     * Define a lua set accessor function for the specified member
     * which relies on a regular C++ set accessor functions.  @showcontent
     */
#define QTLUA_PROPERTY_ACCESSOR_F_SET(member)				\
    inline void lua_set_##member(QtLua::State *ls, const QtLua::Value &value) \
    {									\
      set_##member(value);						\
    }

    /** 
     * Define lua accessors functions for the specified member which
     * rely on regular C++ accessors.  @showcontent
     */
#define QTLUA_PROPERTY_ACCESSORS_F(member)		\
    QTLUA_PROPERTY_ACCESSOR_F_GET(member)		\
    QTLUA_PROPERTY_ACCESSOR_F_SET(member)

    /** 
     * Declare a member of given type and define lua
     * accessor functions for the specified member. This is a
     * convenience macro, member and accessor functions can be defined
     * directly.  @showcontent
     */
#define QTLUA_PROPERTY(type, member)		\
  type member;					\
  QTLUA_PROPERTY_ACCESSORS(member);

    /** 
     * Declare a member of given type and define a lua
     * get accessor function for the specified member.  @showcontent
     * @see #QTLUA_PROPERTY
     */
#define QTLUA_PROPERTY_GET(type, member)	\
  type member;					\
  QTLUA_PROPERTY_ACCESSOR_GET(member);

    /** 
     * Declare a member of given type and define a lua
     * set accessor function for the specified member.  @showcontent
     * @see #QTLUA_PROPERTY
     */
#define QTLUA_PROPERTY_SET(type, member)	\
  type member;					\
  QTLUA_PROPERTY_ACCESSOR_SET(member);

    /**
     * Property table entry with get and set accessors.
     */
#define QTLUA_PROPERTY_ENTRY(class_name, name, member)			\
  { name, &class_name::lua_set_##member, &class_name::lua_get_##member }

    /**
     * Property table entry with get accessor only.
     */
#define QTLUA_PROPERTY_ENTRY_GET(class_name, name, member)	\
  { name, 0, &class_name::lua_get_##member }

    /**
     * Property table entry with set accessor only.
     */
#define QTLUA_PROPERTY_ENTRY_SET(class_name, name, member)	\
  { name, &class_name::lua_set_##member, 0 }

    /**
     * Property table entry with user defined lua accessor functions.
     */
#define QTLUA_PROPERTY_ENTRY_U(class_name, name, get, set)	\
  { name, &class_name::set, &class_name::get }

    /**
     * Property table entry with user defined lua get accessor function only.
     */
#define QTLUA_PROPERTY_ENTRY_U_GET(class_name, name, get)	\
  { name, 0, &class_name::get }

    /**
     * Property table entry with user defined lua set accessor function only.
     */
#define QTLUA_PROPERTY_ENTRY_U_SET(class_name, name, set)	\
  { name, &class_name::set, 0 }

  };
}

#endif

