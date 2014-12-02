#ifndef TASK_H
#define TASK_H

namespace BagOfTasks {

class Worker;

class Task
{
public:
    /**
     * @brief The Type enum indicates the way of
     * a task will be executed. The user needs control
     * the timelife for Arbitrary and Continuous types.
     *
     * @value Once default type and after execution this is deleted.
     *
     * @value Arbitrary its execution is arbitrarily and
     * may be executed again.
     * @value Continuous it is executated continuously
     *
     */
    enum Type {Once, Arbitrary, Continuous};

    /**
     * @brief The Priority enum indicates how the priority
     * a task will execute
     *
     * @value Highest scheduled as the first one task that will be executed
     * @value Hight  scheduled more often than Normal
     * @value Normal scheduled with default priority
     */

    /*
     * @value Low scheduled less often than Lowest
     * @value Lowest scheuled with minimum priority, may be not executed (Needs improvements)
     */
    enum Priority {Normal, Hight, Highest}; //, Low, Lowest};

    Task(Priority priority = Normal);
    virtual ~Task();
    virtual bool execute() = 0;

    inline int getId() const { return id; }

    inline void setType(Type type = Once) { this->type = type; }
    inline Type getType() const { return type; }

    inline void setPriority(Priority priority = Normal) { this->priority = priority; }
    inline Priority getPriority() const { return priority; }

    inline bool operator<(const Task &other) const { return priority < other.priority; }

    /** 
     * Identify what worker must be execute this task
     * Use it only when is necessary define what worker must be treat 
     * this task such as you are working with Sockets (TCP and UDP)
     * \param id of worker
     */
    inline int getWorkerId() const { return workerId; }

    /**
     * Allows and sets a worker that will execute this task.
     * Some task like socket task must be executed only by the same thread.
     */
    const Worker * runExclusively();

    // friend
    // inline bool lessPriority(const Task &a, const Task& b) const { return a.priority < b.priority; }
    // inline bool operator<(const Task &other) const { return priority < other.priority; }


protected:
    /* * 
     * Identify what worker must be execute this task
     * Use it only when is necessary define what worker must be treat 
     * this task such as you are working with Sockets (TCP and UDP)
     * \param id of worker
     */
    // inline void setWorkerId(int workerId = -1) { this->workerId = workerId; }


    Type type;
    Priority priority;
    int workerId;


private:
    int id;

};

}  // namespace BagOfTasks

#endif // TASK_H

