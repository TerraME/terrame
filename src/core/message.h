/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.

Author: Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*************************************************************************************/

/*!
  \file message.h
  \brief This file contains definitions about the Message objects. Messages are dispatched by the
                 simulation engine Event objects. In general, a message is a function with several
                 calls to the TerraME API services (or API functions). Messages run Agent objects
                 over the CellularSpace objects, carry out the communication between Agent objects,
                 report model result, synchronize or load or save Cellular space in the geographical database.
                 Handles: Message
                 Implementations: MessageImpl
  \author Tiago Garcia de Senna Carneiro
*/

#ifndef MESSAGE_H
#define MESSAGE_H

#include "event.h"

/**
 * \brief
 *  Implementation for a Message object.
 *
 */
class Message: public Model
{
public:

    /// Executes a simulation engine Message object
    /// \param event is the reference to the Event which has triggered this Message
    /// \return A boolean value: true if the Message object must be re-inserted in the simulation
    ////        engine Scheduler, otherwise false.
    virtual bool execute(Event& /*event*/){return false;}

};

#endif

