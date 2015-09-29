#include "cellMapper.h"

CellMapper::CellMapper()
{}

CellMapper::CellMapper(const string id) :
    id(id)
{}

CellMapper::CellMapper(const CellMapper &other) :
    id(other.id), x(other.x), y(other.y), attributes(other.attributes)
//    pk(other.pk), length(other.length)
{
}

CellMapper::CellMapper(const string id, int x, int y) :
    id(id), x(x), y(y)
{
}

CellMapper::~CellMapper()
{}

//CellMapper::CellMapper(string id, int x, int y, bool pk, unsigned int length) :
//    id(id), x(x), y(y), pk(pk), length(length)
//{
//}

string CellMapper::getId() const
{
    return id;
}

int CellMapper::getX() const
{
    return x;
}

int CellMapper::getY() const
{
    return y;
}

void CellMapper::addAttribute(const string name, const string value,
                              const Attribute::Type type, bool pk, unsigned int lenght)
{
    attributes.push_back(Attribute(name, value, type, pk, lenght));
}

//void CellMapper::addAttribute(const string value)
//{
//    addAttribute(NULL, value, Attribute::UNKNOWN);
//}

vector<Attribute> CellMapper::getAttributes() const
{
    return attributes;
}

CellMapper& CellMapper::operator=(const CellMapper& other)
{
    if (this != &other)
    {
        id = other.id;
        x = other.x;
        y = other.y;
//        pk = other.pk;
//        length = other.length;
        attributes = other.attributes;

        return *this;
    }

    return *this;
}
