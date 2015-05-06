#include "legendAttributes.h"

#include <QDebug>
#include <math.h>

using namespace TerraMEObserver;

//////////////////////////////////////////////////////////////////////////////////////////// OBS_LEGEND
ObsLegend::ObsLegend() : color(Qt::white), from(""), to(""), label("")
{
     occurrence = 0;
     fromNumber = 0;
     toNumber = 0;
     idxColor = 0;
}

ObsLegend::ObsLegend(const ObsLegend &other)
{
    if(this != &other)
    {
        color = other.color;
        from = other.from;
        to = other.to;
        label = other.label;
        occurrence = other.occurrence;
        idxColor = other.idxColor;

        fromNumber = other.fromNumber;
        toNumber = other.toNumber;
    }
}

ObsLegend & ObsLegend::operator=(const ObsLegend &other)
{
    if(this == &other)
        return *this;

    color = other.color;
    from = other.from;
    to = other.to;
    label = other.label;
    occurrence = other.occurrence;
    idxColor = other.idxColor;

    fromNumber = other.fromNumber;
    toNumber = other.toNumber;

    return *this;
}

ObsLegend::~ObsLegend()
{
}

void ObsLegend::setColor(const QColor & c)
{
    color = c;
}

void ObsLegend::setColor(int r, int g, int b, int a)
{
    color = QColor(r, g, b, a);
    invColor = QColor(255 - r, 255 - g, 255 - b, a);
}

//QColor ObsLegend::getColor() const
//{
//    return color;
//}

void ObsLegend::setFrom(const QString & f)
{
    from = f;
    fromNumber = from.toDouble();
}

//const QString & ObsLegend::getFrom() const
//{
//    return from;
//}

//double ObsLegend::getFromNumber() const
//{
//    return fromNumber;
//}

void ObsLegend::setTo(const QString & t)
{
    to = t;
    toNumber = to.toDouble();
}

//const QString & ObsLegend::getTo() const
//{
//    return to;
//}

//double ObsLegend::getToNumber() const
//{
//    return toNumber;
//}

void ObsLegend::setLabel(const QString & l)
{
    label = l;
}

//const QString & ObsLegend::getLabel() const
//{
//    return label;
//}

void ObsLegend::setOccurrence(int o)
{
    occurrence = o;
}

//int ObsLegend::getOccurrence() const
//{
//    return occurrence;
//}

void ObsLegend::setIdxColor(unsigned int i)
{
    idxColor = i;
}

//unsigned int ObsLegend::getIdxColor() const
//{
//    return idxColor;
//}

QDataStream & operator <<(QDataStream & out, const TerraMEObserver::ObsLegend & obsLeg)
{
    out << obsLeg.getColor();
    out << obsLeg.getFrom();
    out << obsLeg.getTo();
    out << obsLeg.getLabel();
    out << (qint8) obsLeg.getOccurrence();
    out << (quint8) obsLeg.getIdxColor(); 

    // out << obsLeg.fromNumber;
    // out << obsLeg.toNumber;

    return out;
}

QDataStream & operator >>(QDataStream & in, TerraMEObserver::ObsLegend & obsLeg)
{
    QColor color;
    QString from, to, label;
    qint8 occurrence;
    quint8 idxColor;
    double fromNumber, toNumber;

    in >> color;
    in >> from;
    in >> to;
    in >> label;
    in >> occurrence;
    in >> idxColor;

    in >> fromNumber;
    in >> toNumber;

    obsLeg.setColor(color);
    obsLeg.setFrom(from);
    obsLeg.setTo(to);
    obsLeg.setLabel(label);
    obsLeg.setOccurrence((int)occurrence);
    obsLeg.setIdxColor((unsigned int) idxColor);

    // obsLeg.setFrom = fromNumber;
    // obsLeg.toNumber = toNumber;

    return in;
}

//////////////////////////////////////////////////////////////////////////////////////////// ATTRIBUTES

