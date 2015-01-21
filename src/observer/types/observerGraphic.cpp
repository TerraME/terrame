#include "observerGraphic.h"

#include <QColorDialog>
#include <QApplication>
#include <QPalette>
#include <QDebug>

#include <qwt_plot_legenditem.h>
#include <qwt_plot_item.h>

#include "chartPlot.h"
#include "internalCurve.h"
#include "terrameGlobals.h"

extern "C"
{
#include <lua.h>
}
#include "luna.h"

extern lua_State * L;
extern ExecutionModes execModes;

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    #include "statistic.h"
#endif

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
    #include "subjectAttributes.h"
    #include "legendAttributes.h"
#endif

#include "visualArrangement.h"

using namespace TerraMEObserver;

ObserverGraphic::ObserverGraphic(Subject *sub, QWidget *parent) 
    : ObserverInterf(sub) // , QThread()
{
    observerType = TObsGraphic;
    subjectType = sub->getType(); // TO_DO: Changes it to Observer pattern

    // paused = false;
    legend = new QwtLegend;
    // legend->setItemMode(QwtLegend::ClickableItem);
    internalCurves = new QHash<QString, InternalCurve*>();

#ifdef TME_BLACK_BOARD
    //hashAttributes = (QHash<QString, Attributes *> *) 
    //            &BlackBoard::getInstance().getAttributeHash(getSubjectId());

    hashAttributes = new QHash<QString, Attributes*>();

    // This pointer will pointing to a attribute object
    xAxisValues = 0;
#else
    xAxisValues = new QVector<double>();
#endif
    
    plotter = new ChartPlot(parent);
	plotter->id = getId();
    plotter->setAutoReplot(true);
//    plotter->setStyleSheet("background-color: rgb(255, 255, 255);");
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

	VisualArrangement* v = VisualArrangement::getInstance();

	SizeVisualArrangement s = v->getSize(getId());
	PositionVisualArrangement p = v->getPosition(getId());

	if(s.width > 0 && s.height > 0)
	    plotter->resize(s.width, s.height);
	else
	    plotter->resize(450, 350);

	if(p.x > 0 && p.y > 0)
		plotter->move(p.x, p.y);
	else
		plotter->move(50 + getId() * 50, 50 + getId() * 50);

    plotter->setWindowTitle("TerraME :: Chart");

    plotter->showNormal();

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);
}

ObserverGraphic::~ObserverGraphic()
{
    // wait();
    foreach(InternalCurve *curve, internalCurves->values())
        delete curve;
    delete internalCurves; internalCurves = 0;

    delete plotter; plotter = 0;

#ifdef TME_BLACK_BOARD
    if (observerType == TObsDynamicGraphic)
        delete xAxisValues;
#else
    delete xAxisValues;
#endif

    //if (legend)
    //    delete legend;
    //legend = 0;
}

void ObserverGraphic::setObserverType(TypesOfObservers type)
{
    observerType = type;

#ifdef TME_BLACK_BOARD
    if (observerType == TObsDynamicGraphic)
        xAxisValues = new QVector<double>();
#endif
}

const TypesOfObservers ObserverGraphic::getType() const
{
    return observerType;
}

