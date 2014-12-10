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

    Copyright (C) 2008-2013, Alexandre Becoulet <alexandre.becoulet@free.fr>

*/

#include "config.hh"

#ifdef HAVE_QT_UITOOLS
# include <QUiLoader>
#endif

#include <QFile>
#include <QWidget>

#include <QLayout>
#include <QBoxLayout>
#include <QGridLayout>
#include <QFormLayout>
#include <QColorDialog>
#include <QFileDialog>
#include <QErrorMessage>
#include <QInputDialog>
#include <QMessageBox>
#include <QApplication>
#include <QTranslator>
#include <QActionGroup>
#include <QMainWindow>
#include <QDockWidget>
#include <QToolBar>
#include <QStackedWidget>
#include <QToolBar>
#include <QScrollArea>
#include <QSplitter>
#include <QMdiArea>

#if QT_VERSION < 0x050000
# include <QWorkspace>
#endif

#include <QAbstractItemView>
#include <QComboBox>

#include <QMenu>
#include <QMenuBar>
#include <QStatusBar>

#include <QtLua/State>
#include <QtLua/Function>
#include <internal/QObjectWrapper>
#include <QtLua/QHashProxy>
#include <QtLua/ItemViewDialog>
#include <QtLua/TableGridModel>
#include <QtLua/TableTreeModel>
#include <QtLua/LuaModel>

#include <internal/Method>
#include <internal/MetaCache>
#include <internal/QMetaObjectWrapper>

#include "qtluaqtlib.hh"

namespace QtLua {

  typedef QMap<String, QMetaObjectWrapper > qmetaobject_table_t;

  class QMetaObjectTable
    : public QHashProxyRo<qmetaobject_table_t>
    , public QObject
  {
  public:
    QMetaObjectTable()
      : QHashProxyRo<qmetaobject_table_t>(_mo_table)
    {
      for (const meta_object_table_s *me = meta_object_table; me->_mo; me++)
	{
	  String name(me->_mo->className());
	  name.replace(':', '_');
	  _mo_table.insert(name, QMetaObjectWrapper(me->_mo, me->_creator));
	}

      _mo_table.insert("Qt", QMetaObjectWrapper(&staticQtMetaObject));
      _mo_table.insert("QSizePolicy", QMetaObjectWrapper(&QtLua::SizePolicy::staticMetaObject));
    }

    qmetaobject_table_t _mo_table;
  };

  static QMetaObjectTable qt_meta;

  void qtlib_register_meta(const QMetaObject *mo, qobject_creator *creator)
  {
    String name(mo->className());
    name.replace(':', '_');
    qt_meta._mo_table.insert(name, QMetaObjectWrapper(mo, creator));
  }


  ////////////////////////////////////////////////// qobjects


  QTLUA_FUNCTION(connect, "Connect a Qt signal to a Qt slot or lua function.",
		 "usage: qt.connect(qobjectwrapper, \"qt_signal_signature()\", qobjectwrapper, \"qt_slot_signature()\")\n"
		 "       qt.connect(qobjectwrapper, \"qt_signal_signature()\", lua_function)\n")
  {
    meta_call_check_args(args, 3, 4, Value::TUserData, Value::TString, Value::TNone, Value::TString);

    QObjectWrapper::ptr sigqow = args[0].to_userdata_cast<QObjectWrapper>();

    String signame = args[1].to_string();
    QObject &sigobj = sigqow->get_object();

    int sigindex = sigobj.metaObject()->indexOfSignal(signame.constData());
    if (sigindex < 0)
      QTLUA_THROW(qt.connect, "No such signal `%'.", .arg(signame));

    switch (args.size())
      {
      case 3: {
	// connect qt signal to lua function
	sigqow->_lua_connect(sigindex, args[2]);
	break;
      }

      case 4: {
	// connect qt signal to qt slot
	String slotname = args[3].to_string();
	QObject &sloobj = args[2].to_userdata_cast<QObjectWrapper>()->get_object();	

	int slotindex = sloobj.metaObject()->indexOfSlot(slotname.constData());
	if (slotindex < 0)
	  QTLUA_THROW(qt.connect, "No such slot `%'.", .arg(slotname));

	if (!QMetaObject::checkConnectArgs(signame.constData(), slotname.constData()))
	  QTLUA_THROW(qt.connect, "Incompatible argument types between signal `%' and slot `%'.",
		      .arg(signame.constData()).arg(slotname.constData()));

	if (!QMetaObject::connect(&sigobj, sigindex, &sloobj, slotindex))
	  QTLUA_THROW(qt.connect, "Unable to connect signal to slot.");
      }
      }

    return Value::List();
  }


