#include "visualMapping.h"

#include <QPainter>
#include <QImage>
#include <QDebug>
#include <time.h>

#include "legendAttributes.h"
#include "calculateResult.h"
#include "taskManager.h"

#ifdef TME_BLACK_BOARD
#include "blackBoard.h"
#include "subjectAttributes.h"
#include "luaUtils.h"
#endif

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

#include "terrameGlobals.h"

extern lua_State * L;
extern ExecutionModes execModes;

using namespace TerraMEObserver;
using namespace BagOfTasks;

VisualMapping::VisualMapping(TypesOfObservers observerType, QObject *parent)
    : observerType(observerType), QObject(parent), Task(Task::Hight)
{
    setType(Task::Arbitrary);

    countSave = 0;
    reconfigMaxMin = false;
    executing = false;
    gridEnabled =  false; // true; // false;
    spaceSize = QSize(); // IMAGE_SIZE;

    agentAttribPositions = new QVector<int>();

    //posicionar randomicamente os agentes na célula
    // para que seja possível visualizar mais agentes
    // dentro da mesma célular
    //qsrand(time(NULL));
    qsrand(1);
}

VisualMapping::~VisualMapping()
{
    delete agentAttribPositions; agentAttribPositions = 0;
}

bool VisualMapping::execute()
{
    if (executing)
        return false;
    executing = true;
    
#ifdef TME_STATISTIC
    waitTime = Statistic::getInstance().endMicroTime() - waitTime;
    double t = Statistic::getInstance().startMicroTime();

    QString name = QString("zz__wait_task VisualMapping %1").arg(getId());
    Statistic::getInstance().addElapsedTime(name, waitTime);

    // double t3 = 0, tt = 0;    
#endif


#ifdef DEBUG_OBSERVER
    qDebug() << "VisualMapping::execute()"; 
    for (int i = 0 ; i < attribList.size(); ++i)
    {
        Attributes *attrib = attribList.at(i);
        qDebug() << "\n   type: " << getSubjectName( attrib->getType() ) 
            << "::: " << attribList.size();
    }
    std::cout.flush();
#endif

    agentAttribPositions->clear();

#ifdef TME_DRAW_VECTORIAL_AGENTS
    bool isAgentOrSociety = false;
#endif

    for (int i = 0 ; i < attribList.size(); ++i)
    {
        Attributes *attrib = attribList.at(i);

        switch (attrib->getType())
        {
        case TObsAgent:
                agentAttribPositions->append(i);
#ifdef TME_DRAW_VECTORIAL_AGENTS

                isAgentOrSociety = true;
                break;

        case TObsSociety:
            isAgentOrSociety = true;
#endif // TME_DRAW_VECTORIAL_AGENTS

            break;

        default:
            QPainter p;
            drawAttrib(&p, attrib);
            break;
        }
    }

    bool isMap = (observerType == TObsMap);

    if (attribList.size() == 1)
    {
        if (isMap)
            emit displayImage(*attribList.first()->getImage());
        else
            save(*attribList.first()->getImage());
    }
    else if (attribList.size() > 1)
    {        
        CalculateResult calculateResult(spaceSize, attribList);

#ifdef TME_DRAW_VECTORIAL_AGENTS
            if (isMap || isAgentOrSociety)
            {
                connect(&calculateResult, SIGNAL(displayImage(QImage)), 
                    this, SIGNAL(displayImage(QImage)) 
                    // ); 
                    , Qt::DirectConnection);
                    // , Qt::QueuedConnection); 
                    // , BlockingQueuedConnection );
            }
            else
            {
                connect(&calculateResult, SIGNAL(displayImage(QImage)), 
                    this, SLOT(save(QImage)) 
                    // ); 
                     , Qt::DirectConnection);
                    // , Qt::QueuedConnection); 
                    //, Qt::BlockingQueuedConnection );
            }
#else

        if (agentAttribPositions && agentAttribPositions->isEmpty())
        {
            if (isMap)
            {
                connect(&calculateResult, SIGNAL(displayImage(QImage)), 
                    this, SIGNAL(displayImage(QImage)) 
                    // ); 
                    , Qt::DirectConnection);
                    // , Qt::QueuedConnection); 
                    // , BlockingQueuedConnection );
            }
            else
            {
                connect(&calculateResult, SIGNAL(displayImage(QImage)), 
                    this, SLOT(save(QImage)) 
                    // ); 
                     , Qt::DirectConnection);
                    // , Qt::QueuedConnection); 
                    //, Qt::BlockingQueuedConnection );
            }
        }
        else // ! agentAttribPositions->isEmpty()
        {
            connect(&calculateResult, SIGNAL(displayImage(QImage)), 
                this, SLOT(drawAgent(QImage)) 
                // ); 
                , Qt::DirectConnection); 
                // , Qt::QueuedConnection); 
                //, Qt::BlockingQueuedConnection );
        } 

#endif // TME_DRAW_VECTORIAL_AGENTS

        calculateResult.execute();
        // BagOfTasks::TaskManager::getInstance().add(&calculateResult);
    }   

    executing = false;

#ifdef TME_STATISTIC
    // name = QString("map Rendering %1").arg(block);
    name = QString("map VisualMapping task %1").arg(getId());
    t = Statistic::getInstance().startMicroTime() - t;
    Statistic::getInstance().addElapsedTime(name, t);
#endif

    return true;
}

