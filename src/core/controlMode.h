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

/*!
  \file controlMode.h
  \brief This file contains definitions about the TerraME model for representing agent's finite state machine.
         A ControlMode is a model to the agent's internal discrete state.
                 Handles: ControlMode
                 Implementations: ComtrolModeImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/

#ifndef CONTROL_MODE_H
#define CONTROL_MODE_H

#include "bridge.h"
#include "composite.h"
#include "process.h"

/**
 * \brief
 *  Implementation for a ControlMode object. A control mode is a representation for the Agent internal discrete
 *  state.It is necessary to implement the agent hybrid and situated state machine.
 *
 */
class ControlModeImpl : public Implementation
{
public:
    /// Sets the control mode name (identifier)
    /// \param controlModeName is a control mode identifier
    void setControlModeName(string &controlModeName) {
        name = controlModeName;
    }

    /// Gets the control mode name (identifier)
    /// \return Return the control mode identifier
    string getControlModeName(void) {
        return name;
    }
private:
    string name; ///< control mode identifier
};

/**
 * \brief
 *  ControlMode Handle Type
 *
 */
typedef Interface<ControlModeImpl> ControlModeInterf;

/**
 * \brief
 *  Vector Process ControlMode Handle Type
 *
 */
typedef CompositeInterface< vectorComposite<Process> > ProcessCompositeInterf;

/**
 * \brief
 *  Handle for a ControlMode object. A control mode is a representation for the Agent internal discrete
 *  state.It is necessary to implement the agent hybrid and situated state machine.
 *  A ControlMode is vector composite of Process objects. Each process has several rules waiting to be executed.
 *  The Process objects are executed in the order they have been inserted into the ControlMode composite.
 *
 */
class ControlMode : public ControlModeInterf, public ProcessCompositeInterf
{
public:
    /// Default constructor
    ControlMode(void) {
        string strTemp = ""; // Raian: ControlModeInterf::pImpl_->setControlModeName(string(""));
        ControlModeInterf::pImpl_->setControlModeName(strTemp);
    }

    /// Constructor
    /// \param controlModeName is the control mode identifier
    ControlMode(string &controlModeName) {
        ControlModeInterf::pImpl_->setControlModeName(controlModeName);
    }

    /// Executes the Process objects in the order they have been inserted into ControlMode composite.
    /// \param event is a reference to the Event which linked message has triggered the agent control mode execution.
    /// \param agent is a pointer to the Agent being executed
    /// \param cellIndexPair is a pair of CellIndex objects and Cell pointers. The formers are user defined
    ///  n-dimensional coordinates for the latters.
    bool execute(Event &event, class Agent *agent, pair<CellIndex, Cell*> &cellIndexPair)
    {
        try
        {
            ProcessCompositeInterf::iterator iterator;
            iterator = ProcessCompositeInterf::pImpl_->begin();
            while (iterator != ProcessCompositeInterf::pImpl_->end())
            {
                if (!iterator->execute(event, agent, cellIndexPair)) return false;
                iterator++;
            }
            return true;
        }
        catch(...) { return true; }
    }

    /// HANDLE - Gets the ControMode name (identifier)
    /// \return a string containing the control mode identifier
    string getControlModeName(void) {
        return ControlModeInterf::pImpl_->getControlModeName();
    }

    /// HANDLE - Sets the ControMode name (identifier)
    /// \param controlModeName is a string containing the control mode identifier
    void setControlModeName(string &controlModeName)
    {
    	ControlModeInterf::pImpl_->setControlModeName(controlModeName);
    }
};

#endif