  QTLUA_FUNCTION(disconnect, "Disconnect a Qt signal",
		 "usage: qt.disconnect(qobjectwrapper, \"qt_signal_signature()\", qobjectwrapper, \"qt_slot_signature()\")\n"
		 "       qt.disconnect(qobjectwrapper, \"qt_signal_signature()\", lua_function)\n"
		 "       qt.disconnect(qobjectwrapper, \"qt_signal_signature()\")\n")
  {
    meta_call_check_args(args, 2, 4, Value::TUserData, Value::TString, Value::TNone, Value::TString);

    QObjectWrapper::ptr sigqow = args[0].to_userdata_cast<QObjectWrapper>();

    String signame = args[1].to_string();
    QObject &sigobj = sigqow->get_object();

    int sigindex = sigobj.metaObject()->indexOfSignal(signame.constData());
    if (sigindex < 0)
      QTLUA_THROW(qt.disconnect, "No such signal `%'.", .arg(signame));

    switch (args.size())
      {
      case 2:
	// disconnect qt signal from all lua functions
	sigqow->_lua_disconnect_all(sigindex);
	return Value::List();

      case 3:
	// disconnect qt signal from lua function
	return Value(ls, (Value::Bool)sigqow->_lua_disconnect(sigindex, args[2]));

      case 4: {
	// disconnect qt signal from qt slot
	String slotname = args[3].to_string();
	QObject &sloobj = args[2].to_userdata_cast<QObjectWrapper>()->get_object();	

	int slotindex = sloobj.metaObject()->indexOfSlot(slotname.constData());
	if (slotindex < 0)
	  QTLUA_THROW(qt.disconnect, "No such slot `%'.", .arg(slotname));

	return Value(ls, (Value::Bool)QMetaObject::disconnect(&sigobj, sigindex, &sloobj, slotindex));
      }

      }

    abort();
  }


  QTLUA_FUNCTION(connect_slots_by_name, "Invoke the QMetaObject::connectSlotsByName function.",
		 "usage: qt.connect_slots_by_name(qobjectwrapper)\n")
  {
    QMetaObject::connectSlotsByName(get_arg_qobject<QObject>(args, 0));

    return Value(ls);
  }

  QTLUA_FUNCTION(meta_type, "Translate between a registered Qt type numeric handle and associated type name.",
		 "usage: qt.meta_type(\"QTypeName\")\n"
		 "       qt.meta_type(type_handle)\n")
  {
    meta_call_check_args(args, 1, 1, Value::TNone);

    switch (args[0].type())
      {
      case Value::TString: {
	String n(args[0].to_string());
	if (int t = QMetaType::type(n.constData()))
	  return Value(ls, t);
	QTLUA_THROW(qt.meta_type, "Unable to resolve Qt meta type `%'.", .arg(n));
      }

      case Value::TNumber: {
	int t = args[0].to_integer();
	if (const char *n = QMetaType::typeName(t))
	  return Value(ls, n);
	QTLUA_THROW(qt.meta_type, "Unable to resolve Qt meta type handle `%'.", .arg(t));
      }

      default:
	QTLUA_THROW(qt.meta_type, "Bad argument type, string or number expected.");
	break;
      }
  }


  QTLUA_FUNCTION(new_qobject, "Dynamically create a new QObject.",
		 "usage: qt.new_qobject( qt.meta.QClassName, [ Constructor arguments ] )\n")
  {
    QMetaObjectWrapper::ptr mow = get_arg_ud<QMetaObjectWrapper>(args, 0);

    return Value(ls, mow->create(args), true, true);
  }


  ////////////////////////////////////////////////// ui


  QTLUA_FUNCTION(load_ui, "Load a Qt ui file.",
		 "usage: qt.ui.load_ui(\"file.ui\", [ parent ])\n")
  {
#ifdef HAVE_QT_UITOOLS
    static QUiLoader uil;

    meta_call_check_args(args, 1, 2, Value::TString, Value::TUserData);
    QWidget *p = 0;

    if (args.size() > 1)
      p = args[0].to_qobject_cast<QWidget>();

    QFile f(args[0].to_qstring());
    QObject *w = uil.load(&f, p);

    if (!w)
      QTLUA_THROW(qt.ui.load_ui, "Unable to load the `%' ui file.", .arg(f.fileName()));

    return Value(ls, w, true, true);
#else
    QTLUA_THROW(new_qobject, "QtLua has been compiled without support for Qt uitools module.");
#endif
  }


  QTLUA_FUNCTION(new_widget, "Dynamically create a new Qt Widget using QUiLoader.",
		 "usage: qt.ui.new_widget(\"QtClassName\", [ \"name\", parent ] )\n")
  {
#ifdef HAVE_QT_UITOOLS
    static QUiLoader uil;

    meta_call_check_args(args, 1, 3, Value::TString, Value::TString, Value::TUserData);
    QWidget *p = 0;
    String classname(args[0].to_string());
    String name;

    if (args.size() > 2)
      p = args[2].to_qobject_cast<QWidget>();

    if (args.size() > 1)
      name = args[1].to_string();

    QObject *w = uil.createWidget(classname.to_qstring(), p, name.to_qstring());

    if (!w)
      QTLUA_THROW(qt.ui.new_widget, "Unable to create a widget of type `%'.", .arg(classname));

    return Value(ls, w, true, true);
#else
    QTLUA_THROW(new_qobject, "QtLua has been compiled without support for Qt uitools module.");
#endif
  }

