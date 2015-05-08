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

#ifndef OBSERVER_IMAGE_H
#define OBSERVER_IMAGE_H

#include "observerInterf.h"
#include "legendWindow.h"
#include "painterWidget.h"

#include <QDataStream>
#include <QVector>
#include <QHash>

class ImageGUI;

namespace TerraMEObserver {

class Decoder;

/**
 * \brief Spatial visualization for cells and saved in a png image file
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerImage.h
 */
class ObserverImage :  public ObserverInterf
{

public:
    /**
    * Constructor
    * \param subj a pointer to a Subject
    */
    ObserverImage(Subject *subj);

    /**
     * Destructor
     */
    virtual ~ObserverImage();

    /**
     * Draws the internal state of a Subject
     * \param state a reference to a QDataStream object
     * \return a boolean, \a true if the internal state was rendered.
     * Otherwise, returns \a false
     * \see  QDataStream
     */
    bool draw(QDataStream &state);

    /**
     * Sets the attributes for observation in the observer
     *
     * \param attribs a list of attributes under observation
     * \param legKeys a list of legend keys
     * \param legAttribs a list of legend attributes
     */
    void setAttributes(QStringList &attribs, QStringList legKeys,
                       QStringList legAttribs, TypesOfSubjects type);

    /**
     * Gets the attributes list
     */
    QStringList getAttributes();

    /**
     * Gets the type of observer
     */
    const TypesOfObservers getType() const;

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
    const QSize & getCellSpaceSize() const;

    /**
     * Sets the path and the prefix to the image file
     * \param path a reference to the path where the image file will be save
     * \param prefix a reference to the prefix for the file name
     * \see QString
     */
    void setPath(const QString &path = "./",
                 const QString &prefix = DEFAULT_NAME);

    /**
     * Closes the ObserverImage user interface
     */
    int close();

    /**
     * Shows the ObserverImage user interface
     */
    void show();

protected:
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
     * Gets a reference to the decoder object
     * \see Decoder
     */
    Decoder & getProtocolDecoder() const;

    /**
     * Saves the image file in the path
     * \see ObserverImage::setPath
     */
    bool save();

    /**
     * Desactivate the save method. It will call by a sub-class
     */
    void setDisableSaveImage();

    /**
     * Gets the save method flag
     */
    bool getDisableSaveImage() const;

private:

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QSize cellularSpaceSize;
    int width, height;
    int builtLegend;
    bool needResizeImage;
    // disables image rescue,
    // for the method being invoked by another object
    bool disableSaveImage;

    QString path;
    QSize resultSize;

    // list of all keys, key list under observation
    QStringList attribList, obsAttrib;

    ImageGUI *obsImgGUI;  // GUI
    LegendWindow *legendWindow;
    PainterWidget *painterWidget;
    // map of all keys
    QHash<QString, Attributes*> *mapAttributes;
    Decoder *protocolDecoder;
};

}

#endif
