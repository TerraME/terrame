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
\file scheduler.h
\brief This file contains definitions about the Scheduler objects. Scheduler objects are
    discrete Event schedulers. The Scheduler implementation is based the version published in
    [Jain, 1991]. In this kind of implementation, the Scheduler works serving Event object in its
    Event-Message Pair ordered queue. Each Event occurs in a certain periodicity. Events are stimulus
    which must be answered by the simulation engine. For this reason, at each time a Scheduler is executed,
    it consumes the pair Event-Message at the head of its queue. The simulation clock is set assigned with
    the consumed Event time attribute value. The Message linked to the Event in the pair is dispatched
    (or executed). The Event-Message pairs is re-inserted in the queue if the Message execution return true or
    discarded otherwise. In general Message objects run Agent objects over the CellularSpace objects,
    carry out the communication between Agent objects, report model result, synchronize or load or save
    CellularSpace objects in the geographical database. Event objects are chronologically ordered in the
    Scheduler queue. Event objects with the same time instant to occur are ordered by their priority.
    Handles: Scheduler. A Scheduler object stops running when its Event-Message queue is empty or when the
    end simulation time has been reached.
    Implementations: SchedulerImpl
    Referece:
    Jain, R.. "The Art of Computer Systems Performance Analysis -
    Thechniques for Experimental Design, Measurement, Simulation,
    and Modeling", John Wiley & Sons, Inc., 1991.
    \author Tiago Garcia de Senna Carneiro
*/


#ifndef SCHEDULER_H
#define SCHEDULER_H

#include "bridge.h"
#include "composite.h"

#include "event.h"
#include "message.h"

#include <QApplication>
#include "player.h"

#include <float.h>

extern bool SHOW_GUI;
extern bool paused;
extern bool step;

/**
* \brief
*  Event-Message Pair Composite Handle Type.
*
*/
typedef CompositeInterface< multimapComposite<Event,Message*> > EventMessagePairCompositeInterf;

/**
* \brief
*  Implementation for a Scheduler object.
*
*/
class SchedulerImpl : public Implementation
{
    Event time_; ///< Scheduler simulation timer

public:	

    /// Default constructor
    SchedulerImpl( void )
    {
        if (SHOW_GUI)
            TerraMEObserver::Player::getInstance().setEnabled(true);
        time_.setTime( -DBL_MAX );
    }

    /// Resets the Scheduler simulation time
    void reset( void ) { time_.setTime( -DBL_MAX ); }

    ///Sets the Scheduler simulation time
    /// \param time is a double value representing the current simulation time
    void setTime( double time  ) {
		time_.setTime( time );
	}

    ///Gets the Scheduler simulation time
    double getTime() {
		return time_.getTime();
	}

    /// Gets the Event object on the head of the Event-Message queue
    /// \return A copy to the Event object on Event-Message head
    Event getEvent( void ) {
        EventMessagePairCompositeInterf::iterator iterator = eventMessageQueue.begin();
        pair<Event, Message*> eventMessagePair;

        if ( iterator != eventMessageQueue.end() )
        {
            eventMessagePair.first = iterator->first;
            return eventMessagePair.first;
        }

        return time_;
    }

    // TO CORRECT ADD METHOD: needs to change here, for when an event is added to a scheduler
    // the whole simulation structure should be changed: the tree of schedulers and
    // environments tree (scales)

    /// Adds a new pair Event-Messsage to the Scheduler queue.
    /// \param event is a reference to the Event being added
    /// \param message is a pointer to message being linked to the Event
    void add( Event& event, Message* message ){
        pair<Event, Message*> eventMessagePair;
        eventMessagePair.first = event;
        eventMessagePair.second = message;
        eventMessageQueue.add( eventMessagePair );
    }


    /// Executes the Scheduler object. Only one simulation time step is executed.
    /// Therefore, just the Message on the head of the Scheduler queue is executed.
    /// \return A reference to Event object which has triggered the Message object
    Event& execute( ) {
        pair<Event, Message*> eventMessagePair;
        EventMessagePairCompositeInterf::iterator iterator;

        iterator = eventMessageQueue.begin();
        if( iterator != eventMessageQueue.end() )
        {
            Event& event = eventMessagePair.first = iterator->first;
            Message *message = eventMessagePair.second = iterator->second;

            time_ = event.getTime();

            Message msg = *message; // it's Important to keep the message implementation alive
            eventMessageQueue.erase(iterator);

            if (message->execute( event )) {
                eventMessagePair.first.setTime( double( time_.getTime() + event.getPeriod()) );
                eventMessageQueue.add( eventMessagePair );
            }

            iterator = eventMessageQueue.begin();
        }

        if ( ! eventMessageQueue.empty() )
        {
            Event& event = (Event& )iterator->first;
            return event;
        }
        return time_;
    }

