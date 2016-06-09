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
 * \file observerInterf.h
 * \brief Design Pattern Subject and Observer handles.
 * \author Antonio Jos? da Cunha Rodrigues 
 * \author Tiago Garcia de Senna Carneiro
*/

#ifndef OBSERVER_INTERF
#define OBSERVER_INTERF

#include "../core/bridge.h"
#include "observer.h"
#include "observerImpl.h"

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
//#include <iostream>
#include <QtCore/QDataStream>
#include <QtCore/QDateTime>


using namespace TerraMEObserver;

class SubjectInterf;

// mantem o numero de observer j? criados
//static long int numObserverCreated = 0;

/**
* \brief  
*  Handle for a Observer object.
*
*/
class ObserverInterf :public Observer, public Interface<ObserverImpl>
{
public:
    /**
     * Default constructor
     */
    ObserverInterf();

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \see Subject
     */
    ObserverInterf(Subject *subj);

    /**
     * Destructor
     */
    virtual ~ObserverInterf();

    /**
     * \copydoc TerraMEObserver::Observer::update
     */
    virtual bool update(double time);

    /**
     * \copydoc TerraMEObserver::Observer::setVisible
     */
    void setVisible(bool visible);

    /**
     * \copydoc TerraMEObserver::Observer::getVisible
     */
    bool getVisible();

    /**
     * \copydoc TerraMEObserver::Observer::draw
     */
    virtual bool draw(QDataStream& state) = 0;

    /**
     * \copydoc TerraMEObserver::Observer::getType
     */
    virtual const TypesOfObservers getType() = 0;

    /**
     * \copydoc TerraMEObserver::Observer::setModelTime
     */
    virtual void setModelTime(double time);

    /**
     * \copydoc TerraMEObserver::Observer::getId
     */
    int getId();

    /**
     * \copydoc TerraMEObserver::Observer::getAttributes
     */
    virtual QStringList getAttributes() = 0;

    /**
     * \copydoc TerraMEObserver::Observer::setDirtyBit
     */
    void setDirtyBit();
};



////////////////////////////////////////////////////////////  Subject


/*
** \classe Subject
** \author Ant?nio Jos? da Cunha Rodrigues
** Baseado no padr?o Observer do livro "Padr?es de Projeto"
*/

/**
* \brief  
*  Handle for a Subject object.
*
*/
class SubjectInterf : public Subject, public Interface<SubjectImpl>
{
public:
    /**
     * \copydoc TerraMEObserver::Subject::attach
     */
    void attach(Observer *obs);

    /**
     * \copydoc TerraMEObserver::Subject::detach
     */
    void detach(Observer *obs);

    /**
     * \copydoc TerraMEObserver::Subject::getObserverById
     */
    Observer * getObserverById(int id);

    /**
     * \copydoc TerraMEObserver::Subject::notify
     */
    void notify(double time);

    /**
     * \copydoc TerraMEObserver::Subject::getState
     */
    virtual QDataStream& getState(QDataStream &state, Subject *subj,
                                  int observerId, QStringList &attribs) = 0;

    /**
     * \copydoc TerraMEObserver::Subject::getType
     */
    virtual const TypesOfSubjects getType() = 0;

    /**
     * \copydoc TerraMEObserver::Subject::getId
     */
    int getId() const;
};


#endif
