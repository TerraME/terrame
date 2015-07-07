#include "observerGraphic.h"

#include <iostream>

using namespace std;

#include <QColorDialog>
#include <QApplication>
#include <QPalette>
#include <QDebug>

#include <qwt_plot_legenditem.h>
#include <qwt_plot_item.h>

#include "chartPlot.h"
#include "internalCurve.h"
#include "terrameGlobals.h"

extern ExecutionModes execModes;

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "../statistic/statistic.h"
#endif

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
    plotter->setAutoReplot(true);
	plotter->setStyleSheet("QwtPlot { padding: 8px }");
    plotter->setFrameShape(QFrame::Box);
    plotter->setFrameShadow(QFrame::Plain);
    plotter->setLineWidth(0);

    QPalette palette = plotter->canvas()->palette();
    palette.setColor(QPalette::Background, Qt::white);
    plotter->canvas()->setPalette(palette);

    palette = plotter->palette();
    palette.setColor(QPalette::Background, Qt::white);
    plotter->setPalette(palette);

    plotter->resize(450, 350);
    plotter->setWindowTitle("TerraME Observer : Chart");

    plotter->showNormal();

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
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
    subjectType = (TypesOfSubjects) tokens.at(1).toInt();
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
        bool contains = (idx != -1); // caso a chave n?o exista, idx == -1

        switch (typeOfData)
        {
            case (TObsBool):
                if (contains)
                    if (execModes != Quiet)
                        qWarning("Was expected a numeric parameter.");
                break;

            case (TObsDateTime)	:
                //break;

            case (TObsNumber):

                if (contains)
                {
                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append( tokens.at(j).toDouble() );
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

                    // Gr?fico Din?mico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        internalCurves->value(key)->plotCurve->setSamples(*abs, *ord); 
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
                if (! contains)
                    break;

                if ( (subjectType == TObsAutomaton) || (subjectType == TObsAgent) )
                {
                    if (! states.contains(tokens.at(j)))
                        states.push_back(tokens.at(j));

                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append( states.indexOf(tokens.at(j)) );
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

                    // Gr?fico Din?mico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        abs = xAxisValues;
                        internalCurves->value(key)->plotCurve->setSamples(*abs, *ord); 
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
                                 qPrintable(tokens.at(j)) );
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
            curve = internalCurves->value( internalCurves->keys().at(i) );
            curve->plotCurve->setSamples(*abs, *internalCurves->value( internalCurves->keys().at(i) )->values); 
        }
    }
    plotter->repaint();

    qApp->processEvents();
    return true;
}

void ObserverGraphic::setTitles(const QString &title, const QString &xTitle, const QString &yTitle)
{
    plotter->setTitle(title);

    plotter->setAxisTitle(QwtPlot::xBottom, xTitle);
    plotter->setAxisTitle(QwtPlot::yLeft, yTitle);
}

void ObserverGraphic::setLegendPosition(QwtPlot::LegendPosition pos)
{
    if (! legend)
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
#ifdef DEBUG_OBSERVER
    qDebug() <<"\n" << attribs;
    qDebug() << curveTitles;
    qDebug() << "LEGEND_ITENS: " << LEGEND_ITENS;

    for(int i = 0; i < legKeys.size(); i++)
    {
        if (i == LEGEND_ITENS)
            qDebug() << "\n";

        qDebug() << i << " - " << legKeys.at(i) << ": " << legAttribs.at(i);
    }
#endif

    attribList = attribs;
    InternalCurve *interCurve = 0;
    QColor color;

    int attrSize = attribList.size();

    // Ignores the attribute of the x axis 
    if (observerType == TObsGraphic)
        attrSize--;

    for(int i = 0; i < attrSize; i++)
    {
        interCurve = new InternalCurve(attribList.at(i), plotter);

        if (interCurve)
        {

            if (i < curveTitles.size())
                interCurve->plotCurve->setTitle(curveTitles.at(i));
            else
                interCurve->plotCurve->setTitle(QString("$curve %1").arg(i + 1));

            internalCurves->insert(attribList.at(i), interCurve);

            // Sets a random color for the created curve 
            color = QColor::fromHsvF(hueValues[(int)(qrand() % HUE_COUNT)], 1, 1);
            interCurve->plotCurve->setPen(color);
			interCurve->plotCurve->setLegendAttribute(QwtPlotCurve::LegendShowLine);

            int width = 0, style = 0, symbol = 0, colorBar = 0, num = 0, size = 0, penstyle = 0;

            width = legKeys.indexOf(WIDTH);
            style = legKeys.indexOf(STYLE);
            symbol = legKeys.indexOf(SYMBOL);
			size = legKeys.indexOf(SIZE_);
			penstyle = legKeys.indexOf(PENSTYLE);
            colorBar = legKeys.indexOf(COLOR_BAR);

            if ((! legAttribs.isEmpty()) && (colorBar > -1))
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
                pen.setWidth( (num > 0) ? num : 1);
                interCurve->plotCurve->setPen(pen);

				// pen
                num = legAttribs.at(penstyle).toInt();
				pen.setStyle((Qt::PenStyle) num);
                interCurve->plotCurve->setPen(pen);

                // style
                num = legAttribs.at(style).toInt();
                interCurve->plotCurve->setStyle( (QwtPlotCurve::CurveStyle) num);

                // symbol
                num = legAttribs.at(symbol).toInt();
                QwtSymbol* qwtSymbol = new QwtSymbol;
                qwtSymbol->setStyle( (QwtSymbol::Style) num);
                qwtSymbol->setPen(pen);

				if((QwtSymbol::Style) num != (QwtSymbol::Style) -1)
				{
					interCurve->plotCurve->setLegendAttribute(QwtPlotCurve::LegendShowSymbol);
				}

				//size
                num = legAttribs.at(size).toInt();
                qwtSymbol->setSize(num);


                if (qwtSymbol->brush().style() != Qt::NoBrush)
                    qwtSymbol->setBrush(pen.color());

                interCurve->plotCurve->setSymbol(qwtSymbol);

                for(int j = 0; j < LEGEND_ITENS; j++)
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
    //if ( w && w->inherits("QwtLegendItem") )
    //{
    //    QColor color = ((QwtLegendItem *)w)->curvePen().color();
    //    color = QColorDialog::getColor(color);

    //    if ((color.isValid()) && (color != ((QwtLegendItem *)w)->curvePen().color()) )
    //    {
    //        ((QwtLegendItem *)w)->setCurvePen(QPen(color));
    //        
    //        // in this context, pointer item is QwtPlotItem son 
    //        ((QwtPlotCurve *)item)->setPen(QPen(color));
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
	if(xAxisValues->size() > 0 && time == (*xAxisValues)[0] && (*xAxisValues)[xAxisValues->size() - 1] == (xAxisValues->size() - 1))
		time = xAxisValues->size();	

    if (observerType == TObsDynamicGraphic)
        xAxisValues->push_back(time);
}

void ObserverGraphic::setCurveStyle()
{
    foreach(InternalCurve *curve, internalCurves->values())
        curve->plotCurve->setStyle(QwtPlotCurve::Steps);
}

int ObserverGraphic::close()
{
    plotter->close();
    QThread::exit(0);
    return 0;
}
