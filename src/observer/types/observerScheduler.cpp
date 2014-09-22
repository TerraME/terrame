#include "observerScheduler.h"

#include <QTreeWidget>
#include <QLabel>
#include <QToolButton>
#include <QFont>
#include <QHBoxLayout>
#include <QApplication>
#include <QDebug>

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
    #include "subjectAttributes.h"
#endif

using namespace TerraMEObserver;

ObserverScheduler::ObserverScheduler(Subject *s, QWidget *parent)
    : ObserverInterf( s ), QDialog(parent) // , QThread()
{
    observerType = TObsScheduler;
    subjectType = s->getType(); // TO_DO: Changes it to Observer pattern

    paused = false;

    resize(200, 140);  // feito no final
    setWindowTitle("TerraME Observer : Scheduler");

    clockPanel = new QWidget(this);
    clockPanel->setObjectName(QString::fromUtf8("clockPanel"));
    clockPanel->setMinimumSize(QSize(190, 0));
    clockPanel->setMaximumSize(QSize(190, 16777215));

    QHBoxLayout *hboxLayout1 = new QHBoxLayout();
    hboxLayout1->setSpacing(0);
    hboxLayout1->setObjectName(QString::fromUtf8("hboxLayout1"));

    butExpand = new QToolButton(clockPanel);
    butExpand->setObjectName(QString::fromUtf8("butExpand"));
    butExpand->setMinimumSize(QSize(20, 20));
    butExpand->setAutoRaise(true);
    butExpand->setText("»");  // "«" "»"

    QSpacerItem *horizSpacerItem = new QSpacerItem(40, 20, QSizePolicy::Expanding, QSizePolicy::Minimum);

    hboxLayout1->addItem(horizSpacerItem);
    hboxLayout1->addWidget(butExpand);

    QFont font;
    font.setFamily(QString::fromUtf8("Verdana"));
    font.setPointSize(26);
    font.setStyleStrategy(QFont::PreferDefault);

    lblClock = new QLabel(clockPanel);
    lblClock->setObjectName(QString::fromUtf8("lblClock"));
    lblClock->setFont(font);
    lblClock->setFrameShape(QFrame::Box);
    lblClock->setFrameShadow(QFrame::Raised);
    lblClock->setAlignment(Qt::AlignCenter);
    lblClock->setText("00:00:00");

    QVBoxLayout *vboxLayout = new QVBoxLayout(clockPanel);
    vboxLayout->setObjectName(QString::fromUtf8("vboxLayout"));
    vboxLayout->setSpacing(0);

    vboxLayout->addLayout(hboxLayout1);
    vboxLayout->addWidget(lblClock);

    QSpacerItem *vertSpacerItem = new QSpacerItem(20, 40, QSizePolicy::Minimum, QSizePolicy::Expanding);
    vboxLayout->addItem(vertSpacerItem);

    QStringList headers;
    headers << "Event Key   " 
            << "Time        " 
            << "Peridiocity " 
            << "Priority    ";

    pipelineWidget = new QTreeWidget(this);
    pipelineWidget->setObjectName(QString::fromUtf8("pipelineWidget"));
    pipelineWidget->setRootIsDecorated(false);
    pipelineWidget->setHeaderLabels(headers);
    pipelineWidget->setVisible(false);
    //	pipelineWidget->setSortingEnabled(true);

    pipelineWidget->sortItems(0, Qt::AscendingOrder); //Qt::DescendingOrder);

    QHBoxLayout *hboxLayout = new QHBoxLayout();
    hboxLayout->setObjectName(QString::fromUtf8("hboxLayout"));
    hboxLayout->setSpacing(0);

    hboxLayout->addWidget(clockPanel);
    hboxLayout->addWidget(pipelineWidget);

    setLayout(hboxLayout);
    showNormal();

    QDialog::connect(butExpand, SIGNAL(clicked()), (QDialog *)this, SLOT(on_butExpand_clicked()));

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);

    on_butExpand_clicked();
}


ObserverScheduler::~ObserverScheduler(void)
{
    // wait();

    delete pipelineWidget; pipelineWidget = 0;
    delete lblClock; lblClock = 0;

    delete clockPanel; clockPanel = 0;
    //    delete butExpand; butExpand = 0;

    //foreach(QTreeWidgetItem *item, hashTreeItem.values())
    //    delete item;
}

const TypesOfObservers ObserverScheduler::getType() const
{
    return observerType;
}

#ifdef TME_BLACK_BOARD

bool ObserverScheduler::draw(QDataStream & /*state*/)
{
    pipelineWidget->setSortingEnabled(false);

    draw();

    pipelineWidget->setSortingEnabled(true);
    pipelineWidget->sortByColumn(Priority, Qt::AscendingOrder);
    pipelineWidget->sortByColumn(Time, Qt::AscendingOrder);

    qApp->processEvents();
    return true;
}

#else

