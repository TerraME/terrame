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

#ifndef OBSERVERSTATEMACHINE_H
#define OBSERVERSTATEMACHINE_H

#include <QDialog>
#include <QHash>
#include <QRectF>

#include "observerInterf.h"
#include "legendWindow.h"

class QGraphicsView;
class QGraphicsScene;
class QWheelEvent;
class QLabel;
class QToolButton;
class QComboBox;
class QFrame;
class QTreeWidget;
class QResizeEvent;

namespace TerraMEObserver
{

class Decoder;
class Node;
class Canvas;

/**
 * \brief Plots the state machine nodes and edges
 * \see ObserverInterf
 * \see QDialog
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerStateMachine.h
*/
class ObserverStateMachine : public QDialog, public ObserverInterf
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \param parent a pointer to a QWidget
     * \see Subject
     * \see QWidget
     */
    ObserverStateMachine(Subject *subj, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverStateMachine();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &);

    /**
     * Sets the attributes for observation in the observer
     * \param attribs a list of attributes under observation
     * \param legKeys a list of legend keys
     * \param legAttribs a list of legend attributes
     * \see QStringList
     */
    void setAttributes(QStringList &attribs, QStringList legKeys,
                       QStringList legAttribs);

    /**
     * \copydoc Observer::getAttributes
     */
    QStringList getAttributes();

    /**
     * \copydoc Observer::getAttributes
     */
    const TypesOfObservers getType() const;

    /**
     * Adds the states and their transition in the observer
     * \param allStates a list of states and their transition
     * \see QList, \see QPair, \see QString
     */
    void addState(QList<QPair<QString, QString> > &allStates);

    int close() { return 0; }

public slots:
    /**
     * Treats the legend button click
     */
    void butLegend_Clicked();

    /**
     * Treats the zoom in button click
     */
    void butZoomIn_Clicked();

    /**
     * Treats the zoom out button click
     */
    void butZoomOut_Clicked();

    /**
     * Treats the zoom window button click
     */
    void butZoomWindow_Clicked();

    /**
     * Treats the zoom restore button click
     */
    void butZoomRestore_Clicked();

    /**
     * Treats the zoom pan button click
     */
    void butHand_Clicked();

    /**
     * Treats the selected scale of zoom in the zoom comboBox
     * \param scale the selecte zoom scale
     * \see QString
     */
    void zoomActivated(const QString &scale);

    /**
     * Treats the zoom change signal. Receives new zoom rectangle, proportional
     * factor for width and height
     * \param zoomRect a new zoom rectangle
     * \param width a proportion factor for the width
     * \param height a proportion factor for the height
     * \see QRect
     */
    void zoomChanged(const QRectF &zoomRect, double width, double height);

    /**
     * Treats the zoom out signal
     */
    void zoomOut();

protected:
    /**
     * Catchs the wheel event
     * \see QWheelEvent
     */
    void wheelEvent(QWheelEvent *event);

    /**
     * Sets the new scale to the \a view object
     * \param newScale the new scale to the view
     */
    void scaleView(qreal newScale);

    /**
     * Catchs the resize event
     * \see QResizeEvent
     */
    void resizeEvent(QResizeEvent *);

private:
    /**
     * Sets up the user interface
     */
    void setupGUI();

    /**
     * Shows the attributes layer
     */
    void showLayerLegend();
    // void connectTreeLayer(bool);

    /**
     * Converts a index from zoom comboBox to a integer
     * \param in boolean, if \a true
     * \return integer value of index
     */
    int convertZoomIndex(bool in);

    void zoomWindow();

    bool draw();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    int buildLegend;

    Canvas *view;
    QGraphicsScene *scene;
    QTreeWidget *treeLayers;

    LegendWindow *legendWindow;
    Decoder *protocolDecoder;

    QHash<QString, Node *> *states;
    QStringList attribList;
    QStringList obsAttrib;          // key list under observation
    QHash<QString, Attributes *> *mapAttributes;  // map of all keys
    
    QVector<int> zoomVec;
    int positionZoomVec;
    double offsetState;
    QPointF center;

    QComboBox *zoomComboBox;
 
    QToolButton *butLegend, *butGrid;
    QToolButton *butZoomIn, *butZoomOut;
    QToolButton *butZoomWindow, *butHand;
    QToolButton *butZoomRestore;

    // QLabel *lblOperator;
    QFrame *frameTools;
};

}

#endif // OBSERVERSTATEMACHINE_H
