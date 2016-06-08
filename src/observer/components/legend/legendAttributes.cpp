/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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
    if (this != &other)
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
    if (this == &other)
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
}

QColor ObsLegend::getColor() const
{
    return color;
}

void ObsLegend::setFrom(const QString & f)
{
    from = f;
    fromNumber = from.toDouble();
}

const QString & ObsLegend::getFrom() const
{
    return from;
}

double ObsLegend::getFromNumber() const
{
    return fromNumber;
}

void ObsLegend::setTo(const QString & t)
{
    to = t;
    toNumber = to.toDouble();
}

const QString & ObsLegend::getTo() const
{
    return to;
}

double ObsLegend::getToNumber() const
{
    return toNumber;
}

void ObsLegend::setLabel(const QString & l)
{
    label = l;
}

const QString & ObsLegend::getLabel() const
{
    return label;
}

void ObsLegend::setOccurrence(int o)
{
    occurrence = o;
}

int ObsLegend::getOcurrence() const
{
    return occurrence;
}

void ObsLegend::setIdxColor(unsigned int i)
{
    idxColor = i;
}

unsigned int ObsLegend::getIdxColor() const
{
    return idxColor;
}


//////////////////////////////////////////////////////////////////////////////////////////// ATTRIBUTES

Attributes::Attributes(QString name, int contSize, double width, double height) : attribName(name)
{
    containersSize = contSize;
    attribDataType = TObsUnknownData;
    attribType = TObsCell;
    className = "";

    numericValues = new QVector<double>();
    textValues = new QVector<QString>();
    boolValues = new QVector<bool>();
    xs = new QVector<double>();
    ys = new QVector<double>();

	//@RAIAN
        neighValues = new QVector<QMap<QString, QList<double> > >;
	//@RAIAN: FIM

    valueList = QStringList();
    labelList = QStringList();
    legend = new QVector<ObsLegend>();
    image = QImage(QSize(width, height), QImage::Format_ARGB32_Premultiplied);
    image.fill(0);
    visible = true;

    maxValue = 100;
    minValue = 0;
    val2Color = 255 /(maxValue - minValue);
    colorBarVec = vector<ColorBar>();
    stdColorBarVec = vector<ColorBar>();

    slicesNumber = 4; // posi??o 5 no comboBox
    groupMode = TObsEqualSteps;
    precNumber = 5; // posi??o 6 no comboBox
    stdDev = TObsNone;

    // Bkp
    slicesNumberBkp = -1;
    precNumberBkp = -1;

    attribDataTypeBkp = TObsUnknownData;
    groupModeBkp = TObsEqualSteps;
    stdDevBkp = TObsNone;
    colorBarVecBkp = vector<ColorBar>();
    stdColorBarVecBkp = vector<ColorBar>();
}

Attributes::Attributes(const Attributes &other)
{
    if (this != &other)
    {
        delete xs;
        delete ys;
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

		//@RAIAN
		neighValues = other.neighValues;
		//@RAIAN: FIM

        colorBarVec = colorBarVec;
        stdColorBarVec = stdColorBarVec;
        valueList = valueList;
        labelList = labelList;

        attribName = other.attribName;
        maxValue = other.maxValue;
        minValue = other.minValue;
        val2Color = other.val2Color;
        containersSize = other.containersSize;

        slicesNumber = other.slicesNumber;
        precNumber = other.precNumber;

        // Enumerators
        attribType = other.attribType;
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
		std::cout << "legendAttributes " << 1 << std::endl;
    }
}

Attributes & Attributes::operator=(const Attributes &other)
{
    if (this == &other)
        return *this;

    delete xs;
    delete ys;
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

	//@RAIAN
	neighValues = other.neighValues;
	//@RAIAN: FIM

    colorBarVec = colorBarVec;
    stdColorBarVec = stdColorBarVec;
    valueList = valueList;
    labelList = labelList;

    attribName = other.attribName;
    maxValue = other.maxValue;
    minValue = other.minValue;
    val2Color = other.val2Color;
    containersSize = other.containersSize;

    slicesNumber = other.slicesNumber;
    precNumber = other.precNumber;

    // Enumerators
    attribType = other.attribType;
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
    delete numericValues; numericValues = 0;
    delete textValues; textValues = 0;
    delete boolValues; boolValues = 0;
    delete legend; legend = 0;
    delete xs; xs = 0;
    delete ys; ys = 0;

	//@RAIAN
	delete neighValues;
	//@RAIAN: FIM
}

