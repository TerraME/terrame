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

#ifndef OBESERVERMAP_RENDERTHREAD_H
#define OBESERVERMAP_RENDERTHREAD_H

#include <QtCore/QMutex>
#include <QtCore/QSize>
#include <QtCore/QWaitCondition>
#include <QtGui/QImage>
#include <QtCore/QThread>
#include <QtGui/QPainter>

#include "../../observer.h"

extern "C"
{
#include <lua.h>
}
#include "luna.h"

namespace TerraMEObserver {

class Attributes;

/**
 * \brief Auxiliary class to draws the cellular space state
 * \see QThread
 * \author Antonio Jos? da Cunha Rodrigues
 * \file painterThread.h
 */
class PainterThread : public QThread
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QObject
     * \see QObject
     */
    PainterThread(QObject *parent = 0);

    /**
     * Destructor
     */
    virtual ~PainterThread();

    /**
     * Draws an Attributes \a attrib using a QPainter \a p
     * \param p a pointer to a QPainter
     * \param attrib a pointer to an attribute
     * \see Attributes, \see QPainter
     */
    void drawAttrib(QPainter *p, Attributes *attrib);
    // void setVectorPos(QVector<double> *xs, QVector<double> *ys);

    /**
     * Draws a grid in the image with a width \a width and a height \a height
     * \param image reference to an QImage
     * \param width reference to a width
     * \param height referenece to a height
     * \see QImage
     */
    void drawGrid(QImage &image, double &width, double &height);

signals:
    //void teste();
    //void renderedImage(const QImage &image, double scaleFactor);

public slots:
    // void gridOn(bool);

protected:
    /**
     * Runs the thread
     * \see QThread
     */
    void run();

private:
    /**
     * Draws a subject type \a subjType using a painter \a p in
     * the coordenate (\a x, \a y)
     * \param p a pointer to a QPainter
     * \param subjType type of subject
     * \param x axis position
     * \param y axis position
     */
    void draw(QPainter *p, TypesOfSubjects subjType , double &x, double &y);

	//@RAIAN: Desenha a vizinhanca
		/// Draws a Neighborhood object
		/// \author Raian Vargas Maretto
	void drawNeighborhood(QPainter *, double &, double &, double &, double &);
	//@RAIAN: FIM


    QMutex mutex;
    QWaitCondition condition;
    bool restart, abort, reconfigMaxMin;

    QPainter *p;
    // QPen defaultPen;
};

}

#endif
