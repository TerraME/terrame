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

#include "Downloader.h"
#include <iostream>

using namespace std;

Downloader::Downloader() : QEventLoop()
{
	packagesPage = "";
	manager = new QNetworkAccessManager(this);
}

QString Downloader::listPackages(QString url)
{
	connect(manager, SIGNAL(finished(QNetworkReply*)),
	        this, SLOT(listFinished(QNetworkReply*)));
	QNetworkReply *reply = manager->get(QNetworkRequest(url));
	exec();
	return packagesPage;
}

void Downloader::listFinished(QNetworkReply *reply)
{
	QByteArray qba;

	if (reply->error())
	{
		packagesPage = reply->errorString();
	}
	else
	{
		packagesPage = reply->readAll();
	}

	reply->deleteLater();
	exit();
}

QString Downloader::downloadPackage(QString filename, QString repos)
{
	fileName = filename;
	QString url = repos + filename;
	connect(manager, SIGNAL(finished(QNetworkReply*)),
	        this, SLOT(downloadFinished(QNetworkReply*)));
	QNetworkReply *reply = manager->get(QNetworkRequest(url));
	exec();
	return packagesPage;
}

void Downloader::downloadFinished(QNetworkReply *reply)
{
	QByteArray qba;

	if (reply->error())
	{
		packagesPage = reply->errorString();
	}
	else
	{
		qba = reply->readAll();
		packagesPage = qba;

		QFile file(fileName);
		file.open(QIODevice::WriteOnly);
		file.write(qba);
		file.close();
	}

    reply->deleteLater();
	exit();
}

