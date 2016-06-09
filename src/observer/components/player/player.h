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

#ifndef TME_PLAYER_H
#define TME_PLAYER_H

#include <QString>

class PlayerGUI;

namespace TerraMEObserver {

/**
 * \brief Handle simulation object
 * Only when used Environment and/or Timer object
 * \see Enviroment, \see Timer
 * \author Antonio Jos? da Cunha Rodrigues
 * \file player.h
 */
class Player
{
public:
    /**
     * Factory for the Player object
     * \return Player object reference
     */
    static Player & getInstance();

    /**
     * Destructor for the object
     */
    virtual ~Player();

    /**
     * Shows the window
     */
    void show();

    /**
     * Closes the window
     */
    int close();

    /** 
     * Define the user interface is enable to execute
     * \param on boolean, if \a true enable the user interface. Otherwise, disable it.
     */
    void setEnabled(bool on);

    /**
     * Gets the user interface state
     */
    bool isEnabled();

protected:
    /**
     * Sets the buttons state in the window
     * \param active boolean, if \a true actives the buttons. Otherwise, desactives it.
     */
    void setActiveButtons(bool active);

private:
    /**
     * Construtor
     */
    Player();

    PlayerGUI *playerGUI;
};

} // namespace TerraMEObserver

#endif // TME_PLAYER_H

