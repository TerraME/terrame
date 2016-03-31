/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

#ifndef DECODER_H
#define DECODER_H

#include <QVector>
#include <QHash>
#include <QDebug>

#include "../../components/legend/legendAttributes.h"
#include "../../observer.h"

namespace TerraMEObserver {

/**
 * \brief Decoder class for comunication protocol
 * \author Antonio Jos? da Cunha Rodrigues
 * \file decoder.h
 */
class Decoder
{

public:
    /**
     * Constructor
     * \param mapAttributes a pointer to a hash of attributes
     * \see Attributes
     * \see QHash, \see QString
     */
    Decoder( QHash<QString, Attributes *> *mapAttributes);

    /**
     * Destructor
     */
    virtual ~Decoder();

    /**
     * Decodes the state
     * \param protocol the state in QString format
     * \param xs a references to a x axis values
     * \param ys a references to a y axis values
     * \see QVector, \see QString
     */
    bool decode(const QString &protocol, QVector<double> &xs, QVector<double> &ys);

private:
    /**
     * Copy constructor
     */
    Decoder(const Decoder &);

    /**
     * Assign operator
     */
    Decoder& operator=(Decoder &);

    /**
     * Recursion method that start the interpertation of datagram
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \param xs reference to a doubles vector for x axis values
     * \param ys reference to a doubles vector for y axis values
     * \see QStringList
     */
    bool interpret(QStringList &tokens, int &idx, QVector<double> &xs,
                   QVector<double> &ys);

    /**
     * Identification of the subject object
     * Transition: 1-2 of the decoder state machine
     * \param id reference for the subject id
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \see QStringList
     */
    inline bool consumeID(QString &id, QStringList &tokens, int &idx );

    /**
     * Identification of the subject type
     * Transition: 2-3 of the decoder state machine
     * \param type reference for the subject type
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \see TypesOfSubjects
     * \see QStringList
     */
    inline bool consumeSubjectType(TypesOfSubjects &type, QStringList &tokens,
                                   int &idx);

    /**
     * Identification of the attributes number
     * Transition: 3-4 of the decoder state machine
     * \param attrNum number of internal attributes of a subject
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \see QStringList
     */
    inline bool consumeAttribNumber(int &attrNum, QStringList &tokens,
                                    int &idx);

    /**
     * Identification of the elements number
     * Transition: 4-5 of the decoder state machine
     * \param elemNum number of elements that compose a subject
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \see QStringList
     */
    inline bool consumeElementNumber(int &elemNum, QStringList &tokens,
                                     int &idx);

    /**
     * Identification of the triple: key, type and value of a attribute
     * Transition: [6-7-8]* of the decoder state machine
     * \param elemNum number of elements that compose a subject
     * \param tokens reference to a list of attributes values splitted
     * \param idx index of a token under decodification
     * \see QStringList, \see QVector
     */
    inline bool consumeTriple(QStringList &tokens, int &idx, QVector<double> &xs,
                              QVector<double> &ys);

	//@RAIAN: Decodifica a vizinhanca
		/// \author Raian Vargas Maretto
                inline void consumeNeighborhood(QStringList &tokens, int &idx, QString neighborhoodID, int &numElem, QMap<QString, QList<double> > &neighborhood);

		/// \author Raian Vargas Maretto
                inline void consumeNeighbor(QStringList &tokens, int &idx, QMap<QString, QList<double> > &neighborhood);

		/// \author Raian Vargas Maretto
		inline void consumeNeighborTriple(QStringList &tokens, int &idx, QList<double> &neighbor);
	//@RAIAN: FIM


    QHash<QString, Attributes *> *mapAttributes;
    TypesOfSubjects parentSubjectType;
};

}

#endif // DECODER_H
