#include "decoder.h"

#include <QStringList>

using namespace TerraMEObserver;

Decoder::Decoder( QHash<QString, Attributes *> *map) : mapAttributes(map)
{

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

bool Decoder::decode(const QString &protocol, 
                     QVector<double> &xs, QVector<double> &ys)
{
    int idx = 0;
    QStringList tokens = protocol.split(PROTOCOL_SEPARATOR,
                                        QString::SkipEmptyParts);

    if (tokens.isEmpty())
        return false;

    // qDebug() << tokens;
    parentSubjectType = (TypesOfSubjects) tokens.at(1).toInt();

#ifdef DEBUG_OBSERVER
    if (parentSubjectType == TObsAgent)
        qDebug() << tokens.at(0);
#endif

    bool ret = interpret(tokens, idx, xs, ys);
    return ret;
}

bool Decoder::interpret(QStringList &tokens, int &idx, 
                        QVector<double> &xs, QVector<double> &ys)
{
    bool ret = false;
    QString id;
    TypesOfSubjects subjectType = TObsUnknown;
    int numAttrib = 0, numElem = 0;
    
    ret = consumeID(id, tokens, idx);
    ret = ret && consumeSubjectType(subjectType, tokens, idx);
    ret = ret && consumeAttribNumber(numAttrib, tokens, idx);
    ret = ret && consumeElementNumber(numElem, tokens, idx);

    numAttrib *= 3;
    numElem *= 3;

	//@RAIAN: Decodificando a Vizinhanca
	if(subjectType == TObsNeighborhood)
	{
		if(mapAttributes->contains(id))
		{
			Attributes *attrib = 0;
                        QMap<QString, QList<double> > neighborhood = QMap<QString, QList<double> >();


			ret = interpret(tokens, idx, xs, ys); // Pega as informa??es da c?lula central da vizinhanca

			consumeNeighborhood(tokens, idx, id, numElem, neighborhood);
			attrib = mapAttributes->value(id);

			if(attrib->getType() != TObsNeighborhood)
				attrib->setType(TObsNeighborhood);

			if(attrib->getDataType() == TObsUnknownData)
				attrib->setDataType(TObsNumber);

			attrib->addValue(neighborhood);
		}
	}
	//@RAIAN: FIM
	else
	{
    
		int i = 4;
		for(; ret && (i < numAttrib + 4); i += 3)
			ret = consumeTriple(tokens, idx, xs, ys);

		for(i = 0; ret && (i < numElem) && (idx < tokens.size()); i++)
			ret = interpret(tokens, idx, xs, ys);
	}

    return ret;
}

// transi??o 1-2: idenfica??o do objeto
bool Decoder::consumeID(QString &id, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    id = tokens.at(idx);
    idx++;
    return true;
}

// transi??o 2-3: definicao do tipo de subject
bool Decoder::consumeSubjectType(TypesOfSubjects &type, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    type = (TypesOfSubjects) tokens.at(idx).toInt();
    idx++;
    return true;
}

// transi??o 3-4: n?mero de atributos
bool Decoder::consumeAttribNumber(int &value, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    value = tokens.at(idx).toInt();
    idx++;
    return true;
}

// transi??o 4-5: n?mero de elementos
bool Decoder::consumeElementNumber(int &value, QStringList &tokens, int &idx)
{
    if (tokens.size() <= idx)
        return false;
        
    value = tokens.at(idx).toInt();
    idx++;
    return true;
}

// transi??o 5-[6-7-8]*: chave, tipo, valor
bool Decoder::consumeTriple(QStringList &tokens, int &idx,
                            QVector<double> &xs, QVector<double> &ys)
{
    if (tokens.size() <= idx + 2)
        return false;

    QString key = tokens.at(idx);
    TypesOfData type = (TypesOfData) tokens.at(idx + 1).toInt();
    Attributes *attrib = 0;

    if (mapAttributes->contains(key))
    {
        switch(type)
        {
            case TObsNumber:
                attrib = mapAttributes->value(key);
                if (attrib->getDataType() == TObsUnknownData)
                    attrib->setDataType(TObsNumber);

                attrib->addValue(tokens.at(idx + 2).toDouble());
                break;

            case TObsText:
                attrib = mapAttributes->value(key);
                if (attrib->getDataType() == TObsUnknownData)
                    attrib->setDataType(TObsText);

#ifdef DEBUG_OBSERVER
                if (attrib->getType() == TObsAgent)
                    qDebug() << "tokens.at(idx + 2): " << tokens.at(idx + 2);
#endif
                attrib->addValue(tokens.at(idx + 2));
                break;

            case TObsBool:
            case TObsDateTime:
            default:
                break;
        }
    }
    else
    {
        if (key == "x")
        {
            xs.append(tokens.at(idx + 2).toDouble());

            if ((parentSubjectType == TObsTrajectory) && (mapAttributes->contains("trajectory")))
            {
                attrib = mapAttributes->value("trajectory");
                attrib->addValue( (double) attrib->getXsValue()->size() );
            }
        }
        else
        {
            if (key == "y")
                ys.append(tokens.at(idx + 2).toDouble());
        }
    }
    idx += 3;
    return true;
}

//@RAIAN: Metodos para decodificar a vizinhanca
void Decoder::consumeNeighborhood(QStringList &tokens, int &idx, QString neighborhoodID, int &numElem, QMap<QString, QList<double> > &neighborhood)
{
	for(int i = 0; (i < (numElem - 3)) && idx < tokens.size(); i += 3)
	{
		consumeNeighbor(tokens, idx, neighborhood);
	}	
}

void Decoder::consumeNeighbor(QStringList &tokens, int &idx, QMap<QString, QList<double> > &neighborhood)
{
	QString id;
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
		neighborhood.insert(id, neighbor);
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

