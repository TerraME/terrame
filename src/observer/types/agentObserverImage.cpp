#include "agentObserverImage.h"

#include <QBuffer>
#include <QStringList>
#include <QDebug>
#include "terrameGlobals.h"

extern ExecutionModes execModes;

#include "../globalAgentSubjectInterf.h"
#include "../protocol/decoder/decoder.h"
#include "observerMap.h"

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
    bool drw = false, decoded = false;
    drw = ObserverImage::draw(state);
    cleanImage = true;
    className = "";

    for(int i = 0; i < linkedSubjects.size(); i++)
    {
        Subject *subj = linkedSubjects.at(i).first;
        // className = linkedSubjects.at(i).second;

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
            if (className != linkedSubjects.at(i).second)
                cleanImage = true;
            
            // if (className != attribListAux.first())
            //    cleanImage = true;

            // className = attribListAux.first();
            className = linkedSubjects.at(i).second;
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
}

void AgentObserverImage::setSubjectAttributes(const QStringList & attribs, TypesOfSubjects type,
                                            const QString & className)
{
    QHash<QString, Attributes*> * mapAttributes = getMapAttributes();

    for (int i = 0; i < attribs.size(); i++)
    {
        if (! subjectAttributes.contains(attribs.at(i)) )
            subjectAttributes.push_back(attribs.at(i));

        if (! mapAttributes->contains(attribs.at(i)))
         {
            if (execModes != Quiet )
            {
                qWarning("Warning: The attribute called \"%s\" not found.", 
                    qPrintable(attribs.at(i)));
            }
        }
        else
        {
            Attributes *attrib = mapAttributes->value(attribs.at(i));
            attrib->setType(type);
            attrib->setClassName(className);
        }
    }
    setDisableSaveImage();

    if (type == TObsAgent)
        getPainterWidget()->setExistAgent(true);
}

QStringList & AgentObserverImage::getSubjectAttributes()
{
    return subjectAttributes;
}

void AgentObserverImage::registry(Subject *subj, const QString & className)
{
    if (! ObserverMap::constainsItem(linkedSubjects, subj) )
    {
        linkedSubjects.push_back(qMakePair(subj, className));

        // sorts the subject linked vector by the class name
        qStableSort(linkedSubjects.begin(), linkedSubjects.end(), sortByClassName);
    }
}

bool AgentObserverImage::unregistry(Subject *subj, const QString & className)
{
    if (! ObserverMap::constainsItem(linkedSubjects, subj))
        return false;

    int idxItem = -1;
    for (int i = 0; i < linkedSubjects.size(); i++)
    {
        if (linkedSubjects.at(i).first == subj)
        {
            idxItem = i;
            break;
        }
    }
    linkedSubjects.remove(idxItem);

    for (int i = 0; i < subjectAttributes.size(); i++)
    {
        Attributes *attrib = getMapAttributes()->value(subjectAttributes.at(i));

        if (className == attrib->getClassName())
        {
            attrib->clear();
            break;
        }

        //// Remove apenas o atributo que não possui valores
        //if (subj->getSubjectType() == attrib->getType())
        //{
        //        if ( (attrib->getType() != TObsAgent) 
        //            || ((className == attrib->getExhibitionName()) 
        //                 && (! ObserverMap::existAgents(linkedSubjects)) ) )
        //    {
        //        getMapAttributes()->take(attrib->getName());
        //        getPainterWidget()->setExistAgent(false);
        //        subjectAttributes.removeAt( subjectAttributes.indexOf(attrib->getName()) );
        //        delete attrib;
        //        return true;
        //    }
        //}
    }
    if (linkedSubjects.isEmpty())
        getPainterWidget()->setExistAgent(false);

    return true;
}

void AgentObserverImage::unregistryAll()
{
    linkedSubjects.clear();
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

        decoded = getProtocolDecoder().decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
        // getPainterWidget()->plotMap(attrib);
    }
    qApp->processEvents();

    return decoded;
}

bool AgentObserverImage::draw()
{
    QList<Attributes *> attribList = getMapAttributes()->values();
    Attributes *attrib = 0;

    qStableSort(attribList.begin(), attribList.end(), sortAttribByType);

    for(int i = 0; i < attribList.size(); i++)
    {
        attrib = attribList.at(i);
        if ( (attrib->getType() != TObsCell)
             ) // && (attrib->getType() != TObsAgent) )
            getPainterWidget()->plotMap(attrib);
    }
    return true;
}
