/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

#ifndef ATTRIBUTES
#define ATTRIBUTES

#include <QtCore/QString>
#include <QtCore/QVector>
#include <QImage>
#include <QFont>
#include <QPair>

#include "../../observer.h"
#include "legendColorBar.h"

namespace TerraMEObserver {

/**
 * \brief Item of observer legend.
 * This object represents each item that composes the observer
 * legend for the ObserverMap, ObserverImage and ObserverStateMachine
 * \author Antonio Jos? da Cunha Rodrigues
 * \file legendAttributes.h
 */
class ObsLegend
{
public:
    /**
     * Default constructor
     */
    ObsLegend();

    /**
     * Copy constructor
     * \param other reference to an other ObsLegend
     */
    ObsLegend(const ObsLegend &other);

    /**
     * Destructor
     */
    virtual ~ObsLegend();

    /**
     * Assgin operator for ObsLegend object
     * \param other references for another ObsLegend
     * \return reference to this ObsLegend
     */
    ObsLegend & operator=(const ObsLegend &other);

    /**
     * Sets the ObsLegend color
     * \param color reference to this object
     * \see QColor
     */
    void setColor(const QColor & color);

    /**
     * Sets the color
     * \param r integer value for the color component red
     * \param g integer value for the color component gree
     * \param b integer value for the color component blue
     * \param a integer value for the color component alfa
     * \see QColor
     */
    void setColor(int r, int g, int b, int a = 255);

    /**
     * Gets the color
     */
    QColor getColor() const;

    /**
     * Sets the minimum value
     * \param f minimum value
     * \see QString
     */
    void setFrom(const QString & f);

    /**
     * Gets the minimum value
     */
    const QString & getFrom() const;

    /// Gets the minimum value in numeric format
    double getFromNumber() const;

    /**
     * Sets the maximum value
     * \param t maximum value
     * \see QString
     */
    void setTo(const QString & t);

    /**
     * Gets the maximum value
     */
    const QString & getTo() const;

    /**
     * Gets the maximum value in numeric format
     */
    double getToNumber() const;
    
    /**
     * Sets the label for this object
     * \param l label value for this object
     * \see QString
     */
    void setLabel(const QString & l);
    
    /**
     * Gets the label of this object
     */
    const QString & getLabel() const;

    /**
     * Sets the occurrence of it found in the simulation
     */
    void setOccurrence(int o);

    /**
     * Gets the occurrence in the simulation
     */
    int getOcurrence() const;

    /**
     * Sets the index of color in the LegendWindow::vector<TeColor>
     * \param i unsigned integer that indexing a color
     */
    void setIdxColor(unsigned int i);
    
    /**
     * Gets the index of color
     */
    unsigned int getIdxColor() const;

private:
    QColor color;
    QString from;
    QString to;
    QString label;
    int occurrence;
    unsigned int idxColor; // indice da cor no vetor de cores

    double fromNumber;
    double toNumber;
};

/**
 * \file legendAttributes.h
 * \brief Attributes of observation in the spacial observers
 * \author Antonio Jos? da Cunha Rodrigues
 */
class Attributes
{
public:
    /**
     * Attriubtes Contructor
     * \param name attribute name
     * \param containersSize deprecated parameter
     * \param width of cellular space
     * \param height of cellular space
     */
    Attributes(QString name, int containersSize, double width, double height);

    /**
     * Destructor
     */
    virtual ~Attributes();

    /**
     * Sets the attribute name
     * \param name for this attribute
     * \see QString
     */
    void setName(QString name);

    /**
     * Gets the attribute name
     */
    QString getName() ;

    /**
     * Sets a pointer to a vector of double
     * \param v a pointer to a vector
     * \see QVector
     */
    void setValues( QVector<double>* v);

    /**
     * Gets the vector of double
     */
    QVector<double>* getNumericValues();

    /**
     * Sets a pointer to a vector of QString
     * \param s a pointer to a QString vector
     * \see QVector, \see QString
     */
    void setValues( QVector<QString>* s);

    /**
     * Gets the vector of QString
    */
    QVector<QString>* getTextValues();

    /**
     * Sets a pointer to a vector of boolean
     * \param b a pointer to a boolean vector
     * \see QVector, \see QString
     */
    void setValues( QVector<bool>* b);

    /**
     * Gets the vector of boolean
    */
    QVector<bool>* getBoolValues();

    /**
     * Adds a numeric value for this attribute
     * \param num a double value
     */
    void addValue(double num);

