#include "luaLogFile.h"

#include "luna.h"
#include "terrameGlobals.h"

luaLogFile::luaLogFile(lua_State* L)
{
	luaL = L;
}

int luaLogFile::setObserver(lua_State* L)
{
    ObserverLogFile *obslf = (ObserverLogFile*) lua_touserdata(L, -1);
    obs = obslf;
    return 0;
}

luaLogFile::~luaLogFile(void)
{
}
