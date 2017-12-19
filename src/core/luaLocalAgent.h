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

/*! \file luaLocalAgent.h
    \brief This file definitions for the luaLocalAgent objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUALOCALAGENT_H
#define LUALOCALAGENT_H

#include "luaAgent.h"
#include "../observer/localAgentSubjectInterf.h"

class luaCell;
class luaCellularSpace;

///////////////////////////////////////////////////////////////////////////////////////
/**
* \brief
*  Implementation for a luaLocalAgent object.
*
*/
class luaLocalAgent : public LocalAgentSubjectInterf, public luaAgent
{
private:
    // Antonio
    // int ref;
    lua_State *luaL;
    TypesOfSubjects subjectType;
    luaCell *whereCell;
    QString attrClassName;
    luaCellularSpace* cellSpace;
    QStringList observedAttribs;
    bool notNotify;

    //@RODRIGO
    // ServerSession *serverSession;
    QString getAll(QDataStream& in, int obsId, QStringList& attribs);
    QString getChanges(QDataStream& in, int obsId, QStringList& attribs);

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<luaLocalAgent>::RegType methods[];

public:
    /// Constructor
    luaLocalAgent(lua_State *L);

    ///Destructor
    ~luaLocalAgent(void);

    /// Gets the simulation time elapsed since the last change in the luaLocalAgent internal discrete state
    int getLatency(lua_State *L);

    /// Adds a new luaControlMod to the luaLocalAgent object
    int add(lua_State *L);

    /// Executes the luaLocalAgent object
    /// parameter: luaEvent
    int execute(lua_State* L);

    /// Sets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent object will traverse its internal
    /// luaTrajectory objects
    /// parameter: boolean
    int setActionRegionStatus(lua_State* L);

    /// Gets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent object will traverse its internal
    /// luaTrajectory objects
    /// parameter: boolean
    int getActionRegionStatus(lua_State* L);

    /// Builds the luaLocalAgent object
    int build(lua_State* L);

    // int setReference(lua_State* L);
    // int getReference(lua_State *L);

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver(lua_State *L);

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L);

    /// Gets the subject's type
    const TypesOfSubjects getType();

    /// Gets the object's internal state (serialization)
    /// \param in the serializated object that contains the data that will be observed in the observer
    /// \param subject a pointer to a observed subject
    /// \param observerId the id of the observer
    /// \param attribs the list of attributes observed
    QDataStream& getState(QDataStream& in, Subject *subject, int observerID, QStringList& attribs);

    /// Gets the attributes of Lua stack
    /// \param attribs the list of attributes observed
    QString pop(lua_State *L, QStringList& attribs);

    /// Destroys the observer object instance
    int kill(lua_State *L);
};
#endif
