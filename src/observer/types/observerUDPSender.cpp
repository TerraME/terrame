#include "observerUDPSender.h"

#include <QApplication>
#include <QLabel>
#include <QList>
#include "terrameGlobals.h"

#include "senderGUI.h"
#include "udpSocketTask.h"

#include "taskManager.h"
#include "worker.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Estatisticas de desempenho
	#include "statistic.h"
#endif

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
	#include "subjectAttributes.h"
#endif

extern ExecutionModes execModes;


using namespace TerraMEObserver;


ObserverUDPSender::ObserverUDPSender(Subject *subj, QObject *parent)
    : ObserverInterf(subj), QObject(parent)
{
#ifdef TME_STATISTIC
    static bool showMsg = true;
    if (showMsg)
        qDebug() << "flag TME_STATISTIC enabled in the class ObserverUDPSender";
    showMsg = false;
#endif
    observerType = TObsUDPSender;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern

    // udpSocket = new QUdpSocket();
    // hosts = new QList<QHostAddress>();
    senderGUI = new SenderGUI();
    senderGUI->setWindowTitle("TerraME Observer :: UDP Sender");

    //paused = false;
    //failureToSend = false;
    //compressDatagram = true;   //  //  false; 
    //setCompress(compressDatagram);
    //// default port
    //port = DEFAULT_PORT;


}

ObserverUDPSender::~ObserverUDPSender()
{
    //hosts->clear();
    //delete hosts; hosts = 0;
    //delete udpSocket; udpSocket = 0;

    delete senderGUI;
}

const TypesOfObservers ObserverUDPSender::getType() const
{
    return observerType;
}

bool ObserverUDPSender::draw(QDataStream &state)
{
//#ifdef TME_STATISTIC
//	// Captura o tempo de espera para os observadores que tambem sao threads
    //double t = Statistic::getInstance().endVolatileMicroTime();
//	
//	char pName[100];
//    sprintf(pName, "%p", this );
//    QString name = QString("wait %1").arg(getId());
//	Statistic::getInstance().addElapsedTime(name, t);
//#endif
//
//    if (failureToSend)
//        return false;
//
//    QString msg;
//    state >> msg;
//
//#ifndef DEBUG_OBSERVER
//    dumpRetrievedState(msg, "out_protocol");
//#endif
//
//    // TO-DO: Alterar a forma de transmiss„o de streams via rede
//    if (! sendDatagram(msg))
//    {
//        datagramRatio *= 0.5;
//        datagramSize = MINIMUM_DATAGRAM_SIZE * datagramRatio;
//        QString str;
//
//        if (datagramSize < 32)
//        {
//            str = "Warning: The datagram's size is low that 32 bytes. "
//                "The Udp Sender will stop to send datagrams.";
//            senderGUI->appendMessage(str);
//            failureToSend = true;
//            return false;
//        }
//        str = QString("Warning: Reducing the datagram's size for %1 bytes.").arg(datagramSize);
//        senderGUI->appendMessage(str);
//
//        if (! QUIET_MODE)
//            qDebug("%s", qPrintable(str));
//
//    }

    QString stateAux;
    state >> stateAux;

    if(!stateAux.isEmpty())
    {
        static bool created = false;
        if(!created)
    	{
            UdpSocketTask *udpSocketTask = new UdpSocketTask();
            udpSocketTask->setPort(port);
            udpSocketTask->setHost(&addresses);
            udpSocketTask->setCompress(compressed);

            connect(udpSocketTask, SIGNAL(messageSent(const QString &)), senderGUI, SLOT(appendMessage(const QString &)) );
                    // , Qt::DirectConnection);
            connect(udpSocketTask, SIGNAL(messageFailed(const QString &)), senderGUI, SLOT(messageFailed(const QString &)));
            connect(udpSocketTask, SIGNAL(statusMessage(int, int)), senderGUI, SLOT(statusMessage(int, int)),
                    Qt::DirectConnection);
            connect(this, SIGNAL(addState(const QByteArray &)), udpSocketTask, SLOT(addState(const QByteArray &)),
                    Qt::DirectConnection);
                    // Qt::QueuedConnection);
            connect(this, SIGNAL(setModelTimeSignal(double)), udpSocketTask, SLOT(setModelTime(double)),
                    Qt::DirectConnection);

            const BagOfTasks::Worker *w = udpSocketTask->runExclusively();
            udpSocketTask->moveToThread((QThread *)w);
            BagOfTasks::TaskManager::getInstance().add(udpSocketTask);

            created = true;
    	}

        emit addState(stateAux.toLatin1());
    	qApp->processEvents();
	}
    else
	{
        senderGUI->appendMessage(tr("The retrieved state is empty. There is nothing to do."));
	}

    return true;
}

