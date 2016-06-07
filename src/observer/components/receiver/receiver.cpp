/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#include "receiver.h"
#include "ui_receiverGUI.h"

#include <math.h>

#include <QHostAddress>
#include <QThread>
#include <QDebug>

// Observers
#include "../../types/agentObserverMap.h"

//class ObserverThread : public QThread
//{
//    // Q_OBJECT
//
//public:
//    ObserverThread()//  : QThread(parent)
//    {}
//
//    void run()
//    {
//        exec();
//    }
//};

Receiver::Receiver(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::receiverGUI)
{
    ui->setupUi(this);

    msgReceiver = 0;
    statesReceiver = 0;
    obsMap = 0;

    connect(ui->closeButton, SIGNAL(clicked()), this, SLOT(closeButtonClicked()));
    connect(ui->bindButton, SIGNAL(clicked()), this, SLOT(blindButtonClicked()));

    udpSocket = new QUdpSocket(this);
    connect(udpSocket, SIGNAL(readyRead()), this, SLOT(processPendingDatagrams()));

    blindButtonClicked();
}

Receiver::~Receiver()
{
    delete ui;

    udpSocket->abort();
    delete udpSocket;
}

void Receiver::closeButtonClicked()
{
    close();
}

void Receiver::blindButtonClicked()
{
    udpSocket->abort();
    int port = ui->portComboBox->currentText().toInt();
    udpSocket->bind(port, QUdpSocket::ShareAddress);
    // udpSocket->bind(QHostAddress::LocalHost, port);

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

    ui->lblReceiverStatus->setText(QString("Socket state: \"%1\", Port: %2").arg(state).arg(port));
}

// TENTATIVA 3
void Receiver::processPendingDatagrams()
{
    // int totalDatagrams = 0;
    bool compressDatagram = false;
    qint64 dataSize = -1.0, pos = 0;
    qint64 datagramSize = -1; // , dataRemainder = -1.0;

    QHostAddress host;
    quint16 port;

    QByteArray datagram;
    do
    {
        datagram.resize(udpSocket->pendingDatagramSize());
        udpSocket->readDatagram(datagram.data(), datagram.size(), &host, &port);

    } while (udpSocket->hasPendingDatagrams());


    QByteArray data, auxData;
    QDataStream in(&datagram, QIODevice::ReadOnly);
    // in.setVersion(QDataStream::Qt_4_6);

    // Reserva o espa?o necess?rio para o stream transmitido
    in >> dataSize;         // tamanho total do stream enviado
    in >> datagramSize;     // tamanho do datagrama enviado

    in >> pos;  // indice do dado recebido
    in >> compressDatagram; // flag formato do datagrama transmitido
    in >> auxData; // dado recebido

    // totalDatagrams = dataSize / datagramSize;

    if ((completeData.isEmpty()))
          completeData = QByteArray('\0', dataSize);


    if (compressDatagram)
    {
        data = qUncompress(auxData);
    }
    else
    {
        data = auxData;
    }

    msgReceiver++;
    ui->lblMessageStatus->setText("Datagrams received: " + QString::number(msgReceiver));

    if ((pos > -1)) // && (data != COMPLETE_STATE.toLatin1()))
    {
        // redimensiona o objeto e insere lixo
        // msg.insert( (int)pos, data);
        completeData.replace( (int)pos, data.size(), data);

        message = tr("Messages received: %1. From: %2, Port: %3")
            .arg(msgReceiver).arg(host.toString()).arg(port);

        ui->logEdit->appendPlainText(
            QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") + message);
    }
    else
    {
        if (data == COMPLETE_STATE.toLatin1())
        {
            processDatagram(completeData);
            completeData.clear();
            statesReceiver++;

            ui->lblStatesStatus->setText("States received: " +  QString::number(statesReceiver));

            message = tr("States received: %1. From: %2, Port: %3\n")
                .arg(statesReceiver).arg(host.toString()).arg(port);

            ui->logEdit->appendPlainText(
                QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") + message);
        }
        else
        {
            if (data == COMPLETE_SIMULATION.toLatin1())
            {
                obsMap->close();
                delete obsMap;
                obsMap = 0;

                msgReceiver = 0;
                statesReceiver = 0;

                 ui->logEdit->appendPlainText("Simulation fineshed!\n");
            }
        }
    }
}


#include <QDebug>

void Receiver::processDatagram(const QString msg)
{
    //qDebug() << msg;

    // ui->logEdit->appendPlainText("Processing datagram...");
     ui->logEdit->appendPlainText(msg);
    ui->logEdit->appendPlainText("------\n");
}
#include <QFile>
void Receiver::processDatagram(QByteArray msg)
{
    // QString m(msg);
    // static int asas = 0; asas++;
    // QFile file("receiverSPLITTED_" + QString::number(asas) + ".txt");
    // if (file.open(QIODevice::WriteOnly | QIODevice::Text))
    // {
    //     QTextStream out(&file);
    //
    //     foreach(QString x, m.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts))
    //         out << x << "\n";
    //}
    //
    //QFile file1("receiverDATAGRAM_" + QString::number(asas) + ".txt");
    //if (file1.open(QIODevice::WriteOnly | QIODevice::Text))
    //{
    //    QTextStream out(&file1);
    //    out << msg;
    //}

    // qDebug() << "QByteArray msg: " << msg.size();
    // qDebug() << msg;

    /** 
    QByteArray data;
    QDataStream out(&data, QIODevice::WriteOnly);
    out.setVersion(QDataStream::Qt_4_6);

    out << QString(msg);
    out.device()->close();
    out.device()->open(QIODevice::ReadOnly);

    // ObserverThread thread;

    if (! obsMap)
    {
        obsMap = new AgentObserverMap();
        int l = 100;
        obsMap->setCellSpaceSize(l, l);
        // obs->setHeaders(QStringList() << "height" << "x" << "y", QStringList(), QStringList());
        // obs->setHeaders(QStringList() << "height" << "soilWater" << "x" << "y", QStringList(), QStringList());
        obsMap->setAttributes(
            QStringList() << "soilWater" << "x" << "y" 
                // << "attr1" << "attr2" << "attr3" << "attr4"
                // << "attr5" << "attr6" << "attr7" << "attr8"
                // << "attr9" << "attr10" << "attr11"
                ,            
            QStringList(), QStringList());
        // obs->moveToThread(&thread);
    }
    obsMap->draw(out);

    //static ObserverLogFile *obs = 0; 
    //if (! obs)
    //{
    //    obs = new ObserverLogFile();
    //    //obs->setHeaders(QStringList() << "valor" << "explosao");
    //    obs->setHeaders(QStringList() << "height" << "x" << "y");
    //    obs->moveToThread(&thread);
    //}
    //obs->draw(out);

 */    
}

