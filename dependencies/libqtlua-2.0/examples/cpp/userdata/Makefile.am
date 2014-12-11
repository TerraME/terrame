
include $(top_srcdir)/build/autotroll.mk

noinst_PROGRAMS = function ref userobject userobject2

function_SOURCES = function.cc
function_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
function_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
function_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
function_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la

userobject_SOURCES = userobject.cc
userobject_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
userobject_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
userobject_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
userobject_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la

userobject2_SOURCES = userobject2.cc
userobject2_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
userobject2_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
userobject2_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
userobject2_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la

ref_SOURCES = ref.cc
ref_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
ref_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
ref_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
ref_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la
