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

#include "QGis.h"

#include <boost/filesystem.hpp>

#include "QgsReader.h"
#include "QgsWriter.h"
#include "Utils.h"

terrame::qgis::QGis& terrame::qgis::QGis::getInstance()
{
	static terrame::qgis::QGis instance;
	return instance;
}

terrame::qgis::QGisProject terrame::qgis::QGis::read(const std::string& qgsfile)
{
	QgsReader reader;
	reader.setPostgisRole(user, password);
	return reader.read(qgsfile);
}

void terrame::qgis::QGis::write(const QGisProject& qgp)
{
	QgsWriter writer;

	if (boost::filesystem::exists(qgp.getFile()))
	{
		QGisProject fileQgp = getInstance().read(qgp.getFile());
		std::vector<QGisLayer> layersInFile = fileQgp.getLayers();
		std::vector<QGisLayer> layersParam = qgp.getLayers();
		std::vector<QGisLayer> layersToAdd;
		for (unsigned int i = 0; i < layersParam.size(); i++)
		{
			if(!fileQgp.hasLayer(layersParam.at(i)))
			{
				layersToAdd.push_back(layersParam.at(i));
			}
		}

		if(layersToAdd.size() > 0)
		{
			writer.addLayers(qgp, layersToAdd);
		}
	}
	else
	{
		writer.create(qgp);
	}
}

void terrame::qgis::QGis::setPostgisRole(const std::string& user,
										const std::string& password)
{
	this->user = user;
	this->password = password;
}