void Attributes::setName(QString name)
{
    attribName = name;
}

QString Attributes::getName()
{
    return attribName;
}

void Attributes::setValues(QVector<double>* v)
{
    numericValues = v;
}

QVector<double>* Attributes::getNumericValues()
{
    return numericValues;
}

void Attributes::setValues(QVector<QString>* s)
{
    textValues = s;
}

QVector<QString>* Attributes::getTextValues()
{
    return textValues;
}

void Attributes::setValues(QVector<bool>* b)
{
    boolValues = b;
}

QVector<bool>* Attributes::getBoolValues()
{
    return boolValues;
}

void Attributes::addValue(double num)
{
    //if (numericValues->size() == containersSize)
    //    numericValues->clear();
    numericValues->push_back(num);
}

void Attributes::addValue(bool b)
{
    //if (boolValues->size() == containersSize)
    //    boolValues->clear();
    boolValues->push_back(b);
}

void Attributes::addValue(QString txt)
{
    //if (textValues->size() == containersSize)
    //    textValues->clear();
    if (txt.contains("Lua-Address"))
        return;

    textValues->push_back(txt);
}

void Attributes::setLegend(QVector<ObsLegend>* l)
{
    legend = l;
}

QVector<ObsLegend>* Attributes::getLegend()
{
    return legend;
}

void Attributes::addLegend(ObsLegend leg)
{
    legend->push_back(leg);
}

void Attributes::setMaxValue(double m)
{
    maxValue = m;
    if (maxValue - minValue == 0)
        maxValue++;
    val2Color = 255 /(maxValue - minValue);
}

double Attributes::getMaxValue()
{
    return maxValue;
}

void Attributes::setMinValue(double m)
{
    minValue = m;
    if (maxValue - minValue == 0)
        maxValue++;

    val2Color = 255 /(maxValue - minValue);
}

double Attributes::getMinValue()
{
    return minValue;
}

double Attributes::getVal2Color()
{
    return val2Color;
}

void Attributes::setColorBar(vector<ColorBar> colorVec)
{
    colorBarVec = colorVec;
}

vector<ColorBar> Attributes::getColorBar()
{
    return colorBarVec;
}

void Attributes::setStdColorBar(vector<ColorBar> colorVec)
{
    stdColorBarVec = colorVec;
}

vector<ColorBar> Attributes::getStdColorBar()
{
    return stdColorBarVec;
}

void Attributes::setSlices(int slices)
{
    slicesNumber = slices;
}

int Attributes::getSlices()
{
    return slicesNumber;
}

void Attributes::setPrecisionNumber(int prec)
{
    precNumber = prec;
}

int Attributes::getPrecisionNumber()
{
    return precNumber;
}

void Attributes::setType(TypesOfSubjects type)
{
    attribType = type;
}

TypesOfSubjects Attributes::getType()
{
    return attribType;
}

void Attributes::setDataType(TypesOfData type)
{
    attribDataType = type;
}

TypesOfData Attributes::getDataType()
{
    return attribDataType;
}

void Attributes::setGroupMode(GroupingMode type)
{
    groupMode = type;
}

GroupingMode Attributes::getGroupMode()
{
    return groupMode;
}

void Attributes::setStdDeviation(StdDev type)
{
    stdDev = type;
}

StdDev Attributes::getStdDeviation()
{
    return stdDev;
}

void Attributes::setValueList(const QStringList & values)
{
    valueList = values;
}

int Attributes::addValueListItem(QString value)
{
    if (!valueList.contains(value))
    {
        valueList.push_back(value);
        return valueList.size() - 1;
    }
    return valueList.indexOf(value);
}