Attributes::Attributes(const QString &name, double width, double height, TypesOfSubjects type) 
    : attribName(name), attribType(type) 
{	
    attribDataType = TObsUnknownData;
    observerBy = TObsUndefined;
    className = "";

    circularIdxVectorDirectionPos = 0;

    numericValues = new QVector<double>();
    textValues = new QVector<QString>();
    boolValues = new QVector<bool>();

#ifdef TME_BLACK_BOARD
    xs = NULL;
    ys = NULL;
#else
    xs = new QVector<double>();
    ys = new QVector<double>();
#endif
    legend = new QVector<ObsLegend>();

	////@RAIAN
 //   neighValues = new QVector<QMap<QString, QList<double> > >;
 //   neighValues = 0;
	////@RAIAN: END
	
    valueList = QStringList();
    labelList = QStringList();

    setImageSize(QSize(width, height));

    dirtyBit = true;
    visible = true;
    maxValue = 100;
    minValue = 0;
    val2Color = 255 / (maxValue - minValue);
    colorBarVec = std::vector<ColorBar>();
    stdColorBarVec = std::vector<ColorBar>();

    slicesNumber = 4; // posicao 5 no comboBox
    groupMode = TObsEqualSteps;
    precNumber = 5; // posicao 6 no comboBox
    stdDev = TObsNone;

    // Bkp
    slicesNumberBkp = -1;
    precNumberBkp = -1;

    attribDataTypeBkp = TObsUnknownData;
    groupModeBkp = TObsEqualSteps;
    stdDevBkp = TObsNone;
    colorBarVecBkp = std::vector<ColorBar>();
    stdColorBarVecBkp = std::vector<ColorBar>();
}

Attributes::Attributes(const Attributes &other)
{
    if (this != &other)
    {
#ifndef TME_BLACK_BOARD
        delete xs;
        delete ys;
#endif
        delete numericValues;
        delete textValues;
        delete boolValues;
        delete legend;

        xs = other.xs;
        ys = other.ys;
        numericValues = other.numericValues;
        textValues = other.textValues;
        boolValues = other.boolValues;
        legend = other.legend;

		////@RAIAN
		//neighValues = other.neighValues;
		////@RAIAN: END
		
        colorBarVec = colorBarVec;
        stdColorBarVec = stdColorBarVec;
        valueList = valueList;
        labelList = labelList;

        attribName = other.attribName;
        maxValue = other.maxValue;
        minValue = other.minValue;
        val2Color = other.val2Color;

        slicesNumber = other.slicesNumber;
        precNumber = other.precNumber;

        // Enumerators
        attribType = other.attribType;
        observerBy = other.observerBy;
        attribDataType = other.attribDataType;
        groupMode = other.groupMode;
        stdDev = other.stdDev;

        image = other.image;
        visible = other.visible;
        className = other.className;

        //---- Bkps ---------------------------------
        slicesNumberBkp = other.slicesNumberBkp;
        precNumberBkp = other.precNumberBkp;

        attribDataTypeBkp = other.attribDataTypeBkp;
        groupModeBkp = other.groupModeBkp;
        stdDevBkp = other.stdDevBkp;
        colorBarVecBkp = other.colorBarVecBkp;
        stdColorBarVecBkp = other.stdColorBarVecBkp;
    }
}

Attributes & Attributes::operator=(const Attributes &other)
{
    if (this == &other)
        return *this;

#ifndef TME_BLACK_BOARD
    delete xs;
    delete ys;
#endif

    delete numericValues;
    delete textValues;
    delete boolValues;
    delete legend;

    xs = other.xs;
    ys = other.ys;
    numericValues = other.numericValues;
    textValues = other.textValues;
    boolValues = other.boolValues;
    legend = other.legend;

	////@RAIAN
	//neighValues = other.neighValues;
	////@RAIAN: END
	
    colorBarVec = colorBarVec;
    stdColorBarVec = stdColorBarVec;
    valueList = valueList;
    labelList = labelList;

    attribName = other.attribName;
    maxValue = other.maxValue;
    minValue = other.minValue;
    val2Color = other.val2Color;

    slicesNumber = other.slicesNumber;
    precNumber = other.precNumber;

    // Enumerators
    attribType = other.attribType;
    observerBy = other.observerBy;
    attribDataType = other.attribDataType;
    groupMode = other.groupMode;
    stdDev = other.stdDev;

    image = other.image;
    visible = other.visible;
    className = other.className;

    //---- Bkps ---------------------------------
    slicesNumberBkp = other.slicesNumberBkp;
    precNumberBkp = other.precNumberBkp;

    attribDataTypeBkp = other.attribDataTypeBkp;
    groupModeBkp = other.groupModeBkp;
    stdDevBkp = other.stdDevBkp;
    colorBarVecBkp = other.colorBarVecBkp;
    stdColorBarVecBkp = other.stdColorBarVecBkp;

    return *this;
}

