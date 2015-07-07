#ifndef OBSERVER_UDP_SENDER_GUI_H
#define OBSERVER_UDP_SENDER_GUI_H

#include <QDialog>

namespace Ui {
class UdpSenderGUI;
}

class UdpSenderGUI : public QDialog
{
    Q_OBJECT
    
public:
    UdpSenderGUI(QWidget *parent = 0);
    virtual ~UdpSenderGUI();
    
    void setPort(int port);
    void setStateSent(int state);
    void setMessagesSent(int msg);
    void setSpeed(const QString &speed);
    void appendMessage(const QString &message);
    void setCompressDatagram(bool compress);

private:
    Ui::UdpSenderGUI *ui;
};

#endif // OBSERVER_UDP_SENDER_GUI_H
