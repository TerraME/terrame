#include "observerTable.h"

#include <QApplication>
#include <QVBoxLayout>
#include <QTreeWidgetItem>
#include <QDebug>

#include <math.h>

#include "visualArrangement.h"

ObserverTable::ObserverTable(Subject *subj, QWidget *parent)
    : QDialog(parent), ObserverInterf( subj ), QThread()
{
    observerType = TObsTable;
    subjectType = TObsUnknown;
    paused = false;

    setWindowTitle("TerraME Observer : Table");
    //setMaximumSize(QSize(200, 480));

    tableWidget = new QTreeWidget(this);
    tableWidget->setGeometry(8, 8, 184, 464);
    tableWidget->setAlternatingRowColors(true);
    tableWidget->setRootIsDecorated(false);

    QVBoxLayout *vertLayout = new QVBoxLayout();
    vertLayout->addWidget(tableWidget);

    setLayout(vertLayout);

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    start(QThread::IdlePriority);

    VisualArrangement::getInstance()->starts(getId(), this);
}

ObserverTable::~ObserverTable()
{
    wait();
    delete tableWidget;
    tableWidget = 0;
}

const TypesOfObservers ObserverTable::getType()
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
    attribList = attribs;

    QTreeWidgetItem *item;
    for(int i = 0; i < attribs.size(); i++)
    {
        item = new QTreeWidgetItem(tableWidget);
        item->setText(0, attribs.at(i));
    }
    // redimensiona o tamanho da coluna
    tableWidget->resizeColumnToContents(0);
}

bool ObserverTable::draw(QDataStream &state)
{
    QString msg;
    state >> msg;

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR); //, QString::SkipEmptyParts);
    QTreeWidgetItem *item = 0;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    // int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
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

    // redimensiona o tamanho da coluna
    tableWidget->resizeColumnToContents(1);
    qApp->processEvents();
    return true;
}

void ObserverTable::run()
{
    QThread::exec();
}

void ObserverTable::pause()
{
    paused = !paused;
}

QStringList ObserverTable::getAttributes()
{
    return attribList;
}

int ObserverTable::close()
{
    QDialog::close();
    QThread::exit(0);
    return 0;
}

void ObserverTable::resizeEvent(QResizeEvent *event)
{
    VisualArrangement::getInstance()->resizeEventDelegate(getId(), event);
}

void ObserverTable::moveEvent(QMoveEvent *event)
{
    VisualArrangement::getInstance()->moveEventDelegate(getId(), event);
}

void ObserverTable::closeEvent(QCloseEvent *event)
{
    VisualArrangement::getInstance()->closeEventDelegate();
}

void ObserverTable::save(std::string file, std::string extension)
{
      saveAsImage(file, extension);
}

void ObserverTable::saveAsImage(std::string file, std::string extension)
{
      QPixmap pixmap = grab();
      pixmap.save(file.c_str(), extension.c_str());
}
