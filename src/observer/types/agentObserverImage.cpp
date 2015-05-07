#include "agentObserverImage.h"
#include "terrameGlobals.h"

#include <QBuffer>
#include <QStringList>
#include <QDebug>

extern ExecutionModes execModes;

#include "globalAgentSubjectInterf.h"
#include "decoder.h"
#include "observerMap.h"

#ifdef TME_BLACK_BOARD
	#include "blackBoard.h"
#endif

extern "C"
{
#include <lua.h>
}
#include "luna.h"

extern lua_State * L;
using namespace TerraMEObserver;

AgentObserverImage::AgentObserverImage(Subject * subj) : ObserverImage(subj)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverImage::~AgentObserverImage()
{
    unregistryAll();
}

bool AgentObserverImage::draw(QDataStream & state)
{
#ifdef TME_BLACK_BOARD
    // bool drw = false;
    // drw = ObserverImage::draw(state);

    for(int i = 0; i < nestedSubjects.size(); i++)
    {
        Subject *subj = nestedSubjects.at(i).first;
        // className = nestedSubjects.at(i).second;

        BlackBoard::getInstance().setDirtyBit(subj->getId());
        BlackBoard::getInstance().getState(subj, getId(), subjectAttributes);
        // decoded = BlackBoard::getInstance().canDraw();
	}

	// decoded = BlackBoard::getInstance().canDraw();
	//if (decoded)
    //    drw = drw && draw();

    // return drw && ObserverImage::save();
    return BlackBoard::getInstance().canDraw() && ObserverImage::draw(state);

#else

    bool drw = false, decoded = false;
    drw = ObserverImage::draw(state);
    cleanImage = true;
    className = "";

    for(int i = 0; i < nestedSubjects.size(); i++)
    {
        Subject *subj = nestedSubjects.at(i).first;
        // className = nestedSubjects.at(i).second;

        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        QDataStream out(&buffer);

        buffer.open(QIODevice::WriteOnly);
        //QStringList attribListAux;
        //attribListAux << subjectAttributes;

        QDataStream& state = subj->getState(out, subj, getId(), subjectAttributes);
        buffer.close();
        buffer.open(QIODevice::ReadOnly);

        //-----
        if ((subj->getType() == TObsAgent) || (subj->getType() == TObsAutomaton))
        {
            if (className != nestedSubjects.at(i).second)
                cleanImage = true;

            // if (className != attribListAux.first())
            //    cleanImage = true;

            // className = attribListAux.first();
            className = nestedSubjects.at(i).second;
        }
        //-----

        ///////////////////////////////////////////// Decode and Draw
        decoded = decode(state, subj->getType());
        cleanImage = false;
        /////////////////////////////////////////////

        buffer.close();
    }

    if (decoded)
        drw = drw && draw();

    return drw && ObserverImage::save();

#endif // TME_BLACK_BOARD

}

void AgentObserverImage::setSubjectAttributes(const QStringList & attribs,
    int nestedSubjID, const QString & className)
{
    QHash<QString, Attributes*> * mapAttributes = getMapAttributes();

    for (int i = 0; i < attribs.size(); i++)
    {
        if (!subjectAttributes.contains(attribs.at(i)))
            subjectAttributes.push_back(attribs.at(i));

        if (!mapAttributes->contains(attribs.at(i)))
         {
            if (execModes != Quiet)
            {
				string str = string("The attribute called ")
						+ attribs.at(i).toLatin1().data()
						+ string(" was not found.");
				lua_getglobal(L, "customWarning");
				lua_pushstring(L, str.c_str());
				lua_call(L, 1, 0);
            }
        }
        else
        {
            Attributes *attrib = mapAttributes->value(attribs.at(i));
            attrib->setClassName(className);
            attrib->setParentSubjectID(nestedSubjID);

            if ((attrib->getType() == TObsAgent) || (attrib->getType() == TObsSociety))
                getPainterWidget()->setExistAgent(true);
        }
    }
    setDisableSaveImage();
}

