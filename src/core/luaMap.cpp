#include "luaMap.h"
#include "observerMap.h"
#include "luna.h"
#include "terrameGlobals.h"

luaMap::luaMap(lua_State* L)
{
	luaL = L;
}

int luaMap::setObserver(lua_State* L)
{
	ObserverMap * obsg = (ObserverMap*) lua_touserdata(L, -1);
	obs = obsg;
	return 0;
}

luaMap::~luaMap(void)
{
}

int luaMap::save(lua_State* L)
{
	std::string e = luaL_checkstring(L, -1);
	std::string f = luaL_checkstring(L, -2);

	obs->save(f, e);

	return 0;
}

