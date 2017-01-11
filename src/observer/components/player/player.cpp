/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

#include "player.h"
#include "playerGUI.h"

using namespace TerraMEObserver;

Player & Player::getInstance()
{
    static Player player;
    return player;
}

// Player::Player(Subject *sub) : ObserverInterf(sub)
Player::Player()
{
    playerGUI = new PlayerGUI();
}

Player::~Player()
{
    delete playerGUI;
}

//bool Player::draw(QDataStream &)
//{
//    QString msg;
//    return true;
//}
//
//const TypesOfObservers Player::getObserverType()
//{
//    return observerType;
//}
//
//QStringList Player::getAttributes()
//{
//    return itemList;
//}
//
//int Player::close()
//{
//    PlayerGUI->close();
//    return 0;
//}

void Player::setActiveButtons(bool active)
{
    playerGUI->setEnabled(active);
}

void Player::show()
{
    playerGUI->showNormal();
}

void Player::setEnabled(bool enabled)
{
    playerGUI->setEnabled(enabled);
}

bool Player::isEnabled()
{
    return playerGUI->isEnabled();
}
