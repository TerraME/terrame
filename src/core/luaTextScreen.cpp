#include "luaTextScreen.h"
#include "observerTextScreen.h"
#include "luna.h"
#include "terrameGlobals.h"

luaTextScreen::luaTextScreen(lua_State* L)
{
	luaL = L;
}

int luaTextScreen::setObserver(lua_State* L)
{
    ObserverTextScreen *obsts = (ObserverTextScreen*) lua_touserdata(L, -1);
    obs = obsts;
    return 0;
}

luaTextScreen::~luaTextScreen(void)
{
}

int luaTextScreen::save(lua_State* L)
{
    std::string e = luaL_checkstring(L, -1);
    std::string f = luaL_checkstring(L, -2);

    obs->save(f, e);

    return 0;
}