void VisualMapping::setSize(const QSize & spaceSize, const QSize &cellSize)
{
    this->spaceSize = spaceSize;
    this->cellSize = cellSize;
}

void VisualMapping::setAttributeList(const QList<Attributes *> &attribs)
{
    attribList = attribs;
    qStableSort(attribList.begin(), attribList.end(), sortAttribByType);
}

void VisualMapping::drawAttrib(QPainter *p, Attributes *attrib)
{
#ifdef TME_STATISTIC
    double t = 0;
    QString name;

    p->begin(attrib->getImage());
    p->setPen(Qt::NoPen);

	switch (attrib->getType())
    {
		case TObsNeighborhood:
		{
			mappingNeighborhood(attrib, p);
			break;
		}
		case TObsSociety:
		{
            mappingSociety(attrib , p);
			break;
		}
		
		default:
		{
			if (attrib->getDataType() == TObsNumber)
			{
				if (BlackBoard::getInstance().renderingOnlyChanges())
				{
					t = Statistic::getInstance().startMicroTime();

					mappingChanges(attrib, p);

					name = QString("z_mappingChanges %1").arg(getId());
					t = Statistic::getInstance().endMicroTime() - t;
					Statistic::getInstance().addElapsedTime(name, t);
				}
				else
				{
					t = Statistic::getInstance().startMicroTime();

					mappingAll(attrib, p);

					name = QString("z_mappingAll %1").arg(getId());
					t = Statistic::getInstance().endMicroTime() - t;
					Statistic::getInstance().addElapsedTime(name, t);
				}
			} // if TObsNumber        
			else if (attrib->getDataType() == TObsText)
			{
				if (BlackBoard::getInstance().renderingOnlyChanges())
					mappingChangesText(attrib, p);
				else
					mappingAllText(attrib, p);
			}
			break;
		}
	}
	p->end();

#else
    
	p->begin(attrib->getImage());
    p->setPen(Qt::NoPen); //defaultPen
	
	switch (attrib->getType())
    {
		case TObsNeighborhood:
		{
			mappingNeighborhood(attrib, p);
			break;
		}
		case TObsSociety:
		{
            mappingSociety(attrib , p);
			break;
		}
		
		default:
		{
			if (attrib->getDataType() == TObsNumber)
			{
				if (BlackBoard::getInstance().renderingOnlyChanges())
					mappingChanges(attrib, p);
				else
					mappingAll(attrib, p);
			}
			else if (attrib->getDataType() == TObsText)
			{
				if (BlackBoard::getInstance().renderingOnlyChanges())
					mappingChangesText(attrib, p);
				else
					mappingAllText(attrib, p);
			}
			break;
		}
	}
    p->end();

#endif

}

void VisualMapping::rendering(QPainter *p, const TypesOfSubjects &type, 
    const double &x, const double &y)
{
    switch (type)
    {
    case TObsAgent:
        qDebug() << "Incorrect call to rendering Agent";
        break;

    // case TObsAutomaton:
        // p->drawRect(cellSize.width() * x, cellSize.height() * y, cellSize.width(), cellSize.height());
        // break;

    default:
        if (gridEnabled)
            p->drawRect(cellSize.width() * x, cellSize.height() * y, cellSize.width() - 1, cellSize.height() - 1);
        else
            p->drawRect(cellSize.width() * x, cellSize.height() * y, cellSize.width(), cellSize.height());
        break;
    }
}

void VisualMapping::renderingNeighbor(QPainter *p, const double &xCell, const double &yCell, 
    const double &xNeigh, const double &yNeigh)
{
    p->drawLine(xCell, yCell, (cellSize.width() * xNeigh) + cellSize.width() * 0.5,
        (cellSize.height() * yNeigh) + cellSize.height() * 0.5);

    // TODO: Desenhar a cabeca da seta
}