  QTLUA_FUNCTION(layout_add, "Add an item to a QLayout or set QLayout of a QWidget.",
		 "usage: qt.ui.layout_add( box_layout, widget|layout )\n"
		 "       qt.ui.layout_add( grid_layout, widget|layout, row, column, [ row_span, col_span, align ] )\n"
		 "       qt.ui.layout_add( form_layout, widget|layout, row, column, [ col_span ] )\n"
		 "       qt.ui.layout_add( form_layout, text, widget|layout )\n"
		 "       qt.ui.layout_add( widget, layout )\n")
  {
    meta_call_check_args(args, 2, 0, Value::TUserData, Value::TNone);

    QObject *obj = get_arg_qobject<QObject>(args, 0);

    if (QFormLayout *la = dynamic_cast<QFormLayout*>(obj))
      {
	if (args[1].type() == Value::TString)
	  {
	    QObjectWrapper::ptr qow2 = get_arg_ud<QObjectWrapper>(args, 2);
	    QObject &item2 = qow2->get_object();

	    // QFormLayout::addRow ( const QString & labelText, QLayout * field )
	    if (QLayout *li = dynamic_cast<QLayout*>(&item2))
	      {
		qow2->set_delete(false);
		la->addRow(args[1].to_string(), li);
	      }

	    // QFormLayout::addRow ( const QString & labelText, QWidget * field )
	    else if (QWidget *w2 = dynamic_cast<QWidget*>(&item2))
	      {
		if (QLayout *ol = w2->layout())
		  ol->removeWidget(w2);
		la->addRow(args[1].to_string(), w2);
	      }
	    else
	      goto err;

	    return QtLua::Value(ls);
	  }
	else
	  {
	    QObjectWrapper::ptr qow = get_arg_ud<QObjectWrapper>(args, 1);
	    QObject &item = qow->get_object();

	    int row = get_arg<int>(args, 2);
	    int col = get_arg<int>(args, 3);
	    int col_span = get_arg<int>(args, 4, 1);
	    if (col + col_span > 2)
	      QTLUA_THROW(qt.ui.layout_add, "Bad QFormLayout spanning.");

	    QFormLayout::ItemRole role = (col_span > 1 ? QFormLayout::SpanningRole :
					  col ? QFormLayout::FieldRole : QFormLayout::LabelRole);

	    // QFormLayout::setLayout ( int row, ItemRole role, QLayout * layout )
	    if (QLayout *li = dynamic_cast<QLayout*>(&item))
	      {
		qow->set_delete(false);
		la->setLayout(row, role, li);
	      }

	    // QFormLayout::setWidget ( int row, ItemRole role, QWidget * widget )
	    else if (QWidget *w = dynamic_cast<QWidget*>(&item))
	      {
		if (QLayout *ol = w->layout())
		  ol->removeWidget(w);
		la->setWidget(row, role, w);
	      }
	    else
	      goto err;

	    return QtLua::Value(ls);
	  }
      }

    if (QGridLayout *la = dynamic_cast<QGridLayout*>(obj))
      {
	QObjectWrapper::ptr qow = get_arg_ud<QObjectWrapper>(args, 1);
	QObject &item = qow->get_object();

	int row = get_arg<int>(args, 2);
	int col = get_arg<int>(args, 3);
	int row_span = get_arg<int>(args, 4, 1);
	int col_span = get_arg<int>(args, 5, 1);
	int align = get_arg<int>(args, 6, 0);

	// QGridLayout::addLayout ( QLayout * layout, int row, int column, int rowSpan, int columnSpan, Qt::Alignment alignment )
	if (QLayout *li = dynamic_cast<QLayout*>(&item))
	  {
	    qow->set_delete(false);
	    la->addLayout(li, row, col, row_span, col_span, (Qt::Alignment)align);
	  }

	// QGridLayout::addWidget ( QWidget * widget, int row, int column, int rowSpan, int columnSpan, Qt::Alignment alignment )
	else if (QWidget *w = dynamic_cast<QWidget*>(&item))
	  {
	    if (QLayout *ol = w->layout())
	      ol->removeWidget(w);
	    la->addWidget(w, row, col, row_span, col_span, (Qt::Alignment)align);
	  }
	else
	  goto err;

	return QtLua::Value(ls);
      }

    if (QBoxLayout *la = dynamic_cast<QBoxLayout*>(obj))
      {
	QObjectWrapper::ptr qow = get_arg_ud<QObjectWrapper>(args, 1);
	QObject &item = qow->get_object();

	if (QLayout *li = dynamic_cast<QLayout*>(&item))
	  {
	    qow->set_delete(false);
	    la->addLayout(li);
	  }

	else if (QWidget *w = dynamic_cast<QWidget*>(&item))
	  {
	    if (QLayout *ol = w->layout())
	      ol->removeWidget(w);
	    la->addWidget(w);
	  }
	else
	  goto err;

	return QtLua::Value(ls);
      }

    if (QWidget *w = dynamic_cast<QWidget*>(obj))
      {
	QLayout *la = get_arg_qobject<QLayout>(args, 1);
	delete w->layout();
	w->setLayout(la);

	return QtLua::Value(ls);
      }

  err:
    QTLUA_THROW(qt.ui.layout_add, "Bad object type.");
  }


  QTLUA_FUNCTION(layout_spacer, "Add a spacer to a QLayout.",
		 "usage: qt.ui.layout_spacer( layout, width, height, h QSizePolicy, v QSizePolicy )\n")
  {
    meta_call_check_args(args, 3, 5, Value::TUserData, Value::TNumber, Value::TNumber, Value::TNumber, Value::TNumber);

    QLayout *la = args[0].to_qobject_cast<QLayout>();

    la->addItem(new QSpacerItem(get_arg<int>(args, 1),
				get_arg<int>(args, 2),
				(QSizePolicy::Policy)get_arg<int>(args, 3, QSizePolicy::Minimum),
				(QSizePolicy::Policy)get_arg<int>(args, 4, QSizePolicy::Minimum)));

    return QtLua::Value(ls);
  }

  
  ////////////////////////////////////////////////// translation