bool ObserverGraphic::draw(QDataStream &/*state*/)
{
#ifdef TME_STATISTIC
	// Captura o tempo de espera para os observadores que tambem sao threads
    double t = Statistic::getInstance().endVolatileMicroTime();

    QString name = QString("wait %1").arg(getId());
	Statistic::getInstance().addElapsedTime(name, t);
#endif

#ifdef TME_BLACK_BOARD

#ifdef TME_STATISTIC
    t = Statistic::getInstance().startMicroTime();
#endif

    draw();

#ifdef TME_STATISTIC
    name = QString("graphic Rendering %1").arg(getId());
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime(name, t);
#endif

#else // TME_BLACKBOARD

#ifdef TME_STATISTIC
    double decodeSum = 0.0;
    int decodeCount = 0;
#endif

    QString msg, key;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    QVector<double> *ord = 0, *abs = xAxisValues;

#ifdef TME_STATISTIC 
        // t = Statistic::getInstance().startMicroTime();
        Statistic::getInstance().startVolatileMicroTime();
#endif

    //QString subjectId = tokens.at(0);
    // subjectType = (TypesOfSubjects) tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int numElems = tokens.at(3).toInt();

#ifdef TME_STATISTIC 
        // decodeSum += Statistic::getInstance().endMicroTime() - t;
        decodeSum += Statistic::getInstance().endVolatileMicroTime();
        decodeCount++;
#endif

    int j = 4;

    for(int i = 0; i < qtdParametros; i++)
    {

#ifdef TME_STATISTIC 
        // t = Statistic::getInstance().startMicroTime();
        Statistic::getInstance().startVolatileMicroTime();
#endif

        key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

#ifdef TME_STATISTIC 
        // decodeSum += Statistic::getInstance().endMicroTime() - t;
        decodeSum += Statistic::getInstance().endVolatileMicroTime();
        decodeCount++;
#endif

        int idx = attribList.indexOf(key);
        // bool contains = itemList.contains(key);
        bool contains = (idx != -1);

        switch (typeOfData)
        {
            case (TObsBool):
                if (contains)
				{
					if (execModes != Quiet)
					{
						string str = string("Was expected a numeric parameter.");
						lua_getglobal(L, "customWarning");
						lua_pushstring(L,str.c_str());
						lua_pushnumber(L, 5);
						lua_call(L, 2, 0);
					}
				}
                break;
            case(TObsDateTime):
                //break;
            case(TObsNumber):
                if(contains)
                {
#ifdef TME_STATISTIC
                    // t = Statistic::getInstance().startMicroTime();
                    Statistic::getInstance().startVolatileMicroTime();
#endif
                    if(internalCurves->contains(key))
                        internalCurves->value(key)->values->append( tokens.at(j).toDouble() );
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

#ifdef TME_STATISTIC 
                    // decodeSum += Statistic::getInstance().endMicroTime() - t;
                    decodeSum += Statistic::getInstance().endVolatileMicroTime();
                    decodeCount++;
#endif

                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        internalCurves->value(key)->plotCurve->setData(*abs, *ord); 

                        //qDebug() << "key: " << key;
                        //qDebug() << *ord;
                        //qDebug() << *abs;
                    }
                    else
                    {
                        // Gráfico: X vs Y
                        if (idx != attribList.size() - 1)
                            ord = internalCurves->value(key)->values; // y axis
                    }
                }
                break;

            // case TObsText:
            default:
                if (!contains)
                    break;

                if((subjectType == TObsAutomaton) || (subjectType == TObsAgent))
                {

#ifdef TME_STATISTIC
                    // t = Statistic::getInstance().startMicroTime();
                    Statistic::getInstance().startVolatileMicroTime();
#endif

                    if (! states.contains(tokens.at(j)))
                        states.push_back(tokens.at(j));

                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append( states.indexOf(tokens.at(j)) );
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

#ifdef TME_STATISTIC
                    // decodeSum += Statistic::getInstance().endMicroTime() - t;
                    decodeSum += Statistic::getInstance().endVolatileMicroTime();
                    decodeCount++;
#endif

                    // Gráfico Dinâmico: Tempo vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        internalCurves->value(key)->plotCurve->setData(*abs, *ord); 
                    }
                    else
                    {
                        // Gráfico: X vs Y
                        if (idx != attribList.size() - 1)
                            ord = internalCurves->value(key)->values;
                        // else                     
                        //     abs = xAxisValues; // internalCurves->value(key)->values;
                    }
                }
                else
                {
                    if (execModes != Quiet)
					{
						string str = string("Warnig: Was expected a numeric parameter not a string ") + string(tokens.at(j)) + string(".");
						lua_getglobal(L, "customWarningMsg");
						lua_pushstring(L,str.c_str());
						lua_pushnumber(L,5);
						lua_call(L,2,0);
					}
                }
                break;
        }
        j++;
    }
    
#ifdef TME_STATISTIC
    t = Statistic::getInstance().startMicroTime();
#endif

    if (observerType == TObsGraphic)
    {
        InternalCurve *curve = 0;

        for (int i = 0; i < internalCurves->keys().size(); i++)
        {
            curve = internalCurves->value( internalCurves->keys().at(i) );
            curve->plotCurve->setData(*abs, *internalCurves->value( internalCurves->keys().at(i) )->values); 
        }
    }
    plotter->repaint();

#ifdef TME_STATISTIC
    name = QString("graphic Rendering %1").arg(getId());
    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime(name, t);

    name = QString("graphic Decoder %1").arg(getId());
    if (decodeCount > 0)
        Statistic::getInstance().addElapsedTime(name, decodeSum / decodeCount);
#endif

#endif // TME_BLACKBOARD

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
    plotter->insertLegend(legend, pos);

	// #253
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

#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());

    Attributes *attrib = 0;

    for(int i = 0; i < attrSize; i++)
    {
        attrib = new Attributes(attribList.at(i), 0, 0);
        hashAttributes->insert(attribList.at(i), attrib);

        attrib->setParentSubjectID(getSubjectId());            
    }

    // Ignores the attribute of the x axis 
    if(observerType == TObsGraphic)
        xAxisValues = attrib->getNumericValues(); // last attribute is used in X axis
