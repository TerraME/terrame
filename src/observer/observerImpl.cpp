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

#include "observerImpl.h"
#include "observerInterf.h"

#include <time.h>

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
#endif

#include "components/legend/legendAttributes.h"

//#include <iostream>
#include <string>
#include <QApplication>
#include <QBuffer>
#include <QByteArray>
#include <QDebug>

using namespace TerraMEObserver;

const char *const observersTypesNames[] =
{
    "", "TextScreen", "LogFile", "Table", "Graphic",
    "DynamicGraphic", "Map", "UDPSender", "Scheduler",
    "Image", "StateMachine", "Player"
};

const char *const subjectTypesNames[] =
{
    "", "Cell", "CellularSpace", "Neighborhood", "Timer",
    "Event", /*"Message",*/ "Trajectory", "Automaton", "Agent",
    /* "State", "JumpCondition", "FlowCondition",*/ "Environment"
};

const char *const dataTypesNames[] =
{
    "Bool", "Number", "DateTime", "Text"
};

const char *const groupingModeNames[] =
{
    "EqualSteps", "Quantil", "StdDeviation", "UniqueValue"
};

const char *const stdDevNames[] =
{
    "Full", "Half", "Quarter"
};


// const char *getSubjectName(TypesOfSubjects type)
const char *getSubjectName(int type)
{
    return(type == TObsUnknown) ? "Unknown" : subjectTypesNames[type];
}

//const char *getObserverName(TypesOfObservers type)
const char *getObserverName(int type)
{
    return(type == TObsUndefined) ? "undefined" : observersTypesNames[type];
}

//const char *getDataName(TypesOfData type)
const char *getDataName(int type)
{
    return(type == TObsUnknownData) ? "UnknownData" : dataTypesNames[type];
}

//const char *getGroupingName(GroupingMode type)
const char *getGroupingName(int type)
{
    return groupingModeNames[type];
}

//const char *getStdDevNames(StdDev type)
const char *getStdDevNames(int type)
{
    return(type == TObsNone) ? "None" : stdDevNames[type];
}



bool sortAttribByType(Attributes *a, Attributes *b)
{
    return a->getType() < b->getType();
}

bool sortByClassName(const QPair<Subject *, QString> & pair1,
    const QPair<Subject *, QString> & pair2)
{
    return pair1.second.toLower() < pair2.second.toLower();
}

void delay(float seconds)
{
    clock_t endwait;
    endwait = clock() + seconds * CLOCKS_PER_SEC;
    while (clock() < endwait)
        qApp->processEvents();
}

// mantem o numero de observer j? criados
static long int numObserverCreated = 0;
static long int numSubjectCreated = 0;

void restartObserverCounter()
{
	numObserverCreated = 0;
	numSubjectCreated = 0;
}

//////////////////////////////////////////////////////////// Observer
ObserverImpl::ObserverImpl() : visible(true)
{
    numObserverCreated++;
    observerID = numObserverCreated;
}

ObserverImpl::ObserverImpl(const ObserverImpl &other)
{
    if (this != &other)
    {
        observerID = other.observerID;
        visible = other.visible;

        delete subject_;
        delete obsHandle_;

        subject_ = other.subject_;
        obsHandle_ = other.obsHandle_;
    }
}

ObserverImpl & ObserverImpl::operator=(ObserverImpl &other)
{
    if (this == &other)
        return *this;

    observerID = other.observerID;
    visible = other.visible;

    delete subject_;
    delete obsHandle_;

    subject_ = other.subject_;
    obsHandle_ = other.obsHandle_;

    return *this;
}

ObserverImpl::~ObserverImpl()
{
    bool thereAreOpenWidgets = false;
    foreach(QWidget *widget, QApplication::allWidgets())
    {
        if (widget)
            thereAreOpenWidgets = true;
    }
    if (!thereAreOpenWidgets)
        QApplication::exit();
}

