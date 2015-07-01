/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
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

#ifndef LEGEND_WINDOW_OBSERVERMAP
#define LEGEND_WINDOW_OBSERVERMAP

#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QComboBox>
#include <QtGui/QDialog>
#include <QtGui/QGridLayout>
#include <QtGui/QGroupBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QLabel>
#include <QtGui/QPushButton>
#include <QtGui/QSpacerItem>
#include <QtGui/QVBoxLayout>
#include <QtCore/QAbstractItemModel>
#include <QtGui/QAbstractItemView>
#include <QtGui/QItemSelectionModel>
#include <QtGui/QStandardItemModel>
#include <QtGui/QTableWidget>
#include <QtGui/QColor>
#include <QtCore/QString>

#include <set>

#include "legendColorBar.h"
#include "../../terrameIncludes.h"
#include "legendAttributes.h"

extern "C"
{
#include <lua.h>
}
#include "luna.h"

namespace TerraMEObserver {


/**
 * \brief User interface for legend
 * \see QDialog
 * \author Antonio José da Cunha Rodrigues
 * \file legendWindow.h
 */
class LegendWindow : public QDialog
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QWidget
     */
    LegendWindow(QWidget *parent = 0);
    
    /**
     * Destructor
     */
    virtual ~LegendWindow();

    /**
     * Sets the hash of attributes under observation
     * \param mapAttributes a pointer to a QHash of attributes
     * \see Attributes
     * \see QHash, \see QString
     */
    void setValues(QHash<QString, Attributes*> *mapAttributes);

    /**
     * Makes the legend for every attribute
     */
    void makeLegend();

    /**
     * Build an image of size \a size filled with color \a color
     * \param color a reference to a QColor
     * \param size the size of the image
     * \return a QPixmap image
     * \see QPixmap, \see QSize
     */
    QPixmap color2Pixmap(const QColor &color, const QSize size = ICON_SIZE);
	
	//@RAIAN
		/// \author Raian Vargas Maretto
		QPixmap color2PixmapLine(const QColor &color, double width, const QSize size = ICON_SIZE);
	//@RAIAN: FIM

public slots:
    /** 
     * Executes and shows in modal way the window
     */
    int exec();

    /** 
     * Closes the window without consist any change
     */
    void rejectWindow();

    /** 
     * Treats of any change in the \a slice comboBox
     */
    void slicesComboBox_activated( const QString & );

    /** 
     * Treats of any change in the \a attributes comboBox
     */
    void attributesComboBox_activated(const QString &);

    /** 
     * Treats of any change in the \a stdDev comboBox
     */
    void stdDevComboBox_activated(const QString &);

    /** 
     * Ttreatst of any change in the \a precision comboBox
     */
    void precisionComboBox_activated(const QString &);

    //    void importFromThemeComboBox_activated(const QString &);
    //    void importFromViewComboBox_activated(const QString &);

    /** 
     * Treats of any change in the \a function comboBox
     */
    void functionComboBox_activated(int);
    //    void chrononComboBox_activated(int);
    //    void loadNamesComboBox_activated(int);

    /** 
     * Treats of any change in the \a grouping \a mode comboBox
     */
    void groupingModeComboBox_activated(int);

    /** 
     * Treats the clicked in the \a ok button
     */
    void okPushButton_clicked();
    //    void helpPushButton_clicked();

    /** 
     * Treats the clicked in the \a invertColor button
     */
    void invertColorsPushButton_clicked();

    /** 
     * Treats the clicked in the \a equalSpace button
     */
    void equalSpacePushButton_clicked();

    /** 
     * Treats the clicked in the \a clearColor button
     */
    void clearColorsPushButton_clicked();

    /** 
     * Treats the clicked in the \a apply button
     */
    void applyPushButton_clicked();

    //    void importPushButton_clicked();
    //    void saveColorPushButton_clicked();
    //    void importCheckBox_toggled(bool);

    /** 
     * Treats the change in the colors of colorBar objects
     */
    void colorChangedSlot();

    /** 
     * Treats the double clicked in the legend table
     */
    void legendTable_doubleClicked(int, int);

private slots:
    /** 
     * Identify any change in the window
     */
    void valueChanged();

private:
    /**
     * Sets up the user interface
     */
    void setupUi();

    /**
     * Sets up the comboBoxes
     */
    void setupComboBoxes();

    /**
     * Creates the table view
     * \param rowsNum number of rows that it will be show
     */
    void createView(int rowsNum);

    /**
     * Translates the user interface
     */
    void retranslateUi();

