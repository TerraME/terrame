#include "worker.h"
#include "task.h"
#include "taskManager.h"

#include <QDebug>
#include <QMutexLocker>
#include <iostream>

using namespace BagOfTasks;

static int workerCount = 0;

Worker::Worker(QWaitCondition &waitCond, QMutex &mtex)
    : waitCondition(waitCond), mutex(mtex)
{
    abort = false;

    workerCount++;
    id = workerCount;

    start(); // QThread::NormalPriority)
    // start(QThread::HighPriority);
    // start(QThread::HighestPriority);
}

Worker::~Worker()
{
    QMutexLocker locker(&mutex);
    abort = true;
    // waitCondition.wakeAll(); // done by the destructor of TaskManager
    locker.unlock();
    if (! wait(1000))
    {
        if(! wait(3000))
        {
            terminate();
            qWarning("Wait time of thread exceeded. This may occur when \"autoclose\"\n"
                    "flag has been used and caused the freezing of the current task.");
        }
    }

#ifdef UNIT_TME_TEST_PRINT
    qDebug() << "Worker" << id << "destroyed!!!!!"; std::cout.flush();
#endif
}

void Worker::run()
{
    bool empty = true;
    Task *task = 0;
    TaskManager &manager = TaskManager::getInstance();

#ifdef UNIT_TME_TEST_PRINT
    qDebug() << "worker" << id << "started"; std::cout.flush();
#endif

    QMutexLocker locker(&mutex);
    while(! abort)
    {
        while(! empty)
        {
            task = manager.getTask(id);
            locker.unlock();

            if (abort)
                break;

            if (task)
            {
                try
                {
                    task->execute();
                  
                    switch (task->getType())
                    {
                        // TODO: This causes problems in 'join' of TaskManager?

                        // Re-inserts the task in the bag because
                        // TaskManager manages the task priority
                         case Task::Continuous:
                            // qDebug() << this << "====" ;
                            TaskManager::getInstance().add(task);
                            // qDebug() << "\n TaskManager::getInstance().add(task); <<<<<<<<<<<<<<<<<<<\n";
                            break;

                        case Task::Arbitrary:
                            break;

                        // Frees the memory used by task
                        // case Task::Once:
                        default:
                            delete task;
                            task = 0;
                    }
                }
                catch(...)
                {

                }
            }
            locker.relock();
            empty = manager.isEmpty();
         }

        locker.relock();
        // waitCondition.wakeOne();

#ifdef UNIT_TME_TEST_PRINT
        if (empty)
        {
            qDebug() << "worker" << id << "sleeping"; std::cout.flush();
            waitCondition.wait(&mutex);
            qDebug() << "worker" << id << "woken up"; std::cout.flush();
        }
#else
        if (empty)
            waitCondition.wait(&mutex);
#endif

        // Workers woken up but is bag realy empty?
        empty = manager.isEmpty();
    }
}

//void Worker::wake()
//{
//    mutex.lock();
//    waitCondition.wakeAll();
//    mutex.unlock();
//}

void Worker::stop()
{
    QMutexLocker locker(&mutex);
    abort = true;
}

void Worker::finish()
{
    quit();
}

