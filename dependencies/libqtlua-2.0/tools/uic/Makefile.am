
include $(top_srcdir)/build/autotroll.mk

bin_PROGRAMS = qtlua_uic

qtlua_uic_SOURCES = qtlua_uic.cc
qtlua_uic_CXXFLAGS = $(QT_CXXFLAGS) $(AM_CXXFLAGS)
qtlua_uic_CPPFLAGS = $(QT_CPPFLAGS) $(AM_CPPFLAGS) -I$(top_srcdir)/src
qtlua_uic_LDFLAGS  = $(QT_LDFLAGS) $(LDFLAGS) $(libtool_flags)
qtlua_uic_LDADD   = $(QT_LIBS) $(LDADD) $(top_builddir)/src/libqtlua.la

EXTRA_DIST = CMakeLists.txt

