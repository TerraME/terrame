include $(top_srcdir)/build/autotroll.mk

SUBDIRS = QtLua internal

EXTRA_DIST = CMakeLists.txt

lib_LTLIBRARIES = libqtlua.la

BUILT_SOURCES = QtLua/qtluaconsole.moc.cc QtLua/qtluauseritemselectionmodel.moc.cc \
		QtLua/qtluauseritemmodel.moc.cc QtLua/qtluatabletreemodel.moc.cc \
		QtLua/qtluaitemviewdialog.moc.cc QtLua/qtluastate.moc.cc	\
		QtLua/qtluatablegridmodel.moc.cc QtLua/qtlualuamodel.moc.cc	\
		qtluaqtlib.moc.cc

nodist_libqtlua_la_SOURCES = $(BUILT_SOURCES)
libqtlua_la_SOURCES = qtluaconsole.cc qtluaenum.cc qtluaqmetavalue.cc		\
	qtluafunction.cc qtluauseritem.cc qtluauseritemmodel.cc	qtluauserlistitem.cc	\
	qtlualistiterator.cc qtluamember.cc qtluametacache.cc qtluamethod.cc	\
	qtluaplugin.cc qtluaqobjectwrapper.cc qtluaqtlib.cc qtluastate.cc	\
	qtluatableiterator.cc qtluauserdata.cc qtluavaluebase.cc qtluavalue.cc	\
	qtluavalueref.cc qtluaqobjectiterator.cc qtluaenumiterator.cc		\
	qtluaproperty.cc qtluaqmetaobjecttable.cc qtluaqmetaobjectwrapper.cc	\
	qtluauseritemselectionmodel.cc qtluaqtlib.hh qtluatabletreekeys.cc		\
	qtluatabletreemodel.cc qtluaitemviewdialog.cc qtluatablegridmodel.cc	\
	qtluadispatchproxy.cc qtlualuamodel.cc

libqtlua_la_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
libqtlua_la_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS)
libqtlua_la_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags) -release $(LIBRARY_VERSION)
libqtlua_la_LIBADD   = $(QT_LIBS) $(LIBADD)

