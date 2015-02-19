#include "agentObserverMap.h"

#ifndef TME_OBSERVER_CLIENT_MODE
	#include "globalAgentSubjectInterf.h"
#endif

#include "decoder.h"

#include <QBuffer>
#include <QStringList>
#include <QTreeWidget>
#include <QDebug>
#include "terrameGlobals.h"
#include "blackBoard.h"

#define TME_STATISTIC_UNDEF

#ifdef TME_STATISTIC
    // Estatisticas de desempenho
    #include "statistic.h"
#endif

extern "C"
{
#include <lua.h>
}
#include "luna.h"

extern lua_State * L;
extern ExecutionModes execModes;

using namespace TerraMEObserver;

AgentObserverMap::AgentObserverMap(Subject * subj, QWidget *parent) 
    : ObserverMap(subj, parent)
{
    subjectAttributes.clear();
    cleanImage = false;
}

AgentObserverMap::~AgentObserverMap()
{
    unregistryAll();
}


#ifdef TME_BLACK_BOARD

bool AgentObserverMap::draw(QDataStream & state)
{
    bool drw = true, decoded = false;
    //cleanImage = true;
    // className = "";

#ifdef DEBUG_OBSERVER
    qDebug() << "\nAgentObserverMap::draw()";
    qDebug() << "nestedSubjects.size():" << nestedSubjects.size() << "\n" << nestedSubjects;
    qDebug() << "subjectAttributes:" << subjectAttributes << "\n";
#endif

    for(int i = 0; i < nestedSubjects.size(); i++)
    {
        Subject *subj = nestedSubjects.at(i).first;
        // className = nestedSubjects.at(i).second;

        BlackBoard::getInstance().setDirtyBit(subj->getId());
        BlackBoard::getInstance().getState(subj, getId(), subjectAttributes);

#ifdef DEBUG_OBSERVER
        qDebug() << "AgentObserverMap::draw()\n" << "subj->getId()" << subj->getId();

        SubjectAttributes *subjAttr = BlackBoard::getInstance().getSubject(subj->getId());
        if (subjAttr)
        {
            qDebug() << subjAttr->toString()
                << (subjAttr->hasNestedSubjects() ?
                    subjAttr->getNestedSubjects().size() : -1)
               << subjAttr->getNestedSubjects();
        }
#endif

    }
	
	decoded = BlackBoard::getInstance().canDraw();

    return decoded && ObserverMap::draw(state);
}


#else // TME_BLACK_BOARD

bool AgentObserverMap::draw(QDataStream & state)
{
#ifdef TME_STATISTIC
    //// tempo gasto do 'getState' ate aqui
    //double decodeSum = 0.0, t = Statistic::getInstance().endVolatileTime();
    //Statistic::getInstance().addElapsedTime("comunicação map", t);

    int decodeCount = 0;

    // numero de bytes transmitidos
    Statistic::getInstance().addOccurrence("bytes map", in.device()->size());
#endif

    // bool drw = ObserverMap::draw(in);
    bool drw = true, decoded = false;
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
        //// attribListAux.push_back("@getLuaAgentState");
        //attribListAux << subjectAttributes;        

#ifndef TME_BLACK_BOARD
		if(subj->getType() == TObsCell)
			subjectAttributes.push_back("@getNeighborhoodState");
#endif
		
//#ifdef TME_BLACK_BOARD
//        QDataStream& state = BlackBoard::getInstance().getState(subj, getId(), subjectAttributes);
//        BlackBoard::getInstance().setDirtyBit(subj->getId() );
//#else
        QDataStream& state = subj->getState(out, subj, getId(), subjectAttributes);
//#endif

        buffer.close();
        buffer.open(QIODevice::ReadOnly);

        //-----
		// @RAIAN: Acrescentei a celula na comparacao, para o observer do tipo Neighborhood
        if ((subj->getType() == TObsAgent) || (subj->getType() == TObsAutomaton) 
            || (subj->getType() == TObsCell))
        {
            if (className != nestedSubjects.at(i).second)
                cleanImage = true;
            
            // if (className != attribListAux.first())
            //    cleanImage = true;

            // className = attribListAux.first();
            className = nestedSubjects.at(i).second;
        }
        //-----

#ifdef TME_STATISTIC 
        t = Statistic::getInstance().startTime();
#endif
        ///////////////////////////////////////////// DRAW AGENT
        decoded = decode(state, subj->getType());

#ifdef TME_STATISTIC 
        decodeSum += Statistic::getInstance().endTime() - t;
        decodeCount++;
#endif

        cleanImage = false;
        /////////////////////////////////////////////

        buffer.close();
    }
    //bool drw = true;


#ifdef TME_STATISTIC

    if (decoded)
    {
        t = Statistic::getInstance().startMicroTime();

        drw = draw();

        t = Statistic::getInstance().endMicroTime() - t;
        Statistic::getInstance().addElapsedTime("Map-Complex Rendering", t);

    	if (decodeCount > 0)
        	Statistic::getInstance().addElapsedTime("Map-Complex Decoder", decodeSum / decodeCount);
    }
    return drw && ObserverMap::draw(state);
    
#else
    if (decoded)
        drw = draw();

    return drw && ObserverMap::draw(state);

#endif
}
#endif // TME_BLACK_BOARD


