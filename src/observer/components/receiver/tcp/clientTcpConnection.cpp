#include "clientTcpConnection.h"

#include <QDebug>
#include <QStringList>
#include <QHostAddress>

#include "agentObserverMap.h"
#include "observerGraphic.h"
#include "receiverGUI.h"
#include "concretSubject.h"
#include "subjectAttributes.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Estatisticas de desempenho
	#include "statistic.h"
#endif


#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
#endif

using namespace TerraMEObserver;


ClientTcpConnection::ClientTcpConnection(ReceiverGUI *ui, QObject *parent)
    : ui(ui), QTcpSocket(parent)
{
    blockSize = 0;
    msgReceiver = 0;
    statesReceiver = 0;
    compressed = false;
    completeState.clear();

    //obsMap = 0;
    //// obsGraphic = 0;
    //cSubj = 0;

#ifdef TME_STATISTIC
    statMsgCount = 0;
    TME_STATISTIC
    ui->appendMessage("TME_STATISTIC activated!! <br>******* Instanciando objetos para o teste de desempenho");
    createObserver();
#endif

    connect(this, SIGNAL(readyRead()), this, SLOT(receive()));
    connect(ui, SIGNAL(createObserver()), this, SLOT(createObserver()));
}

ClientTcpConnection::~ClientTcpConnection()
{
    ui->appendMessage("Client disconnected by server.");    
    // waitForDisconnected(2000);
    // disconnectFromHost();

    // Se esta vazio, todos os estados foram recebidos
    if (! observers.isEmpty()) 
    {
#ifdef TME_STATISTIC
        Statistic::getInstance().collectMemoryUsage();
        Statistic::getInstance().saveData("client_");
#endif

        BlackBoard::getInstance().clear();
    }

    for(int i = 0; i < cSubjects.size(); i++)
        delete cSubjects.at(i);
    cSubjects.clear();

    for (int i = 0; i < observers.size(); i++)
    {
        observers.at(i)->close();
        delete observers.at(i);
    }
    observers.clear();
}

