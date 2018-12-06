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

#ifndef QGIS_PROJECT_H
#define QGIS_PROJECT_H

#include <string>
#include <vector>

#include "Config.h"
#include "QGisLayer.h"

namespace terrame
{
	namespace qgis
	{
		class TERRAME_QGIS_DLL_EXPORT QGisProject
		{
		public:
			QGisProject(const std::string& qgspath);
			QGisProject(const QGisProject& other);
			virtual ~QGisProject();

			std::string getFile() const;
			void setFile(const std::string& filepath);
			std::string getTitle() const;
			void setTitle(const std::string& title);
			std::string getAuthor();
			void setAuthor(const std::string& author);
			int getVersion();
			void setVersion(int version);
			void addLayer(const terrame::qgis::QGisLayer& layer);
			std::vector<terrame::qgis::QGisLayer> getLayers() const;
			bool hasLayer(const terrame::qgis::QGisLayer& layer);
			bool hasLayer(const std::string& name);
			terrame::qgis::QGisLayer getLayerByName(const std::string& name);

		private:
			std::string file;
			std::string title;
			std::string author;
			int version;
			std::vector<QGisLayer> layers;
		};
	} // namespace qgis
} // namespace terrame

#endif
