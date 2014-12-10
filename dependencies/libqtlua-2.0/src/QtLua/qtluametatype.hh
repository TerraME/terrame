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

    Copyright (C) 2011, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#ifndef QTLUAMETATYPE_HH_
#define QTLUAMETATYPE_HH_

#include <string>

#include <QMetaObject>
#include <QMetaType>
#include <QMap>

#include "qtluavalue.hh"
#include "internal/qtluaqobjectwrapper.hh"

/* related stuff in internal/qtluamember.hh */

namespace QtLua {

  template <typename X>
  class MetaType;

  /** @internal */
  typedef MetaType<void> metatype_void_t;
  /** @internal */
  typedef QMap<int, metatype_void_t* > metatype_map_t;
  /** @internal */
  extern metatype_map_t types_map;

  /**
   * @short Register Lua to Qt meta types conversion functions
   * @header QtLua/Value
   * @module {Base}
   *
   * This class can be used to register conversion functions used by
   * QtLua to convert between Lua values and C++ types registered as
   * Qt meta types. It enables use of user defined types for @ref QObject
   * properties and slot parameters.
   *
   * Consider the following user defined struct and @ref QObject properties:
   *
   * @example examples/cpp/types/myobject.hh:3
   *
   * The following code shows how to write conversion handler class
   * to handle the @tt Mystruct C++ type as a table value on the lua side:
   *
   * @example examples/cpp/types/myobject.hh:1
   *
   * The conversion handler and the Qt meta type will be registered on
   * class instantiation:
   *
   * @example examples/cpp/types/meta.cc:1
   *
   * Moreover, a template class with builtin conversion functions is
   * available to readily handle @ref QObject pointer cases:
   *
   * @example examples/cpp/types/myobject.hh:2
   * @example examples/cpp/types/meta.cc:2
   *
   * @see qRegisterMetaType @see #QTLUA_METATYPE
   * @see #QTLUA_METATYPE_ID @see #QTLUA_METATYPE_QOBJECT
   */
  template <typename X>
  class MetaType
  {
    friend class QMetaValue;

  protected:
    /** Register a conversion handler for an already registered Qt
	meta type. */
    MetaType(int type);

    /** Register a conversion handler @b and qt meta type (using the
	@ref qRegisterMetaType function). */
    MetaType(const char *type_name);

    /** Unregister conversion handler */
    ~MetaType();

    /** This function must be implemented to converts a C++ value to a
	lua value. */
    virtual Value qt2lua(State *ls, const X *qtvalue) = 0;

    /** This function must be implemented to converts a lua value to a
	C++ value.  @return true on success. */
    virtual bool  lua2qt(X *qtvalue, const Value &luavalue) = 0;

    /** @showcontent This macro defines a type conversion handler
	class. Class instantiation will also take care of registering
	the meta type to Qt. @see MetaType */
#define QTLUA_METATYPE(name, typename_)				\
    struct name							\
      : public QtLua::MetaType<typename_>			\
    {								\
      name()							\
	: QtLua::MetaType<typename_>(#typename_) {}		\
								\
      inline QtLua::Value qt2lua(QtLua::State *ls,		\
				 typename_ const * qtvalue);	\
      inline bool lua2qt(typename_ *qtvalue,			\
			 const QtLua::Value &luavalue);		\
    };

    /** @showcontent This macro defines a type conversion handler
	class for an existing Qt meta type id. @see MetaType */
#define QTLUA_METATYPE_ID(name, typename_, typeid_)		\
    struct name							\
      : public QtLua::MetaType<typename_>			\
    {								\
      name()							\
	: QtLua::MetaType<typename_>((int)typeid_) {}		\
								\
      inline QtLua::Value qt2lua(QtLua::State *ls,		\
				 typename_ const * qtvalue);	\
      inline bool lua2qt(typename_ *qtvalue,			\
			 const QtLua::Value &luavalue);		\
    };

    /** This macro defines a type conversion class along with its
	handler functions able to convert @ref QObject pointers
	values. The @tt class_ parameter is the bare class name
	without star. @see MetaType */
#define QTLUA_METATYPE_QOBJECT(name, class_)		\
    typedef QtLua::MetaTypeQObjectStar<class_> name;

    /** @hidden */
    int get_type();
  private:
    MetaType();
    int _type;
    const char *_typename;
  };

  /** @hidden */
  template <class X>
  class MetaTypeQObjectStar
    : public MetaType<X*>
  {
  public:
    MetaTypeQObjectStar()
      : MetaType<X*>((std::string(X::staticMetaObject.className())+"*").c_str())
    {
    }

  private:
    inline QtLua::Value qt2lua(QtLua::State *ls, X* const * qtvalue);
    inline bool lua2qt(X** qtvalue, const QtLua::Value &luavalue);
  };

}

#endif

