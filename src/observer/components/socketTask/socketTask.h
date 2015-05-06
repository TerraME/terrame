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

#ifndef SOCKET_SENDER_TASK_H
#define SOCKET_SENDER_TASK_H

#include <QByteArray>
#include <QString>
#include <QHostAddress>
#include <QReadWriteLock>
#include <QList>

#include "observer.h"
#include "task.h"

namespace TerraMEObserver {

class Attributes;
class SubjectAttributes;

class SocketTask : public BagOfTasks::Task
{
public:
    /**
     * Constructor
     */
    SocketTask();

    /**
     * Destructor
     */
    virtual ~SocketTask();

    /**
     * Overload of task method.
     * \copydoc BagOfTasks::Task::execute
     */
    virtual bool execute() = 0;

    /**
     * Sets the use of compression for sent messages
     * The compression format is without compression
     * \param on boolean, if \a true sends compressed datagrams.
     * Otherwise, sends without compression.
     */
    virtual void setCompress(bool on);

    /**
     * Gets the use of compression
     * \see setCompressDatagram
     */
    inline bool isCompress() const { return compressed; }

     /**
     * Sets the communication port
     * \param port a quint16 number
     */
    virtual void setPort(quint16 port);

     /**
     * Gets the communication port
     */
    virtual quint16 getPort() const { return port; }

    /**
     * Disconnects from connected host
     */
    virtual void disconnectFromHost() = 0;

    /**
     * Sets the model time
     */
    virtual void setModelTime(double time) = 0;

    virtual void addState(const QByteArray &state);

    virtual QString errorString() const = 0;

    virtual void abort() = 0;

protected:
    /**
     * Sends the information that bound the complete state
     * \param data a QByteArray
     */
    virtual bool sendCompleteStateInfo(const QByteArray &) = 0;

    /**
     * Sends a message by socket
     * \param data a QByteArray containing the message you want to send.
     */
    virtual bool send(const QByteArray &data) = 0;

    /**
     * Receives a message by socket
     */
    virtual void receive() = 0;

    QList<QByteArray> states;
    QReadWriteLock lock;

    bool executing, compressed;
    qint64 dataSize;   // size of data
    double dataRatio;    // ratio of data compression
    quint16 port;
    // qint64 blockSize;
    int stateCount, msgCount;

    static const int MINIMUM_DATA_SIZE;
    static const qreal COMPRESS_RATIO;

};

}

#endif // SOCKET_SENDER_TASK_H
