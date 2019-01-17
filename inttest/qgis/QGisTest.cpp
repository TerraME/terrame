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

#include <boost/filesystem.hpp>

#include "qgis/QGis.h"

TEST_F(QGisTest, ReadEmptyQgsExceptionQGisV2)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/empty.qgs");

	try
	{
		terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
		FAIL();
	}
	catch(const std::runtime_error& e)
	{
		ASSERT_STREQ(e.what(), "Failed to load QGIS project file for reading.");
	}
	catch(...)
	{
		FAIL();
	}
}

TEST_F(QGisTest, ReadQgsFileNotExists)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampz.qgs");
	EXPECT_ANY_THROW(terrame::qgis::QGis::getInstance().read(qgsfile));
}


TEST_F(QGisTest, ReadOneFileLayerQGisV2)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 2);
	ASSERT_STREQ(qgp.getTitle().c_str(), "Sampa QGis Project");
	ASSERT_EQ(qgp.getLayers().size(), 1);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "SP");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");
}

TEST_F(QGisTest, ReadVariousFileLayerQGisV2)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/various.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 2);
	ASSERT_STREQ(qgp.getTitle().c_str(), "");
	ASSERT_EQ(qgp.getLayers().size(), 3);
	terrame::qgis::QGisLayer layer;

	layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "biomassa-manaus");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");

	layer = qgp.getLayers().at(1);
	ASSERT_STREQ(layer.getName().c_str(), "sampa");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");

	layer = qgp.getLayers().at(2);
	ASSERT_STREQ(layer.getName().c_str(), "vegtype_2000");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");
}

TEST_F(QGisTest, ReadOnePosgisLayerQGisV2)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampapg.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 2);
	ASSERT_EQ(qgp.getLayers().size(), 1);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "SP");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STREQ(layer.getUri().path().c_str(), "/postgis_22_sample");
	ASSERT_STREQ(layer.getUri().host().c_str(), "localhost");
	ASSERT_STREQ(layer.getUri().query().c_str(), "sampa");
	ASSERT_STREQ(layer.getUri().user().c_str(), "postgres");
	ASSERT_STREQ(layer.getUri().password().c_str(), "postgres");
	ASSERT_STREQ(layer.getUri().port().c_str(), "5432");
}

TEST_F(QGisTest, ReadWebLayerQGisV2)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/webservice.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 2);
	ASSERT_EQ(qgp.getLayers().size(), 2);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "LANDSAT2013");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STREQ(layer.getUri().path().c_str(), "http://terrabrasilis.info/geoserver/ows");
	ASSERT_STREQ(layer.getUri().query().c_str(), "format=png&layers=Prodes_2013:LANDSAT2013");
	ASSERT_STREQ(layer.getUri().scheme().c_str(), "wms");

	layer = qgp.getLayers().at(1);
	ASSERT_STREQ(layer.getName().c_str(), "reddpac:LandCover2000");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STREQ(layer.getUri().path().c_str(), "http://terrabrasilis.info/redd-pac/wfs");
	ASSERT_STREQ(layer.getUri().query().c_str(), "reddpac:LandCover2000");
	ASSERT_STREQ(layer.getUri().scheme().c_str(), "wfs");
}

TEST_F(QGisTest, ReadOneFileLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 3);
	ASSERT_STREQ(qgp.getTitle().c_str(), "Sampa QGis Project");
	ASSERT_EQ(qgp.getLayers().size(), 1);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "SP");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");
}

TEST_F(QGisTest, ReadQGisNotSupportedExtension)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgz");

	try
	{
		terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
		FAIL();
	}
	catch (const std::runtime_error& e)
	{
		ASSERT_STREQ(e.what(), "QGIS file extension must be '.qgs', but received '.qgz'.");
	}
	catch (...)
	{
		FAIL();
	}
}

TEST_F(QGisTest, ReadVariousFileLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/various_v3.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 3);
	ASSERT_STREQ(qgp.getTitle().c_str(), "");
	ASSERT_EQ(qgp.getLayers().size(), 3);
	terrame::qgis::QGisLayer layer;

	layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "biomassa-manaus");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");

	layer = qgp.getLayers().at(1);
	ASSERT_STREQ(layer.getName().c_str(), "sampa");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");

	layer = qgp.getLayers().at(2);
	ASSERT_STREQ(layer.getName().c_str(), "vegtype_2000");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STRNE(layer.getUri().path().c_str(), "");
}

