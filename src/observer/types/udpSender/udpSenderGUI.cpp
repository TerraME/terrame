#include "udpSenderGUI.h"
#include "ui_udpSenderGUI.h"

#include <QDateTime>

UdpSenderGUI::UdpSenderGUI(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::UdpSenderGUI)
{
    ui->setupUi(this);

    // ui->lblCompressIcon->setScaledContents(true);
    // ui->lblCompressIcon->setPixmap(QPixmap(":/icons/compress.png"));
    ui->lblCompress->setText("Compress: Off");
    ui->lblCompress->setToolTip("The send compressed is disabled.");
}

UdpSenderGUI::~UdpSenderGUI()
{
    delete ui;
}

void UdpSenderGUI::setPort(int port)
{
    ui->lblPortStatus->setText("Sending at Port: " + QString::number(port));
}

void UdpSenderGUI::setMessagesSent(int msg)
{
    ui->lblMessagesSent->setText("Messages sent: " + QString::number(msg));
}

void UdpSenderGUI::setStateSent(int state)
{
    ui->lblStatesSent->setText("States sent: " + QString::number(state));
}

void UdpSenderGUI::setSpeed(const QString &speed)
{
    ui->lblSpeedStatus->setText(speed);

//    float secs = stopWatch.elapsed() / 1000.0;
//    qDebug("\t%.2fMB/%.2fs: %.2fMB/s", float(nbytes / (1024.0*1024.0)),
//    secs, float(nbytes / (1024.0*1024.0)) / secs);
}

void UdpSenderGUI::appendMessage(const QString &message)
{
    ui->logEdit->appendPlainText(
        QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss: ") + message);
}

void UdpSenderGUI::setCompressDatagram(bool compress)
{
    if (compress)
    {
        ui->lblCompress->setText("Compress: On");
        ui->lblCompress->setToolTip("The send compressed is enabled.");
    }
    else
    {
        ui->lblCompress->setText("Compress: Off");
        ui->lblCompress->setToolTip("The send compressed is disabled.");
    }
}