Attributes::~Attributes()
{
#ifdef DEBUG_OBSERVER
    qDebug() << "Attributes::~Attributes()"; std::cout.flush();
#endif

    delete numericValues; numericValues = 0;
    delete textValues; textValues = 0;
    delete boolValues; boolValues = 0;
    delete legend; legend = 0;

#ifndef TME_BLACK_BOARD
    delete xs; xs = 0;
    delete ys; ys = 0;
#endif
	
	////@RAIAN
	//delete neighValues;
	////@RAIAN: END
}

void Attributes::setParentSubjectID(int subjID)
{
    parentSubjectID = subjID;
}

void Attributes::setName(const QString &name)
{
    attribName = name;
}

const QString & Attributes::getName() const
{
    return attribName;
}

void Attributes::setValues(QVector<double>* v)
{
    if (numericValues) delete numericValues;
    numericValues = v;
}

QVector<double>* Attributes::getNumericValues() const
{
    // Q_ASSERT_X(numericValues, "Attributes::getNumericValues()", "Vector of values is NULL");

    return numericValues;
}

void Attributes::setValues(QVector<QString>* s)
{
    if (textValues) delete textValues;
    textValues = s;
}

QVector<QString>* Attributes::getTextValues() const
{
    // Q_ASSERT_X(! textValues, "Attributes::getTextValues()", "Vector of values is NULL");
    return textValues;
}

void Attributes::setValues(QVector<bool>* b)
{
    boolValues = b;
}

QVector<bool>* Attributes::getBoolValues() const
{
    return boolValues;
}

void Attributes::addValue(int id, double &value)
{ 
    numericValues->push_back(value);

    // With bug: This follow code does not work for all subject (e.g. cell) at
    // chart observer

    // static int factor = id - numericValues->size();
    // if (id > numericValues->size())
    //    numericValues->push_back(value);
    // else
    //    numericValues->replace(id - factor, value);

#ifdef DEBUG_OBSERVER
    qDebug() << "factor: " << factor;
    qDebug() << "id: " << id;
    qDebug() << "numericValues->size(): " << numericValues->size();
#endif
}

void Attributes::addValue(int id, bool &value)
{ 
    boolValues->push_back(value);

    //static int factor = id - boolValues->size();

    //if (id > numericValues->size())
    //    boolValues->push_back(value);
    //else
    //    boolValues->replace(id - factor, value);
}

void Attributes::addValue(/*int id, */ const QString &value)
{
    textValues->push_back(value);

    // static int factor = id - textValues->size();

    // if (id > numericValues->size())
    //    textValues->push_back(value);
    // else
    //    textValues->replace(id - factor, value);
}

void Attributes::setLegend(QVector<ObsLegend>* l)
{
    legend = l;
}

QVector<ObsLegend>* Attributes::getLegend() const
{
    return legend;
}

void Attributes::addLegend(const ObsLegend &leg)
{
    legend->push_back(leg);
}

void Attributes::setMaxValue(double m)
{
    maxValue = m;
    if (maxValue - minValue == 0)
        maxValue++;
    val2Color = 255 / (maxValue - minValue);
}

double Attributes::getMaxValue() const
{
    return maxValue;
}

void Attributes::setMinValue(double m)
{
    minValue = m;
    if (maxValue - minValue == 0)
        maxValue++;

    val2Color = 255 / (maxValue - minValue);
}

double Attributes::getMinValue() const
{
    return minValue;
}

double Attributes::getVal2Color() const
{
    return val2Color;
}

void Attributes::setColorBar(const std::vector<ColorBar> &colorVec)
{
    colorBarVec = colorVec;
}

std::vector<ColorBar> Attributes::getColorBar() const
{
    return colorBarVec;
}

void Attributes::setStdColorBar(const std::vector<ColorBar> &colorVec)
{
    stdColorBarVec = colorVec;
}

std::vector<ColorBar> Attributes::getStdColorBar() const
{
    return stdColorBarVec;
}

void Attributes::setSlices(int slices)
{
    slicesNumber = slices;
}

int Attributes::getSlices() const
{
    return slicesNumber;
}

void Attributes::setPrecisionNumber(int prec)
{
    precNumber = prec;
}

int Attributes::getPrecisionNumber() const
{
    return precNumber;
}

void Attributes::setType(TypesOfSubjects type)
{
    attribType = type;
}

//TypesOfSubjects Attributes::getType() const
//{
//    return attribType;
//}

