#ifndef ATTRIBUTE_H
#define ATTRIBUTE_H

#include <iostream>
//#include <vector>
using namespace std;

class Attribute
{
public:

    enum Type
    {
        STRING    =   0,
        DATETIME,
        CHARACTER,
        REAL,
        INT,
        BLOB,
        OBJECT,
        UNKNOWN
    };

    Attribute();

//    Attribute(const string name, const string value, Type type);

    Attribute(const string name, const string value, Type type,
              bool pk = false, unsigned int length = 0);

    ~Attribute();

    void setName(const string name);
    const string getName() const;

    void setValue(const string value);
    const string getValue() const;

    void setType(Type type);
    const Type getType() const;

    void setPk(bool primary);
    bool getPk() const;

    void setLength(unsigned int length);
    unsigned int getLength() const;

private:
    string name;
    string value;
    Type type;
    bool pk;
    unsigned int length;
};

#endif
