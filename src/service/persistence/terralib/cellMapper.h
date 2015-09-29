#ifndef CELL_MAPPER_H
#define CELL_MAPPER_H

#include "attribute.h"

#include <iostream>
#include <vector>
using namespace std;

class CellMapper
{
public:
    CellMapper();

    CellMapper(const string id);

    CellMapper(const CellMapper &other);

    CellMapper(const string id, int x, int y);

//    CellMapper(string id, int x, int y, bool pk, unsigned int lenght);

    ~CellMapper();

    string getId() const;

    int getX() const;

    int getY() const;

    void addAttribute(const string name, const string value, const Attribute::Type type,
                      bool pk = false, unsigned int lenght = 0);

//    void addAttribute(const string value);

    vector<Attribute> getAttributes() const;

//    TeAttrDataType convertAttrTypeToTeType(Type type);

    CellMapper& operator=(const CellMapper& other);

private:
    string id;
    int x;
    int y;

    vector<Attribute> attributes;
};

#endif
