/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#ifndef LUNA_H
#define LUNA_H

extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
}

#include "LuaBinding.h"
#include "LuaSystem.h"

template <typename T> 
class Luna : public terrame::lua::LuaBinding<T>
{
    typedef struct { T *pT; } userdataType;
	static int m_ref;

public:
    typedef int(T::*mfp)(lua_State *L);
    typedef struct { const char *name; mfp mfunc; } RegType;

	static Luna<T>* getInstance()
	{		
		static Luna<T>* instance = new Luna<T>();
		return instance;
	}

	int t_error(lua_State *L, int narg, const char *tname)
    {
      const char *msg = lua_pushfstring(
    		  L, "%s expected, got %s", tname, luaL_typename(L, narg));
      return luaL_argerror(L, narg, msg);
    }

    void setup(lua_State *L) {
        lua_newtable(L);
        int methods = lua_gettop(L);

        luaL_newmetatable(L, T::className);
        int metatable = lua_gettop(L);

		//
		//lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);
		//lua_pushglobaltable(L);

		// store method table in globals so that
        // scripts can add functions written in Lua.
        //lua_pushstring(L, T::className);
        lua_pushvalue(L, methods);
        //lua_settable(L, LUA_GLOBALSINDEX);
		//
		//lua_setmetatable(L, -2);
		//lua_pop(L, 1);
		lua_setglobal(L, T::className);

        lua_pushliteral(L, "__metatable");
        lua_pushvalue(L, methods);
        lua_settable(L, metatable);  // hide metatable from Lua getmetatable()

        lua_pushliteral(L, "__index");
        lua_pushvalue(L, methods);
        lua_settable(L, metatable);

        lua_pushliteral(L, "__tostring");
        lua_pushcfunction(L, tostring_T);
        lua_settable(L, metatable);

        lua_pushliteral(L, "__gc");
        lua_pushcfunction(L, gc_T);
        lua_settable(L, metatable);

        lua_newtable(L);                // mt for method table
        int mt = lua_gettop(L);
        lua_pushliteral(L, "__call");
        lua_pushcfunction(L, new_T);
        lua_pushliteral(L, "new");
        lua_pushvalue(L, -2);           // dup new_T function
        lua_settable(L, methods);       // add new_T to method table
        lua_settable(L, mt);            // mt.__call = new_T
        lua_setmetatable(L, methods);

        // fill method table with methods from class T
        for (RegType *l = T::methods; l->name; l++) {
            lua_pushstring(L, l->name);
            lua_pushlightuserdata(L, (void*)l);
            lua_pushcclosure(L, thunk, 1);
            lua_settable(L, methods);
        }

        lua_pop(L, 2);  // drop metatable and method table
    }

    // get userdata from Lua stack and return pointer to T object
    T* check(lua_State *L, int narg) {
        userdataType *ud =
                static_cast<userdataType*>(luaL_checkudata(L, narg, T::className));
        //if (!ud) luaL_typerror(L, narg, T::className);
		if (!ud)
			t_error(L, narg, T::className);

        return ud->pT;  // pointer to T object
    }

	int setReference(lua_State* L)
	{
		if (m_ref == LUA_REFNIL)
			m_ref = terrame::lua::LuaSystem::getInstance().getLuaApi()->createWeakTable(L); //createWeakTable(L);
		// retrieves the container
		lua_rawgeti(L, LUA_REGISTRYINDEX, m_ref);

		// container[cObj] = lua_object
		lua_pushvalue(L, -2);
		lua_rawsetp(L, -2, this);
		lua_pop(L, 2);	
					
		return 0;				
	}

	int getReference(lua_State* L)
	{
		// retrieves the container
		lua_rawgeti(L, LUA_REGISTRYINDEX, m_ref);

		// container[cObj]
		lua_rawgetp(L, -1, this);
		lua_remove(L, -2);

		return 1;
	}

private:
    // member function dispatcher
    static int thunk(lua_State *L) {
        // stack has userdata, followed by method args
        T *obj = getInstance()->check(L, 1);  // get 'self', or if you prefer, 'this'
        lua_remove(L, 1);  // remove self so member function args start at index 1
        // get member function from upvalue
        RegType *l = static_cast<RegType*>(lua_touserdata(L, lua_upvalueindex(1)));
        return(obj->*(l->mfunc))(L);  // call member function
    }

    // create a new T object and
    // push onto the Lua stack a userdata containing a pointer to T object
    static int new_T(lua_State *L) {
        lua_remove(L, 1);   // use classname:new(), instead of classname.new()
        T *obj = new T(L);  // call constructor for T objects
        userdataType *ud =
                static_cast<userdataType*>(lua_newuserdata(L, sizeof(userdataType)));
        ud->pT = obj;  // store pointer to object in userdata
        luaL_getmetatable(L, T::className);  // lookup metatable in Lua registry
        lua_setmetatable(L, -2);
        return 1;  // userdata containing pointer to T object
    }

    // garbage collection metamethod
    static int gc_T(lua_State *L) {
        userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
        T *obj = ud->pT;
        delete obj;  // call destructor for T objects
        return 0;
    }

    static int tostring_T(lua_State *L) {
        char buff[32];
        userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
        T *obj = ud->pT;
        sprintf(buff, "%p", obj);
        lua_pushfstring(L, "%s(%s)", T::className, buff);
        return 1;
    }

	Luna() {}
	Luna(const Luna& old);
	const Luna &operator=(const Luna& old);				
	~Luna() {}	
};

template <typename T> 
int Luna<T>::m_ref = LUA_REFNIL;

#endif
