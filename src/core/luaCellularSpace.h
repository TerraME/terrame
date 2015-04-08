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
/*! \file luaCellularSpace.h
    \brief This file definitions for the luaCellularSpace objects.
        \author Tiago Garcia de Senna Carneiro
*/
#if ! defined( LUACELLULARSPACE_H )
#define LUACELLULARSPACE_H

extern "C"
{
#include <lua.h>
}
#include "luna.h"

#include <QHash>
#include <QByteArray>

#include "cellSpaceSubjectInterf.h"
#include "luaCell.h"
#include "reference.h"

// Protocol Buffers
namespace ObserverDatagramPkg
{
    class SubjectAttribute; 
}

class TeDatabase;
class TeTheme;
class TeDatabasePortal;
struct TeGrouping;

/**
* \brief  
*  Implementation for a luaCellularSpace object. It is integrated with TerraLib geographical databases.
*
*/
class luaCellularSpace : public CellSpaceSubjectInterf, public Reference<luaCellularSpace>
{
    string dbType; ///< database type, e. g., MySQL, ADO, etc...
    string host;  ///< host name
    string dbName; ///< database name
    string user;  ///< user name
    string pass;  ///< password
    string inputLayerName; ///< database input layer
    string inputThemeName;  ///< database input TeTheme name
    vector<string> attrNames; ///< TeTable attribute names
    string whereClause;  ///< SQL WHERE CLAUSE string used to querie the TeTheme
    int port;

    lua_State *luaL; ///< Stores locally the lua stack location in memory
    TypesOfSubjects subjectType;
    bool getSpaceDimensions;
    QHash<QString, QString> observedAttribs;
    QHash<int, Observer *> observersHash;

    QByteArray getAll(QDataStream& in, const QStringList& attribs);
    QByteArray getChanges(QDataStream& in, const QStringList& attribs);

#ifndef TME_NO_TERRALIB
    void loadLegendsFromDatabase(TeDatabase *db, TeTheme *inputTheme, QString& luaLegend);
	QStringList retrieveStdDeviationColorBar(QStringList colorBarRawItems);
	QStringList retrieveUniqueValueColorBar(TeTheme *inputTheme);
	QStringList retrieveColorBar(TeDatabasePortal *portal, TeTheme *inputTheme, TeGrouping *grouping);

	QString retrieveLegendType(int attrType);
	QString retrieveMaxValue(TeDatabasePortal *portal, TeTheme *inputTheme,QString attrName ,int attrType);
	QString retrieveMinValue(TeDatabasePortal *portal, TeTheme *inputTheme,QString attrName ,int attrType);
	QString retrieveStdMode(int attrType, TeGrouping grouping);

#endif // TME_NO_TERRALIB
    
public:
    ///< Data structure issued by Luna<T>
    static const char className[]; 

    ///< Data structure issued by Luna<T>
    static Luna<luaCellularSpace>::RegType methods[]; 

public:
    /// constructor
    luaCellularSpace(lua_State *L);

    /// Sets the database type: MySQL, ADO, etc.
    int setDBType(lua_State *L );

    /// Sets the host name.
    int setHostName(lua_State *L );

    /// Sets the database name.
    int setDBName(lua_State *L );

    int getDBName(lua_State *L);

    /// Sets the user name.
    int setUser(lua_State *L );

    /// Sets the password name.
    int setPassword(lua_State *L );

    /// Sets the geographical database layer name
    int setLayer(lua_State *L );

    /// Sets the geographical database theme name
    int setTheme(lua_State *L );

    /// Clears the cellular space attributes names
    int clearAttrName(lua_State *L) ;

    /// Adds a new attribute name to the CellularSpace attributes table used in the load function
    int addAttrName( lua_State *L);

    /// Sets the SQL WHERE CLAUSE to the string received as parameter
    int setWhereClause(lua_State *L );

    /// Load the luaCellularSpace object from the TerraLib geographic database
    int load(lua_State *L);
    
    /// Load the luaCellularSpace object from the Shapefile
    int loadShape(lua_State *L);

    int saveShape(lua_State *L);

#ifndef TME_NO_TERRALIB
    /// Save the luaCellularSpace object to the TerraLib geographic database
    int save(lua_State *L);
#endif

