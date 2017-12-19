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

/*! \file luaTrajectory.h
\brief This file definitions for the luaTrajectory objects.
\author Tiago Garcia de Senna Carneiro
*/
#ifndef LUATRAJECTORY_H
#define LUATRAJECTORY_H

#include "trajectorySubjectInterf.h"
#include "reference.h"

#include <QString>
#include <QDataStream>
#include <QHash>

class luaCellularSpace;

/**
* \brief
*  Implementation for a luaTrajectory object.
*
*/
class luaTrajectory : public TrajectorySubjectInterf, public Reference<luaTrajectory>
{
    //@RODRIGO
    QString getAll(QDataStream& in, int obsId, QStringList& attribs);
    QString getChanges(QDataStream& in, int obsId, QStringList& attribs);

    // Antonio
    lua_State *luaL;
    luaCellularSpace* cellSpace;
    QStringList observedAttribs;

protected:
    // Antonio
    TypesOfSubjects subjectType;
    // @DANIEL
    // Movido para a classe Reference
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
    // Movido para a classe Reference
    // int setReference(lua_State* L);

    /// Gets the luaTrajectory object reference
    // @DANIEL
    // Movido para a classe Reference
    // int getReference(lua_State *L);

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver(lua_State *L);

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L);

    /// Returns the Agent Map Observers linked to this cellular space
    /// \param observerId the id of observer
    // \return a pointer for an observer if the id exists. Otherwise, returns a NULL pointer
    Observer * getObserver(int observerId);

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

    /// Debugging method for ObserverUDPSender
    void save(const QString &msg);
};


#endif
