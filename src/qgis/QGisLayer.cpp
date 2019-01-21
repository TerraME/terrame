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
#include "QGisLayer.h"

#include <boost/algorithm/string.hpp>

#include "Utils.h"


terrame::qgis::QGisLayer::QGisLayer() {}

terrame::qgis::QGisLayer::QGisLayer(const std::string& name, int srid,
								const te::core::URI& uri)
{
	this->name = name;
	this->srid = srid;
	this->uri = uri;
}

terrame::qgis::QGisLayer::QGisLayer(const QGisLayer & other)
{
	name = other.name;
	srid = other.srid;
	uri = other.uri;
	provider = other.provider;
	geometry = other.geometry;
	type = other.type;
	setExtent(other.xmin, other.ymin, other.xmax, other.ymax);
	proj4 = other.proj4;
	srsid = other.srsid;
	description = other.description;
	projectionAcronym = other.projectionAcronym;
	ellipsoidAcronym = other.ellipsoidAcronym;
	dataset = other.dataset;
}

terrame::qgis::QGisLayer::~QGisLayer() {}

std::string terrame::qgis::QGisLayer::getName()
{
	return name;
}

void terrame::qgis::QGisLayer::setName(const std::string& name)
{
	this->name = name;
}

int terrame::qgis::QGisLayer::getSrid() const
{
	return srid;
}

void terrame::qgis::QGisLayer::setSrid(int srid)
{
	this->srid = srid;
}

te::core::URI terrame::qgis::QGisLayer::getUri() const
{
	return uri;
}

void terrame::qgis::QGisLayer::setUri(const te::core::URI& uri)
{
	this->uri = uri;
}

std::string terrame::qgis::QGisLayer::getPath() const
{
	if(uri.uri().empty())
	{
		return "";
	}

	if(uri.scheme() == "pgsql")
	{
		return "dbname='" + boost::replace_all_copy(uri.path(), "/", "") + "'"
				+ " host=" + uri.host()
				+ " port=" + uri.port()
				+ " user=" + uri.user()
				+ " password=" + uri.password()
				+ " sslmode=disable"
				+ " key='fid'"
				+ " srid=" + std::to_string(srid)
				+ " type=" + geometry
				+ " table=" + dataset + " (ogr_geometry)"
				+ " sql=";
	}
	else if(uri.scheme() == "WFS")
	{
		return std::string(" restrictToRequestBBOX='1'")
				+ " srsname='EPSG:" + std::to_string(srid) + "'"
				+ " typename='" + dataset + "'"
				+ " url='" + uri.path() + "'"
				+ " version='auto'"
				+ " table=\"\""
				+ " sql=";
	}
	else if(uri.scheme() == "wms")
	{
		std::map<std::string, std::string> info = te::core::Expand(uri.query());
		return std::string("contextualWMSLegend=0&")
				+ "&crs=EPSG:" + std::to_string(srid)
				+ "&format=image/" + info["FORMAT"]
				+ "&layers=" + dataset
				+ "&styles"
				+ "&url=" + info["URI"];
	}
	else
	{
		return boost::replace_all_copy(uri.host() + uri.path(), "\\", "/");
	}
}

void terrame::qgis::QGisLayer::setExtent(double xmin, double ymin,
										double xmax, double ymax)
{
	this->xmin = xmin;
	this->ymin = ymin;
	this->xmax = xmax;
	this->ymax = ymax;
}

void terrame::qgis::QGisLayer::setSpatialRefSys(const std::string& proj4,
											const std::string& description)
{
	this->proj4 = proj4;
	this->srsid = srid;
	this->description = description;
	setAcronyms(proj4);
}

void terrame::qgis::QGisLayer::setProvider(const std::string& provider)
{
	if(provider == "POSTGIS")
	{
		this->provider = "postgres";
	}
	else if(provider == "WFS")
	{
		this->provider = provider;
	}
	else if (provider == "WMS2")
	{
		this->provider = "wms";
	}
	else
	{
		this->provider = boost::algorithm::to_lower_copy(provider);
	}
}

void terrame::qgis::QGisLayer::setGeometry(const std::string& geometry)
{
	this->geometry = geometry;
}

void terrame::qgis::QGisLayer::setType(const std::string& type)
{
	this->type = type;
}

void terrame::qgis::QGisLayer::setAcronyms(const std::string& proj4)
{
	if(!proj4.empty())
	{
		std::map<std::string, std::string> map = terrame::qgis::createAttributesMap(proj4, " ");

		if(proj4.find("proj") != std::string::npos)
		{
			projectionAcronym = map.at("+proj");
		}

		if(proj4.find("ellps") != std::string::npos)
		{
			ellipsoidAcronym = map.at("+ellps");
		}
		else if (proj4.find("datum") != std::string::npos)
		{
			ellipsoidAcronym = map.at("+datum");
		}
	}
}

std::string terrame::qgis::QGisLayer::getProvider()
{
	return provider;
}

std::string terrame::qgis::QGisLayer::getGeometry()
{
	return geometry;
}

std::string terrame::qgis::QGisLayer::getType()
{
	return type;
}

double terrame::qgis::QGisLayer::getXmin() const
{
	return xmin;
}

double terrame::qgis::QGisLayer::getXmax() const
{
	return xmax;
}

double terrame::qgis::QGisLayer::getYmin() const
{
	return ymin;
}

double terrame::qgis::QGisLayer::getYmax() const
{
	return ymax;
}

std::string terrame::qgis::QGisLayer::getProj4() const
{
	return proj4;
}

std::string terrame::qgis::QGisLayer::getSrsid()
{
	return srsid;
}

std::string terrame::qgis::QGisLayer::getDescription() const
{
	return description;
}

std::string terrame::qgis::QGisLayer::getProjectionAcronym() const
{
	return projectionAcronym;
}

std::string terrame::qgis::QGisLayer::getEllipsoidAcronym() const
{
	return ellipsoidAcronym;
}

void terrame::qgis::QGisLayer::setDataSetName(const std::string & name)
{
	dataset = name;
}

std::string terrame::qgis::QGisLayer::getDataSetName() const
{
	return dataset;
}

bool terrame::qgis::QGisLayer::equals(const terrame::qgis::QGisLayer& other) const
{
	return this->name == other.name;
}

bool terrame::qgis::QGisLayer::empty()
{
	return name.empty();
}
