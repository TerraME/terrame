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

    //hashAttributes = (QHash<QString, Attributes *> *)
    //            &BlackBoard::getInstance().getAttributeHash(getSubjectId());

    hashAttributes = new QMap<QString, Attributes*>();

    // This pointer will pointing to a attribute object
    xAxisValues = 0;

    plotter = new ChartPlot(parent);
	plotter->id = getId();
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

	VisualArrangement* v = VisualArrangement::getInstance();

	SizeVisualArrangement s = v->getSize(getId());
	PositionVisualArrangement p = v->getPosition(getId());
    plotter->setWindowTitle("TerraME :: Chart");

	if(s.width > 0 && s.height > 0)
		plotter->resize(s.width, s.height);
	else
		plotter->resize(450, 350);

    plotter->showNormal();

    // thread priority
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);

	if(p.x > 0 && p.y > 0)
		plotter->move(p.x, p.y - plotter->geometry().y() + plotter->y());
	else
		plotter->move(50 + getId() * 50, 50 + getId() * 50);
}

ObserverGraphic::~ObserverGraphic()
{
    // wait();
    foreach(InternalCurve *curve, internalCurves->values())
        delete curve;
    delete internalCurves; internalCurves = 0;

    delete plotter; plotter = 0;

    if (observerType == TObsDynamicGraphic)
        delete xAxisValues;

    //if (legend)
    //    delete legend;
    //legend = 0;
}

void ObserverGraphic::setObserverType(TypesOfObservers type)
{
    observerType = type;

    if (observerType == TObsDynamicGraphic)
        xAxisValues = new QVector<double>();
}

const TypesOfObservers ObserverGraphic::getType() const
{
    return observerType;
}

void ObserverGraphic::save(std::string file, std::string extension)
{
	plotter->exportChart(file, extension);
}

bool ObserverGraphic::draw(QDataStream &/*state*/)
{

#ifdef TME_BLACK_BOARD

    draw();

#else // TME_BLACKBOARD

    QString msg, key;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    QVector<double> *ord = 0, *abs = xAxisValues;

    //QString subjectId = tokens.at(0);
    // subjectType = (TypesOfSubjects) tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int numElems = tokens.at(3).toInt();

    int j = 4;

    for(int i = 0; i < qtdParametros; i++)
    {
        key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

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
						lua_pushstring(L, str.c_str());
						lua_call(L, 1, 0);
					}
				}
                break;
            case(TObsDateTime):
                //break;
            case(TObsNumber):
                if(contains)
                {
                    if(internalCurves->contains(key))
                        internalCurves->value(key)->values->append(
                        		tokens.at(j).toDouble());
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

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
                        // Graph: X vs Y
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
                    if (!states.contains(tokens.at(j)))
                        states.push_back(tokens.at(j));

                    if (internalCurves->contains(key))
                        internalCurves->value(key)->values->append(
                        		states.indexOf(tokens.at(j)));
                    else
                        xAxisValues->append(tokens.at(j).toDouble());

                    // Dynamic Graph: Time vs Y
                    if (observerType == TObsDynamicGraphic)
                    {
                        ord = internalCurves->value(key)->values;
                        internalCurves->value(key)->plotCurve->setData(*abs, *ord);
                    }
                    else
                    {
                        // Graph: X vs Y
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
						string str = string("Warnig: Was expected a numeric parameter not a string ")
								+ string(tokens.at(j)) + string(".");
						lua_getglobal(L, "customWarning");
						lua_pushstring(L, str.c_str());
						lua_call(L, 1, 0);
					}
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
            curve->plotCurve->setData(*abs, *internalCurves->value(
            		internalCurves->keys().at(i))->values);
        }
    }
    plotter->repaint();

#endif // TME_BLACKBOARD

    qApp->processEvents();
    return true;
}

void ObserverGraphic::setTitles(const QString &title,
		const QString &xTitle, const QString &yTitle)
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

void ObserverGraphic::setAttributes(const QStringList &attribs,
		const QStringList &curveTitles,
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

    // Ignores the attribute of the x axis
    if(observerType == TObsGraphic)
        attrSize--;

    for(int i = 0; i < attrSize; i++)
    {
        interCurve = new InternalCurve(attribList.at(i), plotter);

        if(interCurve)
        {
            internalCurves->insert(attribList.at(i), interCurve);

            // resign the values vector a curve
            delete interCurve->values;
            interCurve->values = hashAttributes->value(
            		attribList.at(i))->getNumericValues();

            if(i < curveTitles.size())
                interCurve->plotCurve->setTitle(curveTitles.at(i));
            else
                interCurve->plotCurve->setTitle(QString("$curve %1").arg(i + 1));

			interCurve->plotCurve->setLegendAttribute(QwtPlotCurve::LegendShowLine);

            int width = 0, style = 0, symbol = 0,
            		colorBar = 0, num = 0, size, penstyle = 0;

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

                aux = legAttribs.at(colorBar).mid(0,
                		legAttribs.at(colorBar).indexOf(COLOR_BAR_SEP));

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
				lua_call(L, 1, 0);
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
    //if (w && w->inherits("QwtLegendItem"))
    //{
    //    QColor color = ((QwtLegendItem *)w)->curvePen().color();
    //    color = QColorDialog::getColor(color);

    //    if ((color.isValid()) && (color != ((QwtLegendItem *)w)->curvePen().color()))
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
	if(xAxisValues->size() > 0 && time == (*xAxisValues)[0]
		&& (*xAxisValues)[xAxisValues->size() - 1] == (xAxisValues->size() - 1))
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
    // QThread::exit(0);
    return 0;
}

void ObserverGraphic::draw()
{
    InternalCurve *curve = 0;
    SubjectAttributes *subjAttr = 0;
    int id = getSubjectId();
    double v = 0;

    for (int i = hashAttributes->values().size() - 1; i >= 0; i--)
    {
        Attributes *attrib = hashAttributes->values().at(i);

        subjAttr = BlackBoard::getInstance().getSubject(id);

        if (subjAttr && subjAttr->getNumericValue(attrib->getName(), v))
        {
            attrib->addValue(id, v);

            if (internalCurves->contains(attrib->getName()))
            {
                curve = internalCurves->value(attrib->getName());
                curve->plotCurve->setSamples(*xAxisValues, *curve->values);
            }
        }
    }
    plotter->repaint();

#ifdef DEBUG_OBSERVER
        qDebug() << "internalCurves->keys().at(i): " << internalCurves->keys().at(i);
        qDebug() << "\nxAxisValues->size() - "
        		<< xAxisValues->size() << ": " << *xAxisValues;
        qDebug() << "curve->values->size() - "
        		<< curve->values->size() << ": " << *curve->values;
#endif
}

