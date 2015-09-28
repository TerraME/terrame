#include "terralibFacade.h"

#include "cellularSpaceMapper.h"

#include "luaUtils.h"

#include <TeDatabase.h>
#include <TeMySQL.h>
#include <TeAttribute.h>

TerraLibFacade* TerraLibFacade::instance = NULL;

TerraLibFacade::TerraLibFacade()
{
    resetlastError();
}

TerraLibFacade::~TerraLibFacade()
{
    if (instance)
    {
        instance = NULL;
        delete instance;
    }
}

TerraLibFacade* TerraLibFacade::getInstance()
{
    if (!instance)
    {
        instance = new TerraLibFacade();
    }

    return instance;
}

bool TerraLibFacade::connect(const Server &server, const string &host,
                             const string &user, const string &pass,
                             const string &database, int port)
{
    resetlastError();

    db = createServerDb(server);

    if (!db->connect(host, user, pass, database, port))
    {
        lastErrorMessage = db->errorMessage();
        lastError = DB_CONNECTION_ERROR;
        return false;
    }

    return true;
}

TeDatabase* TerraLibFacade::createServerDb(const Server &server)
{
    if (server == MYSQL)
    {
        db = new TeMySQL();
    }

    return db;
}

bool TerraLibFacade::isDbVersionCompatible()
{
    string version;
    db->loadVersionStamp(version);

    if (version == TeDBVERSION)
        return true;

    lastErrorMessage = "DB Version expected " + TeDBVERSION;
    lastError = DB_VERSION_ERROR;
    db->close();

    return false;
}

CellularSpaceMapper TerraLibFacade::getCellularSpace(const string layerName,
                                                    const string themeName,
                                                    const vector<string> attrNames,
                                                    const string whereClause)
{
    CellularSpaceMapper cellularSpace = createCellularSpace(layerName, themeName);

    if (lastError != NONERROR)
    {
        return CellularSpaceMapper();
    }

    return loadCellularSpace(cellularSpace, attrNames, whereClause);
}

CellularSpaceMapper TerraLibFacade::getCellularSpace(const string themeName,
                                                    const vector<string> attrNames,
                                                    const string whereClause)
{
    return getCellularSpace("", themeName, attrNames, whereClause);
}

CellularSpaceMapper TerraLibFacade::loadCellularSpace(CellularSpaceMapper cellularSpace,
                                                        const vector<string> attrNames,
                                                        const string whereClause)
{
    if (!cellularSpace.load(attrNames, whereClause))
    {
        lastErrorMessage = "Unknown Error!";
        lastError = UNKNOWN_ERROR;
    }

    return cellularSpace;
}

const string TerraLibFacade::getLastErrorMessage() const
{
    return lastErrorMessage;
}

const TerraLibFacade::Error TerraLibFacade::getLastError() const
{
    return lastError;
}

void TerraLibFacade::resetlastError()
{
    lastError = NONERROR;
    lastErrorMessage = "";
}

bool TerraLibFacade::save(const string themeName, const string tableName,
                          const string whereClause, vector<CellMapper> cellsSchemas,
                          vector<CellMapper> cells)
{
    return save("", themeName, tableName, whereClause, cellsSchemas, cells);
}

bool TerraLibFacade::save(const string layerName, const string themeName,
                          const string tableName, const string whereClause, vector<CellMapper> cellsSchemas,
                          vector<CellMapper> cells)
{
    CellularSpaceMapper cellularSpace = createCellularSpace(layerName, themeName);

    if (lastError != NONERROR)
    {
        db->close();
        return false;
    }

    if(db->tableExist(tableName))
    {
        if(!deleteLayerByName(tableName))
        {
            db->close();
            return false;
        }

    }

    TeTable table = createTableWithSchemas(tableName, cellsSchemas);

    if (saveTableInLayer(table, cellularSpace.getLayer(), cells))
    {
        TeView *view = createView(cellularSpace);

        if (lastError == NONERROR)
        {
            TeTheme *theme = createTheme(cellularSpace.getLayer(), tableName);

            if(lastError == NONERROR)
            {
                if (!createNewTheme(table, tableName, whereClause, themeName,
                                      view, cellularSpace.getLayer(), theme))
                {
                    db->close();
                    return false;
                }
            }

            return true;
        }
        else
        {
            db->close();
            return false;
        }
    }

    return false;
}

