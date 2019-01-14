-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

-- This code is part of the TerraME framework.
-- This framework is free software; you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public
-- License as published by the Free Software Foundation; either
-- version 2.1 of the License, or (at your option) any later version.

-- You should have received a copy of the GNU Lesser General Public
-- License along with this library.

-- The authors reassure the license terms regarding the warranties.
-- They specifically disclaim any warranties, including, but not limited to,
-- the implied warranties of merchantability and fitness for a particular purpose.
-- The framework provided hereunder is on an "as is" basis, and the authors have no
-- obligation to provide maintenance, support, updates, enhancements, or modifications.
-- In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
-- indirect, special, incidental, or consequential damages arising out of the use
-- of this software and its documentation.
--
-------------------------------------------------------------------------------------------

-- @example Creates a project for the Itaituba region, in Para state, Brazil.

import("gis")

itaituba = Project{
	file = "itaituba.tview",
	clean = true,
	localities = filePath("itaituba-localities.shp", "gis"),
	roads = filePath("itaituba-roads.shp", "gis"),
	census = filePath("itaituba-census.shp", "gis")
}

Layer{
	project = itaituba,
	name = "deforestation",
	file = filePath("itaituba-deforestation.tif", "gis"),
	epsg = 29191
}

Layer{
	project = itaituba,
	name = "elevation",
	file = filePath("itaituba-elevation.tif", "gis"),
	epsg = 29191
}

itaitubaCells = Layer{
	project = itaituba,
	name = "cells",
	clean = true,
	file = "itaituba.shp",
	input = "census",
	resolution = 5000,
	progress = false
}

itaitubaCells:fill{
	operation = "average",
	layer = "elevation",
	attribute = "elevation",
	progress = false
}

itaitubaCells:fill{
	operation = "coverage",
	layer = "deforestation",
	attribute = "defor",
	progress = false
}

itaitubaCells:fill{
	operation = "distance",
	layer = "roads",
	attribute = "distroad",
	progress = false
}

itaitubaCells:fill{
	operation = "distance",
	layer = "localities",
	attribute = "distlocal",
	progress = false
}

itaitubaCells:fill{
	operation = "sum",
	layer = "census",
	attribute = "population",
	select = "population",
	area = true,
	progress = false
}

cell = Cell{
	logpop = function(self)
		return math.log(self.population)
	end
}

cs = CellularSpace{
	project = itaituba,
	layer = "cells",
	as = {
		river = "defor_167",
		deforestation = "defor_87"
	},
	instance = cell
}

Map{
	target = cs,
	select = "elevation",
	slices = 6,
	color = "Blues"
}

Map{
	target = cs,
	select = "river",
	slices = 6,
	color = "Blues"
}

Map{
	target = cs,
	select = "deforestation",
	slices = 6,
	invert = true,
	color = "Greens"
}

Map{
	target = cs,
	select = "distlocal",
	slices = 10,
	color = "Reds"
}

Map{
	target = cs,
	select = "distroad",
	slices = 10,
	color = "Reds"
}

Map{
	target = cs,
	select = "logpop",
	slices = 10,
	color = "Purples"
}