    /// Clear all luaCellularSpace object content (cells)
    int clear(lua_State *L);

    /// Loads a luaNeighborhood from a GAL text file
    int loadGALNeighborhood(lua_State *L);

#ifndef TME_NO_TERRALIB
    /// Loads a luaNeighborhood from a GPM matrix stored into a TerraLib database
    int loadTerraLibGPM( lua_State *L);
#endif

    /// Adds a the luaCell received as parameter to the luaCellularSpace object
    /// parameters: x, y, luaCell
    int addCell( lua_State *L);

    /// Gets the luaCell object within the CellularSpace identified by the coordenates received as parameter
    /// parameters: cell index
    int getCell(lua_State *L);

    /// Returns the number of cells of the CellularSpace object
    /// no parameters
    int size(lua_State* L);

    int setPort(lua_State* L);

	/// Gets the name of the layer
	/// \author Raian Vargas Maretto
	void setLayerName( string layerName );

	/// Sets the name of the layer
	/// \author Raian Vargas Maretto
	int getLayerName(lua_State *L);

	/// Sets the name of the layer
	/// \author Raian Vargas Maretto
	string getLayerName( );

    /// Creates several types of observers to the luaCellularSpace object
    /// parameters: observer type, observeb attributes table, observer type parameters
    int createObserver( lua_State *L );

    /// Notifies the Observer objects about changes in the luaCellularSpace internal state
    int notify(lua_State *L );
    
    /// Returns the Agent Map Observers linked to this cellular space
    /// \param observerId the id of observer
    // \return a pointer for an observer if the id exists. Otherwise, returns a NULL pointer
    Observer * getObserver(int observerId);

    /// Gets the subject's type
    const TypesOfSubjects getType() const;

    /// Gets the object's internal state (serialization)
    /// \param in the serializated object that contains the data that will be observed in the observer
    /// \param subject a pointer to a observed subject
    /// \param observerId the id of the observer
    /// \param attribs the list of attributes observed
    QDataStream& getState(QDataStream& in, Subject *subject, int observerID, const QStringList& attribs);

	/**
	 * Gets the attributes of Lua stack
	 * \param attribs the list of attributes observed
	 */
    QByteArray pop(lua_State *L, const QStringList& attribs, ObserverDatagramPkg::SubjectAttribute *csSubj,
        ObserverDatagramPkg::SubjectAttribute *parentSubj);

    /// Destroys the observer object instance
    int kill(lua_State *L);

    /// This method loads a neighborhood from a file. Extensions supported: .GAL, .GWT, .txt
	/// \author  Raian Vargas Maretto
    int loadNeighborhood(lua_State *L);

	/// Loads a neighborhood from a .gpm file.
	/// \author  Raian Vargas Maretto
	int loadNeighborhoodGPMFile(lua_State *L, const char* fileName, const char* neighName, bool check);
	
	/// Loads GAL Neighborhood files
	/// \author Raian Vargas Maretto
    int loadNeighborhoodGALFile(lua_State *L, const char* fileName, const char* neighName, bool check);

	/// Loads GWT Neighborhood files
	/// \author Raian Vargas Maretto
    int loadNeighborhoodGWTFile(lua_State *L, const char* fileName, const char* neighName, bool check);

	/// Loads TXT Neighborhood file.
	/// \author Raian Vargas Maretto
    int loadTXTNeighborhood(lua_State *L, const char* fileName, const char* neighName, bool check);

	/// Find a cell given a cell ID
	/// \author Raian Vargas Maretto
	luaCell * findCellByID(const char* cellID);

	/// Gets the luaCell object within the CellularSpace identified by the cell ID received as parameter
	/// \author Raian Vargas Maretto
	int getCellByID(lua_State *L);
};

/// Find a cell given a luaCellularSpace object and a luaCellIndex object
luaCell * findCell( luaCellularSpace* cs, CellIndex& cellIndex);

#ifndef TME_NO_TERRALIB
#if defined( TME_MSVC ) && defined( TME_WIN32 )
void configureADO();
#endif
#endif // TME_NO_TERRALIB

#endif

