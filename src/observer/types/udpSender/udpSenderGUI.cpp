/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

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

