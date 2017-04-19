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

-- @example Creates and fills amazonia database in PostGIS DataBase Management System.

import("terralib")

amazonia = Project{
	file = "amazonia-postgis.tview",
	clean = true,
	title = "Amazonia database",
	ports = filePath("amazonia-ports.shp", "terralib"),
	roads = filePath("amazonia-roads.shp", "terralib"),
	limit = filePath("amazonia-limit.shp", "terralib")
}

prodes = Layer{
	name = "prodes",
	project = amazonia,
	epsg = 29191,
	file = filePath("amazonia-prodes.tif", "terralib")
}

protected = Layer{
	name = "protected",
	project = amazonia,
	epsg = 29191,
	file = filePath("amazonia-indigenous.shp", "terralib")
}

if not getConfig() then
	customError("You should provide connection information in a config.lua file.")
end

amazoniaCells = Layer{
	project = amazonia,
	clean = true,
	input = "limit",
	name = "cells",
	resolution = 50000,
	source = "postgis",
	user = getConfig().user or "postgres", -- this should be only "user = getConfig().user" - "postgres" should be the default value for user
	password = getConfig().password,
	database = "amazonia",
	table = "amazonia"
}

amazoniaCells:fill{
	operation = "coverage",
	layer = "prodes",
	attribute = "prodes"
}

amazoniaCells:fill{
	operation = "distance",
	layer = "roads",
	attribute = "distroads"
}

amazoniaCells:fill{
	operation = "distance",
	layer = "ports",
	attribute = "distports"
}

amazoniaCells:fill{
	operation = "area",
	layer = "protected",
	attribute = "protected"
}

cs = CellularSpace{
	project = amazonia,
	layer = "cells",
	as = {
		forest = "prodes_208",
		deforestation = "prodes_10"
	}
}

Map{
	target = cs,
	select = "distroads",
	slices = 10,
	invert = true,
	color = "YlOrBr"
}

Map{
	target = cs,
	select = "distports",
	slices = 10,
	invert = true,
	color = "YlOrBr"
}

Map{
	target = cs,
	select = "protected",
	slices = 10,
	invert = true,
	color = "PuBu"
}

Map{
	target = cs,
	select = "deforestation",
	slices = 10,
	invert = true,
	color = "YlGn"
}