void ClientTcpConnection::receive()
{
#ifdef TME_STATISTIC
    // Statistic::getInstance().collectMemoryUsage();
    double sum = 0, tt = 0, t = Statistic::getInstance().startMicroTime();
    int count = 0;
    int statStateCount = 0;
    qint64 streamReceived = 0;
#endif

    time.start();
    QDataStream in(this);
    in.setVersion(QDataStream::Qt_4_6);
    QString strSpeed;

    forever
    {
#ifdef TME_STATISTIC
        tt = Statistic::getInstance().startMicroTime();
#endif

        if (blockSize == 0)
        {
            if (bytesAvailable() < sizeof(qint64))
            {
#ifdef TME_STATISTIC
                tt = Statistic::getInstance().startMicroTime() - tt;
#endif
                break;
            }

            in >> blockSize;
        }

        if (bytesAvailable() < blockSize)
        {
#ifdef TME_STATISTIC
            tt = Statistic::getInstance().startMicroTime() - tt;
#endif
            break;
        }

        double speed = in.device()->size() * 1.0 / (time.elapsed() + 1);
        //qDebug() << "speed" << speed  << " time.elapsed():" << time.elapsed()
        //    << "in.device()->size()" << in.device()->size();

        formatSpeed(speed, strSpeed);
        ui->setSpeed(strSpeed);   

#ifdef TME_STATISTIC
        streamReceived = in.device()->size();
        Statistic::getInstance().addElapsedTime("zzz__speed", speed * KILOBYTE_DIV);
#endif

        QByteArray data, auxData;

        qint64 dataSize = -1.0, pos = -1.0;

        in >> dataSize;         // tamanho total do stream enviado
        in >> pos;              // indice do dado recebido
        in >> compressed;      // flag formato do datagrama transmitido
        in >> auxData;          // dado recebido


#ifdef TME_STATISTIC
        // Tempo de rede
        qint64 networkTime;
        in >> networkTime;
        Statistic::getInstance().addElapsedTime("z_network time", 
            (double) (QDateTime::currentMSecsSinceEpoch() - networkTime));
#endif

#ifdef DEBUG_OBSERVER
        qDebug() << "\ndataSize:" << dataSize;
        qDebug() << "auxData.size():" << auxData.size() << "\n";

        QString str;
        str.append( tr("\ndataSize: %1\n").arg((int) dataSize));
        str.append( tr("pos: %1\n").arg((int) pos));
        str.append( tr("compressDatagram: %1\n").arg(compressMsg ? "true" : "false"));
        // qWarning() << "auxData: " << auxData;
        ui->appendMessage(str);
#endif

#ifdef TME_STATISTIC 
        
        if (compressed)
        {
            t = Statistic::getInstance().startMicroTime();

            data = qUncompress(auxData);

            t = Statistic::getInstance().endMicroTime() - t;
            Statistic::getInstance().addElapsedTime("z_uncomp with compressed", t);
        }
        else
        {
            t = Statistic::getInstance().startMicroTime();

            data = auxData;

            t = Statistic::getInstance().endMicroTime() - t;
            Statistic::getInstance().addElapsedTime("z_uncomp without compress", t);
        }
        
#else

        if (compressed)
            data = qUncompress(auxData);
        else
            data = auxData;
#endif

        if (completeState.isEmpty())
            completeState = QByteArray('\0', dataSize);

        msgReceiver++;
        ui->setMessagesStatus(msgReceiver);
        ui->setCompression(compressed);

#ifdef TME_STATISTIC
        statMsgCount++;
        // statMsgCount = msgReceiver - statMsgCount;
        Statistic::getInstance().addOccurrence("z_tcp - bytes received", (int) streamReceived);
#endif

        if (pos > -1)
        {
            completeState.replace( (int)pos, data.size(), data);

            ui->appendMessage(tr("Messages received: %1. From: %2")
                .arg(msgReceiver).arg(peerAddress().toString()) );

            blockSize = 0;
        }
        else
        {
            // qDebug() << "\n" << data;

            if (data == COMPLETE_STATE)
            {
                statesReceiver++;
                ui->setStatesStatus(statesReceiver);

                QString message = tr("Complete state received: %1. From: %2<br>")
                    .arg(statesReceiver).arg(peerAddress().toString());

                ui->appendMessage(message);

                process(completeState);

                completeState.clear();
                blockSize = 0;

#ifdef TME_STATISTIC

                // statStateCount++; 
                statStateCount = statesReceiver - statStateCount;
                Statistic::getInstance().addOccurrence("Received Messages", statMsgCount);
                Statistic::getInstance().addOccurrence("Received States", statStateCount);
#endif
            }
            else
            {
                if (data == COMPLETE_SIMULATION)
                {
#ifdef TME_STATISTIC
                    Statistic::getInstance().collectMemoryUsage();
                    Statistic::getInstance().saveData("client_");

                    BlackBoard::getInstance().clear();
#endif

                    ui->appendMessage(tr("Simulation finished!<br>"));
                    send(DISCONNECT_FROM_CLIENT);

                    for (int i = 0; i < cSubjects.size(); i++)
                        delete cSubjects.at(i);
                    cSubjects.clear();

                    for (int i = 0; i < observers.size(); i++)
                    {
                        observers.at(i)->close();
                        delete observers.at(i);
                    }
                    observers.clear();

                    msgReceiver = 0;
                    statesReceiver = 0;

                    blockSize = 0;
                    completeState.clear();
                }
            }
        }
#ifdef TME_STATISTIC
        sum += Statistic::getInstance().startMicroTime() - tt;
        count++;
#endif
    }

#ifdef TME_STATISTIC
    Statistic::getInstance().addElapsedTime("z_receive", (count != 0) ? sum / count : 0);
#endif

    qApp->processEvents();
}

