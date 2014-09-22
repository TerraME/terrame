#include "decoder.h"

#include <QStringList>
#include <QMap>
#include <QDebug>

#include "blackBoard.h"

#ifdef TME_PROTOCOL_BUFFERS
	#include "protocol.pb.h"
#endif

using namespace TerraMEObserver;

Decoder::Decoder()
{
    mapAttributes = 0;
    stateSize = 0;
}

Decoder::Decoder(const Decoder &)
{

}

Decoder& Decoder::operator=(Decoder &)
{
    return *this;
}

Decoder::~Decoder()
{

}

void Decoder::setBlackBoard(BlackBoard *blackBoard)
{
    bb = blackBoard;
}

void Decoder::setMapAttrbute(QHash<QString, Attributes*> *mapAttribs)
{
    mapAttributes = mapAttribs;
}

#ifdef TME_PROTOCOL_BUFFERS

bool Decoder::decode(const QByteArray &state)
{  
#ifdef DEBUG_OBSERVER
    // It was checked before the call
    if (state.empty())
        return false;
#endif

    ObserverDatagramPkg::SubjectAttribute subjDatagram;
    bool ret = subjDatagram.ParseFromArray(state.data(), state.size());

    stateSize = subjDatagram.ByteSize();

#ifdef DEBUG_OBSERVER 
    qDebug() << "ret: " << (ret ? "true" : "false");
    // std::cout << subjDatagram.DebugString();

    qDebug() << "subjDatagram.id()" << subjDatagram.id();
#endif

    if (ret)
    {
        SubjectAttributes *subjAttr = bb->insertSubject( subjDatagram.id() );
        subjAttr->setSubjectType( (TypesOfSubjects) subjDatagram.type() );
        subjAttr->setDirtyBit(false);
        subjAttr->clearNestedSubjects();

        if (ret && subjDatagram.attribsnumber() > 0)
        {
            ret = ret && decodeAttributes(subjAttr, subjDatagram);
        }
#ifdef DEBUG_OBSERVER
        else
        {
            qDebug() << "Fail in decodeAttributes of subjDatagram - " << subjDatagram.id();
        }
#endif

        if (ret && subjDatagram.itemsnumber() > 0)
        {
            // Resets the counter of subjects changed
            bb->resetCounterChangedSubjects();

            // subjAttr->clearNestedSubjects();
            ret = ret && decodeInternals(subjAttr, subjDatagram, subjAttr);
        }
#ifdef DEBUG_OBSERVER
        else
            qDebug() << "Fail in decodeInternals of subjDatagram - " << subjDatagram.id();

        qDebug() << "inter. subjDatagram: "<< subjDatagram.internalsubject_size();
        qDebug() << "inter. subj: "<< subjAttr->getNestedSubjects().size();

#endif


    }

    return ret;
}

bool Decoder::decodeAttributes(SubjectAttributes *subjAttr, 
    const ObserverDatagramPkg::SubjectAttribute &subjDatagram)
{
    // int attrNumber = subjDatagram.rawattributes_size();
    int attrNumber = subjDatagram.attribsnumber();
    // QString key;

    // Gets attributes 
    for (int i = 0; i < attrNumber; ++i)
    {
        const ObserverDatagramPkg::RawAttribute &raw = subjDatagram.rawattributes(i);

        // Textual 
        if (raw.has_text())
        {
            subjAttr->addItem(raw.key().c_str(), raw.text().c_str());
        }
        else
        {
            // Numeric
            // key = raw.key().c_str();
            // if (key == "x")
            if (strcmp(raw.key().c_str(), "x") == 0)
            {
                subjAttr->setX(raw.number());
            }
            else
            {
                // if (key == "y")
                if (strcmp(raw.key().c_str(), "y") == 0)
                {
                    subjAttr->setY(raw.number());
                }
                else
                {
                    /*
                    if (mapAttributes)
                    {
                        Attributes *attrib = mapAttributes->value(raw.key().c_str());
                    
                        if (attrib)
                        {
                            // TO-DO: Código irá falhar qdo o id do subject não for 
                            // condizente com a posição no vetor de valores do atributo
                            double d = raw.number();
                            attrib->addValue(subjAttr->getId(), d);
                        }
                    }
                    */
                    subjAttr->addItem(raw.key().c_str(), raw.number());
                }
            }
        }
    }

    return true;
}

