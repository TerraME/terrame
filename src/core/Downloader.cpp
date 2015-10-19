
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

	if(reply->error())
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

	if(reply->error())
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

