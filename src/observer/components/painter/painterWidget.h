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

#ifndef PAINTER_WIDGET_H
#define PAINTER_WIDGET_H

#include <QtGui/QScrollArea>
#include <QtGui/QLabel>
#include <QtGui/QImage>
#include <QtGui/QPainter>
#include <QtCore/QHash>
#include <QtCore/QString>
#include <QtGui/QPaintEvent>
#include <iostream>

#include "visualMapping.h"

namespace TerraMEObserver {


/**
 * \brief Shows the cellular space state
 * \see QWidget
 * \author Antonio José da Cunha Rodrigues 
 * \file painterWidget.h
 */
class PainterWidget : public QWidget
{
    Q_OBJECT
public:
    /**
     * Constructor
     * \param mapAttributes a pointer to a hash of attributes
     * \param parent a pointer to a widget parent
     * \see Attributes
     * \see QWidget, \see QHash, \see QString
     */
    PainterWidget(QHash<QString, Attributes*> *mapAttributes,
        TypesOfObservers observerType = TerraMEObserver::TObsMap, QWidget *parent = 0);
    
    /**
     * Destructor
     */
    virtual ~PainterWidget();

    /**
     * Sets the mode of operation used by a QPainter to compose a image
     * \param mode composition mode of QPainter
     * \see QPainter, \see QPainter::Compoistion
     */
    void setOperatorMode(QPainter::CompositionMode mode);

    /* * 
     * Plots a attribute
     * \param attrib a pointer to a attribute
     * \see Attributes
     */
    void plotMap(Attributes *attrib);

    /* *
     * Re-paints all attributes under observation
     */
    void replotMap();

    /**
     *
     */
    bool draw();

    /**
     * Rescale according the zoom
     * \param size new size of the object
     * \see QSize
     */
    bool rescale(const QSize & size); 

    /** 
     * Rescale the image according the CellularSpace dimension
     * \param size new sise of the image/space
     * \param cellSize calculate size of cells
     * \see QSize
     */
    void resize(const QSize &spaceSize, const QSize &cellSize);

    // / Gets the original size of 
    // QSize getOriginalSize();

    /** 
     * Sets a pointer to a QScrollArea object
     * \param scrollArea a pointer to a QScrollArea
     */
    void setParentScroll(QScrollArea *scrollArea);

    /**
     * Activates the zoom window
     */
    void setZoomWindow();

    /**
     * Activates the zoom pan
     */
    void setHandTool();

    /** 
     * Defines the mouse cursor
     * \param cursor a reference to a QCursor
     * \see QCursor
     */
    void defineCursor(QCursor &cursor);
    
    /**
     * Sets the existence of an agent
     * \param exist true exist an agent. Otherwise, false.
     */
    void setExistAgent(bool exist);

    /**
     * Stops the thread and closes this object
     */
    int close();

    void updateAttributeList();

    void setCellSize(const QSize &size);

    /**
     * Sets path for save images when it observes by TObsImage
     *
     */
    void setPath(const QString & pth);

signals:
    /**
     * Emits a new zoom rectangle, a proportion factor for width and height
     * \param rect a new zoom rectangle
     * \param width a proportion factor for the width
     * \param height a proportion factor for the height
     * \see ObserverMap::zoomChanged
     * \see QRect
     */
    void zoomChanged(QRect rect, double width, double height);

    /**
     * Emits a signal that zoom out was activated
     * \see ObserverMap::zoomOut
     */
    void zoomOut();

    /**
     * Activates and triggers the grid draw
     * \param on if \a true the grid will be draw. Otherwise, will not draw.
     */
    void enableGrid(bool state);

public slots:
    void displayImage(const QImage &result);

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
        
    /**
     * Catchs the resize event inside the user interface object
     * \see QResizeEvent
     */
    void resizeEvent(QResizeEvent *);
    
    //void wheelEvent(QWheelEvent *);

private:
    /**
     * Draws the grid
     */
    void drawGrid();

    /**
     * Draws the Subject Agent
     */
    void drawAgent();


    double pixmapScale, curScale, scaleFactor;
    double heightProportion, widthProportion;
    QSize cellSize;
    
    QPainter::CompositionMode operatorMode;

    // atributos em observação
    QImage resultImage;
    QImage resultImageBkp;

    // objetos do ObserverMap
    QHash<QString, Attributes*> *mapAttributes;
    QScrollArea *mParentScroll;

    VisualMapping *visualMapping;

    QPoint lastDragPos, imageOffset;
    bool showRectZoom, zoomWindow, handTool;
    bool gridEnabled, existAgent;
    bool mapValuesPassed;

    QCursor zoomWindowCursor;
    QCursor zoomInCursor, zoomOutCursor;
};

}

#endif
