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

#ifndef TCP_SOCKET_SENDER_TASK_H
#define TCP_SOCKET_SENDER_TASK_H

#include <QTcpSocket>
#include <QTime>

#include "socketTask.h"

namespace TerraMEObserver {

class Attributes;
class SubjectAttributes;

class TcpSocketTask : public QTcpSocket, public SocketTask
{
    Q_OBJECT

public:
    /** 
     * Constructor
     */
    TcpSocketTask(QObject * parent = 0);
    
    /**
     * Destructor
     */
    virtual ~TcpSocketTask();

    /**
     * Overload of task method.
     * \copydoc BagOfTasks::Task::execute
     */
    bool execute();

    ///**
    // * Sets the use of compression for sent messages
    // * The compression format is without compression
    // * \param on boolean, if \a true sends compressed datagrams.
    // * Otherwise, sends without compression.
    // */
    //void setCompress(bool on);

    ///**
    // * Gets the use of compression
    // * \see setCompressDatagram
    // */
    //inline bool isCompress() { return compress; }
    //
    ///**
    // * Sets the communication port
    // * \param port a quint16 number
    // */
    //void setPort(quint16 port);

    ///**
    // * Gets the communication port
    // */
    //virtual quint16 getPort();

    /**
     * Connects to a host
     * \param host the ip host 
     * \param port the number of port
     */
    bool connectToHost(const QHostAddress &host, quint16 port);

    /**
     * Disconnects from connected host
     */
    void disconnectFromHost();

    QString errorString() const;
    
    
// #ifdef TME_STATISTIC
    // Statistic variable. It should be deleted soon
    double waitTime;
    bool setupStatistics;
// #endif

signals:
    void messageSent(const QString &);
    void messageFailed(const QString &);
    void statusMessages(int msgs);
    void statusStates(int states);
    void speed (const QString &);

public slots:
    void addState(const QByteArray &);
    void abort();
    
    /**
     * Sets the model time
     */
    void setModelTime(double time);

    void receive();

private slots:
    void error(QAbstractSocket::SocketError socketError);
    void timeout(); 

protected:
    /**
     * Sends the information that bound the complete state 
     * \param data a QByteArray  
     */
    inline bool sendCompleteStateInfo(const QByteArray &data) { return send(data); }

    /**
     * Sends a fragment/part of a state
     * \param data a QByteArray that contains a split of state 
     */
    bool send(const QByteArray &data);

    /* * 
     * Gets the size of data that have been send
     * For UDP is datagram size and for TCP is message size
     */
    // inline quint64 getDataSize() { return dataSize; }

    /* * 
     * Gets the ratio of data compression 
     */
    // inline double getDataRatio() { return dataRatio; }

    //bool compress;
    //quint64 dataSize;   // size of data
    //double dataRatio;    // ratio of data compression
    //quint16 port;

private:
    QHostAddress address;
    QTime time;
};

}

#endif // SOCKET_SENDER_TASK_H
