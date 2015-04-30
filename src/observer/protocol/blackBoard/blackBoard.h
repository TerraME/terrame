/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

#ifndef BLACKBOARD_H
#define BLACKBOARD_H

#include <vector>
#include <QHash>
#include <QReadWriteLock>
#include <QPair>

#include "legendAttributes.h"

//class QBuffer;
// class PrivateCache;

class QDataStream;
class QByteArray;


namespace TerraMEObserver{

class Subject;
class SubjectAttributes;
class Decoder;
class Control;

/**
 * \brief BlackBoard class for optimization of visualization.
 *
 * The blackboard works like a cache memory and try to optimize the state
 * of a Subject.
 * References: Buschmann, F., Meunier, R., Rohnert, H., Sommerlad, P., and Stal, M. (1996).
 *    \a Pattern-oriented \a software \a architecture: \a a \a system \a of \a patterns. John Wiley & Sons, Inc.
 * \author Antonio Jose da Cunha Rodrigues
 * \file blackBoard.h
*/
class BlackBoard
{
public:

    /**
     * Destructor
    */
    virtual ~BlackBoard();

    /**
     * Factory for the BlackBoard object
     * \return reference to the BlackBoard object
     */
    static BlackBoard & getInstance();

    /**
     * Sets the \a dirty-bit for a subject state by their id
     * \param subjectID the unique identifier for a subject
     * \see Subject
     */
    void setDirtyBit(int subjectID);

    /**
     * Gets the \a dirty-bit state for a subject by their id
    */
    bool getDirtyBit(int subjectID) const;

    /**
     * Gets the subject state
     * \param subj a pointer to a subject object
     * \param observerID the unique identifier for a observer
     * \param attribs the list of attributes under observation
     * \return QDataStream a bytestream in serialized format
     * \see Subject, \see Observer
     * \see QDataStream
     */
    QDataStream & getState(Subject *subj, int observerID,
                           const QStringList &attribs);

    /**
     * Checks the state retrieved and decoded is consistent
     */
    inline bool canDraw() const { return canDrawState; }
    /*inline */bool renderingOnlyChanges() const;

    void addSubject(int subjectId);
    SubjectAttributes * getSubject(int subjectId);
    bool removeSubject(int subjectId);
    bool removeSubject(SubjectAttributes *subjAttr);
    inline SubjectAttributes * insertSubject(int subjectId)
        { addSubject(subjectId); return getSubject(subjectId); }

    SubjectAttributes * addAttribute(int subjectId, const QString & name);       

    // Attributes & addAttribute(int subjectId, const QString & name, 
    //     double width, double height = 0.0);

    // Attributes & getAttribute(int subjectId, const QString & name);
	
    // bool removeAttribute(int subjectId, const QString & name);

    // // TO-DO: Antonio - perhaps remove...
    // QHash<QString, Attributes *>& getAttributeHash(int subjectId);

    bool decode(const QByteArray &msg);
    // QByteArray & serialize(int subjectId, QByteArray &data, const QStringList &attributes);

    inline QReadWriteLock *getLocker() { return locker; }

    // Increments the counter of subjects changed
    void incrementCounterChangedSubjects() { countChangedSubjects++; }

    // Resets the counter of subjects changed
    void resetCounterChangedSubjects() { countChangedSubjects = 0; }
    
    void startControl();
    void stopControl();

    // Low performance... it makes two copies
    // const QList<SubjectAttributes *> cachedValues() { return cache.values(); }
    const QHash<int, SubjectAttributes *> & getCache() const { return cache; } 

    void setPercent(double p = 0.8);

    void setWorkersNumber(int number);

    /**
     * Cleans the blackboard content
     * Use it carefully
     */
    void clear();

private:
    Control *control;
    QReadWriteLock *locker;

    /**
     * Constructor
     */
    BlackBoard();

    // key: subject id
    // value: a pointer for a container of attributes
    QHash<int, SubjectAttributes *> cache;
    QHash<int, QPair<double, double> > *deletedSubjects;

    int countChangedSubjects;
    bool canDrawState;
    double percent;
    QByteArray *data;
    QDataStream *state;
    Decoder *protocolDecoder;
};

}
#endif
