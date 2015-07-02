#include "taskManager.h"

#include "worker.h"

#include <QPair>
#include <QDebug>
#include <QMutexLocker>

#include <iostream>
using namespace std;

extern int WORKERS_NUMBER;

using namespace BagOfTasks;

namespace BagOfTasks {

inline bool operator<(int priority, const QPair<Task *, int> &t)
{
    return t.second < priority;
}
inline bool operator<(const QPair<Task *, int> &t, int priority)
{
    return priority < t.second;
}

}  // using namespace BagOfTasks;

TaskManager& TaskManager::getInstance()
{
    static TaskManager taskManager;
    return taskManager;
}

TaskManager::TaskManager()
{
    // Marks the position of worker that was requested
    // by user and make a uniform distribution among them
    requestedWorkerPos = -1;

    sync = false;

    int threadCount = QThread::idealThreadCount();

    // Do not count the main process
    int workersCount = (threadCount > 1 ? threadCount - 1 : 1);
    if((WORKERS_NUMBER > 0) && (WORKERS_NUMBER < workersCount))
    {
        if(WORKERS_NUMBER > 1)
            workersCount = WORKERS_NUMBER;
        else
            workersCount = 1;
    }

    // Starts workers for all cores identified (default) or
    // the number setted by "-workers" flag at main function
    while(workers.size() < workersCount)
    {
        Worker *worker = new Worker(waitCondition, mutex);
        workers.append(worker);
    }

}

TaskManager::TaskManager(const TaskManager &)
{
}

TaskManager& TaskManager::operator=(const TaskManager &)
{
    return *this;
}

TaskManager::~TaskManager()
{
    // issue #537
    //    VisualArrangement* v = VisualArrangement::getInstance();
    //    qDebug() << "2------------------------------";
    //    v->buildLuaCode();

    for(int i = 0; i < workers.size(); i++)
    {
        if (workers.at(i)->isRunning())
        {
            workers.at(i)->stop();
            waitCondition.wakeAll();

            if (!workers.at(i)->wait(5000))
            {
                workers.at(i)->terminate();
                workers.at(i)->wait();
            }
        }
    }

#ifdef UNIT_TME_TEST_PRINT
    qDebug() << "bagOfTasks.size()" << bagOfTasks.size();
    qDebug() << "~TaskManager()"; std::cout.flush();
#endif
}

// #include <qthreadpool.h>
void TaskManager::add(Task *task)
{
    QMutexLocker locker(&mutex);
    QList<QPair<Task *, int> >::iterator pos =
            qUpperBound(bagOfTasks.begin(), bagOfTasks.end(), (int)task->getPriority());

    bagOfTasks.insert(pos, qMakePair(task, (int)task->getPriority()));

    // waitCondition.wakeOne();
    if (!sync)
        waitCondition.wakeOne();
    // //    waitCondition.wakeAll();
}

bool TaskManager::join(int /*timeout*/)
{
//    QMutexLocker locker(&mutex);
//    if (timeout < 0) {
//        while (!(bagOfTasks.isEmpty() && activeThreads == 0))
//            noActiveThreads.wait(locker.mutex());
//    }
//    else
//    {
//        QElapsedTimer timer;
//        timer.start();
//        int t;
//        while (!(bagOfTasks.isEmpty() && activeThreads == 0) &&
//               ((t = timeout - timer.elapsed()) > 0))
//            noActiveThreads.wait(locker.mutex(), t);
//    }

//    bool ret = bagOfTasks.isEmpty();

//    return ret && activeThreads == 0;

    return false;
}

const Worker * TaskManager::getWorker()
{
    requestedWorkerPos = (requestedWorkerPos < workers.size() ?
        requestedWorkerPos + 1 : 0);
    return workers.at(requestedWorkerPos);
}

