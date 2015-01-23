#include "observerImpl.h"
#include "observerInterf.h"

#include <time.h>
#include <string>
#include <QApplication>
#include <QBuffer>
#include <QByteArray>
#include <QDebug>

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
#endif

#ifdef TME_STATISTIC
    #include "statistic.h"
#endif

#include "legendAttributes.h"

using namespace TerraMEObserver;

const char *const observersTypesNames[] =
{
    "", "TextScreen", "LogFile", "Table", "Graphic",
    "DynamicGraphic", "Map", "UDPSender", "Scheduler",
    "Image", "StateMachine", "Neigh", "Shapefile", 
    "TCPSender"
};

const char *const subjectTypesNames[] =
{
    "", "Cell", "CellularSpace", "Neighborhood", "Timer",
    "Event", "Trajectory", "Automaton", "Agent", "Environment",
    "Society"
    /* "Message", "State", "JumpCondition", "FlowCondition" */ 
};

const char *const dataTypesNames[] =
{
    "Bool", "Number", "DateTime", "Text"
};

const char *const groupingModeNames[] =
{
    "EqualSteps", "Quantil", "StdDeviation", "UniqueValue"
};

const char *const stdDevNames[] =
{
    "Full", "Half", "Quarter"
};

// const char *getSubjectName(TypesOfSubjects type)
const char *getSubjectName(int type)
{
    return (type == TObsUnknown) ? "Unknown" : subjectTypesNames[type];
}

//const char *getObserverName(TypesOfObservers type)
const char *getObserverName(int type)
{
    return (type == TObsUndefined) ? "undefined" : observersTypesNames[type];
}

//const char *getDataName(TypesOfData type)
const char *getDataName(int type)
{
    return (type == TObsUnknownData) ? "UnknownData" : dataTypesNames[type];
}

//const char *getGroupingName(GroupingMode type)
const char *getGroupingName(int type)
{
    return groupingModeNames[type];
}

//const char *getStdDevNames(StdDev type)
const char *getStdDevNames(int type)
{
    return (type == TObsNone) ? "None" : stdDevNames[type];
}

bool sortAttribByType(Attributes *a, Attributes *b)
{
    return a->getType() < b->getType();
}

bool sortByClassName(const QPair<Subject *, QString> & pair1, 
    const QPair<Subject *, QString> & pair2) 
{
    return pair1.second.toLower() < pair2.second.toLower();
}

void delay(double seconds)
{
    clock_t endwait;
    endwait = clock() + seconds * CLOCKS_PER_SEC ;
    while (clock() < endwait)
        qApp->processEvents();
}

#include <QFile>
#include <QTextStream>

void TerraMEObserver::dumpRetrievedState(const QString & msg, const QString &name)
{
    static int asas = 0;
	asas++;

    QFile file(name + QString::number(asas) + ".txt");
    if(file.open(QIODevice::WriteOnly | QIODevice::Text))
    {
        QTextStream out(&file);

        foreach(const QString x, msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts))
            out << x << "\n";
    }
}

void TerraMEObserver::formatSpeed(double speed, QString &strSpeed)
{
    strSpeed = QObject::tr("Speed: ");

    if(speed < 1024)
	{
        strSpeed.append(QString("%1 bytes/s").arg(speed, 3, 'f', 1) );
    }
    else
    {
        if(speed < MEGABYTE_VALUE)
            strSpeed.append(QString("%1 KB/s").arg(speed * KILOBYTE_DIV, 3, 'f', 1));
        else
            strSpeed.append(QString("%1 MB/s").arg(speed * MEGABYTE_DIV, 3, 'f', 1));
    }
}

// store the number of observers created along the simulation
static long int numObserverCreated = 0;
static long int numSubjectCreated = 0;

//////////////////////////////////////////////////////////// Observer
ObserverImpl::ObserverImpl() : visible(true)
{ 
    numObserverCreated++;
    observerID = numObserverCreated;
}

ObserverImpl::ObserverImpl(const ObserverImpl &other)
{
    if(this != &other)
    {
        observerID = other.observerID;
        visible = other.visible;

        delete subject_;
        delete obsHandle_;

        subject_ = other.subject_;
        obsHandle_ = other.obsHandle_;
    }
}

