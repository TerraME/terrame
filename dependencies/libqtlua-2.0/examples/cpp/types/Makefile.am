
include $(top_srcdir)/build/autotroll.mk

noinst_PROGRAMS = meta

BUILT_SOURCES = myobject.moc.cc

meta_SOURCES = meta.cc myobject.hh
nodist_meta_SOURCES = myobject.moc.cc
meta_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
meta_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
meta_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
meta_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la

