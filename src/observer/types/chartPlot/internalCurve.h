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

#ifndef INTERNAL_CURVE_H
#define INTERNAL_CURVE_H

#include <QVector>

#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_symbol.h>


namespace TerraMEObserver {

class InternalCurve : public QwtPlotCurve
{
private:
	QVector < QPair<int, int>> gaps;

public:
    InternalCurve(const QString &name, QwtPlot *plotter)
    {
        values = new QVector<double>();
       //  symbol = new QwtSymbol();
		//setSymbol(new QwtSymbol);
        setPaintAttribute(QwtPlotCurve::FilterPoints, true);
        setRenderHint(QwtPlotItem::RenderAntialiased);
        //setSymbol(*symbol);
        attach(plotter);
    }

    virtual ~InternalCurve()
    {
        delete values;
        // delete symbol;
    }

	void insertGap()
	{
		int from, to;

		if (gaps.isEmpty())
		{
			from = 0;
			to = values->size() - 1;
			gaps.push_back(QPair<int, int>(from, to));
		}
		else
		{
			from = gaps.last().second + 1;
			to = values->size() - 1;
			gaps.push_back(QPair<int, int>(from, to));
		}
	}

    QVector<double> *values;
    // QwtSymbol* symbol;

protected:
	virtual void drawCurve(QPainter *p, int style,
		const QwtScaleMap &xMap, const QwtScaleMap &yMap,
		const QRectF &canvasRect, int from, int to) const
	{
		if (gaps.isEmpty())
		{
			QwtPlotCurve::drawCurve(p, style, xMap, yMap, canvasRect, from, to);
		}
		else
		{
			int f, t;

			for (int i = 0; i < gaps.size(); i++)
			{
				f = gaps.at(i).first;
				t = gaps.at(i).second;
				QwtPlotCurve::drawCurve(p, style, xMap, yMap, canvasRect, f, t);
			}

			if (to > t)
			{
				t++;
				QwtPlotCurve::drawCurve(p, style, xMap, yMap, canvasRect, t, to);
			}
		}
	}
};
} // namespace TerraMEObserver

#endif // INTERNAL_CURVE_H