    /**
     * Adds a boolean value for this attribute
     * \param b a boolean value
     */
    void addValue(bool b);

    /**
     * Adds a string value for this attribute
     * \param txt a string value
     * \see QString
     */
    void addValue(QString txt);

    /**
    * Sets a legend vector to this attribute
    * \param l a pointer to a ObsLegend QVector
    * \see QVector
    */
    void setLegend( QVector<ObsLegend>* l);

    /**
     * Gets the legend to this attribute
     */
    QVector<ObsLegend>* getLegend();

    /**
     * Adds a legend value to this attribute
     * \param leg a legend of a attribute
     * \see ObsLegend
     */
    void addLegend(ObsLegend leg);

    /**
     * Sets the maximum value
     * \param m maximum value to a attribute
     */
    void setMaxValue(double m);

    /**
     * Gets maximum value
     */
    double getMaxValue();

    /**
     * Sets the minimum value
     * \param m minimum value to a attribute
     */
    void setMinValue(double m);

    /**
     * Gets the minimum value
    */
    double getMinValue();

    /**
     * Converts a value to its corresponding color
    */
    double getVal2Color();

    /**
     * Sets the colorBar vector
     * \param colorVec a vector of colorBar
    */
    void setColorBar(vector<ColorBar> colorVec);

    /**
     * Gets the color bar vector
     */
    vector<ColorBar> getColorBar();

    /**
     * Set the standard deviation color bar vector
     * \param colorVec a vector of stdColorBar
     */
    void setStdColorBar(vector<ColorBar> colorVec);

    /**
     * Gets the standard deviation color bar vector
     */
    vector<ColorBar> getStdColorBar();

    /**
     * Sets the number of legend slices
     * \param slices the number of slices
     */
    void setSlices(int slices);

    /**
     * Gets the number of legend slices
     */
    int getSlices();

    /**
     * Sets the precision number
     * \param prec the precision number
     */
    void setPrecisionNumber(int prec);

    /**
     *  Gets the precision number
     */
    int getPrecisionNumber();

    /**
     * Sets which the type of subject this attribute belongs
     * \param type the type of subject
     * \see TypesOfSubjects
     */
    void setType(TypesOfSubjects type);

    /**
     * Gets the type of subject
     */
    TypesOfSubjects getType();

    /**
     * Sets which the type of data is this attribute
     * \param type the type of data
     * \see TypeOfData
     */
    void setDataType(TypesOfData type);

    /**
     * Gets the type of data
     */
    TypesOfData getDataType();

    /**
     * Sets which the mode of grouping
     * \param type the type of grouping mode
     * \see GroupingMode
     */
    void setGroupMode(GroupingMode type);

    /**
     * Gets the mode of grouping
     */
    GroupingMode getGroupMode();

    /**
     * Sets the type of standard deviation
     * \param type the type of standard deviation
     * \see StdDev
     */
    void setStdDeviation(StdDev type);

    /**
     * Gets the type of standard deviation
     */
    StdDev getStdDeviation();

    /**
     * Sets the list of values
     * \param values a references for a QStringList
     * \see QStringList
     */
    void setValueList(const QStringList & values);

    /**
     * Adds a value into the values list and return its index
     * \param value a QString value
     * \return index of the value
     * \see QString
     */
    int addValueListItem(QString value);

    /**
     * Gets the values list
     */
    QStringList & getValueList();

    /**
     * Sets the list of labels
     * \param labels a reference for a labels list
     * \see QStringList
     */
    void setLabelList(const QStringList & labels);
    
    /**
     * Adds a label into the labels list
     * \param value a QString label
     * \return the index of the label
     * \see QString
     */
    int addLabelListItem(QString value);
    
    /**
     * Gets the labels list
     */
    QStringList & getLabelList();

    /**
    * Converts the attributes to a QString format
     */
    QString toString();

    /**
     * Restores the attributes changes
     */
    void restore();

    /**
     * Makes the attribute back up
     */
    void makeBkp();

    /**
     * Sets the attribute image size and recreate it
     * in this new size
     * \param w the width of the image
     * \param h the height of the image
     */
    void setImageSize(int w, int h);

    /**
     * Gets the pointer of attribute image
     */
    QImage * getImage();

    /**
     * Sets the visibility of the attribute
     * \param visible boolean, if \a true shows the attribute.
     * Otherwise, hides it.
     */
    void setVisible(bool visible);
    
    /**
     * Gets the visibility
     */
    bool getVisible();

