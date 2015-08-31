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
/*! \file luaEvent.h
    \brief This file definitions for the luaEvent objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUAEVENT_H )
#define LUAEVENT_H

extern "C"
{
#include <lua.h>
}
#include "luna.h"
#include "reference.h"

#include "../observer/eventSubjectInterf.h"


/**
* \brief  
*  Implementation for a luaEvent object.
*
*/
class luaEvent : public EventSubjectInterf, public Reference<luaEvent>
{
    lua_State *luaL;
    TypesOfSubjects subjectType;
    QStringList observedAttribs;
    
    QString getAll(QDataStream& in, int observerId, QStringList& attribs);
    QString getChanges(QDataStream& in, int observerId, QStringList& attribs);

public:

    ///< Data structure issued by Luna<T>
    static const char className[]; 
    
    ///< Data structure issued by Luna<T>
    static Luna<luaEvent>::RegType methods[]; 

public:
    /// constructor
    luaEvent(lua_State *L);

    /// destructor
    ~luaEvent(void);

    /// Constructor - creates a luaEvent object from a Event object
    /// \param event is the copied Event object
    luaEvent(Event &event);

    /// Configures the luaEvent object
    int config(lua_State *L);

    /// Gets the luaEvent time
    int getTime(lua_State *L);

    /// Gets the luaEvent priority
    int getPriority(lua_State *L);

    /// Sets the luaEvent priority
    /// parameters: number
    int setPriority(lua_State *L);

    /// Gets the luaEvent periodicity
    int getPeriod(lua_State *L);

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver(lua_State *L);

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L);

    /// Gets the subject type
    const TypesOfSubjects getType();

    int getType(lua_State *L);

    /// Gets the object's internal state (serialization)
    /// \param in the serializated object that contains the data that will be observed in the observer
    /// \param subject a pointer to a observed subject
    /// \param observerId the id of the observer
    /// \param attribs the list of attributes observed
    QDataStream& getState(QDataStream& in, Subject *subject, int observerID, QStringList& attribs);

    /// Gets the attributes of Lua stack
    /// \param attribs the list of attributes observed
    QString pop(lua_State *L, QStringList& attribs);

    /// Destroys the observer instance
    int kill(lua_State *L);
};

#endif

