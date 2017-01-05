/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

#include "agentObserverMap.h"

#include "../globalAgentSubjectInterf.h"
#include "../protocol/decoder/decoder.h"

#include <QBuffer>
#include <QStringList>
#include <QTreeWidget>
#include <QDebug>
#include "terrameGlobals.h"

#ifdef TME_BLACK_BOARD
    #include "blackBoard.h"
#endif

extern ExecutionModes execModes;

using namespace TerraMEObserver;

AgentObserverMap::AgentObserverMap(QWidget *parent) : ObserverMap(parent)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverMap::AgentObserverMap(Subject * subj) : ObserverMap(subj)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverMap::~AgentObserverMap()
{
    unregistryAll();
}

bool AgentObserverMap::draw(QDataStream & state)
{
    // bool drw = ObserverMap::draw(in);
    bool drw = true, decoded = false;
    cleanImage = true;
    className = "";

    for (int i = 0; i < linkedSubjects.size(); i++)
    {
        Subject *subj = linkedSubjects.at(i).first;
        // className = linkedSubjects.at(i).second;

        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        QDataStream out(&buffer);

        buffer.open(QIODevice::WriteOnly);

        //QStringList attribListAux;
        //// attribListAux.push_back("@getLuaAgentState");
        //attribListAux << subjectAttributes;

		//@RAIAN: Solucao provisoria
#ifndef TME_BLACK_BOARD
		if (subj->getType() == TObsCell)
			subjectAttributes.push_back("@getNeighborhoodState");
#endif
		//@RAIAN: FIM

//#ifdef TME_BLACK_BOARD
//        QDataStream& state = BlackBoard::getInstance().getState(subj, getId(), subjectAttributes);
//        BlackBoard::getInstance().setDirtyBit(subj->getId());
//#else
        QDataStream& state = subj->getState(out, subj, getId(), subjectAttributes);
//#endif

        buffer.close();
        buffer.open(QIODevice::ReadOnly);

        //-----
		// @RAIAN: Acrescentei a celula na comparacao, para o observer do tipo Neighborhood
        if ((subj->getType() == TObsAgent) ||(subj->getType() == TObsAutomaton) ||(subj->getType() == TObsCell))
        {
            if (className != linkedSubjects.at(i).second)
                cleanImage = true;

            // if (className != attribListAux.first())
            //    cleanImage = true;

            // className = attribListAux.first();
            className = linkedSubjects.at(i).second;
        }
        //-----

        ///////////////////////////////////////////// DRAW AGENT
        decoded = decode(state, subj->getType());

        cleanImage = false;
        /////////////////////////////////////////////

        buffer.close();
    }
    //bool drw = true;

    if (decoded)
        drw = draw();

    return drw && ObserverMap::draw(state);
}

void AgentObserverMap::setSubjectAttributes(const QStringList & attribs, TypesOfSubjects type,
                                          const QString & className)
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

    if (type == TObsAgent)
        getPainterWidget()->setExistAgent(true);
}

QStringList & AgentObserverMap::getSubjectAttributes()
{
    return subjectAttributes;
}

void AgentObserverMap::registry(Subject *subj, const QString & className)
{
    if (!constainsItem(linkedSubjects, subj))
    {
//#ifdef TME_BLACK_BOARD
//        BlackBoard::getInstance().setDirtyBit(subj->getId());
//#endif

        linkedSubjects.push_back(qMakePair(subj, className));

        // sorts the subject linked vector by the class name
        qStableSort(linkedSubjects.begin(), linkedSubjects.end(), sortByClassName);
    }
}

