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

#include <QFile>
#include <QTextStream>
#include <QWidget>
#include <QResizeEvent>
#include <QMoveEvent>

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

void VisualArrangement::resizeEventDelegate(int id,  QResizeEvent *event)
{
    SizeVisualArrangement s;
    s.height = event->size().height();
    s.width = event->size().width();

    addSize(id, s);
}

void VisualArrangement::moveEventDelegate(int id, QMoveEvent *event)
{
    PositionVisualArrangement p;
    p.x = event->pos().x();
    p.y = event->pos().y();

    addPosition(id, p);
}

void VisualArrangement::closeEventDelegate()
{
    buildLuaCode();
}

void VisualArrangement::starts(int id, QWidget *widget)
{
    SizeVisualArrangement s = getSize(id);
    PositionVisualArrangement p = getPosition(id);

    if(s.width > 0 && s.height > 0)
        widget->resize(s.width, s.height);
    else
        widget->resize(450, 350);

    if(p.x > 0 && p.y > 0)
        widget->move(p.x, p.y - widget->geometry().y() + widget->y());
    else
        widget->move(50 + id * 50, 50 + id * 50);

    widget->showNormal();
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

    QFile qfile(file.c_str());

    if (qfile.open(QIODevice::ReadWrite | QIODevice::Truncate))
    {
        QTextStream out(&qfile);
        out << "return {" << endl;
        for(std::map<int, PositionVisualArrangement>::iterator it =
                myarrangement->position.begin(); it != myarrangement->position.end(); ++it)
        {
            out << "\t[" << it->first << "] = {" << endl;
            out << "\t\tx = " << it->second.x << ", \n";
            out << "\t\ty = " << it->second.y << ", \n";
            out << "\t\twidth = " << myarrangement->size[it->first].width << ", \n";
            out << "\t\theight = " << myarrangement->size[it->first].height << ", \n";
            out << "\t}, " << endl;
        }
        out << "}" << endl;
    }
    qfile.close();
}

