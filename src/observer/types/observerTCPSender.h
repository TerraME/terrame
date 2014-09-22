#ifndef OBSERVER_TCPSENDER_H
#define OBSERVER_TCPSENDER_H

#include <QHostAddress>
#include <QList>
#include <QStringList>

#include "observerInterf.h"

class SenderGUI;

namespace TerraMEObserver {

class TcpSocketTask;

/**
 * \brief Sends the attributes observed via TCP Protocol
 * \see ObserverInterf
 * \author Antonio José da Cunha Rodrigues
 * \file observerTCPSender.h
 */
class ObserverTCPSender : public QObject, public ObserverInterf
{
    Q_OBJECT

public:
    ObserverTCPSender(Subject *subj, QObject *parent = 0);
    virtual ~ObserverTCPSender();

    bool connectTo(quint16 port);
    void disconnectFromHost();
    void addHost(const QString & host);

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
     * \copydoc SenderTask::setCompress
     */
    void setCompress(bool on);



    /**
     * Closes the window and stops the thread execution
     */
    int close();

    /**
     * Shows the window
     */
    void show();

signals:
    void addState(const QByteArray &);
    void setModelTimeSignal(double);
    void abort();

public slots:
    void connected();


protected:
    /**
     * \copydoc Observer::setModelTime
     */
    void setModelTime(double time);

private:
    quint16 port; 
    int stateCount, msgCount;
    int datagramSize;
    double datagramRatio;
    bool compressed;

    TypesOfObservers observerType;
    TypesOfSubjects subjectType;
    
    TcpSocketTask *tcpSocketTask;

    QStringList attribList;
    QList<QHostAddress> *addresses;

    SenderGUI *senderGUI;
};

}

#endif // OBSERVERTCPSENDER_H
