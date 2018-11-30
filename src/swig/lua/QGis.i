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

%typemap(out) std::vector<terrame::qgis::QGisLayer*>
{
	std::vector<terrame::qgis::QGisLayer*> layers = (std::vector<terrame::qgis::QGisLayer*>)$result;
	int size = (int)layers.size();

	lua_createtable(L, size, 0);
	int layersTable = lua_gettop(L);

	for(int i = 0; i < size; i++)
	{
		SWIG_NewPointerObj(L, (void*) layers.at(i), $descriptor(terrame::qgis::QGisLayer*), 1);
		SWIG_arg++;
		lua_rawseti(L, layersTable, i);
	}

	return 1;
}

%extend terrame::qgis::QGisProject
{
	std::vector<terrame::qgis::QGisLayer*> getLayers()
	{
		std::vector<terrame::qgis::QGisLayer*> layersPtr;
		std::vector<terrame::qgis::QGisLayer> layers = $self->getLayers();

		for(int i = 0; i < layers.size(); i++)
		{
			layersPtr.push_back(new terrame::qgis::QGisLayer(layers.at(i)));
		}

		return layersPtr;
	}
}

%nspace terrame::qgis::QGis;
%nspace terrame::qgis::QGisProject;
%nspace terrame::qgis::QGisLayer;

%include "qgis/QGis.h"
%include "qgis/QGisProject.h"
%include "qgis/QGisLayer.h"
