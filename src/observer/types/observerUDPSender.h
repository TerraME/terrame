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

#ifndef OBSERVER_UDP_SENDER
#define OBSERVER_UDP_SENDER

#include "observerInterf.h"
#include <QtNetwork/QHostAddress>

class SenderGUI;

namespace TerraMEObserver {

/**
 * \brief Sends the attributes observed via UDP Protocol
 * \see ObserverInterf
 * \see QThread,
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerUDPSender.h
 */
class ObserverUDPSender : public QObject, public ObserverInterf
{
    Q_OBJECT

public:
    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \see Subject
     */
    ObserverUDPSender(Subject *subj, QObject *parent = 0);

    /**
     * Destructor
     */
    virtual ~ObserverUDPSender();

    /**
     * \copydoc Observer::draw
     */
    bool draw(QDataStream &);

    /**
     * Sets the attributes for observation in the observer
     *
     * \param attribs a list of attributes under observation
     */
    void setAttributes(QStringList &attribs);

    /**
     * \copydoc Observer::getAttributes
     */
    QStringList getAttributes();

    /**
     * \copydoc Observer::getAttributes
     */
    const TypesOfObservers getType() const;

    /**
     * Pauses the thread execution
     */
    void pause();

    /**
     * Closes the window and stops the thread execution
     */
    int close();

    /**
     * Shows the window
     */
    void show();

    /**
     * Sets the use of compression for send datagrams
     * The compression format is without compression
     * \param on boolean, if \a true sends compressed datagrams.
     * Otherwise, sends without compression.
     */
    void setCompress(bool on);

    /**
     * Sets the number of communication port
     * \param port the number of port
     */
    void setPort(int port);

    /**
     * Gets the communication port
     */
    int getPort();

    /**
     * Adds the host ip
     * \param host the ip host in string format
     * \see QString
     */
    void addHost(const QString & host);

signals:
    void addState(const QByteArray &);
    void setModelTimeSignal(double);

protected:

    /**
     * \copydoc Observer::setModelTime
     */
    void setModelTime(double time);

private:
    /**
     * Sends the datagram
     * \param msg a reference to the datagram composes of the subject internal state
     * \return boolean, \a true if the datagram could be sent.
     * Otherwise, returns \a false.
     */
    bool sendDatagram(const QString & msg);

    /**
     *  Sends the informations that indicates that complete state was sent
     * \param flag a reference to the QByteArray \a flag
     * \return boolean, \a true if the complete state could be sent.
     * Otherwise, returns \a false.
     * \see QByteArray
     */
    bool completeState(const QByteArray &flag);

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;

    QList<QHostAddress> addresses;
    quint16 port;
    // int stateCount, msgCount;
    //int datagramSize;
    //double datagramRatio;

    QStringList attribList;

    SenderGUI *senderGUI;

    // bool failureToSend;
    bool compressed;
};

}

#endif
