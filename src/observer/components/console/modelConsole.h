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

#ifndef MODELCONSOLE_H
#define MODELCONSOLE_H

#include <QWidget>

namespace Ui {
class ModelConsoleGUI;
}

/**
 * \brief User interface for Model Console object
 * \see QWidget
 * \author Antonio Jose da Cunha Rodrigues
 * \file modelConsole.h
 */
class ModelConsole : public QWidget
{
    Q_OBJECT

public:
    /**
     * Destructor
     */
    virtual ~ModelConsole();

    /**
     * Appends a message in to the model console user interface
     * \param msg reference for a QString message
     * \see QString
     */
    void appendMessage(const QString &msg);

protected:
    /**
     * Construtor
     */
    ModelConsole(QWidget *parent = 0);

private:
    Ui::ModelConsoleGUI *ui;
};

#endif // MODELCONSOLE_H
