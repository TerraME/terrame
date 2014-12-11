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


#ifndef QTLUAPLUGIN_HH_
#define QTLUAPLUGIN_HH_

#include <QtPlugin>
#include <QPluginLoader>
#include <QMap>

#include "qtluaqhashproxy.hh"
#include "qtluastring.hh"
#include "qtluauserdata.hh"

namespace QtLua {

  class Function;

  /** @internal */
  typedef QMap<String, UserData*> plugin_map_t;

  /**
   * @short QtLua plugin class
   * @header QtLua/Plugin
   * @module {Base}
   * @see PluginInterface
   *
   * This class allows easy development and loading of Qt plugins
   * which can be handled from lua scripts.
   *
   * These plugins must use the @ref PluginInterface interface. They may
   * implement additional Qt plugin interfaces which can be queried with
   * the @ref api function from C++ code.
   *
   * These plugins are designed to contain @ref Function objects which can
   * be invoked from lua.
   *
   * @ref Function objects contained in plugin library must be
   * registered on the @ref Plugin object. This is done on @ref Plugin
   * creation from the @ref PluginInterface::register_members function.
   * This function must invoke the @ref #QTLUA_PLUGIN_FUNCTION_REGISTER
   * macro for each @ref Function to register.
   *
   * An internal @ref Plugin::Loader {plugin loader} object is
   * allocated and referenced by the @ref Plugin object so that the Qt
   * plugin is unloaded when the object is garbage collected. @ref
   * Function objects invoke the @ref Refobj::ref_delegate function on
   * the @ref Plugin object when registered. This ensure references to
   * plugin functions will keep the plugin loeaded.
   *
   * The @ref Plugin object can be copied to a lua table containing
   * all registered @ref Function objects by using the @ref to_table
   * function in C++ or the @tt - operator in lua. When used that way,
   * there is no need to expose or keep the @ref Plugin object once
   * the plugin has been loaded.
   *
   * The @ref QtLuaLib lua library provides a @tt{plugin()} lua
   * function which returns a @ref Plugin userdata object for a given plugin
   * file name. The platform dependent plugin file name extension will
   * be appended automatically. The returned @ref Plugin object may be
   * converted directly to a lua table using the @tt - lua operator.
   *
   * @section {Example}
   * Here is the code of an example plugin. The header file implements the Qt plugin interface:
   * @example examples/cpp/plugin/plugin.hh:1
   *
   * The plugin source file registers a @ref Function object:
   * @example examples/cpp/plugin/plugin.cc:1
   *
   * Here is a C++ example of plugin use:
   * @example examples/cpp/plugin/plugin_load.cc:1
   * @end section
   */

  class Plugin : public QHashProxyRo<plugin_map_t>
  {
    friend class Function;
  public:

    QTLUA_REFTYPE(Plugin);

    /** Load a new plugin */
    Plugin(const String &filename);

    ~Plugin();

    /** Convert @ref Plugin object to lua table */
    Value to_table(State *ls) const;

    /** Get instance of the requested interface type. Return 0 if no
	such interface is available in the plugin. */
    template <class interface>
    inline interface *api() const;

    /** Get platform dependent plugin file name suffix */
    static const String & get_plugin_ext();

/** This macro registers a @ref Function object on a @ref Plugin
    object. It must be used in the @ref PluginInterface::register_members function */
#define QTLUA_PLUGIN_FUNCTION_REGISTER(plugin, name)	\
  (new QtLua_Function_##name)->register_(plugin, #name)

  private:

    /**
     * @short Ref counted plugin loader object
     * @internal 
     */
    struct Loader : public QPluginLoader, public UserData
    {
      QTLUA_REFTYPE(Loader);
      Loader(const String &filename);
      ~Loader();
    };

    void completion_patch(String &path, String &entry, int &offset);

    plugin_map_t	_map;
    Ref<Loader>		_loader;
  };

  /**
   * @short QtLua plugin interface
   * @header QtLua/Plugin
   * @module {Base}
   * @see Plugin
   *
   * This class describes the interface which must be implemented
   * to write plugins compatible with the @ref Plugin class.
   */

  class PluginInterface
  {
  public:
    virtual ~PluginInterface() { }

    /** Register all plugin members, called on @ref Plugin
	initialization.  This function must contains invocations of
	the @ref #QTLUA_PLUGIN_FUNCTION_REGISTER macro. */
    virtual void register_members(Plugin &plugin) = 0;
  };

}

Q_DECLARE_INTERFACE(QtLua::PluginInterface, "QtLua.PluginInterface/2.0")

#endif