bool ObserverImpl::update(double time) // ver se passa realmente este par?metro aqui
{
    // if (! obsHandle_->getVisible())
    //    return false;

    if (obsHandle_->getType() == TObsDynamicGraphic)
        obsHandle_->setModelTime(time);

    // recupera a lista de atributos em observa??o
    QStringList attribList = obsHandle_->getAttributes();

#ifdef TME_BLACK_BOARD

    // getState via BlackBoard
    QDataStream& state = BlackBoard::getInstance().getState(subject_, obsHandle_->getId(), attribList);

    state.device()->open(QIODevice::ReadOnly);
    obsHandle_->draw(state);
    state.device()->close();

#else  // TME_BLACK_BOARD

    // getState feito a partir do subject
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    QDataStream out(&buffer);

    buffer.open(QIODevice::WriteOnly);

    QDataStream& state = subject_->getState(out, subject_, obsHandle_->getId(), attribList);

    buffer.close();
    buffer.open(QIODevice::ReadOnly);
    obsHandle_->draw(state);
    buffer.close();

#endif  // TME_BLACK_BOARD

    return true;
}

bool ObserverImpl::getVisible()
{
    return ObserverImpl::visible;
}

void ObserverImpl::setVisible(bool visible)
{
    ObserverImpl::visible = visible;
}

void ObserverImpl::setSubject(TerraMEObserver::Subject *s)
{
    subject_ = s;
}

void ObserverImpl::setObsHandle(Observer* obs)
{
    obsHandle_	= obs;
    subject_->attach(obs);
}

const TypesOfObservers ObserverImpl::getObserverType()
{
    return obsHandle_->getType();
}

int ObserverImpl::getId()
{
    return observerID;
}

QStringList ObserverImpl::getAttributes()
{
    return QStringList();
}

void ObserverImpl::setModelTime(double time)
{
    obsHandle_->setModelTime(time);
}

void ObserverImpl::setDirtyBit()
{
    // TO DO: Not finished the use of dirty bit flag
    // obsHandle_->setDirtyBit();
}


////////////////////////////////////////////////////////////  Subject
SubjectImpl::SubjectImpl()
{
    numSubjectCreated++;
    subjectID = numSubjectCreated;
}

SubjectImpl::SubjectImpl(const SubjectImpl &other)
{
    if (this != &other)
    {
        observers.clear();
        ObsList &obs =(ObsList &) other.observers;
        ObsListIterator i = obs.begin();
        for (; i != obs.end(); ++i)
            observers.push_back(*i);
    }
}

SubjectImpl & SubjectImpl::operator=(SubjectImpl &other)
{
    if (this == &other)
        return *this;

    observers.clear();
    ObsList &obs =(ObsList &) other.observers;
    ObsListIterator i = obs.begin();
    for (; i != obs.end(); ++i)
        observers.push_back(*i);

    return *this;
}

SubjectImpl::~SubjectImpl()
{
}

void SubjectImpl::attachObserver(Observer* obs)
{
    observers.push_back(obs);
}

void SubjectImpl::detachObserver(Observer* obs)
{
    observers.remove(obs);
}

Observer * SubjectImpl::getObserverById(int id)
{
    Observer *obs = 0;

    for (ObsListIterator i(observers.begin()); i != observers.end(); ++i)
    {
        if ((*i)->getId() == id)
        {
            obs = *i;
            break;
        }
    }
    return obs;
}

void SubjectImpl::notifyObservers(double time)
{
#ifdef TME_BLACK_BOARD
    BlackBoard::getInstance().setDirtyBit(getId());
#endif

    ObsList detachList;

    for (ObsListIterator i(observers.begin()); i != observers.end(); ++i)
    {
        if (!(*i)->update(time))
        {
            detachList.push_back(*i);
        }
    }
}

const TypesOfSubjects SubjectImpl::getSubjectType()
{
    return TObsUnknown;
}

int SubjectImpl::getId() const
{
    return subjectID;
}

