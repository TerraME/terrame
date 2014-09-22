#include "receiverUDP.h"
#include "ui_receiverGUI.h"

#include <math.h>
#include <QHostAddress>
#include <QThread>
#include <QDebug>

#include "agentObserverMap.h"
#include "observerGraphic.h"
#include "receiverGUI.h"
#include "concretSubject.h"
#include "taskManager.h"
#include "datagramReceiverTask.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Estatisticas de desempenho
	#include "statistic.h"
#endif

ReceiverUDP::ReceiverUDP(QObject *parent) 
    : QObject (parent)
{
    msgReceiver = 0;
    statesReceiver = 0;

    // GUI
    ui = new ReceiverGUI();
    ui->setWindowTitle(tr("Observer Client :: Receiver - mode UDP"));

    ui->appendMessage("Não esta funcionando corretamente!!!\n\n");

    udpSocket = new QUdpSocket(this);
    blind(DEFAULT_PORT);

    cleanCompleteStateReceived = true;

    datagramReceiverTask = new DatagramReceiverTask(0);
    datagramReceiverTask->setType(BagOfTasks::Task::Arbitrary); 
    // datagramReceiverTask->setType(BagOfTasks::Task::Continuous);
    // datagramReceiverTask->setDataContainer(&completeData);
    
    connect(ui, SIGNAL(blindListenPort(int)), this, SLOT(blind(int)));
    connect(udpSocket, SIGNAL(readyRead()), this, SLOT(processPendingDatagrams()));
    connect(datagramReceiverTask, SIGNAL(notify(int, int)), this, SLOT(createNotifyObserver(int, int))
        ); 
        // , Qt::DirectConnection);
        // , Qt::BlockingQueuedConnection);


#ifdef TME_STATISTIC
    Statistic::getInstance();
    Statistic::getInstance().setDisableRemove(true);
#endif
}

ReceiverUDP::~ReceiverUDP()
{
    delete ui; ui = 0;

    delete datagramReceiverTask; datagramReceiverTask = 0;

    udpSocket->abort();
    delete udpSocket; udpSocket = 0;
}

void ReceiverUDP::blind(int port)
{
    udpSocket->abort();
    // udpSocket->bind(port, QUdpSocket::ShareAddress);
    udpSocket->bind(QHostAddress::LocalHost, port);

    QString state;

    switch (udpSocket->state())
    {
    case 1:
        state = "HostLookupState";
        break;

    case 2:
        state = "ConnectingState";
        break;

    case 3:
        state = "ConnectedState";
        break;

    case 4:
        state = "BoundState";
        break;

    case 5:
        state = "ListeningState";
        break;

    case 6:
        state = "ClosingState";
        break;

    default: // case 0:
        state = "UnconnectedState";
    }

    ui->setStatusAndPort(state, port);
}