bool Decoder::decodeInternals(SubjectAttributes * /*subjAttr*/, 
    const ObserverDatagramPkg::SubjectAttribute &subjDatagram, SubjectAttributes *parentSubjAttr)
{
    int itemsNumber = subjDatagram.itemsnumber();
    // int itemsNumber = subjDatagram.internalsubject_size()

    bool ret = true;

    // Gets internals subjects
    for (int i = 0; i < itemsNumber; ++i)
    {
        const ObserverDatagramPkg::SubjectAttribute &interSubjDatagram = subjDatagram.internalsubject(i);

        SubjectAttributes *interSubjAttr = bb->insertSubject( interSubjDatagram.id() );
        interSubjAttr->setSubjectType( (TypesOfSubjects) interSubjDatagram.type() ); 
        interSubjAttr->clearNestedSubjects();

        if (parentSubjAttr)
        {
            parentSubjAttr->addNestedSubject(interSubjAttr->getId());

            // Increments the counter of subjects changed
            bb->incrementCounterChangedSubjects();
        }

        if (ret && interSubjDatagram.has_attribsnumber())
        {
            ret = ret && decodeAttributes(interSubjAttr, interSubjDatagram);
        }
#ifdef DEBUG_OBSERVER
        else
        {
            qDebug() << "Fail in decodeAttributes of subjDatagram - " << interSubjDatagram.id();
        }
#endif

        //qDebug() << "\n\nDecoder::decodeInternals()";
        //qDebug() << interSubjAttr->toString();

        if (ret && interSubjDatagram.itemsnumber() > 0)
        {
            // ret = ret && decodeInternals(interSubjAttr, interSubjDatagram, parentSubjAttr);
            ret = ret && decodeInternals(interSubjAttr, interSubjDatagram, interSubjAttr);
        }
#ifdef DEBUG_OBSERVER
        else
        {
            qDebug() << "Fail in decodeInternals of subjDatagram - " << interSubjDatagram.id();
        }
#endif
    }
    return ret;
}

#else /// CODIGO ANTIGO DAQUI PRA BAIXO

bool Decoder::decode(const QByteArray &protocol)
{
    QStringList tokens = QString(protocol).split(PROTOCOL_SEPARATOR,
                                        QString::SkipEmptyParts);

    if (tokens.isEmpty())
        return false;

#ifdef DEBUG_OBSERVER
    qDebug() << tokens;

    // // parentID = tokens.at(0).toInt();
    // parentSubjectType = (TypesOfSubjects) tokens.at(1).toInt();

    // Cleans the set of nested subject
    // int id = tokens.at(0).toInt();
    // if (! cache->contains(id)) qDebug() << "subject removido";
    // cache->value(id)->clearNestedSubjects();
#endif

    // Resets the counter of subjects changed
    bb->resetCounterChangedSubjects();

    SubjectAttributes *subjAttr = bb->getSubject(tokens.at(0).toInt());
    if (subjAttr)
    {
        subjAttr->clearNestedSubjects();
        subjAttr->setDirtyBit(false);
    }

    int idx = 0;
    bool ret = interpret(tokens, idx);

#ifdef DEBUG_OBSERVER
    // qDebug() << tokens

    // if (parentSubjectType == TObsAgent)
    //    qDebug() << tokens.at(0);

    qDebug() << "size: " << cache->size() << "\n";

    foreach(const int &k, cache->keys())
    {
        qDebug() << "Id : " << k;
        qDebug() << "attribName: " << cache->value(k)->getRawAttributes().keys();
        qDebug() << "position: " << cache->value(k)->getCoordinates();

        foreach(const RawAttribute *r, cache->value(k)->getRawAttributes())
            qDebug() << "   AttrName: " << r->key << " AttrType: " << getDataName(r->type);
        qDebug() << "";
    }
#endif

    return ret;
    
    // qDebug() << "Deprecated, use: \n\t bool decode(const QByteArray &state) instead of";
    // return false;
}

