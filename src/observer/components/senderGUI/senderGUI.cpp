#include "senderGUI.h"
#include "ui_senderGUI.h"

#include <QDateTime>

extern "C"
{
#include <lua.h>
}
#include "luna.h"
#include "terrameGlobals.h"

extern lua_State * L;
extern ExecutionModes execModes;

SenderGUI::SenderGUI(QWidget *parent) 
    : QDialog(parent), ui(new Ui::senderGUI)
{
    ui->setupUi(this);

    setMessagesSent(0);
    setStateSent(0);

    // ui->lblCompressIcon->setScaledContents(true);
    // ui->lblCompressIcon->setPixmap(QPixmap(":/icons/compress.png"));
    ui->lblCompress->setText("Compress: Off");
    ui->lblCompress->setToolTip("The send compressed is disabled.");
}

SenderGUI::~SenderGUI()
{
    delete ui;
}

void SenderGUI::setPort(int port)
{
    ui->lblPortStatus->setText( tr("Sending at Port: ").arg(port));
}

void SenderGUI::setMessagesSent(int msgs)
{
    ui->lblMessagesSent->setText( tr("Messages sent: %1").arg(msgs));
}

void SenderGUI::setStateSent(int states)
{
    ui->lblStatesSent->setText( tr("States sent: %1").arg(states));
}

void SenderGUI::setSpeed(const QString &speed)
{
    ui->lblSpeedStatus->setText(speed);

//    double secs = stopWatch.elapsed() / 1000.0;
//    qDebug("\t%.2fMB/%.2fs: %.2fMB/s", double(nbytes / (1024.0*1024.0)),
//    secs, double(nbytes / (1024.0*1024.0)) / secs);
}

void SenderGUI::appendMessage(const QString &message)
{
    ui->logEdit->appendPlainText(tr("%1 %2")
        .arg(QDateTime::currentDateTime().toString("MM/dd/yyyy, hh:mm:ss:"))
        .arg(message) );
}

void SenderGUI::messageFailed(const QString &errorMsg)
{
    QString wng_msg = SenderGUI::tr("Failed on send message. Socket Error: %1").arg(errorMsg);
    appendMessage(wng_msg);
	
	if (execModes != Quiet){
		lua_getglobal(L, "customErrorMsg");
		lua_pushstring(L,wng_msg.toLatin1().data());
		lua_pushnumber(L,5);
		lua_call(L,2,0);
	}
}

void SenderGUI::statusMessages(int msgs)
{
    setMessagesSent(msgs);
}

void SenderGUI::statusStates(int states)
{
    setStateSent(states);
}

void SenderGUI::setCompress(bool compress)
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

