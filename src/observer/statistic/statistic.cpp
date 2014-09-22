#include "statistic.h"

#include <QApplication>
#include <QStringList>
#include <QTextStream>
#include <QDateTime>
#include <QFile>
#include <QProcess>
#include <QThread>
#include <QDebug>

#include <math.h>


Statistic &Statistic::getInstance()
{
    static Statistic stat;
    return stat;
}

Statistic::Statistic() : QObject()
{
    //elapsedTimer = new QElapsedTimer();
    //volatileTimer = new QElapsedTimer();

    timeStatistics.clear();
    occurStatistics.clear();
    
    disableRemove = false;
    observerCount = -1;
    
    //elapsedTimer->start();

//
//#ifdef _MSC_VER
//    // QueryPerformanceCounter ( (LARGE_INTEGER*)(&startMicroTime_ ) );
//    // endMicroTime_ = startMicroTime_;
//#else
//    // gettimeofday(&startMicroTime_, NULL);
//#endif
}

Statistic::~Statistic()
{
    //delete elapsedTimer;
    //delete volatileTimer;

    foreach(QVector<double> *v, timeStatistics.values())
        delete v;

    foreach(QVector<int> *v, occurStatistics.values())
        delete v;
}

//double Statistic::startTime()
//{
//    return elapsedTimer->elapsed() * 1.0;
//}
//
//double Statistic::elapsedTime()
//{
//    return elapsedTimer->elapsed() * 1.0;
//}

void Statistic::addElapsedTime(const QString &name, double value)
{
    QVector<double> *stat = 0;

    if (timeStatistics.contains(name))
    {
        stat = timeStatistics[name];
        stat->push_back(value);
    }
    else
    {
        stat = new QVector<double>();
        stat->push_back(value);

        timeStatistics.insert(name, stat);
    }
}

void Statistic::addOccurrence(const QString &name, int occur)
{
    QVector<int> *stat = 0;

    if (occurStatistics.contains(name))
    {
        stat = occurStatistics[name];
        stat->push_back(occur);
    }
    else
    {
        stat = new QVector<int>();
        stat->push_back(occur);

        occurStatistics.insert(name, stat);
    }
}

void Statistic::collectMemoryUsage()
{
#ifdef TME_WIN32
    bool exec = QProcess::startDetached(qApp->applicationDirPath() + "/mem.bat");
#else
    bool exec = QProcess::startDetached(qApp->applicationDirPath() + "/./mem.sh");
#endif
    // qDebug() << qApp->applicationDirPath() ;

    if (! exec)
        qDebug("Memory Collector was not found in the application path.");
}

bool Statistic::saveTimeStatistic(const QString &prefix)
{
    bool ret = false;

    //// if (! timeStatistics.isEmpty())
    //{
    //    QFile file("timeStatistic_"
    //               + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
    //               + "_.csv");

    //    if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
    //        return false;

    //    QTextStream out(&file);

    //    QStringList keys = timeStatistics.keys();
    //    out << keys.join(";") << "\n";

    //    int size = timeStatistics.value(keys.at(0))->size();

    //    for (int i = 0; i < size; i++)
    //    {
    //        foreach(QString key, keys)
    //            out <<  timeStatistics.value(key)->at(i) << ";";

    //        out << "\n";
    //    }
    //    file.close();
    //    ret = true;
    //}

    // if (! timeStatistics.isEmpty())
    {
        int size = -1;
        for (int i = 0; i < timeStatistics.values().size(); i++)
            size = qMax(timeStatistics.values().at(i)->size(), size);
        
        QString name ("timeStatistic_");
        name.prepend(prefix);

        QFile file(name
                   + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
                   + "_.csv");

        if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        const QStringList &keys = timeStatistics.keys();
        // qStableSort(keys.begin(), keys.end());

        QMap<QString, QPair<QVector<double> *, double> > diffSquare;
        double value = 0;
        for (int i = 0; i < keys.size(); i++)
        {
            diffSquare.insert(keys.at(i), 
                qMakePair<QVector<double> *, double>(new QVector<double>(), 0) );
        }

        QTextStream out(&file);

        out << keys.join(";") << "\n";

        // remove o primeiro e o ˙ltimo elemento, se n„o È o modo receiver
        if (! disableRemove)
        {
            foreach(QString key, keys)
            {
                if (! timeStatistics.value(key)->isEmpty())
                    timeStatistics.value(key)->pop_front();

                if (! timeStatistics.value(key)->isEmpty())
                    timeStatistics.value(key)->pop_back();
                        
                if (key.toLower().contains("pop lua"))
                {
                    for (int i = 0; (i < observerCount - 1) && (i < timeStatistics.value(key)->size()); i++)
                    {
                        timeStatistics.value(key)->pop_front(); 
                        timeStatistics.value(key)->pop_back();
                    }
                }
            }
        }

        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (timeStatistics.value(key)->size() > i)
                {
                    out <<  timeStatistics.value(key)->at(i) << ";";
                    diffSquare[key].second += timeStatistics.value(key)->at(i);
                }
                else
                {
                    out <<  ";";
            	}
            }
            out << "\n";
        }
        file.close();
 
        foreach(QString key, keys)
        {
            if (timeStatistics.value(key)->size() > 1)
                diffSquare[key].second /= timeStatistics.value(key)->size();
            else
                diffSquare[key].second = -1;
        }


        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (timeStatistics.value(key)->size() > i)
                {
                    value = timeStatistics.value(key)->at(i)- diffSquare.value(key).second;
                    diffSquare[key].first->append( pow(value, 2) ); 
                }
            }
        }

        // Salva no arquivo de analise   
        name = QString("%1analized_timeStatistic_").arg(prefix);
        QFile fileAnalysis(name
            + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
            + "_.csv");

        if (! fileAnalysis.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        QTextStream outAnalysis(&fileAnalysis);

        outAnalysis << keys.join(";") << ";\n";

        QString line1("media;"), line2("desvio padrao;");
        foreach(QString key, keys)
        {
            double sum = 0, value = 0;
            sum = diffSquare.value(key).second;

            // soma dos quadrados das diferenÁas
            for (int i = 0; i < diffSquare.value(key).first->size(); i++)
                value += diffSquare.value(key).first->at(i);

            if (diffSquare.value(key).first->size() > 1)
                value /= (diffSquare.value(key).first->size() - 1);
            else
                value = -1;

            line1.append( QString::number(sum) );
            line1.append(";");
            line2.append( QString::number( sqrt(value), 'g', 6));
            line2.append(";");
        }

        outAnalysis << line1 << "\n";
        outAnalysis << line2 << "\n";

        fileAnalysis.close();
        ret = true;
    }

    return ret;
}