  QTLUA_FUNCTION(tr, "Translate utf8 text using the QCoreApplication::translate function.",
		 "usage: qt.tr(\"context\", \"text\", [ \"disambiguation\", n ])\n")
  {
    return Value(ls, QCoreApplication::translate(get_arg<String>(args, 0),
						 get_arg<String>(args, 1),
						 get_arg<String>(args, 2, ""),
#if QT_VERSION < 0x050000
						 QCoreApplication::UnicodeUTF8,
#endif
						 get_arg<int>(args, 3, -1)));
  }


  QTLUA_FUNCTION(translator, "Install a translation file and return associated QTranslator object.",
		 "usage: qt.translator(\"filename\")\n")
  {
    String filename(get_arg<String>(args, 0));
    QTranslator *qtr = new QTranslator();

    if (!qtr->load(filename))
      {
	delete qtr;
	QTLUA_THROW(qt.translator, "Unable to load the translation file `%'", .arg(filename));
      }

    QCoreApplication::installTranslator(qtr);
    return Value(ls, qtr, true, true);
  }


  ////////////////////////////////////////////////// menus
  

  QTLUA_FUNCTION(add_menu, "Add a new QMenu to a QMenu or QMenuBar.",
		 "usage: qt.ui.menu.add_menu( menu|menubar, \"text\", [ \"object_name\" ] )\n")
  {
    meta_call_check_args(args, 2, 3, Value::TUserData, Value::TString, Value::TString);

    QObject *obj = args[0].to_qobject();
    String text = args[1].to_string();
    QObject *result;

    if (QMenu *menu = dynamic_cast<QMenu*>(obj))
      result = menu->addMenu(text);
    else if (QMenuBar *menubar = dynamic_cast<QMenuBar*>(obj))
      result = menubar->addMenu(text);
    else
      QTLUA_THROW(qt.ui.menu.add_menu, "Bad object type.");

    if (args.size() > 2)
      result->setObjectName(args[2]);

    return QtLua::Value(ls, result, true, true);
  }


  QTLUA_FUNCTION(add_separator, "Add a separator QAction to a QMenu or QToolBar.",
		 "usage: qt.ui.menu.add_separator( menu|toolbar, [ \"name\" ] )\n")
  {
    meta_call_check_args(args, 1, 2, Value::TUserData, Value::TString);

    QObject *obj = args[0].to_qobject();
    QObject *result;

    if (QMenu *menu = dynamic_cast<QMenu*>(obj))
      result = menu->addSeparator();
    else if (QToolBar *tb = dynamic_cast<QToolBar*>(obj))
      result = tb->addSeparator();
    else
      QTLUA_THROW(qt.ui.menu.add_separator, "Bad object type.");

    if (args.size() > 1)
      result->setObjectName(args[1]);

    return QtLua::Value(ls, result, true, true);
  }


  QTLUA_FUNCTION(add_action, "Add a QAction to a QMenuBar, QMenu or QActionGroup.",
		 "usage: qt.ui.menu.add_action( menu|menubar|... , \"text\", [ \"name\" ] )\n")
  {
    meta_call_check_args(args, 2, 3, Value::TUserData, Value::TNone, Value::TString);

    QObject *obj = args[0].to_qobject();
    String text = args[1].to_string();
    QObject *result;

    if (QMenu *menu = dynamic_cast<QMenu*>(obj))
      result = menu->addAction(text);
    else if (QMenuBar *menubar = dynamic_cast<QMenuBar*>(obj))
      result = menubar->addAction(text);
    else if (QActionGroup *group = dynamic_cast<QActionGroup*>(obj))
      result = group->addAction(text);
    else if (QToolBar *tb = dynamic_cast<QToolBar*>(obj))
      result = tb->addAction(text);
    else
      QTLUA_THROW(qt.ui.menu.add_action, "Bad object type.");

    if (args.size() > 2)
      result->setObjectName(args[2].to_string());

    return QtLua::Value(ls, result, true, true);
  }

  QTLUA_FUNCTION(menu_attach, "Attach QAction, QActionGroup, QMenu, QMenuBar and QToolBar together.",
		 "usage: qt.ui.menu.attach( container, part )\n")
  {
    QObject *obj = get_arg_qobject<QObject>(args, 0);
    QObject *obj2 = get_arg_qobject<QObject>(args, 1);

    if (QAction *action = dynamic_cast<QAction*>(obj2))
      {
	if (QMenu *menu = dynamic_cast<QMenu*>(obj))
	  menu->addAction(action);
	else if (QMenuBar *menubar = dynamic_cast<QMenuBar*>(obj))
	  menubar->addAction(action);
	else if (QActionGroup *group = dynamic_cast<QActionGroup*>(obj))
	  group->addAction(action);
	else if (QToolBar *tb = dynamic_cast<QToolBar*>(obj))
	  tb->addAction(action);
	else
	  goto err;
      }
    else if (QMenu *submenu = dynamic_cast<QMenu*>(obj2))
      {
	if (QMenu *menu = dynamic_cast<QMenu*>(obj))
	  menu->addAction(submenu->menuAction());
	else if (QMenuBar *menubar = dynamic_cast<QMenuBar*>(obj))
	  menubar->addAction(submenu->menuAction());
	else
	  goto err;
      }
    else
      goto err;

    return QtLua::Value(ls);
  err:
    QTLUA_THROW(qt.ui.menu.attach, "Can not attach a `%' object to a `%' object.",
		.arg(obj2->metaObject()->className())
		.arg(obj->metaObject()->className()));
  }