bool ObserverScheduler::draw(QDataStream & state)
{
    pipelineWidget->setSortingEnabled(false);

    double num;
    QString msg, timer;
    state >> msg;

    QStringList tokens = msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);
    QTreeWidgetItem *item = 0;

    // QString subjectId = tokens.at(0);
    // int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt() * 3;
    // int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i = 0; i < qtdParametros; i += 3)
    {
        QString key = tokens.at(j);
        j++;

        int typeOfData = tokens.at(j).toInt();
        j++;

        switch (typeOfData)
        {
            case (TObsBool):
                // break;

            case (TObsDateTime):
                break;

            case (TObsNumber):
                if (key.contains("@"))
                {
                    item = hashTreeItem.value( key );

                    // recupera o eventTime
                    num = tokens.at(j).toDouble();
                    item->setText(Time,  number2String(num));
                    j += 3;

                    // recupera o period
                    num = tokens.at(j).toDouble();
                    item->setText(Periodicity,  number2String(num));
                    j += 3;

                    // recupera o priority
                    num = tokens.at(j).toDouble();
                    item->setText(Priority, number2String(num));

                    i += 6;
                }
                break;

            default:
                if (key == TIMER_KEY)
                    timer = tokens.at(j);
        }
        j++;
    }

    setTimer(timer);

    pipelineWidget->setSortingEnabled(true);
    pipelineWidget->sortByColumn(Priority, Qt::AscendingOrder);
    pipelineWidget->sortByColumn(Time, Qt::AscendingOrder);

    qApp->processEvents();
    return true;
}

#endif // TME_BLACKBOARD

//void ObserverScheduler::pause()
//{
//    paused = !paused;
//}

void ObserverScheduler::setAttributes(QStringList &attribs)
{
#ifdef TME_BLACK_BOARD
    BlackBoard::getInstance().addSubject(getSubjectId());
    // SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
#endif

    attribList = attribs;

    QString evKey;
    QTreeWidgetItem *item = 0;
    for(int i = 0; i < attribList.size(); i++)
    {
        // o atributo TIMER_KEY é apresentado apenas na GUI do observer
        if ((attribList.at(i) != TIMER_KEY) && (attribList.at(i).contains("@")) )
        {
            evKey = attribList.at(i);
            item = new QTreeWidgetItem(pipelineWidget);
            item->setText(Key, evKey.remove(0, 1) );

            item->setText(Time, QString::number(0) );
            item->setText(Periodicity, QString::number(0) );
            item->setText(Priority, QString::number(0) );

            hashTreeItem.insert(attribList.at(i), item);
        }
    }

    // redimensiona o tamanho da coluna
    pipelineWidget->resizeColumnToContents(Key);
    pipelineWidget->resizeColumnToContents(Time);
    pipelineWidget->resizeColumnToContents(Periodicity);
    pipelineWidget->resizeColumnToContents(Priority);
}

QStringList ObserverScheduler::getAttributes()
{
    return attribList;
}

void ObserverScheduler::on_butExpand_clicked()
{
    pipelineWidget->setVisible(! pipelineWidget->isVisible());
    pipelineWidget->resize(400, clockPanel->height());

    if (pipelineWidget->isVisible())
    {
        resize(QSize(600, height()));
        butExpand->setText("«");
    }
    else
    {
        resize(QSize(50, height()));
        butExpand->setText("»");  // "«" "»"
    }
}

void ObserverScheduler::setTimer(const QString &timer)
{
    lblClock->setText(timer);
}

// Verificar complexidade, pois para cada evento esse 
// método é chamado 3 vezes.
const QString ObserverScheduler::number2String(double number)
{
    static const QString COMPLEMENT("000000");

    QString aux, countString = QString::number(number);
    aux = COMPLEMENT;
    aux = aux.left(COMPLEMENT.size() - countString.size());
    aux.append(countString);
    return aux;
}

int ObserverScheduler::close()
{
    return QDialog::close();
}

bool ObserverScheduler::draw()
{
    SubjectAttributes *subjAttr = BlackBoard::getInstance().getSubject(getSubjectId());
    QTreeWidgetItem *item = 0;
    double num = 0.0;

//#ifdef DEBUG_OBSERVER
//    //qDebug() << BlackBoard::getInstance().getSubject(1)->toString() << "\n\n"
//    //    << BlackBoard::getInstance().getSubject(2)->toString();
//    // qDebug() << attribList;
//#endif

    // The first position of attribute list contains the TIMER_KEY attribute
    // So the loop starts from second position
    for(int i = 1; i < attribList.size(); i++)
    {
        // Gets the name of the event
        const RawAttribute *raw = subjAttr->getRawAttribute(attribList.at(i));
            
        if (raw)
        {
            int id = (int) raw->number;
            item = hashTreeItem.value( raw->key );
            
            SubjectAttributes *innerSubjAttr = BlackBoard::getInstance().getSubject(id);

            innerSubjAttr->getNumericValue("Time", num);
            item->setText(Time,  number2String(num));

            innerSubjAttr->getNumericValue("Periodicity", num);
            item->setText(Periodicity,  number2String(num));

            innerSubjAttr->getNumericValue("Priority", num);
            item->setText(Priority,  number2String(num));

            //qDebug() << item->text(0) << item->text(Time) << item->text(Periodicity) << item->text(Priority);
        }
#ifdef DEBUG_OBSERVER
        else
        {
            qDebug() << "\n raw == NULL";
            qDebug() << subjAttr->toString();
        }
#endif
    }
    setTimer(QString::number( subjAttr->getRawAttribute(TIMER_KEY)->number ));
    return true;
}
