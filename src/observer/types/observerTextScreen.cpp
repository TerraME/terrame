#include "observerTextScreen.h"

#include <QApplication>
#include <QByteArray>

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

    // thread
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

bool ObserverTextScreen::draw(QDataStream & /*state*/)
{
    draw();
    qApp->processEvents();

    bool ret = write();

    if (subjectType == TObsNeighborhood)
        attribList.clear();

    return ret;
}

void ObserverTextScreen::setAttributes(QStringList &attribs)
{
    SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(getSubjectId());
    if (subjAttr) 
        subjAttr->setSubjectType(getSubjectType());

    attribList = attribs;
    for (int i = 0; i < attribList.size(); i++)
        valuesList.insert(i, ""); // list of items in the order they appear
    header = false;
}

bool ObserverTextScreen::headerDefined()
{
    return header;
}

bool ObserverTextScreen::write()
{
    // Write the header in the file
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
                nestedSubj = bb.getSubject(subjectsIDs.at(id));

                if (nestedSubj && nestedSubj->getNumericValue("weight", weight))
                {
                    doubleToText(nestedSubj->getId(), tmpValue);
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