    /// Executes the Scheduler object. Messages are executed until the end simulation time has been reached or
    /// until the Event-Message queue becomes empty.
    /// \param finalTime is a real number representing the end simulation time
    /// \return A real number meaning the Scheduler internal clock
    double execute( double& finalTime ) {
        Event event;
        Message *message;
        pair<Event, Message*> eventMessagePair;
        EventMessagePairCompositeInterf::iterator iterator;

        iterator = eventMessageQueue.begin();
        while( iterator != eventMessageQueue.end() && time_.getTime() <= finalTime )
        {
		//Player
            while (paused)
                qApp->processEvents();

            event = eventMessagePair.first = iterator->first;
            message = eventMessagePair.second = iterator->second;

            if(event.getTime() > finalTime){
				time_ = finalTime;
				break;
			}

            time_ = event.getTime();
            Message msg = *message; // it's Important to keep the message implementation alive
            eventMessageQueue.erase(iterator);

            if (message->execute( event )) {
                eventMessagePair.first.setTime( double(time_.getTime() + event.getPeriod()) );
                eventMessageQueue.add( eventMessagePair );
            }

            iterator = eventMessageQueue.begin();

            if (step)
                paused = true;
        }
		return finalTime;
    }

    /// Pauses the Scheduler. NOT IMPLEMENTED.
    void pause( ){}

    /// Stops the Scheduler. NOT IMPLEMENTED
    void stop( ) {}

    /// Return true if the Event-Message queue is empty.
    /// \return A boolean value: returns true if the Scheduler queue is empty, otherwise returns false.
    bool empty( void ) { return eventMessageQueue.empty(); }

public:

    EventMessagePairCompositeInterf eventMessageQueue; ///< Event-Message Pair queue

};

/**
* \brief
*  Scheduler Handle Type.
*
*/
typedef Interface<SchedulerImpl> SchedulerInterf;

/**
* \brief
*  Handle for a Scheduler object.
*
*/
class Scheduler : public Model, public SchedulerInterf
{
public:
    string timerId; ///< Scheduler identifier

    /// Default constructor
    ///
    Scheduler(void){}

    /// Gets the Event object on the head of the Event-Message queue
    /// \return A copy to the Event object on Event-Message head
    Event getEvent( ) { return SchedulerInterf::pImpl_->getEvent( );}

    /// Executes the Scheduler object. Only one simulation time step is executed.
    /// Therefore, just the Message on the head of the Scheduler queue is executed.
    /// \return A reference to Event object which has triggered the Message object
    Event& execute() { return SchedulerInterf::pImpl_->execute(); }

    /// Executes the Scheduler object. Messages are executed until the end simulation time has been reached or
    /// until the Event-Message queue becomes empty.
    /// \param finalTime is a real number representing the end simulation time
    /// \return A real number meaning the Scheduler internal clock
    double execute( double& finalTime ) { return SchedulerInterf::pImpl_->execute(finalTime); }

    /// Pauses the Scheduler. NOT IMPLEMENTED.
    void pause( ){ SchedulerInterf::pImpl_->pause(); }

    /// Stops the Scheduler. NOT IMPLEMENTED
    void stop( ){ SchedulerInterf::pImpl_->stop(); }

    /// Adds a new pair Event-Message to the Scheduler queue.
    /// \param event is a reference to the Event being added
    /// \param message is a pointer to message being linked to the Event
    void add( Event& event, Message* message ){ SchedulerInterf::pImpl_->add(event, message); }

    /// Return true if the Event-Message queue is empty.
    /// \return A boolean value: returns true if the Scheduler queue is empty, otherwise returns false.
    bool empty( void ) { return SchedulerInterf::pImpl_->empty(); }

    /// Resets the Scheduler simulation time
    void reset( void ) { SchedulerInterf::pImpl_->reset(); }

    ///Sets the Scheduler simulation time
    /// \param time is a double value representing the current simulation time
    void setTime( double time ) { SchedulerInterf::pImpl_->setTime( time ); }

    ///Gets the Scheduler simulation time
    double getTime() { return SchedulerInterf::pImpl_->getTime(); }
};  
#endif
