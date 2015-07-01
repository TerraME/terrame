#include "observerLogFile.h"

#include <QtGui/QApplication>
#include <QtGui/QMessageBox>
#include <QtCore/QTextStream>

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

    for (int i=0; i < qtdParametros;i++)
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

bool ObserverLogFile::write() //QString text)
{
    if (fileName.isEmpty() || fileName.isNull())
    {
        QMessageBox::information(0, QObject::tr("TerraME Observer :: LogFile"),
                                 QObject::tr("Invalid filename."));
        return false;
    }

    QFile file(fileName);

    // Caso já exista o arquivo, os novos valores são inseridos ao final do arquivo
    // Caso contrário, cria o arquivo com o nome passado.
    //if (!QFile::exists(fileName)){
    //	if (!file.open(QIODevice::WriteOnly | QIODevice::Text)){
    //		QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
    // QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
    //			.arg(this->fileName).arg(file.errorString()	));
    //		return false;
    //	}
    //}
    //else{
    //	if (!file.open(QIODevice::Append | QIODevice::Text)){
    //		QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
    // QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
    //			.arg(this->fileName).arg(file.errorString()	));
    //		return false;
    //	}
    //}


    //if (!QFile::exists(fileName)){
    if (mode == QString("w"))
    {
        if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
                                     QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
                                     .arg(this->fileName).arg(file.errorString()	));
            return false;
        }
        mode = "w+";
    }
    else
    {
        if (!file.open(QIODevice::Append | QIODevice::Text))
        {
            QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
                                     QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
                                     .arg(this->fileName).arg(file.errorString()	));
            return false;
        }
    }

    // insere o cabeçalho do arquivo
    if (header)
    {
        QString headers;
        for (int i = 0; i < attribList.size(); ++i)
        {
            headers += attribList.at(i);
            
            if (i < attribList.size() - 1)
                headers += separator;
        }
        header = false;
        headers += "\n";
        file.write(headers.toAscii().data(),  qstrlen( headers.toAscii().data() ));
    }

    QString text;
    for (int i = 0; i < valuesList.size(); ++i)
    {
        text += valuesList.at(i);

        if (i < attribList.size() - 1)
            text += separator;
    }

    text.append("\n");
    file.write(text.toAscii().data(), qstrlen( text.toAscii().data() ));
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
