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

/*!
  \file region.h
  \brief Region is an indexed set of cells implemented as a map composite of generic indexes into cell pointers.
                 Handles: Region
  \author Tiago Garcia de Senna Carneiro (tiago@dpi.inpe.br)
*/
#ifndef REGION_H
#define REGION_H

#include <map>
using namespace std;

#include "composite.h"
#include "cell.h"

class Cell;

/**
 * \brief
 *  Handle for a Region object. The Region object implements the TerraME Trajectory (or SpatialIterator) in C++
 *  programming language. It is implemented as a multimap composite of indexes into cells. This concept is completely
 *  re-implemented in Lua software layer
 *
 */
template <class Indx>
class Region_ : public CompositeInterface< multimapComposite<Indx, Cell*> >
{
public:
    /// Add a cell to the Region
    /// \param indx is a generic index representing the n-dimensional cell coordinate
    /// \param cell is a pointer to the cell being inserted into the Region
    void add(Indx indx, Cell* cell)
    {
        pair<Indx, Cell*>  indexCellPair;

        indexCellPair.first = indx;
        indexCellPair.second = cell;

        CompositeInterface< multimapComposite<Indx, Cell*> >::add(indexCellPair);
    }

    /// Searches for a cell into the region
    /// \return a Cell pointer is the cell has been found, otherwise returns a NULL pointer
    Cell* operator [](Indx indx)
    {
        pair<Indx, Cell*>  indexCellPair;

        indexCellPair =
        		CompositeInterface< multimapComposite<Indx, Cell*> >::operator [](indx);

        return indexCellPair.second;
    }
};
#endif
