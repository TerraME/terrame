/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

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

#include "observerScheduler.h"

#include <QTreeWidget>
#include <QLabel>
#include <QToolButton>
#include <QFont>
#include <QHBoxLayout>
#include <QApplication>
#include <QDebug>
#include <QResizeEvent>

#include "visualArrangement.h"

using namespace TerraMEObserver;

ObserverScheduler::ObserverScheduler(Subject *s, QWidget *parent)
    : ObserverInterf(s), QDialog(parent) // , QThread()
{
    observerType = TObsScheduler;
    subjectType = TObsUnknown;

    paused = false;

    setWindowTitle("Clock");

    clockPanel = new QWidget(this);
    clockPanel->setObjectName(QString::fromUtf8("clockPanel"));
    clockPanel->setMinimumSize(QSize(190, 0));
    clockPanel->setMaximumSize(QSize(190, 16777215));

    QHBoxLayout *hboxLayout1 = new QHBoxLayout();
    hboxLayout1->setSpacing(0);
    hboxLayout1->setObjectName(QString::fromUtf8("hboxLayout1"));

    butExpand = new QToolButton(clockPanel);
    butExpand->setObjectName(QString::fromUtf8("butExpand"));
    butExpand->setMinimumSize(QSize(20, 20));
    butExpand->setAutoRaise(true);
    butExpand->setText("#");  // "?" "?"

    QSpacerItem *horizSpacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxLayout1->addItem(horizSpacerItem);
    hboxLayout1->addWidget(butExpand);

    QFont font;
    font.setFamily(QString::fromUtf8("Verdana"));
    font.setPointSize(26);
    font.setStyleStrategy(QFont::PreferDefault);

    lblClock = new QLabel(clockPanel);
    lblClock->setObjectName(QString::fromUtf8("lblClock"));
    lblClock->setFont(font);
    lblClock->setFrameShape(QFrame::Box);
    lblClock->setFrameShadow(QFrame::Raised);
    lblClock->setAlignment(Qt::AlignCenter);
    lblClock->setText("00:00:00");

    QVBoxLayout *vboxLayout = new QVBoxLayout(clockPanel);
    vboxLayout->setObjectName(QString::fromUtf8("vboxLayout"));
    vboxLayout->setSpacing(0);

    vboxLayout->addLayout(hboxLayout1);
    vboxLayout->addWidget(lblClock);

    QSpacerItem *vertSpacerItem = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);
    vboxLayout->addItem(vertSpacerItem);

    QStringList headers;
    headers << "Event Key" << "Event Time" << "Peridiocity" << "Priority";

    pipelineWidget = new QTreeWidget(this);
    pipelineWidget->setObjectName(QString::fromUtf8("pipelineWidget"));
    pipelineWidget->setRootIsDecorated(false);
    pipelineWidget->setHeaderLabels(headers);
    pipelineWidget->setVisible(false);
    pipelineWidget->setSortingEnabled(true);
    pipelineWidget->sortItems(Time, Qt::AscendingOrder);

    QHBoxLayout *hboxLayout = new QHBoxLayout();
    hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
    hboxLayout->setSpacing(0);

    hboxLayout->addWidget(clockPanel);
    hboxLayout->addWidget(pipelineWidget);

    setLayout(hboxLayout);

    QDialog::connect(butExpand, SIGNAL(clicked()), (QDialog *)this, SLOT(on_butExpand_clicked()));

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);

    on_butExpand_clicked();

    VisualArrangement::getInstance()->starts(getId(), this);
}


ObserverScheduler::~ObserverScheduler(void)
{
    // wait();

    delete pipelineWidget; pipelineWidget = 0;
    delete lblClock; lblClock = 0;

    delete clockPanel; clockPanel = 0;
    //    delete butExpand; butExpand = 0;

    //foreach(QTreeWidgetItem *item, hashTreeItem.values())
    //    delete item;
}

const TypesOfObservers ObserverScheduler::getType()
{
    return observerType;
}

