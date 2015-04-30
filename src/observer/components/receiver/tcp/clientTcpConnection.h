#ifndef CLIENT_TCP_CONNECTION_H
#define CLIENT_TCP_CONNECTION_H

#include <QTcpSocket>
#include <QTime>

#include "observer.h"

class ReceiverGUI;

namespace TerraMEObserver{

class AgentObserverMap;
class ObserverGraphic;
class Subject;
class Observer;
class ConcretSubject;


class ClientTcpConnection : public QTcpSocket
{
    Q_OBJECT
public:
    ClientTcpConnection(ReceiverGUI *ui, QObject *parent = 0);
    virtual ~ClientTcpConnection();

public slots:
    void receive();

private slots:
    void createObserver();

private:
    void process(const QByteArray &data);
    bool send(const QByteArray &data);


    qint64 blockSize;
    QByteArray completeState;
    QTime time;

    QVector<TerraMEObserver::AgentObserverMap *> observers;
    QVector<ConcretSubject *> cSubjects;

    ReceiverGUI *ui;

    int statesReceiver, msgReceiver;
    bool compressed;
    

// #ifdef TME_STATISTIC
    int statMsgCount;
// #endif

};

}
#endif // CLIENT_TCP_CONNECTION_H
