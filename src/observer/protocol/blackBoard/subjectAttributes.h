#ifndef SUBJECTATTRIBUTES_H
#define SUBJECTATTRIBUTES_H

#include <QString>
#include <QHash>
#include <QVector>
#include <QDebug>
#include <time.h>
#include "observer.h"

namespace TerraMEObserver
{

/**
 * Decoded attributes retrieved from Lua
 *
 */
class RawAttribute
{
public:
    /**
     * Default constructor
     */
    RawAttribute() : key(""), type(TObsUnknownData), number(-1), text("")
    {
    }

    /**
     * Constructor for text attribute
     */
    RawAttribute(const QString &k, const TypesOfData &t, const QString &v)
    {
        key = k;
        type = t;
        text = v;
        number = -1;
    }

    /**
     * Constructor for number attribute
     */
    RawAttribute(const QString &k, const TypesOfData &t, const double &v)
    {
        key = k;
        type = t;
        number = v;
        text = "";
    }

    /**
     * Destructor
     */
    virtual ~RawAttribute() {}

    inline void setValue(const QString &k, const TypesOfData &t, const double& v)
    {
        key = k;
        type = t;
        number = v;
    }

    inline void setValue(const QString &k, const TypesOfData &t, const QString& v)
    {
        key = k;
        type = t;
        text = v;
    }

    /**
     * Debug method
     * Prints the raw attribute values
     * \see TerraMEObserver::getDataName
     * \see QString
     */
    inline const QString toString() const
    {
        return QString("%1 (%2): %3")
            .arg(key)
            .arg(getDataName(type))
            .arg( ((type == TObsNumber) ? 
                    QString("%1").arg(number) : QString("\"%1\"").arg(text)) 
                );
    }

// private:
    TypesOfData type;
    double number;
    QString key, text;

};


class SubjectAttributes
{
public:
    // typedef QHash<QString, RawAttributeCollection *>::ConstIterator SubjectAttributes::Interator;

    /**
     * Constructor
     */
    SubjectAttributes(int id);

    /**
     * Destructor
     */
    virtual ~SubjectAttributes();

    void setSubjectType(const TypesOfSubjects &type);

    /**
     * Gets the type of subject
     * \return TypesOfSubjects, the type of subject
     */
    inline TypesOfSubjects getType() const { return subjectType; }

    /**
     * Gets the subject id
     * \return int, the subject id
     */
    inline int getId() const { return subjectId; }

    /**
     * Adds and retrieves an attribute
     * \param key, the key of an item (key = CellSpaceID + CellID)
     * \param attrName, the name of an item
     * \param value, the value for the item attrName (value = string or double)
     * \return the retrieved or inserted item
     */
    // template<class T>
    void addItem(const QString &attrName, const double &value = 0.0);

    /**
     * \copydoc TerraMEObserver::SubjectAttributes::addItem
     */
    void addItem(const QString &attrName, const QString &value);

     /**
      * Gets the RawAttribute and all subject attributes that has been observed
      * \param key, the name of the attribute
      * \return a constant pointer for this attribute
      */
    inline const RawAttribute * getRawAttribute(const QString &key)
     {
        if (! attribHash->contains(key))
            return 0;

        return (const RawAttribute *)attribHash->operator[](key);
     }

    /**
     * Gets the numeric value of a attribute
     * \param key, the name of the attribute
     * \param value, returned value of the attribute
     * \return bool, true if the attribute was found
     */
    inline bool getNumericValue(const QString &key, double &value) const 
    { 
        if (! attribHash->contains(key))
            return false;

        value = attribHash->value(key)->number; 
        return true;
    }

    /**
     * Gets the textual value of a attribute
     * \param key, the name of the attribute
     * \param value, returned value of the attribute
     * \param bool, true if the attribute was found
     */
    inline bool getTextValue(const QString &key, QString & value) const 
    { 
        if (! attribHash->contains(key))
            return false;

        value = attribHash->value(key)->text;
        return true;
    }

    /**
     * Removes a attribute by its name
     * \param attrName, the name of a attribute
     * \return bool, true if the attribute was removed.
     */
    bool removeAttributeByName(const QString &attrName);

    // inline const QHash<QString, RawAttribute *>& getRawAttributes() const { return attribHash; }

    /**
     * Sets the bit state of a subject
     * \param value, true if subject is dirty
     */
    inline void setDirtyBit(bool value) { dirtyBit = value; }

    /**
     * Gets the value of bit state
     */
    inline bool getDirtyBit() const { return dirtyBit; }

    /**
     * Sets the attribute coordinate
     * \param x, the x coordinate of the item
     */
    inline void setX(const double &x) { this->x = x; }
    
