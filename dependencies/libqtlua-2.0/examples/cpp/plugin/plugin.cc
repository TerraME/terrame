
/* anchor 1 */
#include <QtLua/Function>
#include <QtLua/Plugin>

#include "plugin.hh"

#if QT_VERSION < 0x050000
Q_EXPORT_PLUGIN2(example, ExamplePlugin);
#endif

QTLUA_FUNCTION(foo, "The foo function", "No help available")
{
  Q_UNUSED(args);
  return QtLua::Value(ls, "result");
}

void ExamplePlugin::register_members(QtLua::Plugin &plugin)
{
  QTLUA_PLUGIN_FUNCTION_REGISTER(plugin, foo);
}
/* anchor end */

struct LoadUnload
{
  LoadUnload()
  {
    qDebug("example plugin loaded");
  }

  ~LoadUnload()
  {
    qDebug("example plugin unloaded");
  }
} load_unload;

