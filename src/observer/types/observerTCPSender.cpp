#include "observerTCPSender.h"

#include <QtNetwork>

#include "senderGUI.h"
#include "tcpSocketTask.h"

#include "taskManager.h"
#include "worker.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Performance Statistics
    #include "statistic.h"
#endif

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
	#include "subjectAttributes.h"
#endif

using namespace TerraMEObserver;

ObserverTCPSender::ObserverTCPSender(Subject *subj, QObject *parent)
    : QObject(parent), ObserverInterf(subj)
{

#ifdef TME_STATISTIC
    static bool showMsg = true;
    if (showMsg)
        qDebug() << "flag TME_STATISTIC enabled in the class ObserverTCPSender";
    showMsg = false;
#endif

    observerType = TObsTCPSender;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern
    tcpSocketTask = 0;

    //tcpSocketTask = new TcpSocketTask();
    //tcpSocketTask->setCompress(false);

    //connect(tcpSocketTask, SIGNAL(messageSent(const QString &)), this, SLOT(messageSent(const QString &)));
    //connect(tcpSocketTask, SIGNAL(messageFailed(const QString &)), this, SLOT(messageFailed(const QString &)));
    //connect(tcpSocketTask, SIGNAL(statusMessage(int, int)), this, SLOT(statusMessage(int, int)));
    //// connect(tcpSocketTask, SIGNAL(connected()), this, SLOT(connected()));

    senderGUI = new SenderGUI();
    senderGUI->setWindowTitle("TerraME Observer :: TCP Sender");

    addresses = new QList<QHostAddress>();
}

ObserverTCPSender::~ObserverTCPSender()
{
    // tcpSocketTask->disconnectFromHost();
    // tcpSocketTask->waitForDisconnected(2000);

    // delete tcpSocketTask; tcpSocketTask = 0;
    delete senderGUI; senderGUI = 0;
    delete addresses; addresses = 0;
}

bool ObserverTCPSender::draw(QDataStream& state)
{
    bool drew = false;

    QByteArray stateAux;
    state >> stateAux;

#ifdef DEBUG_OBSERVER
    dumpRetrievedState(stateAux, "serial_");
#endif

    // qDebug() << "stateAux.size(): " << stateAux.size();

    if(!stateAux.isEmpty())
    {
        static bool socket = false;
        if (!socket)
        {
            tcpSocketTask = new TcpSocketTask();

            connect(tcpSocketTask, SIGNAL(messageSent(const QString &)),
            		senderGUI, SLOT(appendMessage(const QString &)));
                // , Qt::DirectConnection);
            connect(tcpSocketTask, SIGNAL(messageFailed(const QString &)),
            		senderGUI, SLOT(messageFailed(const QString &)));
            connect(tcpSocketTask, SIGNAL(statusMessages(int)),
            		senderGUI, SLOT(statusMessages(int)) /*, Qt::DirectConnection*/);
            connect(tcpSocketTask, SIGNAL(statusStates(int)),
            		senderGUI, SLOT(statusStates(int)) /*, Qt::DirectConnection*/);
            // connect(tcpSocketTask, SIGNAL(disconnected()), this, SLOT(deleteLater()));
            connect(tcpSocketTask, SIGNAL(connected()), this, SLOT(connected()));
            connect(tcpSocketTask, SIGNAL(speed(const QString &)),
            		senderGUI, SLOT(setSpeed(const QString &)) /*, Qt::DirectConnection*/);

            connect(this, SIGNAL(addState(const QByteArray &)),
            		tcpSocketTask, SLOT(addState(const QByteArray &)),
                Qt::DirectConnection);
                // Qt::QueuedConnection);
            connect(this, SIGNAL(setModelTimeSignal(double)),
            		tcpSocketTask, SLOT(setModelTime(double)),
                Qt::DirectConnection);
            connect(this, SIGNAL(abort()), tcpSocketTask, SLOT(abort()),
                Qt::DirectConnection);

            tcpSocketTask->setCompress(compressed);
            tcpSocketTask->connectToHost(addresses->first(), port);

            // const BagOfTasks::Worker *w = tcpSocketTask->runExclusively();
            // tcpSocketTask->moveToThread((QThread *) w);
            tcpSocketTask->moveToThread((QThread *) tcpSocketTask->runExclusively());

            socket = true;
        }

        BagOfTasks::TaskManager::getInstance().add(tcpSocketTask);
        emit addState(stateAux);
        qApp->processEvents();

        drew = true;
    }
    else
    {
        senderGUI->appendMessage(
        		tr("The retrieved state is empty. There is nothing to do."));
    }

    qApp->processEvents();
    return drew;
}

void ObserverTCPSender::setAttributes(QStringList &attribs)
{
    attribList = attribs;

#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr)
        subjAttr->setSubjectType(getSubjectType());
#endif

//#ifdef TME_BLACK_BOARD_
//    Attributes *attrib = 0;
//
//    for(int i = 0; i < attribList.size(); i++)
//    {
//        if ((attribList.at(i) != "x") && (attribList.at(i) != "y"))
//        {
//            attrib = (Attributes *) &BlackBoard::getInstance()
//                .addAttribute(getSubjectId(), attribList.at(i));
//
//            attrib->setVisible(true);
//            attrib->setObservedBy(observerType);
//        }
//    }
//#endif
}

QStringList ObserverTCPSender::getAttributes()
{
    return attribList;
}

const TypesOfObservers ObserverTCPSender::getType() const
{
    return observerType;
}

void ObserverTCPSender::addHost(const QString & host)
{
    addresses->append(QHostAddress(host));
}

int ObserverTCPSender::close()
{
    emit abort();
    senderGUI->close();
    return 0;
}

void ObserverTCPSender::show()
{
    senderGUI->showNormal();
}

void ObserverTCPSender::setCompress(bool compress)
{
    compressed = compress;
    senderGUI->setCompress(compress);
}

void ObserverTCPSender::setModelTime(double time)
{
    if (time == -1)
        emit setModelTimeSignal(time);
}

bool ObserverTCPSender::connectTo(quint16 prt)
{
    port = prt;

    //if (addresses->size() > 1)
    //    qDebug() << "ObserverTCPSender - Sends for more than one client simultaneously did not implement yet";

    //if (tcpSocketTask->connectToHost(addresses->first(), port))
    //{
    //    senderGUI->appendMessage(SenderGUI::tr("Connected on %1:%2 ")
    //        .arg(addresses->first().toString())
    //        .arg(port));
    //    return true;
    //}
    //senderGUI->appendMessage(SenderGUI::tr("Conection fail: '%1'").arg(tcpSocketTask->errorString()));
    return false;
}

void ObserverTCPSender::connected()
{
    // Used only for debugging
    senderGUI->appendMessage("conectou!!");
}

