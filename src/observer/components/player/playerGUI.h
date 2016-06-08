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

#ifndef TME_PLAYER_GUI_H
#define TME_PLAYER_GUI_H

#include <QDialog>
#include <stdio.h>
#include <stdlib.h>

namespace Ui {
class PlayerGUI;
}

/**
 * \brief User interface for simulation controller (Player)
 * \see QDialog
 * \author Antonio Jos? da Cunha Rodrigues
 * \file privatePlayerGUI.h
 */
class PlayerGUI : public QDialog
{
    Q_OBJECT

public:
    /**
     * Contructor
     * \param parent a pointer to a QWidget object
     * \see QWidget
     */
    PlayerGUI(QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~PlayerGUI();

    /**
     * Activates the buttons states
     * \param active boolean, if \a true actives the buttons. Otherwise, desactives it.
     */
    void setActiveButtons(bool active);

public slots:
    /**
     * Treats the click in the \a play/pause button and starts or pauses the simulation
     */
    void playPauseClicked();

    /**
     * Treats the click in the \a step button and enables the step by step simulation
     */
    void stepClicked();

    /**
     * Treats the click in the \a stop button and finishs the simulation
     */
    void stopClicked();

private:
    Ui::PlayerGUI *ui;
};

#endif // TME_PLAYER_GUI_H
