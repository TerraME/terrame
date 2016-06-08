/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

/*! \file luaSociety.h
    \brief This file definitions for the luaSociety objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUASOCIETY_H
#define LUASOCIETY_H

#include "../observer/societySubjectInterf.h"
#include "luaGlobalAgent.h"

extern "C"
{
#include <lua.h>
}
#include "luna.h"
#include "reference.h"

/**
* \brief 
*
* Represents a set of Societys in the Lua runtime environment. 
*
*/
//class SocietySubjectInterf;

class luaSociety : public SocietySubjectInterf, public Reference<luaSociety>
{
    // @DANIEL
    // Movido para clsse Reference
    // int ref; ///< The position of the object in the Lua stack
    string objectId_; ///< luaSociety identifier

    // Antonio - construtor
    TypesOfSubjects subjectType;
    lua_State *luaL; ///< Stores locally the lua stack location in memory
    QStringList observedAttribs;

    QString attrNeighName;

    QString getAll(QDataStream& in, int obsId, QStringList& attribs);
    QString getChanges(QDataStream& in, int obsId, QStringList& attribs);

public:
    ///< Data structure issued by Luna<T>
    static const char className[];

    ///< Data structure issued by Luna<T>
    static Luna<luaSociety>::RegType methods[];

public:
    /// Constructor
    luaSociety(lua_State *L);

    /// Returns the current internal state of the LocalAgent (Automaton) within the cell and received as parameter
    int getCurrentStateName(lua_State *L);

    /// Puts the iterator in the beginning of the luaNeighborhood composite.
    int first(lua_State *L);

    /// Puts the iterator in the end of the luaNeighborhood composite.
    int last(lua_State *L);

    /// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure
    /// no parameters
    int isFirst(lua_State *L);

    /// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure
    /// no parameters
    int isLast(lua_State *L);

    /// Returns true if the Neighborhood is empty.
    /// no parameters
    int isEmpty(lua_State *L);

    /// Clears all the Neighborhood content
    /// no parameters
    int clear(lua_State *L);

    /// Returns the number of Neighbors cells in the Neighborhood
    int size(lua_State *L);

    /// Fowards the Neighborhood iterator to the next Neighbor cell
    // no parameters
    int next(lua_State *L);

    /// destructor
    ~luaSociety(void);

    /// Sets the Society latency
    int setLatency(lua_State *L);

    /// Gets the Society latency
    int getLatency(lua_State *L);

    /// Sets the neighborhood
    int setNeighborhood(lua_State *L);

    /// Gets the current active luaNeighboorhood
    int getCurrentNeighborhood(lua_State *L);

    /// Returns the Neihborhood graph which name has been received as a parameter
    int getNeighborhood(lua_State *L);

    /// Adds a new luaNeighborhood graph to the Society
    /// parameters: identifier, luaNeighborhood
    int addNeighborhood(lua_State *L);

    /// Synchronizes the luaSociety
    int synchronize(lua_State *L);

    /// Registers the luaSociety object in the Lua stack
    // @DANIEL
    // Movido para clsse Reference
    // int setReference(lua_State* L);

    /// Gets the luaSociety object reference
    // @DANIEL
    // Movido para clsse Reference
    // int getReference(lua_State *L);

    /// Gets the luaSociety identifier
    int getID(lua_State *L);

    /// Sets the luaSociety identifier
    int setID(lua_State *L);

	/// Gets the luaSociety identifier
	/// \author Raian Vargas Maretto
		const char* getID();

	// Raian
	/// Sets the cell index
	/// \author Raian Vargas Maretto
        int setIndex(lua_State *L);

	//Raian
	/// Gets the cell index (x,y)
	/// \author Raian Vargas Maretto
        //SocietyIndex getIndex();

    /// Creates several types of observers
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver(lua_State *L);

    /// Notifies observers about changes in the luaSociety internal state
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


/// Gets the luaSociety position of the luaSociety in the Lua stack
/// \param L is a pointer to the Lua stack
/// \param cell is a pointer to the cell within the Lua stack
void getReference(lua_State *L, luaSociety *cell);

#endif
