#include "receiverTcpServer.h"
#include "ui_receiverGUI.h"

#include <QtGui>
#include <QtNetwork>

#include "observer.h"
#include "clientTcpConnection.h"
#include "receiverGUI.h"

using namespace TerraMEObserver;

ReceiverTcpServer::ReceiverTcpServer(QObject *parent)
    :   QTcpServer(parent)
{
    ui = new ReceiverGUI();
    ui->setWindowTitle(tr("Observer Client :: Receiver - mode TCP"));
    connect(ui, SIGNAL(blindListenPort(quint16)), this, SLOT(listenning(quint16)));

    connectionCount = 0;

    listenning(DEFAULT_PORT);
}

ReceiverTcpServer::~ReceiverTcpServer()
{
    delete ui;
}

void ReceiverTcpServer::incomingConnection(int socketDescriptor)
{
    ui->appendMessage(tr("Incoming connection for socket descriptor %1.")
    		.arg(socketDescriptor));

    //if (connectionCount >= ui->getAttributesSize())
    //    connectionCount = 0;

    ClientTcpConnection *clientConnection = new ClientTcpConnection(ui, this);
    // clientConnection->createItens((TypesOfObservers) ui->getTypeSelected(),*ui->getAttributes(connectionCount));

    clientConnection->setSocketDescriptor(socketDescriptor);
    QObject::connect(clientConnection, SIGNAL(disconnected()),
    		clientConnection, SLOT(deleteLater()));

    //connectionCount++;
}

void ReceiverTcpServer::listenning(quint16 port)
{
    this->port = port;

    if (! listen(QHostAddress::Any, port))
    {
        ui->appendMessage(tr("Error: Unable to start the server: %1").arg(errorString()));
        //close();
        return;
    }

    ui->appendMessage(tr("The server is running on port: %1\n").arg((int)port));
    ui->setStatusAndPort("Listening", (int)port);
}

void ReceiverTcpServer::show()
{
    ui->show();
}

