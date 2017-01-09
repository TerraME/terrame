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

#include "node.h"

#include <QPainter>
#include <QStyleOptionGraphicsItem>
#include <QWidget>

#include "edge.h"

using namespace TerraMEObserver;

static const int DIMENSION = 70;
static const int ACTIVE_PEN_WIDTH = 3.0;
static const int INACTIVE_PEN_WIDTH = 0.0;

static const QColor INACTIVE_COLOR = Qt::gray;
static const QColor ACTIVE_COLOR = Qt::green;

Node::Node(QString n, QGraphicsItem *parent, QGraphicsScene *scene)
    : QGraphicsEllipseItem(parent/*, scene*/)
{
    // setZValue(-1);
    // setFlag(QGraphicsItem::ItemIsMovable);

    name = n;
    currentPenWidth = INACTIVE_PEN_WIDTH;
    currentColor = INACTIVE_COLOR;
    currentColorDefined = false;
}

Node::~Node() {}

QRectF Node::boundingRect() const
{
    qreal adjust = 2.0;
    return QRectF(-(DIMENSION * 0.5) - adjust, -(DIMENSION * 0.5) - adjust,
                  DIMENSION + adjust, DIMENSION + adjust);
}

QPainterPath Node::shape() const
{
    QPainterPath path;
    path.addEllipse(boundingRect());
    return path;
}

void Node::setActive(bool active)
{
    if (active)
    {
        if (!currentColorDefined)
            currentColor = ACTIVE_COLOR;
        currentPenWidth = ACTIVE_PEN_WIDTH;
    }
    else
    {
        if (!currentColorDefined)
            currentColor = INACTIVE_COLOR;
        currentPenWidth = INACTIVE_PEN_WIDTH;
    }
}

const QString & Node::getName()
{
    return name;
}

void Node::setColor(QColor c)
{
    currentColor = c;
    currentColorDefined = true;
}

const QColor & Node::getColor()
{
    return currentColor;
}

void Node::paint(QPainter *painter, const QStyleOptionGraphicsItem *option, QWidget *widget)
{
    Q_UNUSED(option);
    Q_UNUSED(widget);

    painter->setBrush(currentColor);
    painter->setPen(QPen(Qt::black, currentPenWidth));
    // painter->drawRect(boundingRect());
    painter->drawEllipse(boundingRect());

    QFont font = painter->font();
    font.setBold((currentPenWidth == ACTIVE_PEN_WIDTH));
    font.setPointSize(11);
    painter->setFont(font);

    painter->setBrush(Qt::black);
    painter->setPen(QPen(Qt::black, currentPenWidth));
    painter->drawText(boundingRect(), Qt::AlignCenter, name);
}

QVariant Node::itemChange(GraphicsItemChange change,
                          const QVariant &value)
{
    if (change == QGraphicsItem::ItemPositionChange)
    {
        foreach(Edge *i, edgeList)
            i->updatePosition();
    }
    return value;
}

void Node::addEdge(Edge *edge)
{
    edgeList.push_back(edge);
    edge->updatePosition();
}

QList<Edge *> Node::getEdges() const
{
    return edgeList;
}
