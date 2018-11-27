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

#include <stdexcept>

#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/parsers/XercesDOMParser.hpp>
#include <xercesc/dom/DOMDocument.hpp>
#include <xercesc/dom/DOMNodeList.hpp>
#include <xercesc/dom/DOMImplementation.hpp>
#include <xercesc/dom/DOMImplementationRegistry.hpp>
#include <boost/filesystem.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/tokenizer.hpp>

#include "QgsWriter.h"
#include "Utils.h"

terrame::qgis::QGis& terrame::qgis::QGis::getInstance()
{
	static terrame::qgis::QGis instance;
	return instance;
}

terrame::qgis::QGisProject terrame::qgis::QGis::read(const std::string& qgsfile)
{
	if(!boost::filesystem::exists(qgsfile))
	{
		throw std::runtime_error("QGIS project file '" + qgsfile + "' not found.");
	}

	if (boost::algorithm::to_lower_copy(boost::filesystem::extension(qgsfile)) != ".qgs")
	{
		throw std::runtime_error("QGIS file extension must be '.qgs', but received '"
								+ boost::filesystem::extension(qgsfile)
								+ "'.");
	}

	xercesc::XMLPlatformUtils::Initialize();

	xercesc::XercesDOMParser* parser = new xercesc::XercesDOMParser();
	parser->setValidationScheme(xercesc::XercesDOMParser::Val_Never);
	parser->setDoNamespaces(false);
	parser->setDoSchema(false);
	parser->setLoadExternalDTD(false);

	parser->parse(qgsfile.c_str());
	xercesc::DOMDocument* doc = parser->getDocument();
	xercesc::DOMElement* root = doc->getDocumentElement();

	if (!root)
	{
		delete parser;
		xercesc::XMLPlatformUtils::Terminate();
		throw std::runtime_error("Empty QGIS project.");
	}

	QGisProject qgp;
	qgp.setFile(qgsfile);
	qgp.setVersion(getVersion(root));
	qgp.setTitle(getTitle(root));

	xercesc::DOMNodeList* layersNode = root->getElementsByTagName(xercesc::XMLString::transcode("maplayer"));
	for (unsigned int i = 0; i < layersNode->getLength(); i++)
	{
		xercesc::DOMElement* layerElement = dynamic_cast<xercesc::DOMElement*>(layersNode->item(i));
		QGisLayer* layer = new QGisLayer();
		layer->setName(getElementContentAsString(layerElement, "layername"));
		layer->setSrid(std::stoi(getElementContentAsString(layerElement, "srid")));
		layer->setUri(getElementContentAsUri(layerElement, "datasource", qgsfile));
		qgp.addLayer(layer);
	}

	delete parser;
	xercesc::XMLPlatformUtils::Terminate();

	return qgp;
}

void terrame::qgis::QGis::write(const QGisProject& qgp, const std::string& qgsfile)
{
	if (boost::filesystem::exists(qgsfile))
	{
		QGisProject fileQgp = getInstance().read(qgsfile);
		std::vector<QGisLayer*> layersInFile = fileQgp.getLayers();
		std::vector<QGisLayer*> layersParam = qgp.getLayers();
		std::vector<QGisLayer*> layersToAdd;
		for (unsigned int i = 0; i < layersParam.size(); i++)
		{
			if(!fileQgp.hasLayer(layersParam.at(i)))
			{
				layersToAdd.push_back(layersParam.at(i));
			}
		}

		if(layersToAdd.size() > 0)
		{
			writeLayers(fileQgp, qgsfile, layersToAdd);
		}
	}
}

int terrame::qgis::QGis::getVersion(xercesc::DOMElement* root)
{
	std::string ver = xercesc::XMLString::transcode(
					root->getAttribute(xercesc::XMLString::transcode("version")));

	return std::stoi(&ver.front());
}

std::string terrame::qgis::QGis::getTitle(xercesc::DOMElement * root)
{
	xercesc::DOMNodeList* nodeList = root->getElementsByTagName(
							xercesc::XMLString::transcode("title"));
	xercesc::DOMNode* node = nodeList->item(0);

	return xercesc::XMLString::transcode(node->getTextContent());
}

bool terrame::qgis::QGis::isNodeValid(xercesc::DOMNode * node)
{
	return node->getNodeType() &&
			(node->getNodeType() == xercesc::DOMNode::ELEMENT_NODE);
}

std::string terrame::qgis::QGis::getElementContentAsString(xercesc::DOMElement* element,
															 const std::string& name)
{
	xercesc::DOMNodeList* node = element->getElementsByTagName(
									xercesc::XMLString::transcode(name.c_str()));
	xercesc::DOMElement* el = dynamic_cast<xercesc::DOMElement*>(node->item(0));
	std::string value = xercesc::XMLString::transcode(el->getTextContent());

	return value;
}

te::core::URI terrame::qgis::QGis::getElementContentAsUri(xercesc::DOMElement* element,
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

te::core::URI terrame::qgis::QGis::createFileUri(const std::string& qgsfile,
												const std::string& content)
{
	try
	{
		boost::filesystem::path relativeTo(qgsfile);
		boost::filesystem::path dir(relativeTo.parent_path());
		boost::filesystem::path canonic(boost::filesystem::canonical(content, dir));
		return te::core::URI("file://" + canonic.string());
	}
	catch (const boost::filesystem::filesystem_error& e)
	{
		throw std::runtime_error(content + " - " + e.what());
	}
}

te::core::URI terrame::qgis::QGis::createDatabaseUri(const std::string & content)
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
		+ table.at(1));

	te::core::URI uri(uriStr);

	if (!uri.isValid())
		throw std::runtime_error("Invalid QGIS database URI: '"
								+ uriStr + "'.");

	return uri;
}

te::core::URI terrame::qgis::QGis::createWfsUri(const std::string& content)
{
	std::map<std::string, std::string> contents(
							terrame::qgis::createAttributesMap(content, " "));

	std::string uriStr("wfs:" + contents.at("url") + "?" + contents.at("typename"));

	te::core::URI uri(uriStr);

	if (!uri.isValid())
		throw(std::runtime_error("Invalid QGIS WFS URI."));

	return uri;
}

te::core::URI terrame::qgis::QGis::createWmsUri(const std::string& content)
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

bool terrame::qgis::QGis::isDatabase(const std::string& content)
{
	return boost::contains(content, "dbname");
}

bool terrame::qgis::QGis::isWfs(const std::string& content)
{
	return boost::contains(content, "typename");
}

bool terrame::qgis::QGis::isWms(const std::string& content)
{
	return boost::contains(content, "contextualWMSLegend");
}

void terrame::qgis::QGis::writeLayers(const terrame::qgis::QGisProject& qgp, const std::string& qgsfile,
										std::vector<QGisLayer*> layers)
{
	terrame::qgis::QgsWriter::getInstance().insert(qgp, layers, qgsfile);
}

void terrame::qgis::QGis::setPostgisRole(const std::string& user,
										const std::string& password)
{
	this->user = user;
	this->password = password;
}
