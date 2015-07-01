#include "observerUDPSender.h"

#include <QtNetwork/QUdpSocket>
#include <QApplication>
#include <QLabel>
#include <QList>
#include "terrameGlobals.h"

///< Gobal variabel: Lua stack used for comunication with C++ modules.
extern lua_State * L;

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
// Estatisticas de desempenho
#include "../observer/statistic/statistic.h"
#endif

extern ExecutionModes execModes;

// Debug method for check state data
void saveInFile(QString & msg);

// Datagram default size
static const int MINIMUM_DATAGRAM_SIZE = 1024;
static const int COMPRESS_RATIO = 6;

ObserverUDPSender::ObserverUDPSender()
    : QThread()
{
    init();
}

ObserverUDPSender::ObserverUDPSender(Subject *subj)
    : QThread(), ObserverInterf(subj)
{
    init();
}

ObserverUDPSender::~ObserverUDPSender()
{
    //if (QThread::isRunning())
    wait();

    hosts->clear();
    delete hosts; hosts = 0;
    delete udpSocket; udpSocket = 0;

    delete udpGUI;
}

void ObserverUDPSender::init()
{
    observerType = TObsUDPSender;
    subjectType = TObsUnknown;

    paused = false;
    failureToSend = false;
    compressDatagram = true;   //  //  false; 

    // default port
    port = DEFAULT_PORT;
    
    if (compressDatagram)
        datagramRatio = 50.0;
    else
        datagramRatio = 6.0;

    datagramSize = MINIMUM_DATAGRAM_SIZE * datagramRatio;
    stateCount = 0;
    msgCount = 0;

    udpSocket = new QUdpSocket();
    hosts = new QList<QHostAddress>();

    udpGUI = new UdpSenderGUI();

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    start(QThread::IdlePriority);
}

const TypesOfObservers ObserverUDPSender::getType()
{
    return observerType;
}

bool ObserverUDPSender::draw(QDataStream &state)
{
#ifdef TME_STATISTIC
    //// tempo gasto do 'getState()' ate aqui
    //double t = Statistic::getInstance().endVolatileMicroTime();
    //Statistic::getInstance().addElapsedTime("comunicacao udp", t);

    // numero de bytes transmitidos
    Statistic::getInstance().addOccurrence("bytes udp", in.device()->size());
#endif

    if (failureToSend)
        return false;

    QString msg;
    state >> msg;

#ifdef DEBUG_OBSERVER
    saveInFile(msg);
#endif

    if (! sendDatagram(msg))
    {
        datagramRatio *= 0.5;
        datagramSize = MINIMUM_DATAGRAM_SIZE * datagramRatio;
        QString str;

        if (datagramSize < 32)
        {
            str = "Warning: The datagram's size is low that 32 bytes. "
                "The Udp Sender will stop to send datagrams.";
            udpGUI->appendMessage(str);
            failureToSend = true;
            return false;
        }
        str = QString("Warning: Reducing the datagram's size for %1 bytes.").arg(datagramSize);
        udpGUI->appendMessage(str);

        if (execModes != Quiet){
            lua_getglobal(L, "customWarningMsg");
            lua_pushstring(L,str.toAscii().constData());
            lua_pushnumber(L,4);
            lua_call(L,2,0);
        }

    }
    qApp->processEvents();
    return true;
}

void ObserverUDPSender::run()
{
    //while (!paused)
    //{
    //    QThread::exec();
    //}
    QThread::exec();
}

void ObserverUDPSender::pause()
{
    paused = !paused;
}

QStringList ObserverUDPSender::getAttributes()
{
    return attribList;
}

void ObserverUDPSender::setAttributes(QStringList& attribs)
{
    attribList = attribs;

    //QString msg("attribList|");
    //msg.append(attrs.join("|"));
    //sendDatagram(msg);
}

