/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
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

/*!
 * \file observer.h
 * \brief Design Pattern Subject and Observer interfaces
 * \author Antonio José da Cunha Rodrigues 
 * \author Tiago Garcia de Senna Carneiro
*/

#ifndef OBSERVER_INTERFACE
#define OBSERVER_INTERFACE

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
//#include <iostream>

#include <QDataStream>
// #include <QDateTime>
#include <QStringList>
#include <QPair>
#include <QString>
#include <QTextStream>

#include "observerGlobals.h"

namespace TerraMEObserver{
    class Attributes;
    class Subject;


    inline static void doubleToQString(const double & number, QString & string, 
        const int & precision = TerraMEObserver::NUMBERIC_PRECISION)
    {
        string = "";
	    QTextStream textStream(&string);
        textStream.setRealNumberPrecision(precision);
        textStream << number;
    }

}


/// Auxiliary Function for sorting objects Attributes by the type.
bool sortAttribByType(TerraMEObserver::Attributes *a, TerraMEObserver::Attributes *b);

/// Auxiliary Function for sorting objects Subjects by the class name.
bool sortByClassName(const QPair<TerraMEObserver::Subject *, QString> & pair1, 
    const QPair<TerraMEObserver::Subject *, QString> & pair2);


// ---------------------- 

//const char *getSubjectName(TypesOfSubjects type);
//const char *getObserverName(TypesOfObservers type);
//const char *getDataName(TypesOfData type);
//const char *getGroupingName(GroupingMode type);
//const char *getStdDevNames(StdDev type);

/**
* Converts the subject type for the name subject in string format
* \param subject type enumarator
* \return subject string name
*/
const char *getSubjectName(int type);

/**
* Converts the observer type for a string format
* \param observer type enumarator
* \return observer string name
*/
const char *getObserverName(int type);

/**
* Converts the data type for a string format
* \param data type enumarator
* \return data string name
*/
const char *getDataName(int type);

/**
* Converts the grouping type for a string format
* \param grouping type enumarator
* \return grouping string name
*/
const char *getGroupingName(int type);

/**
* Converts the standard deviation type for a string format
* \param standard deviatio type enumarator
* \return standard deviatio string name
*/
const char *getStdDevNames(int type);

/**
* Delays the application for some seconds
* \param seconds float
*/
void delay(float seconds);


namespace TerraMEObserver{

class Subject;

/**
* \brief
*  Interface for an Observer object.
*
*/
class Observer
{
public:

    /**
    * Triggers the observer process
    * \param time the simulation time
    * \return boolean, returns \a true if the observer could be updated.
    * Otherwise, returns \a false.
    */
    virtual bool update(double time) = 0;

    /**
    * Sets the simulation time
    * Used in the observer dinamic graphic
    * \param time simulation time
    */ 
    virtual void setModelTime(double time) = 0;

    /**
    * Sets the visibility of a Observer
    * \param visible boolean, if \a true observer is visible.
    * Otherwise, observer is hide
    */
    virtual void setVisible(bool visible) = 0;

    /**
    * Gets the visibility of a Observer
    */
    virtual bool getVisible() = 0;

    /**
     * Draws the internal state of a Subject
     * \param state a reference to a QDataStream object
     * \return a boolean, \a true if the internal state was rendered.
     * Otherwise, returns \a false
     * \see QDataStream
     */
    virtual bool draw(QDataStream &state) = 0;

    /**
    * Gets the Observer unique identification
    */
    virtual int getId() = 0;

    /**
     * Gets the type of observer
     * \see TypesOfObservers
     */
    virtual const TypesOfObservers getType() = 0;

    /* *
     * Sets the attributes for observation in the observer
     * \param attribs a list of attributes under observation
     */
    // virtual void setAttributes(QStringList &) = 0;
    
    /**
    * Recupera a lista de atributos em observação
    * \return QStringList lista de atributtos
    */
    virtual QStringList getAttributes() = 0;


    /**
     * Sets the \a dirty-bit for the Observer internal state
     */
    virtual void setDirtyBit() = 0;
};

/**
 * \brief
 *  TerraME Subject Interface.
 *
 */
class Subject
{
public:
    /**
     * Attachs a Observer \a obs to a Subject
     * \param obs a pointer to an Observer object
     * \see Observer
     */
    virtual void attach(Observer *obs) = 0;

    /**
     * Detachs a Observer \a obs to a Subject
     * \param obs a pointer to a Observer object
     * \see Observer
     */
    virtual void detach(Observer *obs) = 0;

    /**
     * Gets a Observer object by their \a id
     * \param id the unique identifier to an Observer
     * \return a pointer to a Observer or a null pointer
     */
    virtual Observer * getObserverById(int id) = 0;

    /**
     * Trigger the renderization process for every Oberver attached in a Subject
     * \param time the simulation time
     */
    virtual void notify(double time) = 0;

    /**
    *  Gets the internal Subject state and serialize them
    * \param state the internal state of the Subject \a subj
    * \param subj a pointer to a Subject
    * \param observerId the unique identifier of an Observer
    * \param attribs the list of attributes under observation
    * \return a serialized internal state of the Subject \a subj
    * \see Subject,
    * \see QDataStream, \see QStringList
    */
    virtual QDataStream& getState(QDataStream &state, Subject *subj,
                                  int observerId, QStringList &attribs) = 0;
    
    /**
    * Gets the type of Subject
    * \see TypesOfSubjects
    */
    virtual const TypesOfSubjects getType() = 0;

    /**
    * Gets the unique identifier of a Subject
    */
    virtual int getId() const = 0;
};

}


#endif
