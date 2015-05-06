#include "observerLogFile.h"

#include <QApplication>
#include <QMessageBox>
#include <QTextStream>
#include <QDebug>

#include "logFileTask.h"
#include "taskManager.h"

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
    #include "subjectAttributes.h"
#endif

ObserverLogFile::ObserverLogFile(Subject *subj, QObject *parent)
    : QObject(parent), ObserverInterf(subj) 
{
    observerType = TObsLogFile;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern

    UNKNOWN = "unknown";
    logTask = new LogFileTask(subj->getId(), subjectType);

    // // prioridade da thread
    // //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    //start(QThread::IdlePriority);
}

ObserverLogFile::~ObserverLogFile()
{
    delete logTask; logTask = 0;
}

const TypesOfObservers ObserverLogFile::getType() const
{
    return observerType;
}

#ifdef TME_BLACK_BOARD

bool ObserverLogFile::draw(QDataStream & /*state*/)
{
    BagOfTasks::TaskManager::getInstance().add(logTask);

    // qApp->processEvents();
    return (BlackBoard::getInstance().canDraw());
}

#else

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

    for (int i = 0; i < qtdParametros;i++)
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

#endif

void ObserverLogFile::setProperties(const QString &filename, const QString &separator, const QString &mode)
{
    if (logTask)
        logTask->setProperties(filename, separator, mode);
}

void ObserverLogFile::setFileName(const QString &filename)
{
    if (logTask)
        logTask->setFilename(filename);
}

void ObserverLogFile::setSeparator(const QString &sep)
{
    if (logTask)
        logTask->setSeparator(sep);
}

void ObserverLogFile::setWriteMode(const QString &mode)
{
    if (logTask)
        logTask->setWriteMode(mode);
}

const QString & ObserverLogFile::getWriteMode() const
{
    if (logTask)
        return logTask->getWriteMode();

    return UNKNOWN;
}

void ObserverLogFile::setAttributes(QStringList &attribs)
{
#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());
#endif

#ifndef TME_BLACK_BOARD
    attribList = attribs;
#endif

    if (logTask)
        logTask->createHeader(attribs);
}

QStringList ObserverLogFile::getAttributes()
{
#ifdef TME_BLACK_BOARD
    return (logTask ? logTask->getAttributes() : QStringList());
#else
    return attribList;
#endif
}

int ObserverLogFile::close()
{
    // QThread::exit(0);
    return 0;
}