void Attributes::setObservedBy(TypesOfObservers type)
{
    observerBy = type;
}

TypesOfObservers Attributes::getObserverBy() const
{
    return observerBy;
}

void Attributes::setDataType(TypesOfData type)
{
    attribDataType = type;
}

//TypesOfData Attributes::getDataType() const
//{
//    return attribDataType;
//}

void Attributes::setGroupMode(GroupingMode type)
{
    groupMode = type;
}

//GroupingMode Attributes::getGroupMode() const
//{
//    return groupMode;
//}

void Attributes::setStdDeviation(StdDev type)
{
    stdDev = type;
}

StdDev Attributes::getStdDeviation() const
{
    return stdDev;
}

void Attributes::setValueList(const QStringList & values)
{
    valueList = values;
}

int Attributes::addValueListItem(const QString &value)
{
    if(! valueList.contains(value))
    {
        valueList.push_back(value);
        return valueList.size() - 1;
    }
    return valueList.indexOf(value);
}

QStringList * Attributes::getValueList() const
{
    return (QStringList *)&valueList;
}

void Attributes::setLabelList(const QStringList & labels)
{
    labelList = labels;
}

int Attributes::addLabelListItem(const QString &label)
{
    if(! labelList.contains(label))
    {
        labelList.push_back(label);
        return labelList.size() - 1;
    }
    return labelList.indexOf(label);
}

QStringList * Attributes::getLabelList() const
{
    return (QStringList *)&labelList;
}

void  Attributes::setImageSize(int width, int height)
{
    setImageSize(QSize(width, height));
}

void  Attributes::setImageSize(const QSize &size)
{
    if(attribType == TObsAgent || attribType == TObsSociety)
        image = QImage(size, QImage::Format_ARGB32);
    else
        image = QImage(size, QImage::Format_ARGB32_Premultiplied);
    image.fill(0);
}

QImage * Attributes::getImage() const
{
    return (QImage *) &image;
}

void Attributes::setVisible(bool visible)
{
    this->visible = visible;
}

void Attributes::setDirtyBit(bool dirty) 
{
    dirtyBit = dirty;
}

void Attributes::setXsValue(QVector<double>* xss)
{
    if (xs) delete xs;
    xs = xss;
}

void Attributes::setYsValue(QVector<double>* yss)
{
    if (ys) delete ys;
    ys = yss;
}

QVector<double>* Attributes::getXsValue() const
{
    return xs;
}

QVector<double>* Attributes::getYsValue() const
{
    return ys;
}

//@RAIAN
void Attributes::setValues(QVector<QMap<QString, QList<double> > >* n)
{
    qDebug() << "Deprecated!! 'Attributes::setValues()'";
	// neighValues = n;
}

QVector<QMap<QString, QList<double> > >* Attributes::getNeighValues()
{
    qDebug() << "Deprecated!! 'Attributes::getNeighValues()'";
	return 0; //neighValues;
}

void Attributes::addValue(QMap<QString, QList<double> > n)
{
    qDebug() << "Deprecated!! 'Attributes::addValues()'";
	// neighValues->push_back(n);
}

void Attributes::setWidth(double w)
{
	width = w;	
}

double Attributes::getWidth()
{
	return width;
}
//@RAIAN: END

void Attributes::makeBkp()
{
    slicesNumberBkp = slicesNumber;
    precNumberBkp = precNumber;

    attribDataTypeBkp = attribDataType;
    groupModeBkp = groupMode;
    stdDevBkp = stdDev;

    colorBarVecBkp = colorBarVec;
    //colorBarVec_bkp.clear();
    //for (int i = 0; i < (int)this->colorBarVec.size(); i++)
    //    colorBarVec_bkp.push_back(colorBarVec.at(i));

    stdColorBarVecBkp = stdColorBarVec;
    //colorBarVecB_bkp.clear();
    //for (int i = 0; i < (int)this->colorBarVecB.size(); i++)
    //    colorBarVecB_bkp.push_back(colorBarVecB.at(i));
}

