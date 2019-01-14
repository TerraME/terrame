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

-- @example Creates a database that can be used by the example fire-spread of base package.

import("gis")

project = Project{
	file = "emas.tview",
	clean = true,
	author = "Almeida, R.",
	title = "Emas database",
	firebreak = filePath("emas-firebreak.shp", "gis"),
	river = filePath("emas-river.shp", "gis"),
	limit = filePath("emas-limit.shp", "gis")
}

Layer{
	project = project,
	name = "cover",
	file = filePath("emas-accumulation.tif", "gis"),
	epsg = 29192
}

cl = Layer{
	project = project,
	file = "emas.shp",
	clean = true,
	input = "limit",
	name = "cells",
	resolution = 500,
	progress = false
}

cl:fill{
	operation = "presence",
	attribute = "firebreak",
	layer = "firebreak",
	progress = false
}

cl:fill{
	operation = "presence",
	attribute = "river",
	layer = "river",
	progress = false
}

cl:fill{
	operation = "maximum",
	attribute = "maxcover",
	layer = "cover",
	progress = false
}

cl:fill{
	operation = "minimum",
	attribute = "mincover",
	layer = "cover",
	progress = false
}

cs = CellularSpace{
	project = project,
	layer = "cells"
}

Map{
	target = cs,
	select = "firebreak",
	value = {0, 1},
	color = {"darkGreen", "black"},
	label = {"forest", "firebreak"}
}

Map{
	target = cs,
	select = "river",
	value = {0, 1},
	color = {"darkGreen", "darkBlue"},
	label = {"forest", "river"}
}

Map{
	target = cs,
	select = "mincover",
	slices = 5,
	color = "YlGn"
}

Map{
	target = cs,
	select = "maxcover",
	slices = 5,
	color = "YlGn"
}

