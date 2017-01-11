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

#ifndef VISUAL_ARRANGEMENT
#define VISUAL_ARRANGEMENT

#include <map>
#include <string>
#include <iostream>
#include <fstream>

class QResizeEvent;
class QMoveEvent;
class QWidget;

using namespace std;

struct PositionVisualArrangement
{
	int x;
	int y;
};

struct SizeVisualArrangement
{
	int width;
	int height;
};

class VisualArrangement
{
public:
	static VisualArrangement* getInstance();

	void addSize(int, SizeVisualArrangement);
	void addPosition(int, PositionVisualArrangement);

	SizeVisualArrangement getSize(int id);
	PositionVisualArrangement getPosition(int id);
	void setFile(string);

	void buildLuaCode();

    void resizeEventDelegate(int id, QResizeEvent *event);
    void moveEventDelegate(int id,  QMoveEvent *event);
    void closeEventDelegate();
    void starts(int id, QWidget *widget);

protected:
	VisualArrangement() {}
	static VisualArrangement* myarrangement;
	string file;
private:
	map<int, PositionVisualArrangement> position;
	map<int, SizeVisualArrangement> size;
};

#endif

