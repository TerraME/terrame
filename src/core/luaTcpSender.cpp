#include "luaTcpSender.h"

#include "luna.h"
#include "terrameGlobals.h"

luaTcpSender::luaTcpSender(lua_State* L)
{
	luaL = L;
}

int luaTcpSender::setObserver(lua_State* L)
{
    ObserverTCPSender *obsts = (ObserverTCPSender*) lua_touserdata(L, -1);
    obs = obsts;
    return 0;
}

luaTcpSender::~luaTcpSender(void)
{
}

