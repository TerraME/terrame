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

#include "observerTextScreen.h"

#include <QApplication>
#include <QByteArray>

#include "visualArrangement.h"

ObserverTextScreen::ObserverTextScreen(Subject *subj, QWidget *parent)
    : QDialog(parent), ObserverInterf(subj), QThread()
{
    observerType = TObsTextScreen;
    subjectType = TObsUnknown;

    paused = false;
    header = false;

    setWindowTitle("Text Screen");

    textEdit = new QTextEdit(this);
    textEdit->setReadOnly(true);

    VisualArrangement::getInstance()->starts(getId(), this);

    textEdit->setFixedSize(this->size());

    start(QThread::IdlePriority);
}

ObserverTextScreen::~ObserverTextScreen()
{
    wait();
}

const TypesOfObservers ObserverTextScreen::getType()
{
    return observerType;
}

bool ObserverTextScreen::draw(QDataStream &state)
{
    QString msg;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    //double num;
    //QString text;
    //bool b;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        switch (typeOfData)
        {
            case(TObsBool)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key),
                                      (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case(TObsDateTime)	:
                //break;

            case(TObsNumber)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;

            default							:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;
        }
        j++;
    }

    qApp->processEvents();
    return write();
}

void ObserverTextScreen::setAttributes(QStringList &attribs)
{
    attribList = attribs;
    for (int i = 0; i < attribList.size(); i++)
        valuesList.insert(i, QString("")); // lista dos itens na ordem em que aparecem
    header = false;
}

bool ObserverTextScreen::headerDefined()
{
    return header;
}

bool ObserverTextScreen::write()
{
    // insere o cabe?alho do arquivo
    if (!header)
    {
        QString headers;
        for (int i = 0; i < attribList.size(); ++i)
        {
            headers += attribList.at(i);

            if (i < attribList.size() - 1)
                headers += "\t";
        }

        textEdit->setText(headers);
        header = true;
    }

    QString text;
    for (int i = 0; i < valuesList.size(); i++)
    {
        text += valuesList.at(i) + "\t";

        if (i < valuesList.size() - 1)
            text += "\t";
    }

    textEdit->append(text);

    return true;
}

void ObserverTextScreen::run()
{
    //while (!paused)
    //{
    //    QThread::exec();
    //    //show();
    //    //printf("run() ");
    //}
    QThread::exec();
}

void ObserverTextScreen::pause()
{
    paused = !paused;
}

QStringList ObserverTextScreen::getAttributes()
{
    return attribList;
}

int ObserverTextScreen::close()
{
    QThread::exit(0);
    return 0;
}

void ObserverTextScreen::resizeEvent(QResizeEvent *event)
{
	if (this->isVisible())
	{
		VisualArrangement::getInstance()->resizeEventDelegate(getId(), event);
		textEdit->setFixedSize(this->size());
	}
	else
		event->ignore();
}

void ObserverTextScreen::moveEvent(QMoveEvent *event)
{
	if (this->isVisible())
		VisualArrangement::getInstance()->moveEventDelegate(getId(), event);
	else
		event->ignore();
}

void ObserverTextScreen::closeEvent(QCloseEvent *event)
{
#ifdef __linux__
	VisualArrangement::getInstance()->closeEventDelegate(this);
#else
	VisualArrangement::getInstance()->closeEventDelegate();
#endif
}

void ObserverTextScreen::save(std::string file, std::string extension)
{
      saveAsImage(file, extension);
}

void ObserverTextScreen::saveAsImage(std::string file, std::string extension)
{
      QPixmap pixmap = textEdit->grab();
      pixmap.save(QString::fromLocal8Bit(file.c_str()), extension.c_str());
}

