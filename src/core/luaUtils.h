/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright � 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.

Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*************************************************************************************/

/*!
\file luaUtils.h
\brief This file contains definitions about the TerraME utilitary functions.
\author Tiago Garcia de Senna Carneiro
*/

#if ! defined( LUA_UTILS_H )
#define LUA_UTILS_H

extern "C"
{
	#include <lua.h>
}
#include "luna.h"

#if defined( TME_MSVC ) && defined( TME_WIN32 )
	#include <TeAdoDB.h>
#endif

#include <TeLegendEntry.h>
#include <TeMySQL.h>

#include <TeQuerier.h>
#include <TeQuerierParams.h>

/// UTILIITARY FUNCTION - Print the Lua stack. Used for debugging purpose.
/// \param size is the number of position to be printed from the stack top
/// \author Antonio Rodrigues
void luaStackToQString(int size);

int functionStackLevel(lua_State *L);

void stackDump (lua_State *L);

/// UTILITARY FUNCTION - Checks if the value located at index "idx" in the Lua stack "L" is of the
/// user defined type "name".
/// \param L is a Lua stack
/// \param idx is a Lua stack position index
/// \param name is an user defined Lua type name
/// \return A boolean value: true case positive, otherwise false.
int isudatatype (lua_State *L, int idx, const char *name);

/// UTILITARY FUNCTION - Converts a TerraLib object ID to (x,y) coordinates
/// \param objId is a "const char const *" containing the object ID
/// \param x is a natural number returned by this function
/// \param y is a natural number returned by this fucntion
// RODRIGO
// void objectId2coords( const char const * objId, int &x, int &y);
void objectId2coords( const char * objId, int &x, int &y);

/// UTILIITARY FUNCTION - Deletes a table from a TerraLib geographical database.
/// \param db is a pointer to a TerraLib database
/// \param tableName is the name of the table being removed
/// \return Return true in case of sucess, otherwise it returns false. 
bool deleteLayerTableName ( TeDatabase *db, std::string &tableName );

/// UTILIITARY FUNCTION - Creates a new Theme a TerraLib geographical database
/// \param attTable is a copy to the Theme new attriute table being created
/// \param outputTable is the new Theme table name
/// \param whereClause is a SQL WHERE CLAUSE like string used to querie the TerraLib database
/// \param inputThemeName is a string containing the inputTheme that serves as information 
///        source for the Theme being created
/// \param view is a pointer to the TerrraLib TeView object to which Theme will be attached
/// \param layer is a pointer to the TerrraLib TeLayer object to which Theme will be attached
/// \param db is a pointer to the TerrraLib database into which the Theme will be interted
/// \param theme is a pointer to the TeTheme object being added to the geographical database
bool createNewTheme( TeTable attTable, char outputTable[], string whereClause, string inputThemeName, TeView *view, TeLayer *layer, TeDatabase *db, TeTheme *theme );



#endif
