#include "observerTable.h"

#include <QApplication>
#include <QVBoxLayout>
#include <QTreeWidgetItem>
#include <QDebug>

#include <math.h>

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
	#include "subjectAttributes.h"
#endif

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
	// Performance Statistics
	#include "statistic.h"
#endif


ObserverTable::ObserverTable(Subject *subj, QWidget *parent)
    : QDialog(parent), ObserverInterf(subj) //, QThread()
{
    observerType = TObsTable;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern
    // paused = false;

    resize(200, 480);
    setWindowTitle("TerraME Observer : Table");
    //setMaximumSize(QSize(200, 480));

    tableWidget = new QTreeWidget(this);
    tableWidget->setGeometry(8, 8, 184, 464);
    tableWidget->setAlternatingRowColors(true);
    tableWidget->setRootIsDecorated(false);

    QVBoxLayout *vertLayout = new QVBoxLayout();
    vertLayout->addWidget(tableWidget);

    setLayout(vertLayout);

    showNormal(); // transferred to the run () method

    // thread priority
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);
}

ObserverTable::~ObserverTable()
{
    // wait();
    delete tableWidget;
    tableWidget = 0;
}

const TypesOfObservers ObserverTable::getType() const
{
    return observerType;
}

//void ObserverTable::closeEvent(QCloseEvent *e)
//{
//	pause();
//	wait();
//	e->accept();
//}

void ObserverTable::setColumnHeaders(QStringList &headers)
{
    for (int i = 0; i < headers.size(); i++)
    {
        QString c = headers.at(i);
        if (c.isNull() || c.isEmpty())
            headers[i] = "empty col " + QString::number(i);
    }
    tableWidget->setHeaderLabels(headers);
}

void ObserverTable::setAttributes(QStringList &attribs)
{
#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());
#endif

    attribList = attribs;

    QTreeWidgetItem *item;
    for(int i = 0; i < attribs.size(); i++)
    {
        item = new QTreeWidgetItem(tableWidget);
        item->setText(0, attribs.at(i));
    }
    // resizes the column size
    tableWidget->resizeColumnToContents(0);
}

#ifdef TME_BLACK_BOARD

bool ObserverTable::draw(QDataStream & /*state*/)
{
    bool ret = draw();

    tableWidget->resizeColumnToContents(1);
    qApp->processEvents();
    return ret;
}

#else // TME_BLACK_BOARD

bool ObserverTable::draw(QDataStream &state)
{
#ifdef TME_STATISTIC
    // spent time 'pop ()' up here
    double t = Statistic::getInstance().endVolatileTime();
    Statistic::getInstance().addElapsedTime("comunicacao table", t);

    // number of bytes transmitted
    Statistic::getInstance().addOccurrence("bytes table", in.device()->size());
#endif

    QString msg;
    state >> msg;

#ifdef TME_STATISTIC 
        t = Statistic::getInstance().startMicroTime();
#endif

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR); //, QString::SkipEmptyParts);
    QTreeWidgetItem *item = 0;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    // int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i = 0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        if(contains)
            item = tableWidget->topLevelItem(attribList.indexOf(key));

        switch (typeOfData)
        {
            case (TObsBool):
                if (contains)
                    item->setText(1, (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime):
                //break;

            case (TObsNumber):
                if (contains)
                    item->setText(1, tokens.at(j));
                break;

            default:
                if (contains)
                    item->setText(1, tokens.at(j));
                break;
        }
        j++;
    }

#ifdef TME_STATISTIC
        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime("rendering table", t);
#endif

    tableWidget->resizeColumnToContents(1);
    qApp->processEvents();
    return true;
}

#endif // TME_BLACK_BOARD

//void ObserverTable::run()
//{
//    QThread::exec();
//}
//
//void ObserverTable::pause()
//{
//    paused = !paused;
//}

QStringList ObserverTable::getAttributes()
{
    return attribList;
}

int ObserverTable::close()
{
    QDialog::close();
    // QThread::exit(0);
    return 0;
}

bool ObserverTable::draw()
{
    SubjectAttributes *subjAttr = BlackBoard::getInstance().getSubject(getSubjectId());
    QTreeWidgetItem *item = 0;
    QByteArray tmpValue;

    switch(subjectType)
    {
    default:
        for(int i = 0; i < attribList.size(); i++)
        {
            const RawAttribute *raw = subjAttr->getRawAttribute(attribList.at(i));
            item = tableWidget->topLevelItem(i);

            if (raw)
            {
                switch (raw->type)
                {
                case (TObsBool):
                    item->setText(1, (raw->number ? "true" : "false"));
                    break;

                case (TObsDateTime):
                    //break;

                case (TObsNumber):
                    doubleToText(raw->number, tmpValue, 20);
                    item->setText(1, tmpValue);
                    break;

                default:
                    item->setText(1, raw->text);
                    break;
                }
            }
        }
        break;

    case TObsNeighborhood:
        {
            const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();
            // qStableSort(subjectsIDs.begin(), subjectsIDs.end());

            tableWidget->clear();
            long time = clock();
            subjAttr->setTime(time + 1);
            double weight = 0.;

            SubjectAttributes *nestedSubj = 0;
            QTreeWidgetItem *item = 0;

            BlackBoard &bb = BlackBoard::getInstance();
            bb.getLocker()->lockForRead();

            for(int id = 0; id < subjectsIDs.size(); ++id)
            {
                nestedSubj = bb.getSubject(subjectsIDs.at(id));

                // if (nestedSubj && nestedSubj->getNumericValue(attribList.first(), weight))
                if (nestedSubj && nestedSubj->getNumericValue("weight", weight))
                {
                    item = new QTreeWidgetItem(tableWidget);
                    doubleToText(nestedSubj->getId(), tmpValue);
                    item->setText(0, tmpValue);

                    doubleToText(weight, tmpValue);
                    item->setText(1, tmpValue); 
                }
            }
            bb.getLocker()->unlock();
        }
        break;
    }
    return true;
}
