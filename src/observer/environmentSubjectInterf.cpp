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

#include "environmentSubjectInterf.h"

#include "types/observerTable.h"
#include "types/observerGraphic.h"
#include "types/observerTextScreen.h"
#include "types/observerLogFile.h"
#include "types/observerUDPSender.h"
// #include "types/observerPlayer.h"

Observer * EnvironmentSubjectInterf::createObserver(TypesOfObservers typeObserver)
{
    Observer* obs = 0;

    switch (typeObserver)
    {
        case TObsTable:
            obs = new ObserverTable(this);
            break;

        case TObsLogFile:
            obs = new ObserverLogFile(this);
            break;

        case TObsDynamicGraphic:
        case TObsGraphic:
            obs = new ObserverGraphic(this);
            break;

        case TObsUDPSender:
            obs = new ObserverUDPSender(this);
            break;

        case TObsTextScreen:
        default:
            obs = new ObserverTextScreen(this);
            break;
    }
    return obs;
}

bool EnvironmentSubjectInterf::kill(int id)
{
    Observer * obs = getObserverById(id);
    detach(obs);

    if (!obs)
        return false;

    switch (obs->getType())
    {
        case TObsLogFile:
            ((ObserverLogFile *)obs)->close();
            delete (ObserverLogFile *)obs;
            break;

        case TObsTable:
            ((ObserverTable *)obs)->close();
            delete (ObserverTable *)obs;
            break;

        case TObsGraphic:
        case TObsDynamicGraphic:
            ((ObserverGraphic *)obs)->close();
            delete (ObserverGraphic *)obs;
            break;

        case TObsUDPSender:
            ((ObserverUDPSender *)obs)->close();
            delete (ObserverUDPSender *)obs;
            break;

        case TObsTextScreen:
            ((ObserverTextScreen *)obs)->close();
            delete (ObserverTextScreen *)obs;
            break;

            //case TObsPlayer:
            //    ((ObserverPlayer *)obs)->close();
            //    delete (ObserverPlayer *)obs;
            //    break;

            // case TObsMap:
            //     ((AgentObserverMap *)obs)->close();
            //     delete (AgentObserverMap *)obs;
            //     break;

        default:
            delete obs;
            break;
    }
    obs = 0;
    return true;
}

