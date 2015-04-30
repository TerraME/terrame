#if !defined( LUNA_H )
#define LUNA_H

extern "C" {
#include "lua.h"
#include "lauxlib.h"
}


template <typename T> class Luna {
    typedef struct { T *pT; } userdataType;
public:
    typedef int (T::*mfp)(lua_State *L);
    typedef struct { const char *name; mfp mfunc; } RegType;

	static int t_error (lua_State *L, int narg, const char *tname) 
    {
      const char *msg = lua_pushfstring(L, "%s expected, got %s", tname, luaL_typename(L, narg));
      return luaL_argerror(L, narg, msg);
    }

    static void Register(lua_State *L) {
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
    static T *check(lua_State *L, int narg) {
        userdataType *ud =
                static_cast<userdataType*>(luaL_checkudata(L, narg, T::className));
        //if(!ud) luaL_typerror(L, narg, T::className);
		if(!ud) t_error(L, narg, T::className);
        return ud->pT;  // pointer to T object
    }

private:
    Luna();  // hide default constructor

    // member function dispatcher
    static int thunk(lua_State *L) {
        // stack has userdata, followed by method args
        T *obj = check(L, 1);  // get 'self', or if you prefer, 'this'
        lua_remove(L, 1);  // remove self so member function args start at index 1
        // get member function from upvalue
        RegType *l = static_cast<RegType*>(lua_touserdata(L, lua_upvalueindex(1)));
        return (obj->*(l->mfunc))(L);  // call member function
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

    static int tostring_T (lua_State *L) {
        char buff[32];
        userdataType *ud = static_cast<userdataType*>(lua_touserdata(L, 1));
        T *obj = ud->pT;
        sprintf(buff, "%p", obj);
        lua_pushfstring(L, "%s (%s)", T::className, buff);
        return 1;
    }
};

#endif
