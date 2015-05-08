#include "subjectAttributes.h"

#include <time.h>
#include <QDebug>

using namespace TerraMEObserver;

SubjectAttributes::SubjectAttributes(int id)
{
    // qDebug() << "SubjectAttributes created: " << id;

    subjectId = id;
    subjectType = TObsUnknown;
    dirtyBit = true;
    time = 0;

    // attribHash->clear();
    attribHash = new QHash<QString, RawAttribute *>();

    // Coordinates
    x = 0;
    y = 0;

    // Pointers of vectors
    xs = 0;
    ys = 0;
    nestedSubjectsID = 0;
}

SubjectAttributes::~SubjectAttributes()
{
    foreach(RawAttribute *raw, attribHash->values())
        delete raw;

    delete attribHash; attribHash = 0;

    delete xs; xs = 0;
    delete ys; ys = 0;
    delete nestedSubjectsID; nestedSubjectsID = 0;
}

const QString SubjectAttributes::toString() const
{
    QString ret = QString("id: %1 (%2) {\n  x: %3, y: %4;\n")
            .arg(subjectId)
            .arg(getSubjectName((int) subjectType))
            .arg(x)
            .arg(y);

    if (attribHash->size() > 0)
    {
        foreach(RawAttribute *raw, attribHash->values())
            ret.append(QString("  %1;\n").arg(raw->toString()));
    }
    ret.append("}\n");
    return ret;
}

void SubjectAttributes::setSubjectType(const TypesOfSubjects &type)
{
    subjectType = type;

    if ((subjectType != TObsCell)
        // && (subjectType != TObsAgent)         // Who knows the location in space is the cell.
        // && (subjectType != TObsAutomaton)     // Therefore, an agent is composed of a cell
      )
    {
        if (!xs) xs = new QVector<double>();
        if (!ys) ys = new QVector<double>();
        if (!nestedSubjectsID) nestedSubjectsID = new QVector<int>();
    }
}

void SubjectAttributes::addItem(const QString &attrName, const double &value)
{
    if (attribHash->contains(attrName))
        attribHash->value(attrName)->setValue(attrName, TObsNumber, value);
    else
        attribHash->insert(attrName, new RawAttribute(attrName, TObsNumber, value));

    // time = clock();
}

void SubjectAttributes::addItem(const QString &attrName, const QString &value)
{
    if (attribHash->contains(attrName))
        attribHash->value(attrName)->setValue(attrName, TObsText, value);
    else
        attribHash->insert(attrName, new RawAttribute(attrName, TObsText, value));

    // time = clock();
}

bool SubjectAttributes::removeAttributeByName(const QString &attrName)
{
    RawAttribute *rawAttr = attribHash->take(attrName);
    delete rawAttr; rawAttr = 0;
    return true;
}

//
//bool operator<(const SubjectAttributes &other)
//{
//    return time <= other.time;
//}
