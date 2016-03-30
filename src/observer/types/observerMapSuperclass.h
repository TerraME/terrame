/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

#ifndef OBSERVERSUPERCLASS_H
#define OBSERVERSUPERCLASS_H

#include <QDialog>
#include <QHash>
#include <QRectF>

#include "../observerInterf.h"
#include "components/legend/legendWindow.h"

class QGraphicsView;
class QGraphicsScene;
class QWheelEvent;
class QLabel;
class QToolButton;
class QComboBox;
class QFrame;
class QTreeWidget;
class QTreeWidgetItem;
class QResizeEvent;

namespace TerraMEObserver
{

class Decoder;
class Canvas;

/**
 * \brief Super Class from draw oberser in QGraphicsScene
 * \see ObserverInterf
 * \see QDialog
 * \author Washington Sena de Franca e Silva
 * \file observerSuperclass.h
*/
class ObserverMapSuperclass : public QDialog, public ObserverInterf
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
    ObserverMapSuperclass(Subject *subj, const TypesOfObservers &obsType,
                       const QString &windowTitle, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverMapSuperclass();

    /**
     * \copydoc Observer::draw
     */
    virtual bool draw(QDataStream &state) = 0;

    /**
     * Sets the attributes for observation in the observer
     * \param attribs a list of attributes under observation
     * \param legKeys a list of legend keys
     * \param legAttribs a list of legend attributes
     * \see QStringList
     */

    virtual void setAttributes(QStringList &attribs, QStringList legKeys,
                           QStringList legAttribs);

    /**
     * \copydoc Observer::getAttributes
     */
    virtual QStringList getAttributes();

    /**
     * \copydoc Observer::getAttributes
     */
    const TypesOfObservers getType();

    /**
     * Adds the states and their transition in the observer
     * \param allStates a list of states and their transition
     * \see QList, \see QPair, \see QString
     */
    void addState(QList<QPair<QString, QString> > &allStates);

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
    void zoomChanged(const QRectF &zoomRect, float width, float height);

    /**
    * Treats the zoom out signal
    */
    void zoomOut();

    virtual void treeLayers_itemChanged(QTreeWidgetItem * item, int column);

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
    virtual void scaleView(qreal newScale);

    /**
     * Catchs the resize event
     * \see QResizeEvent
     */
    void resizeEvent(QResizeEvent *);

protected:
    /**
     * Sets up the user interface
     */
    void setupGUI();

    /**
     * Shows the attributes layer
     */
    virtual void showLayerLegend() = 0;

    int convertZoomIndex(bool in);
    void connectTreeLayerSlot(bool on);

    void zoomWindow();

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    int buildLegend;

    Canvas *view;
    QGraphicsScene *scene;
    QTreeWidget *treeLayers;

    LegendWindow *legendWindow;
    Decoder *protocolDecoder;

    QVector<int> zoomVec;
    int positionZoomVec;
    float offsetState;
    QPointF center;

    QComboBox *zoomComboBox;

    QStringList attribList;
    QStringList obsAttrib;          // lista de chaves em observacao
    QHash<QString, Attributes *> *mapAttributes;  // map de todas as chaves

    QToolButton *butLegend, *butGrid;
    QToolButton *butZoomIn, *butZoomOut;
    QToolButton *butZoomWindow, *butHand;
    QToolButton *butZoomRestore;

    QFrame *frameTools;
};

}

#endif // OBSERVERSTATEMACHINE_H

