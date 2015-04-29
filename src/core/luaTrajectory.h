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
/*! \file luaTrajectory.h
\brief This file definitions for the luaTrajectory objects.
\author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUATRAJECTORY_H )
#define LUATRAJECTORY_H

#include "trajectorySubjectInterf.h"
#include "reference.h"

#include <QString>
#include <QDataStream>
#include <QHash>

class luaCellularSpace;

namespace ObserverDatagramPkg
{
    class SubjectAttribute; 
}

/**
* \brief  
*  Implementation for a luaTrajectory object.
*
*/
class luaTrajectory : public TrajectorySubjectInterf, public Reference<luaTrajectory>
{
#ifdef TME_PROTOCOL_BUFFERS
    QByteArray getAll(QDataStream& in, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, const QStringList& attribs);
#else
    QByteArray getAll(QDataStream& in, int obsId, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, int obsId, const QStringList& attribs);
#endif

    lua_State *luaL;
    luaCellularSpace* cellSpace;
    QHash<QString, QString> observedAttribs;

protected:
    // Antonio
    TypesOfSubjects subjectType;
    // @DANIEL
    // Moved to Reference class
    // int ref; ///< The position of the object in the Lua stack

public:
    ///< Data structure issued by Luna<T>
    static const char className[];
    
    ///< Data structure issued by Luna<T>
    static Luna<luaTrajectory>::RegType methods[]; 

public:
    /// constructor
    luaTrajectory(lua_State* L);

    /// destructor
    ~luaTrajectory(void);

    /// Inserts the the luaTrajectory object. The luaCell will be inserted in the number-th position.
    /// parameters: luaCell, number
    int add(lua_State* L);

    /// Clears all luaTrajectory object content
    int clear(lua_State* L);

    /// Registers the luaTrajectory object in the Lua stack
    // @DANIEL
    // Moved to Reference class
    // int setReference( lua_State* L);

    /// Gets the luaTrajectory object reference
    // @DANIEL
    // Moved to Reference class
    // int getReference( lua_State *L );

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observer attributes table, observer type parameters
    int createObserver(lua_State *L);

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L);
    
    /// Returns the Agent Map Observers linked to this cellular space
    /// \param observerId the id of observer
    // \return a pointer for an observer if the id exists. Otherwise, returns a NULL pointer
    Observer * getObserver(int observerId);

    /// Gets the subject's type
    const TypesOfSubjects getType() const;

    /// Gets the object's internal state (serialization)
    /// \param in the serialized object that contains the data that will be observed in the observer
    /// \param subject a pointer to a observed subject
    /// \param observerId the id of the observer
    /// \param attribs the list of attributes observed
    QDataStream& getState(QDataStream& in, Subject *subject, int observerID, const QStringList& attribs);

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

    /// Debugging method for ObserverUDPSender
    // void save(const QString &msg);
};

#endif

