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

#ifndef OBSERVER_MAP_H
#define OBSERVER_MAP_H

#include <QDialog>
#include <QString>
#include <QTextEdit>
#include <QStringList>

#include <QPainter>
#include <QTreeWidget>
#include <QTreeWidgetItem>

extern "C"
{
#include <lua.h>
}
#include "luna.h"

class QLabel;
class QToolButton;
class QSplitter;
class QHBoxLayout;
class QSpacerItem;
class QVBoxLayout;

#include "../observerInterf.h"
#include "../components/legend/legendWindow.h"
#include "../components/painter/painterWidget.h"

namespace TerraMEObserver {

class Decoder;

/**
 * \brief Spatial visualization for cells and saved in the user interface
 * \see ObserverInterf
 * \see QDialog
 * \author Antonio Jos? da Cunha Rodrigues
 * \file observerMap.h
*/
class ObserverMap :  public QDialog, public ObserverInterf
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QWidget
     */
    ObserverMap(QWidget *parent = 0);

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \see Subject
     */
    ObserverMap(Subject *subj);

    /**
     * Destructor
     */
    virtual ~ObserverMap();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &state);

    /**
     * Sets the attributes for observation in the observer
     * \param attribs a list of attributes under observation
     * \param legKeys a list of legend keys
     * \param legAttribs a list of legend attributes
     * \see QStringList
     */
    void setAttributes(QStringList &attribs, QStringList legKeys,
                       QStringList legAttribs);

    /**
     * \copydoc Observer::getAttributes
     */
    QStringList getAttributes();

    /**
     * \copydoc Observer::getType
     */
    const TypesOfObservers getType();

    /**
     * Sets the cellular space size
     * \param width the width of cellular space
     * \param height the height of cellular space
     */
    void setCellSpaceSize(int width, int height);

    /**
     * Gets the size of cellular space
     * \see QSize
     */
    const QSize getCellSpaceSize();

	void save(string, string);

    /**
     * Creates a color bar
     * \param colors a QString with the Lua legend colorBar in string format
     * \param colorBarVec a reference to a ColorBar vector
     * \param stdColorBarVec a reference to a ColorBar vector
     * \param valueList a reference to a list of values
     * \param labelList a reference to a list of labels
     * \see QString, QStringList
     */
    static void createColorsBar(QString colors, std::vector<ColorBar> &colorBarVec,
                        std::vector<ColorBar> &stdColorBarVec, QStringList &valueList,
                        QStringList &labelList);

    /**
     * Chechs if a Subject \a subj exist in the QVector \a linkedSubjects
     * \param linkedSubjects a reference to a pairs QVector of Subject pointer and QString
     * \param subj a pointer to a Subject
     * \see Subject
     * \see QVector, \see QPair, \see Subject
     */
    static bool constainsItem(const QVector<QPair<Subject *, QString> > &linkedSubjects,
        const Subject *subj);

    /**
     * Closes the observer window
     */
    int close();

    void setGridVisible(bool visible);

signals:
    /**
     * Triggers the grid draw
     * \param on boolean, if \a true shows the grid. Otherwise, does not show.
     */
    void gridOn(bool on);

public slots:
    /**
     * Treats the zoom in button click
     */
    void butZoomIn_Clicked();

    /**
     * Treats the zoom out button click
     */
    void butZoomOut_Clicked();

    /**
     * Treats the zoom window button click
     */
    void butZoomWindow_Clicked();

    /**
     * Treats the zoom restore button click
     */
    void butZoomRestore_Clicked();

    /**
     * Treats the pan zoom button click
     */
    void butHand_Clicked();

    /**
     * Treats the interaction with treeLayers component of the window
     * \param item a pointer to a QTreeWidgetItem object
     * \param column the index of the column on the treeLayer component
     * \see QTreeWidget, \see QTreeWidgetItem
     */
    void treeLayers_itemChanged(QTreeWidgetItem * item, int column);

    /**
     * Treats the selected scale of zoom in the zoom comboBox
     * \param scale the selecte zoom scale
     * \see QString
     */
    void zoomActivated(const QString &scale);

    /**
     * Treats the zoom change signal. Receives new zoom rectangle, proportional
     * factor for width and height
     * \param zoomRect a new zoom rectangle
     * \param width a proportion factor for the width
     * \param height a proportion factor for the height
     * \see PainterWidget::zoomChanged
     * \see QRect
     */
    void zoomChanged(QRect zoomRect, double width, double height);

    /**
     * Treats the zoom out signal
     * \see PainterWidget::zoomOut
     */
    void zoomOut();

protected:
    /**
     * Catchs the resize event
     * \see QResizeEvent
     */
    void resizeEvent(QResizeEvent* event);

    /**
     * Gets a pointer to the painterWidget object
     * \see PainterWidget
     */
    PainterWidget * getPainterWidget() const;

    /**
     * Gets a pointer to the hash of Attributes
     * \see Attributes
     * \see QHash, \see QString
     */
    QHash<QString, Attributes*> * getMapAttributes() const;

    /**
     * Gets a reference to the docoder object
     * \see Decoder
     */
    Decoder & getProtocolDecoder() const;

    /**
     * \deprecated Gets the treeLayers component
     * \see QTreeWidget
     */
    QTreeWidget * getTreeLayers();

private:
    /**
     * Initializes the commom object to the constructors
     */
    void init();

    /**
     * Sets up the user interface
     */
    void setupGUI();

    /**
     * Connects the slot on the treeLayer object
     * \param on boolean, if \a true connects the signal to the slot.
     * Otherwise, disconnects its.
     */
    void connectTreeLayerSlot(bool on);

    /**
     * currentMode
     * @return
     */
    QPainter::CompositionMode currentMode() const;

    /**
     * Calculates the zoom level from the zoom comboBox
     * \param in boolean, if \true caluculates the zoom in.
     * Otherwise, calculates the zoom out.
     */
    void calculeZoom(bool in);

    /**
     * Shows the attributes layer
     */
    void showLayerLegend();

    /**
     * Makes the colorBar struct
     * \param distance the value for color in the colorBar object
     * \param strColorBar a string that contains the values for colorBar in string format
     * \param value
     * \param label
     */
    static ColorBar makeColorBarStruct(int distance,
                 QString strColorBar, QString &value, QString &label);
    void zoomWindow();

    void moveEvent(QMoveEvent *event);
    void closeEvent(QCloseEvent *event);

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    bool paused, cleanValues;
    int numTiles;
    int rows, cols;  /// numero de linha e colunas


    QStringList itemList; /// lista de todas as chaves
    QStringList obsAttrib;  /// lista de chaves em observa??o
    QHash<QString, Attributes*> *mapAttributes;	/// map de todas as chaves
    QTreeWidget *treeLayers;

    QScrollArea *scrollArea;
    QFrame *frameTools;

    QComboBox *zoomComboBox;

    QToolButton *butZoomIn, *butZoomOut;
    QToolButton *butZoomWindow, *butHand;
    QToolButton *butZoomRestore;

    PainterWidget *painterWidget;
    LegendWindow *legendWindow;
    Decoder *protocolDecoder;
    int builtLegend;

    bool needResizeImage;
    double 	newWidthCellSpace, newHeightCellSpace;
    int width, height;

    QVector<int> zoomVec;
    int positionZoomVec;
    int zoomCount, zoomIdx;
    double actualZoom;
};

}

#endif
