#include "luaUdpSender.h"

#include "luna.h"
#include "terrameGlobals.h"

luaUdpSender::luaUdpSender(lua_State* L)
{
	luaL = L;
}

int luaUdpSender::setObserver(lua_State* L)
{
    ObserverUDPSender *obsus = (ObserverUDPSender*) lua_touserdata(L, -1);
    obs = obsus;
    return 0;
}

luaUdpSender::~luaUdpSender(void)
{
}
