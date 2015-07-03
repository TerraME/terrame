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

#ifndef INTERNAL_CURVE_H
#define INTERNAL_CURVE_H

#include <QVector>

#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_symbol.h>


namespace TerraMEObserver {

class InternalCurve
{
public:
    InternalCurve(const QString &name, QwtPlot *plotter)
    {
        values = new QVector<double>();
       //  symbol = new QwtSymbol();

        plotCurve = new QwtPlotCurve(name);
		//plotCurve->setSymbol(new QwtSymbol);
        plotCurve->setPaintAttribute(QwtPlotCurve::FilterPoints, true);
        plotCurve->setRenderHint(QwtPlotItem::RenderAntialiased);
        // plotCurve->setSymbol(*symbol);
        plotCurve->attach(plotter);
    }

    virtual ~InternalCurve()
    {
        delete values;
        delete plotCurve;
        // delete symbol;
    }

    QVector<double> *values;
    QwtPlotCurve* plotCurve;
    // QwtSymbol* symbol;
};

}
#endif // INTERNAL_CURVE_H
