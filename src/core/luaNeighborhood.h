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
/*! \file luaNeighborhood.h
    \brief This file definitions for the luaNeighborhood objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUANEIGHBORHOOD_H )
#define LUANEIGHBORHOOD_H


extern "C" 
{
#include <lua.h>
}
#include "luna.h"

#include "luaCellIndex.h"
#include "luaCell.h"
#include "neighborhood.h"
#include "neighborhoodSubjectInterf.h"

#include <QString>
#include <QDataStream>

class luaCellularSpace;

namespace ObserverDatagramPkg
{
    class SubjectAttribute; 
}

/**
* \brief  
*  Implementation for a luaNeighborhood object.
*
*/
class luaNeighborhood : public NeighborhoodSubjectInterf, public Reference<luaNeighborhood>
{
    CellNeighborhood::iterator it; ///< luaNeighboorhood iterator
    bool itNext; ///< auxliary variable used to avoid iterator problems that occurs when the erase() method is called

#ifdef TME_PROTOCOL_BUFFERS
    QByteArray getAll(QDataStream& in, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, const QStringList& attribs);
#else
    QByteArray getAll(QDataStream& in, int obsId, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, int obsId, const QStringList& attribs);
#endif

    TypesOfSubjects subjectType;
    lua_State *luaL;
    luaCellularSpace* cellSpace;
    QHash<QString, QString> observedAttribs;
    
public:
    ///< Data structure issued by Luna<T>
    static const char className[]; 
    
    ///< Data structure issued by Luna<T>
    static Luna<luaNeighborhood>::RegType methods[]; 


public:
    /// constructor
    luaNeighborhood(lua_State *L);

    /// destructor
    ~luaNeighborhood( void );

    /// Adds a new luaNeighbor cell to the luaNeighborhood
    /// parameters: cell.y, cell.x,  cell, weight
    int addNeighbor(lua_State *L);

	/// Removes the luaNeighbor cell from the luaNeighborhood 
	/// parameters: cell.x, cell.y
	/// \author Raian Vargas Maretto
	int eraseNeighbor(lua_State *L);

    /// Adds a new luaNeighbor cell to the luaNeighborhood
    /// parameters: cell index,  cell, weight
    /// return luaCell
    int addCell(lua_State *L);

    /// Removes the luaNeighbor cell from the luaNeighborhood
    /// parameters: cell index
    int eraseCell(lua_State *L);

    /// Gets the luaNeighborhood relationship weight value for the luaNeighbor 
    /// idexed by the 2D coordinates received as parameter
    /// parameters: cell index
    /// return weight
    int getCellWeight(lua_State *L);

    /// Gets the luaNeighbor cell indexed by the 2D coordinates received as parameter
    /// parameters: cell index,
    /// return luaCell
    int getCellNeighbor(lua_State *L);

    /// Gets the luaNeighborhood relationship weight value for the luaNeighbor 
    /// indexed by the 2D coordinates received as parameter.
    /// no parameters
    int getWeight( lua_State *L );
    
    /// Gets the luaNeighbor cell pointed by the Neighborhood iterator.
    /// no parameters
    int getNeighbor( lua_State *L );

    /// Gets luaNeighbor identifier
    /// no parameters
    int getID( lua_State *L );

    /// Sets the luaNeighbor's weight receiving a reference to the luaNeighbor
	/// parameters: cell.x, cell.y, weight
	/// \author Raian Vargas Maretto
		int setNeighWeight(lua_State *L);

	//Raian:
	/// Gets the weight of a neighborhood relationship
	/// parameters: cell.x, cell.y
	/// \author Raian Vargas Maretto
		int getNeighWeight(lua_State *L);
		
    /// Sets the weight for the neighborhood relationship with the cell indexed by the coordinates
    /// received as parameter.
    // parameters: cell index, weight
    int setCellWeight(lua_State *L);

    /// Sets the weight for the neighborhood relationship with the Neighbor pointed by the Neighborhood iterator.
    // parameters: weight
    int setWeight( lua_State *L);

    /// Puts the Neighborhood iterator in the beginning of the Neighbor composite data structure
    /// no parameters
    int first( lua_State *L);

    /// Puts the Neighborhood iterator in the end of the Neighbor composite data structure
    /// no parameters
    int last( lua_State* L);

    /// Returns true if the Neighborhood iterator is in the beginning of the Neighbor composite data structure
    /// no parameters
    int isFirst( lua_State *L );

    /// Returns true if the Neighborhood iterator is in the end of the Neighbor composite data structure
    /// no parameters
    int  isLast( lua_State *L );

    /// Checks if a given cell is within the luaNeighborhood
	/// parameters: cell
	/// \author Raian Vargas Maretto
		int isNeighbor( lua_State *L );
	
    /// Forwards the Neighborhood iterator to the next Neighbor cell
    /// no parameters
    int next( lua_State *L );

    /// Forwards the Neighborhood iterator to the previous Neighbor cell
    /// no parameters
    ///\author Raian Vargas Maretto
    int previous( lua_State *L );

    /// Gets the X coordinate of the Neighbor cell pointed by the Neighborhood iterator
    /// no parameters
    int getX( lua_State *L );

    /// Gets the Y coordinate of the Neighbor cell pointed by the Neighborhood iterator
    /// no parameters
    int getY( lua_State *L );

    /// Gets the coordenates of the Neighbor cell pointed by the Neighborhood iterator
    /// no parameters
    int getCoord( lua_State *L );

    /// Returns true if the Neighborhood is empty.
    /// no parameters
    int isEmpty(lua_State *L);

    /// Clears all the Neighborhood content
    /// no parameters
    int clear(lua_State *L);

    /// Returns the number of Neighbors cells in the Neighborhood
    /// no parameters
    int size(lua_State *L);

        /// Gets the Neighborhood Parent, i. e., the "central" cell in the neighborhood graph.
        /// no parameters
        /// \author Raian Vargas Maretto
        int getParent( lua_State *L );
    
    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observer attributes table, observer type parameters
    int createObserver( lua_State *L );

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L );
    
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


};

#endif
