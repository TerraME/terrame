/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright 2001-2007 INPE and Tecgraf/PUC-Rio.

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
/*! \file luaLocalAgent.h
    \brief This file definitions for the luaLocalAgent objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUALOCALAGENT_H )
#define LUALOCALAGENT_H

#include "luaAgent.h"
#include "localAgentSubjectInterf.h"

#include <QHash>

class luaCell;
class luaCellularSpace;

namespace ObserverDatagramPkg
{
    class SubjectAttribute; 
}

///////////////////////////////////////////////////////////////////////////////////////
/**
* \brief  
*  Implementation for a luaLocalAgent object.
*
*/
class luaLocalAgent : public LocalAgentSubjectInterf, public luaAgent
{
private:

    lua_State *luaL;
    TypesOfSubjects subjectType;
    luaCell *whereCell;
    QByteArray attrClassName;
    luaCellularSpace* cellSpace;
    QHash<QString, QString> observedAttribs;

#ifdef TME_PROTOCOL_BUFFERS
    QByteArray getAll(QDataStream& in, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, const QStringList& attribs);
#else
    QByteArray getAll(QDataStream& in, int obsId, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, int obsId, const QStringList& attribs);
#endif

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
    int getLatency( lua_State *L);

    /// Adds a new luaControlMod to the luaLocalAgent object
    int add(lua_State *L);

    /// Executes the luaLocalAgent object
    /// parameter: luaEvent
    int execute( lua_State* L);

    /// Sets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent object will traverse its internal
    /// luaTrajectory objects
    /// parameter: boolean
    int setActionRegionStatus( lua_State* L);

    /// Gets the luaLocalAgent "Action Region" status to true, tha luaLocalAgent object will traverse its internal
    /// luaTrajectory objects
    /// parameter: boolean
    int getActionRegionStatus( lua_State* L);

    /// Builds the luaLocalAgent object
    int build( lua_State* L);

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver( lua_State *L );

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L );
    
    /// Gets the subject's type
    const TypesOfSubjects getType() const;

    /// Gets the object's internal state (serialization)
    /// \param in the serializated object that contains the data that will be observed in the observer
    /// \param subject a pointer to a observed subject
    /// \param observerId the id of the observer
    /// \param attribs the list of attributes observed
    QDataStream& getState(QDataStream& in, Subject *subject, 
        int observerID, const QStringList& attribs);

#ifdef TME_PROTOCOL_BUFFERS
    QByteArray pop(lua_State *L, const QStringList& attribs, ObserverDatagramPkg::SubjectAttribute *csSubj,
        ObserverDatagramPkg::SubjectAttribute *parentSubj);
#else
    /**
     * Gets the attributes of Lua stack
     * \param attribs the list of attributes observed
     */
    QByteArray pop(lua_State *L, const QStringList& attribs);
#endif

    /// Destroys the observer object instance
    int kill(lua_State *L);
};
#endif
