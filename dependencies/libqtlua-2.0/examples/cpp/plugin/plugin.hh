
#ifndef EXAMPLE_PLUGIN_HH_
#define EXAMPLE_PLUGIN_HH_

/* anchor 1 */
#include <QObject>
#include <QtLua/Plugin>

class ExamplePlugin : public QObject, public QtLua::PluginInterface
{
  Q_OBJECT
  Q_INTERFACES(QtLua::PluginInterface)
#if QT_VERSION >= 0x050000
  Q_PLUGIN_METADATA(IID "qtlua.ExamplePlugin")
#endif

public:

  void register_members(QtLua::Plugin &plugin);
};
/* anchor end */

#endif

