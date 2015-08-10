#include "luaTable.h"

#include "luna.h"
#include "terrameGlobals.h"

luaTable::luaTable(lua_State* L)
{
	luaL = L;
}

int luaTable::setObserver(lua_State* L)
{
    ObserverTable *obst = (ObserverTable*) lua_touserdata(L, -1);
    obs = obst;
    return 0;
}

luaTable::~luaTable(void)
{
}

int luaTable::save(lua_State* L)
{
    std::string e = luaL_checkstring(L, -1);
    std::string f = luaL_checkstring(L, -2);

    obs->save(f, e);

    return 0;
}