#endif


bool Decoder::interpret(QStringList &tokens, int &idx, int parentSubjID) 
{
    bool ret = false;
    int subID;
    TypesOfSubjects subjectType = TObsUnknown;
    int numAttrib = 0, numElem = 0;
    
    ret = consumeID(subID, tokens, idx);
    ret = ret && consumeSubjectType(subjectType, tokens, idx);
    ret = ret && consumeAttribNumber(numAttrib, tokens, idx);
    ret = ret && consumeElementNumber(numElem, tokens, idx);

    numAttrib *= 3;
    numElem *= 3;

    // Maintains the nested subject into parent subject
    if (parentSubjID > 0)
	{
        SubjectAttributes *subjAttr = bb->getSubject(parentSubjID);
        if (subjAttr)
            subjAttr->addNestedSubject(subID);

        // 50% mais eficiente usando ponteiros ao invés dos ID's
        //SubjectAttributes *subjAttr = bb->getSubject(parentSubjID);
        //SubjectAttributes *nestedSubj = bb->getSubject(subID);
        //if (subjAttr && nestedSubj)
        //    subjAttr->addNestedSubject(nestedSubj);

        // Increments the counter of subjects changed
         bb->incrementCounterChangedSubjects();
    }
	////@RAIAN: Decodificando a Vizinhanca
	//if(subjectType == TObsNeighborhood)
	//{
	//	if(cache->contains(subID))
	//	{
	//		Attributes *attrib = 0;
 //           QMap<QString, QList<double> > neighborhood; // = QMap<QString, QList<double> >();

	//		ret = interpret(tokens, idx, xs, ys); // Pega as informações da célula central da vizinhanca

	//		consumeNeighborhood(tokens, idx, subID, numElem, neighborhood);
	//		attrib = cache->value(id);

	//		if(attrib->getType() != TObsNeighborhood)
	//			attrib->setType(TObsNeighborhood);

	//		if(attrib->getDataType() == TObsUnknownData)
	//			attrib->setDataType(TObsNumber);

	//		attrib->addValue(neighborhood);
	//	}
	//}
	////@RAIAN: FIM
	// else
	{
		int i = 4;
		for(; ret && (i < numAttrib + 4); i += 3)
			ret = consumeTriple(tokens, idx, subID);

		for(i = 0; ret && (i < numElem) && (idx < tokens.size()); i++)
			ret = interpret(tokens, idx, subID);
	}
    return ret;
}

// transição 1-2: idenficação do objeto
bool Decoder::consumeID(int &id, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    ok = false;
    id = tokens.at(idx).toInt(&ok);
    idx++;

    bb->addSubject(id);

#ifdef DEBUG_OBSERVER
        qDebug() << "Decoder::consumeID - inserted Id: " << id;
#endif


#ifdef DEBUG_OBSERVER
    else
    {
        qDebug() << "subj cache: " << id << " size(): " << cache->value(id)->toString();
	}
#endif

    return ok;
}

// transição 2-3: definicao do tipo de subject
bool Decoder::consumeSubjectType(TypesOfSubjects &type, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    type = (TypesOfSubjects) tokens.at(idx).toInt();
    idx++;
    return true;
}

// transição 3-4: número de atributos
bool Decoder::consumeAttribNumber(int &value, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    value = tokens.at(idx).toInt();
    idx++;
    return true;
}

// transição 4-5: número de elementos
bool Decoder::consumeElementNumber(int &value, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    value = tokens.at(idx).toInt();
    idx++;
    return true;
}

