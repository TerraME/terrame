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

#include "canvas.h"

#include <QGraphicsView>
#include <QMouseEvent>
#include <QGraphicsRectItem>
#include <QDebug>

#include "observer.h"

using namespace TerraMEObserver;

Canvas::Canvas(QGraphicsScene * scene, QWidget *parent) : QGraphicsView(scene, parent)
{
    // zoom
    handTool = false;
    zoomWindow = false;
    gridEnabled = false;

    zoomWindowCursor = QCursor(QPixmap(":icons/zoomWindow.png").scaled(ICON_SIZE));
    zoomInCursor = QCursor(QPixmap(":icons/zoomIn.png").scaled(ICON_SIZE));
    zoomOutCursor = QCursor(QPixmap(":icons/zoomOut.png").scaled(ICON_SIZE));

    imageOffset = QPointF();
    showRectZoom = false;
}

Canvas::~Canvas()
{
}

void Canvas::setWindowCursor()
{
    zoomWindow = true;
    handTool = false;
    setCursor(zoomWindowCursor);
}

void Canvas::setPanCursor()
{
    handTool = true;
    zoomWindow = false;
    setCursor(Qt::OpenHandCursor);
}

void Canvas::paintEvent(QPaintEvent * ev)
{
    if (showRectZoom)
    {
        //---- Desenha o retangulo de zoom
        QPen pen(Qt::DashDotLine);
        QBrush brush(Qt::Dense5Pattern);
        brush.setColor(Qt::white);

        //QPainter painter;
        //painter.setPen(Qt::black);
        //painter.setBrush(brush);
        // painter.drawRect(QRect(imageOffset, lastDragPos));

        zoomRectItem = scene()->addRect(QRectF(mapToScene(imageOffset.x(), imageOffset.y()),
            mapToScene(lastDragPos.x(), lastDragPos.y())), pen, brush);
    }
    QGraphicsView::paintEvent(ev);
}


void Canvas::mousePressEvent(QMouseEvent *ev)
{
    if (ev->button() == Qt::LeftButton)
    {
        imageOffset = mapToScene(ev->pos());

        if (zoomWindow)
        {
            showRectZoom = true;
            setCursor(zoomInCursor);
        }
        else if (handTool)
        {
            lastDragPos = ev->pos();
            setCursor(Qt::ClosedHandCursor);
        }
    }
    else if (ev->button() == Qt::RightButton)
    {
        if (zoomWindow)
            setCursor(zoomOutCursor);
    }
    // QGraphicsView::mousePressEvent(ev);
}

void Canvas::mouseMoveEvent(QMouseEvent *ev)
{
    if (ev->buttons() & Qt::LeftButton)
    {
        if (zoomWindow)
        {
            // Define as coordenadas do retangulo de zoom
            if (!sceneRect().contains(QRectF(imageOffset, ev->pos())))
            {
                bool right = ev->pos().x() > rect().right();
                bool left = ev->pos().x() < rect().left();

                bool top = ev->pos().y() < rect().top();
                bool bottom = ev->pos().y() > rect().bottom();

                // x
                if (right)
                {
                    lastDragPos.setX(rect().right() - 1);
                    lastDragPos.setY(ev->pos().y());
                }
                else if (left)
                {
                    lastDragPos.setX(rect().left());
                    lastDragPos.setY(ev->pos().y());
                }

                // y
                if (top)
                {
                    lastDragPos.setY(0);
                    lastDragPos.setX(ev->pos().x());
                }
                else if (bottom)
                {
                    lastDragPos.setY(rect().height() - 2);
                    lastDragPos.setX(ev->pos().x());
                }
            }
            else
            {
                lastDragPos = ev->pos();
            }
            update();
        }
        else if (handTool)
        {
            setCursor(Qt::ClosedHandCursor);
            QPointF delta = mapToScene(lastDragPos.toPoint()) - mapToScene(ev->pos());
            centerOn(mapToScene(viewport()->rect().center()) + delta);

            // Causa bug ao arrastar
            // lastDragPos = ev->pos();
        }
    }
    // QGraphicsView::mousePressEvent(ev);
}

void Canvas::mouseReleaseEvent(QMouseEvent *ev)
{
    if (ev->button() == Qt::LeftButton)
    {
        if (zoomWindow)
        {
            showRectZoom = false;

            setCursor(zoomWindowCursor);
            update();

            QRectF zoomRect(imageOffset, lastDragPos);
            zoomRect = zoomRect.normalized();

            double factWidth = viewport()->width(); // resultImage.size().width();
            double factHeight = viewport()->height(); // resultImage.size().height();

            factWidth /= zoomRect.width();
            factHeight /= zoomRect.height();

            // Define o maior zoom como sendo 3200%
            factWidth = factWidth > 32.0 ? 32.0 : factWidth;
            factHeight = factHeight > 32.0 ? 32.0 : factHeight;

            // emite o sinal informando o tamanho do retangulo de zoom e
            // os fatores width e height
            emit zoomChanged(zoomRect, factWidth, factHeight);

            // scene()->removeItem(zoomRectItem);
            // delete zoomRectItem;
        }
        else
        {
            if (handTool)
            {
                setCursor(Qt::OpenHandCursor);
                lastDragPos = QPointF();
            }
        }
    }
    else
    {
        if (ev->button() == Qt::RightButton)
        {
            if (zoomWindow)
            {
                emit zoomOut();
                setCursor(zoomWindowCursor);
            }
        }
    }
    // QGraphicsView::mouseReleaseEvent(ev);
}


