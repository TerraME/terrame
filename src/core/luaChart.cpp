#include "luaChart.h"
#include "observerGraphic.h"
#include "luna.h"
#include "terrameGlobals.h"

luaChart::luaChart(lua_State* L)
{
	luaL = L;
}


int luaChart::setObserver(lua_State* L)
{
	ObserverGraphic * obsg = (ObserverGraphic*) lua_touserdata(L, -1);
	obs = obsg;
	return 0;
}

luaChart::~luaChart(void)
{
}

int luaChart::save(lua_State* L)
{
	std::string e = luaL_checkstring(L, -1);
	std::string f = luaL_checkstring(L, -2);

	obs->save(f, e);

	return 0;
}

