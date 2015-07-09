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

#include <QSet>
#include <QMetaMethod>

#include <internal/Method>
#include <internal/Enum>
#include <internal/Property>
#include <internal/MetaCache>
#include <internal/StaticFunction>

namespace QtLua {

  meta_cache_t MetaCache::_meta_cache;

  MetaCache::MetaCache(const QMetaObject *mo, const QMetaObject *supreme_mo, bool auto_property)
    : _mo(mo), _supreme_mo(supreme_mo),
      _index_toString(-1), _index_setDP(-1), _index_getDP(-1),
      _auto_property(auto_property)
  {
    //get Lua name if exist
    {
      int index = _mo->indexOfClassInfo("LuaName");
      if(index != -1 && _mo->classInfoOffset() <= index)
          _lua_name = _mo->classInfo(index).value();
      else _lua_name = _mo->className();
    }
    int method_offset = _supreme_mo->methodOffset();
    //get index of toString
    {
      int index = _mo->indexOfMethod("toString()");
      if(index != -1 && method_offset <= index)
        {
          if(mo->method(index).returnType() == QMetaType::QString)
              _index_toString = index;
        }
    }
    //get index of getDP
    {
      int index = _mo->indexOfMethod("getDP(QByteArray)");
      if(index != -1 && method_offset <= index)
        {
          if(mo->method(index).returnType() == QMetaType::QVariant)
              _index_getDP = index;
        }
    }
    //get index of setDP
    {
      int index = _mo->indexOfMethod("setDP(QByteArray,QVariant)");
      if(index != -1 && method_offset <= index)
        {
          if(mo->method(index).returnType() == QMetaType::Void)
              _index_setDP = index;
        }
    }

    // Fill a set with existing member names in parent classes to
    // detect names collisions

    QSet<String> existing;

    for (const QMetaObject *tmp = mo->superClass(); tmp; tmp = tmp->superClass())
      {
	const member_cache_t &mt = get_meta(tmp).get_member_table();

	for (member_cache_t::const_iterator i = mt.begin(); i != mt.end(); i++)
	  existing.insert(i.key());
      }

    // Add method members
    for (int i = 0; i < mo->methodCount(); i++)
      {
	int index = mo->methodOffset() + i;
	QMetaMethod mm = mo->method(index);

#if QT_VERSION < 0x050000
	if (!mm.signature())
	  continue;
	String signature(mm.signature());
#else
	String signature(mm.methodSignature());
	if (signature.isNull())
	  continue;	  
#endif

	String name(signature.constData(), signature.indexOf('('));
        //if collision, assigned new name
	while (existing.contains(name) || _member_cache.contains(name))
	  name += "_m";

	_member_cache.insert(name, QTLUA_REFNEW(Method, mo, index));
      }

    // Add enum members
    for (int i = 0; i < mo->enumeratorCount(); i++)
      {
	int index = mo->enumeratorOffset() + i;
	QMetaEnum me = mo->enumerator(index);

	if (!me.isValid())
	  continue;

	String name(me.name());

	while (existing.contains(name) || _member_cache.contains(name))
	  name += "_e";

	_member_cache.insert(name, QTLUA_REFNEW(Enum, mo, index));
      }

    // Add property members
    for (int i = 0; i < mo->propertyCount(); i++)
      {
	int index = mo->propertyOffset() + i;
	QMetaProperty mp = mo->property(index);

	if (!mp.isValid())
	  continue;

	String name(mp.name());

	while (existing.contains(name) || _member_cache.contains(name))
	  name += "_p";

	_member_cache.insert(name, QTLUA_REFNEW(Property, mo, index));
      }
  }

  Member::ptr MetaCache::get_member(const String &name) const
  {
    const MetaCache *mc = this;
    const QMetaObject *meta = _mo;
    Member::ptr m = mc->_member_cache.value(name);
    while(!m.valid() && mc->_mo != _supreme_mo) {
        meta = mc->_mo->superClass();
        if(meta) {
            mc = &MetaCache::get_meta(meta);
            m = mc->_member_cache.value(name);
        }
        else break;
    }

    return m;
  }

  int MetaCache::get_enum_value(const String &name) const
  {
    for (const QMetaObject *mo = _mo; mo;
         mo = (mo == _supreme_mo) ? 0x0 : mo->superClass())
      {
	for (int i = 0; i < mo->enumeratorCount(); i++)
	  {
	    int index = mo->enumeratorOffset() + i;
	    QMetaEnum me = mo->enumerator(index);

            if(!me.isValid()) continue;

	    int value = me.keyToValue(name);
            if(0 <= value) return value;
	  }
      }

    return -1;
  }

  MetaCache & MetaCache::create_meta(const QMetaObject *mo, const QMetaObject *supreme_mo, bool auto_property)
  {
    return _meta_cache.insert(mo, MetaCache(mo, supreme_mo, auto_property)).value();
  }

  bool MetaCache::add_static_function(const QMetaObject *mo, const String &key, FunctionSignature func, QMetaType::Type argt[], int count)
  {
      meta_cache_t::iterator i = _meta_cache.find(mo);
      if(i != _meta_cache.end()) {
          MetaCache &mc = i.value();
          mc._member_cache.insert(key, QTLUA_REFNEW(StaticFunction, mo, key, func, argt, count));
          return true;
      }
      else return false;
  }

  bool MetaCache::add_static_function(const QMetaObject *mo, const String &key, FunctionSignature func, const QList<String> &argv)
  {
      meta_cache_t::iterator i = _meta_cache.find(mo);
      if(i != _meta_cache.end()) {
          MetaCache &mc = i.value();
          mc._member_cache.insert(key, QTLUA_REFNEW(StaticFunction, mo, key, func, argv));
          return true;
      }
      else return false;
  }

  MetaCache & MetaCache::get_meta(const QMetaObject *mo)
  {
    meta_cache_t::iterator i = _meta_cache.find(mo);

    if (i != _meta_cache.end())
      return i.value();

    return _meta_cache.insert(mo, MetaCache(mo, &QObject::staticMetaObject, false)).value();
  }

  String MetaCache::get_meta_name(const QMetaObject *mo)
  {
    MetaCache &mc = get_meta(mo);
    return mc._lua_name;
  }

  int MetaCache::get_index_toString(const QObject &obj)
  {
    MetaCache &mc = get_meta(obj);
    return mc._index_toString;
  }

  int MetaCache::get_index_getDP(const QObject &obj)
  {
    MetaCache &mc = get_meta(obj);
    return mc._index_getDP;
  }

  int MetaCache::get_index_setDP(const QObject &obj)
  {
    MetaCache &mc = get_meta(obj);
    return mc._index_setDP;
  }

  int MetaCache::get_index_toString() const
  {
    return _index_toString;
  }

  int MetaCache::get_index_getDP() const
  {
    return _index_getDP;
  }

  int MetaCache::get_index_setDP() const
  {
    return _index_setDP;
  }

  bool MetaCache::can_auto_property() const
  {
      return _auto_property;
  }

  void MetaCache::enable_auto_property(bool enable)
  {
      _auto_property = enable;
  }
}

