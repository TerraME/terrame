#include "logFileTask.h"

#include <QFile>
#include <QMessageBox>


#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
    #include "subjectAttributes.h"
#endif

using namespace TerraMEObserver;
using namespace BagOfTasks;

LogFileTask::LogFileTask(int subjID, TypesOfSubjects type) 
    : Task(), subjectId(subjID), subjectType(type)
{
    setType(Task::Arbitrary);
    executing = false;
    header = false;

    setProperties();
}

LogFileTask::~LogFileTask()
{

}

bool LogFileTask::execute()
{
    if (executing)
        return false;
     executing = true;

    bool ret = draw();
    ret = ret && rendering();

    if (subjectType == TObsNeighborhood)
        attribList.clear();

    executing = false;
    return ret;
}

void LogFileTask::setProperties(const QString &filename, const QString &separator, const QString &mode)
{
    this->filename = filename;
    this->separator = separator;
    this->mode = mode;
}

void LogFileTask::setFilename(const QString &filename)
{
    this->filename = filename;
}

void LogFileTask::setSeparator(const QString &separator)
{
    this->separator = separator;
}

void LogFileTask::setWriteMode(const QString &mode)
{
    this->mode = mode;
}

const QString & LogFileTask::getWriteMode() const
{
    return mode;
}

void LogFileTask::createHeader(const QStringList &attribs)
{
    attribList = attribs;

    for (int i = 0; i < attribs.size(); i++)
        valuesList.insert(i, ""); // lista dos itens na ordem em que aparecem
    header = true;
}

bool LogFileTask::rendering()
{
    QFile file(filename);

    // Caso já exista o arquivo, os novos valores são inseridos ao final do arquivo
    // Caso contrário, cria o arquivo com o nome passado.
    //if (!QFile::exists(filename)){
    //	if (!file.open(QIODevice::WriteOnly | QIODevice::Text)){
    //		QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
    // QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
    //			.arg(filename).arg(file.errorString()	));
    //		return false;
    //	}
    //}
    //else{
    //	if (!file.open(QIODevice::Append | QIODevice::Text)){
    //		QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
    // QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
    //			.arg(filename).arg(file.errorString()	));
    //		return false;
    //	}
    //}

    //if (!QFile::exists(fileName)){
    if (mode == "w")
    {
        if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            QMessageBox::information(0, QObject::tr("Erro ao abrir arquivo"),
                                     QObject::tr("Não foi possível abrir o arquivo de log \"%1\".\n%2")
                                     .arg(filename).arg(file.errorString()	));
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
                                     .arg(filename).arg(file.errorString()	));
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
        file.write(headers.toLatin1().data(),  qstrlen( headers.toLatin1().data() ));
    }

    QString text;
    for (int i = 0; i < valuesList.size(); ++i)
    {
        text += valuesList.at(i);

        if (i < attribList.size() - 1)
            text += separator;
    }

    text.append("\n");
    file.write(text.toLatin1().data(), qstrlen( text.toLatin1().data() ));
    file.close();

    return true;
}


bool LogFileTask::draw()
{
    SubjectAttributes *subjAttr = BlackBoard::getInstance().getSubject(subjectId);
    QByteArray tmpValue;

    switch(subjectType)
    {
    default:
        for(int i = 0; i < attribList.size(); i++)
        {
            const RawAttribute *raw = subjAttr->getRawAttribute(attribList.at(i));

            if (raw)
            {
                switch (raw->type)
                {
                case (TObsBool):
                    valuesList.replace(i, (raw->number ? "true" : "false"));
                    break;

                case (TObsDateTime):
                    //break;

                case (TObsNumber):
                    doubleToText(raw->number, tmpValue);
                    valuesList.replace(i, tmpValue);
                    break;

                default:
                    valuesList.replace(i, raw->text);
                    break;
                }
            }
        }
        break;

    case TObsNeighborhood:
        {
            const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();
            // qStableSort(subjectsIDs.begin(), subjectsIDs.end());

            attribList.clear();
            valuesList.clear();

            long time = clock();
            subjAttr->setTime(time + 1);
            double weight = 0.;

            SubjectAttributes *nestedSubj = 0;

            BlackBoard &bb = BlackBoard::getInstance();
            bb.getLocker()->lockForRead();

            for(int id = 0; id < subjectsIDs.size(); ++id)
            {
                nestedSubj = bb.getSubject( subjectsIDs.at(id) );

                if (nestedSubj && nestedSubj->getNumericValue("weight", weight))
                {
                    doubleToText( nestedSubj->getId(), tmpValue);
                    attribList.append("neighbor");
                    valuesList.append(tmpValue);

                    doubleToText(weight, tmpValue);
                    attribList.append("weight");
                    valuesList.append(tmpValue);
                }
            }
            bb.getLocker()->unlock();
        }
        break;
    }

    return true;
}
