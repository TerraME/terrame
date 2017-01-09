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

#include "blackBoard.h"
#include "../observer.h"

#include <QDataStream>
#include <QBuffer>
#include <QByteArray>
#include <QDebug>

using namespace TerraMEObserver;

/**
 * Provides a private cache structure to a Subject object in the BlackBoard
 * \see QByteArray, \see QDataStream, \see QBuffer
 */
class PrivateCache
{
public:
    bool dirtyBit;          /// the dirty-bit flag
    QByteArray *byteArray;  /// structure that contains a Subject internal state
    QBuffer *buffer;        /// interface for a QByteArray
    QDataStream *out;       /// provides the serialization of the QByteArray

    /**
     * Constructor
     */
    PrivateCache()
    {
        dirtyBit = true;

        byteArray = new QByteArray();
        buffer = new QBuffer(byteArray);
        out = new QDataStream(buffer);
    }

    /**
     * Destructor
     */
    virtual ~PrivateCache()
    {
        delete byteArray;
        delete buffer;
        delete out;
    }
};

BlackBoard::BlackBoard() {}

BlackBoard::~BlackBoard()
{
    foreach(PrivateCache *c, cache)
        delete c;
}

BlackBoard & BlackBoard::getInstance()
{
    static BlackBoard blackBoard;
    return blackBoard;
}

void BlackBoard::setDirtyBit(int subjectId)
{
    if (cache.contains(subjectId))
        cache.value(subjectId)->dirtyBit = true;
    else
        cache.insert(subjectId, new PrivateCache());
}

bool BlackBoard::getDirtyBit(int subjectId) const
{
    return cache.value(subjectId)->dirtyBit;
}

QDataStream & BlackBoard::getState(Subject *subj, int observerId, QStringList &attribs)
{
    PrivateCache *state = cache.value(subj->getId());

    if (!state->dirtyBit)
    {
        return *state->out;
    }

    state->buffer->open(QIODevice::WriteOnly);
    state->out = &subj->getState(*state->out, subj, observerId, attribs);
    state->buffer->close();

    state->dirtyBit = false;
    return *state->out;
}
