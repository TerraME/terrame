/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

/*!
 * \file observerInterf.h
 * \brief Design Pattern Subject and Observer handles.
 * \author Antonio Jose da Cunha Rodrigues 
 * \author Tiago Garcia de Senna Carneiro
*/

#ifndef OBSERVER_INTERF
#define OBSERVER_INTERF

#include "bridge.h"
#include "observer.h"
#include "observerImpl.h"

#include <stdarg.h>
#include <string.h>
#include <list>
#include <iterator>
#include <QtCore/QDataStream>
#include <QtCore/QDateTime>

using namespace TerraMEObserver;

class SubjectInterf;
struct lua_State;

#ifdef TME_PROTOCOL_BUFFERS
namespace ObserverDatagramPkg
{
    class SubjectAttribute;
}
#endif

//static long int numObserverCreated = 0;

/**
* \brief  
*  Handle for a Observer object.
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
    bool getVisible() const;

    /**
     * \copydoc TerraMEObserver::Observer::draw
     */
    virtual bool draw(QDataStream& state) = 0;

    /**
     * \copydoc TerraMEObserver::Observer::getType
     */
    virtual const TypesOfObservers getType() const = 0;

    /**
     * \copydoc TerraMEObserver::Observer::getSubjectType
     */
    virtual const TypesOfSubjects getSubjectType() const;

    /**
     * \copydoc TerraMEObserver::Observer::setModelTime
     */
    virtual void setModelTime(double time);

    /**
     * \copydoc TerraMEObserver::Observer::getId
     */
    int getId() const;

    /**
     * \copydoc TerraMEObserver::Observer::getSubjectId
     */
    int getSubjectId() const;

    /**
     * \copydoc TerraMEObserver::Observer::getAttributes
     */
    virtual QStringList getAttributes() = 0;

    /**
     * \copydoc TerraMEObserver::Observer::setDirtyBit
     */
    void setDirtyBit();

    /**
     * \copydoc TerraMEObserver::Observer::close
     */
    virtual int close();

protected:
    /* *
    * \copydoc TerraMEObserver::Observer::setId
    */
    // virtual void setId(int);
};

////////////////////////////////////////////////////////////  Subject

/*
** \class SubjectInterf
** \author Antonio Jose da Cunha Rodrigues
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
     * Destructor
     */
    virtual ~SubjectInterf();

    /**
     * \copydoc TerraMEObserver::Subject::attach
     */
    void attach(Observer *);

    /**
     * \copydoc TerraMEObserver::Subject::detach
     */
    void detach(Observer *);

    /**
     * \copydoc TerraMEObserver::Subject::getObserverById
     */
    Observer* getObserverById(int id);

    /**
     * \copydoc TerraMEObserver::Subject::notify
     */
    void notify(double time = 0);

    /**
     * \copydoc TerraMEObserver::Subject::getState
     */
    virtual QDataStream& getState(QDataStream &state, Subject *subj,
                                  int observerId, const QStringList &attribs) = 0;
    
    /**
     * \copydoc TerraMEObserver::Subject::getType
     */
    virtual const TypesOfSubjects getType() const = 0;

    /**
     * \copydoc TerraMEObserver::Subject::getId
     */
    int getId() const;

    /**
     *  Gets the attributes of Lua stack
     * \param attribs the list of attributes observed
     */
#ifdef TME_PROTOCOL_BUFFERS
    virtual QByteArray pop(lua_State *L, const QStringList& attribs, ObserverDatagramPkg::SubjectAttribute *subj,
        ObserverDatagramPkg::SubjectAttribute *parentSubj)
    {  Q_UNUSED(L); Q_UNUSED(attribs); Q_UNUSED(subj); Q_UNUSED(parentSubj);
        return ""; }
#else
    virtual QByteArray pop(lua_State *L, const QStringList& attribs)
    { Q_UNUSED(L); Q_UNUSED(attribs);
      return ""; }
#endif

protected:
    /**
    * \copydoc TerraMEObserver::Subject::setId
    */
    virtual void setId(int);

#ifdef TME_PROTOCOL_BUFFERS
    virtual QByteArray getAll(QDataStream& in, const QStringList& attribs)
    { Q_UNUSED(in); Q_UNUSED(attribs); return ""; }
    virtual QByteArray getChanges(QDataStream& in, const QStringList& attribs)
    { Q_UNUSED(in); Q_UNUSED(attribs); return ""; }
#else
    virtual QByteArray getAll(QDataStream& in, int obsId, const QStringList& attribs)
    {   Q_UNUSED(in); Q_UNUSED(obsId); Q_UNUSED(attribs);
        return ""; }
    virtual QByteArray getChanges(QDataStream& in, int obsId, const QStringList& attribs)
    {   Q_UNUSED(in); Q_UNUSED(obsId); Q_UNUSED(attribs);
        return ""; }
#endif

};

#endif

