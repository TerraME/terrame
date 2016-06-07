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

#include "observerLogFile.h"

#include <QApplication>
#include <QMessageBox>
#include <QTextStream>

ObserverLogFile::ObserverLogFile() : QObject()
{
    init();
}

ObserverLogFile::ObserverLogFile(Subject *subj)
    : QObject(), ObserverInterf( subj ) // , QThread()
{
    init();
}

ObserverLogFile::~ObserverLogFile()
{
    // wait();
}

void ObserverLogFile::init()
{
    observerType = TObsLogFile;
    subjectType = TObsUnknown;

    paused = false;
    header = false;

    fileName = DEFAULT_NAME + ".csv";
    separator = ";";

    // // prioridade da thread
    // //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    //start(QThread::IdlePriority);
}

const TypesOfObservers ObserverLogFile::getType()
{
    return observerType;
}

bool ObserverLogFile::draw(QDataStream &state)
{
    QString msg;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    //double num;
    //QString text;
    //bool b;

    //QString subjectId = tokens.at(0);
    subjectType = (TypesOfSubjects) tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i = 0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        switch (typeOfData)
        {
            case (TObsBool):
                if (contains)
                    valuesList.replace(attribList.indexOf(key),
                                       (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime):
                //break;

            case (TObsNumber):
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;

            default:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;
        }
        j++;
    }

    qApp->processEvents();
    return write();
}

void ObserverLogFile::setFileName(QString name)
{
    fileName = name;
}

void ObserverLogFile::setSeparator(QString sep)
{
    separator = sep;
}

void ObserverLogFile::setAttributes(QStringList &attribs)
{
    attribList = attribs;
    for (int i = 0; i < attribList.size(); i++)
        valuesList.insert(i, QString("")); // lista dos itens na ordem em que aparecem
    header = true;
}

bool ObserverLogFile::headerDefined()
{
    return header;
}

bool ObserverLogFile::write()
{
    QFile file(fileName);

    if (mode == QString("w"))
    {
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
                                     QObject::tr("N?o foi poss?vel abrir o arquivo de log \"%1\".\n%2")
                                     .arg(this->fileName).arg(file.errorString()	));
            return false;
        }

        QString headers;
        for (int i = 0; i < attribList.size(); ++i)
        {
            headers += attribList.at(i);

            if (i < attribList.size() - 1)
                headers += separator;
        }
        header = false;
        headers += "\n";
        file.write(headers.toLatin1().data(),  qstrlen( headers.toLatin1().data() ));

        mode = "w+";
    }
    else
    {
        if (!file.open(QIODevice::Append | QIODevice::Text))
        {
            QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
                                     QObject::tr("N?o foi poss?vel abrir o arquivo de log \"%1\".\n%2")
                                     .arg(this->fileName).arg(file.errorString()	));
            return false;
        }
    }

    QString text;
    for (int i = 0; i < valuesList.size(); ++i)
    {
        text += valuesList.at(i);

        if (i < attribList.size() - 1) text += separator;
    }

    text.append("\n");
    file.write(text.toLatin1().data(), qstrlen( text.toLatin1().data() ));
    file.close();
    return true;
}

void ObserverLogFile::setWriteMode(QString mode)
{
    this->mode = mode;
}

QString ObserverLogFile::getWriteMode()
{
    return mode;
}

void ObserverLogFile::run()
{
    ////while (!paused)
    ////{
    ////	QThread::exec();
    ////}
    //QThread::exec();
}

void ObserverLogFile::pause()
{
    paused = !paused;
}

QStringList ObserverLogFile::getAttributes()
{
    return attribList;
}

int ObserverLogFile::close()
{
    // QThread::exit(0);
    return 0;
}