bool Statistic::saveOccurrenceStatistic(const QString &prefix)
{
    bool ret = false;

    // if (! occurStatistics.isEmpty())
    {
        QString name("occurrences_");
        name.prepend(prefix);

        QFile file(name
            + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
            + "_.csv");

        if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        QTextStream out(&file);

        const QStringList &keys = occurStatistics.keys();
        out << keys.join(";") << ";\n";

        // remove o primeiro e o ˙ltimo elemento, se n„o È o modo receiver
        if (! disableRemove)
        {
            foreach(QString key, keys)
            {
                if (! occurStatistics.value(key)->isEmpty())
                    occurStatistics.value(key)->pop_front();

                if (! occurStatistics.value(key)->isEmpty())
                    occurStatistics.value(key)->pop_back();
                        
                if (key.toLower().contains("bytes sent"))
                {
                    for (int i = 0; (i < observerCount - 1) && (i < occurStatistics.value(key)->size()); i++)
                    {
                        occurStatistics.value(key)->pop_front();
                        occurStatistics.value(key)->pop_back();
                    }
                }
            }
        }

        QMap<QString, QPair<QVector<int> *, double> > diffSquare;
        double value = 0;

        for (int i = 0; i < keys.size(); i++)
        {
            diffSquare.insert(keys.at(i), 
                qMakePair<QVector<int> *, double>(new QVector<int>(), 0) );
        }        
        
        int size = -1;
        for (int i = 0; i < occurStatistics.values().size(); i++)
            size = qMax(occurStatistics.values().at(i)->size(), size);

        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (occurStatistics.value(key)->size() > i)
                {
                    out <<  occurStatistics.value(key)->at(i) << ";";
                    diffSquare[key].second += occurStatistics.value(key)->at(i);
                }
                else
                {
                    out <<  ";";
            	}
            }
            out << "\n";
        }
        file.close();
 
        foreach(QString key, keys)
        {
            if (occurStatistics.value(key)->size() > 1)
                diffSquare[key].second /= occurStatistics.value(key)->size();
            else
                diffSquare[key].second = -1;
        }

        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (occurStatistics.value(key)->size() > i)
                {
                    value = occurStatistics.value(key)->at(i) - diffSquare.value(key).second;
                    diffSquare[key].first->append( pow(value, 2) ); 
                }
            }
        }

        
        // Salva no arquivo de analise
        name = QString("%1analized_occurrences_").arg(prefix);
        QFile fileAnalysis(name
            + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
            + "_.csv");

        if (! fileAnalysis.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        QTextStream outAnalysis(&fileAnalysis);
        
        outAnalysis << keys.join(";") << ";\n";

        QString line1("media;"), line2("desvio padrao;");
        foreach(QString key, keys)
        {
            double sum = 0, value = 0;
            int i = 0;
            sum = diffSquare.value(key).second;

            // soma dos quadrados das diferenÁas
            // ignora o primeiro resultado (notify de inicializaÁ„o)
            for (i = 0; i < diffSquare.value(key).first->size(); i++)
                value += diffSquare.value(key).first->at(i);

            if (diffSquare.value(key).first->size() > 1)
                value /= (diffSquare.value(key).first->size() - 1);
            else
                value = -1;

            line1.append( QString::number(sum) );
            line1.append(";");
            line2.append( QString::number( sqrt(value), 'g', 6));
            line2.append(";");
        }

        outAnalysis << line1 << "\n";
        outAnalysis << line2 << "\n";

        fileAnalysis.close();
        ret = true;
    }
    return ret;
}

bool Statistic::saveData(const QString &prefix)
{
    bool ret = false;

    if (! timeStatistics.isEmpty())
        ret = saveTimeStatistic(prefix);
    
    if (ret)
    {
        qDebug() << "Time Statistics saved!";
        timeStatistics.clear();
    }
    else
    {
        qDebug() << "Time Statistics was not saved!";
    }

    if (! occurStatistics.isEmpty())
        ret = saveOccurrenceStatistic(prefix);

    if (ret)
    {
        qDebug() << "Occurrence Statistics saved!";
        occurStatistics.clear();
    }
    else
    {
        qDebug() << "Occurrence Statistics was not saved!";
    }
    return ret;
}

void Statistic::setObserverCount(int num)
{
    observerCount = qMax(observerCount, num);
}

void Statistic::setDisableRemove(bool on)
{
    disableRemove = on;
}
