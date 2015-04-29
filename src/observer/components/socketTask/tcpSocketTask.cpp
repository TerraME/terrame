#include "tcpSocketTask.h"

// #include <QTcpSocket>
#include <QApplication>
#include <QtGlobal>
#include <QTimer>

#include "taskManager.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Performance Statistics
    #include "statistic.h"
#endif


using namespace TerraMEObserver;
using namespace BagOfTasks;

static const int TIME_OUT = 10000;


TcpSocketTask::TcpSocketTask(QObject * parent) 
    : QTcpSocket(parent), SocketTask()
{
    setType(Task::Arbitrary);
    // type = Task::Continuous;
    // type = Task::Arbitrary;

    compressed = false;
    stateCount = 0;
    msgCount = 0;
    
    
#ifdef TME_STATISTIC
    waitTime = 0.0;
    setupStatistics = false;
#endif
    
    connect(this, SIGNAL(readyRead()), this, SLOT(receive()));
}

TcpSocketTask::~TcpSocketTask()
{
    waitForDisconnected(2000);
    emit messageSent(tr("TcpSocketTask::~TcpSocketTask()"));
    qDebug() << "TcpSocketTask::~TcpSocketTask()";
    // abort();
}

//void TcpSocketTask::setCompress(bool comp)
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
//
//
//    
//void TcpSocketTask::setPort(quint16 prt)
//{
//    port = prt;
//}

bool TcpSocketTask::execute()
{
#ifdef TME_STATISTIC 
    if (executing || states.isEmpty())
        return false;
    executing = true;

    waitTime = Statistic::getInstance().endMicroTime() - waitTime;
    QString name = QString("zz__wait_task TcpSocketTask %1").arg(getId());
    Statistic::getInstance().addElapsedTime(name, waitTime);

    double t = 0, tt = 0, sum = 0;
    int count = 0;
    
    t = Statistic::getInstance().startMicroTime();
    
    if (! setupStatistics)
    {
        name = QString("map TcpSocketTask task %1").arg(getId());
        Statistic::getInstance().addElapsedTime(name, 0);

        Statistic::getInstance().addOccurrence("Sent Messages", 0);
        Statistic::getInstance().addOccurrence("Sent States", 0);

        Statistic::getInstance().addOccurrence("Bytes written", 0);

        setupStatistics = true;
    }

    bool isEmpty = states.isEmpty();

    while (! isEmpty)
    {  
        lock.lockForWrite();
        const QByteArray curState = states.takeFirst();
        isEmpty = states.isEmpty();
        lock.unlock();

        tt = Statistic::getInstance().startMicroTime();

        send(curState); 

        sum += Statistic::getInstance().endMicroTime() - tt;
        count++;
    }

    executing = false;

    name = QString("z_send TcpSocketTask task %1").arg(getId());
    if (count > 0) 
        Statistic::getInstance().addElapsedTime(name, sum / count);
    else
        Statistic::getInstance().addElapsedTime(name, 0);
    
    name = QString("map TcpSocketTask task %1").arg(getId());
    t = Statistic::getInstance().startMicroTime() - t;
    Statistic::getInstance().addElapsedTime(name, t);
    
    // Calculates the waiting time for the task start running
    // waitTime = Statistic::getInstance().startMicroTime();

    qApp->processEvents();

    // qDebug() << (BagOfTasks::TaskManager::getInstance().isEmpty() ? " bag empty" : "bag not empty");

    return true;

#else
    bool isEmpty = states.isEmpty();

    if (executing || isEmpty)
        return false;
    executing = true;

    while (! isEmpty)
    {   
        lock.lockForWrite();
        const QByteArray curState = states.takeFirst();
        isEmpty = states.isEmpty();
        lock.unlock();

        send(curState);
    }

    // timer->start(TIME_OUT);
    // timer.start(TIME_OUT);
    
    executing = false;
    qApp->processEvents();
    return true;
#endif    
}

bool TcpSocketTask::connectToHost(const QHostAddress &host, quint16 prt)
{
    address = host;
    port = prt;

    QTcpSocket::connectToHost(host, port);
    stateCount = 0;
    msgCount = 0;

    return waitForConnected(1000);
}

