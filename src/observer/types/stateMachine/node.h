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

#ifndef NODE_H
#define NODE_H

#include <QGraphicsEllipseItem>
#include <QList>

class QPainter;
class QStyleOptionGraphicsItem;
class QWidget;

namespace TerraMEObserver
{

class Edge;

/**
 * \brief State machine node
 * \see QGraphicsEllipseItem
 * \author Antonio Jose da Cunha Rodrigues
 * \file node.h
*/
class Node : public QGraphicsEllipseItem
{
public:
    /**
     * Constructor
     * \param name the name of this node
     * \param parent a pointer to a parent QGraphicsItem
     * \param scene a pointer to a scene QGraphicsScene
     * \see QString, \see QGraphicsItem, \see QGraphicsScene
     */
    Node(QString name, QGraphicsItem *parent = 0, QGraphicsScene *scene = 0);

    /**
     * Destructor
     */
    virtual ~Node();

    /**
     * Gets the bounding rectangle of it
     * \see QRectF
     */
    QRectF boundingRect() const;

    /**
     * Gets the shape of it
     * \see QPainterPath
     */
    QPainterPath shape() const;

    /**
     * Paints in new way this object using a QPainter \a painter
     * \param painter a pointer to a QPainter object
     * \param option a pointer to a style option graphic
     * \param widget a pointer to a QWidget where it will be painted
     * \see QPainter, \see QStyleOptionGraphicsItem, \see QWidget
     * \sa QGraphicsLineItem, QGraphicsLineItem::paint
     */
    void paint(QPainter *painter,
    		const QStyleOptionGraphicsItem *option = 0, QWidget *widget = 0);

    /**
     * Sets the node color
     * \param color a color of the node
     * \see QColor
     */
    void setColor(QColor color);

    /**
     * Gets the reference of node color
     * \see QColor
     */
    const QColor & getColor();

    /**
     * Sets it as active. The node is highlighted
     * \param active boolean, if \a true the node is highlighted. Otherwise, it is not highlighted.
     */
    void setActive(bool active);

    /**
     * Gets the reference to the node name
     * \see QString
     */
    const QString & getName();

    /**
     * Adds an edge for a node
     * \param edge a pointer to an Edge
     * \see Edge
     */
    void addEdge(Edge *edge);

    /**
     * Gets a list of edge pointers
     * \see Edge
     * \see QList
     */
    QList<Edge *> getEdges() const;

signals:

public slots:

protected:
    QVariant itemChange(GraphicsItemChange change, const QVariant &value);

private:

    QList<Edge *> edgeList;
    QString name;
    QColor currentColor;
    int currentPenWidth;
    bool currentColorDefined;
};

}

#endif // NODE_H