#endif
    
    // Ignores the attribute of the x axis 
    if(observerType == TObsGraphic)
        attrSize--;

    for(int i = 0; i < attrSize; i++)
    {
        interCurve = new InternalCurve(attribList.at(i), plotter);

        if(interCurve)
        {
            internalCurves->insert(attribList.at(i), interCurve);

#ifdef TME_BLACK_BOARD
            // resign the values vector a curve
            delete interCurve->values;
            interCurve->values = hashAttributes->value(attribList.at(i))->getNumericValues();
#endif
            
            if(i < curveTitles.size())
                interCurve->plotCurve->setTitle(curveTitles.at(i));
            else
                interCurve->plotCurve->setTitle(QString("$curve %1").arg(i + 1));

			interCurve->plotCurve->setLegendAttribute(QwtPlotCurve::LegendShowLine);

            int width = 0, style = 0, symbol = 0, colorBar = 0, num = 0, size, penstyle = 0;

            width = legKeys.indexOf(WIDTH);
            style = legKeys.indexOf(STYLE);
            symbol = legKeys.indexOf(SYMBOL);
			size = legKeys.indexOf(SIZE);
			penstyle = legKeys.indexOf(PENSTYLE);
            colorBar = legKeys.indexOf(COLOR_BAR);

            if((!legAttribs.isEmpty()) && (colorBar > -1))
            {
                QString aux;
                QStringList colorStrList;
                QPen pen;

                aux = legAttribs.at(colorBar).mid(0, legAttribs.at(colorBar).indexOf(COLOR_BAR_SEP));
                
                // Retrieves the first colorBar value 
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

				// pen
                num = legAttribs.at(penstyle).toInt();
				pen.setStyle((Qt::PenStyle) num);
                interCurve->plotCurve->setPen(pen);

                // style
                num = legAttribs.at(style).toInt();
                interCurve->plotCurve->setStyle((QwtPlotCurve::CurveStyle) num);

                // symbol
                num = legAttribs.at(symbol).toInt();
                QwtSymbol *qwtSymbol = new QwtSymbol;
                qwtSymbol->setStyle((QwtSymbol::Style) num);
                qwtSymbol->setPen(pen);

				if((QwtSymbol::Style) num != (QwtSymbol::Style) -1)
				{
					interCurve->plotCurve->setLegendAttribute(QwtPlotCurve::LegendShowSymbol);
				}

				//size
                num = legAttribs.at(size).toInt();
                qwtSymbol->setSize(num);

                if(qwtSymbol->brush().style() != Qt::NoBrush)
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
			if(execModes != Quiet)
			{
				string str = string(qPrintable(TerraMEObserver::MEMORY_ALLOC_FAILED));
				lua_getglobal(L, "customWarning");
				lua_pushstring(L, str.c_str());
				lua_pushnumber(L, 5);
				lua_call(L, 2, 0);
			}
        }
    }
    plotter->setInternalCurves(internalCurves->values());

//#ifdef TME_BLACK_BOARD_
//    Attributes *attrib = 0;
//
//    for(int i = 0; i < attribList.size(); i++)
//    {
//        attrib = (Attributes *) &BlackBoard::getInstance()
//            .addAttribute(getSubjectId(), attribList.at(i));
//
//        attrib->setVisible(true);
//        attrib->setObservedBy(observerType);
//    }
//
//    if (observerType == TObsGraphic)
//        xAxisValues = attrib->getNumericValues(); // last attribute is used in X axis
//    
//    for (int i = 0; i < internalCurves->keys().size(); i++)
//    {
//        interCurve = internalCurves->value(internalCurves->keys().at(i));
//
//        attrib = (Attributes *) &BlackBoard::getInstance()
//            .addAttribute(getSubjectId(), attribList.at(i));
//
//        // Frees memory of curve values 
//        delete interCurve->values;
//        interCurve->values = attrib->getNumericValues();
//        
//        interCurve->plotCurve->setData(*xAxisValues, *interCurve->values);
//    }
//#endif
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

//void ObserverGraphic::run()
    //{
//    //while (!paused)
//    //{
//    //    QThread::exec();
//    //}
    //    QThread::exec();
//}

//void ObserverGraphic::pause()
//{
//    paused = !paused;
    //}

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
        curve->plotCurve->setStyle(QwtPlotCurve::Steps);
}

int ObserverGraphic::close()
{
    plotter->close();
    // QThread::exit(0);
    return 0;
}

void ObserverGraphic::draw()
{
    InternalCurve *curve = 0;
    SubjectAttributes *subjAttr = 0;
    int id = getSubjectId();
    double v = 0; 

    foreach(Attributes *attrib, hashAttributes->values())
    {
        subjAttr = BlackBoard::getInstance().getSubject(id);
        
        if (subjAttr && subjAttr->getNumericValue(attrib->getName(), v))
        {
            attrib->addValue(id, v);

            if (internalCurves->contains(attrib->getName()))
            {
                curve = internalCurves->value( attrib->getName() );
                curve->plotCurve->setSamples(*xAxisValues, *curve->values); 
            }
        }
    }
    plotter->repaint();
    
#ifdef DEBUG_OBSERVER
        qDebug() << "internalCurves->keys().at(i): " << internalCurves->keys().at(i);
        qDebug() << "\nxAxisValues->size() - " << xAxisValues->size() << ": " << *xAxisValues;
        qDebug() << "curve->values->size() - " << curve->values->size() << ": " << *curve->values;
#endif
}