bool ObserverUDPSender::sendDatagram(QString& msg)
{
#ifdef TME_STATISTIC 
    int datagramsCount = msgCount, compressionCount = 0, renderingCount = 0;
    double t = 0.0, compressionSum = 0.0, renderingSum = 0.0;
#endif

    QByteArray data(msg.toAscii().constData(), msg.size());

    qint64 bytesWritten = 0, bytesRead = data.size();
    int pos = 0;

    while(bytesRead > 0)
    {
        QByteArray datagram;

        QDataStream out(&datagram, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_6);

        out << (qint64) data.size();
        out << (qint64) datagramSize;
        out << (qint64) pos;
        out << compressDatagram; // flag formato do datagrama transmitido

        if (compressDatagram)
        {
#ifdef TME_STATISTIC 
            // t = Statistic::getInstance().startMicroTime();
            Statistic::getInstance().startVolatileMicroTime();
#endif
            out << qCompress( data.mid(pos, datagramSize), COMPRESS_RATIO);

#ifdef TME_STATISTIC
            // compressionSum += (Statistic::getInstance().endMicroTime() - t);
            compressionSum += Statistic::getInstance().endVolatileMicroTime();
            compressionCount++;
#endif
        }
        else    
        {
#ifdef TME_STATISTIC 
            // t = Statistic::getInstance().startMicroTime();
            Statistic::getInstance().startVolatileMicroTime();
#endif
            out << data.mid(pos, datagramSize);

#ifdef TME_STATISTIC
            // compressionSum += (Statistic::getInstance().endMicroTime() - t);
            compressionSum += Statistic::getInstance().endVolatileMicroTime();
            compressionCount++;
#endif
        }

        for(int i = 0; i < hosts->size(); i++)
        {

#ifdef TME_STATISTIC 
            // t = Statistic::getInstance().startMicroTime();
            Statistic::getInstance().startVolatileMicroTime();
#endif
            bytesWritten = udpSocket->writeDatagram(datagram, hosts->at(i), port);     

#ifdef TME_STATISTIC
            // renderingSum += (Statistic::getInstance().endMicroTime() - t);
            renderingSum += Statistic::getInstance().endVolatileMicroTime();
            renderingCount++;
#endif
            udpSocket->flush();

            udpGUI->appendMessage( QLabel::tr("Datagram sent for %1").arg(hosts->at(i).toString()) );

            if (bytesWritten == -1)
            {
                QString error;
                error = tr("Warning: Failed on send message. Socket Error: %1")
                    .arg(udpSocket->errorString());
                udpGUI->appendMessage(error);

#ifdef TME_LUA_5_2
                if (execModes != Quiet){
                    lua_getglobal(L, "customWarningMsg");
                    lua_pushstring(L,error.toAscii().constData());
                    lua_pushnumber(L,4);
                    lua_call(L,2,0);
                }
#else

                if (execModes != Quiet){
                    qWarning("%s", qPrintable(error));
                }
#endif

                return false;
            }
        }

        if (compressDatagram)
        {
            bytesRead -= datagramSize;
            pos += datagramSize;        
        }
        else
        {
            bytesRead -= bytesWritten;
            pos += bytesWritten;
        }
        msgCount++;

        // faz um pausa antes de continuar a enviar
        // delay( (float) 0.01); // 0.0125);
        // delay( (float) 0.0125);
        qApp->processEvents();
    }

    completeState(COMPLETE_STATE.toAscii());

    msgCount++;
    stateCount++;

    udpGUI->setMessagesSent(msgCount);
    udpGUI->setStateSent(stateCount);
    

    //udpGUI->appendMessage(tr("compressionSum: %1 / %2 = %3")
    //    .arg(compressionSum).arg(compressionCount).arg(compressionSum / compressionCount));
    //udpGUI->appendMessage(tr("renderingSum: %1 / %2 = %3")
    //    .arg(renderingSum).arg(renderingCount).arg(renderingSum / renderingCount));
    
    
    udpGUI->appendMessage(tr("States sent: %1.\n").arg(stateCount));

#ifdef TME_STATISTIC 
    datagramsCount = (msgCount - datagramsCount) / hosts->size();
    Statistic::getInstance().addOccurrence("Messages sent", datagramsCount);
    Statistic::getInstance().addOccurrence("States sent", stateCount);
    
    if (compressDatagram) 
        Statistic::getInstance().addElapsedTime("Storage with Compress", compressionSum / compressionCount);
    else
        Statistic::getInstance().addElapsedTime("Storage without Compress", compressionSum / compressionCount);

    Statistic::getInstance().addElapsedTime("Udp Rendering", renderingSum / renderingCount);
#endif

    return true;
}

void ObserverUDPSender::setPort(int prt)
{
    port = prt;
    udpGUI->setPort(port);
}

int ObserverUDPSender::getPort()
{
    return port;
}

void ObserverUDPSender::addHost(const QString & host)
{
    QHostAddress hostAddress(host);
    hosts->push_back(hostAddress);
}

void ObserverUDPSender::setCompressDatagram(bool on)
{
    compressDatagram = on;

    if (compressDatagram)
        datagramRatio = 50.0;
    else
        datagramRatio = 6.0;

    datagramSize = MINIMUM_DATAGRAM_SIZE * datagramRatio;
    udpGUI->setCompressDatagram(compressDatagram);
}

bool ObserverUDPSender::getCompressDatagram()
{
    return compressDatagram;
}

bool ObserverUDPSender::completeState(const QByteArray & flag)
{
    qint64 bytesWritten = 0;
    QByteArray datagram, data;
    data = QByteArray(flag);

    QDataStream out(&datagram, QIODevice::WriteOnly);
    // out.setVersion(QDataStream::Qt_4_6);

    out << (qint64) data.size();
    out << (qint64) datagramSize;
    out << (qint64) -1;
    out << compressDatagram;

    if (compressDatagram)
       out << qCompress( data, 1);
    else    
        out << data;

    for(int i = 0; i < hosts->size(); i++)
    {
        bytesWritten = udpSocket->writeDatagram(datagram, hosts->at(i), port);
        udpSocket->flush();

        if (bytesWritten == -1)
            return false;
    }
    return true;
}

void ObserverUDPSender::setModelTime(double time)
{
    if (time == -1)
        completeState(COMPLETE_SIMULATION.toAscii());
}

int ObserverUDPSender::close()
{
    udpSocket->abort();
    QThread::exit(0);
    return 0;
}

void ObserverUDPSender::show()
{
    udpGUI->showNormal();
}


#include <QFile>
#include <QTextStream>

void saveInFile(QString & msg)
{
    // qDebug() << msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    static int asas = 0; asas++;
    QFile file("out_" + QString::number(asas) + ".txt");
    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&file);

        foreach(QString x, msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts))
            out << x << "\n";

        // out << msg;
    }
}



