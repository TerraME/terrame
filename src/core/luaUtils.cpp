/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright © 2001-2008 INPE and TerraLAB/UFOP.

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
\file luaUtils.cpp
\brief This file contains implementations for the TerraME utilitary functions.
\author Tiago Garcia de Senna Carneiro
*/

#include "luaUtils.h"

#include <cstring>

extern lua_State * L; ///< Gobal variabel: Lua stack used for comunication with C++ modules.

/// UTILIITARY FUNCTION - Print the Lua stack. Used for debugging purpose.
/// \param size is the number of position to be printed from the stack top
/// \author Antonio Rodrigues
void luaStackToQString(int size)
{
    lua_State *luaL = L;
    printf("\n");
    for (int i = 0; i < size; i++)
    {
        printf("%i - %s \t %p\n", i, lua_typename(luaL, lua_type(luaL, (i * -1) )),
               lua_topointer(luaL,  (i * -1) ));
    }
    printf("\n");
}


int functionStackLevel(lua_State *L) {
    int i;
    int top = lua_gettop(L);
    for (i = 0; i <= top; i++) { /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { /* strings */
                //printf("idx: %i string: '%s' \t %p\n", i,
                //       lua_tostring(L, i), lua_topointer(L, i));
                // std::cout << lua_tostring(L, i) << std::endl;
                break;
            }
            case LUA_TBOOLEAN: { /* booleans */
                //printf("idx: %i bool: %s \t %p\n", i,
                //       lua_toboolean(L, i) ? "true" : "false", lua_topointer(L, i));
                //std::cout << (lua_toboolean(L, i) ? "true" : "false") << std::endl;
                break;
            }
            case LUA_TNUMBER: { /* numbers */
                //printf("idx: %i number: %g \t %p\n", i, lua_tonumber(L, i), lua_topointer(L, i));
                //std::cout << lua_tonumber(L, i) << std::endl;
                break;
            }
            default: { /* other values */
                printf("idx: %i others: %s \t %p\n", i, lua_typename(L, t), lua_topointer(L, i));
                //std::cout << lua_typename(L, t) << std::endl;
                break;
            }
        }
    }
    return i;
}

void stackDump (lua_State *L) {
    int i;
    int top = lua_gettop(L);
    printf("pilha Lua - top: %i\n ", top);
    //for (i = top; i >= 0; i--) { /* repeat for each level */
    for (i = 0; i <= top; i++) { /* repeat for each level */
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { /* strings */
                printf("idx: %i string: '%s' \t %p\n", i,
                       lua_tostring(L, i), lua_topointer(L, i));
                // std::cout << lua_tostring(L, i) << std::endl;
                break;
            }
            case LUA_TBOOLEAN: { /* booleans */
                printf("idx: %i bool: %s \t %p\n", i,
                       lua_toboolean(L, i) ? "true" : "false", lua_topointer(L, i));
                //std::cout << (lua_toboolean(L, i) ? "true" : "false") << std::endl;
                break;
            }
            case LUA_TNUMBER: { /* numbers */
                printf("idx: %i number: %g \t %p\n", i, lua_tonumber(L, i), lua_topointer(L, i));
                //std::cout << lua_tonumber(L, i) << std::endl;
                break;
            }
            default: { /* other values */
                printf("idx: %i others: %s \t %p\n", i, lua_typename(L, t), lua_topointer(L, i));
                //std::cout << lua_typename(L, t) << std::endl;
                break;
            }
        }
        printf(" "); /* put a separator */
    }
    printf("\n\n"); /* end the listing */
}
/// UTILIITARY FUNCTION - Checks if the value located at index "idx" in the Lua stack "L" is of the 
/// user defined type "name".
/// \param L is a Lua stack
/// \param idx is a Lua stack position index
/// \param name is an user defined Lua type name
/// \return A boolean value: true case positive, otherwise false.
int isudatatype (lua_State *L, int idx, const char *name)
{ // returns true if a userdata is of a certain type
    int res;
    if (lua_type(L,idx)!=LUA_TUSERDATA) return 0;
    lua_getmetatable(L,idx);
    luaL_newmetatable (L, name);
    res = lua_compare(L,-2,-1,LUA_OPEQ);
    lua_pop(L,2); // pop both tables (metatables) off
    return res;
} 

/// UTILITARY FUNCTION - Converts a TerraLib object ID to (x,y) coordinates
/// \param objId is a "const char const *" containing the object ID
/// \param x is a natural number returned by this function
/// \param y is a natural number returned by this fucntion
// RODRIGO
//void objectId2coords( const char const * objId, int &x, int &y)
void objectId2coords( const char * objId, int &x, int &y)
{
    char lin[32], col[32];
    char seps[] = "CL";
    char aux[255]="";

    strncpy(aux, objId, strlen(objId));
    strcpy( col, strtok( (char*)aux, seps ));
    strcpy( lin,  strtok( NULL, seps ) );
    //cout << "{" << col <<","<< lin <<"}" << endl;
    x = atoi(col);
    y = atoi(lin);
}


//-------------------------------------------------------------------------------------
//----------------------- AUXILIARY FUNCTION TO DELETE TABLES -------------------------  
//-------------------------------------------------------------------------------------