TEST_F(QGisTest, ReadOnePosgisLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampapg_v3.qgs");
	terrame::qgis::QGis::getInstance().setPostgisRole("postgres", "postgres");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 3);
	ASSERT_EQ(qgp.getLayers().size(), 1);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "SP");
	ASSERT_EQ(layer.getSrid(), 4019);
	ASSERT_STREQ(layer.getUri().path().c_str(), "/postgis_22_sample");
	ASSERT_STREQ(layer.getUri().host().c_str(), "localhost");
	ASSERT_STREQ(layer.getUri().query().c_str(), "sampa");
	ASSERT_STREQ(layer.getUri().user().c_str(), "postgres");
	ASSERT_STREQ(layer.getUri().password().c_str(), "postgres");
	ASSERT_STREQ(layer.getUri().port().c_str(), "5432");
}

TEST_F(QGisTest, ReadOnePosgisLayerWithoutRoleQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampapg_v3.qgs");
	terrame::qgis::QGis::getInstance().setPostgisRole("", "");

	try
	{
		terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
		FAIL();
	}
	catch (const std::runtime_error& e)
	{
		ASSERT_STREQ(e.what(), "QGIS Postgis user and password not found. Set its Role before load.");
	}
	catch (...)
	{
		FAIL();
	}
}

TEST_F(QGisTest, ReadWebLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/webservice_v3.qgs");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgsfile);
	ASSERT_STREQ(qgp.getFile().c_str(), qgsfile.c_str());
	ASSERT_EQ(qgp.getVersion(), 3);
	ASSERT_EQ(qgp.getLayers().size(), 2);

	terrame::qgis::QGisLayer layer = qgp.getLayers().at(0);
	ASSERT_STREQ(layer.getName().c_str(), "LANDSAT2013");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STREQ(layer.getUri().path().c_str(), "http://terrabrasilis.info/geoserver/ows");
	ASSERT_STREQ(layer.getUri().query().c_str(), "format=png&layers=Prodes_2013:LANDSAT2013");
	ASSERT_STREQ(layer.getUri().scheme().c_str(), "wms");

	layer = qgp.getLayers().at(1);
	ASSERT_STREQ(layer.getName().c_str(), "reddpac:LandCover2000");
	ASSERT_EQ(layer.getSrid(), 4326);
	ASSERT_STREQ(layer.getUri().path().c_str(), "http://terrabrasilis.info/redd-pac/wfs");
	ASSERT_STREQ(layer.getUri().query().c_str(), "reddpac:LandCover2000");
	ASSERT_STREQ(layer.getUri().scheme().c_str(), "wfs");
}