void VisualMapping::mappingChanges(Attributes *attrib, QPainter *p)
{
    //if (attrib->getType() == TObsTrajectory)
    //    attrib->getImage()->fill(0);

    double v = 0.0;

    QColor color(Qt::white);
    p->setBrush(color);
    long time = clock();

    BlackBoard &bb = BlackBoard::getInstance();
    SubjectAttributes *subjAttr = bb.getSubject(attrib->getParentSubjectID());
    const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();
    
    subjAttr->setTime(time + 1);
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    const bool isVecLegendEmpty = vecLegend->isEmpty();
    SubjectAttributes *nestedSubj = 0;

    // It is more efficient than use iterators
    for(int id = 0; id < subjectsIDs.size(); ++id)
    {
		nestedSubj = bb.getSubject(subjectsIDs.at(id));

#ifdef DEBUG_OBSERVER
        if (subjAttr->getType() == TObsTrajectory)
        qDebug() << "VisualMapping::mappingChanges()" << getSubjectName((int)subjAttr->getType())
            << "nesteds" << subjectsIDs << ": " << subjectsIDs.at(id) 
            << (nestedSubj->getNumericValue(attrib->getName(), v) ? "sim" : "nao") << v;
#endif

        p->setPen(Qt::NoPen);

        // Checks if the nestedSubj is valid and gets their value
        if (nestedSubj //&& (nestedSubj->getType() == attrib->getType())
            && (nestedSubj->getNumericValue(attrib->getName(), v)) )
        {
            // nestedSubj->setTime(time);
            const double &x = nestedSubj->getX();
            const double &y = nestedSubj->getY();

            //// TO-DO: Código irá falhar qdo o id do subject não for 
            //// condizente com a posição no vetor de valores do atributo
            // attrib->addValue(id, v);

            // Primeiro draw() irá gerar imagens em escala de cinza
            if (isVecLegendEmpty)
            {
                v = v - attrib->getMinValue();

                double c = v * attrib->getVal2Color();
                if ((c >= 0) && (c <= 255))
                {
                    color.setRgb(c, c, c);
                }
                else
                {
                    if (! reconfigMaxMin)
                    {	
						if (execModes != Quiet){
							string str = string("Invalid color. You need to reconfigure the "
										"maximum and the minimum values of the attribute ") + string(attrib->getName().toLatin1().data());
							lua_getglobal(L, "customWarning");
							lua_pushstring(L,str.c_str());
							lua_call(L,1,0);
						}
						
                        reconfigMaxMin = true;
                    }
                    color.setRgb(255, 255, 255);
                }
                p->setBrush(color);

                if (gridEnabled)
                    p->setPen(QColor(255 - color.red(), 255 - color.green(), 255 - color.blue()));
            }
            else
            {
                p->setBrush(Qt::white);

                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);

                    if (attrib->getGroupMode() == TObsUniqueValue)
                    {
                        if (v == leg.getToNumber())
                        {
                            p->setBrush(leg.getColor());
                            if (gridEnabled) 
                                p->setPen(leg.getInvertedColor());
                            break;
                        }
                    }
                    else if ((leg.getFromNumber() <= v) && (v < leg.getToNumber()))
					{
						p->setBrush(leg.getColor());
						if (gridEnabled) 
							p->setPen(leg.getInvertedColor());
						break;
					}
                }
            }

            if ((x >= 0) && ( y >= 0))
                rendering(p, attrib->getType(), x, y);

        } // nestedSubj != NULL
    } // loop for each subjectsIDs elements
}

void VisualMapping::mappingAll(Attributes *attrib, QPainter *p)
{
    // if (attrib->getType() == TObsTrajectory)
    //    attrib->getImage()->fill(0); 

    double v = 0.0;

    QColor color(Qt::white);
    p->setBrush(color);

    // long time = clock();
    // subjAttr->setTime(time + 1);

    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    const bool isVecLegendEmpty = vecLegend->isEmpty();

    BlackBoard &bb = BlackBoard::getInstance();
    const QHash<int, SubjectAttributes *> &cachedValues = bb.getCache();
    // SubjectAttributes *nestedSubj = 0;
		
    foreach(SubjectAttributes *nestedSubj, cachedValues)
    //for (QHash<int, SubjectAttributes *>::ConstIterator it = cachedValues.constBegin();
    //    it != cachedValues.constEnd(); ++it)
    {
        //nestedSubj = (*it);

#ifdef DEBUG_OBSERVER
        qDebug() << "VisualMapping::mappingAll()" << getSubjectName((int)nestedSubj->getType())
                << getDataName((int)attrib->getDataType());
#endif

        p->setPen(Qt::NoPen);

        // Checks if the nestedSubj is valid and gets their value
        if (nestedSubj //&& (nestedSubj->getType() == attrib->getType())
            && (nestedSubj->getNumericValue(attrib->getName(), v))) 
        {
            // nestedSubj->setTime(time);
            const double &x = nestedSubj->getX();
            const double &y = nestedSubj->getY();

            // attrib->addValue(id, v);

            // Primeiro draw() irá gerar imagens em escala de cinza
            if (isVecLegendEmpty)
            {
                v = v - attrib->getMinValue();

                double c = v * attrib->getVal2Color();
                if ((c >= 0) && (c <= 255))
                {
                    color.setRgb(c, c, c);
                }
                else
                {
                    if (! reconfigMaxMin)
                    {
						if (execModes != Quiet){
							string str = string("Invalid color. You need to reconfigure the "
												"maximum and the minimum values of the attribute ") + string(attrib->getName().toLatin1().data());
							lua_getglobal(L, "customWarning");
							lua_pushstring(L,str.c_str());
							lua_call(L,1,0);
						}
						
                        reconfigMaxMin = true;
                    }
                    color.setRgb(255, 255, 255);
                }
                p->setBrush(color);

                if (gridEnabled)
                    p->setPen(QColor(255 - color.red(), 255 - color.green(), 255 - color.blue()));
            }
            else
            {
                p->setBrush(Qt::white);

                for(int j = 0; j < vecLegend->size(); j++)
                {
                    // int j = 0;
                    const ObsLegend &leg = vecLegend->at(j);

                    if (attrib->getGroupMode() == TObsUniqueValue)
                    {
                        if (v == leg.getToNumber())
                        {
                            p->setBrush(leg.getColor());
                            if (gridEnabled) 
                                p->setPen(leg.getInvertedColor());
                            break;
                        }
                    }
                    else if ((leg.getFromNumber() <= v) && (v < leg.getToNumber()))
					{
						p->setBrush(leg.getColor());
						if (gridEnabled) 
							p->setPen(leg.getInvertedColor());
						break;
					}
                }
            }

            if ((x >= 0) && ( y >= 0))
                rendering(p, attrib->getType(), x, y);

        } // nestedSubj != NULL
        
#ifdef DEBUG_OBSERVER
        else {qDebug() << "nestedSubj: " << nestedSubj; }
#endif

    } // foreach
}