QStringList & AgentObserverImage::getSubjectAttributes()
{
    return subjectAttributes;
}

void AgentObserverImage::registry(Subject *subj, const QString & className)
{
    if (!ObserverMap::constainsItem(nestedSubjects, subj))
    {
#ifdef TME_BLACK_BOARD
    	SubjectAttributes *subjAttr = BlackBoard::getInstance().insertSubject(subj->getId());
    	if (subjAttr)
        	subjAttr->setSubjectType(subj->getType());
#endif

        nestedSubjects.append(qMakePair(subj, className));

        // sorts the subject linked vector by the class name
        qStableSort(nestedSubjects.begin(), nestedSubjects.end(), sortByClassName);
    }
}

bool AgentObserverImage::unregistry(Subject *subj, const QString & className)
{
    if (!ObserverMap::constainsItem(nestedSubjects, subj))
        return false;

    int idxItem = -1;
    for (int i = 0; i < nestedSubjects.size(); i++)
    {
        if (nestedSubjects.at(i).first == subj)
        {
            idxItem = i;
            break;
        }
    }
    nestedSubjects.remove(idxItem);

    for (int i = 0; i < subjectAttributes.size(); i++)
    {
        Attributes *attrib = getMapAttributes()->value(subjectAttributes.at(i), 0);

        if (attrib && (className == attrib->getClassName()))
        {
            getMapAttributes()->remove(subjectAttributes.at(i));

            // Updates de copies of attributes lists
            getPainterWidget()->updateAttributeList();
            attrib->clear();

            // Deletes the Attribute
            delete attrib; attrib = 0;
            break;
        }

        //// Remove only the attribute that has no values
        //if (subj->getSubjectType() == attrib->getType())
        //{
        //        if ((attrib->getType() != TObsAgent)
        //            || ((className == attrib->getExhibitionName())
        //                 && (!ObserverMap::existAgents(nestedSubjects))))
        //    {
        //        getMapAttributes()->take(attrib->getName());
        //        getPainterWidget()->setExistAgent(false);
        //        subjectAttributes.removeAt(subjectAttributes.indexOf(attrib->getName()));
        //        delete attrib;
        //        return true;
        //    }
        //}
    }
    if (nestedSubjects.isEmpty())
        getPainterWidget()->setExistAgent(false);

    return true;
}

void AgentObserverImage::unregistryAll()
{
    nestedSubjects.clear();
}

bool AgentObserverImage::decode(QDataStream &in, TypesOfSubjects subject)
{
    bool decoded = false;
    QString msg;
    in >> msg;

    // qDebug() << msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    Attributes * attrib = 0;

    if (subject == TObsTrajectory)
        attrib = getMapAttributes()->value("trajectory");
    else
    {
        // // ((subjectType == TObsAgent) || (subjectType == TObsAutomaton))
        // attrib = getMapAttributes()->value("currentState" + className);

        foreach (Attributes *attr, getMapAttributes()->values())
        {
            if (attr->getClassName() == className)
            {
                attrib = attr;
                break;
            }
        }
    }

    if (attrib)
    {
        if (cleanImage)
            attrib->clear();

        // decoded = getProtocolDecoder().decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
        // getPainterWidget()->plotMap(attrib);
    }
    qApp->processEvents();

    return decoded;
}

bool AgentObserverImage::draw()
{
    //QList<Attributes *> attribList = getMapAttributes()->values();
    //Attributes *attrib = 0;

    //qStableSort(attribList.begin(), attribList.end(), sortAttribByType);

    //for(int i = 0; i < attribList.size(); i++)
    //{
    //    attrib = attribList.at(i);
    //    if ((attrib->getType() != TObsCell)
    //      ) // && (attrib->getType() != TObsAgent))
    //        getPainterWidget()->plotMap(attrib);
    //}
    return true;
}
