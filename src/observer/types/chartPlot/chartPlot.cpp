#include "chartPlot.h"

#include <QContextMenuEvent>
#include <QMenu>
#include <QAction>
#include <QVector>

#include "plotPropertiesGUI.h"
#include "internalCurve.h"
#include "visualArrangement.h"

#include <qwt_legend.h>
#include <qwt_symbol.h>
#include <qwt_plot_layout.h>
#include <qwt_plot_grid.h>
#include <qwt_plot_picker.h>

using namespace TerraMEObserver;

struct CurveBkp
{
    QPen pen;
    const QwtSymbol *symbol;
    QwtPlotCurve::CurveStyle style;
};

ChartPlot::ChartPlot(QWidget *parent) : QwtPlot(parent)
{
	id = 1;
    picker = 0;
    plotPropGui = 0;
    exportAct = new QAction("Export...", this);
    propertiesAct = new QAction("Properties...", this);

    ((QFrame*)canvas())->setFrameShape(QFrame::NoFrame);
    ((QFrame*)canvas())->setFrameShadow(QFrame::Plain);
    ((QFrame*)canvas())->setLineWidth(0);

	QwtPlotLayout *layout = plotLayout();
	layout->setCanvasMargin(0);
	// layout->setAlignCanvasToScales(true);
    createPicker();

    connect(exportAct, SIGNAL(triggered()), this, SLOT(exportChart()));
    connect(propertiesAct, SIGNAL(triggered()), this, SLOT(propertiesChart()));
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

void ChartPlot::contextMenuEvent(QContextMenuEvent *ev)
{
    QMenu context(this);
    // context.addAction(exportAct);
    context.addSeparator();
    context.addAction(propertiesAct);
    context.exec(ev->globalPos());
}

void ChartPlot::mouseDoubleClickEvent(QMouseEvent * /*ev*/)
{
    propertiesChart();
}

void ChartPlot::resizeEvent(QResizeEvent * q)
{
	VisualArrangement* v = VisualArrangement::getInstance();

	SizeVisualArrangement s;
	s.height = q->size().height();
	s.width = q->size().width();	

	v->addSize(id, s);

	QwtPlot::resizeEvent(q);
}

void ChartPlot::moveEvent(QMoveEvent* q)
{
	VisualArrangement* v = VisualArrangement::getInstance();

	PositionVisualArrangement s;
	s.x = q->pos().x();
	s.y = q->pos().y();	

	v->addPosition(id, s);
}

void ChartPlot::exportChart()
{
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
    int plotterLWidth = lineWidth();
    QPalette canvasPalette = canvas()->palette();
    QFont titleFont = title().font(), axesFont = axisTitle(QwtPlot::xBottom).font();
    QFont scalesFont = axisFont(QwtPlot::xBottom), legendFont = legend()->font();
    QVector<CurveBkp> curvesBkp;
    for (int i = 0; i < internalCurves.size(); i++)
    {
        CurveBkp bkp;
        bkp.pen = internalCurves.at(i)->plotCurve->pen();
        bkp.style = internalCurves.at(i)->plotCurve->style();
        bkp.symbol = internalCurves.at(i)->plotCurve->symbol();
        curvesBkp.append(bkp);
    }

    if(!plotPropGui->exec())
    {
        // Roll-backs plotter objects
        setPalette(plotterPalette);
        setLineWidth(plotterLWidth);

        // Title 
        QwtText text = title();
        text.setFont(titleFont);
        setTitle(text);

        // Axes
        text = axisTitle(QwtPlot::xBottom);
        text.setFont(axesFont);
        setAxisTitle(QwtPlot::xBottom, text);

        text = axisTitle(QwtPlot::yLeft);
        text.setFont(axesFont);
        setAxisTitle(QwtPlot::yLeft, text);

        // Scale
        setAxisFont(QwtPlot::xBottom, scalesFont);
        setAxisFont(QwtPlot::yLeft, scalesFont);

        legend()->setFont(legendFont);
        canvas()->setPalette(canvasPalette);

        for(int i = 0; i < curvesBkp.size(); i++)
        {
            CurveBkp bkp = curvesBkp.at(i);
            internalCurves.at(i)->plotCurve->setPen(bkp.pen);
            internalCurves.at(i)->plotCurve->setStyle(bkp.style);
            internalCurves.at(i)->plotCurve->setSymbol((QwtSymbol*)bkp.symbol);
        }
    }
}

void ChartPlot::setInternalCurves(const QList<InternalCurve *> &interCurves)
{
    internalCurves = interCurves;
}

void ChartPlot::createPicker()
{
    // cria o objeto responsável por exibir as coordenadas do ponteiro do mouse na tela
    picker = new QwtPlotPicker(QwtPlot::xBottom, QwtPlot::yLeft,
        /*QwtPicker::PointSelection | QwtPicker::DragSelection,*/
        QwtPlotPicker::CrossRubberBand, QwtPicker::ActiveOnly, //AlwaysOn,
        canvas());

    picker->setRubberBandPen( QColor(Qt::darkMagenta) );
    picker->setRubberBand(QwtPicker::CrossRubberBand);
    picker->setTrackerPen( QColor(Qt::black) );
}

