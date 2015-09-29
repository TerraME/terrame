#ifndef CELLULAR_SPACE_MAPPER_H
#define CELLULAR_SPACE_MAPPER_H

//class CellMapper;
#include "cellMapper.h"

class TeTheme;
class TeLayer;
class TeQuerierParams;
class TeSTInstance;
class TeAttribute;
class TeTable;
class TeProjection;

#include <iostream>
#include <vector>
using namespace std;

class CellularSpaceMapper
{
public:

    CellularSpaceMapper();

    CellularSpaceMapper(const CellularSpaceMapper& other);

    CellularSpaceMapper(TeLayer* layer, TeTheme* theme);

    ~CellularSpaceMapper();

    bool load(const vector<string> attrNames, const string whereClause);

    void setCells(vector<CellMapper> cells);
    vector<CellMapper> getCells() const;

    TeLayer* getLayer() const;

    string getLayerName() const;

    CellularSpaceMapper& operator=(const CellularSpaceMapper& other);

private:
    TeQuerierParams* createQuerierParams(const vector<string> attrNames,
                                         const string whereClause);

    bool loadCells(TeQuerierParams* querierParams);
    CellMapper createCell(TeSTInstance element);

    vector<CellMapper> cells;
//    Legend legend;
    TeTheme *theme;
    TeLayer *layer;
};

#endif
