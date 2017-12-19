/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.
*************************************************************************************/

#include "CellularSpaceTest.h"

#include "core/model.cpp"  //< TODO(#1919): change after
#include "core/cellularSpace.h"

void CellularSpaceTest::SetUp()
{
	cs = new CellularSpace();
}

void CellularSpaceTest::TearDown()
{
	cs->clear();
	delete cs;
}

void CellularSpaceTest::addCell(int first, int second)
{
	Cell *c = new Cell();
	CellIndex ci;
	ci.first = first;
	ci.second = second;
	cs->add(ci, c);
}

TEST_F(CellularSpaceTest, Add1Cell)
{
	addCell(0, 0);
	ASSERT_EQ(cs->size(), 1);
}

TEST_F(CellularSpaceTest, Add2SameCells)
{
	Cell *c = new Cell();
	CellIndex cidx1;
	cidx1.first = 0;
	cidx1.second = 0;

	cs->add(cidx1, c);

	CellIndex cidx2;
	cidx2.first = 0;
	cidx2.second = 1;

	cs->add(cidx2, c);

	ASSERT_EQ(cs->size(), 2);

	Region_<CellIndex>::iterator cit1 = cs->find(cidx1);
	Region_<CellIndex>::iterator cit2 = cs->find(cidx2);

	ASSERT_NE(cit1, cit2);
	ASSERT_EQ(cit1->second, cit2->second);  //< it is possible add same cell
	ASSERT_NE(cit1->first, cit2->first);
	ASSERT_EQ(cit1->first.first, cit2->first.first);
	ASSERT_NE(cit1->first.second, cit2->first.second);
}

TEST_F(CellularSpaceTest, Add2SameCellsAndIndexes)
{
	Cell *c = new Cell();
	CellIndex cidx1;
	cidx1.first = 0;
	cidx1.second = 0;

	cs->add(cidx1, c);

	CellIndex cidx2;
	cidx2.first = 0;
	cidx2.second = 0;

	cs->add(cidx2, c);

	ASSERT_EQ(cs->size(), 2);

	Region_<CellIndex>::iterator cit1 = cs->find(cidx1);
	Region_<CellIndex>::iterator cit2 = cs->find(cidx2);

	ASSERT_EQ(cit1, cit2);  //< it is possible add same cell and same index
	ASSERT_EQ(cit1->second, cit2->second);
	ASSERT_EQ(cit1->first, cit2->first);
}

TEST_F(CellularSpaceTest, Add2CellsWithSameIndexes)
{
	Cell *c1 = new Cell();
	CellIndex cidx1;
	cidx1.first = 0;
	cidx1.second = 0;

	cs->add(cidx1, c1);

	Cell *c2 = new Cell();
	CellIndex cidx2;
	cidx2.first = 0;
	cidx2.second = 0;

	cs->add(cidx2, c2);

	ASSERT_EQ(cs->size(), 2);

	Region_<CellIndex>::iterator cit1 = cs->find(cidx1);
	Region_<CellIndex>::iterator cit2 = cs->find(cidx2);

	ASSERT_EQ(cit1, cit2);  //< the its are the same, is this a problem?
	ASSERT_EQ(cit1->second, cit2->second);
	ASSERT_EQ(cit1->first, cit2->first);
}


TEST_F(CellularSpaceTest, Synchronize)
{
	addCell(0, 0);
	addCell(0, 1);
	addCell(1, 0);
	addCell(1, 1);

	ASSERT_EQ(cs->size(), 4);

	cs->synchronize(sizeof(multimapComposite<CellIndex, Cell* >));
}

TEST_F(CellularSpaceTest, SynchronizeWithoutCells)
{
	cs->synchronize(sizeof(multimapComposite<CellIndex, Cell* >));
}
