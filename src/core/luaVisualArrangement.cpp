#include "luaVisualArrangement.h"

#include "visualArrangement.h"

#include "luna.h"

#include "terrameGlobals.h"

luaVisualArrangement::luaVisualArrangement(lua_State* L)
{
    luaL = L;
}

luaVisualArrangement::~luaVisualArrangement(void)
{
}

int luaVisualArrangement::setFile(lua_State* L)
{
    string f = luaL_checkstring(L, -1);

    VisualArrangement* v = VisualArrangement::getInstance();
	v->setFile(f);

    return 0;
}

int luaVisualArrangement::addPosition(lua_State *L)
{
    int id = luaL_checknumber(L, -3);
    int x  = luaL_checknumber(L, -2);
    int y  = luaL_checknumber(L, -1);

    VisualArrangement* v = VisualArrangement::getInstance();

	PositionVisualArrangement s;
	s.x = x;
	s.y = y;         

	v->addPosition(id, s);

    return 0;
}

int luaVisualArrangement::addSize(lua_State *L)
{
    int id = luaL_checknumber(L, -3);
    int width  = luaL_checknumber(L, -2);
    int height  = luaL_checknumber(L, -1);

    VisualArrangement* v = VisualArrangement::getInstance();

	SizeVisualArrangement s;
	s.width = width;
	s.height = height;         

	v->addSize(id, s);

    return 0;
}