void VisualMapping::mappingChangesText(Attributes *attrib, QPainter *p)
{  
    // if (attrib->getType() == TObsTrajectory)
    //    attrib->getImage()->fill(0); 
    
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    const bool isVecLegendEmpty = vecLegend->isEmpty();
    const int random = rand() % 256;
    QColor color(random, random, random);    
    QString v;
    
    p->setBrush(color);

    long time = clock();

    BlackBoard &bb = BlackBoard::getInstance();

    SubjectAttributes *subjAttr = bb.getSubject(attrib->getParentSubjectID());
    const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();
    
    subjAttr->setTime(time + 1);
    SubjectAttributes *nestedSubj = 0;

    for(int id = 0; id < subjectsIDs.size(); ++id)  // Opção simples e eficiente
    {
        nestedSubj = bb.getSubject(subjectsIDs.at(id));

        // Checks if the nestedSubj is valid and gets their value
        if (nestedSubj // && (nestedSubj->getType() == attrib->getType())
            && (nestedSubj->getTextValue(attrib->getName(), v))) 
        {
            p->setPen(Qt::NoPen);

            // nestedSubj->setTime(time);
            const double &x = nestedSubj->getX();
            const double &y = nestedSubj->getY();
            if (isVecLegendEmpty)
            {
                p->setBrush(color);

                if (gridEnabled)
                    p->setPen(QColor (255 - random, 255 - random, 255 - random));
            }
            else
            {
                p->setBrush(Qt::white);

                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);
                    if (v == leg.getFrom())
                    {
                        p->setBrush(leg.getColor());
                        if (gridEnabled)
                            p->setPen(leg.getInvertedColor());
                        break;
                    }
                }
            }
            
            if ((x >= 0) && ( y >= 0))
                rendering(p, attrib->getType(), x, y);
        }
    }
}

void VisualMapping::mappingAllText(Attributes *attrib, QPainter *p)
{
    // if (attrib->getType() == TObsTrajectory)
    //    attrib->getImage()->fill(0); 

    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    const bool isVecLegendEmpty = vecLegend->isEmpty();
    const int random = rand() % 256;
    QColor color(random, random, random);
    
    QString v;
    p->setBrush(color);

    BlackBoard &bb = BlackBoard::getInstance();
    const QHash<int, SubjectAttributes *> &cachedValues = bb.getCache();
    // SubjectAttributes *nestedSubj = 0;
    
    foreach(SubjectAttributes *nestedSubj, cachedValues)
    // for (QHash<int, SubjectAttributes *>::ConstIterator it = cachedValues.constBegin();
    //    it != cachedValues.constEnd(); ++it)
    {
        // nestedSubj = (*it);

        // Checks if the nestedSubj is valid and gets their value
        if (nestedSubj // && (nestedSubj->getType() == attrib->getType())
            && (nestedSubj->getTextValue(attrib->getName(), v)) )
        {
            p->setPen(Qt::NoPen);

            // nestedSubj->setTime(time);
            const double &x = nestedSubj->getX();
            const double &y = nestedSubj->getY();

            if (isVecLegendEmpty)
            {
                p->setBrush(color);
                if (gridEnabled)
                    p->setPen(QColor(255 - random, 255 - random, 255 - random));
            }
            else
            {
                p->setBrush(Qt::white);
                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);
                    if (v == leg.getFrom())
                    {
                        p->setBrush(leg.getColor());
                        if (gridEnabled)
                            p->setPen(leg.getInvertedColor());
                        break;
                    }
                }
            }
            if ((x >= 0) && ( y >= 0))
                rendering(p, attrib->getType(), x, y);
        }
    }
}

