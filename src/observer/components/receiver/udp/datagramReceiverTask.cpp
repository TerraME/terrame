#include "datagramReceiverTask.h"

#include <QByteArray>
#include <QString>
#include <QDataStream>

#include "observer.h"
#include "blackBoard.h"
#include "subjectAttributes.h"

using namespace TerraMEObserver;

DatagramReceiverTask::DatagramReceiverTask(QObject *parent)
	: QObject(parent), BagOfTasks::Task()
{

}

DatagramReceiverTask::~DatagramReceiverTask()
{

}

bool DatagramReceiverTask::execute()
{
    // qDebug() << "DatagramReceiverTask::execute()";

    //bool compressed = false;
    //qint64 dataSize = -1.0, pos = 0;
    //qint64 datagramSize = -1; // , dataRemainder = -1.0;

    //QByteArray data, auxData, *part;
    //// QByteArray completeData;

    QByteArray *state;
    QMutexLocker locker(&mutex);

    while (!partialData.isEmpty())
    {
        state = partialData.takeFirst();
        locker.unlock();

        if (state)
        {
            process(QString(*state));

            //QDataStream in(part, QIODevice::ReadOnly);
            //in.setVersion(QDataStream::Qt_4_6);

            //// Reserve the space required for the stream transmitted
            //in >> dataSize;         // Total size of the uploaded stream
            //in >> pos;              // The index of received data
            //in >> compressed; // datagram format transmitted flag
            //in >> auxData;          // data received

            //if ((completeData.isEmpty()))
            //{
            //    // delete completeData;
            //    completeData = QByteArray('\0', dataSize);
            //}

            //if (compressed)
            //{
            //    data = qUncompress(auxData);
            //}
            //else
            //{
            //    data = auxData;
            //}

            //// msgReceiver++;
            //// ui->setMessagesStatus(msgReceiver);

            //if ((pos > -1)) // && (data != COMPLETE_STATE.toLatin1()))
            //{
            //    qDebug() << "completeData.replace() pos:" << pos << "size:" << data.size()
            //        << "completeData.size" << completeData.size();

            //    // resizes the object and inserts garbage
            //    // msg.insert((int)pos, data);
            //    completeData.replace((int)pos, data.size(), data);

            //    // ui->appendMessage(tr("Messages received: %1. From: %2, Port: %3")
            //    //    .arg(msgReceiver).arg(hostSender.toString()).arg(port));
            //}
            //else
            //{
            //    if (data == COMPLETE_STATE)
            //    {
            //        qDebug() << COMPLETE_STATE << "completeData: " << completeData.size();

            //        process(QString(completeData));
            //
            //        completeData.clear();
            //        //statesReceiver++;

            //        //ui->setStatesStatus(statesReceiver);

            //        //ui->appendMessage(tr("States received: %1. From: %2, Port: %3\n")
            //        //    .arg(statesReceiver).arg(hostSender.toString()).arg(port));

            //
            //    }
            //    else
            //    {
            //        if (data == COMPLETE_SIMULATION)
            //        {
            //            //// msgReceiver = 0;
            //            //// statesReceiver = 0;
            //            //ui->appendMessage("Simulation finished!\n");

            //            qDebug() << "Simulation finished!\n";
            //        }
            //    }
            //}  // if pos
        } // if state
        delete state; state = 0;
        locker.relock();

        qDebug() << "DatagramReceiverTask::execute()" << partialData.size();
    }

	return true;
}

//void DatagramReceiverTask::setDataContainer(QByteArray *complete)
//{
//    completeData = complete;
//}

void DatagramReceiverTask::addPartialState(QByteArray *partial)
{
    QMutexLocker locker(&mutex);
    partialData.append(partial);
}

// void DatagramReceiverTask::process(const QByteArray &msg)
void DatagramReceiverTask::process(const QString & /*state*/)
{
    qDebug() << "\nDatagramReceiverTask::process(const QString &)\n\tprecisa ser reimplementado!!!\n";

//    if (state.isEmpty())
//    {
//        qDebug() << "state received is empty.";
//        return;
//    }
//
//#ifdef DEBUG_OBSERVER
//    dumpRetrievedState(state);
//#endif
//
//    // QString state(msg);
//
//    int pos = state.indexOf(PROTOCOL_SEPARATOR);
//    bool ok = false;
//
//    int id = state.mid(0, pos).toInt(&ok);
//
//    // qDebug() << "state.mid: " << state.mid(0, 10).toLatin1().constData();
//
//    if (ok)
//    {
//        int type = state.mid(pos + 1, 1).toInt(&ok);
//
//        if (!ok)
//        {
//            qDebug() << "Failed on convert QString to int. ID and/or Type incorrect!";
//            return;
//        }
//
//        BlackBoard &bb = BlackBoard::getInstance();
//        SubjectAttributes *subjAttr = bb.insertSubject(id);
//        subjAttr->setSubjectType((TypesOfSubjects) type);
//
//#ifdef TME_PROTOCOL_BUFFERS
//        // bool dec = bb.decode(id, state.toLatin1());
//        bool decoded = bb.decode(state.toLatin1());
//#else
//        // bool dec = bb.decode(id, state);
//        bool decoded = bb.decode(state);
//#endif
//
//        if (decoded)
//            qDebug() << "decoded state!!!";
//        else
//            qDebug() << "Failed on decoding state.";
//
//        emit notify(id, type);
//    }
}