ObserverImpl & ObserverImpl::operator=(ObserverImpl &other)
{
    if(this == &other)
        return *this;

    observerID = other.observerID;
    visible = other.visible;

    delete subject_;
    delete obsHandle_;

    subject_ = other.subject_;
    obsHandle_ = other.obsHandle_;

    return *this;
}

ObserverImpl::~ObserverImpl()
{
    bool thereAreOpenWidgets = false;
    foreach (QWidget *widget, QApplication::allWidgets())
    {
        if(widget)
            thereAreOpenWidgets = true;
    }
    if(!thereAreOpenWidgets)
        QApplication::exit();
}

bool ObserverImpl::update(double time)
{
#ifdef TME_STATISTIC
    double t = 0;
    QString name;
#endif

    if(obsHandle_->getType() == TObsDynamicGraphic)
        obsHandle_->setModelTime(time);

    // TO-DO: Otimizar, retornar referencia ou ponteiro
    // recupera a lista de atributos em observacao
    QStringList attribList = obsHandle_->getAttributes();

#ifdef TME_BLACK_BOARD

#ifdef TME_STATISTIC
    if((time == -1) && (obsHandle_->getType() == TObsUDPSender))
    {
        obsHandle_->setModelTime(time);
    }
    else
    {
        t = Statistic::getInstance().startMicroTime();

   		// getState via BlackBoard
    	QDataStream& state = BlackBoard::getInstance().getState(subject_, obsHandle_->getId(), attribList);

        name = QString("Recovery with bb %1").arg(getId());
    	t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime(name, t);

        // Captura o tempo do 'draw()'
        t = Statistic::getInstance().startMicroTime();
        
        // Captura o tempo de espera para os observadores que tambem sao threads
        // Statistic::getInstance().startVolatileMicroTime();

    	obsHandle_->draw(state);
        //state.device()->close();

        name = QString("Manager %1").arg(getId());
        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime(name, t);
    }    
#else
    // getState via BlackBoard
    QDataStream& state = BlackBoard::getInstance().getState(subject_, obsHandle_->getId(), attribList);

    obsHandle_->draw(state);
    state.device()->close(); 
#endif

#else  // TME_BLACK_BOARD
    // getState feito a partir do subject
    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    QDataStream out(&buffer);

    buffer.open(QIODevice::WriteOnly);
    
#ifdef TME_STATISTIC
    if((time == -1) && (obsHandle_->getType() == TObsUDPSender))
    {
        obsHandle_->setModelTime(time);
    }
    else
    {
        t = Statistic::getInstance().startMicroTime();
#endif
    	QDataStream& state = subject_->getState(out, subject_, obsHandle_->getId(), attribList);

        // State is already available
        buffer.close();
        buffer.open(QIODevice::ReadOnly);

#ifdef TME_STATISTIC 
        // numero de bytes transmitidos
        Statistic::getInstance().addOccurrence("bytes serialized", state.device()->size());

        name = QString("Recovery without BB %1").arg(getId());
    	t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime(name, t);

        // Captura o tempo do 'draw()'
        t = Statistic::getInstance().startMicroTime();

        // Captura o tempo de espera para os observadores que tambem sao threads
        Statistic::getInstance().startVolatileMicroTime();
#endif
    	obsHandle_->draw(state);
    	buffer.close();

#ifdef TME_STATISTIC 
        name = QString("Draw %1").arg(getId());
        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime(name, t);
    }
#endif

#endif  // TME_BLACK_BOARD
    return true;
}

bool ObserverImpl::getVisible() const
{
    return ObserverImpl::visible;
}

void ObserverImpl::setVisible(bool visible)
{
    ObserverImpl::visible = visible;
}

void ObserverImpl::setSubject(TerraMEObserver::Subject *s)
{
    subject_ = s;
}

void ObserverImpl::setObsHandle(Observer* obs)
{
    obsHandle_	= obs;
    subject_->attach(obs);
}

