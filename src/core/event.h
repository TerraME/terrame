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

// Events are stimuli to which the system being simulated must
// respond or stimuli that trigger the simulator control actions. A common
// control action is the calculation and rescue, periodic, statistical
// information  on the simulator database. Information agents are also important.
// Examples of events to which the simulated systems usually need to answer are:
// a user performs an input operation or a process of simulated system requests
// information from another process.
//   Every event has a type that identifies and defines which routine should be
//   called to treat him. Every event must register the moment in which will
//   occur.

/*!
  \file event.h
  \brief This file contains definitions about the Event objects. Events are stimulus to which
                 the simulation engine should respond and carry out control actions. These stimulus trigger
                 message which call simulation engine services provide in the TerraME API.
                 Handles: Event
                 Implementations: EventImpl
  \author Tiago Garcia de Senna Carneiro
*/
#ifndef EVENT_H
#define EVENT_H

#include "bridge.h"
#include "model.h"
#include "reference.h"
#include <float.h>

extern lua_State * L; ///< Global variable: Lua stack used for communication with C++ modules.

/**
 * \brief
 *  Implementation for a Event object.
 *
 */
class EventImpl : public Implementation
{
    double time_; ///< instant in which the Events must occurs
    double period_; ///<  periodicity in which the Event must occurs
    double priority_; /// Event priority (default value = 0)  Higher numbers means lower  priority.
	int action_;
    /// The normal priority is 0(zero).
public:

    /// Default constructor
    EventImpl(void) { time_ = -DBL_MAX, period_ = 1, priority_ = 0, action_ = 0; }

    /// Sets the Event instant to occur
    /// \param eventTime is the moment to the Event happens
    void setTime(double eventTime) { time_ = eventTime; }

    /// Gets the instant the Event is programmed to happen
    /// \return  A double value representing the next instant the Event will happen
    double getTime() { return time_; }

    /// Sets the Event priority.
    /// \param priority is a double value. Higher numbers means lower  priority. The normal priority is 0(zero).
    void setPriority(double priority) { priority_ = priority; }

    /// Gets the Event priority
    /// \return A double value representing the Event priority.  Higher numbers means lower  priority. The normal
    /// priority is 0(zero).
    double getPriority(void) { return priority_; }

    /// Configures the Event.
    /// \param eventTime is the time instant in which the Event must occurs
    /// \param eventFrequency is the periodicity in which the Event must occurs
    /// \param priority is the priority in which the event must occurs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    void config(double eventTime, double eventFrequency, double priority) {
        period_   = eventFrequency > 0 ? eventFrequency : 0;
        time_     = eventTime;// > 0 ? eventTime : 0;
        priority_ = priority;
    }

    /// Gets the peridiocity in which the Event is programmed to happens
    /// \return A double number representing the Event periodicity in time
    double getPeriod() { return period_; }

    /// Sets the periodicity in which the Event must occurs in time
    /// \param period is the real number representing the periodicity in which the Event must occurs
    void setPeriod(double period) { period_ = period; }

    void setAction(int action) { action_ = action; }
    int getAction() { return action_; }
};

/**
 * \brief
 *  Event Handle Type.
 *
 */
typedef Interface<EventImpl> EventInterf;

/**
 * \brief
 *  Handle for a Event object.
 *
 */
class Event: public Model, public EventInterf
{
public:

    /// Constructor.
    /// \param time is the time instant in which the Event must occurs
    /// \param period is the periodicity in which the Event must occurs
    /// \param priority is the priority in which the event must occurs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    Event(double time = -DBL_MAX, double period = 1, double priority = 0)
	{
        EventInterf::pImpl_->setTime(time);
        EventInterf::pImpl_->setPeriod(period);
        EventInterf::pImpl_->setPriority(priority);
    }

    /// HANDLE - Gets the instant the Event is programmed to happen
    /// \return  A double value representing the next instant the Event will happen
    double getTime() { return EventInterf::pImpl_->getTime(); }

    /// HANDLE - Configures the Event object.
    /// \param time is the time instant in which the Event must occurs
    /// \param frequency is the periodicity in which the Event must occurs
    /// \param priority is the priority in which the event must occurs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    void config(double time, double frequency, double priority)
    {
    	EventInterf::pImpl_->config(time, frequency, priority);
    }

    /// HANDLE - Gets the periodicity in which the Event is programmed to happens
    /// \return A double number representing the Event periodicity in time
    double getPeriod() { return EventInterf::pImpl_->getPeriod(); }

    /// HANDLE - Gets the instant the Event is programmed to happen
    /// \return  A double value representing the next instant the Event will happen
    void setTime(double time) { EventInterf::pImpl_->setTime(time); }

    /// HANDLE - Sets the periodicity in which the Event must occurs in time
    /// \param period is the real number representing the periodicity in which the Event must occurs
    void setPeriod(double period) { EventInterf::pImpl_->setPeriod(period); }

    /// HANDLE - Sets the Event priority.
    /// \param priority is a double number. Higher numbers means lower  priority. The default priority is 0(zero).
    void setPriority(double priority) { EventInterf::pImpl_->setPriority(priority); }

    void setAction(int action) { EventInterf::pImpl_->setAction(action); }
    int getAction() { return EventInterf::pImpl_->getAction(); }

    /// HANDLE - Gets the Event priority
    /// \return A double value representing the Event priority. Higher numbers means lower  priority. The default
    /// priority is 0(zero).
    double getPriority(void) { return EventInterf::pImpl_->getPriority(); }

    /// Executes the luaMessage object
    /// \param event is the Event which has trigered this luaMessage
    bool execute() {
		lua_rawgeti(L, LUA_REGISTRYINDEX, getAction());
        if(!lua_isfunction(L, -1))
        {
            string err_out = string("Action function not defined!");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			lua_call(L, 1, 0);
            return 0;
        }

        // puts the Event constructor on the top of the lua stack
        lua_getglobal(L, "Event");
        if(!lua_isfunction(L, -1))
        {
			string err_out = string("Event constructor not found.");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			//lua_pushnumber(L, 5);
			lua_call(L, 1, 0);
            return 0;
        }

        // builds the table parameter of the constructor
        lua_newtable(L);
		if(getTime() != 1) {
        	lua_pushstring(L, "start");
        	lua_pushnumber(L, getTime());
        	lua_settable(L, -3);
		}
		if(getPeriod() != 1) {
        	lua_pushstring(L, "period");
        	lua_pushnumber(L, getPeriod());
        	lua_settable(L, -3);
		}
		if(getPriority() != 0) {
        	lua_pushstring(L, "priority");
        	lua_pushnumber(L, getPriority());
        	lua_settable(L, -3);
		}

        // calls the event constructor
        if(lua_pcall(L, 1, 1, 0) != 0)
        {
            string err_out = string("Event constructor not found in the stack.");
			lua_getglobal(L, "customError");
			lua_pushstring(L, err_out.c_str());
			lua_call(L, 1, 0);
            return 0;
        }

    	// calls the function 'execute'
        lua_call(L, 1, 1);

        // retrieve the message result value from the lua stack
        int result = true;
        if(lua_type(L, -1) == LUA_TBOOLEAN)
        {
            result = lua_toboolean(L, -1);
            lua_pop(L, 1);  // pop returned value
        }

        return result;
    }
};

/// Compares Event objects.
/// \param e1 is a Event object
/// \param e2 is a Event object
/// \return A boolean value:  true if e1 must occur earlier than e2, false otherwise.
bool operator<(Event e1, Event e2);

#endif