// transição 5-[6-7-8]*: chave, tipo, valor
bool Decoder::consumeTriple(QStringList &tokens, int &idx, const int &subjID)
{
    if (tokens.size() <= idx + 2)
        return false;

    QString attrName = tokens.at(idx);
    TypesOfData type = (TypesOfData) tokens.at(idx + 1).toInt();
    SubjectAttributes *subjAttr = 0;

    // const QString &hashKey = subjID;

    if (attrName == "x")
    {
            subjAttr = bb->getSubject(subjID);
            
            if (subjAttr)
                subjAttr->setX(tokens.at(idx + 2).toDouble());
            
            //if ((parentSubjectType == TObsTrajectory) && (cache->contains("trajectory")))
            //{
            //    rawAttrib = cache->value("trajectory");
            //    rawAttrib->setValue<double>("trajectory", TObsNumber, attrib->getXsValue()->size() );
            //}
        }
    else
    {
        if (attrName == "y")
        {
            subjAttr = bb->getSubject(subjID);
            if (subjAttr)
                subjAttr->setY(tokens.at(idx + 2).toDouble());
        }
        else
        {
            subjAttr = bb->getSubject(subjID);

            if (subjAttr)
            {
        		switch(type)
        		{
            	case TObsNumber:
                    tmpNumber = tokens.at(idx + 2).toDouble();
                    subjAttr->addItem(attrName, tmpNumber);

                    //if (mapAttributes)
                    //{
                    //    Attributes *attrib = mapAttributes->value(attrName);
                    //
                    //    if (attrib)
                    //    {
                    //        // TO-DO: Código irá falhar qdo o id do subject não for 
                    //        // condizente com a posição no vetor de valores do atributo
                    //        attrib->addValue(subjID, tmpNumber);
                    //    }
                    //}
                break;

            	case TObsText:
                    subjAttr->addItem(attrName, tokens.at(idx + 2));
                break;

            	case TObsBool:
            	case TObsDateTime:
            	default:
                	break;
        		}
    		}
        }
    }
    idx += 3;
    return true;
}

//@RAIAN: Metodos para decodificar a vizinhanca
void Decoder::consumeNeighborhood(QStringList &tokens, int &idx, QString neighborhoodID, 
    int &numElem, QMap<QString, QList<double> > &neighborhood)
{
	for(int i = 0; (i < (numElem - 3)) && idx < tokens.size(); i += 3)
	{
		consumeNeighbor(tokens, idx, neighborhood);
	}	
}

void Decoder::consumeNeighbor(QStringList &tokens, int &idx, QMap<QString, QList<double> > &neighborhood)
{
	int id;
	TypesOfSubjects subjectType = TObsUnknown;
	int numAttrib = 0, numElem = 0;
	
	consumeID(id, tokens, idx);
	consumeSubjectType(subjectType, tokens, idx);
	consumeAttribNumber(numAttrib, tokens, idx);
	consumeElementNumber(numElem, tokens, idx);

	numAttrib *= 3;
	numElem *= 3;

	QList<double> neighbor = QList<double>();
	
	for(int i = 0; i < numAttrib; i += 3)
	{
		consumeNeighborTriple(tokens, idx, neighbor);
		neighborhood.insert(QString(id), neighbor);
	}
}

void Decoder::consumeNeighborTriple(QStringList &tokens, int &idx, QList<double> &neighbor)
{
	QString key = tokens.at(idx);
	// TypesOfData type = (TypesOfData) tokens.at(idx + 1).toInt();
	
	if(key == "x")
		neighbor.insert(0, tokens.at(idx + 2).toDouble());
	else
	{
		if(key == "y")
			neighbor.insert(1, tokens.at(idx + 2).toDouble());
		else
		{
			if(key == "@getWeight")
				neighbor.insert(2, tokens.at(idx + 2).toDouble());
		}
	}

	idx += 3;
}
//@RAIAN: FIM
