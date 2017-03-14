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

#include "observerGraphic.h"

#include <iostream>

using namespace std;

#include <QColorDialog>
#include <QApplication>
#include <QPalette>
#include <QFontDatabase>

#include <qwt_plot_legenditem.h>
#include <qwt_plot_item.h>

#include "chartPlot.h"
#include "internalCurve.h"
#include "terrameGlobals.h"

#include "visualArrangement.h"

extern ExecutionModes execModes;

using namespace TerraMEObserver;

// Hue component values contains 12 values and it is used
// to compose a HSV color
static const float hueValues[] = {
    // 0, 30/360, 60/360, 90/360, 120/360, 150/360, 180/360, 210/360, 240/360, 270/360, 300/360, 330/360
    0.000, 0.083, 0.167, 0.250, 0.333, 0.417, 0.500, 0.583, 0.667, 0.750, 0.833, 0.917
};
const int HUE_COUNT = 12;

ObserverGraphic::ObserverGraphic(Subject *sub, QWidget *parent)
    : ObserverInterf(sub), QThread()
{
    qsrand(1);

    observerType = TObsGraphic;
    subjectType = TObsUnknown;

    paused = false;
    legend = 0;
    xAxisValues = new QVector<double>();
    internalCurves = new QMap<QString, InternalCurve*>();

    plotter = new ChartPlot(parent);
    plotter->setId(getId());
    plotter->setAutoReplot(true);
    plotter->setFrameShape(QFrame::Box);
    plotter->setFrameShadow(QFrame::Plain);
    plotter->setLineWidth(0);

    QPalette palette = plotter->canvas()->palette();
    palette.setColor(QPalette::Background, Qt::white);
    plotter->canvas()->setPalette(palette);

    palette = plotter->palette();
    palette.setColor(QPalette::Background, Qt::white);
    plotter->setPalette(palette);
    plotter->setWindowTitle("Chart");

    VisualArrangement::getInstance()->starts(plotter->getId(), plotter);

    start(QThread::IdlePriority);
}

ObserverGraphic::~ObserverGraphic()
{
    wait();

    foreach(InternalCurve *curve, internalCurves->values())
        delete curve;
    delete internalCurves; internalCurves = 0;

    delete plotter; plotter = 0;
    delete xAxisValues; xAxisValues = 0;

    //if (legend)
    //    delete legend;
    //legend = 0;
}


void ObserverGraphic::setObserverType(TypesOfObservers type)
{
    observerType = type;
}

const TypesOfObservers ObserverGraphic::getType()
{
    return observerType;
}

void ObserverGraphic::save(std::string file, std::string extension)
{
	plotter->exportChart(file, extension);
}

bool ObserverGraphic::draw(QDataStream &state)
{
    QString msg, key;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);
    QVector<double> *ord = 0, *abs = xAxisValues;
    // double num = 0, x = 0, y = 0;

    //QString subjectId = tokens.at(0);
    subjectType =(TypesOfSubjects) tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int numElems = tokens.at(3).toInt();

    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        int idx = attribList.indexOf(key);
        // bool contains = itemList.contains(key);
        bool contains =(idx != -1);

        switch (typeOfData)
        {
            case(TObsBool):
                if (contains)
                    if (execModes != Quiet)
                        qWarning("Was expected a numeric parameter.");
                break;

            case(TObsDateTime)	:
                //break;

            case(TObsNumber):

                if (contains)
                {
                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append(tokens.at(j).toDouble());
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

                    // Gr?fico Din?mico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        internalCurves->value(key)->setSamples(*abs, *ord);
                    }
                    else
                    {
                        // Gr?fico: X vs Y
                        if (idx != attribList.size() - 1)
                            ord = internalCurves->value(key)->values; // y axis
                    }
                }
                break;

            // case TObsText:
            default:
                if (!contains)
                    break;

                if ((subjectType == TObsAutomaton) ||(subjectType == TObsAgent))
                {
                    if (!states.contains(tokens.at(j)))
                        states.push_back(tokens.at(j));

                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append(states.indexOf(tokens.at(j)));
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

                    // Gr?fico Din?mico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        abs = xAxisValues;
                        internalCurves->value(key)->setSamples(*abs, *ord);
                    }
                    else
                    {
                        // Gr?fico: X vs Y
                        if (idx != attribList.size() - 1)
                            ord = internalCurves->value(key)->values;
                        // else
                        //     abs = xAxisValues; // internalCurves->value(key)->values;
                    }
                }
                else
                {
                    if (execModes != Quiet)
                        qWarning("Warnig: Was expected a numeric parameter not a string '%s'.\n",
                                 qPrintable(tokens.at(j)));
                }
                break;
        }
        j++;
    }

    if (observerType == TObsGraphic)
    {
        InternalCurve *curve = 0;

        for (int i = 0; i < internalCurves->keys().size(); i++)
        {
            curve = internalCurves->value(internalCurves->keys().at(i));
            curve->setSamples(*abs, *internalCurves->value(internalCurves->keys().at(i))->values);
        }
    }
    plotter->repaint();

    qApp->processEvents();
    return true;
}