void Attributes::restore()
{
    slicesNumber = slicesNumberBkp;
    precNumber = precNumberBkp;

    attribDataType = attribDataTypeBkp;
    groupMode = groupModeBkp;
    stdDev = stdDevBkp;

#ifdef DEBUG_OBSERVER
    qDebug() << "\n-------------- " << attribName;
    qDebug() << "colorBarVec.size():  " << colorBarVec.size();
    foreach(ColorBar cb, colorBarVec)
        qDebug() << cb.toString();

    qDebug() << "\ncolorBarVec_bkp.size():  " << colorBarVec_bkp.size();
    foreach(ColorBar cb, colorBarVec_bkp)
        qDebug() << cb.toString();

    qDebug() << "\ncolorBarVecB.size():  " << colorBarVecB.size();
    foreach(ColorBar cb, colorBarVecB)
        qDebug() << cb.toString();

    qDebug() << "\ncolorBarVecB_bkp.size():  " << colorBarVecB_bkp.size();
    foreach(ColorBar cb, colorBarVecB_bkp)
        qDebug() << cb.toString();

    qDebug() << "--------------\n";
#endif

    colorBarVec = colorBarVecBkp;
    stdColorBarVec = stdColorBarVecBkp;
}

void Attributes::clear()
{
#ifdef DEBUG_OBSERVER
    qDebug() << "Attributes::clear()";
#endif

    textValues->clear();
    boolValues->clear();
	// //@RAIAN
	// neighValues->clear();
	// //@RAIAN: END

#ifdef TME_BLACK_BOARD
    if ((observerBy != TObsDynamicGraphic) && (observerBy != TObsGraphic))
        numericValues->clear();
#else
    numericValues->clear();

    xs->clear();
    ys->clear();

    image.fill(0);
#endif
}

void Attributes::setFontSize(int size)
{
    font.setPointSize(size);
}

void Attributes::setFontFamily(const QString &family)
{
    font.setFamily(family);
}

void Attributes::setFont(const QFont &font)
{
    this->font = font;
}

const QFont & Attributes::getFont() const
{
    return font;
}

void Attributes::setSymbol(const QString &sym)
{
    symbol = sym;
}

const QString & Attributes::getSymbol() const
{
    return symbol;
}

void Attributes::setClassName(const QString &name)
{
    className = name;
}

const QString & Attributes::getClassName() const
{
    return className;
}

void Attributes::appendLastPos(double x, double y)
{
    qDebug() << "Deprecated!!! Attributes::appendLastPos(double x, double y)";

    //// QPair<QPointF, qreal> p;
    //QPointF point(x, y);
    //lastPos.append(QPair<QPointF, qreal>(point, 0));
}

double Attributes::getDirection(double x1, double y1)
{
    static const int CEILING = 3;

    double angle = 0.0;

    if(circularIdxVectorDirectionPos == CEILING)
        circularIdxVectorDirectionPos = 0;

    if(vectorDirectionPos.size() < CEILING)
    {
        if(vectorDirectionPos.size() == 0)
        {
            vectorDirectionPos.append(QPair<QPointF, double>(QPointF(x1, y1), 0.0));
    	}
    	else
    	{
            QPointF position = vectorDirectionPos.at(circularIdxVectorDirectionPos - 1).first;
            angle = calcAngleDirection(y1 - position.y(), x1 - position.x());
            vectorDirectionPos.append(qMakePair<QPointF, double>(QPointF(x1, y1), angle));
        }
    }
    else
    {
        QPointF newPoint(x1, y1);
        
        if(circularIdxVectorDirectionPos < vectorDirectionPos.size())
        {
            int last = circularIdxVectorDirectionPos - 1;
            last = (last < 0) ? CEILING - 1 : last;
            QPointF position = vectorDirectionPos.at(last).first;
        
            if(position == newPoint)
            {
                angle = vectorDirectionPos.at(last).second;
    		}
    		else
            {
                angle = calcAngleDirection(y1 - position.y(), x1 - position.x());
                vectorDirectionPos[circularIdxVectorDirectionPos].first = newPoint;
                vectorDirectionPos[circularIdxVectorDirectionPos].second = angle;
            }
        }
    }
    circularIdxVectorDirectionPos++;
    return angle;
}

//void Attributes::resetLastPos()
//{
//    // lastPos.clear();
//}

const QList<QPair<QPointF, double> >& Attributes::getLastPositions() const
{
    return vectorDirectionPos;
}