TEST_F(QGisTest, InsertOneFileLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");

	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
								boost::filesystem::path(qgscopy),
								boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisProject newQgp = qgp;
	terrame::qgis::QGisLayer newLayer;
	newLayer.setName("NewLayer");
	newLayer.setSrid(5808);
	std::string fileLayer(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.geojson");
	newLayer.setUri(te::core::URI("file://" + fileLayer));
	newQgp.addLayer(newLayer);

	terrame::qgis::QGis::getInstance().write(newQgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	ASSERT_NE(qgp.getLayers().size(), qgp2.getLayers().size());

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}

TEST_F(QGisTest, InsertSubdirFileLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");
	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	boost::filesystem::path sub1(std::string(TERRAME_INTTEST_DATA_PATH) + "/sub");
	boost::filesystem::create_directory(sub1);
	boost::filesystem::path sub2(sub1.string() + "/dir");
	boost::filesystem::create_directory(sub2);

	std::string fl(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.geojson");
	std::string flcopy(sub2.string() + "/sampa.geojson");
	boost::filesystem::copy_file(boost::filesystem::path(fl),
		boost::filesystem::path(flcopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisProject newQgp = qgp;
	terrame::qgis::QGisLayer newLayer;
	newLayer.setName("NewLayer");
	newLayer.setSrid(5808);
	newLayer.setUri(te::core::URI("file://" + flcopy));
	newQgp.addLayer(newLayer);

	terrame::qgis::QGis::getInstance().write(newQgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	ASSERT_TRUE(qgp2.getLayerByName("NewLayer").equals(newLayer));

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
	boost::filesystem::remove_all(sub2);
	boost::filesystem::remove_all(sub1);
}

TEST_F(QGisTest, InsertFileLayerOutDirTreeQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");
	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisProject newQgp = qgp;
	terrame::qgis::QGisLayer l1;
	l1.setName("NewLayer");
	l1.setSrid(5808);
	std::string fl(std::string(TERRAME_PKGTEST_DATA_PATH) + "/sampa.geojson");
	l1.setUri(te::core::URI("file://" + fl));
	newQgp.addLayer(l1);

	terrame::qgis::QGisLayer l2;
	l2.setName("Tif");
	l2.setSrid(5808);
	std::string f2(std::string(TERRAME_PKGTEST_DATA_PATH) + "/prodes_polyc_10k.tif");
	l2.setUri(te::core::URI("file://" + f2));
	newQgp.addLayer(l2);

	terrame::qgis::QGis::getInstance().write(newQgp);
	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	ASSERT_TRUE(qgp2.getLayerByName("NewLayer").equals(l1));
	ASSERT_STREQ(fl.c_str(), qgp2.getLayerByName("NewLayer").getPath().c_str());
	ASSERT_TRUE(qgp2.getLayerByName("Tif").equals(l2));
	ASSERT_STREQ(f2.c_str(), qgp2.getLayerByName("Tif").getPath().c_str());

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}

TEST_F(QGisTest, InsertPosgisLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");
	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGis::getInstance().setPostgisRole("postgres", "postgres");
	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer layer;
	layer.setName("LayerPg");
	layer.setDataSetName("tablename");
	layer.setSrid(4903);
	layer.setExtent(1.5, 1.3, 1.9, 1.8);
	layer.setGeometry("Polygon");
	layer.setProvider("postgres");
	layer.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
							"Unknown datum based upon the GRS 1980 ellipsoid");
	layer.setType("vector");
	layer.setUri(te::core::URI("pgsql://postgres:postgres@localhost:5432/postgis_22_sample"));

	qgp.addLayer(layer);

	terrame::qgis::QGis::getInstance().write(qgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer l2 =  qgp2.getLayerByName("LayerPg");
	ASSERT_STREQ(l2.getName().c_str(), "LayerPg");
	ASSERT_EQ(l2.getSrid(), 4903);
	ASSERT_STREQ(l2.getUri().path().c_str(), "/postgis_22_sample");
	ASSERT_STREQ(l2.getUri().host().c_str(), "localhost");
	ASSERT_STREQ(l2.getUri().query().c_str(), "tablename");
	ASSERT_STREQ(l2.getUri().user().c_str(), "postgres");
	ASSERT_STREQ(l2.getUri().password().c_str(), "postgres");
	ASSERT_STREQ(l2.getUri().port().c_str(), "5432");

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}

TEST_F(QGisTest, InsertWfsLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");
	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer layer;
	layer.setName("LayerWfs");
	layer.setDataSetName("data:set");
	layer.setSrid(4903);
	layer.setExtent(1.5, 1.3, 1.9, 1.8);
	layer.setGeometry("Polygon");
	layer.setProvider("WFS");
	layer.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
		"Unknown datum based upon the GRS 1980 ellipsoid");
	layer.setType("vector");
	layer.setUri(te::core::URI("WFS:http://terrabrasilis.info/redd-pac/wfs"));

	qgp.addLayer(layer);

	terrame::qgis::QGis::getInstance().write(qgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer l2 = qgp2.getLayerByName("LayerWfs");
	ASSERT_STREQ(l2.getName().c_str(), "LayerWfs");
	ASSERT_EQ(l2.getSrid(), 4903);
	ASSERT_STREQ(l2.getUri().path().c_str(), "http://terrabrasilis.info/redd-pac/wfs");
	ASSERT_STREQ(l2.getUri().query().c_str(), "data:set");

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}

TEST_F(QGisTest, InsertWmsLayerQGisV3)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa_v3_copy.qgs");
	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer layer;
	layer.setName("LayerWms");
	layer.setDataSetName("data:set");
	layer.setSrid(4903);
	layer.setExtent(1.5, 1.3, 1.9, 1.8);
	layer.setProvider("WMS2");
	layer.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
		"Unknown datum based upon the GRS 1980 ellipsoid");
	layer.setType("raster");
	layer.setUri(te::core::URI(
		"wms://?URI=http://terrabrasilis.info/geoserver/ows&FORMAT=png&VERSION=1.3.0&USERDATADIR=/some/path"));

	qgp.addLayer(layer);

	terrame::qgis::QGis::getInstance().write(qgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	terrame::qgis::QGisLayer l2 = qgp2.getLayerByName("LayerWms");
	ASSERT_STREQ(l2.getName().c_str(), "LayerWms");
	ASSERT_EQ(l2.getSrid(), 4903);
	ASSERT_STREQ(l2.getUri().path().c_str(), "http://terrabrasilis.info/geoserver/ows");
	ASSERT_STREQ(l2.getUri().query().c_str(), "format=png&layers=data:set");

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}

TEST_F(QGisTest, CreateQgsQGisV3)
{
	std::string qgsfile(boost::filesystem::current_path().string() + "/create_qgs_v3.qgs");

	terrame::qgis::QGisProject newQgp(qgsfile);
	newQgp.setTitle("QGIS Project");
	std::string fileLayer(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.geojson");

	terrame::qgis::QGisLayer layer("NewLayer", 4019, te::core::URI("file://" + fileLayer));
	layer.setDataSetName("sampa");
	layer.setExtent(-53.11011153163347842f, -25.31232094931403509f,
					-44.16136516442313109f, -19.77965579787450423f);
	layer.setGeometry("Polygon");
	layer.setProvider("OGR");
	layer.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
		"Unknown datum based upon the GRS 1980 ellipsoid");
	layer.setType("vector");

	newQgp.addLayer(layer);

	terrame::qgis::QGis::getInstance().write(newQgp);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgsfile);

	ASSERT_EQ(qgp2.getLayers().size(), 1);

	boost::filesystem::remove(boost::filesystem::path(qgsfile));
}

TEST_F(QGisTest, InsertLayerNoNamePathException)
{
	std::string qgsfile(boost::filesystem::current_path().string() + "/nonamepath.qgs");

	terrame::qgis::QGisProject newQgp(qgsfile);
	newQgp.setTitle("QGIS Project");

	terrame::qgis::QGisLayer layer;

	newQgp.addLayer(layer);

	try
	{
		terrame::qgis::QGis::getInstance().write(newQgp);
		FAIL();
	}
	catch (const std::runtime_error& e)
	{
		ASSERT_STREQ(e.what(), "Layer 'name' and 'uri' must be set to allow save it.");
	}
	catch (...)
	{
		FAIL();
	}
}

TEST_F(QGisTest, RemoveLayerOfNewProject)
{
	std::string qgsfile(boost::filesystem::current_path().string() + "/remove_layer.qgs");

	terrame::qgis::QGisProject qgp1(qgsfile);
	qgp1.setTitle("QGIS Project");
	std::string f1(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.geojson");
	terrame::qgis::QGisLayer l1("Layer1", 4019, te::core::URI("file://" + f1));
	l1.setDataSetName("sampagj");
	l1.setExtent(-53.11011153163347842f, -25.31232094931403509f,
		-44.16136516442313109f, -19.77965579787450423f);
	l1.setGeometry("Polygon");
	l1.setProvider("OGR");
	l1.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
		"Unknown datum based upon the GRS 1980 ellipsoid");
	l1.setType("vector");

	std::string f2(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.shp");
	terrame::qgis::QGisLayer l2("Layer2", 4019, te::core::URI("file://" + f2));
	l2.setDataSetName("sampashp");
	l2.setExtent(-53.11011153163347842f, -25.31232094931403509f,
		-44.16136516442313109f, -19.77965579787450423f);
	l2.setGeometry("Polygon");
	l2.setProvider("OGR");
	l2.setSpatialRefSys("+proj=longlat +ellps=GRS80 +no_defs",
		"Unknown datum based upon the GRS 1980 ellipsoid");
	l2.setType("vector");

	qgp1.addLayer(l1);
	qgp1.addLayer(l2);
	terrame::qgis::QGis::getInstance().write(qgp1);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgsfile);
	qgp2.removeLayer(l1);

	terrame::qgis::QGis::getInstance().write(qgp2);

	terrame::qgis::QGisProject qgp3 = terrame::qgis::QGis::getInstance().read(qgsfile);
	
	ASSERT_EQ(qgp3.getLayers().size(), 1);
	ASSERT_TRUE(qgp3.getLayerByName(l1.getName()).empty());
	ASSERT_STREQ(qgp3.getLayerByName(l2.getName()).getName().c_str(), l2.getName().c_str());

	boost::filesystem::remove(boost::filesystem::path(qgsfile));
}

TEST_F(QGisTest, RemoveLayerOfExistingProject)
{
	std::string qgsfile(std::string(TERRAME_INTTEST_DATA_PATH) + "/various_v3.qgs");
	std::string qgscopy(std::string(TERRAME_INTTEST_DATA_PATH) + "/various_v3_copy.qgs");

	boost::filesystem::copy_file(boost::filesystem::path(qgsfile),
		boost::filesystem::path(qgscopy),
		boost::filesystem::copy_option::overwrite_if_exists);

	terrame::qgis::QGisProject qgp1 = terrame::qgis::QGis::getInstance().read(qgscopy);	
	terrame::qgis::QGisLayer l1 = qgp1.getLayerByName("sampa");

	qgp1.removeLayer(l1);

	terrame::qgis::QGis::getInstance().write(qgp1);

	terrame::qgis::QGisProject qgp2 = terrame::qgis::QGis::getInstance().read(qgscopy);

	ASSERT_EQ(qgp2.getLayers().size(), 2);
	ASSERT_TRUE(qgp2.getLayerByName("sampa").empty());
	ASSERT_STREQ(qgp2.getLayerByName("biomassa-manaus").getName().c_str(), "biomassa-manaus");
	ASSERT_STREQ(qgp2.getLayerByName("vegtype_2000").getName().c_str(), "vegtype_2000");

	boost::filesystem::remove(boost::filesystem::path(qgscopy));
}
