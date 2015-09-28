#ifndef TERRALIB_FACADE_H
#define TERRALIB_FACADE_H

#include "cellMapper.h"

class CellularSpaceMapper;

class TeDatabase;
class TeTheme;
class TeLayer;
class TeView;
class TeTable;
class TeAttribute;

#include <iostream>
#include <vector>
using namespace std;

class TerraLibFacade
{
public:
    ~TerraLibFacade();

    static TerraLibFacade* getInstance();

    enum Server
    {
        MYSQL = 0
    };
    
    enum Error
    {
        NONERROR = 0,
        DB_CONNECTION_ERROR,
        DB_VERSION_ERROR,
        DB_NONCONNECTED_ERROR,
        DB_EXECUTE_ERROR,
        THEME_LOAD_ERROR,
        THEME_DELETION_ERROR,
        THEME_SAVE_ERROR,
        LAYER_LOAD_ERROR,
        SHAPE_FILE_OPEN_ERROR,
        VIEW_LOAD_ERROR,
        VIEW_INSERT_ERROR,
        TABLE_DELETION_ERROR,
        UNKNOWN_ERROR
    };

    bool connect(const Server &server, const string &host, const string &user,
                 const string &pass, const string &database, int port);

    CellularSpaceMapper getCellularSpace(const string layerName,
                                        const string themeName,
                                        const vector<string> attrNames,
                                        const string whereClause);

    CellularSpaceMapper getCellularSpace(const string themeName,
                                        const vector<string> attrNames,
                                        const string whereClause);

    const string getLastErrorMessage() const;

    const Error getLastError() const;

    bool save(const string themeName, const string tableName,
              const string whereClause,
              vector<CellMapper> cellsSchemas, vector<CellMapper> cells);

    bool save(const string layerName, const string themeName, const string tableName,
              const string whereClause, vector<CellMapper> cellsSchemas,
              vector<CellMapper> cells);

private:
    static TerraLibFacade *instance;

    TerraLibFacade();

    bool isDbVersionCompatible();
    void resetlastError();
    CellularSpaceMapper loadCellularSpace(CellularSpaceMapper cellularSpace,
                                        const vector<string> attrNames,
                                        const string whereClause);
    CellularSpaceMapper createCellularSpace(const string layerName, const string themeName);
    CellularSpaceMapper createCellularSpace(const string themeName);
    bool createViewAndTheme(CellularSpaceMapper cellularSpace, const string tableName);
    TeView* createView(CellularSpaceMapper cellularSpace);
    TeTable createTableWithSchemas(const string tableName, vector<CellMapper> cellsSchemas);
    vector<TeAttribute> getTeAttributesFromCellsSchemas(vector<CellMapper> cellsSchemas);
    int convertAttrTypeToTeType(Attribute::Type type);
    bool saveTableInLayer(TeTable table, TeLayer *layer, vector<CellMapper> cells);
    void putCellsInTable(TeTable &table, vector<CellMapper> cells);
    TeTheme* createTheme(TeLayer *layer, const string themeName);
    bool createNewTheme(TeTable attTable, const string tableName,
                        const string whereClause, string inputThemeName,
                        TeView *view, TeLayer *layer, TeTheme *theme);
    bool deleteLayerByName(const string name);
    TeDatabase* createServerDb(const Server &server);

    TeDatabase *db;
    string lastErrorMessage;
    Error lastError;
};

#endif
