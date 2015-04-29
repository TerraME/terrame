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

#ifndef OBESERVERMAP_RENDERTHREAD_H
#define OBESERVERMAP_RENDERTHREAD_H


#include <QtCore/QMutex>
#include <QtCore/QSize>
#include <QtCore/QWaitCondition>
#include <QtGui/QImage>
#include <QtCore/QThread>
#include <QtGui/QPainter>

#include "observer.h"
#include "task.h"

/**
 * TME_DRAW_VECTORIAL_AGENTS flag enables the VisualMapping and
 * PainterWidget object draw the Agents and Society as a vector
 * image. So, when the user active Zoom in or Zoom out that subjects
 * are not changed but it are re-drawn.
 */
#define TME_DRAW_VECTORIAL_AGENTS

namespace TerraMEObserver {

class Attributes;
class SubjectAttributes;

/**
 * \brief Auxiliary class to draws the cellular space state
 * \see QThread
 * \author Antonio Jose da Cunha Rodrigues
 * \file painterThread.h
 */
class VisualMapping : public QObject, public BagOfTasks::Task
{
    Q_OBJECT

public:

    /**
     * Constructor
     * \param parent a pointer to a QObject
     * \see QObject
     */
    VisualMapping(TypesOfObservers observerType = TerraMEObserver::TObsMap, 
        QObject *parent = 0);
    
    /**
     * Destructor
     */
    virtual ~VisualMapping();

    // void setVectorPos(QVector<double> *xs, QVector<double> *ys);
   
    // void addTask(ExecMode mode, int priority = 1);
    void setAttributeList(const QList<Attributes *> &attribs);
    void setSize(const QSize & spaceSize, const QSize &cellSize);

    /**
     * Draws a grid in the image with a width \a width and a height \a height
     * \param image a pointer to a QImage
     * \param width reference to a width
     * \param height referenece to a height
     * \see QImage
     */
    void drawGrid(QImage *image, double &width, double &height);

    bool execute();

    void setPath(const QString & path);


// #ifdef TME_STATISTIC
    // Statistic variable. It should be deleted soon
    double waitTime;
// #endif

signals:
    // void update();
    void displayImage(const QImage &result);
    void saveImage(bool result);

public slots:
    void enableGrid(bool);
    void drawAgent(const QImage &result, const QSize &size = QSize());
    void save(const QImage &result);
    /*inline*/ void mappingSociety(Attributes *attrib, QPainter *p, 
        const QImage &result = QImage(), const QSize &size = QSize());

protected:
    /**
     * Runs the thread
     * \see QThread
     */
    // void run();

private:
    /**
     * Draws an Attributes \a attrib using a QPainter \a p
     * \param p a pointer to a QPainter
     * \param attrib a pointer to an attribute
     * \see Attributes, \see QPainter
     */
    void drawAttrib(QPainter *p, Attributes *attrib);

    /**
     * Builds a subject type \a subjType using a painter \a p in
     * the coordenate (\a x, \a y)
     * \param p a pointer to a QPainter
     * \param subjType type of subject
     * \param x axis position
     * \param y axis position
     */
    inline void rendering(QPainter *p, const TypesOfSubjects &subjType , 
        const double &x, const double &y);
	
	/**
     * Draws a Neighborhood object
     * 
     */
	void renderingNeighbor(QPainter *p, const double &xCell, const double &yCell, 
        const double &xNeigh, const double &yNeigh);


    void drawGrid();
    // inline void calculateResult();
    inline void mappingChanges(Attributes *attrib, QPainter *p);
    inline void mappingAll(Attributes *attrib, QPainter *p);
    
    inline void mappingChangesText(Attributes *attrib, QPainter *p);
    inline void mappingAllText(Attributes *attrib, QPainter *p);

    inline void mappingNeighborhood(Attributes *attrib, QPainter *p);

    // QMutex mutex;
    // QWaitCondition condition;
    // bool empty, abort, reconfigMaxMin;
    bool executing, abort, reconfigMaxMin, gridEnabled;

    // data for draw agents
    double propWidthCell, propHeightCell;
    
    QSize spaceSize, cellSize; 

    QVector<int> *agentAttribPositions;
    QList<Attributes *> attribList;
    QImage *gridImage;
    TypesOfObservers observerType;
    
    int countSave;
    QString path;
    // QImage resultImage;
};

}

#endif
