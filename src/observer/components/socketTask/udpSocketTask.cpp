#include "udpSocketTask.h"

#include <QtGlobal>
#include <QTimer>
#include "taskManager.h"

using namespace TerraMEObserver;
using namespace BagOfTasks;

static const int TIME_OUT = 10000;

UdpSocketTask::UdpSocketTask(QObject * parent)
    : QUdpSocket(parent), SocketTask()
{
    // setType(Task::Continuous);
    // setType(Task::Arbitrary);
    // type = Task::Continuous;

    compressed = false;
    finished = false;
    stateCount = 0;
    msgCount = 0;

    connect(this, SIGNAL(readyRead()), this, SLOT(receive()));
}

UdpSocketTask::~UdpSocketTask()
{
    // abort();
}

//void UdpSocketTask::setCompress(bool comp)
//{
//    compress = comp;
//
//    if (compress)
//        dataRatio = MINIMUM_BLOCK_SIZE;
//    else
//        dataRatio = MINIMUM_BLOCK_SIZE * 0.25;  // ratio is 1/4 of Minimum block size
//
//    dataSize = MINIMUM_BLOCK_SIZE * dataRatio;
//}

bool UdpSocketTask::execute()
{
    if (executing)
        return false;
    executing = true;

    bool isEmpty = states.isEmpty();
    finished = false;

    while (!finished)  // Task is active while not finish the simulation. It might be a good idea !!
    {
        while (!isEmpty)
        {
            lock.lockForWrite();
            const QByteArray state = states.takeFirst();
            isEmpty = state.isEmpty();
            lock.unlock();

            send(state);
        }
    }

    executing = false;

    return true;
}

bool UdpSocketTask::send(const QByteArray &data)
{
    qint64 bytesWritten = 0, bytesRead = data.size();
    int pos = 0;

    if ((data == COMPLETE_STATE) || (data == COMPLETE_SIMULATION))
        pos = -1;

    while(bytesRead > 0)
    {
        QByteArray datagram;

        QDataStream out(&datagram, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_6);

        out << (qint64) data.size();
        out << (qint64) pos;
        out << compressed; // datagram format transmitted flag

        // This header uses 17 bytes: 'data.size() + pos + compressed'

        if (compressed)
        {
            out << qCompress(data); //qCompress(data.mid(pos, dataSize), COMPRESS_RATIO);
        }
        else
        {
            // qDebug() << "datagram size: " << datagram.size() << "dataSize:" << dataSize << "pos:" << pos;
            out << data.mid(pos, dataSize);
            // qDebug() << "datagram size: " << datagram.size() << "\n\n";
        }

        for(int i = 0; i < addresses->size(); i++)
        {
            bytesWritten = writeDatagram(datagram, addresses->at(i), port);
            flush();

            // emit messageSent(tr("Datagram sent for %1").arg(addresses->at(i).toString()));

            emit messageSent (tr("Datagram sent for %1. Bytes sent: %2")
            		.arg(addresses->at(i).toString())
                .arg(bytesWritten));

            if (bytesWritten == -1)
            {
                emit messageFailed(errorString());
                return false;
            }
        }

        //if (compressed)
        //{
        //    bytesRead -= datagramSize;
        //    pos += datagramSize;
        //}
        //else
        {
            bytesRead -= bytesWritten;
            pos += bytesWritten;
        }
        msgCount++;
    }

    if ((data != COMPLETE_STATE) && (data != COMPLETE_SIMULATION))
    {
        qDebug() << "sendCompleteStateInfo(COMPLETE_STATE)";
        // finished = true;

        if (!sendCompleteStateInfo(COMPLETE_STATE))
            return false;
    }

    stateCount++;

    emit statusMessages(msgCount, stateCount);
    emit messageSent(tr("States sent: %1.").arg(stateCount));

    return false;
}

void UdpSocketTask::disconnectFromHost()
{
    QUdpSocket::disconnectFromHost();
}

QString UdpSocketTask::errorString() const
{
    return QUdpSocket::errorString();
}

void UdpSocketTask::abort()
{
    QUdpSocket::abort();
}

void UdpSocketTask::setModelTime(double /*time*/)
{
    // setType(Task::Once);

    qDebug() << "\nUdpSocketTask::setModelTime(double time): " << COMPLETE_SIMULATION;
    sendCompleteStateInfo(COMPLETE_SIMULATION);
    finished = true;
}

bool UdpSocketTask::sendCompleteStateInfo(const QByteArray &data)
{
    bool ret = send(data);

    if (data == COMPLETE_SIMULATION) {
        // waitForDisconnected(2000);
        qDebug("COMPLETE_SIMULATION States sent: %i. Msgs: %i", stateCount, msgCount);
    }
    return ret;
}

void UdpSocketTask::addState(const QByteArray &state)
{
    SocketTask::addState(state);
}

void UdpSocketTask::error(QAbstractSocket::SocketError /* socketError */)
{
    emit messageFailed(errorString());
}

void UdpSocketTask::receive()
{
    qDebug() << "SLOT UdpSocketTask::receive()";

    while(hasPendingDatagrams())
    {

    }
    finished = false;
}

void UdpSocketTask::process(const QByteArray & /*data*/)
{

}

void UdpSocketTask::setHost(QList<QHostAddress> *hosts)
{
    addresses = hosts;
}
