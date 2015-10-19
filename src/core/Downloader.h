
#ifndef DOWNLOADER_H
#define DOWNLOADER_H

#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QFile>
#include <QThread>
#include <QEventLoop>

class Downloader : public QEventLoop
{
	Q_OBJECT
public:
	Downloader();

	QString listPackages(QString url);
	QString downloadPackage(QString filename, QString repos);
	void run();

public slots:
	void listFinished(QNetworkReply *reply);
	void downloadFinished(QNetworkReply *reply);

private:
	QString packagesPage;
	QNetworkAccessManager *manager;
	QString fileName;
};

#endif