TeTable TerraLibFacade::createTableWithSchemas(const string tableName,
                                                 vector<CellMapper> cellsSchemas)
{
    vector<TeAttribute> attrs = getTeAttributesFromCellsSchemas(cellsSchemas);
    TeTable table(tableName, attrs, "object_id_", "object_id_", TeAttrStatic);

    return table;
}

vector<TeAttribute> TerraLibFacade::getTeAttributesFromCellsSchemas(
        vector<CellMapper> cellsSchemas)
{
    vector<TeAttribute> teAttrs;
    for (int i = 0; i < cellsSchemas.size(); i++)
    {
        TeAttribute teAttr;
        vector<Attribute> attrs = cellsSchemas.at(i).getAttributes();
        for (int j = 0; j < attrs.size(); j++)
        {
            teAttr.rep_.name_ = attrs.at(j).getName();
            teAttr.rep_.type_ = (TeAttrDataType)convertAttrTypeToTeType(attrs.at(j).getType());
            teAttr.rep_.isPrimaryKey_ = attrs.at(j).getPk();
            teAttr.rep_.numChar_ = attrs.at(j).getLength();

            teAttrs.push_back(teAttr);
        }
    }

    return teAttrs;
}

int TerraLibFacade::convertAttrTypeToTeType(Attribute::Type type)
{
    switch(type)
    {
        case Attribute::STRING:
        case Attribute::DATETIME:
        case Attribute::CHARACTER:
            return TeSTRING;
            break;

        case Attribute::REAL:
            return TeREAL;
            break;

        case Attribute::INT:
            return TeINT;
            break;

        case Attribute::BLOB:
        case Attribute::OBJECT:
        case Attribute::UNKNOWN:
        default:
            return TeCHARACTER;
    }
}

bool TerraLibFacade::saveTableInLayer(TeTable table, TeLayer *layer,
                                           vector<CellMapper> cells)
{
    if (layer->createAttributeTable(table))
    {
        putCellsInTable(table, cells);

        if (table.size() > 0)
        {
            return layer->saveAttributeTable(table);
        }
    }
    else
    {
        return false;
    }

    return true;
}

void TerraLibFacade::putCellsInTable(TeTable &table,
                                          vector<CellMapper> cells)
{
    TeTableRow tableRow;

    for (int i = 0; i < cells.size(); i++)
    {
        tableRow.push_back(cells.at(i).getId());
        vector<Attribute> attrs = cells.at(i).getAttributes();
        for (int j = 0; j < attrs.size(); j++)
        {
            tableRow.push_back(attrs.at(j).getValue());
        }
        table.add(tableRow);
        tableRow.clear();
    }
}

TeView* TerraLibFacade::createView(CellularSpaceMapper cellularSpace)
{
    // Create a view to show the saved results *****************
    TeProjection* proj = cellularSpace.getLayer()->projection();
    string viewName = "Result";
    TeView* view = new TeView(viewName, db->user());

    // Check whether there is a view with this name in the datatabase
    if (db->viewExist(viewName))
    {
        // loads the existing view
        if(!db->loadView(view))
        {
            string err = string("Error: fail to load view \"")
                    + string(viewName) + string("\" - ")
                    + db->errorMessage()  + string("\n");
            lastErrorMessage = err;
            lastError = VIEW_LOAD_ERROR;

            return NULL; // I don't like this, I will go to improve (maybe exception?)
        }
    }
    else
    {
        // Create a view with the same projection of the layer
        view->projection(proj);
        if (!db->insertView(view))			// save the view in the database
        {
            string err = string("Error: fail to insert the view \"")
                    + string(viewName) + string("\" into the database - ")
                    + db->errorMessage()  + string("\n");
            lastErrorMessage = err;
            lastError = VIEW_INSERT_ERROR;

            return NULL; // I don't like this, I will go to improve (maybe exception?)
        }
    }

    return view;
}