bool AgentObserverMap::unregistry(Subject *subj, const QString & className)
{
    if (!constainsItem(linkedSubjects, subj))
        return false;

#ifdef DEGUB_OBSERVER
    // qDebug() << "subjectAttributes " << subjectAttributes;
    // qDebug() << "linkedSubjects " << linkedSubjects;

    foreach(SubjectInterf *s, subjects)
        qDebug() << s->getSubjectType() << ", " << getSubjectName(s->getSubjectType());
#endif

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

    QTreeWidget * treeLayers = getTreeLayers();

    for (int i = 0; i < subjectAttributes.size(); i++)
    {
        if (getMapAttributes()->contains(subjectAttributes.at(i)))
        {
            Attributes *attrib = getMapAttributes()->value(subjectAttributes.at(i));

            if (className == attrib->getClassName())
            {
            // @RAIAN: Comentei esta parte para execut?-la no fim, ap?s remover a legenda.
//                attrib->clear();
//                break;
//            }
            // @RAIAN: FIM

            /*
             // Remove apenas o atributo que n?o possui valores
             if (subj->getSubjectType() == attrib->getType())
             {
             qDebug() << "\nclassName " << className;
             qDebug() << "attrib->getExhibitionName() " << attrib->getExhibitionName();
             
             if ((attrib->getType() != TObsAgent)
             ||((className == attrib->getExhibitionName()) &&
            (! ObserverMap::existAgents(linkedSubjects))))
             {
             //for (int j = 0; j < treeLayers->topLevelItemCount(); j++)
             //{
             //    // Remove o atributo da ?rvore de layers
             //    if (treeLayers->topLevelItem(j)->text(0) == attrib->getName())
             //    {
             //        QTreeWidgetItem *treeItem = treeLayers->takeTopLevelItem(j);
             //        delete treeItem;
             //        break;
             //    }
             //}
             
             // Remove o atributo do mapa de atributos
             getMapAttributes()->take(attrib->getName());
             getPainterWidget()->setExistAgent(false);
             subjectAttributes.removeAt(subjectAttributes.indexOf(attrib->getName()));
             delete attrib;
             return true;
             }
             }*/

                //@RAIAN
                // Alterei o codigo acima, do toninho, que havia sido comentado para remover a legenda caso
                // nao haja mais agentes/vizinhancas sendo observados.
                if (((attrib->getType() == TObsAgent) ||(attrib->getType() == TObsNeighborhood))
                    && (linkedSubjects.isEmpty()))
                {
                    for (int j = 0; j < treeLayers->topLevelItemCount(); j++)
                    {
                        // Remove o atributo da arvore de layers
                        if (treeLayers->topLevelItem(j)->text(0) == attrib->getName())
                        {
                            QTreeWidgetItem *treeItem = treeLayers->takeTopLevelItem(j);
                            delete treeItem;
                            break;
                        }
                    }
                }
                attrib->clear();
                break;
            }
            //@RAIAN: FIM
        }
    }

    if (linkedSubjects.isEmpty())
        getPainterWidget()->setExistAgent(false);

    return true;
}

void AgentObserverMap::unregistryAll()
{
    linkedSubjects.clear();
}

bool AgentObserverMap::decode(QDataStream &in, TypesOfSubjects subject)
{
    bool ret = false;
    QString msg;
    in >> msg;

    // qDebug() << msg.split(PROTOCOL_SEPARATOR, QString::SkipEmptyParts);

    Attributes * attrib = 0;

    if (subject == TObsTrajectory)
    {
        attrib = getMapAttributes()->value("trajectory");
    }
    else
    {
		//@RAIAN: Neighborhood
		if (subject == TObsCell)
		{
			attrib = getMapAttributes()->value(className);
		}
		//@RAIAN: FIM
		else
		{
            // //((subjectType == TObsAgent) ||(subjectType == TObsAutomaton))
            // attrib = getMapAttributes()->value("currentState" + className);

            foreach(Attributes *attr, getMapAttributes()->values())
            {
                if (attr->getClassName() == className)
                {
                    attrib = attr;
                    break;
                }
            }
        }
    }

    if (attrib)
    {
        if (cleanImage)
            attrib->clear();

        ret = getProtocolDecoder().decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
        // getPainterWidget()->plotMap(attrib);
    }
    qApp->processEvents();
    return ret;
}

bool AgentObserverMap::draw()
{
    QList<Attributes *> attribList = getMapAttributes()->values();
    Attributes *attrib = 0;

    qStableSort(attribList.begin(), attribList.end(), sortAttribByType);

    for (int i = 0; i < attribList.size(); i++)
    {
        attrib = attribList.at(i);
        if ((attrib->getType() != TObsCell)
              && (attrib->getType() != TObsAgent))
            getPainterWidget()->plotMap(attrib);
    }

    //static int ss = 1;
    //for (int i = 0; i < attribList.size(); i++)
    //{
    //    //attrib = attribList.at(i);
    //    //if ((attrib->getType() != TObsCell)
    //    //       && (attrib->getType() != TObsAgent))
    //    //       attrib->getImage()->save("imgs/" + attrib->getName() + QString::number(ss) + ".png");

    //    qDebug() << attrib->getName() << ": " << getSubjectName(attrib->getType());
    //}

    //ss++;
    return true;
}