QStringList & Attributes::getValueList()
{
    return valueList;
}

void Attributes::setLabelList(const QStringList & labels)
{
    labelList = labels;
}

int Attributes::addLabelListItem(QString label)
{
    if (!labelList.contains(label))
    {
        labelList.push_back(label);
        return labelList.size() - 1;
    }
    return labelList.indexOf(label);
}

QStringList & Attributes::getLabelList()
{
    return labelList;
}

void  Attributes::setImageSize(int w, int h)
{
    image = QImage(QSize(w, h),
                    QImage::Format_ARGB32_Premultiplied);
}

QImage * Attributes::getImage()
{
    return(QImage *) &image;
}

void Attributes::setVisible(bool visible)
{
    this->visible = visible;
}

bool Attributes::getVisible()
{
    return visible;
}

void Attributes::setXsValue(QVector<double>* xss)
{
    // delete xs;
    xs = xss;
}

void Attributes::setYsValue(QVector<double>* yss)
{
    // delete ys;
    ys = yss;
}

QVector<double>* Attributes::getXsValue()
{
    return xs;
}

QVector<double>* Attributes::getYsValue()
{
    return ys;
}

//@RAIAN
void Attributes::setValues(QVector<QMap<QString, QList<double> > >* n)
{
	neighValues = n;
}

QVector<QMap<QString, QList<double> > >* Attributes::getNeighValues()
{
	return neighValues;
}

void Attributes::addValue(QMap<QString, QList<double> > n)
{
	neighValues->push_back(n);
}

void Attributes::setWidth(double w)
{
	width = w;
}

double Attributes::getWidth()
{
	return width;
}
//@RAIAN: FIM

void Attributes::makeBkp()
{
    slicesNumberBkp = slicesNumber;
    precNumberBkp = precNumber;

    attribDataTypeBkp = attribDataType;
    groupModeBkp = groupMode;
    stdDevBkp = stdDev;

    colorBarVecBkp = colorBarVec;
    //colorBarVec_bkp.clear();
    //for (int i = 0; i <(int)this->colorBarVec.size(); i++)
    //    colorBarVec_bkp.push_back(colorBarVec.at(i));

    stdColorBarVecBkp = stdColorBarVec;
    //colorBarVecB_bkp.clear();
    //for (int i = 0; i <(int)this->colorBarVecB.size(); i++)
    //    colorBarVecB_bkp.push_back(colorBarVecB.at(i));
}

void Attributes::restore()
{
    slicesNumber = slicesNumberBkp;
    precNumber = precNumberBkp;

    attribDataType = attribDataTypeBkp;
    groupMode = groupModeBkp;
    stdDev = stdDevBkp;

    colorBarVec = colorBarVecBkp;
    stdColorBarVec = stdColorBarVecBkp;
}

void Attributes::setContainersSize(int size)
{
    containersSize = size;
}

void Attributes::clear()
{
    textValues->clear();
    numericValues->clear();
    boolValues->clear();
	neighValues->clear();
    image.fill(0);

    xs->clear();
    ys->clear();
}

void Attributes::setFontSize(int size)
{
    font.setPointSize((size < 1 ? 1 : size));
}

void Attributes::setFontFamily(const QString &family)
{
    font.setFamily(family);
}

void Attributes::setFont(const QFont &font)
{
    this->font = font;
}

const QFont & Attributes::getFont()
{
    return font;
}

void Attributes::setSymbol(const QString &sym)
{
    symbol = sym;
}

const QString & Attributes::getSymbol()
{
    return symbol;
}

void Attributes::setClassName(const QString &name)
{
    className = name;
}

const QString & Attributes::getClassName()
{
    return className;
}

void Attributes::appendLastPos(double x, double y)
{
    // QPair<QPointF, qreal> p;
    QPointF point(x, y);
    lastPos.append(QPair<QPointF, qreal>(point, 0));
}

