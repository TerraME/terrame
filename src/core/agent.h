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
  \file agent.h
  \brief This file contains definitions about the TerraME model for behavior
  	  representation: GlobalAgent, LocalAgent and
         Agent class.
                 Handles: Agent, LocalAgent, GlobalAgent
                 Implementations: AgentImpl, LocalAgentImpl, GlobalAgentImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/
#ifndef AGENT_H
#define AGENT_H

#include <stdlib.h>
#include <string>

#include "model.h"
#include "composite.h"
#include "controlMode.h"
#include "cell.h"
#include "region.h"
#include "cellularSpace.h"

/**
 * \brief
 *  Action Region Vector Composite Handle Type
 *
 */
typedef CompositeInterface< vectorComposite< Region_<CellIndex> > >
											ActionRegionCompositeInterf;

/**
 * \brief
 *
 * Implements the TerraME Agent (GlobaAgent) and Automaton (LocalAgent) types
 * common behavior.
 */
class AgentImpl : public Implementation
{
	///< each agents has a set of Region objects which are used to traverse the cells
	ActionRegionCompositeInterf actionRegions;
	bool actionRegionStatus;  ///< true = action regions ON, false = action regions OFF
	///< time elapsed since the last change in the agent intern discrete state (ControlMode)
	double lastChangeTime;
public:
    /// constructor
    ///
	AgentImpl(void): actionRegionStatus(false), lastChangeTime(0.0) { }

    /// Get the Agent's "regions of action".
    /// \return The composite of action regions.
	ActionRegionCompositeInterf& getActionRegions(void) { return actionRegions; }

    /// Set the Agent's regions of action to that in the composite "actRgs".
    /// \param actRgs is a composite of ActionRegion objects.
   void setActionRegions(ActionRegionCompositeInterf& actRgs) { actionRegions = actRgs; }

    /// Set the Agent's internal state latency counter to zero.
    ///
	void resetLastChangeTime(void) { lastChangeTime = 0.0; }

    /// Set the Agent's internal state latency counter to "time".
    /// \param time is a real number.
	void setLastChangeTime(double time) { lastChangeTime = time; }

    /// Reset the latency counter for Agent's internal state to zero.
    /// \return The period of simulation time elapsed since the last time the
    /// Agent's internal state has changed.
	double getLastChangeTime(void) { return lastChangeTime; }

    /// Get the status of the Agent's action regions.
    /// \return The status of the Agent's action regions: \n
    /// true  - the rules will be applied to all cells the action regions.\n
    /// false - the rules must also define the iteration over the cellular space.
	bool getActionRegionStatus(void) { return actionRegionStatus; }

    /// Set Agent's action regions status to true or false.
    /// \param status is a boolean value: \n
    /// true  - the Agent's rules will be applied to all cells within the
	///			action regions.\n
    /// false - the Agent's is ignoring the actions regions,
    ///         the modeler rules must also define the iteration over the cellular space.
	void setActionRegionStatus(bool status) { actionRegionStatus = status; }
};

/**
 * \brief
 *
 * Implements the TerraME Automaton (LocalAgent) type.
 */

class LocalAgentImpl : public AgentImpl
{
public:
};

/**
 * \brief
 *
 * Implements the TerraME Agent type.
 * GlobalAgent implementation is empty!
 */
class GlobalAgentImpl : public AgentImpl
{
public:
};

/**
 * \brief
 * ControlMode Composite Handle Type
 *
 */
typedef CompositeInterface< vectorComposite<ControlMode> > ControlModeCompositeInterf;

/**
 * \brief
 *  Agent Handle Type
 *
 */
typedef Interface<AgentImpl> AgentInterf;

/**
 * \brief
 *
 * TerraME API interface for the Agent (GlobalAgent) or Automaton (LocalAgent)
 * common behavior.
 */
// abstract class
class Agent : public Model, public AgentInterf, public ControlModeCompositeInterf
{
public:
    /// Gets an interface for the Agent's list of the action regions.
    /// \return A action region composite interface.
	ActionRegionCompositeInterf& getActionRegions(void)
	{
		return AgentInterf::pImpl_->getActionRegions();
	};

