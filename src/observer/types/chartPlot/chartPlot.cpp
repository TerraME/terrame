#include "chartPlot.h"

#include <QContextMenuEvent>
#include <QMenu>
#include <QAction>
#include <QVector>

#include "plotPropertiesGUI.h"
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
    plotPropGui = 0;
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
//    connect(propertiesAct, SIGNAL(triggered()), this, SLOT(propertiesChart()));

    id = 0;

    canvas()->setStyleSheet("border: 0px");
}

ChartPlot::~ChartPlot()
{
    delete exportAct; exportAct = 0;
    delete propertiesAct; propertiesAct = 0;
    delete plotPropGui; plotPropGui = 0;

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
    propertiesChart();
}
*/

void ChartPlot::exportChart(std::string file, string extension)
{
	QPixmap pixmap = grab();
	pixmap.save(file.c_str(), extension.c_str());
}

void ChartPlot::propertiesChart()
{
    if (! plotPropGui)
    {
        plotPropGui = new PlotPropertiesGUI(this);
        plotPropGui->consistGUI(( QList<InternalCurve *> *) &internalCurves);    
    }
    
    // Creates chart objects back-up
	QPalette plotterPalette = palette();
    int plotterMargin = 1;//margin();
    int plotterLWidth = lineWidth();
    QPalette canvasPalette = canvas()->palette();
    //QVector<CurveBkp> curvesBkp;
    for (int i = 0; i < internalCurves.size(); i++)
    {
        //CurveBkp bkp;
        //bkp.pen = internalCurves.at(i)->plotCurve->pen();
        //bkp.style = internalCurves.at(i)->plotCurve->style();
        //bkp.symbol = internalCurves.at(i)->plotCurve->symbol();
        //curvesBkp.append(bkp);
    }

    if (! plotPropGui->exec())
    {
        // Roll-backs plotter objects

        setPalette(plotterPalette);
        //setMargin(plotterMargin);
        setLineWidth(plotterLWidth);

        // Title 
        QwtText text = title();
        setTitle(text);

        // Axes
        text = axisTitle(QwtPlot::xBottom);
        setAxisTitle(QwtPlot::xBottom, text);

        text = axisTitle(QwtPlot::yLeft);
        setAxisTitle(QwtPlot::yLeft, text);

        canvas()->setPalette(canvasPalette);

        //for (int i = 0; i < curvesBkp.size(); i++)
        //{
            //CurveBkp bkp = curvesBkp.at(i);
            //internalCurves.at(i)->plotCurve->setPen(bkp.pen);
            //internalCurves.at(i)->plotCurve->setStyle(bkp.style);
            //internalCurves.at(i)->plotCurve->setSymbol(bkp.symbol);
        //}
    }
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

    picker->setRubberBandPen( QColor(Qt::darkMagenta) );
    picker->setRubberBand(QwtPicker::CrossRubberBand);
    picker->setTrackerPen( QColor(Qt::black) );
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
    VisualArrangement::getInstance()->resizeEventDelegate(id, event);

    QwtPlot::resizeEvent(event);
}

void ChartPlot::moveEvent(QMoveEvent *event)
{
    VisualArrangement::getInstance()->moveEventDelegate(id, event);
}

void ChartPlot::closeEvent(QCloseEvent *event)
{
    VisualArrangement::getInstance()->closeEventDelegate();
}