  QTLUA_FUNCTION(new_action_group, "Create a new QActionGroup and add passed actions.",
		 "usage: qt.ui.menu.new_action_group( action [, action ...] )\n")
  {
    QAction *a[args.size()];

    for (int i = 0; i < args.size(); i++)
      a[i] = args[i].to_qobject_cast<QAction>();

    QActionGroup *result = new QActionGroup(0);
    for (int i = 0; i < args.size(); i++)
      result->addAction(a[i]);

    return QtLua::Value(ls, result, true, true);
  }

  QTLUA_FUNCTION(new_action, "Create a new QAction.",
		 "usage: qt.ui.menu.new_action( parent )\n")
  {
    return QtLua::Value(ls, new QAction(get_arg_qobject<QObject>(args, 0)), true, true);
  }

  QTLUA_FUNCTION(new_menu, "Create a new QMenu.",
		 "usage: qt.ui.menu.new_menu( parent )\n")
  {
    return QtLua::Value(ls, new QMenu(get_arg_qobject<QWidget>(args, 0)), true, true);
  }

  QTLUA_FUNCTION(remove, "Remove a QAction or QMenu action from a QWidget or QActionGroup.",
		 "usage: qt.ui.menu.remove( qaction|qmenu [, qwidget|qactiongroup ] )\n")
  {
    meta_call_check_args(args, 1, 2, Value::TUserData, Value::TUserData);

    QObject *obj = args[0].to_qobject();
    QObject *pobj;
    QAction *action;
    QMenu *menu = 0;

    if (args.size() > 1)
      pobj = args[1].to_qobject();
    else
      pobj = obj->parent();

    if ((action = dynamic_cast<QAction*>(obj)))
      ;
    else if ((menu = dynamic_cast<QMenu*>(obj)))
      action = menu->menuAction();
    else
      QTLUA_THROW(qt.ui.menu.remove, "Bad object type.");

    if (QWidget *w = dynamic_cast<QWidget*>(pobj))
      w->removeAction(action);
    else if (QActionGroup *group = dynamic_cast<QActionGroup*>(pobj))
      group->removeAction(action);
    else
      QTLUA_THROW(qt.ui.menu.remove, "Bad QWidget object type.");

    return QtLua::Value(ls);
  }

  ////////////////////////////////////////////////// main window

  QTLUA_FUNCTION(ui_attach, "Invoke setWidget or addWidget like functions on various widgets.",
		 "usage: qt.ui.attach( container, part, [ attributes ] )\n")
  {
    QObject *obj = get_arg_qobject<QObject>(args, 0);
    QObject *obj2 = get_arg_qobject<QObject>(args, 1);

    if (QMainWindow *mainwin = dynamic_cast<QMainWindow*>(obj))
      {
	if (QMenuBar *menubar = dynamic_cast<QMenuBar*>(obj2))
	  mainwin->setMenuBar(menubar);
	else if (QStatusBar *statusbar = dynamic_cast<QStatusBar*>(obj2))
	  mainwin->setStatusBar(statusbar);
	else if (QToolBar *toolbar = dynamic_cast<QToolBar*>(obj2))
	  mainwin->addToolBar(toolbar);
	else if (QDockWidget *dw = dynamic_cast<QDockWidget*>(obj2))
	  mainwin->addDockWidget((Qt::DockWidgetArea)get_arg<int>(args, 2, Qt::LeftDockWidgetArea), dw);
	else if (QWidget *w = dynamic_cast<QWidget*>(obj2))
	  mainwin->setCentralWidget(w);
	else
	  goto err;
      }
    else if (QWidget *w = dynamic_cast<QWidget*>(obj2))
      {
	if (QDockWidget *dw = dynamic_cast<QDockWidget*>(obj))
	  dw->setWidget(w);
	else if (QStackedWidget *x = dynamic_cast<QStackedWidget*>(obj))
	  x->addWidget(w);
	else if (QToolBar *x = dynamic_cast<QToolBar*>(obj))
	  x->addWidget(w);
	else if (QScrollArea *x = dynamic_cast<QScrollArea*>(obj))
	  x->setWidget(w);
	else if (QSplitter *x = dynamic_cast<QSplitter*>(obj))
	  x->addWidget(w);
	else if (QMdiArea *x = dynamic_cast<QMdiArea*>(obj))
	  x->addSubWindow(w);
#if QT_VERSION < 0x050000
	else if (QWorkspace *x = dynamic_cast<QWorkspace*>(obj))
	  x->addWindow(w);
#endif
	else
	  goto err;
      }
    else
      goto err;

    return QtLua::Value(ls);
  err:
    QTLUA_THROW(qt.ui.attach, "Can not attach a `%' to a `%' object.",
		.arg(obj2->metaObject()->className())
		.arg(obj->metaObject()->className()));
  }

  ////////////////////////////////////////////////// dialogs


  QTLUA_FUNCTION(get_existing_directory, "Wrap QFileDialog::getExistingDirectory function.",
		 "usage: qt.dialog.get_existing_directory( [ \"caption\", \"directory\", QFileDialog::Option ] )\n")
  {
    return Value(ls, QFileDialog::getExistingDirectory(QApplication::activeWindow(),
						       get_arg<QString>(args, 0, ""),
						       get_arg<QString>(args, 1, ""),
						       (QFileDialog::Option)get_arg<int>(args, 2, QFileDialog::ShowDirsOnly)
						       ));
  }


