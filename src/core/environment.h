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
  \file environment.h
  \brief This file contains definitions about the Environment objects. Messages are virtual worlds where
                 the Agent actions take place.
                 Handles: Environment
                 Implementations: EnvironmentImpl
  \author Tiago Garcia de Senna Carneiro
*/

#ifndef ENVIRONMENT_H
#define ENVIRONMENT_H

#if defined (MSDEV)
#include <limits>
#else
#include <float.h>
#endif

#include "bridge.h"
#include "composite.h"
#include "model.h"
#include "cellularSpace.h"
#include "agent.h"
#include "scheduler.h"

#ifndef MIN
#define MIN(a, b)  (a < b ? a : b)
#endif

#include <QApplication>
#include "player.h"

extern bool SHOW_GUI;
extern bool paused;
extern bool step;

/**
 * \brief
 *  Implementation for an Environment object.
 *
 */
class EnvironmentImpl :  public Implementation
{
    double finalTime_;	///< Time instant when the simulation should stop

public:

    /// Configures the time instant when the Environment should stop
    /// \param finTime is a real number when the simulation engine should stop
    void config(double finTime) {
        if(finTime > 0)
        {
            finalTime_ = finTime;
        }
        else finalTime_ = 0;
    }

    /// Gets the time instant when the Environment should stop to run.
    /// \return A real number representing the time instant when the Environment should stop to run
    double getFinalTime() { return finalTime_; }
};

class Environment;

/**
 * \brief
 *  Environment Handle Type.
 *
 */
typedef Interface<EnvironmentImpl> EnvironmentInterf;

/**
 * \brief
 *  LocalAgent Vector Composite Handle Type.
 *
 */
typedef CompositeInterface< vectorComposite<LocalAgent> > LocalAgentCompositeInterf;

/**
 * \brief
 *  GlobalAgent Vector Composite Handle Type.
 *
 */
typedef CompositeInterface< vectorComposite<GlobalAgent> > GlobalAgentCompositeInterf;

/**
 * \brief
 *  CellularSpace Vector Composite Handle Type .
 *
 */
typedef CompositeInterface< vectorComposite<CellularSpace> > CellularSpaceCompositeInterf;

/**
 * \brief
 *  Time-Environment Pair Multimap Composite Handle Type.
 *
 */
typedef CompositeInterface< multimapComposite<Event, Environment> >
									TimeEnvironmentPairCompositeInterf;

/**
 * \brief
 *  Time-Scheduler Pair Multimap Composite Handle Type.
 *
 */
typedef CompositeInterface< multimapComposite<Event, Scheduler> >
									TimeSchedulerPairCompositeInterf;

/**
 * \brief
 *  Handle for an Environment object.
 *
 */