void ReceiverUDP::processPendingDatagrams()
{
    //static bool c = false;
    //if (!c){
    //createNotifyObserver(1, (int) TypesOfSubjects::TObsCellularSpace);
    //c = !c;
    //}
    // qDebug() << "ReceiverUDP::processPendingDatagrams()";

    QHostAddress hostSender;
    quint16 port;

    QByteArray datagram;
    do
    {
        // datagram = new QByteArray();
        //datagram->resize(udpSocket->pendingDatagramSize());
        //udpSocket->readDatagram(datagram->data(), datagram->size(), &hostSender, &port);

        datagram.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(datagram.data(), datagram.size(), &hostSender, &port);

    } while (udpSocket->hasPendingDatagrams());


    compressed = false;
    dataSize = -1.0;
    pos = 0;

    QByteArray data, auxData;
    QDataStream in(&datagram, QIODevice::ReadOnly);
    // in.setVersion(QDataStream::Qt_4_6);

    // Reserva o espaço necessário para o stream transmitido
    in >> dataSize;         // tamanho total do stream enviado
    in >> pos;  // indice do dado recebido
    in >> compressed; // flag formato do datagrama transmitido
    in >> auxData; // dado recebido


    // if ((completeData->isEmpty())){
    if (cleanCompleteStateReceived)
    {
        completeData = new QByteArray('\0', dataSize);
        cleanCompleteStateReceived = false;
    }

    if (compressed)
        data = qUncompress(auxData);
    else
        data = auxData;

    msgReceiver++;
    ui->setMessagesStatus(msgReceiver);

    if ((pos > -1)) // && (data != COMPLETE_STATE.toAscii()))
    {
        // redimensiona o objeto e insere lixo
        // msg.insert( (int)pos, data); 
        completeData->replace( (int)pos, data.size(), data);

        message = tr("Messages received: %1. From: %2, Port: %3")
            .arg(msgReceiver).arg(hostSender.toString()).arg(port);

        ui->appendMessage(QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") 
            + message);
    }
    else
    {
        if (data == COMPLETE_STATE)
        {

            datagramReceiverTask->addPartialState(completeData);

            if (! datagramReceiverTask->isPartialStateEmpty())
                BagOfTasks::TaskManager::getInstance().add(datagramReceiverTask);

            // processDatagram(completeData);
            // completeData.clear();
            cleanCompleteStateReceived = true;
            statesReceiver++;

            ui->setStatesStatus(statesReceiver);

            message = tr("States received: %1. From: %2, Port: %3\n")
                .arg(statesReceiver).arg(hostSender.toString()).arg(port);

            ui->appendMessage(
                QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") + message);
        }
        else
        {
            if (data == COMPLETE_SIMULATION)
            {
                //if (obsMap)
                //{
                //    obsMap->close();
                //    delete obsMap;
                //    obsMap = 0;
                //}

                //if (obsGraphic)
                //{
                //    obsGraphic->close();
                //    delete obsGraphic;
                //    obsGraphic = 0;
                //}

                msgReceiver = 0;
                statesReceiver = 0;
                ui->appendMessage("Simulation finished!\n");
            }
        }
    }
}

void ReceiverUDP::createNotifyObserver(int subjId, int subjType)
{ 
    //BlackBoard &bb = BlackBoard::getInstance();

    //QString state(msg);
    //int pos = state.indexOf(PROTOCOL_SEPARATOR);
    //int id = state.mid(0, pos).toInt(); 

    //SubjectAttributes *subjAttr = bb.insertSubject(id);
    //subjAttr->setSubjectType( (TypesOfSubjects) state.mid(pos + 1, 1).toInt());
    //bool dec = bb.decode(id, state);

    //if (! dec)
    //    qDebug() << "Failed on decoding state.";

    static bool created = false;
    // static ConcretSubject *cSubj = new ConcretSubject(id, (TypesOfSubjects) state.mid(pos + 1, 1).toInt());
    static ConcretSubject *cSubj = new ConcretSubject(subjId, (TypesOfSubjects) subjType);
    if (! created)
    {
        AgentObserverMap *map = new AgentObserverMap(cSubj);
        map->setCellSpaceSize(ui->getDimX(), ui->getDimY());

        //qDebug() << *ui->getLegendKeys(0) << "\n\n";
        //qDebug() << ui->getLegendValue(0);
        //qFatal("LLLL");

        map->setAttributes(*ui->getAttributes(0)
                // QStringList() << "soilWater" << "height"  
                    // << "x" << "y" 
                    // << "attr1" // << "attr2" << "attr3" << "attr4"
                    //<< "attr5" << "attr6" << "attr7" << "attr8"
                    //<< "attr9" << "attr10" << "attr11"
                ,            
                *ui->getLegendKeys(0)
                //QStringList() 
                //    << "minimum" << "type" << "stdDeviation" << "maximum" 
                //    << "grouping" << "font" << "slices" << "symbol" << "precision" 
                //    << "fontSize" << "width" << "style"
                //    << "colorBar"
                //    ////
                //    << "minimum" << "type" << "stdDeviation" << "maximum" 
                //    << "grouping" << "font" << "slices" << "symbol" << "precision" 
                //    << "fontSize" << "width" << "style"
                //    << "colorBar"
                    , 
                    ui->getLegendValue(0)
                //QStringList() 

                //<< "1" << "0" << "50" << "6" << "-1" << "100" << "0" << "255,255,255;100;100;?;#0,0,255;0;0;?;#" 
                //<< "Symbol" << "12" << "1" << "1" << "1" << "0" << "50" << "6" << "-1" << "255" << "0" << "0" 
                //<< "0,0;0;0;?;#255,255,255;100;100;?;#" << "Symbol" << "12" << "«" << "1" << "1"


                //    << "0" << "1" << "-1" << "105" 
                //    << "0" << "Symbol" << "50" << "-«" << "5" 
                //    << "12" << "2" << "1"
                //    << "255,255,255;?;?;0;#170,255,255;?;?;0.122991;#0,170,255;?;?;0.598131;#"
                //        "0,85,255;?;?;3.02804;#0,0,255;?;?;5.45794;#0,0,127;?;?;10;#"
                //    /////
                //    << "0" << "1" << "-1" << "255" 
                //    << "0" << "Symbol" << "50" << "-«" << "5" 
                //    << "12" << "2" << "1"
                //    << "0,0,0;0;0;?;#255,255,255;1;1;?;#"
                ,
                TObsCell
                );



        created = true;
    }

    cSubj->notify();
}

void ReceiverUDP::show()
{
    ui->show();
}

