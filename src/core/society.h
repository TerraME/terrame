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

/*!
  \file cell.h
  \brief This file contains definitions about the TerraME model for location representation: Society class.
                 Handles: Society
                 Implementations: SocietyImpl
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/

#ifndef SOCIETY_H
#define SOCIETY_H

#include <cstring>

#include "bridge.h"
#include "event.h"

//#include "neighborhood.h"
//class SocietyNeighborhood;

/**
 * \brief
 *  Neighborhood Composite Handle Tyoe
 *
 */
//typedef CompositeInterface< mapComposite<string, SocietyNeighborhood*> > NeighCmpstInterf;
//class ControlMode;
//class Agent;
//class LocalAgent;

/**
 * \brief
 *  Implementation for a Society object.
 *
 */
class SocietyImpl : public Implementation
{
    int latency; ///< simulation time elapsed since the last cell change
    NeighCmpstInterf neighborhoods_; ///< each cell may have many neighborhood graphs
    map<Agent*, ControlMode*> targetControlMode_; ///< each cell keeps track of the current state of each automaton whitin itself

public:

    /// Copies the block of memory used by the implementation of cell.
    /// \return A pointer to the copied block of memory (the cells implementation).
    SocietyImpl* clone(void)
    {
        SocietyImpl *copy = (SocietyImpl*) new char[sizeof(SocietyImpl)];
        memcpy(copy, this, sizeof(SocietyImpl));
        return copy;
    }

    /// Default constructor
    ///
    SocietyImpl() {}

    /// Destructor
    ///
    virtual ~SocietyImpl() {}

    /// Updates the tracked state (control mode) of a certain agent within the cell.
    /// \param  agent is a pointer to an agent within the cell.
    /// \param controlMode is a pointer to the new agent tracked control mode (discrete state).
    void attachControlMode(Agent *agent, ControlMode *controlMode) {

        // melhorar
        map<Agent*, ControlMode*>::iterator location = targetControlMode_.find(agent);
        if(location != targetControlMode_.end())
        {
            targetControlMode_.erase(agent);
            targetControlMode_.insert(map<Agent*,
            		ControlMode*>::value_type(agent, controlMode));
        }
        else targetControlMode_.insert(map<Agent*,
        		ControlMode*>::value_type(agent, controlMode));

    }

