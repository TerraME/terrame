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

#include "QgsWriter.h"

#include <stdexcept>

#include <QDomDocument>
#include <QFile>
#include <QTextStream>
#include <QUuid>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>

terrame::qgis::QgsWriter& terrame::qgis::QgsWriter::getInstance()
{
	static terrame::qgis::QgsWriter instance;
	return instance;
}

void terrame::qgis::QgsWriter::insert(const terrame::qgis::QGisProject& qgp,
								const std::vector<terrame::qgis::QGisLayer>& layers)
{
	std::string qgsfile(qgp.getFile());

	QDomDocument doc("QGIS");
	QFile file(qgsfile.c_str());

	if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		throw std::runtime_error("Problem to read QGIS file.");
	}

	doc.setContent(&file);
	file.close();

	QDomElement docElem = doc.documentElement();
	QDomElement layerTreeGroup = docElem.firstChildElement("layer-tree-group");
	QDomElement customOrder = layerTreeGroup.firstChildElement("custom-order");
	QDomElement projectLayers = docElem.firstChildElement("projectlayers");
	QDomElement layerOrder = docElem.firstChildElement("layerorder");

	for(unsigned int i = 0; i < layers.size(); i++)
	{
		QGisLayer layer = layers.at(i);
		QDomElement newLayerTree = doc.createElement("layer-tree-layer");
		newLayerTree.setAttribute("name", layer.getName().c_str());
		std::string relative(getRelativePath(layer.getPath(), qgsfile));
		newLayerTree.setAttribute("source", relative.c_str());
		newLayerTree.setAttribute("checked", "Qt::Checked");
		std::string lid = genLayerId(layer);
		newLayerTree.setAttribute("id", lid.c_str());
		newLayerTree.setAttribute("providerKey", layer.getProvider().c_str());
		newLayerTree.setAttribute("expanded", 1);
		layerTreeGroup.insertBefore(newLayerTree, customOrder);

		customOrder.appendChild(createElement(doc, "item", lid));

		QDomElement newMapLayer = doc.createElement("maplayer");
		newMapLayer.setAttribute("simplifyMaxScale", 1);
		newMapLayer.setAttribute("type", layer.getType().c_str());
		newMapLayer.setAttribute("simplifyLocal", 1);
		newMapLayer.setAttribute("refreshOnNotifyEnabled", 0);
		newMapLayer.setAttribute("simplifyDrawingHints", 1);
		newMapLayer.setAttribute("readOnly", 0);
		newMapLayer.setAttribute("maxScale", 0);
		newMapLayer.setAttribute("hasScaleBasedVisibilityFlag", 0);
		newMapLayer.setAttribute("styleCategories", "AllStyleCategories");
		newMapLayer.setAttribute("simplifyAlgorithm", 0);
		newMapLayer.setAttribute("minScale", "1e+08");
		newMapLayer.setAttribute("labelsEnabled", 0);
		std::string type = layer.getType();
		if(type == "vector")
		{
			newMapLayer.setAttribute("geometry", layer.getGeometry().c_str());
		}
		newMapLayer.setAttribute("refreshOnNotifyMessage", "");
		newMapLayer.setAttribute("autoRefreshTime", 0);
		newMapLayer.setAttribute("autoRefreshEnabled", 0);
		newMapLayer.setAttribute("simplifyDrawingTol", 1);
		projectLayers.appendChild(newMapLayer);

		QDomElement extent = doc.createElement("extent");
		extent.appendChild(createElement(doc, "xmin", std::to_string(layer.getXmin())));
		extent.appendChild(createElement(doc, "ymin", std::to_string(layer.getYmin())));
		extent.appendChild(createElement(doc, "xmax", std::to_string(layer.getXmax())));
		extent.appendChild(createElement(doc, "ymax", std::to_string(layer.getYmax())));
		newMapLayer.appendChild(extent);

		newMapLayer.appendChild(createElement(doc, "id", lid));
		newMapLayer.appendChild(createElement(doc, "datasource", relative));
		newMapLayer.appendChild(createElement(doc, "layername", layer.getName()));

		QDomElement srs = doc.createElement("srs");
		QDomElement spatialRefSys = doc.createElement("spatialrefsys");
		spatialRefSys.appendChild(createElement(doc, "proj4", layer.getProj4()));
		spatialRefSys.appendChild(createElement(doc, "srsid", std::to_string(layer.getSrid())));
		spatialRefSys.appendChild(createElement(doc, "srid", std::to_string(layer.getSrid())));
		spatialRefSys.appendChild(createElement(doc, "authid", "EPSG:" + std::to_string(layer.getSrid())));
		spatialRefSys.appendChild(createElement(doc, "description", layer.getDescription()));
		spatialRefSys.appendChild(createElement(doc, "projectionacronym", layer.getProjectionAcronym()));
		spatialRefSys.appendChild(createElement(doc, "ellipsoidacronym", layer.getEllipsoidAcronym()));
		spatialRefSys.appendChild(createElement(doc, "geographicflag", "true"));
		srs.appendChild(spatialRefSys);
		newMapLayer.appendChild(srs);

		QDomElement provider = doc.createElement("provider");
		provider.setAttribute("encoding", "System");
		QDomText providerText = doc.createTextNode(layer.getProvider().c_str());
		provider.appendChild(providerText);
		newMapLayer.appendChild(provider);

		QDomElement layerElem = doc.createElement("layer");
		layerElem.setAttribute("id", lid.c_str());
		layerOrder.appendChild(layerElem);
	}

	if (!file.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		throw std::runtime_error("Problem to open QGIS file.");
	}

	QTextStream stream(&file);
	doc.save(stream, 2);
	file.close();
}

std::string terrame::qgis::QgsWriter::getRelativePath(const std::string& path,
														const std::string& relative)
{
	std::string result(boost::filesystem::relative(boost::filesystem::path(path),
						boost::filesystem::path(relative)).string());

	std::string winsep("..\\");
	std::string unxsep("../");

	if((occurrences(result, winsep) > 1) || (occurrences(result, unxsep) > 1) || result.empty())
	{
		return path;
	}

	boost::replace_all(result, winsep, "./");
	boost::replace_all(result, unxsep, "./");

	return result;
}

int terrame::qgis::QgsWriter::occurrences(const std::string& str, const std::string& substring)
{
	std::vector<std::string> matches;
	boost::find_all(matches, str, substring);
	return matches.size();
}

QDomElement terrame::qgis::QgsWriter::createElement(QDomDocument& document,
											const std::string& element,
											const std::string& content)
{
	QDomElement elem = document.createElement(element.c_str());
	QDomText text = document.createTextNode(content.c_str());
	elem.appendChild(text);

	return elem;
}

std::string terrame::qgis::QgsWriter::genLayerId(const terrame::qgis::QGisLayer& layer)
{
	QString uuid = QUuid::createUuid().toString();
	std::string id = uuid.mid(1, uuid.length() - 2).toStdString();
	boost::replace_all(id, "-", "_");
	boost::filesystem::path lpath(layer.getDataSetName());

	return lpath.stem().string() + "_" + id;
}