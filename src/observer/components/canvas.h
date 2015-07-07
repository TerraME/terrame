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

#ifndef CANVAS_H
#define CANVAS_H

#include <QGraphicsView>
#include <QMouseEvent>
#include <QPaintEvent>
#include <QCursor>
#include <QPoint>

class QGraphicsRectItem;

namespace TerraMEObserver
{

/**
 * \brief Draws an state machine
 * \see QGraphicsView
 * \author Antonio Jos? da Cunha Rodrigues
 * \file painterWidget.h
 */
class Canvas : public QGraphicsView
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param scene a pointer to a QGraphicsScene object
     * \param parent a pointer to a QWidget object
     * \see QGraphicsScene, \see QWidget
     */
    Canvas(QGraphicsScene * scene, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~Canvas();

    /**
     * Activates the mouse cursor
     */
    void setWindowCursor();

    /**
     * Activates the zoom pan
     */
    void setPanCursor();


signals:
    /**
     * Emits a new zoom rectangle, a proportion factor for width and height
     * \param rect a new zoom rectangle
     * \param width a proportion factor for the width
     * \param height a proportion factor for the height
     */
    void zoomChanged(QRectF rect, float width, float height);

    /**
     * Emits a signal that zoom out was activated
     */
    void zoomOut();


protected:
    /**
     * Paints event of the user interface object
     * \see QPaintEvent
     */
    void paintEvent(QPaintEvent *);

    /**
     * Catchs the mouse press event inside the user interface object
     * \see QMouseEvent
     */
    void mousePressEvent(QMouseEvent *);

    /**
     * Catchs the mouse move event inside the user interface object
     * \see QMouseEvent
     */
    void mouseMoveEvent(QMouseEvent *);

    /**
     * Catchs the mouse release event inside the user interface object
     * \see QMouseEvent
     */
    void mouseReleaseEvent(QMouseEvent *);
    
private:

    QPointF lastDragPos, imageOffset;
    bool showRectZoom, zoomWindow, handTool;
    bool gridEnabled;
    bool existAgent;
    QGraphicsRectItem *zoomRectItem;

    QCursor zoomWindowCursor;
    QCursor zoomInCursor, zoomOutCursor;
};

}

#endif // CANVAS_H