const TypesOfObservers ObserverImpl::getObserverType() const
{
    return obsHandle_->getType();
}

const TypesOfSubjects ObserverImpl::getSubjectType() const
{
    return subject_->getType();
}

int ObserverImpl::getId() const
{
    return observerID;
}

int ObserverImpl::getSubjectId() const
{
    return subject_->getId();
}

QStringList ObserverImpl::getAttributes()
{
    return QStringList();
}

void ObserverImpl::setModelTime(double time)
{
    obsHandle_->setModelTime(time);
}

void ObserverImpl::setDirtyBit()
{
    // TO DO: Not finished the use of dirty bit flag
    // obsHandle_->setDirtyBit();
}

//void ObserverImpl::setId(int id)
//{
//    observerID = id;
//}

int ObserverImpl::close()
{
    return 0;
}

////////////////////////////////////////////////////////////  Subject
SubjectImpl::SubjectImpl()
{
    numSubjectCreated++;
    subjectID = numSubjectCreated;
}

SubjectImpl::SubjectImpl(const SubjectImpl &other)
{
    if(this != &other)
    {
        observers.clear();
        ObsList &obs = (ObsList &) other.observers;
        ObsListIterator i = obs.begin();
        for(; i != obs.end(); ++i)
            observers.push_back(*i);
    }
}

SubjectImpl & SubjectImpl::operator=(SubjectImpl &other)
{
    if(this == &other)
        return *this;

    observers.clear();
    ObsList &obs = (ObsList &) other.observers;
    ObsListIterator i = obs.begin();
    for (; i != obs.end(); ++i)
        observers.push_back(*i);

    return *this;
}

SubjectImpl::~SubjectImpl()
{
}

void SubjectImpl::attachObserver(Observer* obs)
{
    observers.push_back(obs);
}

void SubjectImpl::detachObserver(Observer* obs)
{
    observers.remove(obs);
}

Observer * SubjectImpl::getObserverById(int id)
{
    Observer *obs = 0;

    for(ObsListIterator i (observers.begin()); i != observers.end(); ++i)
    {
        if((*i)->getId() == id)
        {
            obs = *i;
            break;
        }
    }
    return obs;
}

void SubjectImpl::notifyObservers(double time) 
{
#ifdef TME_BLACK_BOARD
    BlackBoard::getInstance().stopControl();
    BlackBoard::getInstance().setDirtyBit(getId());
#endif

    ObsList detachList;

#ifdef TME_STATISTIC
    for(ObsListIterator i (observers.begin()); i != observers.end(); ++i)
    {
//#ifdef TME_BLACK_BOARD
//        (*i)->setDirtyBit();
//#endif

        double t = Statistic::getInstance().startMicroTime();

        QString name = QString("Response Time (%1) %2").arg(getObserverName((*i)->getType())).arg((*i)->getId());

        if(!(*i)->update(time))
        {
            detachList.push_back(*i);
        }

        if((time == -1) && (((*i)->getType() == TObsUDPSender) || ((*i)->getType() == TObsTCPSender)))
        {
            delay(0.750);
            (*i)->setModelTime(time);
            t -=750.0; // remove o tempo de delay
        }

        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime(name, t);
    }

    // Calcula o tempo entre o codigo sequencial e paralelo
    double tt = Statistic::getInstance().endMicroTime() - Statistic::getInstance().getIntermediateTime();
    Statistic::getInstance().addElapsedTime("Total Response Time Seq - cellspace", tt);

#else
    for(ObsListIterator i (observers.begin()); i != observers.end(); ++i)
    {
//#ifdef TME_BLACK_BOARD
//        (*i)->setDirtyBit();
//#endif

        if(!(*i)->update(time))
        {
            detachList.push_back(*i);
        }
    }
#endif

#ifdef TME_BLACK_BOARD
    BlackBoard::getInstance().startControl();
#endif
}

const TypesOfSubjects SubjectImpl::getSubjectType() const
{
    return TObsUnknown;
}

int SubjectImpl::getId() const 
{ 
    return subjectID;
}

void SubjectImpl::setId(int id)
{
    subjectID = id;
}

