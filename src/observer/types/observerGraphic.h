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

#ifndef OBSERVER_GRAPHIC
#define OBSERVER_GRAPHIC

#include "../observerInterf.h"

#include <QDialog>
#include <QThread>

#include <qwt_plot.h>
#include <qwt_plot_curve.h>
#include <qwt_legend.h>

//#include <qwt_plot_marker.h>
//#include <qwt_data.h>
//#include <qwt_text.h>
//#include <math.h>

namespace TerraMEObserver {

class InternalCurve;
class ChartPlot;

/**
 * \brief Plots a simple scatter plot graphic or a scatter plot over the time
 * \see ObserverInterf
 * \see QThread
 * \author Antonio Jos? da Cunha Rodrigues
 * \file observerGraphic.h
*/
class ObserverGraphic : public QThread, public ObserverInterf
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
    ObserverGraphic(Subject *subj, QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverGraphic();

    /**
     * Draws the internal state of a Subject
     * \param state a reference to a QDataStream object
     * \return a boolean, \a true if the internal state was rendered.
     * Otherwise, returns \a false
     * \see  QDataStream
     */
    bool draw(QDataStream &state);

    /**
     * Sets the chart title and the name of x and y axes
     * \param title the chart title 
     * \param xTitle the title to the x axis
     * \param yTitle the title to the y axis
     * \see QString
     */
    void setTitles(const QString &title, const QString &xTitle, const QString &yTitle);

    /**
     * Sets the attributes for observation in the graphic observer
     * \param attribs a list of attributes
     */
    void setAttributes(const QStringList &attribs, const QStringList &curveTitles,
        /*const*/ QStringList &legKeys, /*const*/ QStringList &legAttribs);

    /**
     * Gets the list of attributes
     */
    QStringList getAttributes();

	void save(std::string file, std::string extension);
    /**
     * Sets the position of the legend
     * \param pos enumerator legend position
     * \see QwtPlot, QwtPlot::LegendPosition
     */
    void setLegendPosition(QwtPlot::LegendPosition pos = QwtPlot::BottomLegend);

    /**
     * Sets the type of graphic: simply chart or a dinamic chart
     * \param type the type of observer
     * \see TypesOfObservers
     */
    void setObserverType(TypesOfObservers type);

    /**
     * Gets the type of observer
     * \see TypesOfObservers
     */
    const TypesOfObservers getType();

    /**
     * Auxiliary method to set the simulation time for the dinamic chart
     * \param time the time of simulation
     */
    void setModelTime(double time);

    /**
     * Sets the curve style
     * The default style is QwtPlotCurve::Lines
     * \see QwtPlotCurve, \see QwtPlotCurve::CurveStyle
     */
    void setCurveStyle();

    /**
     * Pauses the thread execution
     */
    void pause();

    /**
     * Closes the window and stops the thread execution
     */
    int close();

private slots:
    /**
     * Treats the click in the legend and changes the curve color
     * \param item a pointer to a plot item
     * \see QwtPlotItem
     */
    void colorChanged(QwtPlotItem* item);

protected:
    /**
     * Runs the thread
     * \see QThread
     */
    void run();

private:
    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    // double modelTime, lastModelTime;

    QStringList attribList, states;
    QString graphicTitle;

    ChartPlot* plotter;
    QwtLegend *legend;
    QMap<QString, InternalCurve *> *internalCurves;

    QVector<double> *xAxisValues;

    bool paused;
};

} // namespace TerraMEObserver
#endif