//TODO: This method must be moved to the header file, because it must be inline.
void VisualMapping::mappingSociety(Attributes *attrib, QPainter *p,
    const QImage &result, const QSize &size)
{
    if (! attrib->getVisible())
        return;

#ifndef TME_DRAW_VECTORIAL_AGENTS
    const double ORIG_TO_DEST_W = 1; //cellSize.width() / spaceSize.width();
    const double ORIG_TO_DEST_H = 1; // cellSize.height() / spaceSize.height();
    
    Q_UNUSED(result);
    Q_UNUSED(size);
    
#else
    p->begin((QImage *) &result);

    double ORIG_TO_DEST_W = 1.0 * result.width() / size.width();
    double ORIG_TO_DEST_H = 1.0 * result.height() / size.height();

#endif

    const int WIDTH_CELL = cellSize.width();
    const int HEIGHT_CELL = cellSize.height();

    const double SIZE_CELL_PROPORT_W = ORIG_TO_DEST_W * WIDTH_CELL;
    const double SIZE_CELL_PROPORT_H = ORIG_TO_DEST_H * HEIGHT_CELL;


#ifdef DEBUG_OBSERVER
    qDebug() << "VisualMapping::mappingSociety()";

    qDebug() << "spaceSize" << spaceSize;
    qDebug() << "cellSize" << cellSize;

    qDebug() << "SIZE_CELL_PROPORT_W " << SIZE_CELL_PROPORT_W << "ORIG_TO_DEST_W" << ORIG_TO_DEST_W
        << "WIDTH_CELL" << WIDTH_CELL;
    qDebug() << "SIZE_CELL_PROPORT_H" << SIZE_CELL_PROPORT_H << "ORIG_TO_DEST_H" << ORIG_TO_DEST_H
        << "HEIGHT_CELL" << HEIGHT_CELL<< " cellSize" << cellSize ;
#endif

    QRectF rec;
    const QRectF RECT_CELL(0 - SIZE_CELL_PROPORT_W * 0.5, 0 - SIZE_CELL_PROPORT_H * 0.5,
        SIZE_CELL_PROPORT_W, SIZE_CELL_PROPORT_H);

    BlackBoard &bb = BlackBoard::getInstance();
    
    //if (! attrib)
    //    return; 

    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    
#ifdef DEBUG_OBSERVER
    qDebug() << parentSubjAttr->toString() << subjectsIDs.size() << "\nids: " << subjectsIDs;
#endif
    
    attrib->getImage()->fill(0);

#ifdef TME_DRAW_VECTORIAL_AGENTS
    p->setFont(attrib->getFont());

#else
    // Resize the character of agent
    QFont attribFont = attrib->getFont();

    if (WIDTH_CELL > attribFont.pointSize() * 4)
        attribFont.setPointSize(WIDTH_CELL * 0.6);
    p->setFont(attribFont);
#endif   
    
    SubjectAttributes *nestedSubj = 0;
    SubjectAttributes *parentSubjAttr = bb.getSubject(attrib->getParentSubjectID());

    const QVector<int> &subjectsIDs = parentSubjAttr->getNestedSubjects();

    bool exist = false, isTextual = (attrib->getDataType() == TObsText);
    QString v;
    double num, x, y;

    for(int id = 0; id < subjectsIDs.size(); ++id)  // Opção simples e eficiente
    {
        nestedSubj = bb.getSubject(subjectsIDs.at(id));
        
        if (nestedSubj)
        {
            // Checks what kind of attribute has being visualized
            if (isTextual)
                exist = nestedSubj->getTextValue(attrib->getName(), v);
            else
                exist = nestedSubj->getNumericValue(attrib->getName(), num);

#ifdef DEBUG_OBSERVER
            qDebug() << ">>>>>>>>>>>>>>>>>>>>>" << nestedSubj->toString() 
                ; // << "\n------" << attrib->getName() << "\n" << v << parentSubjAttr->toString() << "\n";

            qDebug() << "nestedSubj->getType()" << getSubjectName( nestedSubj->getType() )
                << "attrib->getType()" << getSubjectName( attrib->getType() );
#endif

            if (exist) // && (nestedSubj->getType() == attrib->getType()))
            {
                // x = 0; y = 0;

                if (nestedSubj->hasNestedSubjects())
                {
                    const QVector<int> &subNestedSujectsIDs = nestedSubj->getNestedSubjects();

                    // An agent is in only one place on space
                    // So, we get the first id of vector of sub-nested subject
                    if (! subNestedSujectsIDs.isEmpty()) 
                    {
                        SubjectAttributes *subNestedSuj = bb.getSubject(subNestedSujectsIDs.at(0));
                        x = subNestedSuj->getX() * WIDTH_CELL;
                        y = subNestedSuj->getY() * HEIGHT_CELL;
                    }
                }

                // nestedSubj->setTime(time);
                rec = QRectF( x * ORIG_TO_DEST_W , y * ORIG_TO_DEST_H, 
                    SIZE_CELL_PROPORT_W, SIZE_CELL_PROPORT_H);

                p->save();

                p->setPen(Qt::black);
                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);

                    if ((isTextual) && (v == leg.getFrom()) )
                    {
                        p->setPen(leg.getColor());
                        break;
                    }
                    else if (num == leg.getFromNumber())
                    {
                        p->setPen(leg.getColor());
                        break;
                    }
                }
                p->translate(rec.center());

#ifdef DEBUG_OBSERVER
                // qDebug() << "RECT_CELL" << RECT_CELL << ",  rec" << rec;
                // p->drawRect(rec);

                p->drawRect(RECT_CELL); 
                // p->rotate((qreal) (qrand() % 360) );
                qreal a = attrib->getDirection(x, y);
                p->rotate(a);
                p->drawText(RECT_CELL, Qt::AlignCenter, attrib->getSymbol());
#else 

                p->rotate(attrib->getDirection(x, y));

                // p.drawText(RECT_CELL, align[qrand() % ALIGN_FLAGS], attrib->getSymbol());

                // Delimita a area que o simbolo podera ocupar
                int xPos = (int) RECT_CELL.x() + RECT_CELL.width() * 0.07;
                int yPos = (int) RECT_CELL.y() + RECT_CELL.height() * 0.07;

                xPos += qrand() % (int) (RECT_CELL.width() * 0.85);
                yPos += qrand() % (int) (RECT_CELL.height() * 0.85); 
                QPointF position(RECT_CELL.center());
                position += QPointF(xPos, yPos);

                p->drawText(position, attrib->getSymbol());

#endif 
                p->restore();
            }
        }
    }
        
