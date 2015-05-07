#ifndef TASKMANAGER_H
#define TASKMANAGER_H

#include <QHash>
#include <QVariant>
#include <QList>
#include <QVector>
#include <QWaitCondition>
#include <QMutex>

#include "task.h"

namespace BagOfTasks {

class Worker;

class TaskManager
{
public:
    static TaskManager & getInstance();
    virtual ~TaskManager();

    // Requester id
    template<class T>
    void addNewTask()
    {
        Task *task = new T();
        add(task);
    }

    void add(Task *);

    bool join(int timeout = -1);

    inline Task* getTask(int workerId)
    {
        // QMutexLocker locker(&mutex);  // Movido para o Worker

        Task * task = 0;

        if (! bagOfTasks.isEmpty())
        {
            // Task may be executed by any worker
            if (bagOfTasks.first().first->getWorkerId() < 0)
                return bagOfTasks.takeFirst().first;

            // Task can only be executed by the same worker
            if (bagOfTasks.first().first->getWorkerId() == workerId)
            {
                return bagOfTasks.takeFirst().first;
            }
            //else
            //{
            //    QList<QPair<Task *, int> >::iterator it = bagOfTasks.begin();
            //    for (; it != bagOfTasks.end(); ++it)
            //    {
            //        if((*it).first->getWorkerId() == workerId)
            //        {
            //            task = *it;
            //            break;
            //        }
            //    }

            //}
        }
        return task;
    }

    const Worker * getWorker();

    inline bool isEmpty()
    {
        // QMutexLocker locker(&mutex);  // Movido para o Worker
        return bagOfTasks.isEmpty();
    }

#ifndef UNIT_TME_TEST
private:
#endif
    TaskManager();
    TaskManager(const TaskManager &);
    TaskManager & operator=(const TaskManager &);

    // Pair of a Task and their priority
    QList<QPair<Task *, int> > bagOfTasks;
    QList<Worker *> workers;

    QWaitCondition waitCondition;
    QMutex mutex;
    bool sync;
    int requestedWorkerPos;

#ifdef UNIT_TME_TEST
    friend class BagOfTaskTest;
#endif
};

} // namespace BagOfTasks

#endif // TASKMANAGER_H

