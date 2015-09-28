#include "attribute.h"

Attribute::Attribute() {}

//Attribute::Attribute(const string name, const string value, Type type) :
//    name(name), value(value), type(type)
//{
//}

Attribute::Attribute(const string name, const string value, Type type,
                     bool pk, unsigned int length) :
    name(name), value(value), type(type), pk(pk), length(length)
{
}

Attribute::~Attribute() {}

void Attribute::setName(const string name)
{
    this->name = name;
}

const string Attribute::getName() const
{
    return name;
}

void Attribute::setValue(const string value)
{
    this->value = value;
}

const string Attribute::getValue() const
{
    return value;
}

void Attribute::setType(Type type)
{
    this->type = type;
}

const Attribute::Type Attribute::getType() const
{
    return type;
}

void Attribute::setPk(bool primary)
{
    this->pk = primary;
}

bool Attribute::getPk() const
{
    return pk;
}

void Attribute::setLength(unsigned int length)
{
    this->length = length;
}

unsigned int Attribute::getLength() const
{
    return length;
}