    /**
     * Sets the x axis values
     * \param xss a pointer for a double QVector
     * \see QVector
     */
    void setXsValue(QVector<double> *xss);

    /**
     * Sets the y axis values
     * \param yss a pointer for a double QVector
     * \see QVector
     */
    void setYsValue(QVector<double> *yss);

    /**
     * Gets the vector of x axis values
     */
    QVector<double>* getXsValue();

    /**
     * Gets the vector of y axis values
     */
    QVector<double>* getYsValue();

    /**
     * \deprecated Allocates the size of the vectors
     */
    void setContainersSize(int );

    /**
     * Cleans all data structure
     */
    void clear();

    /**
     * Sets a font size that will be used to represent this
     * attribute in the map or image observer. Only used for an
     * Agent attribute.
     * \param size of the font
     */
    void setFontSize(int size);

    /**
     * Sets a font family that will be used to represent this
     * attribute in the map or image observer. Only used for an
     * Agent attribute.
     * \param family name of the font
     * \see QString
     */
    void setFontFamily(const QString &family);
    
    /**
     * Sets a font
     * Only used for an Agent attribute.
     * \param font a reference for a QFont object
     * \see QFont
     */
    void setFont(const QFont &font);
    
    /**
     * Gets the font object
     */
    const QFont & getFont();

    /**
     * Sets a symbol that will be used to represent
     * this attribute in the map, image observer.
     * Only used for an Agent attribute.
     * \param sym a symbol for the attribute
     * \see QString
     */
    void setSymbol(const QString &sym);

    /**
     * Gets the symbol
     */
    const QString & getSymbol();

    /**
     * Sets the class name for the attribute
     * Only for an Agent attribue
     * \param name of class
     * \see QString
     */
    void setClassName(const QString &name);
    
    /**
     * Gets the class name
     */
    const QString & getClassName();

    /**
     * Appends the last position for this attribute in the map
     * \param x axis position
     * \param y axis position
     */
    void appendLastPos(double x, double y);
    
    /**
     * Gets the direction of the attribute using the
     * coordanate (x,y) of the map
     * \param pos position of the attribute in the values list
     * \param x axis position
     * \param y axis position
     * \return angle of direction
     */
    qreal getDirection(int pos, double x, double y);
    
		/// Gets neighborhood values
		/// \author Raian Vargas Maretto
                QVector<QMap<QString, QList<double> > >* getNeighValues();

		/// Sets neighborhood values
		/// \author Raian Vargas Maretto
                void setValues( QVector<QMap<QString, QList<double> > >* n);

		/// Adds a neighborhood to the attribute 
		/// \author Raian Vargas Maretto
                void addValue(QMap<QString, QList<double> > n);

		/// Sets the width of the line used to draw the Neighborhood
		/// \author Raian Vargas Maretto
		void setWidth(double w);

		/// Gets the width of the line used to draw the Neighborhood
		/// \author Raian Vargas Maretto
		double getWidth();
private:
    /**
     * Copy constructor
     */
    Attributes(const Attributes &);
    
    /**
     * Assign operator
     */
    Attributes & operator=(const Attributes &);

    QVector<double> *xs, *ys;
    QVector<double> *numericValues; //modificar para template
    QVector<QString> *textValues; //modificar para template
    QVector<bool> *boolValues; //modificar para template
    QVector<ObsLegend> *legend;
    vector<ColorBar> colorBarVec;
    vector<ColorBar> stdColorBarVec;
    QStringList labelList, valueList;
	QVector<QMap<QString, QList<double> > > *neighValues;
	double width; 

    QString attribName;
    double maxValue;
    double minValue;
    double val2Color;	//convers?o do valor observado em cor
    int containersSize;  // tamanho dos vetores

    // indice nos comboBoxes
    int slicesNumber;
    int precNumber;

    // Enumerators
    TypesOfSubjects attribType;
    TypesOfData attribDataType;
    GroupingMode groupMode;
    StdDev stdDev;

    QImage image;
    bool visible;

    QFont font;
    QString symbol, className;

    //---- Bkps ---------------------------------
    int slicesNumberBkp;
    int precNumberBkp;

    TypesOfData attribDataTypeBkp;
    GroupingMode groupModeBkp;
    StdDev stdDevBkp;
    vector<ColorBar> colorBarVecBkp;
    vector<ColorBar> stdColorBarVecBkp;


    QList<QPair<QPointF, qreal> > lastPos;
};

}

#endif