    /**
     * Sets the attribute coordinate
     * \param y, the y coordinate of the item
     */
    inline void setY(const double &y) { this->y = y; }

    /**
     * Gets the x axis value of a attribute 
     */
    inline const double & getX() const { return x; }
    
    /**
     * Gets the y axis value of a attribute 
     */
    inline const double & getY() const { return y; }
    
    /**
     * Gets all x axis values
     */
    inline QVector<double> * getXs() const { return xs; }
    
    /**
     * Gets all y axis values
     */
    inline QVector<double> * getYs() const { return ys; }

    /**
     * \copydoc TerraMEObserver::RawAttribute::toString
     */
    const QString toString() const;

    /** 
     * Maintains a list of nested subject that had been changed
     */
    inline void addNestedSubject(int subjId) 
    {
		Q_ASSERT_X(nestedSubjectsID, "SubjectAttribute::getNestedSubjects", 
            "The 'nestedSubjectsID' object was not instantiated. It was "
            "defined as no TerraME compose object.\n"
            "Please check the SubjectAttributes::setSubjectType() method.\n");
        nestedSubjectsID->append(subjId); 
    }

    /** 
     * Cleans the nested subject list
     */
    inline void clearNestedSubjects()
    {
        time = clock(); 
        if (nestedSubjectsID)
            nestedSubjectsID->clear();
    }
    
    /**
     * Returns true if it contains some nested subject 
     */
    inline bool hasNestedSubjects() const 
    { 
        return (nestedSubjectsID) && (nestedSubjectsID->size() != 0); 
    }

    /**
     * Gets the constant reference for nested subject list
     */
    inline const QVector<int>& getNestedSubjects() const 
	{ 
		Q_ASSERT_X(nestedSubjectsID, "SubjectAttribute::getNestedSubjects", 
            "The 'nestedSubjectsID' object was not instantiated. It was "
            "defined as no TerraME compose object.\n");
		return *nestedSubjectsID;
	}
    
    /**
     * For debugging
     * \copydoc TerraMEObserver::RawAttribute::getNestedSubjects
     */
    // inline QVector<int> getNestedSubjectsCopy() const { return nestedSubjectsID; }
    
    // 50% mais eficiente que o uso dos ID's
    // inline void addNestedSubject(SubjectAttributes* subj) { nestedSubjectsID.append(subj); }
    // inline const QVector<SubjectAttributes *>& getNestedSubjects() const { return nestedSubjectsID; }
    // inline QVector<SubjectAttributes *> getNestedSubjectsCopy() const { return nestedSubjectsID; }

    inline void clear() 
    { 
        foreach(RawAttribute *raw, attribHash->values()) 
            { delete raw; raw = 0; } 
        
        attribHash->clear();
    }

    /**
     * Sets the time of last update
     */
    inline void setTime(const long &time) { this->time = time; }
    
    /**
     * Gets the time of last update
     */
    inline long getTime() const { return time; }
    
    /**
     * Overload of less operator
     */
    friend inline bool operator< (const SubjectAttributes& a, const SubjectAttributes& b)
    // { return a.getTime() <= b.getTime(); }
    { return a.getTime() < b.getTime(); }

    friend inline bool operator> (const SubjectAttributes& a, const SubjectAttributes& b)
    // { return a.getTime() >= b.getTime(); }
    { return a.getTime() > b.getTime(); }

private:
    //// Hash function based on qHash method of Qt and on PJW hash algorithm (Aho et al. pp. 434-438)
    //// Alfred V. Aho, Ravi Sethi, and Jeffrey D. Ullman, Compilers: Principles, Techniques, and Tools,
    //// Addison-Wesley, 1986.
    //inline uint hashFunction(const QString &key)
    //{
    //    const QChar *p = key.unicode();
    //    int n = key.size();
    //    uint h = 0;
    //    while (n--)
    //    {
    //        h = (h << 5) + (*p++).unicode();
    //        h ^= (h & 0xf0000000) >> 27;
    //        h &= 0x0fffffff;
    //    }
    //    return h;
    //}

    // value: a pointer for a container of raw attribute
    QHash<QString, RawAttribute *> *attribHash;
    bool dirtyBit;
    int subjectId;
    TypesOfSubjects subjectType;
    double x, y;    
    QVector<double> *xs, *ys;

    // Contains the nested subjects
    QVector<int> *nestedSubjectsID;
    
    // 50% mais eficiente que o uso dos ID's mas, d� pau ao limpar o BB
    // QVector<SubjectAttributes *> nestedSubjectsID;

    // Time of last update/acess
    long time;
};

}

#endif // SUBJECTATTRIBUTES_H
