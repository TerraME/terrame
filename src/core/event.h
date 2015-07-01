/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright Â© 2001-2008 INPE and TerraLAB/UFOP.

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

//  Eventos sï¿½o estï¿½mulos aos quais o sistema sendo simulado deve
//  responder ou estï¿½mulos que disparam aï¿½ï¿½es de controle do simulador. Uma aï¿½ï¿½o
//  de controle comum ï¿½ o cï¿½lculo e o salvamento, periï¿½dico, de informaï¿½ï¿½es
//  estatï¿½scas na base de dados do simulador. Informacoes sobre os agentes tambï¿½m,
//  sao importantes. Exemplos de eventos aos quais os
//  sistemas simulados geralmente precisam responder sï¿½o: um usuï¿½rio realiza uma
//  operaï¿½ï¿½o de entrada de dados ou um processo do sistema simulado solicita
//  informaï¿½ï¿½es a outro processo.
//    Todo evento possui um tipo que o identifica e define qual rotina deve ser
//    chamada para tratï¿½-lo. Todo evento deve registrar o momento em que deve
//    ocorrer.


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

/**
 * \brief
 *  Implementation for a Event object.
 *
 */
class EventImpl : public Implementation
{
    float time_; ///< instant in which the Events must occurs
    float period_; ///<  peridiocity in which the Event must occurs
    int	  priority_; /// Event piority (default value = 0)  Higher numbers means lower  priority.
    /// The normal priority is 0(zero).
public:

    /// Default constructor
    EventImpl( void ) { time_ = 0, period_ = 1, priority_ = 0; }

    /// Sets the Event instant to occur
    /// \param eventTime is the moment to the Event happens
    void setTime( float eventTime ) { time_ = eventTime; }

    /// Gets the instant the Event is programmed to happen
    /// \return  A float valeu representing the next instant the Event will happen
    float getTime( ) { return time_; }

    /// Sets the Event priority.
    /// \param priority is a integer nunber. Higher numbers means lower  priority. The normal priority is 0(zero).
    void setPriority(int priority ) { priority_ = priority; }

    /// Gets the Event prioritty
    /// \return A integer value representing the Event priority.  Higher numbers means lower  priority. The normal
    /// priority is 0(zero).
    int getPriority( void ) { return priority_; }

    /// Configures the Event.
    /// \param eventTime is the time instant in which the Event must occurs
    /// \param eventFrequency is the peridiocity in which the Event must occurs
    /// \param priority is the priority in which the event mus occurrs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    void config( float eventTime, float eventFrequency, int priority ) {
        period_ = eventFrequency > 0 ? eventFrequency : 0;
        time_      = eventTime > 0 ? eventTime : 0;
        priority_ = priority;
    }

    /// Gets the peridiocity in which the Event is programmed to happens
    /// \return A float number representing the Event peridiocity in time
    float getPeriod( ) { return period_; }

    /// Sets the peridiocity in which the Event must occurs in time
    /// \param period is the real number representing the peridiocity in which the Event mus occurs
    void setPeriod( float period ) { period_ = period; }

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
class Event : public Model, public EventInterf
{
public:


    /// Constructor.
    /// \param time is the time instant in which the Event must occurs
    /// \param period is the peridiocity in which the Event must occurs
    /// \param priority is the priority in which the event mus occurrs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    Event(float time = 0, float period = 1, float priority = 0){
        EventInterf::pImpl_->setTime( time );
        EventInterf::pImpl_->setPeriod( period );
        EventInterf::pImpl_->setPriority(  priority );
    }

    /// HANDLE - Gets the instant the Event is programmed to happen
    /// \return  A float valeu representing the next instant the Event will happen
    float getTime( ) { return EventInterf::pImpl_->getTime(); }

    /// HANDLE - Configures the Event object.
    /// \param time is the time instant in which the Event must occurs
    /// \param frequency is the peridiocity in which the Event must occurs
    /// \param priority is the priority in which the event mus occurrs
    ///        Higher numbers means lower  priority. The normal priority is 0(zero).
    void config( float time, float frequency, int priority ) { EventInterf::pImpl_->config( time, frequency, priority ); }

    /// HANDLE - Gets the peridiocity in which the Event is programmed to happens
    /// \return A float number representing the Event peridiocity in time
    float getPeriod( ) { return EventInterf::pImpl_->getPeriod(); }

    /// HANDLE - Gets the instant the Event is programmed to happen
    /// \return  A float valeu representing the next instant the Event will happen
    void setTime( float time ) { EventInterf::pImpl_->setTime( time ); }

    /// HANDLE - Sets the peridiocity in which the Event must occurs in time
    /// \param period is the real number representing the peridiocity in which the Event mus occurs
    void setPeriod( float period ) { EventInterf::pImpl_->setPeriod( period ); }

    /// HANDLE - Sets the Event priority.
    /// \param priority is a integer nunber. Higher numbers means lower  priority. The normal priority is 0(zero).
    void setPriority(int priority ) {  EventInterf::pImpl_->setPriority(priority); }

    /// HANDLE - Gets the Event prioritty
    /// \return A integer value representing the Event priority.  Higher numbers means lower  priority. The normal
    /// priority is 0(zero).
    int getPriority( void ) { return EventInterf::pImpl_->getPriority(); }

};

/// Compares Event objects. 
/// \param e1 is a Event object
/// \param e2 is a Event object
/// \return A booleÃ n valus:  true if e1 must occur earlier than e2, false otherwise.
bool operator<(Event e1, Event e2 );

#endif