qreal Attributes::getDirection(int pos, double x1, double y1)
{
    int size = lastPos.size();
    QPointF point;

    if (pos >= size)
    {
        point = QPointF(x1, y1);
        lastPos.append(QPair<QPointF, qreal>(point, 0));
        return 0;
    }

    point = lastPos.at(pos).first;
    QPointF newPoint = QPointF(x1, y1);

    if (point == newPoint)
        return lastPos.at(pos).second;

    lastPos[pos].first = newPoint;

    double num = y1 - point.y();
    double den = x1 - point.x();

    qreal angle = 0;

    if ((den != 0) && (num != 0))
    {
        angle = atan(num / den) * 180 / PI;
    }
    else
    {
        if ((num == 0) && (den != 0))     // movimento na horizontal
            angle =(den > 0) ? 0 : 180;
        else
            if ((den == 0) && (num != 0)) // movimento na vertical
                angle =(num > 0) ? 90 : 270;

        lastPos[pos].second = angle;
        return angle;
    }

    if ((den < 0) && (num < 0))
        angle = 180 + angle;
    else
        if ((den < 0) && (num > 0))
            angle = 90 - angle;

    lastPos[pos].second = angle;
    return angle;
}

//void Attributes::resetLastPos()
//{
//    // lastPos.clear();
//}



QString Attributes::toString()
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
    str += "numeric: "		+ QString::number(numericValues->size())+ "\n\t\t";
    str += "text: "			+ QString::number(textValues->size())	+ "\n\t\t";
    str += "bool: "			+ QString::number(boolValues->size())	+ "\n\t\t";
	//@RAIAN: tamanho do vetor de vizinhancas
	str += "neighborhood: " + QString::number(neighValues->size())	+ "\n\t\t";
	//@RAIAN: FIM
    str += "legend: "		+ QString::number(legend->size())		+ "\n\t\t";
    str += "colorBarVec.size(): "	+ QString::number((int)colorBarVec.size()) + "\n\t\t";

    for (int i = 0; i <(int)colorBarVec.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(colorBarVec.at(i).cor_.red_).arg(colorBarVec.at(i).cor_.green_).arg(colorBarVec.at(i).cor_.blue_);

    str +="\n\t\t";
    str += "colorBarVecB.size(): "	+ QString::number((int)stdColorBarVec.size()) + "\n\t\t";

    for (int i = 0; i <(int)stdColorBarVec.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(stdColorBarVec.at(i).cor_.red_).arg(stdColorBarVec.at(i).cor_.green_).arg(stdColorBarVec.at(i).cor_.blue_);

    str +="\n\t";
    str += "slicesNumber_bkp: "	+ QString::number(slicesNumberBkp) + "\n\t";
    str += "precNumber_bkp: "	+ QString::number(precNumberBkp) + "\n\t";
    str += "attribDataType_bkp: "	+ QString::number(attribDataTypeBkp) + "\n\t";
    str += "groupMode_bkp: "	+ QString::number(groupModeBkp) + "\n\t";
    str += "stdDev_bkp: "	+ QString::number(stdDevBkp) + "\n\t";
    str += "colorBarVec_bkp.size(): "	+ QString::number((int)colorBarVecBkp.size()) + "\n\t\t";

    for (int i = 0; i <(int)colorBarVecBkp.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(colorBarVecBkp.at(i).cor_.red_).arg(colorBarVecBkp.at(i).cor_.green_).arg(colorBarVecBkp.at(i).cor_.blue_);

    str +="\n\t";
    str += "colorBarVecB_bkp.size(): "	+ QString::number((int)stdColorBarVecBkp.size()) + "\n\t\t";

    for (int i = 0; i <(int)stdColorBarVecBkp.size(); i++)
        str += QString("(%1, %2, %3)\n\t\t").arg(stdColorBarVecBkp.at(i).cor_.red_).arg(stdColorBarVecBkp.at(i).cor_.green_).arg(stdColorBarVecBkp.at(i).cor_.blue_);

	std::cout << "legendAttributes " << 3 << std::endl;
    str +="\n\n";
    return str;
}


