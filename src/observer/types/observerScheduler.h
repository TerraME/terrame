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

#ifndef OBSERVER_SCHEDULER
#define OBSERVER_SCHEDULER

#include "../observerInterf.h"

#include <QDialog>
#include <QStringList>
#include <QHash>

class QTreeWidget;
class QTreeWidgetItem;
class QLabel;
class QToolButton;
class QResizeEvent;

namespace TerraMEObserver {


/**
 * \brief Shows the schedule events
 * \see ObserverInterf
 * \see QDialog
 * \author Antonio Jos? da Cunha Rodrigues
 * \file observerScheduler.h
*/
class ObserverScheduler : public QDialog, public ObserverInterf
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QWidget
     */
    ObserverScheduler(QWidget *parent = 0);

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \param parent a pointer to a QWidget
     * \see Subject
     * \see QWidget
     */
    ObserverScheduler(Subject *subj, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverScheduler();


    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &state);

    /**
     * Sets the attributes for observation in the observer
     *
     * \param attribs a list of attributes under observation
     */
    void setAttributes(QStringList &attribs);

    /**
     * \copydoc Observer::getAttributes
     */
    QStringList getAttributes();

    /**
     * \copydoc Observer::getType
     */
    const TypesOfObservers getType();

    /**
     * Pauses the thread execution
     */
    void pause();

    /**
     * Closes the window and stops the thread execution
     */
    int close();

private slots:
    /**
     * Treats the expand button click
     */
    void on_butExpand_clicked();

private:
    /**
     * Sets the simulation time
     * \param timer the time of simulation in string format
     * \see QString
     */
    void setTimer(const QString & timer);

    /**
     * Converts a number \a number to a string
     * \param number a number that will be converted
     * \return a number in string format
     * \see QString
     */
    const QString number2String(double number);

    /**
     * \enum ObserverScheduler::PositionItems
     * Positons of the item inside the \a treeWidget component
     */
    enum PositionItems {
        Key,             /*!< a column of the key in treeWidget component  */
        Time,            /*!< a column of the time in treeWidget component  */
        Periodicity,     /*!< a column of the periodicity in treeWidget component  */
        Priority         /*!< a column of the priority in treeWidget component  */
    };


    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    bool paused;		// ref. ? Thread

    QTreeWidget* pipelineWidget;
    QLabel *lblClock;
    QWidget *clockPanel;
    QToolButton *butExpand;

    QStringList attributes;

    QHash<QString, QTreeWidgetItem *> hashTreeItem;

};

}

#endif
