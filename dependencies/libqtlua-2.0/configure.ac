
AC_INIT(libqtlua, 2.0)
PACKAGE_VERSION=2.0
LIBRARY_VERSION=2.0
AC_SUBST(PACKAGE_VERSION)
AC_SUBST(LIBRARY_VERSION)

AC_CONFIG_AUX_DIR([build])
AC_CONFIG_MACRO_DIR([build])

AM_INIT_AUTOMAKE(libqtlua, 2.0)
AC_CONFIG_HEADERS(config.hh)

AC_PROG_CXX
AC_DISABLE_STATIC
AC_PROG_LIBTOOL

AT_WITH_QT([core gui xml widgets], [uitools])

AC_CONFIG_FILES([
  Makefile
    src/Makefile
    src/QtLua/Makefile
    src/internal/Makefile
    tools/Makefile
    tools/qtlua/Makefile
    tools/uic/Makefile
    examples/Makefile
    examples/lua/Makefile
    examples/cpp/Makefile
    examples/cpp/console/Makefile
    examples/cpp/proxy/Makefile
    examples/cpp/qobject/Makefile
    examples/cpp/userdata/Makefile
    examples/cpp/mvc/Makefile
    examples/cpp/value/Makefile
    examples/cpp/plugin/Makefile
    examples/cpp/types/Makefile
    test/Makefile
    doc/Makefile
])

AC_ARG_WITH(lua-inc-dir,
 AC_HELP_STRING(--with-lua-inc-dir, [Specify lua include directory (default /usr/include)]),
 [CPPFLAGS="$CPPFLAGS -I$withval"])

AC_ARG_WITH(lua-lib,
 AC_HELP_STRING(--with-lua-lib, [Specify lua library name (default lua)]),
 luaname=$withval, luaname=lua)

AC_ARG_WITH(lualib-lib,
 AC_HELP_STRING(--with-lualib-lib, [Specify lua extra library name (default lualib); not needed for all lua versions]),
 lualibname=$withval, lualibname=lualib)

AC_LANG(C)
AC_CHECK_HEADER(lua.h, , AC_MSG_ERROR([can not find lua.h; try --with-lua* arguments]))
AC_CHECK_HEADER(lualib.h, , AC_MSG_ERROR([can not find lualib.h; try --with-lua* arguments]))
AC_CHECK_HEADER(lauxlib.h, , AC_MSG_ERROR([can not find lauxlib.h; try --with-lua* arguments]))

AC_CHECK_LIB(m, cosf, , AC_MSG_ERROR([can not find m library]))
AC_CHECK_LIB(dl, dlopen, , )
AC_CHECK_LIB($luaname, lua_pushnil, , AC_MSG_ERROR([can not find $luaname library; try --with-lua* arguments]))
AC_CHECK_LIB($luaname, lua_gc, AC_DEFINE(HAVE_LUA_GC, 1, [lua_gc function is available]))

AC_CHECK_LIB($luaname, luaL_error, lualibname=$luaname, AC_CHECK_LIB($lualibname, luaL_error))

AC_CHECK_LIB($lualibname, luaopen_package, AC_DEFINE(HAVE_LUA_PACKAGELIB, 1, [lua package library is available]))
AC_CHECK_LIB($lualibname, luaopen_os, AC_DEFINE(HAVE_LUA_OSLIB, 1, [lua os library is available]))
AC_CHECK_LIB($lualibname, luaL_openlibs, AC_DEFINE(HAVE_LUA_OPENLIBS, 1, [lua os library is available]))
AC_CHECK_LIB($lualibname, luaopen_jit, AC_DEFINE(HAVE_LUA_JITLIB, 1, [luajit jit library is available]))
AC_CHECK_LIB($lualibname, luaopen_ffi, AC_DEFINE(HAVE_LUA_FFILIB, 1, [luajit ffi library is available]))

AC_LANG(C++)

LDFLAGS="$QT_LDFLAGS $LDFLAGS"
LIBADD="$QT_LIBS $LIBADD"
CXXFLAGS="$CXXFLAGS $QT_CPPFLAGS -fPIC -Wall -Wno-unused-parameter -DQT_NO_CAST_FROM_BYTEARRAY"

AC_MSG_CHECKING([for Qt uitools])
AC_COMPILE_IFELSE( [AC_LANG_PROGRAM([[#include <QUiLoader>]], [[QUiLoader l;]])],
		   [ AC_DEFINE(HAVE_QT_UITOOLS, 1, [Qt uitools module is available])
		     AC_MSG_RESULT([yes]) ],
		   [ AC_MSG_RESULT([no]) ]
		 )

save_CXXFLAGS="$CXXFLAGS"
CXXFLAGS="$CXXFLAGS -std=c++11"
AC_MSG_CHECKING([for Qt and compiler supports for c++11])
AC_COMPILE_IFELSE( [AC_LANG_PROGRAM([[#include <QObject>]], [[
#if !defined(Q_COMPILER_RVALUE_REFS)
# error
#endif
		   ]])],
		   [ AC_DEFINE(HAVE_QT_CPP2011, 1, [Qt and compiler supports for c++11])
		     AC_MSG_RESULT([yes]) ],
		   [ CXXFLAGS="$save_CXXFLAGS" ]
		   [ AC_MSG_RESULT([no]) ]
		 )

eval shared_ext=\"$shrext_cmds\"
AC_DEFINE_UNQUOTED(SHLIBEXT, $shared_ext, [suffix for dynamic libraries is $shared_ext])

AC_ARG_ENABLE(examples, AC_HELP_STRING(--disable-examples, [Disable compilation of examples]), disable_examples=yes)
AM_CONDITIONAL(EXAMPLES, test x$disable_examples != xyes)

AC_OUTPUT