void AgentObserverMap::setSubjectAttributes(const QStringList & attribs, 
    int nestedSubjID, const QString & className)
{
#ifdef DEBUG_OBSERVER
    qDebug() << "AgentObserverMap::setSubjectAttributes() " << attribs;
#endif

    QHash<QString, Attributes*> * mapAttributes = getMapAttributes();
    // TypesOfSubjects type;

    for (int i = 0; i < attribs.size(); i++)
    {
        if (! subjectAttributes.contains(attribs.at(i)) )
            subjectAttributes.push_back(attribs.at(i));
 
        if (! mapAttributes->contains(attribs.at(i)))
        {
            if (execModes != Quiet)
            {
				string str = string("The attribute called ") + attribs.at(i).toLatin1().data() + string(" was not found.");
				lua_getglobal(L, "customWarning");
				lua_pushstring(L,str.c_str());
				lua_call(L,1,0);
            }
        }
        else
        {
            Attributes *attrib = mapAttributes->value(attribs.at(i));
            attrib->setClassName(className);
            attrib->setParentSubjectID(nestedSubjID);

            if ((attrib->getType() == TObsAgent) || (attrib->getType() == TObsSociety))
        		getPainterWidget()->setExistAgent(true);

            // qDebug() << "AgentObserverMap::setSubjectAttributes()" << attribs.at(i)
            //     << "getSubjectId()" << getSubjectId() << "nestedSubjID" << nestedSubjID;
		}
    }
}

QStringList & AgentObserverMap::getSubjectAttributes()
{
    return subjectAttributes;
}

void AgentObserverMap::registry(Subject *subj, const QString & className)
{
    if (! constainsItem(nestedSubjects, subj) )
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

bool AgentObserverMap::unregistry(Subject *subj, const QString & className)
{
    if (! constainsItem(nestedSubjects, subj))
        return false;

#ifdef DEGUB_OBSERVER
    qDebug() << "\nsubjectAttributes " << subjectAttributes;
    qDebug() << "nestedSubjects " << nestedSubjects << "\n";
#endif

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

    // QTreeWidget * treeLayers = getTreeLayers();

    for (int i = 0; i < subjectAttributes.size(); i++)
    {
        Attributes *attrib = getMapAttributes()->value(subjectAttributes.at(i), 0);
            
        if (attrib && (className == attrib->getClassName()) )
        {
            getMapAttributes()->remove( subjectAttributes.at(i) );
            
            // Updates de copies of attributes lists
            getPainterWidget()->updateAttributeList();
            attrib->clear();            

            // Deletes the Attribute
            delete attrib; attrib = 0;
            break;
        }
            /*
             // Remove apenas o atributo que não possui valores
             if (subj->getSubjectType() == attrib->getType())
             {
             qDebug() << "\nclassName " << className;
             qDebug() << "attrib->getExhibitionName() " << attrib->getExhibitionName();
             
             if ( (attrib->getType() != TObsAgent)
             || ((className == attrib->getExhibitionName()) &&
        	 (! ObserverMap::existAgents(nestedSubjects)) ) )
             {
             //for (int j = 0; j < treeLayers->topLevelItemCount(); j++)
             //{
             //    // Remove o atributo da árvore de layers
             //    if ( treeLayers->topLevelItem(j)->text(0) == attrib->getName())
             //    {
             //        QTreeWidgetItem *treeItem = treeLayers->takeTopLevelItem(j);
             //        delete treeItem;
             //        break;
             //    }
             //}
             
             // Remove o atributo do mapa de atributos
             getMapAttributes()->take(attrib->getName());
             getPainterWidget()->setExistAgent(false);
             subjectAttributes.removeAt( subjectAttributes.indexOf(attrib->getName()) );
             delete attrib;
             return true;
             }
             }*/
    }

    if (nestedSubjects.isEmpty())
        getPainterWidget()->setExistAgent(false);

    return true;
}

void AgentObserverMap::unregistryAll()
{
    nestedSubjects.clear();
}

bool AgentObserverMap::decode(QDataStream &in, TypesOfSubjects subject)
{
    qDebug() << "AgentObserverMap::decode() deprecated";

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
		if(subject == TObsCell)
		{
			attrib = getMapAttributes()->value(className);
		}
		//@RAIAN: FIM
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
    }
    if (attrib)
    {
        if (cleanImage)
            attrib->clear();

        //ret = getProtocolDecoder().decode(msg, *attrib->getXsValue(), *attrib->getYsValue());
        // getPainterWidget()->plotMap(attrib);
    }
    qApp->processEvents();
    return ret;
}

bool AgentObserverMap::draw()
{
    //QList<Attributes *> attribList = getMapAttributes()->values();
    //Attributes *attrib = 0;

    //qStableSort(attribList.begin(), attribList.end(), sortAttribByType);

    //for(int i = 0; i < attribList.size(); i++)
    //{
    //    attrib = attribList.at(i);

    //    if ( (attrib->getType() != TObsCell)
    //          && (attrib->getType() != TObsAgent) )
    //        getPainterWidget()->draw();
    //}

    //static int ss = 1;
    //for(int i = 0; i < attribList.size(); i++)
    //{
    //    //attrib = attribList.at(i);
    //    //if ( (attrib->getType() != TObsCell)
    //    //       && (attrib->getType() != TObsAgent) )
    //    //       attrib->getImage()->save("imgs/" + attrib->getName() + QString::number(ss) + ".png");

    //    qDebug() << attrib->getName() << ": " << getSubjectName(attrib->getType());
    //}

    //ss++;
    return true;
}
