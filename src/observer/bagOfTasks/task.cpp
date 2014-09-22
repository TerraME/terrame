#include "task.h"

#include "taskManager.h"
#include "worker.h"

#include <QThread>
#include <QDebug>

using namespace BagOfTasks;

static int taskCount = 0;

Task::Task(Priority priority) : priority(priority)
{
    taskCount++;
    id = taskCount;
    workerId = -1;

    // setType();
    type = Once;
}

Task::~Task()
{

}

const Worker * Task::runExclusively()
{
    const Worker *w = TaskManager::getInstance().getWorker();
    // setWorkerId(w->getId());
    workerId = w->getId();
    return w;
}