    /// Gets an interface for the Agent's list of the action regions.
    /// \param actRgs is a composite interface of action regions.
	void setActionRegions(ActionRegionCompositeInterf& actRgs)
	{
		AgentInterf::pImpl_->setActionRegions(actRgs);
	}

    /// The modeler should override this method in order to implement the Agent's behavior.
    /// The modeler invokes this method from the Message objects, which are associated to Event objects
    /// and inserted into Timer objects. When the clock of a Timer object reaches the time of an inner Event occurs,
    /// it dispatches the Message object associated to this Event, and then the
    /// Agent's behavior is executed by the simulation engine.
    /// \return A boolean value:\n
    ///      true  - the execution was successful\n
    ///      false - the execution was interrupted in an abnormal situation. The simulation engine must also be halted.
	virtual bool execute(Event &event) = 0;

    /// Set the Agent's internal state latency counter to zero.
    ///
	void resetLastChangeTime(void) { AgentInterf::pImpl_->resetLastChangeTime(); }

    /// Set the Agent's internal state latency counter to "time".
    /// \param time is a real number.
    /// \callgraph
	void setLastChangeTime(double time) { AgentInterf::pImpl_->setLastChangeTime(time); }

    /// Reset the latency counter for Agent's internal state to zero.
    /// \return The period of simulation time elapsed since the last time the
    /// Agent's internal state has changed.
	double getLastChangeTime(void) { return AgentInterf::pImpl_->getLastChangeTime(); }

    /// Get the status of the Agent's action regions.
    /// \return The status of the Agent's action regions: \n
    /// true  - the rules will be applied to all cells the action regions.\n
    /// false - the rules must also define the iteration over the cellular space.
	bool getActionRegionStatus(void) { return AgentInterf::pImpl_->getActionRegionStatus(); }

    /// Set Agent's action regions status to true or false.
    /// \param status is a boolean value: \n
    /// true  - the Agent's rules will be applied to all cells within the action regions.\n
    /// false - the Agent is ignoring the actions regions,
    ///         the modeler rules must also define the iteration over the cellular space.
	void setActionRegionStatus(bool status)
	{
		AgentInterf::pImpl_->setActionRegionStatus(status);
	}

    /// Builds a Agent checking if there are invalid ControlMode objects defined as target into the
    /// Agent internal data structure.
    /// \return Returns true if all the target ControlMode are valid, otherwise returns false.
	bool build(void) {
		ControlModeCompositeInterf::iterator itCtrl = ControlModeCompositeInterf::begin();
		while (itCtrl != ControlModeCompositeInterf::end())
		{
			ControlMode& ctrlMode = *itCtrl;

			ProcessCompositeInterf::iterator itProcess = ctrlMode.ProcessCompositeInterf::begin();
			while (itProcess != ctrlMode.ProcessCompositeInterf::end())
			{
				Process &p = *itProcess;

				JumpCompositeInterf::iterator itJump = p.JumpCompositeInterf::begin();
				while (itJump != p.JumpCompositeInterf::end())
				{
					JumpCondition *jump = *itJump;
					string targetCmName;

					targetCmName = jump->getTargetControlModeName();

					// search for the jump condition target control mode among the agent's control modes
					bool found = false;
					ControlModeCompositeInterf::iterator itCtrl = ControlModeCompositeInterf::begin();
					while (itCtrl != ControlModeCompositeInterf::end())
					{
						ControlMode &agCtrl = *itCtrl;
						if (agCtrl.getControlModeName() == targetCmName)
						{
							jump->config(agCtrl , targetCmName);
							found = true;
							break;
						}

						itCtrl++;
					}
					if (!found) return false;

					itJump++;
				}

				itProcess++;
			}

			itCtrl++;
		}
		return true;
	}
};

/**
 * \brief
 *  Local Agent Handle Type
 *
 */
typedef Interface<AgentImpl> LocalAgentInterf;

/**
 * \brief
 *
 * Handle for the LocalAgent (Cellular Automata) Type.
 */
class LocalAgent : public Agent
{
public:
    /// Default constructor
	LocalAgent(void) { }

