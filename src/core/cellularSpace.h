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
  \file cellularSpace.h
  \brief This file contains definitions about the TerraME model for space representation: CellularSpace class.
                 A CellularSpace is defined as a Region of indexes for "Cell" objects.
                 Handles: CellularSpace
                 Implementations: CellularSpaceImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/


#if ! defined(CELLULAR_SPACE_H)
#define CELLULAR_SPACE_H

#include <vector>
#include <map>
using namespace std;

#include "bridge.h"
#include "composite.h"
#include "model.h"
#include "cell.h"
#include "controlMode.h"
#include "agent.h"


/**
 * \brief
 *  Implementation for a CellularSpace object.
 *  For while, CellularSpace class has a empty implementation!
 */
class CellularSpaceImpl : public Implementation 
{
public:

};

/**
 * \brief
 *  Cellular Space Handle Type
 *
 */
typedef Interface<CellularSpaceImpl> CellularSpaceInterf;

/**
 * \brief
 *  Handle for a CellularSpace object.
 *
 */
class CellularSpace : public Model, public CellularSpaceInterf, public Cell, public Region_<CellIndex>
{
public:

    /// Attaches agent to all cellular space cell.
    /// \param agent is new agent being inserted into the cellular space
    void attachAgent(class LocalAgent *agent){
        ControlMode& controlMode = (*agent)[0];
        attachControlModeToCells(agent, &controlMode);
    }

    /// Detaches the agent from the cellular space
    /// \param agent being remove from the cellular space
    void detachAgent(LocalAgent *agent){
        detachControlModeFromCells(agent);
    }

    /// Updates than cellular space past copying the current value of all cells attributes over the past values.
    /// \param sizeMem is the size (in bytes) of the cell with all its attributes, including the ones defined
    /// in TerraME framework application layer.
    void synchronize(unsigned int  sizeMem) {
        Region_<CellIndex>::iterator theIterator;
        theIterator = Region_<CellIndex>::pImpl_->begin();
        while(theIterator != Region_<CellIndex>::pImpl_->end())
        {
            theIterator->second->synchronize(sizeMem);
            theIterator++;
        }
    }




private:


    /// Attaches a control model of a agent attached to the cellular space to each cell.
    /// Using this method, the cell can keep track of the agents active control mode (or discrete state).
    /// \param agent is a pointer to a agent attached to the cellular space.
    /// \param controlMode is pointer to the agents control mode.
    void attachControlModeToCells(LocalAgent *agent, ControlMode *controlMode) {
        Region_<CellIndex>::iterator theIterator;

        theIterator = Region_<CellIndex>::pImpl_->begin();
        while(theIterator != Region_<CellIndex>::pImpl_->end())
        {
            theIterator->second->attachControlMode(agent, controlMode);
            theIterator++;
        }
    }

    /// Detaches the control model of a agent from the cells.
    /// Using this method, the cells stop to keep track of the agents active control mode (or discrete state).
    /// \param agent is a pointer to a agent attached to the cellular space.
    void detachControlModeFromCells(LocalAgent *agent) {
        Region_<CellIndex>::iterator theIterator;
        theIterator = Region_<CellIndex>::pImpl_->begin();
        while(theIterator != Region_<CellIndex>::pImpl_->end())
        {
            theIterator->second->detachControlMode(agent);
            theIterator++;
        }
    }

};

#endif
