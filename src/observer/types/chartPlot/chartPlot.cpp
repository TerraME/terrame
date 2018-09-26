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

#include "chartPlot.h"

#include <QContextMenuEvent>
#include <QMenu>
#include <QAction>
#include <QVector>

#include "internalCurve.h"

#include <qwt_legend.h>
#include <qwt_symbol.h>
#include <qwt_plot_layout.h>
#include <qwt_plot_grid.h>
#include <qwt_plot_picker.h>

#include <iostream>

#include "visualArrangement.h"

using namespace std;

using namespace TerraMEObserver;

/*
struct CurveBkp
{
    QPen pen;
    QwtSymbol symbol;
    QwtPlotCurve::CurveStyle style;
};
*/

ChartPlot::ChartPlot(QWidget *parent) : QwtPlot(parent)
{
    picker = 0;
    exportAct = new QAction("Export...", this);
    propertiesAct = new QAction("Properties...", this);

    //canvas()->setFrameShape(QFrame::NoFrame);
    //canvas()->setFrameShadow(QFrame::Plain);
    //canvas()->setLineWidth(0);

	// QwtPlotLayout *layout = plotter->plotLayout();
	// layout->setCanvasMargin(0);
	// layout->setAlignCanvasToScales(true);
    createPicker();

//    connect(exportAct, SIGNAL(triggered()), this, SLOT(exportChart()));

    id = 0;

    canvas()->setStyleSheet("border: 0px");
}

ChartPlot::~ChartPlot()
{
    delete exportAct; exportAct = 0;
    delete propertiesAct; propertiesAct = 0;

    //if (picker)
    //    delete picker;
    //picker = 0;
}

// issue #642
/*
void ChartPlot::contextMenuEvent(QContextMenuEvent *ev)
{
    QMenu context(this);
    // context.addAction(exportAct);
    context.addSeparator();
    context.addAction(propertiesAct);
    context.exec(ev->globalPos());
}
*/

// issue #642
/*
void ChartPlot::mouseDoubleClickEvent(QMouseEvent *ev)
{
}
*/

void ChartPlot::exportChart(std::string file, string extension)
{
	QPixmap pixmap = grab();
	pixmap.save(QString::fromLocal8Bit(file.c_str()), extension.c_str());
}

void ChartPlot::setInternalCurves(const QList<InternalCurve *> &interCurves)
{
    internalCurves = interCurves;
}

void ChartPlot::createPicker()
{
    // cria o objeto respons?vel por exibir as coordenadas do ponteiro do mouse na tela
    picker = new QwtPlotPicker(QwtPlot::xBottom, QwtPlot::yLeft,
        QwtPlotPicker::CrossRubberBand, QwtPicker::ActiveOnly, //AlwaysOn,
        canvas());

    picker->setRubberBandPen(QColor(Qt::darkMagenta));
    picker->setRubberBand(QwtPicker::CrossRubberBand);
    picker->setTrackerPen(QColor(Qt::black));
}

void ChartPlot::setId(int id)
{
    this->id = id;
}

const int ChartPlot::getId() const
{
    return id;
}

void ChartPlot::resizeEvent(QResizeEvent *event)
{
	if (this->isVisible())
	{
		VisualArrangement::getInstance()->resizeEventDelegate(id, event);
		QwtPlot::resizeEvent(event);
	}
	else
		event->ignore();
}

void ChartPlot::moveEvent(QMoveEvent *event)
{
	if (this->isVisible())
		VisualArrangement::getInstance()->moveEventDelegate(id, event);
	else
		event->ignore();
}

void ChartPlot::closeEvent(QCloseEvent *event)
{
#ifdef __linux__
	VisualArrangement::getInstance()->closeEventDelegate(this);
#else
    VisualArrangement::getInstance()->closeEventDelegate();
#endif
}
