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
 * \author Antônio José da Cunha Rodrigues
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


    int msgReceiver,statesReceiver;
    QByteArray completeData;
    QString message;

    Ui::receiverGUI *ui;
    QUdpSocket *udpSocket;
    TerraMEObserver::AgentObserverMap *obsMap;

};

#endif // DIALOG_H
