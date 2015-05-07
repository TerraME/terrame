/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C) 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/
/*! \file luaMessage.h
    \brief This file definitions for the luaMessage objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUAMESSAGE_H
#define LUAMESSAGE_H

#include "reference.h"

#include <QDebug>

//////////////////////
/**
* \brief
*  Implementation for a luaMessage object.
*
*/
extern lua_State * L; ///< Global variable: Lua stack used for communication with C++ modules.

class luaMessage : public Message, public Reference<luaMessage>
{
    TypesOfSubjects subjectType;
    string msg;  ///< The message identifier

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<luaMessage>::RegType methods[];

public:
    /// Constructor
    luaMessage(lua_State *)
    {
        subjectType = TObsUnknown;
    }

    /// Destructor
    ~luaMessage(void) {}

    /// Configures the luaMessage object
    /// parameter: identifier
    int config(lua_State *L) {
        msg = lua_tostring(L, -1);
        return 0;
    }

    /// Executes the luaMessage object
    /// \param event is the Event which has trigered this luaMessage
    bool execute(Event& event) {
        // puts the message table on the top of the lua stack
        getReference(L);
        if(!lua_istable(L, -1))
        {
            string err_out = string("Action function ") + string (msg)
            				+ string(" not defined!");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			//lua_pushnumber(L, 5);
			lua_call(L, 1, 0);
            return 0;
        }

        // puts the Lua function 'message:execute()' on the top of the stack
        lua_pushnumber(L, 1);
        lua_gettable(L, -2);

        // puts the Event constructor on the top of the lua stack
        lua_getglobal(L, "Event");
        if(!lua_isfunction(L, -1))
        {
			string err_out = string("Event constructor not found.");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			//lua_pushnumber(L, 5);
			lua_call(L, 1, 0);
            return 0;
        }

        // builds the table parameter of the constructor
        lua_newtable(L);
		if(event.getTime() != 1) {
        	lua_pushstring(L, "time");
        	lua_pushnumber(L, event.getTime());
        	lua_settable(L, -3);
		}
		if(event.getPeriod() != 1) {
        	lua_pushstring(L, "period");
        	lua_pushnumber(L, event.getPeriod());
        	lua_settable(L, -3);
		}
		if(event.getPriority() != 0) {
        	lua_pushstring(L, "priority");
        	lua_pushnumber(L, event.getPriority());
        	lua_settable(L, -3);
		}

        // calls the event constructor
        if(lua_pcall(L, 1, 1, 0) != 0)
        {
            string err_out = string("Event constructor not found in the stack.");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			//lua_pushnumber(L, 5);
			lua_call(L, 1, 0);
            return 0;
        }

        // puts the event parameter on stack top
        //luaEvent *ev = (luaEvent*)&event;
        //ev->getReference(L);

    // Bug agentes
    // qDebug() << "calls the function 'execute': lua_pcall(L, 1, 1, 0)";

    // calls the function 'execute'
        lua_call(L, 1, 1);

        // retrieve the message result value from the lua stack
        int result = true;
        if(lua_type(L, -1) == LUA_TBOOLEAN)
        {
            result = lua_toboolean(L, -1);
            lua_pop(L, 1);  // pop returned value
        }
        //else
        //{
        //cout << " Error: message must return \"true\" or \"false\"" << endl;
        //return 0;

        //}

        return result;
    }
};

#endif