void TcpSocketTask::disconnectFromHost()
{
    QTcpSocket::disconnectFromHost();
}

QString TcpSocketTask::errorString() const
{
    return QTcpSocket::errorString();
}

void TcpSocketTask::abort()
{
    QTcpSocket::abort();
}

void TcpSocketTask::setModelTime(double /*time*/)
{
    // setType(Task::Once);
    sendCompleteStateInfo(COMPLETE_SIMULATION);
    emit messageSent(tr("Simulation finished!!\n") );

#ifdef DEBUG_OBSERVERS
    qDebug() << "\nTcpSocketTask::setModelTime(double time): " << COMPLETE_SIMULATION;
#endif
}

bool TcpSocketTask::send(const QByteArray &data)
{
#ifdef TME_STATISTIC
    // Statistic::getInstance().collectMemoryUsage();

    int statMsgCount = 0, statStateCount = 0;
    int insertCount = 0;
    double insertSum = 0.0, t = 0.0;
    QString name;

    time.start();
    QString strSpeed;

    QByteArray dataAux;

        if (compressed)
        {
            name = "z_comp with compressed";

            t = Statistic::getInstance().startMicroTime();

            dataAux = qCompress(data, COMPRESS_RATIO); //qCompress( data, COMPRESS_RATIO);

            insertSum += Statistic::getInstance().startMicroTime() - t;
            insertCount++;

        }
        else
        {
            name = "z_comp without compressed";

            t = Statistic::getInstance().startMicroTime();

            dataAux = data; // data.mid(pos, (int)SocketSenderTask::dataSize);

            insertSum += Statistic::getInstance().startMicroTime() - t;
            insertCount++;
        }
     
    qint64 bytesWritten = 0, bytesRead = dataAux.size(); 
    // qint64 bytesWritten = 0, bytesRead = data.size();
    int pos = 0;

    if ((data == COMPLETE_STATE) || (data == COMPLETE_SIMULATION))
        pos = -1;

    while(bytesRead > 0)
    {
        QByteArray datagram;
        QDataStream out(&datagram, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_6);

        out << (qint64) 0;              // Block size
        out << (qint64) data.size();    // data size
        out << (qint64) pos;
        out << compressed;                // data sent is compressed?

        //if (compressed)
        //{
        //    name = "z_comp with compressed";

        //    t = Statistic::getInstance().startMicroTime();

        //    out << qCompress(data, COMPRESS_RATIO); //qCompress( data, COMPRESS_RATIO);

        //    insertSum += Statistic::getInstance().startMicroTime() - t;
        //    insertCount++;

        //}
        //else
        //{
        //    name = "z_comp without compressed";

        //    t = Statistic::getInstance().startMicroTime();

        //    out << data; // data.mid(pos, (int)SocketSenderTask::dataSize);

        //    insertSum += Statistic::getInstance().startMicroTime() - t;
        //    insertCount++;
        //}

        out << dataAux;

        // Network Time
        out << QDateTime::currentMSecsSinceEpoch();

        out.device()->seek(0);
        out << (qint64)(datagram.size() - sizeof(qint64));
        bytesWritten = write(datagram);
        flush();


        if (bytesWritten == -1)
        {
            emit messageFailed(errorString());
            return false;
        }

        //if (compressed)
        //{
        //    bytesRead -= dataSize;
        //    pos += SocketSenderTask::dataSize;
        //}
        //else
        {
            bytesRead -= bytesWritten;
            pos += bytesWritten;
        }

        double speed_ = bytesWritten * 1.0 / (time.elapsed() + 1);
        formatSpeed(speed_, strSpeed);
        Statistic::getInstance().addElapsedTime("zzz__speed", speed_ * KILOBYTE_DIV);

        emit speed(strSpeed);

        msgCount++;
        emit messageSent( tr("Message sent: %1. From %2").arg(msgCount).arg(address.toString()) );
        emit statusMessages(msgCount);        

        Statistic::getInstance().addOccurrence("Bytes written", bytesWritten);
    }

    if ((data != COMPLETE_STATE) && (data != COMPLETE_SIMULATION))
    {
        stateCount++;
        if (! sendCompleteStateInfo(COMPLETE_STATE))
            return false;
        
        emit messageSent(tr("States sent: %1. From %2\n").arg(stateCount).arg(address.toString()) );
        emit statusStates(stateCount);
    }

    statMsgCount = msgCount - statMsgCount;
    statStateCount = stateCount - statStateCount;

    Statistic::getInstance().addOccurrence("Sent Messages", statMsgCount);
    Statistic::getInstance().addOccurrence("Sent States", statStateCount);

    if (insertCount > 0)
        Statistic::getInstance().addOccurrence(name, insertSum/insertCount);
    else
        Statistic::getInstance().addOccurrence(name, 0);

    return true;

#else

    time.start();
    QString strSpeed;
    QByteArray dataAux;

    if (compressed)
        dataAux = qCompress(data, COMPRESS_RATIO);
    else
        dataAux = data;

    qint64 bytesWritten = 0, bytesRead = dataAux.size();

    int pos = 0;
    if ((data == COMPLETE_STATE) || (data == COMPLETE_SIMULATION))
        pos = -1;


    while(bytesRead > 0)
    {
        QByteArray datagram;
        QDataStream out(&datagram, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_6);

        out << (qint64) 0;              // Block size
        out << (qint64) data.size();    // data size
        out << (qint64) pos;
        out << compressed;                // data sent is compressed?
        out << dataAux;


        out.device()->seek(0);
        out << (qint64)(datagram.size() - sizeof(qint64));
        bytesWritten = write(datagram);
        flush();


        if (bytesWritten == -1)
        {
            emit messageFailed(errorString());
            return false;
        }

        //if (compressed)
        //{
        //    bytesRead -= dataSize;
        //    pos += SocketSenderTask::dataSize;
        //}
        //else
        {
            bytesRead -= bytesWritten;
            pos += bytesWritten;
        }

        double speed_ = bytesWritten * 1.0 / (time.elapsed() + 1);
        formatSpeed(speed_, strSpeed);

        msgCount++;
        emit messageSent( tr("Message sent: %1. From %2").arg(msgCount).arg(address.toString()) );
        emit statusMessages(msgCount);
    }

    if ((data != COMPLETE_STATE) && (data != COMPLETE_SIMULATION))
    {
        stateCount++;
        if (! sendCompleteStateInfo(COMPLETE_STATE))
            return false;
        
        emit messageSent(tr("States sent: %1. From %2\n").arg(stateCount).arg(address.toString()) );
        emit statusStates(stateCount);
    }


    return true;
#endif
}

