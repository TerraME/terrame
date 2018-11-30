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

#include "QGisLayerTest.h"

#include "qgis/QGisLayer.h"

TEST_F(QGisLayerTest, CompareTwoLayers)
{
	terrame::qgis::QGisLayer l1;
	l1.setName("Layer1");
	l1.setSrid(5808);
	std::string f1(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.geojson");
	l1.setUri(te::core::URI("file://" + f1));

	terrame::qgis::QGisLayer l2;
	l2.setName("Layer2");
	l2.setSrid(5909);
	std::string f2(std::string(TERRAME_INTTEST_DATA_PATH) + "/sampa.shp");
	l2.setUri(te::core::URI("file://" + f2));

	terrame::qgis::QGisLayer l3;
	l3.setName("Layer2");
	l3.setSrid(5909);
	l3.setUri(te::core::URI("file://" + f2));

	ASSERT_FALSE(l1.equals(l2));
	ASSERT_TRUE(l2.equals(l3));
}