  QTLUA_FUNCTION(get_open_filename, "Wrap QFileDialog::getOpenFileName function.",
		 "usage: qt.dialog.get_open_filename( [ \"caption\", \"directory\", \"filter\", QFileDialog::Option ] )\n")
  {
    return Value(ls, QFileDialog::getOpenFileName(QApplication::activeWindow(),
						  get_arg<QString>(args, 0, ""),
						  get_arg<QString>(args, 1, ""),
						  get_arg<QString>(args, 2, ""), 0,
						  (QFileDialog::Option)get_arg<int>(args, 3, 0)
						  ));
  }

  QTLUA_FUNCTION(get_open_filenames, "Wrap QFileDialog::getOpenFileNames function.",
		 "usage: qt.dialog.get_open_filenames( [ \"caption\", \"directory\", \"filter\", QFileDialog::Option ] )\n")
  {
    return Value(ls, QFileDialog::getOpenFileNames(QApplication::activeWindow(),
						   get_arg<QString>(args, 0, ""),
						   get_arg<QString>(args, 1, ""),
						   get_arg<QString>(args, 2, ""), 0,
						   (QFileDialog::Option)get_arg<int>(args, 3, 0)
						   ));
  }


  QTLUA_FUNCTION(get_save_filename, "Wrap QFileDialog::getSaveFileName function.",
		 "usage: qt.dialog.get_save_filename( [ \"caption\", \"directory\", \"filter\", QFileDialog::Option] )\n")
  {
    return Value(ls, QFileDialog::getSaveFileName(QApplication::activeWindow(),
						  get_arg<QString>(args, 0, ""),
						  get_arg<QString>(args, 1, ""),
						  get_arg<QString>(args, 2, ""), 0,
						  (QFileDialog::Option)get_arg<int>(args, 3, 0)
						  ));
  }


  QTLUA_FUNCTION(get_color, "Wrap QColorDialog::getColor function, returns rgb triplet in [0, 255] range.",
		 "usage: qt.dialog.get_color( [ init_red, init_green, init_blue ] )\n")	 
  {
    QColor init(Qt::white);

    if (args.count() >= 3)
      init = QColor(get_arg<int>(args, 0, 0), get_arg<int>(args, 1, 0), get_arg<int>(args, 2, 0));

    QColor c = QColorDialog::getColor(init, QApplication::activeWindow());

    return c.isValid() ? Value::List(Value(ls, c.red()), Value(ls, c.green()), Value(ls, c.blue()))
      : Value::List();
  }


  QTLUA_FUNCTION(get_double, "Wrap QInputDialog::getDouble function.",
		 "usage: qt.dialog.get_double( [ \"title\", \"label\", value, min, max, decimals ] )\n")
  {
    bool ok;
    double v = QInputDialog::getDouble(QApplication::activeWindow(),
				       get_arg<QString>(args, 0, ""),
				       get_arg<QString>(args, 1, ""),
				       get_arg<double>(args, 2, 0),
				       get_arg<double>(args, 3, -2147483647),
				       get_arg<double>(args, 4, 2147483647),
				       get_arg<int>(args, 5, 1),
				       &ok
				       );
    return ok ? Value(ls, v) : Value(ls);
  }


