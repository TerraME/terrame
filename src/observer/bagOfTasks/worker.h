#ifndef WORKER_H
#define WORKER_H

#include <QThread>
#include <QWaitCondition>
#include <QMutex>
#include <QPair>

namespace BagOfTasks {

class Task;

class Worker : public QThread
{
public:
    // enum Status {Busy, Idle};

    Worker(QWaitCondition &waitCond, QMutex &mutex);
    // Worker(QList<Task *> &bag, QWaitCondition &waitCond, QMutex &mutex);
    virtual ~Worker();

    void run();
    // inline void setStatus(Status s) { status = s; }
    // inline Status getStatus() { return status; }

    inline int getId() const { return id; }

private:
    friend class TaskManager;
	/**
     * Stops the thread execution
     */
    void stop();
	
	/**
     * Kills the thread
     */
    void finish();

    QWaitCondition &waitCondition;
    QMutex &mutex;

    int id;
    bool abort, reset;
    // Status status;

#ifdef UNIT_TME_TEST
    friend class BagOfTaskTest;
#endif
};

} // namespace BagOfTasks

#endif // WORKER_H

