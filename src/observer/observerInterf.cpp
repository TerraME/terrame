#include "observerInterf.h"
#include "observerImpl.h"

//////////////////////////////////////////////////////////// Observer
ObserverInterf::ObserverInterf()
{
}

ObserverInterf::ObserverInterf( Subject* subj )
{
    ObserverInterf::pImpl_->setSubject(subj);
    ObserverInterf::pImpl_->setObsHandle(this);
}

ObserverInterf::~ObserverInterf()
{
}

void ObserverInterf::setVisible(bool b)
{
    ObserverInterf::pImpl_->setVisible(b);
}

bool ObserverInterf::getVisible()
{
    return ObserverInterf::pImpl_->getVisible();
}

bool ObserverInterf::update(double time)
{
    return Interface<ObserverImpl>::pImpl_->update(time);
}

int ObserverInterf::getId()
{
    return Interface<ObserverImpl>::pImpl_->getId();
}

const TypesOfObservers ObserverInterf::getType()
{
    return Interface<ObserverImpl>::pImpl_->getObserverType();
}

QStringList ObserverInterf::getAttributes()
{
    return Interface<ObserverImpl>::pImpl_->getAttributes();
}

void ObserverInterf::setModelTime(double time)
{
    Interface<ObserverImpl>::pImpl_->setModelTime(time);
}

void ObserverInterf::setDirtyBit()
{
    Interface<ObserverImpl>::pImpl_->setDirtyBit();
}



////////////////////////////////////////////////////////////  Subject

void SubjectInterf::attach(Observer* obs)
{
    SubjectInterf::pImpl_->attachObserver(obs);
}

void SubjectInterf::detach(Observer* obs)
{
    SubjectInterf::pImpl_->detachObserver(obs);
}

Observer * SubjectInterf::getObserverById(int id)
{
    return SubjectInterf::pImpl_->getObserverById(id);
}

void SubjectInterf::notify(double time) 
{
    SubjectInterf::pImpl_->notifyObservers(time);
}

int SubjectInterf::getId() const
{
    return SubjectInterf::pImpl_->getId();
}
