/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright © 2001-2012 INPE and TerraLAB/UFOP.
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

extern "C"
{
#include <lua.h>
}
#include "luna.h"

#include "../observerInterf.h"
#include "udpSender/udpSenderGUI.h"

#include <QDialog>
#include <QThread>
#include <QHostAddress>

class QUdpSocket;

namespace TerraMEObserver {

/**
 * \brief Sends the attributes observed via UDP Protocol
 * \see ObserverInterf
 * \see QThread,
 * \author Antonio José da Cunha Rodrigues
 * \file observerUDPSender.h
 */
class ObserverUDPSender : public QThread, public ObserverInterf 
{
public:
    /**
     * Default constructor
     */
    ObserverUDPSender();

    /**
     * Constructor
     * \param subj a pointer to a Subject
     * \see Subject
     */
    ObserverUDPSender(Subject *subj);

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
    const TypesOfObservers getType();

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
    void setCompressDatagram(bool on);

    /**
     * Gets the use of compression
     * \see setCompressDatagram
     */
    bool getCompressDatagram();
    
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

protected:
    /**
     * Runs the thread
     * \see QThread
     */
    void run();

    /**
     * \copydoc Observer::setModelTime
     */
    void setModelTime(double time);

private:
    /**
     * Initializes the commom object to the constructors
     */
    void init();

    /**
     * Sends the datagram
     * \param msg a reference to the datagram composes of the subject internal state
     * \return boolean, \a true if the datagram could be sent.
     * Otherwise, returns \a false.
     */
    bool sendDatagram(QString & msg);

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

    QList<QHostAddress> *hosts;
    int port, stateCount, msgCount;
    int datagramSize;
    float datagramRatio;

    QUdpSocket *udpSocket;

    QStringList attribList;

    UdpSenderGUI *udpGUI;

    bool failureToSend, compressDatagram;
    bool paused;
};

}

#endif
