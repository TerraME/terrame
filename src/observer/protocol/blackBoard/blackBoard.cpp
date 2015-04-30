#include "blackBoard.h"
#include "observer.h"
#include "subjectAttributes.h"
#include "decoder.h"

#include <iostream>
#include <algorithm>

#include <QDataStream>
#include <QBuffer>
#include <QByteArray>
#include <QDebug>

#include <QThread>
#include <QWaitCondition>
#include <QMutex>

#define TME_BLACK_BOARD_CONTROL //_OFF

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Performance Statistics
	#include "statistic.h"
#endif

#include "task.h"
#include "taskManager.h"

using namespace TerraMEObserver;


class TerraMEObserver::Control : public BagOfTasks::Task
{
public:
    Control(QHash<int, SubjectAttributes *> &cache) 
        : cache(cache), BagOfTasks::Task()
    {
        abort = false;
        setType(Task::Arbitrary);
    }

    ~Control()
    {
        abort = true;
    }

    bool execute()
    {
        QList<SubjectAttributes *> subjAttrList = cache.values();
        qSort(subjAttrList.begin(), subjAttrList.end(), qLess<SubjectAttributes *>());

        BlackBoard &bb = BlackBoard::getInstance();
        // long recentTime = subjAttrList.front()->getTime();
        int count = 0;
        int removed = 0;
        const int PERC = (int)(subjAttrList.size() * 0.1);

        while (! abort)
        {
            SubjectAttributes *subjAttr = subjAttrList.takeLast(); // gets item from heap
            count++;

            if (removed >= PERC)
                break;

            if (subjAttr)
            {
                bb.removeSubject(subjAttr->getId());
                subjAttr = 0;
                removed++;
			}
        }
        //std::cout << "\ncontrol run end\n";
        return true;
    }

    inline void start()
    {
        BagOfTasks::TaskManager::getInstance().add(this);
    }

    inline void stop()
    {
        abort = true;
    }

private:
    bool abort; //, sleeping;
    // QMutex mutex;
    QHash<int, SubjectAttributes *> &cache;
};

//// end control

BlackBoard::BlackBoard()
{
    protocolDecoder = new Decoder();
    protocolDecoder->setBlackBoard(this);

    locker = new QReadWriteLock();
    control = new Control(cache);

    percent = (double) 0.8;
    countChangedSubjects = 0;
    canDrawState = false;

    deletedSubjects = 0;
    data = 0;
    state = 0;
}

BlackBoard::~BlackBoard()
{
	//@RAIAN: Commented as temporary solution. Pointer is being destroyed also in the destructor of TaskManager,
	// gerando um segmentation fault nesta linha quando tenta destruir pela segunda vez. A possible solution is
	// to overload the 'operator =' of the class so that when assign, copy the object, not just the pointer. TEST THIS SOLUTION.
//    if (control) { delete control; control = 0; }
	//RAIAN: END

    foreach(SubjectAttributes *c, cache)
    {
        delete c;
        c = 0;
	}

    if (data) { delete data; data = 0; }
    if (state) { delete state; state = 0; }
    if (deletedSubjects) { delete deletedSubjects; deletedSubjects = 0; }

    if (locker) { delete locker; locker = 0; }
}

BlackBoard & BlackBoard::getInstance()
{
    static BlackBoard blackBoard;
    return blackBoard;
}

void BlackBoard::setDirtyBit(int subjectId)
{
    if (cache.contains(subjectId))
        cache.value(subjectId)->setDirtyBit(true);
    // else
    // cache.insert(subjectId, new PrivateCache());
}

bool BlackBoard::getDirtyBit(int subjectId) const 
{
    if (cache.contains(subjectId))
        return cache.value(subjectId)->getDirtyBit();
    return false;
}

QDataStream & BlackBoard::getState(Subject *subj, int observerId, const QStringList &attribs)
{
    SubjectAttributes *subjAttr = cache.value(subj->getId());

    if (! subjAttr)
        qFatal("BlackBoard::getState() - Error: The Subject '%i' (%s) not found in BlackBoard", 
            subj->getId(), getSubjectName(subj->getType()) );

    if (! subjAttr->getDirtyBit())
    {
        // TO-DO: Prevents the same image to be redesigned
        // state->device()->close();
        return *state;
    }

    delete data;
    delete state;
    data = new QByteArray();
    state = new QDataStream(data, QIODevice::WriteOnly);
	
    state = &subj->getState(*state, subj, observerId, attribs);
    state->device()->close();

    // The state is now available
    state->device()->open(QIODevice::ReadOnly);
	
    QByteArray msg;
    (*state) >> msg;

    // canDrawState = false;
	
    if (! msg.isEmpty())
    {
        canDrawState = protocolDecoder->decode(msg);
        
        if (! canDrawState)
        {
            if (! msg.isEmpty())
                qWarning("Failed on decode state. SubjectId: '%i'", subj->getId());
            else
                qWarning("Any state to decode. SubjectId: '%1'",subj->getId());
        }
    }

    subjAttr->setDirtyBit(false);
    
#ifdef DEBUG_OBSERVER
    foreach(SubjectAttributes *attr, cache.values())
        qDebug() << attr->getId() << ": " << attr->toString();
#endif

    return *state;
}