TeTheme* TerraLibFacade::createTheme(TeLayer *layer,
                                     const string themeName)
{
    // Create a theme that will contain the objects of the layer which satisfies the
    // attribute restrictions applied
    TeTheme* theme;
    theme = new TeTheme(themeName, layer);

    // Check whether there is a theme with this name in the datatabse
    if(db->themeExist(themeName))
    {
        /// load the inputTheme properties
        // loads the existing view
        if(!db->loadTheme(theme))
        {
            string err = string("Error: fail to load theme \"")
                    + string(themeName) + string("\" - ")
                    + db->errorMessage()  + string("\n");
            lastErrorMessage = err;
            lastError = THEME_LOAD_ERROR;

            return NULL; // I don't like this, I will go to improve (maybe exception?)
        }

        // delete the existing theme
        int themeId = theme->id();
        if (!db->deleteTheme(themeId))
        {
            string err = string("Error: fail to delete theme \"")
                    + string(themeName) + string("\" - ")
                    + db->errorMessage()  + string("\n");
            lastErrorMessage = err;
            lastError = THEME_DELETION_ERROR;

            return NULL; // I don't like this, I will go to improve (maybe exception?)
        }

        theme = new TeTheme(themeName, layer);
    }

    return theme;
}

bool TerraLibFacade::deleteLayerByName(const string name)
{
    resetlastError();

    if (!db->isConnected())
    {
        lastErrorMessage = "Database is not connected!";
        lastError = DB_NONCONNECTED_ERROR;
        return false;
    }

    TeDatabasePortal* portal = db->getPortal();

    if(!portal)
    {
        return false;
    }

    string query = "SELECT attr_table, table_id FROM te_layer_table WHERE attr_table = '" + name + "'";

    if(!portal->query(query))
    {
        delete portal;

        return false;
    }

    vector<int> tableIds;
    string attrTable;
    string tableId;
    string drop;

    while (portal->fetchRow())
    {
        attrTable = portal->getData(0);
        tableId = portal->getData(1);
        //drop = "DROP TABLE " + attrTable;
        if(db->tableExist(attrTable))
        {
            if(!db->deleteTable(attrTable)) //if( !db->execute( drop ) )
            {
                lastErrorMessage = "Error: fail to delete table \"" + attrTable
                        + db->errorMessage();
                lastError = TABLE_DELETION_ERROR;

                delete portal;
                return false;
            }
        }
        tableIds.push_back(atoi(tableId.c_str()));

        string del = "DELETE FROM te_layer_table WHERE table_id = "+ tableId;
        db->execute(del);
    }

    delete portal;
    string del;
    del = "DELETE FROM te_layer_table WHERE attr_table = '" + name + "'";

    if (!db->execute(del))
    {
        return false;
    }

    return true;
}

CellularSpaceMapper TerraLibFacade::createCellularSpace(const string layerName,
                                                        const string themeName)
{
    resetlastError();

    if (!isDbVersionCompatible())
    {
        return CellularSpaceMapper();
    }

    TeLayer *layer;
    TeTheme *theme;

    if (layerName.empty())
    {
        theme = new TeTheme(themeName);

        if (db->loadTheme(theme))
        {
            layer = theme->layer();
        }
        else
        {
            lastErrorMessage = db->errorMessage();
            lastError = THEME_LOAD_ERROR;
            db->close();

            return CellularSpaceMapper();
        }
    }
    else
    {
        layer = new TeLayer(layerName);
        theme = new TeTheme(themeName, layer);

        if (!db->loadTheme(theme))  // erro, tiago: parece que a terralib carrega um thema com mesmo nome, mas de outro layer, pois
                                    // esta funcao nao falha, caso o tema "inputTheme" nao pertenca ao layer (inputLayer), quando deveria
                                    // assim, o proximo acesso ao aobjeto inputTheme procara uma excecao
                                    // Alem disso, quando dois temas possuem o mesmo nomemem layers diferentes, esta funcao falha
                                    // ao carregar o tema do layer selecionado, so funciona quando se tenta carregar o tema
                                    // do layer que o primeiro a ser inserido no banco, para os demais layers a tentativa abaixo
                                    // de criar um tema temporario ira falhar.
                                    // Se varios bancos que possuirem a mesta estrutura, portanto, temas de com o mesmo nome, estiverem
                                    // abertos simultaneamente no TerraView, entao as vistas e os temas de resultados serao criados nos
                                    // dois bancos simultaneamente. Para isso, e' preciso que os banco tenham o mesmo usuario e senha.
                                    //	Entretanto, as tabelas de resultados nao sao criadas em ambos os bancos.
        {
            lastErrorMessage = db->errorMessage();
            lastError = THEME_LOAD_ERROR;
            db->close();

            return CellularSpaceMapper();
        }
    }

    if (!db->loadLayer(layer))
    {
        lastErrorMessage = db->errorMessage();
        lastError = LAYER_LOAD_ERROR;
        db->close();

        return CellularSpaceMapper();
    }

    CellularSpaceMapper cellularSpace(layer, theme);

    return cellularSpace;
}