#ifdef DEBUG_OBSERVER
    static int g = 0;
    g++;
    // result.save(QString("result_%1.png").arg(g), "png");
    
    //if (img)
    //    img->save(QString("agent_result_%1.png").arg(g), "png");

    attrib->getImage()->save(QString("agent_result_%1.png").arg(g), "png");

#endif

}

void VisualMapping::drawAgent(const QImage &result, const QSize &size)
{
    if (agentAttribPositions && agentAttribPositions->isEmpty())
        return;

#ifdef TME_DRAW_VECTORIAL_AGENTS

    double ORIG_TO_DEST_W = 1.0 * result.width() / size.width();
    double ORIG_TO_DEST_H = 1.0 * result.height() / size.height();

#else
    const double ORIG_TO_DEST_W = 1.0 * result.width() / spaceSize.width();
    const double ORIG_TO_DEST_H = 1.0 * result.height() / spaceSize.height();
   
    Q_UNUSED(size);
#endif
    
    const int WIDTH_CELL = cellSize.width();
    const int HEIGHT_CELL = cellSize.height();

    double SIZE_CELL_PROPORT_W = ORIG_TO_DEST_W * WIDTH_CELL;
    double SIZE_CELL_PROPORT_H = ORIG_TO_DEST_H * HEIGHT_CELL;

#ifdef DEBUG_OBSERVER
    qDebug() << "\nresult.size()" << result.size() << ", size" << size;

    std::cout << "SIZE_CELL_PROPORT_W: " << SIZE_CELL_PROPORT_W << ", ORIG_TO_DEST_W: " << ORIG_TO_DEST_W
        << ", WIDTH_CELL: " << WIDTH_CELL;
    std::cout << "\nSIZE_CELL_PROPORT_H: " << SIZE_CELL_PROPORT_H << ", ORIG_TO_DEST_H: " << ORIG_TO_DEST_H
        << ", HEIGHT_CELL: " << HEIGHT_CELL;
    qDebug() << " cellSize" << cellSize ;
#endif

    QRectF rec;
    const QRectF RECT_CELL(0 - SIZE_CELL_PROPORT_W * 0.5, 0 - SIZE_CELL_PROPORT_H * 0.5,
        SIZE_CELL_PROPORT_W, SIZE_CELL_PROPORT_H);

    QImage *img = 0;
    BlackBoard &bb = BlackBoard::getInstance();

#ifdef DEBUG_OBSERVER
    qDebug() << "agentAttribPositions->size()" <<
        agentAttribPositions->size();
#endif

    // Gets the Attribute that is an Agent
    for (int i = 0; i < agentAttribPositions->size(); i++)
    { 
        Attributes *attrib = attribList.at( agentAttribPositions->at(i) );

        if (attrib->getVisible())
        {
#ifdef TME_DRAW_VECTORIAL_AGENTS
            QPainter p( (QImage *) &result );
#else
            img = attrib->getImage();
            img->fill(0);

            QPainter p(img);
#endif

            SubjectAttributes *nestedSubj = 0, 
                *subjAttr = bb.getSubject(attrib->getParentSubjectID());

            bool exist = false, isTextual = (attrib->getDataType() == TObsText);

            QString v;
            double num = 0.0, x = 0.0, y = 0.0;
            
            // Checks what kind of attribute has being visualized
            if (isTextual)
                exist = subjAttr->getTextValue(attrib->getName(), v);
            else
                exist = subjAttr->getNumericValue(attrib->getName(), num);

            const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();
            QVector<ObsLegend> *vecLegend = attrib->getLegend();
            
#ifdef DEBUG_OBSERVER
            qDebug() << subjAttr->toString() << subjectsIDs.size();
#endif


#ifdef TME_DRAW_VECTORIAL_AGENTS
            p.setFont(attrib->getFont());

#else
            // Resize the character of agent
            QFont attribFont = attrib->getFont();

            if (WIDTH_CELL > attribFont.pointSize() * 4)
                attribFont.setPointSize(WIDTH_CELL * 0.6);
            p.setFont(attribFont);
#endif

            
            // From an agent gets the cell where this agent are in
            for(int id = 0; id < subjectsIDs.size(); ++id)  // Opção simples e eficiente
            {
                nestedSubj = bb.getSubject(subjectsIDs.at(id));
                
#ifdef DEBUG_OBSERVER
                 qDebug() << ">>>>>>>>>>>>>>>>>>>>>" << nestedSubj->toString();
                 // qDebug() << "------" << attrib->getName() << "\n" << v << subjAttr->toString() << "\n";
#endif

                // Checks if the nestedSubj is valid and gets their position
                if (nestedSubj && exist) // && (nestedSubj->getType() == attrib->getType()))
                {
                    // nestedSubj->setTime(time);
                    x = nestedSubj->getX() * WIDTH_CELL;
                    y = nestedSubj->getY() * HEIGHT_CELL;
                    rec = QRectF( x * ORIG_TO_DEST_W , y * ORIG_TO_DEST_H, 
                        SIZE_CELL_PROPORT_W, SIZE_CELL_PROPORT_H);

                    p.setPen(Qt::white);
                    p.save();

                    for(int j = 0; j < vecLegend->size(); j++)
                    {
                        const ObsLegend &leg = vecLegend->at(j);

                        if ((isTextual) && (v == leg.getFrom()) )
                        {
                            p.setPen(leg.getColor());
                            break;
                        }
                        else if (num == leg.getFromNumber())
                        {
                            p.setPen(leg.getColor());
                            break;
                        }
                    }
                    p.translate(rec.center());

#ifdef DEBUG_OBSERVER
                   // qDebug() << "RECT_CELL" << RECT_CELL << ",  rec" << rec;
                    // p.drawRect(rec);
                    
                    p.drawRect(RECT_CELL); 
                    // p.rotate((qreal) (qrand() % 360) );
                    qreal a = attrib->getDirection(x, y);
                    p.rotate(a);
                    p.drawText(RECT_CELL, Qt::AlignCenter, attrib->getSymbol());

#else 
                    
                    p.rotate(attrib->getDirection(x, y));
                    
                    // p.drawText(RECT_CELL, align[qrand() % ALIGN_FLAGS], attrib->getSymbol());

                    // Delimita a area que o simbolo podera ocupar
                    int xPos = (int) RECT_CELL.x() + RECT_CELL.width() * 0.07;
                    int yPos = (int) RECT_CELL.y() + RECT_CELL.height() * 0.07;

                    xPos += qrand() % (int) (RECT_CELL.width() * 0.85);
                    yPos += qrand() % (int) (RECT_CELL.height() * 0.85); 
                    QPointF position(RECT_CELL.center());
                    position += QPointF(xPos, yPos);

                    p.drawText(position, attrib->getSymbol());

#endif 

                    p.restore();
                }

#ifndef TME_DRAW_VECTORIAL_AGENTS
                QPainter painter;    
                painter.begin((QImage *)&result);
                // painter.setCompositionMode(QPainter::CompositionMode_SourceOver);
                painter.drawImage(ZERO_POINT, *img); 
                painter.end();
#endif // TME_DRAW_VECTORIAL_AGENTS

            }
        }
    }

#ifdef TME_DRAW_VECTORIAL_AGENTS 
    if (observerType == TObsImage)
        save(result);
#else
    if (observerType == TObsMap)
        emit displayImage(result);
    else
        save(result);
#endif

     
#ifdef DEBUG_OBSERVER
    static int g = 0;
    g++;
    //result.save(QString("result_%1.png").arg(g), "png");
    
    if (img)
        img->save(QString("agent_result_%1.png").arg(g), "png");

#endif

}

