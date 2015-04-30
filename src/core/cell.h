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
*************************************************************************************/
/*! 
  \file cell.h
  \brief This file contains definitions about the TerraME model for location representation: Cell class.
				 Handles: Cell
				 Implementations: CellImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/

#ifndef CELL_H 
#define CELL_H

#include <cstring>

#include "bridge.h"
#include "event.h"

class CellNeighborhood;

/**
 * \brief
 *  Neighborhood Composite Handle Type
 *
 */
typedef CompositeInterface< mapComposite<string, CellNeighborhood*> > NeighCmpstInterf;

class ControlMode;
class Agent;
class LocalAgent;

/**
 * \brief
 *  Implementation for a Cell object.
 *
 */
class CellImpl : public Implementation
{
	int latency; ///< simulation time elapsed since the last cell change
	NeighCmpstInterf neighborhoods_; ///< each cell may have many neighborhood graphs
	map<Agent*,ControlMode*> targetControlMode_; ///< each cell keeps track of the current state of each automaton whitin itself

public:
	/// Copies the block of memory used by the implementation of cell.
	/// \return A pointer to the copied block of memory (the cells implementation).
	CellImpl* clone( void )
	{
		CellImpl *copy = (CellImpl*) new char[sizeof(CellImpl)];
		memcpy( copy, this, sizeof(CellImpl) );
		return copy;
	}

	/// Default constructor
	///
	CellImpl(){}

	/// Destructor
	///
	virtual ~CellImpl(){}

	/// Updates the tracked state (control mode) of a certain agent within the cell.
	/// \param  agent is a pointer to an agent within the cell.
	/// \param controlMode is a pointer to the new agent tracked control mode (discrete state).
	void attachControlMode(Agent *agent, ControlMode *controlMode ) {

		// improve here
		map<Agent*,ControlMode*>::iterator location = targetControlMode_.find( agent );
		if( location != targetControlMode_.end() )
		{
			targetControlMode_.erase(agent);
			targetControlMode_.insert(map<Agent*,ControlMode*>::value_type(agent, controlMode));
		}
		else targetControlMode_.insert(map<Agent*,ControlMode*>::value_type(agent, controlMode));

	}

	/// Releases the tracked state (control mode) of a agent within the cell
	/// \param agent is a pointer to an agent within the cell
	/// \return true - if success, false - otherwise
	bool detachControlMode(Agent *agent ){
		map<Agent*,ControlMode*>::iterator location = targetControlMode_.find( agent );
		if ( location != targetControlMode_.end())
		{
			targetControlMode_.erase(agent);
			return true;
		}
		else
			return false;
	}

	/// HANDLE - Returns the current control model of a Automaton (Local Agent) within the cell
	/// \param agent is a pointer to a local agent within the cell
	/// \return true - if success, false - otherwise
	ControlMode* getControlMode(LocalAgent *agent){
		map<Agent*,ControlMode*>::iterator location = targetControlMode_.find((Agent*)agent);
		if(location != targetControlMode_.end())
		{
			return location->second;
		}
		else
			return NULL;
	}

	/// Determines which is the current tracked control mode of a certain agent within the cell
	/// \param event being executed by the simulation engine, whose attached message has called the agent::execute() method
	/// \param agent is a pointer to the agent being executed
	/// \return A pointer to the agent active control mode (discrete state).
	ControlMode* execute(Event &/*event*/, class Agent *agent){
		map<Agent*,ControlMode*>::iterator location = targetControlMode_.find(agent);
		if(location != targetControlMode_.end())
		{
			return location->second;
		}
		return (ControlMode*)0;
	}

	/// Gets the simulation ticks elapsed since the last change in the cell
	/// \return A integer representing the time elapsed (next version this should be checked).
	int getLatency(void) { return latency; }

	///  Sets the Cell's internal state latency counter to "value".
	/// \param value is a positive number (next version this should be checked).
	void setLatency(int value) { if( value >= 0 ) latency = value; }

	/// Gets the list of neighborhood graphs from the cell
	/// \return A reference to the list of neighborhoods.
	NeighCmpstInterf& getNeighborhoods(void) {

#if defined( DEBUG_NEIGH )
		cout << "C++, interno cell: "<< &neighborhoods_ << endl;
#endif

		return neighborhoods_;
	}