QStringList ObserverUDPSender::getAttributes()
{
    return attribList;
}

void ObserverUDPSender::setAttributes(QStringList& attribs)
{
    attribList = attribs;

#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if(subjAttr) 
        subjAttr->setSubjectType(getSubjectType());
#endif
}

bool ObserverUDPSender::sendDatagram(const QString& /*msg*/)
{
//#ifdef TME_STATISTIC
//    // variaveis usadas no calculo de desempenho
//    int datagramsCount = msgCount, compressionCount = 0, renderingCount = 0;
//    double t = 0.0, compressionSum = 0.0, renderingSum = 0.0;
//#endif
//
//    QByteArray data(msg.toLatin1().constData(), msg.size());
//
//    qint64 bytesWritten = 0, bytesRead = data.size();
//    int pos = 0;
//
//    while(bytesRead > 0)
//    {
//        QByteArray datagram;
//
//        QDataStream out(&datagram, QIODevice::WriteOnly);
//        out.setVersion(QDataStream::Qt_4_6);
//
//        out << (qint64) data.size();
//        // out << (qint64) datagramSize;
//        out << (qint64) pos;
//        out << compressDatagram; // flag formato do datagrama transmitido
//
//        if (compressDatagram)
//        {
//#ifdef TME_STATISTIC 
//            // t = Statistic::getInstance().startMicroTime();
//            Statistic::getInstance().startVolatileMicroTime();
//#endif
//            out << qCompress( data.mid(pos, datagramSize), COMPRESS_RATIO);
//
//#ifdef TME_STATISTIC
//            // compressionSum += (Statistic::getInstance().endMicroTime() - t);
//            compressionSum += Statistic::getInstance().endVolatileMicroTime();
//            compressionCount++;
//#endif
//        }
//        else    
//        {
//#ifdef TME_STATISTIC 
//            // t = Statistic::getInstance().startMicroTime();
//            Statistic::getInstance().startVolatileMicroTime();
//#endif
//            out << data.mid(pos, datagramSize);
//
//#ifdef TME_STATISTIC
//            // compressionSum += (Statistic::getInstance().endMicroTime() - t);
//            compressionSum += Statistic::getInstance().endVolatileMicroTime();
//            compressionCount++;
//#endif
//        }
//
//        for(int i = 0; i < hosts->size(); i++)
//        {
//
//#ifdef TME_STATISTIC 
//            // t = Statistic::getInstance().startMicroTime();
//            Statistic::getInstance().startVolatileMicroTime();
//#endif
//            bytesWritten = udpSocket->writeDatagram(datagram, hosts->at(i), port);     
//
//#ifdef TME_STATISTIC
//            // renderingSum += (Statistic::getInstance().endMicroTime() - t);
//            renderingSum += Statistic::getInstance().endVolatileMicroTime();
//            renderingCount++;
//#endif
//            udpSocket->flush();
//            senderGUI->appendMessage( tr("Datagram sent for %1").arg(hosts->at(i).toString()) );
//
//            senderGUI->setWindowTitle(tr("datagram size: %1 -- %2").arg(datagram.size()).arg((qint64)(datagram.size() - sizeof(qint64)) ));
//
//            if (bytesWritten == -1)
//            {
//                QString error;
//                error = tr("Warning: Failed on send message. Socket Error: %1")
//                    .arg(udpSocket->errorString());
//                senderGUI->appendMessage(error);
//
//                if (! QUIET_MODE)
//                    qWarning("%s", qPrintable(error));
//
//                return false;
//            }
//        }
//
//        if (compressDatagram)
//        {
//            bytesRead -= datagramSize;
//            pos += datagramSize;        
//        }
//        else
//        {
//            bytesRead -= bytesWritten;
//            pos += bytesWritten;
//        }
//        msgCount++;
//
//        // faz um pausa antes de continuar a enviar
//        // delay( (double) 0.01); // 0.0125);
//        // delay( (double) 0.0125);
//        qApp->processEvents();
//    }
//
//    completeState(COMPLETE_STATE.toLatin1());
//
//    msgCount++;
//    stateCount++;
//
//    senderGUI->setMessagesSent(msgCount);
//    senderGUI->setStateSent(stateCount);
//    
//#ifdef DEBUG_OBSERVER
//    senderGUI->appendMessage(tr("compressionSum: %1 / %2 = %3")
    //    .arg(compressionSum).arg(compressionCount).arg(compressionSum / compressionCount));
//    senderGUI->appendMessage(tr("renderingSum: %1 / %2 = %3")
    //    .arg(renderingSum).arg(renderingCount).arg(renderingSum / renderingCount));
//#endif
// 
//    senderGUI->appendMessage(tr("States sent: %1.\n").arg(stateCount));
//
//#ifdef TME_STATISTIC 
//    // Calcula a mÈdia de messagens e estados enviados
//    datagramsCount = (msgCount - datagramsCount) / hosts->size();
//    Statistic::getInstance().addOccurrence("Messages sent", datagramsCount);
//    Statistic::getInstance().addOccurrence("States sent", stateCount);
//    
//    if (compressDatagram) 
//        Statistic::getInstance().addElapsedTime("storage with Compress", compressionSum / compressionCount);
//    else
//        Statistic::getInstance().addElapsedTime("storage without Compress", compressionSum / compressionCount);
//
//    Statistic::getInstance().addElapsedTime("udp Rendering", renderingSum / renderingCount);
//#endif
    
    return true;
}

