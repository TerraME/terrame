#include "statistic.h"

#include <QApplication>
#include <QStringList>
#include <QTextStream>
#include <QDateTime>
#include <QFile>
#include <QProcess>
#include <QThread>
#include <QDebug>


//class StatisticThread : public QThread
//{
//    // Q_OBJECT

//public:
//    StatisticThread()//  : QThread(parent)
//    {}

//    ~StatisticThread()
//    {
//        wait();
//    }

//    void run()
//    {
//        exec();
//    }
//};

Statistic &Statistic::getInstance()
{
    static Statistic stat;
    //static StatisticThread thread;
    //static bool moved = false;

    //if (! moved)
    //    stat.moveToThread(&thread);
    //moved = true;
    
    return stat;
}

Statistic::Statistic() : QObject()
{
    elapsedTimer = new QElapsedTimer();
    volatileTimer = new QElapsedTimer();

    timeStatistics.clear();
    occurStatistics.clear();
    
    elapsedTimer->start();
    
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
    delete elapsedTimer;
    delete volatileTimer;

    foreach(QVector<double> *v, timeStatistics.values())
        delete v;

    foreach(QVector<int> *v, occurStatistics.values())
        delete v;
}

//float Statistic::startTime()
//{
//    return elapsedTimer->elapsed() * 1.0;
//}
//
//float Statistic::elapsedTime()
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
    //QString dir = qApp->
    //memoryCollect->start();
    bool exec = QProcess::startDetached(qApp->applicationDirPath() + "/mem.bat");

    if (! exec)
        qDebug("Memory Collector was not found in the application path.");
}

bool Statistic::saveTimeStatistic()
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
        
        QFile file("timeStatistic_"
                   + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
                   + "_.csv");

        if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        QTextStream out(&file);

        QStringList keys = timeStatistics.keys();
        out << keys.join(";") << "\n";

        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (timeStatistics.value(key)->size() > i)
                    out <<  timeStatistics.value(key)->at(i) << ";";
                else
                    out <<  ";";
            }
            out << "\n";
        }
        file.close();
        ret = true;
    }

    return ret;
}

bool Statistic::saveOccurrenceStatistic()
{
    bool ret = false;

    // if (! occurStatistics.isEmpty())
    {
        QFile file("occurrences_"
                        + QDateTime::currentDateTime().toString("yyyy-MM-dd_hh-mm-ss")
                        + "_.csv");

        if (! file.open(QIODevice::WriteOnly | QIODevice::Text))
            return false;

        QTextStream out(&file);

        QStringList keys = occurStatistics.keys();
        out << keys.join(";") << "\n";

        int size = occurStatistics.value(keys.at(0))->size();

        for (int i = 0; i < size; i++)
        {
            foreach(QString key, keys)
            {
                if (occurStatistics.value(key)->size() > i)
                    out <<  occurStatistics.value(key)->at(i) << ";";
                else
                    out <<  ";";
            }
            out << "\n";
        }
        ret = true;
    }
    return ret;
}

bool Statistic::saveData()
{
    bool ret = false;

    if (! timeStatistics.isEmpty())
        ret = saveTimeStatistic();
    
    if (ret)
        qDebug() << "Time Statistics saved!";
    else
        qDebug() << "Time Statistics was not saved!";

    if (! occurStatistics.isEmpty())
        ret = saveOccurrenceStatistic();

    if (ret)
        qDebug() << "Occurrence Statistics saved!";
    else
        qDebug() << "Occurrence Statistics was not saved!";

    return ret;
}