void VisualMapping::mappingNeighborhood(Attributes *attrib, QPainter *p)
{
    double v = 0.0;

    // p->setRenderHint(QPainter::Antialiasing);
    // p->setRenderHint(QPainter::TextAntialiasing);
    // qDebug() << "VisualMapping::drawAttrib() eh uma vizinhanca " << p->renderHints();

    QColor color(Qt::white);
    // p->setBrush(color);
    QPen pen = p->pen();
    pen.setStyle(Qt::SolidLine);
    pen.setWidth(attrib->getWidth());

    long time = clock();

    BlackBoard &bb = BlackBoard::getInstance();
    
    SubjectAttributes *subjAttr = bb.getSubject(attrib->getParentSubjectID());
    const QVector<int> &subjectsIDs = subjAttr->getNestedSubjects();

    subjAttr->setTime(time + 1);
    QVector<ObsLegend> *vecLegend = attrib->getLegend();
    const bool isVecLegendEmpty = vecLegend->isEmpty();
    SubjectAttributes *nestedSubj = 0, *nestedSubjParentCell = 0;

    if (subjectsIDs.size() > 0)             
        nestedSubjParentCell = bb.getSubject(subjectsIDs.at(0));

    const double xParentCell = (cellSize.width() * nestedSubjParentCell->getX()) 
        + (cellSize.width() * 0.5);
    const double yParentCell = (cellSize.height() * nestedSubjParentCell->getY()) 
        + (cellSize.height() * 0.5);

    // Checks if nestedSubjParentCell is neighbor of itself
    int selfNeighIdx = subjectsIDs.lastIndexOf(nestedSubjParentCell->getId());
    QPen selfNeighPen;

    // It is more efficient than use iterators
    for(int id = 1; id < subjectsIDs.size(); ++id)
    {
        nestedSubj = bb.getSubject(subjectsIDs.at(id));

#ifdef DEBUG_OBSERVER
        if (subjAttr->getType() == TObsNeighborhood)
            qDebug() << attrib->toString();
#endif

        // Checks if the nestedSubj is valid and gets their value
        if ((nestedSubj)
            // && (nestedSubj->getNumericValue(attrib->getName(), v)  ))
            && (nestedSubj->getNumericValue("weight", v)  ))
        {
            // nestedSubj->setTime(time);
            const double &x = nestedSubj->getX();
            const double &y = nestedSubj->getY();

            //// TO-DO: Código irá falhar qdo o id do subject não for 
            //// condizente com a posição no vetor de valores do atributo
            // attrib->addValue(id, v);

            // Primeiro draw() irá gerar imagens em escala de cinza
            if (isVecLegendEmpty)
            {
                v = v - attrib->getMinValue();

                double c = v * attrib->getVal2Color();
                if ((c >= 0) && (c <= 255))
                {
                    color.setRgb(c, c, c);
                }
                else
                {
                    if (! reconfigMaxMin)
                    {
						if (execModes != Quiet){
							string str = string("Invalid color. You need to reconfigure the "
												"maximum and the minimum values of the attribute") + string(attrib->getName().toLatin1().data());
							lua_getglobal(L, "customWarning");
							lua_pushstring(L,str.c_str());
							lua_call(L,1,0);
						}
						
                        reconfigMaxMin = true;
                    }
                    color.setRgb(255, 255, 255);
                }
                // p->setBrush(color);
                pen.setColor(color);
            }
            else
            {
                // p->setBrush(Qt::white);

                for(int j = 0; j < vecLegend->size(); j++)
                {
                    const ObsLegend &leg = vecLegend->at(j);

                    if (attrib->getGroupMode() == TObsUniqueValue)
                    {
                        if (v == leg.getToNumber())
                        {
                            pen.setColor(leg.getColor());
                            break;
                        }
                    }
                    else
                    {
                        if ((leg.getFromNumber() <= v) && (v < leg.getToNumber()) )
                        {
                            pen.setColor(leg.getColor());
                            break;
                        }
                    }
                }
                p->setPen(pen);
            }

            if (nestedSubj->getId() == nestedSubjParentCell->getId())
                selfNeighPen = pen;

            if ((x >= 0) && ( y >= 0))
                renderingNeighbor(p, xParentCell, yParentCell, x, y);

        } // nestedSubj != NULL

    } // loop for each subjectsIDs elements

    // Makes a back-up of pen painter
    pen = p->pen();

    if (selfNeighIdx > 0)
        p->setBrush( selfNeighPen.color() );
    else
        p->setBrush(Qt::white);

    // Draws the ellipse that meaning if the cell is itself neighbor
    p->setPen(Qt::black);
    p->drawEllipse(QPointF(xParentCell, yParentCell), attrib->getWidth(), attrib->getWidth());

    // Restores the back-up of pen painter
    p->setPen(pen);
}

