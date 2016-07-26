-------------------------------------------------------------------------------------------
-- TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
-- Copyright (C) 2001-2016 INPE and TerraLAB/UFOP -- www.terrame.org

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

import("terralib")

project = Project{
	file = "emas.tview",
	clean = true,
	author = "Almeida, R.",
	title = "Emas database",
	firebreak = filePath("firebreak_lin.shp", "terralib"),
	cover = filePath("accumulation_Nov94May00.tif", "terralib"),
	river = filePath("River_lin.shp", "terralib"),
	limit = filePath("Limit_pol.shp", "terralib")
}

cl = Layer{
	project = project,
	file = "emas.shp",
	clean = true,
	input = "limit",
	name = "cells",
	resolution = 500
}

cl:fill{
	operation = "presence",
	attribute = "firebreak",
	layer = "firebreak"
}

cl:fill{
	operation = "presence",
	attribute = "river",
	layer = "river"
}

cl:fill{
	operation = "average",
	attribute = "cover",
	layer = "cover"
}

cs = CellularSpace{
	project = project,
	layer = "cells"
}

Map{
	target = cs,
	select = "firebreak",
	value = {0, 1},
	color = {"white", "black"}
}

Map{
	target = cs,
	select = "river",
	value = {0, 1},
	color = {"white", "black"}
}

--[[
max = 0
forEachCell(cs, function(cell)
	if cell.cover > max then max = cell.cover end
end)
--]]

-- the Map below will only work properly when TerraLib
-- loads the band indexes #808
Map{
	target = cs,
	select = "cover",
	min = 0,
	max = 300, -- it will be 5 or 6 possibly
	slices = 6,
	color = "Greens"
}

