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

void terrame::qgis::QgsWriter::addLayers(const terrame::qgis::QGisProject& qgp,
								const std::vector<terrame::qgis::QGisLayer>& layers)
{
	QDomDocument doc;
	QFile qgsfile(qgp.getFile().c_str());

	if (!qgsfile.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		throw std::runtime_error("Problem to read QGIS file.");
	}

	doc.setContent(&qgsfile);
	qgsfile.close();

	addLayers(doc, qgp.getFile(), layers);
	save(doc, qgp.getFile());
}

void terrame::qgis::QgsWriter::create(const terrame::qgis::QGisProject& qgp)
{
	QDomImplementation impl;
	QDomDocumentType doctype = impl.createDocumentType("qgis", "http://mrcc.com/qgis.dtd", "SYSTEM");
	QDomDocument doc(doctype);
	QDomElement qgis = doc.createElement("qgis");
	qgis.setAttribute("version", "3.4.1-Madeira");
	qgis.setAttribute("projectname", qgp.getTitle().c_str());
	doc.appendChild(qgis);
	
	QDomElement homePath = doc.createElement("homePath");
	homePath.setAttribute("path", "");
	qgis.appendChild(homePath);
	qgis.appendChild(createTextElement(doc, "title", qgp.getTitle()));
	QDomElement autoTransaction = doc.createElement("autotransaction");
	autoTransaction.setAttribute("active", 0);
	qgis.appendChild(autoTransaction);
	QDomElement evaluateDefaultValues = doc.createElement("evaluateDefaultValues");
	evaluateDefaultValues.setAttribute("active", 0);
	qgis.appendChild(evaluateDefaultValues);
	QDomElement trust = doc.createElement("trust");
	trust.setAttribute("active", 0);
	qgis.appendChild(trust);
	QDomElement projectCrs = doc.createElement("projectCrs");
	projectCrs.appendChild(createSpatialRefSysElement(doc, qgp.getLayers().at(0)));
	qgis.appendChild(projectCrs);

	QDomElement mapCanvas = doc.createElement("mapcanvas");
	mapCanvas.setAttribute("name", "theMapCanvas");
	mapCanvas.setAttribute("annotationsVisible", 1);
	mapCanvas.appendChild(createTextElement(doc, "units", "unknown"));
	mapCanvas.appendChild(createExtentElement(doc, qgp.getLayers().at(0)));
	mapCanvas.appendChild(createTextElement(doc, "rotation", "0"));
	mapCanvas.appendChild(createTextElement(doc, "rendermaptile", "0"));
	qgis.appendChild(mapCanvas);

	QDomElement layerTreeGroup = doc.createElement("layer-tree-group");
	qgis.appendChild(layerTreeGroup);
	QDomElement customOrder = doc.createElement("custom-order");
	customOrder.setAttribute("enabled", 0);
	layerTreeGroup.appendChild(customOrder);
	QDomElement projectLayers = doc.createElement("projectlayers");
	qgis.appendChild(projectLayers);
	QDomElement layerOrder = doc.createElement("layerorder");
	qgis.appendChild(layerOrder);
	
	addLayers(doc, qgp.getFile(), qgp.getLayers());
	save(doc, qgp.getFile());
}

void terrame::qgis::QgsWriter::addLayers(QDomDocument& doc, 
									const std::string& qgsfile,
									const std::vector<terrame::qgis::QGisLayer>& layers)
{
	QDomElement docElem = doc.documentElement();
	QDomElement layerTreeGroup = docElem.firstChildElement("layer-tree-group");
	QDomElement customOrder = layerTreeGroup.firstChildElement("custom-order");
	QDomElement projectLayers = docElem.firstChildElement("projectlayers");
	QDomElement layerOrder = docElem.firstChildElement("layerorder");

	for (unsigned int i = 0; i < layers.size(); i++)
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

		customOrder.appendChild(createTextElement(doc, "item", lid));

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

		newMapLayer.appendChild(createExtentElement(doc, layer));

		newMapLayer.appendChild(createTextElement(doc, "id", lid));
		newMapLayer.appendChild(createTextElement(doc, "datasource", relative));
		newMapLayer.appendChild(createTextElement(doc, "layername", layer.getName()));

		QDomElement srs = doc.createElement("srs");
		srs.appendChild(createSpatialRefSysElement(doc, layer));
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

QDomElement terrame::qgis::QgsWriter::createTextElement(QDomDocument& doc,
											const std::string& element,
											const std::string& content)
{
	QDomElement elem = doc.createElement(element.c_str());
	QDomText text = doc.createTextNode(content.c_str());
	elem.appendChild(text);

	return elem;
}

QDomElement terrame::qgis::QgsWriter::createSpatialRefSysElement(QDomDocument& doc, 
												const terrame::qgis::QGisLayer& layer)
{
	QDomElement spatialRefSys = doc.createElement("spatialrefsys");
	spatialRefSys.appendChild(createTextElement(doc, "proj4", layer.getProj4()));
	spatialRefSys.appendChild(createTextElement(doc, "srsid", std::to_string(layer.getSrid())));
	spatialRefSys.appendChild(createTextElement(doc, "srid", std::to_string(layer.getSrid())));
	spatialRefSys.appendChild(createTextElement(doc, "authid", "EPSG:" + std::to_string(layer.getSrid())));
	spatialRefSys.appendChild(createTextElement(doc, "description", layer.getDescription()));
	spatialRefSys.appendChild(createTextElement(doc, "projectionacronym", layer.getProjectionAcronym()));
	spatialRefSys.appendChild(createTextElement(doc, "ellipsoidacronym", layer.getEllipsoidAcronym()));
	spatialRefSys.appendChild(createTextElement(doc, "geographicflag", "true"));

	return spatialRefSys;
}

QDomElement terrame::qgis::QgsWriter::createExtentElement(QDomDocument& doc, 
													const terrame::qgis::QGisLayer& layer)
{
	QDomElement extent = doc.createElement("extent");
	extent.appendChild(createTextElement(doc, "xmin", toString(layer.getXmin())));
	extent.appendChild(createTextElement(doc, "ymin", toString(layer.getYmin())));
	extent.appendChild(createTextElement(doc, "xmax", toString(layer.getXmax())));
	extent.appendChild(createTextElement(doc, "ymax", toString(layer.getYmax())));
	
	return extent;
}

std::string terrame::qgis::QgsWriter::genLayerId(const terrame::qgis::QGisLayer& layer)
{
	QString uuid = QUuid::createUuid().toString();
	std::string id = uuid.mid(1, uuid.length() - 2).toStdString();
	boost::replace_all(id, "-", "_");
	boost::filesystem::path lpath(layer.getDataSetName());

	return lpath.stem().string() + "_" + id;
}

void terrame::qgis::QgsWriter::save(QDomDocument& doc, const std::string& qgspath)
{
	QFile qgsfile(qgspath.c_str());
	if (!qgsfile.open(QIODevice::WriteOnly | QIODevice::Text))
	{
		throw std::runtime_error("Problem to write QGIS file.");
	}

	QTextStream stream(&qgsfile);
	doc.save(stream, 2);
	qgsfile.close();
}

std::string terrame::qgis::QgsWriter::toString(double number)
{
	return QString::number(number, 'g', 15).toStdString();
}
