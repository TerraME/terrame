/************************************************************************************
* TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
* Copyright (C) 2001-2012 INPE and TerraLAB/UFOP.
*  
* This code is part of the TerraME framework.
* This framework is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
* 
* You should have received a copy of the GNU Lesser General Public
* License along with this library.
* 
* The authors reassure the license terms regarding the warranties.
* They specifically disclaim any warranties, including, but not limited to,
* the implied warranties of merchantability and fitness for a particular purpose.
* The framework provided hereunder is on an "as is" basis, and the authors have no
* obligation to provide maintenance, support, updates, enhancements, or modifications.
* In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
* indirect, special, incidental, or consequential damages arising out of the use
* of this library and its documentation.
*
*************************************************************************************/

#include "visualArrangement.h"
#include <iostream>

using namespace std;

VisualArrangement* VisualArrangement::myarrangement = NULL;

VisualArrangement* VisualArrangement::getInstance()
{
	if(myarrangement == NULL)
	{
		myarrangement = new VisualArrangement();
		myarrangement->file = "";
	}
	return myarrangement;
}

void VisualArrangement::addSize(int id, SizeVisualArrangement va)
{
	myarrangement->size[id] = va;
}

void VisualArrangement::addPosition(int id, PositionVisualArrangement va)
{
	myarrangement->position[id] = va;
}

void VisualArrangement::setFile(string f)
{
	file = f;
}

PositionVisualArrangement VisualArrangement::getPosition(int id)
{
	return myarrangement->position[id];
}

SizeVisualArrangement VisualArrangement::getSize(int id)
{
	return myarrangement->size[id];
}

void VisualArrangement::buildLuaCode()
{
	if(file == "" or myarrangement->position.size() == 0) return;

	ofstream f(file.c_str());

	f << "return {" << endl;

	for(std::map<int, PositionVisualArrangement>::iterator it = myarrangement->position.begin(); it != myarrangement->position.end(); ++it)
	{
		f << "\t[" << it->first << "] = {" << endl;
		f << "\t\tx = " << it->second.x << ", \n";
		f << "\t\ty = " << it->second.y << ", \n";
		f << "\t\twidth = " << myarrangement->size[it->first].width << ", \n";
		f << "\t\theight = " << myarrangement->size[it->first].height << ", \n";

		f << "\t}, " << endl;
	}
	f << "}" << endl;
}