QDataStream & operator <<(QDataStream & out, const TerraMEObserver::Attributes & /* attr */)
{
    //// *xs, *ys;
    //out << attr.getNumericValues();
    //out << attr.getBoolValues();
    //out << attr.getTextValues();
    //out << attr.getLegend();

    //out << QVector<ColorBar>::fromStdVector(attr.getColorBar());
    //out << QVector<ColorBar>::fromStdVector(attr.getStdColorBar());

    //// out << attr.getLabelList();
    ////out << attr.getValueList();

    //out << attr.getName();
    //out << attr.getMaxValue();
    //out << attr.getMinValue();
    //out << attr.getVal2Color();

    //out << (qint8) attr.getSlices();
    //out << (qint8) attr.getPrecisionNumber();

    ////// Enumerators
    //out << (qint8) attr.getType();
    //out << (qint8) attr.getObserverBy();
    //out << (qint8) attr.getDataType();
    //out << (qint8) attr.getGroupMode();
    //out << (qint8) attr.getStdDeviation();

    //// out << attr.getImage();
    //out << (qint8) attr.getVisible();

    //out << attr.getFont();
    //out << attr.getSymbol();
    //out << attr.getClassName();

    //out << attr.getLastPositions();

    return out;
}

QDataStream & operator >>(QDataStream & in, TerraMEObserver::Attributes & /* attr */)
{
    return in;
}

QString Attributes::toString() const
{
    QString str("\n");

    str += "attrib: "		+ attribName + "\n\t";
    str += "attribDataType: "			+ QString::number(attribDataType)	+ "\n\t";
    str += "group: "		+ QString::number(groupMode)	+ "\n\t";
    str += "slices: "		+ QString::number(slicesNumber)	+ "\n\t";
    str += "precision: "	+ QString::number(precNumber)	+ "\n\t";
    str += "stdDeviation: " + QString::number(stdDev)	+ "\n\t";
    str += "maxValue: "		+ QString::number(maxValue)		+ "\n\t";
    str += "minValue: "		+ QString::number(minValue)		+ "\n\t";
    str += "val2Color: "	+ QString::number(val2Color)	+ "\n\t";
    str += "vectors size: \n\t\t";
    str += "numeric: "		+ QString::number(numericValues->size()) + "\n\t\t";
    str += "text: "			+ QString::number(textValues->size())	+ "\n\t\t";
    str += "bool: "			+ QString::number(boolValues->size())	+ "\n\t\t";
	////@RAIAN: neighborhood vector size
	//str += "neighborhood: " + QString::number(neighValues->size())	+ "\n\t\t";
	////@RAIAN: END
    str += "legend: "		+ QString::number(legend->size())		+ "\n\t\t";
    str += "colorBarVec.size(): "	+ QString::number((int)colorBarVec.size()) + "\n\t\t";

    for (int i = 0; i < (int)colorBarVec.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(colorBarVec.at(i).cor_.red_).arg(colorBarVec.at(i).cor_.green_).arg(colorBarVec.at(i).cor_.blue_);

    str +="\n\t\t";
    str += "colorBarVecB.size(): "	+ QString::number((int)stdColorBarVec.size()) + "\n\t\t";

    for (int i = 0; i < (int)stdColorBarVec.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(stdColorBarVec.at(i).cor_.red_).arg(stdColorBarVec.at(i).cor_.green_).arg(stdColorBarVec.at(i).cor_.blue_);

    str +="\n\t";
    str += "slicesNumber_bkp: "	+ QString::number(slicesNumberBkp) + "\n\t";
    str += "precNumber_bkp: "	+ QString::number(precNumberBkp) + "\n\t";
    str += "attribDataType_bkp: "	+ QString::number(attribDataTypeBkp) + "\n\t";
    str += "groupMode_bkp: "	+ QString::number(groupModeBkp) + "\n\t";
    str += "stdDev_bkp: "	+ QString::number(stdDevBkp) + "\n\t";
    str += "colorBarVec_bkp.size(): "	+ QString::number((int)colorBarVecBkp.size()) + "\n\t\t";

    for (int i = 0; i < (int)colorBarVecBkp.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(colorBarVecBkp.at(i).cor_.red_).arg(colorBarVecBkp.at(i).cor_.green_).arg(colorBarVecBkp.at(i).cor_.blue_);

    str +="\n\t";
    str += "colorBarVecB_bkp.size(): "	+ QString::number((int)stdColorBarVecBkp.size()) + "\n\t\t";

    for (int i = 0; i < (int)stdColorBarVecBkp.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(stdColorBarVecBkp.at(i).cor_.red_).arg(stdColorBarVecBkp.at(i).cor_.green_).arg(stdColorBarVecBkp.at(i).cor_.blue_);

    str +="\n\n";
    return str;
}