void VisualMapping::drawGrid(QImage * /*image*/, double & /*width*/, double & /*height*/)
{
    qDebug() << "VisualMapping::drawGrid(QImage *image, double &width, double &height)";

    ////mutex.lock();
    //resultImageBkp = image;
    //propWidthCell = width;
    //propHeightCell = height;
    ////mutex.unlock();
}

void VisualMapping::drawGrid()
{
    qDebug() << "VisualMapping::drawGrid()";

    ////mutex.lock();
    //double w = propWidthCell;
    //double h = propHeightCell;
    ////mutex.unlock();

    //QPainter p(result);
    //p.setPen(Qt::darkGray);

    //for(int j = 0; j < result.height(); j++)
    //{
    //    for(int i = 0; i < result.width(); i++)
    //        p.drawRect(i * w, j * h, w, h);
    //}
}

void VisualMapping::enableGrid(bool state)
{
    gridEnabled = state;
}


void VisualMapping::setPath(const QString & pth)
{
    path = pth;
}

void VisualMapping::save(const QImage &result)
{
#ifdef TME_DRAW_VECTORIAL_AGENTS
    if (observerType != TObsImage)
        return;
#endif
    static const QString COMPLEMENT("000000");

    countSave++;

    QString countString, aux;
    aux = COMPLEMENT;
    countString = QString::number(countSave);
    aux = aux.left(COMPLEMENT.size() - countString.size());
    aux.append(countString);

    QString name =  path + aux + ".png";

#ifndef DEBUG_OBSERVER

    bool ret = result.save(name);
    emit saveImage(ret);

#else
    //// bool ret = resultImage.save(name);

    //// if (countSave == 1)
    //{
    //    // Salva o resultado em um PNG de 8 bits e em escala cinza.
    //    QImage imgTeste = resultImage.scaled(8193, 8193);
    //    // imgTeste.save(path + "teste.png");

    //    QImage retImg(imgTeste.width(), imgTeste.height(), QImage::Format_Indexed8);
    //    QVector<QRgb> table( 256 );
    //    for( int i = 0; i < 256; ++i )
    //        table[i] = qRgb(i, i, i);

    //    retImg.setColorTable(table);

    //    for(int i = 0; i < imgTeste.width(); i++)
    //    {
    //        for(int j = 0; j < imgTeste.height(); j++)
    //        {
    //            QRgb value = imgTeste.pixel(i, j);
    //            retImg.setPixel(i, j, qGray(value));
    //        }
    //    }
    //    return retImg.save(name); // path+ + "grayScale.png");
    //}
    //return ret;
#endif
}