/// UTILIITARY FUNCTION - Deletes a table from a TerraLib geographical database.
/// \param db is a pointer to a TerraLib database
/// \param tableName is the name of the table being removed
/// \return Return true in case of sucess, otherwise it returns false. 
bool deleteLayerTableName ( TeDatabase *db, std::string &tableName )
{
    TeDatabasePortal* portal = db->getPortal();

    if( !portal )
        return false;

    string query = "SELECT attr_table, table_id FROM te_layer_table WHERE attr_table = '" + tableName + "'";

    if( !portal->query( query ) )
    {
        delete portal;
        return false;
    }

    vector<int> tableIds;
    string attrTable;
    string tableId;
    string drop;
    while ( portal->fetchRow() )
    {
        attrTable = portal->getData(0);
        tableId = portal->getData(1);
        //drop = "DROP TABLE " + attrTable;
        if( db->tableExist( attrTable ) )
        {
            if( !db->deleteTable( attrTable ) ) //if( !db->execute( drop ) )
            {
                cout << "Error: fail to delete table \"" << attrTable
                     << db->errorMessage() << endl;
                db->close();
                delete portal;
                return false;
            }
        }
        tableIds.push_back( atoi ( tableId.c_str() ) );

        string del = "DELETE FROM te_layer_table WHERE table_id = "+ tableId;
        db->execute(del);
    }

    delete portal;
    string del;
    del = "DELETE FROM te_layer_table WHERE attr_table = '" + tableName + "'";
    if ( !db->execute ( del ) )
        return false;
    return true;
} 

//-------------------------------------------------------------------------------------
//--------------------------- AUXILIARY FUNCTION TO CREATE THEMES ---------------------
//-------------------------------------------------------------------------------------

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
bool createNewTheme( TeTable attTable, char outputTable[], string whereClause, string inputThemeName, TeView *view, TeLayer *layer, TeDatabase *db, TeTheme *theme )
{
    TeTheme inputTheme( inputThemeName, layer); // Raian
    /// load the inputTheme properties
    // loads the existing view
    if( !db->loadTheme( &inputTheme ) )
    {
        cout << "Error: fail to load theme \"" << inputThemeName
             << db->errorMessage() << endl;
        db->close();
        return false;
    }

    view->add(theme);

    if( ! whereClause. empty() ) theme->attributeRest(whereClause);

    // Set a default visual for the geometries of the objects of the layer
    // Polygons will be set with the blue color
    TeVisual polygonVisual(TePOLYGONS);
    TeColor azul(0,0,255); // Raian: polygonVisual.color(TeColor(0,0,255));
    polygonVisual.color(azul);

    // Points will be set with the red color
    TeVisual pointVisual(TePOINTS);
    TeColor vermelho(255,0,0); // Raian: pointVisual.color(TeColor(255,0,0));
    pointVisual.color(vermelho);
    pointVisual.style(TePtTypeX);

    // Set all of the geometrical representations to be visible
    int allRep = layer->geomRep();
    theme->visibleRep(allRep);

    // Select all the attribute tables of the inputTheme
    // and add the new attribute table
    theme->setAttTables( inputTheme.attrTables() );
    theme->addThemeTable( attTable );

    // Save the theme in the database
    if (!theme->save())
    {
        cout << "Error: fail to save the theme \"" << outputTable << "\" in the database: "
             << db->errorMessage() << endl;
        db->close();
        return false;
    }

    // Build the collection of objects associated to the theme*****
    TeAttrTableVector attrsDim;
    inputTheme.getAttTables(attrsDim, TeFixedGeomDynAttr);

    string colTable = theme->collectionTable();
    string colAuxTable = theme->collectionAuxTable ();

    // ------------------------ collection
    string popule;
    popule = " INSERT INTO "+ colTable +" (c_object_id) ";
    popule += " SELECT object_id_ FROM "+ string(outputTable);
    if (!db->execute(popule))
    {
        cout << "Error: fail to build the theme collection\""<< outputTable << "\": " << db->errorMessage()
             << endl;
        db->close();
        return false;
    }
    popule = "UPDATE " + colTable;
    popule += " SET c_legend_id=0, c_legend_own=0, c_object_status=0 ";
    if (!db->execute(popule))
    {
        cout << "Error: fail to build the theme collection\""<< outputTable << "\": " << db->errorMessage()
             << endl;
        db->close();
        return false;
    }
    // ------------------------ collection aux
    if( !attrsDim.empty() && attrsDim[0].name() != "" ){
        string ins = "INSERT INTO "+ colAuxTable +" (object_id, aux0, grid_status) ";
        ins += " SELECT "+ string(outputTable) +".object_id_, "+ attrsDim[0].name() +".attr_id, 0";
        ins += " FROM "+ string(outputTable)+" LEFT JOIN "+ attrsDim[0].name() +" ON ";
        ins += string(outputTable)+".object_id_ = "+ attrsDim[0].name() +".object_id_";
        if (!db->execute(ins))
        {
            cout << "Error: fail to build the theme collection\""<< outputTable << "\": " << db->errorMessage()
                 << endl;
            db->close();
            return false;
        }
    }
    else {
        string ins = "INSERT INTO "+ colAuxTable +" (object_id, grid_status) ";
        ins += " SELECT "+ string(outputTable) +".object_id_, 0";
        ins += " FROM "+ string(outputTable);
        if (!db->execute(ins))
        {
            cout << "Error: fail to build the theme collection\""<< outputTable << "\": " << db->errorMessage()
                 << endl;
            db->close();
            return false;
        }
    };
    return true;

}
