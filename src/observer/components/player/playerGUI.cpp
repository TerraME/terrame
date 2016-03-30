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

#include "playerGUI.h"
#include "ui_playerGUI.h"

#include <QApplication>
// #include "../../components/console/modelConsole.h"

extern bool paused;
extern bool step;

PlayerGUI::PlayerGUI(QWidget *parent)
    : QDialog(parent), ui(new Ui::PlayerGUI)
{
    ui->setupUi(this);
    // ui->mainVLayout->addWidget( &ModelConsole::getInstance() );
    resize(400, 20);

    // The simulation will be launched in pause mode, so
    // the GUI must be similar
    playPauseClicked();
    
    connect(ui->btPlayPause, SIGNAL(clicked()), this, SLOT(playPauseClicked()));
    connect(ui->btStep, SIGNAL(clicked()), this, SLOT(stepClicked()));
    connect(ui->btStop, SIGNAL(clicked()), this, SLOT(stopClicked()));
}

PlayerGUI::~PlayerGUI()
{
    // Desattach the ModelConsole instance from the scrollArea
    // ui->scrollArea->setWidget(0);
    delete ui;
}

void PlayerGUI::playPauseClicked()
{
    QIcon icon;

    if (! paused)
    {
        ui->btPlayPause->setText("Play");
        icon.addFile(QString::fromUtf8(":/icons/play.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
        paused = true;
    }
    else
    {
        ui->btPlayPause->setText("Pause");
        icon.addFile(QString::fromUtf8(":/icons/pause.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
        paused = false;
        step = false;
    }
}

void PlayerGUI::stepClicked()
{
    if (! step)
    {
        QIcon icon;
        ui->btPlayPause->setText("Play");
        icon.addFile(QString::fromUtf8(":/icons/play.png"), QSize(), QIcon::Normal, QIcon::Off);
        ui->btPlayPause->setIcon(icon);
    }
    
    step = true;
    paused = false;
}

void PlayerGUI::stopClicked()
{
    exit(0);
}

void PlayerGUI::setActiveButtons(bool active)
{
    ui->btPlayPause->setEnabled(active);
    ui->btStep->setEnabled(active);
    // ui->btStop->setEnabled(active);
}
