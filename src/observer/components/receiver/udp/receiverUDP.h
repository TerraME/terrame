#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>
#include <QUdpSocket>

class ReceiverGUI;

namespace TerraMEObserver {
    class DatagramReceiverTask;
}

/**
 * \brief The Receiver class is used to receive visualizations
 * in a remote machine. It works with ObserverUDPSender
 * \see QDialog
 * \author Antonio Jose da Cunha Rodrigues
 * \file ReceiverUDP.h
 */
class ReceiverUDP : public QObject
{
    Q_OBJECT
    
public:
    /**
     * Constructor
     * \param parent a pointer to a QObject
     * \see QObject
     */
    ReceiverUDP(QObject *parent = 0);

    /**
     * Destructor
     */
    virtual ~ReceiverUDP();

    
    void show();
    
public slots:
    /**
     * Treats the signal from GUI that contains the port nu
     */
    void blind(int);

    /**
     * Treats the pending datagrams
     */
    void processPendingDatagrams();

    void createNotifyObserver(int subjId, int subjType);

private:


    int msgReceiver, statesReceiver;
    QByteArray *completeData;
    QString message;

    ReceiverGUI *ui;
    QUdpSocket *udpSocket;

    TerraMEObserver::DatagramReceiverTask *datagramReceiverTask;

    //TerraMEObserver::AgentObserverMap *obsMap;
    //TerraMEObserver::ObserverGraphic *obsGraphic;

    bool compressed, cleanCompleteStateReceived;
    qint64 dataSize, pos;

};

#endif // DIALOG_H