    /// Executes the LocalAgent (Cellular Automata) object. If the AgentImpl::actionRegionStatus flag is true, the
    /// LocalAgent will use these Region objects to traverse the cellular spaces. Otherwise, the LocalAgent will do
    /// nothing. If there are no Action Region objects defined for the LocalAgent, or if the Local Region objects are
    /// empty, the LocalAgent will also do nothing.
    /// \param event is a reference to the Event which linked message has triggered the agent control mode execution.
	bool execute(Event &event) {
		Region_<CellIndex>::iterator cellIterator;
		pair<CellIndex, Cell*> cellIndexPair;
		ControlMode *controlMode;

		// for each agent action region
		ActionRegionCompositeInterf& actRgs = getActionRegions();
		ActionRegionCompositeInterf::iterator rgsIterator = actRgs.begin();
		while (getActionRegionStatus() && (rgsIterator != actRgs.end()))
		{
			// for each cell
			cellIterator = rgsIterator->begin();
			while (cellIterator != rgsIterator->end())
			{
				// gets the agent active control mode
				cellIndexPair.first = cellIterator->first;
				cellIndexPair.second = cellIterator->second;

				// execute the control mode
				do
				{
					controlMode = cellIndexPair.second->execute(event, this);
					if (!controlMode) break;
				} while (!controlMode->execute(event, this, cellIndexPair));

				cellIterator++;
			}
			rgsIterator++;
		}
		return true;
	}
};

/**
 * \brief
 * GlobalAgent Handle Type
 *
 */
typedef Interface<AgentImpl> GlobalAgentInterf;

/**
 * \brief
 *
 * Handle for the Agent (GlobalAgent) type.
 */
class GlobalAgent : public Agent
{
	ControlMode* currentControlMode;

public:
    /// Default constructor
	GlobalAgent(void):currentControlMode(NULL) {}

    /// Executes the LocalAgent (Finite Automata) object. If the AgentImpl::actionRegionStatus flag is true, the
    /// LocalAgent will use these Region objects to traverse the cellular spaces. Otherwise, the LocalAgent will do
    /// nothing. If there are no Action Region objects defined for the LocalAgent, or if the Local Region objects are
    /// empty, the LocalAgent will also do nothing.
    /// \param event is a reference to the Event which linked message has triggered the agent control mode execution.
	bool execute(Event &event) {
		if (currentControlMode == NULL)
			currentControlMode = &(*ControlModeCompositeInterf::pImpl_)[0];
		CompositeInterface< multimapComposite<CellIndex, Cell*> >::iterator cellIterator;
		pair<CellIndex, Cell*> cellIndexPair;

		// for each agent action region
		ActionRegionCompositeInterf& actRgs = getActionRegions();
		ActionRegionCompositeInterf::iterator rgsIterator = actRgs.begin();
		if ((!getActionRegionStatus()) || actRgs.empty())
		{
			cellIndexPair.first.first = -1; cellIndexPair.first.second = -1;
			cellIndexPair.second = NULL;
			while (!currentControlMode->execute(event, this, cellIndexPair)){}
			return true;
		}

		while (getActionRegionStatus() && rgsIterator != actRgs.end())
		{
			// for each cell
			cellIterator = rgsIterator->begin();
			while (getActionRegionStatus() && (cellIterator != rgsIterator->end()))
			{
				cellIndexPair.first = cellIterator->first;
				cellIndexPair.second = cellIterator->second;

				// execute the control mode
				while (!currentControlMode->execute(event, this, cellIndexPair)){}

				cellIterator++;
			}
			rgsIterator++;
		}
		return true;
	}

    /// Carries out the GlobalAgent discrete state transition
    /// \param targetControlMode is a pointer to the next GlobalAgent control mode (internal discrete state)
	void jump(ControlMode* const targetControlMode)
	{
		currentControlMode = targetControlMode;
	}

    ///  Gets the current (or active) ControlMode name
    /// \return Returns a pointer to the current control mode (discrete internal state)
	ControlMode* getControlMode() { return currentControlMode; }

    /// Gets the current (or active) ControlMode name
    /// \return Returns the identifier to the current control mode (discrete internal state)
	string getControlModeName() {
        if (currentControlMode == NULL)
        	currentControlMode = &(*ControlModeCompositeInterf::pImpl_)[0];
        return currentControlMode->getControlModeName();
	}
};

#endif
