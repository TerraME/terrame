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

#include "QGisProject.h"

terrame::qgis::QGisProject::QGisProject(const std::string& qgspath)
{
	this->file = qgspath;
}

terrame::qgis::QGisProject::~QGisProject() {}

terrame::qgis::QGisProject::QGisProject(const QGisProject& other)
	: layers(other.layers)
{
	file = other.file;
	title = other.title;
	author = other.author;
	version = other.version;
}

std::string terrame::qgis::QGisProject::getFile() const
{
	return file;
}

void terrame::qgis::QGisProject::setFile(const std::string & filepath)
{
	this->file = filepath;
}

std::string terrame::qgis::QGisProject::getTitle() const
{
	return title;
}

void terrame::qgis::QGisProject::setTitle(const std::string& title)
{
	this->title = title;
}

std::string terrame::qgis::QGisProject::getAuthor()
{
	return author;
}

void terrame::qgis::QGisProject::setAuthor(const std::string& author)
{
	this->author = author;
}

int terrame::qgis::QGisProject::getVersion()
{
	return version;
}

void terrame::qgis::QGisProject::setVersion(int version)
{
	this->version = version;
}

void terrame::qgis::QGisProject::addLayer(const terrame::qgis::QGisLayer& layer)
{
	layers.push_back(layer);
}

void terrame::qgis::QGisProject::removeLayer(const terrame::qgis::QGisLayer& layer)
{
	for (unsigned int i = 0; i < layers.size(); i++)
	{
		if(layers.at(i).equals(layer))
		{
			layers.erase(layers.begin() + i);
		}
	}
}

std::vector<terrame::qgis::QGisLayer> terrame::qgis::QGisProject::getLayers() const
{
	return layers;
}

std::vector<terrame::qgis::QGisLayer> terrame::qgis::QGisProject::getLayersDiff(const QGisProject& other) const
{
	std::vector<QGisLayer> olayers = other.getLayers();
	std::vector<QGisLayer> layersDiff;

	for (unsigned int i = 0; i < olayers.size(); i++)
	{
		if (!this->hasLayer(olayers.at(i)))
		{
			layersDiff.push_back(olayers.at(i));
		}
	}

	return layersDiff;
}

bool terrame::qgis::QGisProject::hasLayer(const terrame::qgis::QGisLayer& layer) const
{
	for (unsigned int i = 0; i < layers.size(); i++)
	{
		if (layers.at(i).equals(layer))
		{
			return true;
		}
	}
	return false;
}

bool terrame::qgis::QGisProject::hasLayer(const std::string& name)
{
	return !getLayerByName(name).empty();
}

terrame::qgis::QGisLayer terrame::qgis::QGisProject::getLayerByName(const std::string& name)
{
	for(int i = 0; i < layers.size(); i++)
	{
		if(layers.at(i).getName() == name)
		{
			return layers.at(i);
		}
	}

	return QGisLayer();
}
