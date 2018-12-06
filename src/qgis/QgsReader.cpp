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

#include "QgsReader.h"

#include <stdexcept>

#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/tokenizer.hpp>

#include <QDomElement>
#include <QFile>

#include "Utils.h"

terrame::qgis::QGisProject terrame::qgis::QgsReader::read(const std::string& qgspath)
{
	if (!boost::filesystem::exists(qgspath))
	{
		throw std::runtime_error("QGIS project file '" + qgspath + "' not found.");
	}

	if (boost::algorithm::to_lower_copy(boost::filesystem::extension(qgspath)) != ".qgs")
	{
		throw std::runtime_error("QGIS file extension must be '.qgs', but received '"
			+ boost::filesystem::extension(qgspath)
			+ "'.");
	}

	QDomDocument doc;

	QFile qgsfile(qgspath.c_str());
	if (!qgsfile.open(QIODevice::ReadOnly | QIODevice::Text))
	{
		throw std::runtime_error("Failed to open QGIS project file for reading.");
	}
	
	if(!doc.setContent(&qgsfile))
	{
		qgsfile.close();
		throw std::runtime_error("Failed to load QGIS project file for reading.");
	}

	qgsfile.close();

	QDomElement root = doc.firstChildElement();

	QGisProject qgp;
	qgp.setFile(qgspath);
	qgp.setVersion(getVersion(root));
	qgp.setTitle(getElementContentAsString(root, "title"));

	QDomNodeList layers = root.elementsByTagName("maplayer");
	for (unsigned int i = 0; i < layers.length(); i++)
	{
		QDomElement layerElement = layers.item(i).toElement();
		QGisLayer layer;
		layer.setName(getElementContentAsString(layerElement, "layername"));
		layer.setSrid(getElementContentAsInt(layerElement, "srid"));
		layer.setUri(getElementContentAsUri(layerElement, "datasource", qgspath));
		qgp.addLayer(layer);
	}

	return qgp;
}

int terrame::qgis::QgsReader::getVersion(const QDomElement& root)
{
	QString ver = root.attribute("version").at(0);
	return ver.toInt();
}

std::string terrame::qgis::QgsReader::getElementContentAsString(const QDomElement& element,
															const std::string& name)
{	
	QDomNode node = element.elementsByTagName(name.c_str()).item(0);
	return node.toElement().text().toStdString();
}

int terrame::qgis::QgsReader::getElementContentAsInt(const QDomElement& element,
															const std::string& name)
{
	QDomNode node = element.elementsByTagName(name.c_str()).item(0);
	return node.toElement().text().toInt();
}

te::core::URI terrame::qgis::QgsReader::getElementContentAsUri(const QDomElement& element,
															const std::string& name,
															const std::string& qgsfile)
{
	std::string content(getElementContentAsString(element, name));

	if (isDatabase(content))
	{
		return createDatabaseUri(content);
	}
	else if (isWfs(content))
	{
		return createWfsUri(content);
	}
	else if (isWms(content))
	{
		return createWmsUri(content);
	}
	else
	{
		return createFileUri(qgsfile, content);
	}

	return te::core::URI("");
}

te::core::URI terrame::qgis::QgsReader::createFileUri(const std::string& qgsfile,
												const std::string& content)
{
	try
	{
		if(boost::filesystem::is_regular_file(content))
		{
			return  te::core::URI("file://" + content);
		}
		else
		{
			boost::filesystem::path relativeTo(qgsfile);
			boost::filesystem::path dir(relativeTo.parent_path());
			boost::filesystem::path canonic(boost::filesystem::canonical(content, dir));
			return te::core::URI("file://" + canonic.string());
		}
	}
	catch (const boost::filesystem::filesystem_error& e)
	{
		throw std::runtime_error("QGIS reading file problem: '" + content + "' - " + e.what());
	}
}

te::core::URI terrame::qgis::QgsReader::createDatabaseUri(const std::string & content)
{
	std::map<std::string, std::string> contents(createAttributesMap(content, " "));
	std::vector<std::string> table;
	boost::split(table, contents.at("table"), boost::is_any_of("."));

	if(contents.find("password") == contents.end())
	{
		if ((this->password != "") && (this->user != ""))
		{
			contents.insert(std::pair<std::string, std::string>("password", this->password));
			contents.insert(std::pair<std::string, std::string>("user", this->user));
		}
		else
		{
			throw std::runtime_error("QGIS Postgis user and password not found. Set its Role before load.");
		}
	}

	std::string uriStr("pgsql://" + contents.at("user") + ":"
		+ contents.at("password") + "@"
		+ contents.at("host") + ":"
		+ contents.at("port") + "/"
		+ contents.at("dbname") + "?"
		+ ((table.size() == 1) ? table.at(0) : table.at(1)));

	te::core::URI uri(uriStr);

	if (!uri.isValid())
		throw std::runtime_error("Invalid QGIS database URI: '"
								+ uriStr + "'.");

	return uri;
}

te::core::URI terrame::qgis::QgsReader::createWfsUri(const std::string& content)
{
	std::map<std::string, std::string> contents(
							terrame::qgis::createAttributesMap(content, " "));

	std::string uriStr("wfs:" + contents.at("url") + "?" + contents.at("typename"));

	te::core::URI uri(uriStr);

	if (!uri.isValid())
		throw(std::runtime_error("Invalid QGIS WFS URI."));

	return uri;
}

te::core::URI terrame::qgis::QgsReader::createWmsUri(const std::string& content)
{
	std::map<std::string, std::string> contents(
								terrame::qgis::createAttributesMap(content, "&"));
	std::vector<std::string> format;
	boost::split(format, contents.at("format"), boost::is_any_of("/"));

	std::string uriStr("wms:" + contents.at("url") + "?"
		+ "format=" + format.at(1) + "&"
		+ "layers=" + contents.at("layers"));

	te::core::URI uri(uriStr);

	if (!uri.isValid())
		throw(std::runtime_error("Invalid QGIS WMS URI."));

	return uri;
}

bool terrame::qgis::QgsReader::isDatabase(const std::string& content)
{
	return boost::contains(content, "dbname");
}

bool terrame::qgis::QgsReader::isWfs(const std::string& content)
{
	return boost::contains(content, "typename");
}

bool terrame::qgis::QgsReader::isWms(const std::string& content)
{
	return boost::contains(content, "contextualWMSLegend");
}

void terrame::qgis::QgsReader::setPostgisRole(const std::string& user,
										const std::string& password)
{
	this->user = user;
	this->password = password;
}