class Environment: public Model,
        public EnvironmentInterf,
        public CellularSpaceCompositeInterf,
        public LocalAgentCompositeInterf,
        public GlobalAgentCompositeInterf,
        public TimeSchedulerPairCompositeInterf,
        public TimeEnvironmentPairCompositeInterf
{

public:
    string envId;

    /// Defautl constructor
    ///
    Environment(void)
    {
        if (SHOW_GUI)
            TerraMEObserver::Player::getInstance().setEnabled(true);
    }

    /// Constructor
    /// \param id is the Environment identifier
    Environment(string id) { envId = id; }

    /// Configures the time instant when the Environment should stop
    /// \param finTime is a real number when the simulation engine should stop
    void config(double finTime) {
        EnvironmentInterf::pImpl_->config(finTime);
    }

    /// Returns the instant time that the Environment is programmed to start running
    /// \return A real number representing the time instant that the Environment is programmed to start running
    double getInitialTime() {
        double timeSch = -1, timeEnv = -1;
        TimeSchedulerPairCompositeInterf::iterator itSch;
        TimeEnvironmentPairCompositeInterf::iterator itEnv;
        itSch = TimeSchedulerPairCompositeInterf::pImpl_->begin();
        itEnv = TimeEnvironmentPairCompositeInterf::pImpl_->begin();
        if (itEnv != TimeEnvironmentPairCompositeInterf::pImpl_->end())
        	timeEnv = itEnv->second.getEvent().getTime();
        if(itSch != TimeSchedulerPairCompositeInterf::pImpl_->end())
        	timeSch = itSch->second.getEvent().getTime();
        if((timeSch >= 0) & (timeEnv >= 0)) return MIN(timeSch, timeEnv);
        if(timeSch >= 0) return timeSch;
        if(timeEnv >= 0) return timeEnv;
        return -1;
    }

    /// Gets the time instant when the Environment should stop to run.
    /// \return A real number representing the time instant when the Environment should stopo to run
    double getFinalTime() { return EnvironmentInterf::pImpl_->getFinalTime(); }

    /// Executes the Environment. The internal Scheduler data structure is put to work.
    /// \return Always returns true.
    virtual bool execute(void) {
        double time = getInitialTime(), timeAux;
        double finalTime = EnvironmentInterf::pImpl_->getFinalTime();
        TimeEnvironmentPairCompositeInterf::iterator iterator;
        Environment envAux;
        Scheduler schAux;
        bool run = true;
        while(run & (time <= finalTime))
        {
            // Player
            while(paused)
                qApp->processEvents();

            // If there is no any internal environment: run "my" clock
            if(TimeEnvironmentPairCompositeInterf::size() == 0)
            {
                run = executeScheduler(this);
                time = getEvent().getTime();
            }
            else
            {
                // gets the first environment
                pair<Event, Environment> environmentPair;
                iterator = TimeEnvironmentPairCompositeInterf::pImpl_->begin();
                if(iterator != TimeEnvironmentPairCompositeInterf::pImpl_->end())
                {
                    envAux = iterator->second;

                    // Attempt to execute the (event, schedule) tree from this environment
                    if((TimeSchedulerPairCompositeInterf::size() > 0) &
                            (getEvent() < envAux.getEvent()))
                    {
                        timeAux = getEvent().getTime();
                        if(timeAux > finalTime) break;
                        run = executeScheduler(this);
                        time = getInitialTime();
                    }
                    else
                    {
                        // Attempt to execute the (event, schedule) tree from an internal environment
                        TimeEnvironmentPairCompositeInterf::erase(iterator);
                        timeAux = envAux.getInitialTime();
                        if(timeAux > finalTime) break;
                        environmentPair.second = envAux;
                        if(executeScheduler(&envAux))
                        {
                            time = timeAux;
                            schAux = envAux.firstScheduler()->second;
                            environmentPair.first = schAux.getEvent();
                            TimeEnvironmentPairCompositeInterf::add(environmentPair);
                            run = true;
                        }
                        else run = false;

                        iterator = TimeEnvironmentPairCompositeInterf::pImpl_->begin();
                    }
                }
            }
            if (step)
                paused = true;
        }
        return true;
    }

    /// Gets the Event on the head of the Scheduler data structure
    /// \return A copy of Event on the next Event that will occur.
    Event getEvent() {
        Event timeSch;
        TimeSchedulerPairCompositeInterf::iterator itSch;
        itSch = TimeSchedulerPairCompositeInterf::pImpl_->begin();
        if(itSch != TimeSchedulerPairCompositeInterf::pImpl_->end())
        	timeSch = itSch->second.getEvent();
        return timeSch;
    }

    /// Puts the Scheduler iterator in the begin of the internal composite Scheduler data structure.
    /// \return A iterator to the internal composite Scheduler data structure.
    TimeSchedulerPairCompositeInterf::iterator firstScheduler() {
        TimeSchedulerPairCompositeInterf::iterator iterator;
        iterator = TimeSchedulerPairCompositeInterf::pImpl_->begin();
        return iterator;
    }

    /// Synchronizes all CellularSpace objects within the Environment
    void synchronize(void)
	{
        CellularSpaceCompositeInterf::iterator iterator;
        iterator = CellularSpaceCompositeInterf::pImpl_->begin();
        while(iterator != CellularSpaceCompositeInterf::pImpl_->end())
        {
            iterator->update();
            iterator++;
        }
    }

    /// Adds a new CellularSpace object to the Environment
    /// \param cs is a reference to the CellularSpace being inserted in the Environment
    void add(CellularSpace &cs)
	{
        LocalAgentCompositeInterf::iterator iterator;
        iterator = LocalAgentCompositeInterf::pImpl_->begin();
        while(iterator != LocalAgentCompositeInterf::pImpl_->end())
		{
            cs.attachAgent(&(*iterator));
            iterator++;
        }
        CellularSpaceCompositeInterf::add (cs);
    }

    /// Removes the CellularSpace object received as parameter from the Environment
    /// \param cs is a reference the CellularSpace being removed from the Environment
    bool erase(CellularSpace &cs)
    {
        LocalAgentCompositeInterf::iterator iterator;
        iterator = LocalAgentCompositeInterf::pImpl_->begin();
        while(iterator != LocalAgentCompositeInterf::pImpl_->end())
		{
            cs.detachAgent(&(*iterator));
            iterator++;
        }

        return CellularSpaceCompositeInterf::erase(cs);
    }

    /// Inserts a new LocalAgent into the Environment. The LocalAgent is attached to each CellularSpace already
    /// embedded in the Environment.
    /// \param agent is a reference to the LocalAgent being inserted into the Environment.
    void add(LocalAgent &agent)
	{
        CellularSpaceCompositeInterf::iterator iterator;
        iterator = CellularSpaceCompositeInterf::pImpl_->begin();
        while(iterator != CellularSpaceCompositeInterf::pImpl_->end())
		{
            iterator->attachAgent(&agent);
            iterator++;
        }
        LocalAgentCompositeInterf::add (agent);
    }

    /// Inserts a new GlobalAgent into the Environment. The GlobalAgent is attached to each CellularSpace already
    /// embedded in the Environment.
    /// \param agent is a reference to the LocalAgent being inserted into the Environment.
    void add(GlobalAgent &agent)
	{
        GlobalAgentCompositeInterf::add (agent);
    }

    /// Removes a LocalAgent from the Environment. The LocalAgent is detached from all CellularSpace
    /// embedded in the Environment.
    /// \param agent is a reference to the LocalAgent being removed from the Environment.
    bool erase(LocalAgent& agent)
    {
        CellularSpaceCompositeInterf::iterator iterator;
        iterator = CellularSpaceCompositeInterf::pImpl_->begin();
        while(iterator != CellularSpaceCompositeInterf::pImpl_->end())
		{
            iterator->detachAgent(&agent);
            iterator++;
        }

        return LocalAgentCompositeInterf::erase(agent);
    }

    /// Removes a GlobalAgent from the Environment. The GlobalAgent is detached from all CellularSpace
    /// embedded in the Environment.
    /// \param agent is a reference to the GlobalAgent being removed from the Environment.
    bool erase(GlobalAgent& agent)
    {
        return GlobalAgentCompositeInterf::erase(agent);
    }

    /// Adds a new Time-Scheduler pair to the internal Scheduler synchronization data structure
    /// \param timeSchedulerPair is a reference to a Time-Scheduler pair being added.
    void add(const pair<Event, Scheduler> &timeSchedulerPair)
	{
        TimeSchedulerPairCompositeInterf::add(timeSchedulerPair);
    }

    /// Removes the Time-Scheduler pair from the Environment Scheduler data structure
    /// \param timeSchedulerPair is a reference to a Time-Scheduler pair being removed.
    void erase(pair<Event, Scheduler> &timeSchedulerPair)
	{
        TimeSchedulerPairCompositeInterf::erase (timeSchedulerPair.first);
    }

    /// Adds a new Event-Environment pair to the internal Environment synchronization data structure
    /// \param timeEnvironmentPair is a reference to a Event-Environment pair being added.
    void add(const pair<Event, Environment> &timeEnvironmentPair)
	{
        TimeEnvironmentPairCompositeInterf::add(timeEnvironmentPair);
    }

    /// Removes the Event-Environment pair from the internal Environment synchronization data structure
    /// \param timeEnvironmentPair is a reference to a Event-Environment pair being added.
    void erase(pair<Event, Environment> &timeEnvironmentPair)
	{
        TimeEnvironmentPairCompositeInterf::erase (timeEnvironmentPair.first);
    }

private:

    /// Executes the first scheduler of the environment received as parameter
    /// \param environment is a pointer to the Environment object being executed
    bool executeScheduler(Environment *environment)
	{
        Event time;
        TimeSchedulerPairCompositeInterf::iterator theIterator;
        pair<Event, Scheduler> timeSchedulerPair;
        theIterator = environment->firstScheduler();

        if (theIterator != environment->TimeSchedulerPairCompositeInterf::end())
        {
            Scheduler scheduler = theIterator->second;
            environment->TimeSchedulerPairCompositeInterf::erase(theIterator);

            time = scheduler.execute();
            if(!scheduler.empty())
				timeSchedulerPair.first = time;
            else
			{
                timeSchedulerPair.first.setTime(DBL_MAX);
                scheduler.setTime(DBL_MAX);
            }
            timeSchedulerPair.second = scheduler;
            environment->TimeSchedulerPairCompositeInterf::add(timeSchedulerPair);
            return true;
        }

        return false;
    }
};

/// Transits the Agent JumpCondition object to the target ControlMode
/// \param event is the reference to the Event which has triggered this auxiliary function
/// \param agent is a pointer to the LocalAgent object being executed
/// \param targetControlMode is a pointer to the jump condition target ControlMode
void jump(Event& event, GlobalAgent* const agent, ControlMode* targetControlMode);

#endif