void ObserverGraphic::setTitles(const QString &title, const QString &xTitle, const QString &yTitle)
{
	QFontDatabase qfd;
	QFont font = qfd.font("Ubuntu", QString(), 12);
	QwtText qtitle(title);
	qtitle.setFont(font);
    plotter->setTitle(qtitle);

	plotter->setAxisFont(0, font);
	plotter->setAxisFont(1, font);
	plotter->setAxisFont(2, font);

	QwtText qxTitle(xTitle);
	qxTitle.setFont(font);
    plotter->setAxisTitle(QwtPlot::xBottom, qxTitle);

	QwtText qyTitle(yTitle);
	qyTitle.setFont(font);
    plotter->setAxisTitle(QwtPlot::yLeft, qyTitle);
}

void ObserverGraphic::setLegendPosition(QwtPlot::LegendPosition pos)
{
    if (!legend)
        legend = new QwtLegend;
   // legend->setItemMode(QwtLegend::ClickableItem);
    plotter->insertLegend(legend, pos);

    //connect(plotter, SIGNAL(legendClicked(QwtPlotItem *)), SLOT(colorChanged(QwtPlotItem *)));
}

//void ObserverGraphic::setGrid()
//{
//    // grid
//    QwtPlotGrid *plotGrid = new QwtPlotGrid;
//    plotGrid->enableXMin(true);
//    plotGrid->enableYMin(true);
//    plotGrid->attach(this);
//}