    /**
     * Connects the slots with their signals
     * \param on boolean, if \a true connects. Otherwise, disconnects the slots
     */
    void connectSlots(bool on);

    /**
     * Sets and adjust columns of table
     */
    void setAndAdjustTableColumns();

    /**
     * Counts the elements number by legend slices
     */
    void countElementsBySlices();

    /**
     * Creates a color vector
     */
    void createColorVector();

    /**
     * Inserts the attributes under observation in the attributes comboBox
     */
    void insertAttributesCombo();

    /**
     * Groups the attribute values ??according to the grouping mode
     * defined in the legend
     * \param attrib a pointer to an attribute
     * \see Attributes
     */
    void groupingAttribute(Attributes *attrib);

    /**
     * Groups attribute values by equal steps
     * \param fix correction for every slice of the legend
     * \param attrib the attribute under observation
     */
    void groupByEqualStep(double fix, Attributes *attrib);

    /**
     * Groups attribute values by quantil
     * \param fix correction for every slice of the legend
     * \param attrib the attribute under observation
     */
    void groupByQuantil(double fix, Attributes *attrib);

    /**
     * Groups attribute values by standard deviation
     * \param fix correction for every slice of the legend
     * \param attrib the attribute under observation
     */
    void groupByStdDeviation(double fix, Attributes *attrib);

    /**
     * Groups attribute values by unique value
     * \param fix correction for every slice of the legend
     * \param attrib the attribute under observation
     */
    void groupByUniqueValue(double fix, Attributes *attrib);

    /**
     * Saves the attributes under observation in the legend.tol file
     */
    void commitFile();

    /**
     * Makes a back up for all attributes
     */
    void makeAttribsBkp();

    /**
     * Restores any changes by the attribute name \a attrName
     * \param attrName reference to the attribute name
     * \see QString
     */
    void rollbackChanges(const QString &attrName);

    /**
     * Converts a enumerator type to a string
     * \param name the name of enumerator
     * \param type the type of enumerator item
     * \see TypesOfData, \see GroupingMode, \see StdDev
     */
    QString enumToString(QString name, int type);

    /**
     * Converts a enumerator item to a string
     * \param type the item of enumerator TypeOfData
     * \see TypesOfData
     */
    QString typesOfDataToString(int item);

    /**
     * Converts a enumerator item to a string
     * \param type the item of enumerator GroupingMode
     * \see GroupingMode
     */
    QString groupingToString(int item);

    /**
     * Converts a enumerator item to a string
     * \param type the item of enumerator StdDev
     * \see StdDev
     */
    QString stdDevToString(int item);



    QGridLayout *gridLayout, *gridLayout1;
    QGridLayout *gridLayout2, *gridLayout3;

    QHBoxLayout *hboxlayout_1, *hboxlayout_2;
    QHBoxLayout *hboxlayout_3;

    QVBoxLayout *vboxlayout_1;

    QGroupBox *groupingParamsGroupBox;
    QGroupBox *loadGroupBox, *colorGroupBox;

    QSpacerItem *spacer13, *spacer14_2;
    QSpacerItem *spacer16, *spacer14;
    QSpacerItem *spacer22, *spacer23;

    QLabel *attributeTextLabel;
    QLabel *groupingModeTextLabel;
    QLabel *precisionTextLabel;
    QLabel *slicesTextLabel;
    QLabel *stdDevTextLabel;
    QLabel *functionTextLabel;
    QLabel *chrononTextLabel;
    
    QComboBox *groupingModeComboBox;
    QComboBox *slicesComboBox;
    QComboBox *precisionComboBox;
    QComboBox *chrononComboBox;
    QComboBox *functionComboBox;
    QComboBox *stdDevComboBox;
    QComboBox *attributesComboBox;
    QComboBox *loadNamesComboBox;

    QPushButton *clearColorsPushButton;
    QPushButton *invertColorsPushButton;
    QPushButton *equalSpacePushButton;
    QPushButton *saveColorPushButton;
    QPushButton *helpPushButton;
    QPushButton *cancelPushButton;
    QPushButton *okPushButton;
    QPushButton *applyPushButton;

    TeQtColorBar *frameTeQtStdColorBar;
    TeQtColorBar *frameTeQtColorBar;
    //TeQtBigTable *legendTable;

    bool invertColor, attrValuesChanged;
    int rows;

    // QAbstractItemModel *model;
    QTableWidget *legendTable;
    QHash<QString, Attributes*> *mapAttributes;
    std::vector<TeColor> *teColorVec;

    //double minValue;
    //double maxValue;

    QString attributesActive;
};

}

#endif // LEGEND_WINDOW_OBSERVERMAP
