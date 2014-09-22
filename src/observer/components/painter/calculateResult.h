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

#ifndef CALCULATE_RESULT_H
#define CALCULATE_RESULT_H


// #include <QtCore/QMutex>
// #include <QtCore/QSize>
// #include <QtCore/QWaitCondition>
// #include <QtCore/QThread>
#include <QtGui/QImage>
#include <QtGui/QPainter>

#include "observer.h"
#include "task.h"

namespace TerraMEObserver {

class Attributes;
class SubjectAttributes;

/**
 * \brief Auxiliary class to draws the cellular space state
 * \see QThread
 * \author Antonio José da Cunha Rodrigues
 * \file painterThread.h
 */
class CalculateResult : public QObject, public BagOfTasks::Task
{
    Q_OBJECT

public:

    /**
     * Constructor
     * \param parent a pointer to a QObject
     * \see QObject
     */
    CalculateResult(const QSize &size, const QList<Attributes *> &attribList, QObject *parent = 0);
    
    /**
     * Destructor
     */
    virtual ~CalculateResult();
  
    void setAttributeList(const QList<Attributes *> &attribs);
    void setWidgetSize(const QSize &size);

    bool execute();

    // Statistic variable. It should be deleted soon
    double waitTime;

signals:
    //void displayImage(const QImage &result);
    void displayImage(const QImage &result);

private:
    
    QSize imageSize; // data for draw others subjects
    QList<Attributes *> attribList;
    QImage result;
};

}

#endif