  QTLUA_FUNCTION(get_integer, "Wrap QInputDialog::getInteger function.",
		 "usage: qt.dialog.get_integer( [ \"title\", \"label\", value, min, max, step ] )\n")
  {
    bool ok;
#if QT_VERSION < 0x050000
    int v = QInputDialog::getInteger(QApplication::activeWindow(),
#else
    int v = QInputDialog::getInt(QApplication::activeWindow(),
#endif
				     get_arg<QString>(args, 0, ""),
				     get_arg<QString>(args, 1, ""),
				     get_arg<int>(args, 2, 0),
				     get_arg<int>(args, 3, -2147483647),
				     get_arg<int>(args, 4, 2147483647),
				     get_arg<int>(args, 5, 1),
				     &ok
				     );
    return ok ? Value(ls, v) : Value(ls);
  }


  QTLUA_FUNCTION(get_text, "Wrap QInputDialog::getText function.",
		 "usage: qt.dialog.get_text( [ \"title\", \"label\", \"init_text\" ] )\n")
  {
    bool ok;
    QString v = QInputDialog::getText(QApplication::activeWindow(),
				      get_arg<QString>(args, 0, ""),
				      get_arg<QString>(args, 1, ""),
				      QLineEdit::Normal,
				      get_arg<QString>(args, 2, ""),
				      &ok
				      );
    return ok ? Value(ls, v) : Value(ls);
  }


  QTLUA_FUNCTION(get_item, "Wrap QInputDialog::getItem function.",
		 "usage: qt.dialog.get_item( { \"item\", \"item\", ... }, [ default, editable, \"title\", \"label\" ] )\n")
  {
    bool ok;
    QString v = QInputDialog::getItem(QApplication::activeWindow(),
				      get_arg<QString>(args, 3, ""),
				      get_arg<QString>(args, 4, ""),
				      get_arg<QList<QString> >(args, 0),
				      get_arg<int>(args, 1, 0),
				      get_arg<Value::Bool>(args, 2, Value::False),
				      &ok
				      );
    return ok ? Value(ls, v) : Value(ls);
  }


  QTLUA_FUNCTION(msg_about, "Wrap QMessageBox::about function.",
		 "usage: qt.dialog.msg_about( \"text\" [ , \"title\" ] )\n")
  {
    QMessageBox::about(QApplication::activeWindow(),
		       get_arg<QString>(args, 1, ""),
		       get_arg<QString>(args, 0));
    return Value(ls);
  }


  QTLUA_FUNCTION(msg_critical, "Wrap QMessageBox::critical function.",
		 "usage: qt.dialog.msg_critical( \"text\" [ , \"title\", buttons, default_button ] )\n")
  {
    return Value(ls, QMessageBox::critical(QApplication::activeWindow(),
					   get_arg<QString>(args, 1, ""),
					   get_arg<QString>(args, 0),
					   (QMessageBox::StandardButtons)get_arg<int>(args, 2, QMessageBox::Ok),
					   (QMessageBox::StandardButton)get_arg<int>(args, 3, QMessageBox::NoButton)));
  }


  QTLUA_FUNCTION(msg_information, "Wrap QMessageBox::information function.",
		 "usage: qt.dialog.msg_information( \"text\" [ , \"title\", buttons, default_button ] )\n")
  {
    return Value(ls, QMessageBox::information(QApplication::activeWindow(),
					      get_arg<QString>(args, 1, ""),
					      get_arg<QString>(args, 0),
					      (QMessageBox::StandardButtons)get_arg<int>(args, 2, QMessageBox::Ok),
					      (QMessageBox::StandardButton)get_arg<int>(args, 3, QMessageBox::NoButton)));
  }


  QTLUA_FUNCTION(msg_question, "Wrap QMessageBox::question function.",
		 "usage: qt.dialog.msg_question( \"text\" [ , \"title\", buttons, default_button ] )\n")
  {
    return Value(ls, QMessageBox::question(QApplication::activeWindow(),
					   get_arg<QString>(args, 1, ""),
					   get_arg<QString>(args, 0),
					   (QMessageBox::StandardButtons)get_arg<int>(args, 2, QMessageBox::Ok),
					   (QMessageBox::StandardButton)get_arg<int>(args, 3, QMessageBox::NoButton)));
  }


  QTLUA_FUNCTION(msg_warning, "Wrap QMessageBox::warning function.",
		 "usage: qt.dialog.msg_warning( \"text\" [ , \"title\", buttons, default_button ] )\n")
  {
    return Value(ls, QMessageBox::warning(QApplication::activeWindow(),
					  get_arg<QString>(args, 1, ""),
					  get_arg<QString>(args, 0),
					  (QMessageBox::StandardButtons)get_arg<int>(args, 2, QMessageBox::Ok),
					  (QMessageBox::StandardButton)get_arg<int>(args, 3, QMessageBox::NoButton)));
  }


  QTLUA_FUNCTION(tree_view, "Expose a lua table in a QTreeView.",
		 "usage: qt.dialog.tree_view( table [ , TableTreeModel::Attribute, \"title\" ] )\n")
  {
    meta_call_check_args(args, 1, 3, Value::TNone, Value::TNumber, Value::TString);

    TableTreeModel::tree_dialog(QApplication::activeWindow(),
				get_arg<QString>(args, 2, ""), args[0],
				(TableTreeModel::Attributes)get_arg<int>(args, 1, 0)
				);

    return Value::List();
  }


  QTLUA_FUNCTION(table_view, "Expose a lua table in a QTableView with key, value and type columns.",
		 "usage: qt.dialog.table_view( table [ , TableTreeModel::Attribute, \"title\" ] )\n")
  {
    meta_call_check_args(args, 1, 3, Value::TNone, Value::TNumber, Value::TString);

    TableTreeModel::table_dialog(QApplication::activeWindow(),
				 get_arg<QString>(args, 2, ""), args[0],
				 (TableTreeModel::Attributes)get_arg<int>(args, 1, 0)
				 );

    return Value::List();
  }


  QTLUA_FUNCTION(grid_view, "Expose 2 dimensions nested lua tables in a QTableView.",
		 "usage: qt.dialog.grid_view( table [ , TableGridModel::Attribute, \"title\", {column keys}, {row keys} ] )\n")
  {
    meta_call_check_args(args, 1, 5, Value::TNone, Value::TNumber,
			 Value::TString, Value::TTable, Value::TTable);
    Value::List rk, *rkptr = 0;
    Value::List ck, *ckptr = 0;

    if (args.count() >= 5)
      {
	rk = args[4].to_qlist<Value>();
	if (!rk.empty())
	  rkptr = &rk;
      }

    if (args.count() >= 4)
      {
	ck = args[3].to_qlist<Value>();
	if (!ck.empty())
	  ckptr = &ck;
      }

    TableGridModel::table_dialog(QApplication::activeWindow(),
				   get_arg<QString>(args, 2, ""), args[0],
				   (TableGridModel::Attributes)get_arg<int>(args, 1, 0),
				   ckptr, rkptr
				   );

    return Value::List();
  }


  ////////////////////////////////////////////////// MVC stuff


  static void set_model(QWidget *obj, QAbstractItemModel *m)
  {
    if (QAbstractItemView *w = dynamic_cast<QAbstractItemView*>(obj))
      w->setModel(m);
    else if (QComboBox *w = dynamic_cast<QComboBox*>(obj))
      w->setModel(m);
    else
      {
	delete m;
	QTLUA_THROW(qt.mvc.new_*_model, "Unable to set the MVC model for this object type.");
      }
  }

  QTLUA_FUNCTION(new_table_tree_model, "Return a new QtLua::TableTreeModel object and set it has MVC model of some Qt views.",
		 "usage: qt.mvc.new_table_tree_model( table, TableTreeModel::Attributes, [ view_widget, ... ] )\n")
  {
    meta_call_check_args(args, 2, -3, Value::TNone, Value::TNumber, Value::TUserData);

    TableTreeModel::Attributes a = (TableTreeModel::Attributes)get_arg<int>(args, 1);
    TableTreeModel *m = new TableTreeModel(args[0], a);

    for (int i = 2; i < args.count(); i++)
      set_model(get_arg_qobject<QWidget>(args, i), m);

    return Value(ls, m, true, true);
  }

  QTLUA_FUNCTION(new_table_grid_model, "Return a new QtLua::TableGridModel object and set it has MVC model of some Qt views.",
		 "usage: qt.mvc.new_table_grid_model( table, TableGridModel::Attributes, [ view_widget, ... ] )\n")
  {
    meta_call_check_args(args, 2, -3, Value::TNone, Value::TNumber, Value::TUserData);

    TableGridModel::Attributes a = (TableGridModel::Attributes)get_arg<int>(args, 1);
    TableGridModel *m = new TableGridModel(args[0], a, true);

    for (int i = 2; i < args.count(); i++)
      set_model(get_arg_qobject<QWidget>(args, i), m);

    return Value(ls, m, true, true);
  }

  QTLUA_FUNCTION(new_lua_model, "Return a new QtLua::LuaModel object and set it has MVC model of some Qt views.",
		 "usage: qt.mvc.new_lua_model( get_fcn [ , set_fcn, ins_row_fcn, \n"
		 "                             del_row_fnc, ins_col_fcn, del_col_fcn, view_widget, ... ] )\n")
  {
    LuaModel *m = new LuaModel(get_arg<Value>(args, 0),
				 get_arg<Value>(args, 1, Value()),
				 get_arg<Value>(args, 2, Value()),
				 get_arg<Value>(args, 3, Value()),
				 get_arg<Value>(args, 4, Value()),
				 get_arg<Value>(args, 5, Value())
				 );

    for (int i = 6; i < args.count(); i++)
      set_model(get_arg_qobject<QWidget>(args, i), m);

    return Value(ls, m, true, true);
  }

  QTLUA_FUNCTION(set_model, "Set a MVC model of one or more Qt views.",
		 "usage: qt.mvc.set_model( model, view_widget [, view_widget, ... ] )\n")
  {
    meta_call_check_args(args, 2, 0, Value::TUserData, Value::TUserData);

    QAbstractItemModel *m = get_arg_qobject<QAbstractItemModel>(args, 0);

    for (int i = 1; i < args.count(); i++)
      set_model(get_arg_qobject<QWidget>(args, i), m);

    return Value::List();
  }

  QTLUA_FUNCTION(new_itemview_dialog, "Dynamically create a new QtLua::ItemViewDialog.",
		 "usage: qt.mvc.new_itemview_dialog( ItemViewDialog::EditActions, model, view )\n")
  {
    return Value(ls, new ItemViewDialog((ItemViewDialog::EditActions)get_arg<int>(args, 0),
					get_arg_qobject<QAbstractItemModel>(args, 1),
					get_arg_qobject<QAbstractItemView>(args, 2)
					));
  }


  //////////////////////////////////////////////////
   
  void qtluaopen_qt(State *ls)
  {
    ls->set_global("qt.meta", Value(ls, qt_meta));

    QTLUA_FUNCTION_REGISTER(ls, "qt.", new_qobject           );
    QTLUA_FUNCTION_REGISTER(ls, "qt.", connect               );
    QTLUA_FUNCTION_REGISTER(ls, "qt.", connect_slots_by_name );
    QTLUA_FUNCTION_REGISTER(ls, "qt.", disconnect            );
    QTLUA_FUNCTION_REGISTER(ls, "qt.", meta_type             );

    QTLUA_FUNCTION_REGISTER(ls, "qt.", tr                    );
    QTLUA_FUNCTION_REGISTER(ls, "qt.", translator            );

    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.", load_ui            );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.", new_widget         );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.", layout_add         );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.", layout_spacer      );
    QTLUA_FUNCTION_REGISTER2(ls, "qt.ui.attach", ui_attach );

    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", add_menu         );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", add_separator    );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", add_action       );
    QTLUA_FUNCTION_REGISTER2(ls, "qt.ui.menu.attach", menu_attach);
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", new_action_group );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", new_action       );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", new_menu         );
    QTLUA_FUNCTION_REGISTER(ls, "qt.ui.menu.", remove           );

    QTLUA_FUNCTION_REGISTER(ls, "qt.mvc.", new_table_tree_model  );
    QTLUA_FUNCTION_REGISTER(ls, "qt.mvc.", new_table_grid_model  );
    QTLUA_FUNCTION_REGISTER(ls, "qt.mvc.", new_lua_model     );
    QTLUA_FUNCTION_REGISTER(ls, "qt.mvc.", set_model         );
    QTLUA_FUNCTION_REGISTER(ls, "qt.mvc.", new_itemview_dialog   );

    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_existing_directory);
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_open_filename     );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_open_filenames    );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_save_filename     );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_color             );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_double            );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_integer           );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_text              );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", get_item              );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", msg_about             );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", msg_critical          );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", msg_information       );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", msg_question          );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", msg_warning           );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", tree_view             );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", table_view            );
    QTLUA_FUNCTION_REGISTER(ls, "qt.dialog.", grid_view             );
  }

}

