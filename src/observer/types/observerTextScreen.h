/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#ifndef OBSERVER_TEXTSCREEN
#define OBSERVER_TEXTSCREEN

#include "observerInterf.h"

#include <QDialog>
#include <QTextEdit>
#include <QString>
#include <QStringList>
#include <QThread>
#include <QCloseEvent>

namespace TerraMEObserver {

/**
 * \brief Shows in tabled form attributes observed
 * \see QTextEdit
 * \see ObserverInterf, \see QThread
 * \author Antonio Jos? da Cunha Rodrigues
 * \file observerTextScreen.h
 */
class ObserverTextScreen : public QDialog, public ObserverInterf, public QThread
{
public:
    /* *
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QWidget
     */
    // ObserverTextScreen(QWidget *parent = 0);

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \param parent a pointer to a QWidget
     * \see Subject
     * \see QWidget
     */
    ObserverTextScreen(Subject *subj, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverTextScreen();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &);

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
     * \copydoc Observer::getAttributes
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

    void save(std::string file, std::string extension);

protected:
    /**
     * Runs the thread
     * \see QThread
     */
    void run();

private:
    /**
     * Gets the state of the file header
     */
    bool headerDefined();

    /**
     * Writes the state into the file
     */
    bool write();

    void resizeEvent(QResizeEvent *event);
    void moveEvent(QMoveEvent *event);
    void closeEvent(QCloseEvent *event);

    void saveAsImage(std::string file, std::string extension);

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QStringList attribList, valuesList;

    bool header;
    bool paused;

    QTextEdit *textEdit;
};

} // namespace TerraMEObserver

#endif
