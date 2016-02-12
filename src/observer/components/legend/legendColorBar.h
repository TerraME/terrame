/************************************************************************************
TerraLib - a library for developing GIS applications.
Copyright (C) 2001-2007 INPE and Tecgraf/PUC-Rio.

This code is part of the TerraLib library.
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The library provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and Tecgraf / PUC-Rio be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this library and its documentation.
*************************************************************************************/

#ifndef  __TERRALIB_INTERNAL_QTCOLORBAR_H
#define  __TERRALIB_INTERNAL_QTCOLORBAR_H

#include <QFrame>
#include "legendColorUtils.h"
#include <QMenu>
#include <QCursor>
#include <vector>
#include <map>
#include <string>
using namespace std;

//class Help;
namespace TerraMEObserver {

/**
 * \brief The color bar object used in LegendWindow object
 * \see QFrame
 * Based in TeQtColorBar object from TerraView
 * More information at http://www.dpi.inpe.br/terraview/
 */
class TeQtColorBar : public QFrame
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QFrame, \see QWidget
     */
    TeQtColorBar( QWidget* parent);

    /**
     * Destructor
     */
    virtual ~TeQtColorBar();
    
    /**
     * Sets a vector of \a TeColor
     * \param colorVec a reference to a \a TeColor vector
     */
    void setColorBar(const vector<TeColor>& colorVec);

    /**
     * \overload
     * \param colorBarVec a reference to a \a ColorBar vector
     */
    void setColorBar(const vector<ColorBar>& colorBarVec);

    /**
     * Sets the name of colors that compose the ColorBar
     * For example: "W-Bl": colorBar object starts with White
     * and finishs with Black
     * \param colors string with the color name.
     */
    void setColorBarFromNames(std::string colors);

    /**
     * Draws the colors in the colorBar object
     */
    void drawColorBar();
 
    /**
     * Sets the orientation
     * \param b boolean, \a True to vertical orientation.
     * Or \a False to horizontal orientation
    */
    void setVerticalBar(bool b);

    void setUpDownBar(bool b) {upDown_ = b;}
    
    /**
     * Inverts the color sequence
     */
    void invertColorBar();
    
    /**
     * Cleans the color bar
     */
    void clearColorBar();

    /**
     * Separates colors at equal distances
     */
    void setEqualSpace();

    /**
     * Gets the colors vector as a std::vector
     */
    std::vector<ColorBar> getInputColorVec() {return inputColorVec_;}

    // / Gets the color vector as a QVector
    // QVector<QColor> getQVectColor(){ return qvecColor;}

public slots:
    /**
     * Adds a color
     */
    void addColorSlot();

    /**
     * Changes a color
     */
    void changeColorSlot();

    /**
     * Removes a color
     */
    void removeColorSlot();

    /**
     * \deprecated Calls the help object
     */
    void helpSlot();

protected:
    /**
     * Paints event of the user interface object
     * \see QPaintEvent
     */
    void paintEvent(QPaintEvent *);

    /**
     * Catchs the mouse press event inside the user interface object
     * \see QMouseEvent
     */
    void mousePressEvent(QMouseEvent *);

    /**
     * Catchs the mouse move event inside the user interface object
     * \see QMouseEvent
     */
    void mouseMoveEvent(QMouseEvent *);

    /**
     * Catchs the mouse release event inside the user interface object
     * \see QMouseEvent
     */
    void mouseReleaseEvent(QMouseEvent *);

    /**
     * Catchs the mouse double click event inside the user interface object
     * \see QMouseEvent
     */
    void mouseDoubleClickEvent(QMouseEvent* );

    /**
     * Catchs the leave event
     * \see QEvent
     */
    void leaveEvent(QEvent*);

    /**
     * Catchs the resize event
     * \see QResizeEvent
     */
    void resizeEvent(QResizeEvent*);

    /**
     * Generates the color map
     */
    void generateColorMap();

    /**
     * Gets the color index
     */
    int	getColorIndiceToChange();

    /**
     * Fits the mouse position
     * \param point the point of mouse
     */
    void fitMousePosition(QPoint point);

    /**
     * Change the distance
     */
    void changeDistance();

    /**
     * Changes the brightness
     */
    void changeBrightness();

    /**
     * Changes all saturations
     */
    void changeAllSaturation();

    /**
     * Changes the saturation
     */
    void changeSaturation();

    /**
     * Changes all brightness
     */
    void changeAllBrightness();

    /**
     * Changes the hue
     */
    void changeHue();

    /**
     * Sorts by distance
     */
    void sortByDistance();

    ColorBar* colorEdit_;
    //	std::vector<TeColor>	getColors(TeColor, TeColor, int);

    QMenu popupMenu_;
    QAction *addColor;
    QAction *removeColor;
    QAction *changeColor;

    QPoint	p_;
    QPoint	pa_;
    int		a_;
    int		b_;
    int		ftam_;
    int		ind_;
    std::vector<ColorBar> inputColorVec_;
    std::vector<int> changeVec_;
    std::map<int, std::vector<TeColor> > colorMap_;
    bool	vertical_;
    bool	upDown_;
    bool	brightness_;
    bool	change_;
    bool	distance_;
    int		limit_, inf_, sup_;
    double	totalDistance_;
    //Help*	help_;

    // QVector<QColor> qvecColor;

signals:
    void mouseReleaseSignal(QMouseEvent*);
    void mouseMoveSignal(QMouseEvent*);
    void colorChangedSignal();
};

}

#endif // __TERRALIB_INTERNAL_QTCOLORBAR_H

