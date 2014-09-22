#include "socketTask.h"

using namespace TerraMEObserver;
using namespace BagOfTasks;


// Constants
const int TerraMEObserver::SocketTask::MINIMUM_DATA_SIZE = 1024;
const qreal TerraMEObserver::SocketTask::COMPRESS_RATIO = 6.0;


SocketTask::SocketTask() 
    : Task()
{
    executing = false;
}

SocketTask::~SocketTask()
{

}

void SocketTask::setCompress(bool comp)
{
    compressed = comp;

    //if (compressed)
    //    dataRatio = MINIMUM_DATA_SIZE * 1.0;
    //else
    //    dataRatio = MINIMUM_DATA_SIZE * 0.25;  // ratio is 1/4 of Minimum block size

    dataSize = MINIMUM_DATA_SIZE * 48; //dataRatio;
}

void SocketTask::setPort(quint16 prt)
{
    port = prt;
}

void SocketTask::addState(const QByteArray &state)
{
    lock.lockForWrite();
    states.append(state);
    lock.unlock();
}
