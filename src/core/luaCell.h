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
/*! \file luaCell.h
    \brief This file definitions for the luaCell objects.
        \author Tiago Garcia de Senna Carneiro
*/
#ifndef LUACELL_H
#define LUACELL_H

#include "../observer/cellSubjectInterf.h"
#include "luaLocalAgent.h"

#include "reference.h"
#include <QHash>
#include <QByteArray>

extern "C"
{
#include <lua.h>
}
#include "luna.h"

#include "luaCellularSpace.h"

#ifdef TME_PROTOCOL_BUFFERS
namespace ObserverDatagramPkg
{
	class SubjectAttribute;
}
#endif

//@Rodrigo /Antonio
// class ServerSession;

//////////////////////////////////////////////////////////////////////////////////////
/**
* \brief
*
* Represents a set of Cells in the Lua runtime environment.
*
*/
class luaCell : public CellSubjectInterf, public Reference<luaCell>
{
	string objectId_; ///< luaCell identifier
	NeighCmpstInterf::iterator it; ///< Neighborhood iterator.

	// The index can be defined when the cell and added space
	CellIndex idx; //Raian: index of the cell.

	// Antonio - constructor
	TypesOfSubjects subjectType;
	lua_State *luaL; ///< Stores locally the lua stack location in memory
	QHash<QString, QString> observedAttribs; // key: attrib name; value: attrib value

	//@RODRIGO
	// ServerSession *serverSession;

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
	static Luna<luaCell>::RegType methods[];

public:
	/// Constructor
	luaCell(lua_State *L);

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
	~luaCell(void);

	/// Sets the Cell latency
	int setLatency(lua_State *L);

	/// Gets the Cell latency
	int getLatency(lua_State *L);

	/// Sets the neighborhood
	int setNeighborhood(lua_State *L);

	/// Gets the current active luaNeighboorhood
	int getCurrentNeighborhood(lua_State *L);

	/// Returns the Neihborhood graph which name has been received as a parameter
	int getNeighborhood(lua_State *L);

	/// Adds a new luaNeighborhood graph to the Cell
	/// parameters: identifier, luaNeighborhood
	int addNeighborhood(lua_State *L);

	/// Synchronizes the luaCell
	int synchronize(lua_State *L);

	/// Gets the luaCell identifier
	int getID(lua_State *L);

	/// Sets the luaCell identifier
	int setID(lua_State *L);

	/// Gets the luaCell identifier
	/// \author Raian Vargas Maretto
	const char* getID();

	/// Sets the cell index
	/// \author Raian Vargas Maretto
	int setIndex(lua_State *L);

	void setIndex(const CellIndex& index);

	/// Gets the cell index (x, y)
	/// \author Raian Vargas Maretto
	const CellIndex & getIndex() const;

	/// Creates several types of observers
	/// parameters: observer type, observeb attributes table, observer type parameters
	int createObserver(lua_State *L);

	/// Notifies observers about changes in the luaCell internal state
	int notify(lua_State *L);

	/// Gets the subject's type
	const TypesOfSubjects getType() const;

	/// Gets the object's internal state (serialization)
	/// \param in the serialized object that contains the data that will be observed in the observer
	/// \param subject a pointer to a observed subject
	/// \param observerId the id of the observer
	/// \param attribs the list of attributes observed
	QDataStream& getState(QDataStream& in, Subject *subject, int observerID,
						const QStringList& attribs);

	/// Gets the attributes of Lua stack
	/// \param attribs the list of attributes observed
#ifdef TME_PROTOCOL_BUFFERS
	QByteArray pop(lua_State *L, const QStringList& attribs,
				ObserverDatagramPkg::SubjectAttribute *cellSubj,
				ObserverDatagramPkg::SubjectAttribute *parentSubj);
#else
	QByteArray pop(lua_State *L, const QStringList& attribs);
#endif

	/// Destroys the observer object instance
	int kill(lua_State *L);
};

#endif