bool ObserverScheduler::draw(QDataStream & state)
{
    double num;
    QString msg, timer;
    state >> msg;

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);
    QTreeWidgetItem *item = 0;

    // QString subjectId = tokens.at(0);
    // int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt() * 3;
    // int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i = 0; i < qtdParametros; i += 3)
    {
        QString key = tokens.at(j);
        j++;

        int typeOfData = tokens.at(j).toInt();
        j++;

        switch (typeOfData)
        {
            case(TObsBool):
                // break;

            case(TObsDateTime):
                break;

            case(TObsNumber):
                if (key.contains("@"))
                {
                    item = hashTreeItem.value(key);

                    // recupera o eventTime
                    num = tokens.at(j).toDouble();
                    item->setText(Time,  number2String(num));
                    j += 3;

                    // recupera o period
                    num = tokens.at(j).toDouble();
                    item->setText(Periodicity,  number2String(num));
                    j += 3;

                    // recupera o priority
                    num = tokens.at(j).toDouble();
                    item->setText(Priority, number2String(num));

                    i += 6;
                }
                break;

            default:
                if (key == TIMER_KEY)
                    timer = tokens.at(j);
        }
        j++;
    }

    setTimer(timer);

    qApp->processEvents();

    return true;
}

void ObserverScheduler::pause()
{
    paused = !paused;
}

void ObserverScheduler::setAttributes(QStringList &attribs)
{
    attributes = attribs;

    QString evKey;
    QTreeWidgetItem *item = 0;
    for (int i = 0; i < attributes.size(); i++)
    {
        // o atributo TIMER_KEY ? aprentado apenas na GUI do observer
        if ((attributes.at(i) != TIMER_KEY) && (attributes.at(i).contains("@")))
        {
            evKey = attributes.at(i);
            item = new QTreeWidgetItem(pipelineWidget);
            item->setText(Key, evKey.remove(0, 1));

            item->setText(Time, QString::number(0));
            item->setText(Periodicity, QString::number(0));
            item->setText(Priority, QString::number(0));

            hashTreeItem.insert(attributes.at(i), item);
        }
    }

    // redimensiona o tamanho da coluna
    pipelineWidget->resizeColumnToContents(Key);
    pipelineWidget->resizeColumnToContents(Time);
    pipelineWidget->resizeColumnToContents(Periodicity);
    pipelineWidget->resizeColumnToContents(Priority);
}

QStringList ObserverScheduler::getAttributes()
{
    return attributes;
}

void ObserverScheduler::on_butExpand_clicked()
{
    pipelineWidget->setVisible(!pipelineWidget->isVisible());
    pipelineWidget->resize(400, clockPanel->height());

    if (pipelineWidget->isVisible())
    {
        resize(QSize(600, height()));
        butExpand->setText("#");
    }
    else
    {
        resize(QSize(50, height()));
        butExpand->setText("#");  // "?" "?"
    }
}

void ObserverScheduler::setTimer(const QString &timer)
{
    lblClock->setText(timer);
}

// Verificar complexidade, pois para cada evento esse
// m?todo ? chamado 3 vezes.
const QString ObserverScheduler::number2String(double number)
{
    static const QString COMPLEMENT("000000");

    QString countString, aux;
    aux = COMPLEMENT;
    countString = QString::number(number);
    aux = aux.left(COMPLEMENT.size() - countString.size());
    aux.append(countString);
    return aux;
}

int ObserverScheduler::close()
{
    return QDialog::close();
}

void ObserverScheduler::resizeEvent(QResizeEvent *event)
{
	if (this->isVisible())
		VisualArrangement::getInstance()->resizeEventDelegate(getId(), event);
	else
		event->ignore();
}

void ObserverScheduler::moveEvent(QMoveEvent *event)
{
	if (this->isVisible())
		VisualArrangement::getInstance()->moveEventDelegate(getId(), event);
	else
		event->ignore();
}

void ObserverScheduler::closeEvent(QCloseEvent *event)
{
#ifdef __linux__
	VisualArrangement::getInstance()->closeEventDelegate(this);
#else
	VisualArrangement::getInstance()->closeEventDelegate();
#endif
}

void ObserverScheduler::save(std::string file, std::string extension)
{
    QPixmap pixmap = grab();
    pixmap.save(QString::fromLocal8Bit(file.c_str()), extension.c_str());
}