//Attributes & BlackBoard::addAttribute(int subjectId, const QString & name, double width, double height)
//{
//    SubjectAttributes *subjAttr = 0;
//
//    if (! cache.contains(subjectId) )
//    {
//        subjAttr = new SubjectAttributes(subjectId);
//        cache.insert(subjectId, subjAttr);
//    }
//    else
//    {
//        subjAttr = cache.value(subjectId);
//    }
//    // return subjAttr->addAttribute(name, width, height);
//    return (Attributes &)*(new Attributes(name, width, height));
//}

SubjectAttributes * BlackBoard::addAttribute(int subjectId, const QString & name)
{
    SubjectAttributes *subjAttr = 0;
    subjAttr = insertSubject(subjectId);
    subjAttr->addItem(name);
    return subjAttr;
}

//Attributes & BlackBoard::getAttribute(int subjectId, const QString & name)
//{
//    // SubjectAttributes *subjAttr = getSubject(subjectId);
//    // // return subjAttr->getAttribute(name);
//    return (Attributes &)*(new Attributes(name, 0, 0));
//}

//bool BlackBoard::removeAttribute(int subjectId, const QString & name)
//{
//    //SubjectAttributes *subjAttr = cache.value(subjectId);
//    //return subjAttr->removeAttribute(name);
//    return false;
//}

void BlackBoard::addSubject(int subjectId)
{
    if(!cache.contains(subjectId))
    {
        SubjectAttributes *subjAttr = new SubjectAttributes(subjectId);

        //qDebug() << "deletedSubjects: " << deletedSubjects;

        if(deletedSubjects && deletedSubjects->contains(subjectId))
        {
            QPair<double, double> coord = deletedSubjects->take(subjectId);
            subjAttr->setX(coord.first);
            subjAttr->setY(coord.second);
        }

        locker->lockForWrite();
        cache.insert(subjectId, subjAttr);
        locker->unlock();
    }
}

SubjectAttributes * BlackBoard::getSubject(int subjectId)
{
    SubjectAttributes *subjAttr = 0;

    if (cache.contains(subjectId) )
        subjAttr = cache.value(subjectId);
    return subjAttr;
}

bool BlackBoard::removeSubject(int subjectId)
{
    if (cache.contains(subjectId))
    {
        SubjectAttributes *subjAttr = cache.take(subjectId);

        if (! deletedSubjects)
            deletedSubjects = new QHash<int, QPair<double, double> >();

        deletedSubjects->insert(subjectId, qMakePair(subjAttr->getX(), subjAttr->getY()) );
        delete subjAttr; subjAttr = 0;

        return true;
    }
    return false;
}

//QHash<QString, Attributes *>& BlackBoard::getAttributeHash(int subjectId)
//{
//    addSubject(subjectId);
//    // return cache.value(subjectId)->getAttributeHash();
//
//    return (QHash<QString, Attributes *> &)*(new QHash<QString, Attributes *>());
//}

bool BlackBoard::decode(const QByteArray &msg)
{
    canDrawState = protocolDecoder->decode(msg);
    return canDrawState;
}

//QByteArray & BlackBoard::serialize(int subjectId, QByteArray &data, const QStringList &attributes)
//{
//    //SubjectAttributes *subjAttr = cache.value(subjectId);
//    //return subjAttr->serialize(data, attributes);
//    qDebug() << "Metodo DESATIVADO";
//    qDebug() << "BlackBoard::serialize(int subjectId, QByteArray &data, const QStringList &attributes)";
//
//    return (QByteArray &)*(new QByteArray);
//} 

void BlackBoard::startControl()
{ 
#ifdef TME_STATISTIC
    Statistic::getInstance().addOccurrence("countChangedSubjects", countChangedSubjects);
#endif

#ifdef TME_BLACK_BOARD_CONTROL
    if (control && renderingOnlyChanges())
        control->start();
#endif
}

void BlackBoard::stopControl()
{
#ifdef TME_BLACK_BOARD_CONTROL
    if (control)
        control->stop();
#endif
}

bool BlackBoard::renderingOnlyChanges() const
{
    // Draw the changes only if the 'n' of changed objects
    // is less than X% of the cache size

    // return countChangedSubjects < (cache.size() * ( 1 - PERCENT));
    return countChangedSubjects < (cache.size() * percent);
}

void BlackBoard::setPercent(double p)
{
    percent = p;
}

void BlackBoard::clear()
{
    stopControl();

    foreach(SubjectAttributes *c, cache)
    {
        delete c; 
        c = 0;
    }
    cache.clear();

    countChangedSubjects = 0;
    canDrawState = false;

    if (data) { delete data; data = 0; }
    if (state) { delete state; state = 0; }
    if (deletedSubjects) { delete deletedSubjects; deletedSubjects = 0; }
    if (locker) { delete locker; locker = 0; }

    locker = new QReadWriteLock();
}
