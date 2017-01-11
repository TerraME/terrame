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
#include <float.h>

/**
 * \brief
 *  Implementation for a Event object.
 *
 */
class EventImpl : public Implementation
{
    double time_; ///< instant in which the Events must occurs
    double period_; ///<  periodicity in which the Event must occurs
    double priority_; /// Event priority(default value = 0)  Higher numbers means lower  priority.
    /// The normal priority is 0(zero).
public:
    /// Default constructor
    EventImpl(void) { time_ = -DBL_MAX, period_ = 1, priority_ = 0; }

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

    /// HANDLE - Gets the Event priority
    /// \return A double value representing the Event priority. Higher numbers means lower  priority. The default
    /// priority is 0(zero).
    double getPriority(void) { return EventInterf::pImpl_->getPriority(); }
};

/// Compares Event objects.
/// \param e1 is a Event object
/// \param e2 is a Event object
/// \return A boolean value:  true if e1 must occur earlier than e2, false otherwise.
bool operator<(Event e1, Event e2);

#endif