void ObserverGraphic::setAttributes(const QStringList &attribs, const QStringList &curveTitles,
        /*const*/ QStringList &legKeys, /*const*/ QStringList &legAttribs)
{
    attribList = attribs;
    InternalCurve *interCurve = 0;
    QColor color;

    int attrSize = attribList.size();

    // Ignores the attribute of the x axis
    if (observerType == TObsGraphic)
        attrSize--;

    for (int i = 0; i < attrSize; i++)
    {
        interCurve = new InternalCurve(attribList.at(i), plotter);

        if (interCurve)
        {
            if (i < curveTitles.size())
                interCurve->setTitle(curveTitles.at(i));
            else
                interCurve->setTitle(QString("$curve %1").arg(i + 1));

            internalCurves->insert(attribList.at(i), interCurve);

            // Sets a random color for the created curve
            color = QColor::fromHsvF(hueValues[(int)(qrand() % HUE_COUNT)], 1, 1);
            interCurve->setPen(color);
			interCurve->setLegendAttribute(QwtPlotCurve::LegendShowLine);

            int width = 0, style = 0, symbol = 0, colorBar = 0, num = 0, size = 0, penstyle = 0;

            width = legKeys.indexOf(WIDTH);
            style = legKeys.indexOf(STYLE);
            symbol = legKeys.indexOf(SYMBOL);
			size = legKeys.indexOf(SIZE_);
			penstyle = legKeys.indexOf(PENSTYLE);
            colorBar = legKeys.indexOf(COLOR_BAR);

            if ((!legAttribs.isEmpty()) && (colorBar > -1))
            {
                QString aux;
                QStringList colorStrList;
                QPen pen;

                aux = legAttribs.at(colorBar).mid(0, legAttribs.at(colorBar).indexOf(COLOR_BAR_SEP));
                colorStrList = aux.split(COLORS_SEP, QString::SkipEmptyParts)
                    .first().split(ITEM_SEP).first().split(COMP_COLOR_SEP);

                // Retrieves the last colorBar value
                // colorStrList = aux.split(COLORS_SEP, QString::SkipEmptyParts)
                //      .last().split(ITEM_SEP).first().split(COMP_COLOR_SEP);

                // color
                color.setRed(colorStrList.at(0).toInt());
                color.setGreen(colorStrList.at(1).toInt());
                color.setBlue(colorStrList.at(2).toInt());

                // width
                num = legAttribs.at(width).toInt();
                pen = QPen(color);
                pen.setWidth((num > 0) ? num : 1);
                interCurve->setPen(pen);

				// pen
                num = legAttribs.at(penstyle).toInt();
				pen.setStyle((Qt::PenStyle) num);
                interCurve->setPen(pen);

                // style
                num = legAttribs.at(style).toInt();
                interCurve->setStyle((QwtPlotCurve::CurveStyle) num);

                // symbol
                num = legAttribs.at(symbol).toInt();
                QwtSymbol* qwtSymbol = new QwtSymbol;
                qwtSymbol->setStyle((QwtSymbol::Style) num);
                qwtSymbol->setPen(pen);

				if ((QwtSymbol::Style) num !=(QwtSymbol::Style) -1)
				{
					interCurve->setLegendAttribute(QwtPlotCurve::LegendShowSymbol);
				}

				//size
                num = legAttribs.at(size).toInt();
                qwtSymbol->setSize(num);


                if (qwtSymbol->brush().style() != Qt::NoBrush)
                    qwtSymbol->setBrush(pen.color());

                interCurve->setSymbol(qwtSymbol);

                for (int j = 0; j < LEGEND_ITENS; j++)
                {
                    legKeys.removeFirst();
                    legAttribs.removeFirst();
                }
            }
        }
        else
        {
            if (execModes != Quiet)
                qWarning("%s", qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
        }
    }
    plotter->setInternalCurves(internalCurves->values());
}

void ObserverGraphic::colorChanged(QwtPlotItem * /* item */)
{
    //QWidget *w = plotter->legend()->find(item);
    //if (w && w->inherits("QwtLegendItem"))
    //{
    //    QColor color =((QwtLegendItem *)w)->curvePen().color();
    //    color = QColorDialog::getColor(color);

    //    if ((color.isValid()) && (color !=((QwtLegendItem *)w)->curvePen().color()))
    //    {
    //       ((QwtLegendItem *)w)->setCurvePen(QPen(color));
    //
    //        // in this context, pointer item is QwtPlotItem son
    //       ((QwtPlotCurve *)item)->setPen(QPen(color));
    //    }
    //}
    //plotter->replot();
}

void ObserverGraphic::run()
{
    //while (!paused)
    //{
    //    QThread::exec();

    //    //std::cout << "teste thread\n";
    //    //std::cout.flush();
    //}
    QThread::exec();
}

void ObserverGraphic::pause()
{
    paused = !paused;
}

QStringList ObserverGraphic::getAttributes()
{
    return attribList;
}

void ObserverGraphic::setModelTime(double time)
{
    if (observerType == TObsDynamicGraphic)
        xAxisValues->push_back(time);
}

void ObserverGraphic::setCurveStyle()
{
    foreach(InternalCurve *curve, internalCurves->values())
        curve->setStyle(QwtPlotCurve::Steps);
}

int ObserverGraphic::close()
{
    plotter->close();
    QThread::exit(0);
    return 0;
}

void ObserverGraphic::clear()
{
	xAxisValues->clear();

	for (int i = 0; i < internalCurves->keys().size(); i++)
	{
		QString k(internalCurves->keys().at(i));
		internalCurves->value(k)->values->clear();
		internalCurves->value(k)->setSamples(*xAxisValues, *internalCurves->value(k)->values);
	}
}

void ObserverGraphic::restart()
{
	for (int i = 0; i < internalCurves->keys().size(); i++)
	{
		QString k(internalCurves->keys().at(i));
		internalCurves->value(k)->insertGap();
	}
}