void TcpSocketTask::addState(const QByteArray &state)
{
    SocketTask::addState(state);
}

void TcpSocketTask::error(QAbstractSocket::SocketError /* socketError */)
{
    emit messageFailed(errorString());
}

void TcpSocketTask::receive()
{
#ifdef DEBUG_OBSERVER
    qDebug() << "SLOT TcpSocketTask::receive()";
#endif

    QDataStream in(this);
    in.setVersion(QDataStream::Qt_4_6);

    forever
    {
        if (dataSize == 0)
        {
            if (bytesAvailable() < sizeof(qint64))
                break;

            in >> dataSize;
        }

        if (bytesAvailable() < dataSize)
            break;

        QByteArray data, auxData;
        
        qint64 dataSizeReceiver = -1.0, pos = -1.0;

        in >> dataSizeReceiver;         // Total size of the uploaded stream
        in >> pos;              // index of received data
        in >> compressed;      // datagram format transmitted flag
        in >> auxData;          // data received

        if (compressed)
            data = qUncompress(auxData);
        else
            data = auxData;

        if (data == DISCONNECT_FROM_CLIENT)
        {
            // setType(Task::Arbitrary);
            setType(Task::Once);
            emit messageSent(tr("\n\n *** Received request to disconnect. *** \n"));
            disconnectFromHost();
        }
    }

    // BagOfTasks::TaskManager::getInstance().add(this);
}

void TcpSocketTask::timeout()
{
    //const QString msg = tr("Time out! Disconnecting from client.");
    //if (QUIET_MODE)    
    //    qWarning("%s", qPrintable(msg));

    //emit messageSent(msg);
    //
    //setType(Task::Arbitrary);
    //// BagOfTasks::TaskManager::getInstance().add(this);
    //
    //// waitForDisconnected(-1);
    //disconnectFromHost();
}
