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

#ifndef OBSERVER_LOG_FILE
#define OBSERVER_LOG_FILE

#include "observerInterf.h"

#include <QDialog>
#include <QString>
#include <QStringList>
#include <QFile>
#include <QThread>
#include <QCloseEvent>

#include <iostream>

namespace TerraMEObserver {

class LogFileTask;

/**
 * \brief Saves the observed attributes in a log file
 * \see QObject
 * \see ObserverInterf
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerGraphic.h
*/
class ObserverLogFile : public QObject, public ObserverInterf
{
public:
    // TODO
    //enum WriteMode {
    //    WriteOnly = 0,
    //    Append = 1
    // // WriteMode == w  -> writeOnly
    // // WriteMode == w+ -> append
    //};


    /**
     * Default constructor
     */
    ObserverLogFile(QObject *parent = 0);

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \see Subject
     */
    ObserverLogFile (Subject *subj, QObject *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverLogFile();

    /**
     * Draws the internal state of a Subject
     * \param state a reference to a QDataStream object
     * \return a boolean, \a true if the internal state was rendered.
     * Otherwise, returns \a false
     * \see  QDataStream
     */
    bool draw(QDataStream &state);

    /**
     * Sets the way for write a file
     * \param filename the filename defined by user or default name
     * \param separator the character used to separate the data
     * \param mode the mode of write a file
     */
    void setProperties(const QString &filename = DEFAULT_NAME + ".csv", 
        const QString &separator = ";", const QString &mode = "w");

    /**
     * Sets the name of the file
     * \param name the filename
     * QString
     */
    void setFileName(const QString & name);

    /**
     * Sets the values separator
     * \param sep the values separator
     * \see QString
     */
    void setSeparator(const QString &sep = ";");

    /**
     * Sets the attributes for observation in the observer
     * \param attribs a list of attributes under observation
     * \see QStringList
     */
    void setAttributes(QStringList &attribs);

    /**
     * Gets the attributes list
     */
    QStringList getAttributes();

    // TODO
    //void setWriteMode(WriteMode mode = WriteMode::WriteOnly);

    // TODO
    //WriteMode getWriteMode();

    /**
     * \todo
     * Sets the file write mode
     * \param mode mode of write in the file
     * \see QString
     */
    void setWriteMode(const QString &mode = "w");

    /**
     * Gets the file write mode
     */
    const QString &getWriteMode() const;

    /**
     * Gets the type of observer
     * \see TypesOfObservers
     */
    const TypesOfObservers getType() const;

    ///**
    // * \deprecated Pauses the thread execution
    // */
    //void pause();

    /**
     * Closes the observer
     */
    int close();

protected:
    ///**
    // * Runs the thread
    // * \see QThread
    // */
    //void run();

private:
    /**
     * Initializes the common object to the constructors
     */
    void init();

    /**
     * Gets the state of the file header
     */
    bool headerDefined();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

#ifndef TME_BLACK_BOARD
    QStringList attribList, valuesList;
#endif

    LogFileTask *logTask;
    QString UNKNOWN;
};

}

#endif
