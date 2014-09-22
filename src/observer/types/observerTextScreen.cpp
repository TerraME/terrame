#include "observerTextScreen.h"

#include <QtGui/QApplication>
#include <QtCore/QByteArray>

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
	#include "subjectAttributes.h"
#endif

ObserverTextScreen::ObserverTextScreen(Subject *subj, QWidget *parent)
    : QTextEdit(parent), ObserverInterf(subj) // , QThread()
{
    observerType = TObsTextScreen;
    subjectType = subj->getType(); // TO_DO: Changes it to Observer pattern

    // paused = false;
    header = false;

    setReadOnly(true);
    //setAutoFormatting(QTextEdit::AutoAll);
    setWindowTitle("TerraME Observer : Text Screen");

    show();
    resize(600, 480);

    // prioridade da thread
    //setPriority(QThread::IdlePriority); //  HighPriority    LowestPriority
    // start(QThread::IdlePriority);
}

ObserverTextScreen::~ObserverTextScreen()
{
    // wait();
}

const TypesOfObservers ObserverTextScreen::getType() const
{
    return observerType;
}

#ifdef TME_BLACK_BOARD

bool ObserverTextScreen::draw(QDataStream & /*state*/)
{
    draw();
    qApp->processEvents();

    bool ret = write();

    if (subjectType == TObsNeighborhood)
        attribList.clear();

    return ret;
}

#else // TME_BLACKBOARD

bool ObserverTextScreen::draw(QDataStream &state)
{
    QString msg;
    state >> msg;
    QStringList tokens = msg.split(PROTOCOL_SEPARATOR);

    //double num;
    //QString text;
    //bool b;

    //QString subjectId = tokens.at(0);
    //int subType = tokens.at(1).toInt();
    int qtdParametros = tokens.at(2).toInt();
    //int nroElems = tokens.at(3).toInt();
    int j = 4;

    for (int i=0; i < qtdParametros; i++)
    {
        QString key = tokens.at(j);
        j++;
        int typeOfData = tokens.at(j).toInt();
        j++;

        bool contains = attribList.contains(key);

        switch (typeOfData)
        {
            case (TObsBool)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key),
                                       (tokens.at(j).toInt() ? "true" : "false"));
                break;

            case (TObsDateTime)	:
                //break;

            case (TObsNumber)		:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;

            default							:
                if (contains)
                    valuesList.replace(attribList.indexOf(key), tokens.at(j));
                break;
        }
        j++;
    }

    qApp->processEvents();
    return write();
}

#endif // TME_PROTOCOL

void ObserverTextScreen::setAttributes(QStringList &attribs)
{
#ifdef TME_BLACK_BOARD
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());
#endif

    attribList = attribs;
    for (int i = 0; i < attribList.size(); i++)
        valuesList.insert(i, ""); // lista dos itens na ordem em que aparecem
    header = false;
}

bool ObserverTextScreen::headerDefined()
{
    return header;
}

bool ObserverTextScreen::write()
{
    // insere o cabeçalho do arquivo
    if (! header)
    {
        QString headers;
        for (int i = 0; i < attribList.size(); ++i)
        {
            headers += attribList.at(i);

            if (i < attribList.size() - 1)
                headers += "\t";
        }

        this->setText(headers);
        header = true;
    }

    QString text;
    for (int i = 0; i < valuesList.size(); i++)
    {
        text += valuesList.at(i) + "\t";

        if (i < valuesList.size() - 1)
            text += "\t";
    }

    this->append(text);
    return true;
}

//void ObserverTextScreen::run()
//{
//    //while (!paused)
//    //{
//    //    QThread::exec();
//    //    //show();
//    //    //printf("run() ");
//    //}
//    QThread::exec();
//}

//void ObserverTextScreen::pause()
//{
//    paused = !paused;
//}

QStringList ObserverTextScreen::getAttributes()
{
    return attribList;
}

int ObserverTextScreen::close()
{
    // QThread::exit(0);
    return 0;
}

bool ObserverTextScreen::draw()
{
    SubjectAttributes *subjAttr = BlackBoard::getInstance().getSubject(getSubjectId());
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
                    doubleToText(raw->number, tmpValue, 20);
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
