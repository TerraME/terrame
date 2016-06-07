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

#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>
#include <QUdpSocket>

namespace TerraMEObserver {
    class AgentObserverMap;
}

namespace Ui {
    class receiverGUI;
}

/**
 * \brief The Receiver class is used to receive visualizations
 * in a remote machine. It works with ObserverUDPSender
 * \see QDialog
 * \author Ant?nio Jos? da Cunha Rodrigues
 * \file receiver.h
 */
class Receiver : public QDialog
{
    Q_OBJECT
public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget
     * \see QWidget
     */
    Receiver(QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~Receiver();

public slots:
    /**
     * Treats the click in the close button
     */
    void closeButtonClicked();

    /**
     * Treats the click in the blind button
     */
    void blindButtonClicked();

    /**
     * Treats the pending datagrams
     */
    void processPendingDatagrams();

private:
    /**
     * \deprecated Processes the datagram
     * \param msg a datagram in QString format
     * \see QString
     */
    void processDatagram(const QString datagram);

    /**
     * \deprecated Processes the datagram
     * \param msg a datagram in QByteArray format
     * \see QByteArray
     */
    void processDatagram(QByteArray datagram);


    int msgReceiver, statesReceiver;
    QByteArray completeData;
    QString message;

    Ui::receiverGUI *ui;
    QUdpSocket *udpSocket;
    TerraMEObserver::AgentObserverMap *obsMap;

};

#endif // DIALOG_H