void ClientTcpConnection::process(const QByteArray &state)
{
#ifdef TME_STATISTIC
    Statistic::getInstance().setIntermediateTime();
    double t = 0;
    
    if (cSubjects.isEmpty())
    {
        createObserver();
    }

    t = Statistic::getInstance().startMicroTime();

    /*bool decoded = */ BlackBoard::getInstance().decode(state);

    t = Statistic::getInstance().endMicroTime() - t;
    Statistic::getInstance().addElapsedTime("decoder bb", t);


#ifdef DEBUG_OBSERVER
    qDebug() << (decoded ? "decoded!!!" : "decoding failure");
#endif
    
    for(int i = 0; i < cSubjects.size(); i++)
    {
           t = Statistic::getInstance().startMicroTime();

            cSubjects.at(i)->notify();

           // Calcula o tempo total de resposta
           t = Statistic::getInstance().endMicroTime() - t;
           Statistic::getInstance().addElapsedTime("Total Response Time - cellspace", t);
    }
#else
    if (cSubjects.isEmpty())
        createObserver();

    bool decoded = BlackBoard::getInstance().decode(state);
    
    // cSubj->notify();
    for(int i = 0; i < cSubjects.size(); i++)
        cSubjects.at(i)->notify();
#endif
}

bool ClientTcpConnection::send(const QByteArray &data)
{
    // COLOCAR FUTURAMENTE COMO UMA TAREFA DO BAG OF TASKS

    if (data.isEmpty())
        return false;

    qint64 bytesWritten = 0, bytesRead = data.size();
    int pos = -1;
    // int msgCount = 0;

    while(bytesRead > 0)
    {
        QByteArray datagram;
        QDataStream out(&datagram, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_6);

        out << (qint64) 0;              // Block size
        out << (qint64) data.size();    // data sizze
        out << (qint64) pos;
        out << compressed;                // data sent is compressed?

        if (compressed)
            out << qCompress( data, 6); //COMPRESS_RATIO);
        else
            out << data; // data.mid(pos, (int)SocketSenderTask::dataSize);

        out.device()->seek(0);
        out << (qint64)(datagram.size() - sizeof(qint64));
        bytesWritten = write(datagram);
        flush();


        if (bytesWritten == -1)
        {
            ui->appendMessage( tr("Failed on the send message: ") + errorString() );
            return false;
        }

        //if (compressed)
        //{
        //    // bytesRead -= dataSize;
        //    // pos += SocketSenderTask::dataSize;
        //}
        //else
        {
            bytesRead -= bytesWritten;
            pos += bytesWritten;
        }

        // senderGUI->appendMessage(SenderGUI::tr("Message sent for %1").arg(address.toString()) );
        // qDebug("Message sent for %s", qPrintable(address.toString()) );
        
        // // emit messageSent( tr("Message sent for %1").arg(address.toString()) );
        // //emit statusMessage(msgCount, stateCount);
        // msgCount++;
        // statesReceiver, msgReceiver
    }

    ui->appendMessage( tr("Negotiating closing connection...") );

    return true;
}

void ClientTcpConnection::createObserver()
{
    qDebug() << "void ClientTcpConnection::createObserver()";

    if (ui->getNumberOfObservers() == 0)
    {
        ui->appendMessage("*** Attributes not defined! ***");
        return;
    }

    for(int i = 0; i < ui->getNumberOfObservers(); i++)
    {
        ui->clearLog();

        ConcretSubject *cSubj = new ConcretSubject(1, TObsCellularSpace);

        AgentObserverMap *obsMap = new AgentObserverMap(cSubj);
        obsMap->setCellSpaceSize(ui->getDimX(), ui->getDimY());

        obsMap->setAttributes(*ui->getAttributes(i), *ui->getLegendKeys(i), 
            ui->getLegendValue(i), TObsCell);

        cSubjects.append(cSubj);
        observers.append(obsMap);
    }
}
