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

#ifndef QGIS_LAYER_H
#define QGIS_LAYER_H

#include <string>
#include <vector>

#include <terralib/core.h>

#include "Config.h"

namespace terrame
{
	namespace qgis
	{
		class TERRAME_QGIS_DLL_EXPORT QGisLayer
		{
		public:
			QGisLayer();
			QGisLayer(const std::string& name, int srid,
					const te::core::URI& uri);
			QGisLayer(const QGisLayer& other);
			virtual ~QGisLayer();

			std::string getName();
			void setName(const std::string& name);
			int getSrid() const;
			void setSrid(int srid);
			te::core::URI getUri() const;
			void setUri(const te::core::URI& uri);
			std::string getPath() const;
			void setExtent(double xmin, double ymin, double xmax, double ymax);
			void setSpatialRefSys(const std::string& proj4,
									const std::string& description);
			void setProvider(const std::string& provider);
			void setGeometry(const std::string& geometry);
			void setType(const std::string& type);
			void setAcronyms(const std::string& proj4);
			std::string getProvider();
			std::string getGeometry();
			std::string getType();
			double getXmin() const;
			double getXmax() const;
			double getYmin() const;
			double getYmax() const;
			std::string getProj4() const;
			std::string getSrsid();
			std::string getDescription() const;
			std::string getProjectionAcronym() const;
			std::string getEllipsoidAcronym() const;
			void setDataSetName(const std::string& name);
			std::string getDataSetName() const;

			bool equals(const QGisLayer& other);
			bool empty();

		private:
			std::string name;
			int srid;
			te::core::URI uri;

			std::string provider;
			std::string geometry;
			std::string type;
			double xmin, xmax, ymin, ymax;
			std::string proj4;
			std::string srsid;
			std::string description;
			std::string projectionAcronym;
			std::string ellipsoidAcronym;
			std::string dataset;
		};
	} // namespace qgis
} // namespace terrame

#endif