	/// Sets the list of neighborhood graphs from the cell
	/// \param neighs is a reference to the list of neighborhoods.
	void setNeighborhoods(NeighCmpstInterf& neighs) { neighborhoods_ = neighs; }

};

/**
 * \brief
 *  Cell Handle Type
 *
 */
typedef Interface<CellImpl> CellInterf;

/**
 * \brief
 *  Handle for a Cell object.
 *
 */
class Cell : public CellInterf
{
protected:
	bool duplicated; ///< A flag that indicates if the cell has been copied (true) or not (false)
	Cell* past; ///< Each cell keeps track of its past

	/// Copies the block of memory used by the handle and the implementation of cell.
	/// \return A pointer to the copied block of memory (the handle of the cell).
	Cell& clone(void)
	{
		Cell* copy = (Cell*) new char[sizeof(Cell)];

		memcpy(copy, this, sizeof(Cell));
		copy->pImpl_ = pImpl_->clone();

		return *copy;
	}
public:

	/// constructor
	///
	Cell():duplicated(false) { past = (Cell*) &clone(); }


	/// HANDLE - Updates the tracked state (control mode) of a certain agent within the cell.
	/// \param  agent is a pointer to an agent within the cell.
	/// \param target is a pointer to the new agent tracked control mode (discrete state).
	void attachControlMode(Agent *agent, ControlMode *target) { pImpl_->attachControlMode(agent, target); }

	/// HANDLE - Releases the tracked state (control mode) of a agent within the cell
	/// \param agent is a pointer to an agent within the cell
	/// \return true - if success, false - otherwise
	bool detachControlMode(Agent *agent){ pImpl_->detachControlMode( agent ); return true; }

	/// HANDLE - Returns the current control model of a Automaton (Local Agent) within the cell
	/// \param agent is a pointer to a local agent within the cell
	/// \return true - if success, false - otherwise
	ControlMode* getControlMode(LocalAgent *agent){ return pImpl_->getControlMode( agent ); }

	///  HANDLE - Sets the Cell's internal state latency counter to "value".
	/// \param value is a positive number (next version this should be checked).
	void setLatency(int value) { pImpl_->setLatency( value ); }

	/// HANDLE - Gets the simulation ticks elapsed since the last change in the cell
	/// \return A integer representing the time elapsed (next version this should be checked).
	int getLatency(void) { return pImpl_->getLatency(); }

	/// HANDLE - Determines which is the current tracked control mode of a certain agent within the cell
	/// \param event being executed by the simulation engine, whose attached message has called the agent::execute() method
	/// \param agent is a pointer to the agent being executed
	/// \return A pointer to the agent active control mode (discrete state).
	ControlMode* execute(Event &event, class Agent *agent) {
		return pImpl_->execute(event,agent);
	}

	/// Copy constructor
	//
	bool operator==(Cell & cell) { return pImpl_ == cell.pImpl_; }

	/// HANDLE - Gets the list of neighborhood graphs from the cell
	/// \return A reference to the list of neighborhoods.
	NeighCmpstInterf&  getNeighborhoods(void) { return pImpl_->getNeighborhoods(); }

	/// HANDLE - Sets the list of neighborhood graphs from the cell
	/// \param neighs is a reference to the list of neighborhoods.
	void  setNeighborhoods(NeighCmpstInterf& neighs) { pImpl_->setNeighborhoods(neighs); }

	/// Gets the past of the cell.
	/// \return A pointer to the past of cell.
	Cell * getPast(void) { return past; }

	/// Updates than cell past copying the current value of its attributes.
	/// \param sizeMem is the size (in bytes) of the cell with all its attributes.
	void synchronize(unsigned int sizeMem)
	{
		CellImpl* p;

		if(sizeMem <= 0) return;
		if(! duplicated) {

			past = (Cell*)new unsigned char[sizeMem];
			past->pImpl_ = new CellImpl();
			duplicated = true;
		}

		p = past->pImpl_;
		memcpy(past, this, sizeMem);
		memcpy(p, this->pImpl_, sizeof(CellImpl));
		past->pImpl_ = p;

	}
};
#endif

