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

#ifndef QTLUAMETACACHE_HH_
#define QTLUAMETACACHE_HH_

#include <QMap>
#include <QHash>

#include <QtLua/Ref>
#include <QtLua/FunctionSignature>

namespace QtLua {

  class MetaCache;
  class QObjectWrapper;
  class Member;

  typedef QMap<String, Ref<Member> > member_cache_t;
  typedef QHash<const QMetaObject *, MetaCache> meta_cache_t;

/**
 * @short Cache of existing Qt meta member wrappers
 * @header internal/MetaCache
 * @module {QObject wrapping}
 * @internal
 *
 * Qt meta properties, enums and methods are constant as described by
 * @ref QMetaObject objects. These meta members are exposed to lua
 * through wrapper objects. This class manages a cache of already
 * created @ref Member based wrappers.
 */

  class MetaCache
  {
    friend class QObjectWrapper;

    MetaCache(const QMetaObject *mo, const QMetaObject *supreme_mo, bool auto_property);

  public:
    /** Copy constructor */
    inline MetaCache(const MetaCache &mc);
    /** Create cache meta information for a QMetaObject with supreme QMetaObject which limit member access. */
    static MetaCache & create_meta(const QMetaObject *mo, const QMetaObject *supreme_mo, bool auto_property);
    /** Add static function to existed cache meta information. */
    static bool add_static_function(const QMetaObject *mo, const String &key, FunctionSignature func, QMetaType::Type argt[], int count);
    static bool add_static_function(const QMetaObject *mo, const String &key, FunctionSignature func, const QList<String> &argv);
    /** Get cache meta information for a QObject */
    inline static MetaCache & get_meta(const QObject &obj);
    /** Get cache meta information for a QMetaObject */
    static MetaCache & get_meta(const QMetaObject *mo);
    /** Get meta object name by className() or classInfo("LuaName") */
    static String get_meta_name(const QMetaObject *mo);
    /** Get index of toString slot which costum print() result*/
    static int get_index_toString(const QObject &obj);
    /** Get index of getDP slot which get dynamic property*/
    static int get_index_getDP(const QObject &obj);
    /** Get index of setDP slot which set dynamic property*/
    static int get_index_setDP(const QObject &obj);

    /** Recursively search for memeber in class and parent classes */
    Ref<Member> get_member(const String &name) const;
    /** Recursively search for memeber in class and parent classes, throw if not found */
    inline Ref<Member> get_member_throw(const String &name) const;
    /** Recursively search for memeber in class and parent classes and
	try to cast to given type, throw if fail. */
    template <class X>
    typename X::ptr get_member_throw(const String &name) const;

    /** Recursively search for enum value in class and parent classes, return -1 if not found */
    int get_enum_value(const String &name) const;

    /** Get member table */
    inline const member_cache_t & get_member_table() const;

    /** Get associated QMetaObject pointer */
    inline const QMetaObject * get_meta_object() const;

    /** Get supreme QMetaObject pointer for current QMetaObject pointer which should not affect others */
    inline const QMetaObject * get_supreme_meta_object() const;

    /** Get index of slot toString for current QMetaObject */
    int get_index_toString() const;

    /** Get index of slot getDP for current QMetaObject */
    int get_index_getDP() const;

    /** Get index of slot setDP for current QMetaObject */
    int get_index_setDP() const;

    /** Can use property() setProperty()*/
    bool can_auto_property() const;
    void enable_auto_property(bool enable);

  private:
    member_cache_t _member_cache;
    const QMetaObject *_mo;
    const QMetaObject *_supreme_mo;
    static meta_cache_t _meta_cache;
    //classinfo "LuaName"
    String _lua_name;
    //index of slots
    int _index_toString;
    int _index_setDP;
    int _index_getDP;
    //auto set/get property, will be override if has setDP/getDP
    int _auto_property;
  };

}

#endif