CellularSpaceMapper TerraLibFacade::createCellularSpace(const string themeName)
{
    return createCellularSpace("", themeName);
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
/// \param theme is a pointer to the TeTheme object being added to the geographical database
bool TerraLibFacade::createNewTheme(TeTable attTable, const string tableName,
                                    const string whereClause, string inputThemeName,
                                    TeView *view, TeLayer *layer, TeTheme *theme)
{
    TeTheme inputTheme(inputThemeName, layer); // Raian
    /// load the inputTheme properties
    // loads the existing view

    if(!db->loadTheme(&inputTheme))
    {
        lastErrorMessage = "Error: fail to load theme \"" + inputThemeName
                + db->errorMessage();
        lastError = THEME_LOAD_ERROR;

        return false;
    }

    view->add(theme);

    if(!whereClause.empty())
        theme->attributeRest(whereClause);

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
    theme->setAttTables(inputTheme.attrTables());
    theme->addThemeTable(attTable);

    // Save the theme in the database
    if (!theme->save())
    {
        lastErrorMessage = "Error: fail to save the theme \""
                + tableName + "\" in the database: "
                + db->errorMessage();
        lastError = THEME_SAVE_ERROR;

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
    popule += " SELECT object_id_ FROM "+ string(tableName);
    if (!db->execute(popule))
    {
        lastErrorMessage = "Error: fail to build the theme collection\""
                + tableName + "\": " + db->errorMessage();
        lastError = DB_EXECUTE_ERROR;

        return false;
    }

    popule = "UPDATE " + colTable;
    popule += " SET c_legend_id=0, c_legend_own=0, c_object_status=0 ";
    if (!db->execute(popule))
    {
        lastErrorMessage = "Error: fail to build the theme collection\""
                + tableName + "\": " + db->errorMessage();
        lastError = DB_EXECUTE_ERROR;


        return false;
    }

    // ------------------------ collection aux
    if( !attrsDim.empty() && attrsDim[0].name() != "" ){
        string ins = "INSERT INTO "+ colAuxTable +" (object_id, aux0, grid_status) ";
        ins += " SELECT "+ string(tableName) +".object_id_, "+ attrsDim[0].name() +".attr_id, 0";
        ins += " FROM "+ string(tableName)+" LEFT JOIN "+ attrsDim[0].name() +" ON ";
        ins += string(tableName)+".object_id_ = "+ attrsDim[0].name() +".object_id_";
        if (!db->execute(ins))
        {
            lastErrorMessage = "Error: fail to build the theme collection\""
                    + tableName + "\": " + db->errorMessage();
            lastError = DB_EXECUTE_ERROR;

            return false;
        }
    }
    else {
        string ins = "INSERT INTO "+ colAuxTable +" (object_id, grid_status) ";
        ins += " SELECT "+ string(tableName) +".object_id_, 0";
        ins += " FROM "+ string(tableName);
        if (!db->execute(ins))
        {
            lastErrorMessage = "Error: fail to build the theme collection\""
                    + tableName + "\": " + db->errorMessage();
            lastError = DB_EXECUTE_ERROR;

            return false;
        }
    }

    return true;
}

