/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2008 INPE and TerraLAB/UFOP.

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
of this library and its documentation.
*************************************************************************************/

#include "QGisTest.h"

#include "qgis/QGis.h"

TEST_F(QGisTest, LoadEmptyQgsException)
{
	try
	{		
		std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/empty.qgs");
		terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().load(qgsfile);
		FAIL();
	}
	catch(const std::runtime_error& e)
	{
		ASSERT_STREQ(e.what(), "Empty QGIS project.");
	}
	catch(...)
	{
		FAIL();
	}
}

TEST_F(QGisTest, LoadQgsFileNotExists)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampz.qgs");
	EXPECT_ANY_THROW(terrame::qgis::QGis::getInstance().load(qgsfile));
}


TEST_F(QGisTest, LoadOneFileLayer)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().load(qgsfile);
	ASSERT_STREQ(qgp.file.c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.version, 2);
	ASSERT_STREQ(qgp.title.c_str(), "Sampa QGis Project");
	ASSERT_EQ(qgp.layers.size(), 1);

	terrame::qgis::QGisLayer* layer = qgp.layers.at(0);
	ASSERT_STREQ(layer->name.c_str(), "SP");
	ASSERT_EQ(layer->srid, 4019);
	ASSERT_STRNE(layer->uri.path().c_str(), "");
}

TEST_F(QGisTest, LoadVariousFileLayer)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/various.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().load(qgsfile);
	ASSERT_STREQ(qgp.file.c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.version, 2);
	ASSERT_STREQ(qgp.title.c_str(), "");
	ASSERT_EQ(qgp.layers.size(), 3);
	terrame::qgis::QGisLayer* layer;

	layer = qgp.layers.at(0);
	ASSERT_STREQ(layer->name.c_str(), "biomassa-manaus");
	ASSERT_EQ(layer->srid, 4326);
	ASSERT_STRNE(layer->uri.path().c_str(), "");

	layer = qgp.layers.at(1);
	ASSERT_STREQ(layer->name.c_str(), "sampa");
	ASSERT_EQ(layer->srid, 4019);
	ASSERT_STRNE(layer->uri.path().c_str(), "");

	layer = qgp.layers.at(2);
	ASSERT_STREQ(layer->name.c_str(), "vegtype_2000");
	ASSERT_EQ(layer->srid, 4326);
	ASSERT_STRNE(layer->uri.path().c_str(), "");
}

TEST_F(QGisTest, LoadOnePosgisLayer)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampapg.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().load(qgsfile);
	ASSERT_STREQ(qgp.file.c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.version, 2);
	ASSERT_EQ(qgp.layers.size(), 1);

	terrame::qgis::QGisLayer* layer = qgp.layers.at(0);
	ASSERT_STREQ(layer->name.c_str(), "SP");
	ASSERT_EQ(layer->srid, 4019);
	ASSERT_STREQ(layer->uri.path().c_str(), "/postgis_22_sample");
	ASSERT_STREQ(layer->uri.host().c_str(), "localhost");
	ASSERT_STREQ(layer->uri.query().c_str(), "sampa");
	ASSERT_STREQ(layer->uri.user().c_str(), "postgres");
	ASSERT_STREQ(layer->uri.password().c_str(), "postgres");
	ASSERT_STREQ(layer->uri.port().c_str(), "5432");
}

TEST_F(QGisTest, LoadWebLayer)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/webservice.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().load(qgsfile);
	ASSERT_STREQ(qgp.file.c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.version, 2);
	ASSERT_EQ(qgp.layers.size(), 2);

	terrame::qgis::QGisLayer* layer = qgp.layers.at(0);
	ASSERT_STREQ(layer->name.c_str(), "LANDSAT2013");
	ASSERT_EQ(layer->srid, 4326);
	ASSERT_STREQ(layer->uri.path().c_str(), "http://terrabrasilis.info/geoserver/ows");
	ASSERT_STREQ(layer->uri.query().c_str(), "format=png&layers=Prodes_2013:LANDSAT2013");
	ASSERT_STREQ(layer->uri.scheme().c_str(), "wms");

	layer = qgp.layers.at(1);
	ASSERT_STREQ(layer->name.c_str(), "reddpac:LandCover2000");
	ASSERT_EQ(layer->srid, 4326);
	ASSERT_STREQ(layer->uri.path().c_str(), "http://terrabrasilis.info/redd-pac/wfs");
	ASSERT_STREQ(layer->uri.query().c_str(), "reddpac:LandCover2000");
	ASSERT_STREQ(layer->uri.scheme().c_str(), "wfs");
}