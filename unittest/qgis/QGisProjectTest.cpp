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

#include "QGisProjectTest.h"

#include "qgis/QGisProject.h"

TEST_F(QGisProjectTest, AddLayer)
{
	terrame::qgis::QGisLayer l1;
	l1.setName("Layer1");
	terrame::qgis::QGisProject qgp("");

	qgp.addLayer(l1);

	terrame::qgis::QGisLayer l2 = qgp.getLayerByName("Layer1");

	ASSERT_STREQ(l2.getName().c_str(), "Layer1");
}

TEST_F(QGisProjectTest, GetLayersDiff)
{
	terrame::qgis::QGisLayer l1;
	l1.setName("Layer1");
	terrame::qgis::QGisProject qgp1("");
	qgp1.addLayer(l1);

	terrame::qgis::QGisLayer l2;
	l2.setName("Layer2");
	terrame::qgis::QGisProject qgp2("");
	qgp2.addLayer(l1);
	qgp2.addLayer(l2);

	std::vector<terrame::qgis::QGisLayer> layersDiff1 = qgp1.getLayersDiff(qgp2);

	ASSERT_STREQ(layersDiff1.front().getName().c_str(), "Layer2");

	std::vector<terrame::qgis::QGisLayer> layersDiff2 = qgp2.getLayersDiff(qgp1);

	ASSERT_EQ(layersDiff2.size(), 0);
}

TEST_F(QGisProjectTest, RemoveLayer)
{
	terrame::qgis::QGisLayer l1;
	l1.setName("Layer1");
	terrame::qgis::QGisProject qgp1("");
	terrame::qgis::QGisLayer l2;
	l2.setName("Layer2");
	qgp1.addLayer(l1);
	qgp1.addLayer(l2);

	qgp1.removeLayer(l1);
	
	ASSERT_EQ(qgp1.getLayers().size(), 1);
	ASSERT_STREQ(qgp1.getLayerByName(l2.getName()).getName().c_str(), l2.getName().c_str());
}

