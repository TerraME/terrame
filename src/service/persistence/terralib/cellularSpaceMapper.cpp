#include "cellularSpaceMapper.h"

#include "luaUtils.h"

#include <TeLayer.h>
#include <TeQuerierParams.h>
#include <TeQuerier.h>

CellularSpaceMapper::CellularSpaceMapper() :
    layer(NULL), theme(NULL)
{
}

CellularSpaceMapper::CellularSpaceMapper(TeLayer *layer, TeTheme *theme) :
    layer(layer), theme(theme)
{
}

CellularSpaceMapper::CellularSpaceMapper(const CellularSpaceMapper &other) :
    layer(other.layer), theme(other.theme), cells(other.cells)
{
}

CellularSpaceMapper::~CellularSpaceMapper()
{
    if (layer)
    {
        layer = NULL;
        delete layer;
    }

    if (theme)
    {
        theme = NULL;
        delete theme;
    }
}

bool CellularSpaceMapper::load(const vector<string> attrNames,
                               const string whereClause)
{
    TeQuerierParams *querierParams = createQuerierParams(attrNames, whereClause);

    if (!loadCells(querierParams))
    {
        return false;
    }

    return true;
}

void CellularSpaceMapper::setCells(vector<CellMapper> cells)
{
    this->cells = cells;
}

vector<CellMapper> CellularSpaceMapper::getCells() const
{
    return cells;
}

TeQuerierParams* CellularSpaceMapper::createQuerierParams(const vector<string> attrNames,
                                                          const string whereClause)
{
    TeQuerierParams *querierParams;

    if (!whereClause.empty())
    {
        TeTheme *tempTheme = new TeTheme("tempTheme", layer);
        tempTheme->attributeRest(whereClause);
        tempTheme->setAttTables(theme->attrTables());

        if(attrNames.empty())
        {
            querierParams = new TeQuerierParams(true, true);
            querierParams->setParams(tempTheme);
        }
        else
        {
            querierParams = new TeQuerierParams(true, attrNames);
            querierParams->setParams(tempTheme);
        }
    }
    else
    {
        if(attrNames.empty())
        {
            querierParams = new TeQuerierParams(true, true);
            querierParams->setParams(theme);
        }
        else
        {
            querierParams = new TeQuerierParams(true, attrNames);
            querierParams->setParams(theme);
        }
    }

    return querierParams;
}

bool CellularSpaceMapper::loadCells(TeQuerierParams *querierParams)
{
    TeQuerier query(*querierParams);
    query.loadInstances();
    TeSTInstance element;

    while(query.fetchInstance(element))
    {
        CellMapper cell = createCell(element);
        cells.push_back(cell);
        element.clear();
    }

    return true;
}

CellMapper CellularSpaceMapper::createCell(TeSTInstance element)
{
    const TePropertyVector& properties = element.getPropertyVector();
    int lin, col;
    char cellId[20];

    if(element.hasCells())
    {
        strcpy((char *)cellId, element.objectId().c_str()); // bad smell
        objectId2coords(cellId, col, lin);
    }
    else
    {
        if(element.hasPolygons() || element.hasPoints() || element.hasLines())
        {
            strcpy((char *)cellId, element.getObjectId().c_str() ); // bad smell
            lin = element.getCentroid().x();
            col = element.getCentroid().y();
        }
    }

    CellMapper cell(cellId, col, lin);

    // puts the others cell's attributes on the table
    for(unsigned int i = 0; i < properties.size(); i++)
    {
        const TeProperty &prop = properties[i];
        string name = prop.attr_.rep_.name_.c_str();
        string value;
        element.getPropertyValue(value, i);

        TeAttrDataType type = prop.attr_.rep_.type_;

        switch(type)
        {
            case TeSTRING:
            case TeDATETIME:
            case TeCHARACTER:
                cell.addAttribute(name, value, Attribute::CHARACTER);
                break;

            case TeREAL:
                cell.addAttribute(name, value, Attribute::REAL);
                break;

            case TeINT:
                cell.addAttribute(name, value, Attribute::INT);
                break;

            case TeBLOB:
            case TeOBJECT:
            case TeUNKNOWN:
            default:
                cell.addAttribute(name, value, Attribute::CHARACTER);
        }
    }

    return cell;
}

TeLayer* CellularSpaceMapper::getLayer() const
{
    return layer;
}

string CellularSpaceMapper::getLayerName() const
{
    return layer->name();
}

CellularSpaceMapper& CellularSpaceMapper::operator=(const CellularSpaceMapper& other)
{
    if (this != &other)
    {
        if (layer)
        {
            layer = NULL;
            delete layer;
        }
        if (theme)
        {
            theme = NULL;
            delete theme;
        }
        if (!cells.empty())
            cells.clear();

        layer = other.layer;
        theme = other.theme;
        cells = other.cells;
    }

    return *this;
}
