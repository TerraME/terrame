#ifndef OBSERVER_UDP_SENDER_GUI_H
#define OBSERVER_UDP_SENDER_GUI_H

#include <QDialog>

namespace Ui {
class senderGUI;
}

/**
 * \brief User interface for observer Udp Sender
 * \see QDialog
 * \author Antonio Jose da Cunha Rodrigues
 * \file observerUDPSenderGUI.h
 */
class SenderGUI : public QDialog
{
    Q_OBJECT
    
public:
    /**
     * Constructor
     * \param parent a pointer to a QWidget object
     * \see QWidget
     */
    SenderGUI(QWidget *parent = 0);

    /**
     * Destructor
     */
    virtual ~SenderGUI();
    
    /**
     * Sets the communication port number
     * \param port the communication port
     */
    void setPort(int port);

    /**
     * Sets the number of states sent
     * \param stateNum number of state sent
     */
    void setStateSent(int stateNum);

    /**
     * Sets the number of messages sent
     * \param msgNum number of messages sent
     */
    void setMessagesSent(int msgNum);

    /**
     * Sets the condition of the send message. Default is uncompress.
     * \param compress boolean, if \a true message sent is compress.
     * Otherwise, message is not compressed.
     */
    void setCompress(bool compress);

public slots:
    /**
     * Appends a message into the user interface
     * \param msg a reference to the message
     */
    void appendMessage(const QString &msg);

    /**
     * Sets the speed sent
     * \param speed a reference for a QString speed
     * \see QString
     */
    void setSpeed(const QString &speed);

    void messageFailed(const QString &errorMsg);

    void statusMessages(int msgs, int states);

    void statusStates(int states);

private:
    Ui::senderGUI *ui;
};

#endif // OBSERVER_UDP_SENDER_GUI_H