void ObserverUDPSender::setPort(int prt)
{
    port = (quint16) prt;
    senderGUI->setPort(prt);
}

int ObserverUDPSender::getPort()
{
    return port;
}

void ObserverUDPSender::addHost(const QString & host)
{
    QHostAddress hostAddress(host);
    addresses.push_back(hostAddress);
}

void ObserverUDPSender::setCompress(bool on)
{
    compressed = on;

    //if (compressDatagram)
    //    datagramRatio = 256.0;
    //else
    //    datagramRatio = 48.0;

    //datagramSize = MINIMUM_DATAGRAM_SIZE * datagramRatio;
    senderGUI->setCompress(on);
}

bool ObserverUDPSender::completeState(const QByteArray & /*flag*/)
{
    //qint64 bytesWritten = 0;
    //QByteArray datagram, data;
    //data = QByteArray(flag);

    //QDataStream out(&datagram, QIODevice::WriteOnly);
    //// out.setVersion(QDataStream::Qt_4_6);

    //out << (qint64) data.size();
    //// out << (qint64) datagramSize;
    //out << (qint64) -1;
    //out << compressDatagram;

    //if (compressDatagram)
    //   out << qCompress( data, 1);
    //else    
    //    out << data;

    //for(int i = 0; i < hosts->size(); i++)
    //{
    //    bytesWritten = udpSocket->writeDatagram(datagram, hosts->at(i), port);
    //    udpSocket->flush();

    //    if (bytesWritten == -1)
    //        return false;
    //}
    return true;
}

void ObserverUDPSender::setModelTime(double time)
{
    if (time == -1)
        emit setModelTimeSignal(time);
}

int ObserverUDPSender::close()
{
    senderGUI->close();
    // udpSocket->abort();
    return 0;
}

void ObserverUDPSender::show()
{
    senderGUI->showNormal();
}

