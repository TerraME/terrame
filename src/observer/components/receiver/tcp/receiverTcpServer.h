#ifndef RECEIVER_TCP_SERVER_H
#define RECEIVER_TCP_SERVER_H

#include <QTcpServer>

class ReceiverGUI;

class ReceiverTcpServer : public QTcpServer
{
    Q_OBJECT

public:
    ReceiverTcpServer(QObject *parent = 0);
    virtual ~ReceiverTcpServer();

    void show();

protected:
    void incomingConnection(int socketDescriptor);

private slots:
    void listenning(quint16);

private:

    quint16 port;
    int connectionCount;

    ReceiverGUI *ui;
};


#endif // RECEIVER_TCP_SERVER_H