    /// Releases the tracked state (control mode) of a agent within the cell
    /// \param agent is a pointer to an agent within the cell
    /// \return true - if success, false - otherwise
    bool detachControlMode(Agent *agent) {
        map<Agent*, ControlMode*>::iterator location = targetControlMode_.find(agent);
        if (location != targetControlMode_.end())
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
    ControlMode* getControlMode(LocalAgent *agent) {
        map<Agent*, ControlMode*>::iterator location =
        		targetControlMode_.find((Agent*) agent);
        if (location != targetControlMode_.end())
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
    ControlMode* execute(Event &/*event*/, class Agent *agent) {
        map<Agent*, ControlMode*>::iterator location = targetControlMode_.find(agent);
        if (location != targetControlMode_.end())
        {

            return location->second;
        }
        return (ControlMode*)0;
    }

    /// Gets the simulation ticks elapsed since the last change in the cell
    /// \return A integer representing the time elapsed (next version this should be checked).
    int getLatency(void) { return latency; }

    ///  Sets the Society's internal state latency counter to "value".
    /// \param value is a positive number (next version this should be checked).
    void setLatency(int value) { if(value >= 0) latency = value; }

    /// Gets the list of neighborhood graphs from the cell
    /// \return A reference to the list of neighborhoods.
    NeighCmpstInterf& getNeighborhoods(void) {
        return neighborhoods_;
    }

    /// Sets the list of neighborhood graphs from the cell
    /// \param neighs is a reference to the list of neighborhoods.
    void setNeighborhoods(NeighCmpstInterf& neighs) { neighborhoods_ = neighs; }

};

/**
 * \brief
 *  Society Handle Type
 *
 */
typedef Interface<SocietyImpl> SocietyInterf;

/**
 * \brief
 *  Handle for a Society object.
 *
 */
class Society : public SocietyInterf
{
protected:
    bool duplicated; ///< A flag that indicates if the cell has been copied (true) or not (false)
    Society* past; ///< Each cell keeps track of its past

    /// Copies the block of memory used by the handle and the implementation of cell.
    /// \return A pointer to the copied block of memory (the handle of the cell).
    Society& clone(void)
    {
        Society* copy = (Society*) new char[sizeof(Society)];

        memcpy(copy, this, sizeof(Society));
        copy->pImpl_ = pImpl_->clone();

        return *copy;
    }

public:

    /// constructor
    ///
    Society():duplicated(false) { past = (Society*) &clone(); }

    /// HANDLE - Updates the tracked state (control mode) of a certain agent within the cell.
    /// \param  agent is a pointer to an agent within the cell.
    /// \param target is a pointer to the new agent tracked control mode (discrete state).
    void attachControlMode(Agent *agent, ControlMode *target)
    {
    	pImpl_->attachControlMode(agent, target);
    }

    /// HANDLE - Releases the tracked state (control mode) of a agent within the cell
    /// \param agent is a pointer to an agent within the cell
    /// \return true - if success, false - otherwise
    bool detachControlMode(Agent *agent) { pImpl_->detachControlMode(agent); return true; }

    /// HANDLE - Returns the current control model of a Automaton (Local Agent) within the cell
    /// \param agent is a pointer to a local agent within the cell
    /// \return true - if success, false - otherwise
    ControlMode* getControlMode(LocalAgent *agent)
    {
    	return pImpl_->getControlMode(agent);
    }

    ///  HANDLE - Sets the Society's internal state latency counter to "value".
    /// \param value is a positive number (next version this should be checked).
    void setLatency(int value) { pImpl_->setLatency(value); }

    /// HANDLE - Gets the simulation ticks elapsed since the last change in the cell
    /// \return A integer representing the time elapsed (next version this should be checked).
    int getLatency(void) { return pImpl_->getLatency(); }

    /// HANDLE - Determines which is the current tracked control mode of a certain agent within the cell
    /// \param event being executed by the simulation engine, whose attached message has called the agent::execute() method
    /// \param agent is a pointer to the agent being executed
    /// \return A pointer to the agent active control mode (discrete state).
    ControlMode* execute(Event &event, class Agent *agent) {
        return pImpl_->execute(event, agent);
    }

    /// Copy constructor
    //
    bool operator==(Society & cell) { return pImpl_ == cell.pImpl_; }

    /// HANDLE - Gets the list of neighborhood graphs from the cell
    /// \return A reference to the list of neighborhoods.
    NeighCmpstInterf&  getNeighborhoods(void) { return pImpl_->getNeighborhoods(); }

    /// HANDLE - Sets the list of neighborhood graphs from the cell
    /// \param neighs is a reference to the list of neighborhoods.
    void  setNeighborhoods(NeighCmpstInterf& neighs) { pImpl_->setNeighborhoods(neighs); }

    /// Gets the past of the cell.
    /// \return A pointer to the past of cell.
    Society * getPast(void) { return past; }

    /// Updates tha cell past copying the current value of its attributes.
    /// \param sizeMem is the size (in bytes) of the cell with all its attributes.
    void synchronize(unsigned int sizeMem)
    {
        SocietyImpl* p;

        if(sizeMem <= 0) return;
        if(!duplicated) {

            past = (Society*)new unsigned char[sizeMem];
            past->pImpl_ = new SocietyImpl();
            duplicated = true;
        }

        p = past->pImpl_;
        memcpy(past, this, sizeMem);
        memcpy(p, this->pImpl_, sizeof(SocietyImpl));
        past->pImpl_ = p;

    }
};
#endif
