/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

#ifndef UDP_SOCKET_SENDER_TASK_H
#define UDP_SOCKET_SENDER_TASK_H

#include <QUdpSocket>
#include "socketTask.h"

namespace TerraMEObserver {

class Attributes;
class SubjectAttributes;

class UdpSocketTask : public QUdpSocket, public SocketTask
{
    Q_OBJECT

public:
    /** 
     * Constructor
     */
    UdpSocketTask(QObject * parent = 0);
    
    /**
     * Destructor
     */
    virtual ~UdpSocketTask();

    /**
     * Overload of task method.
     * \copydoc BagOfTasks::Task::execute
     */
    bool execute();


    void setHost(QList<QHostAddress> *hosts);

    /**
     * Disconnects from connected host
     */
    void disconnectFromHost();

    QString errorString() const;

    void abort();

signals:
    void messageSent(const QString &);
    void messageFailed(const QString &);
    void statusMessages(int msg, int states);

public slots:
    void addState(const QByteArray &);
    
    /**
     * Sets the model time
     */
    void setModelTime(double time);

    void receive();


private slots:
    void error(QAbstractSocket::SocketError socketError);
    //void timeout(); 

protected:
    /**
     * Sends the information that bound the complete state 
     * \param data a QByteArray  
     */
    bool sendCompleteStateInfo(const QByteArray &data);


    //bool compress;
    //quint64 dataSize;   // size of data
    //double dataRatio;    // ratio of data compression
    //quint16 port;

private:
    bool send(const QByteArray &data);
    void process(const QByteArray &data);

    QList<QHostAddress> *addresses;

    bool finished;

};

}

#endif // SOCKET_SENDER_TASK_H
