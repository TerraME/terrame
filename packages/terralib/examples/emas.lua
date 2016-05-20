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
	title = "Emas database"
}

firereak = Layer{
	project = project,
	name = "firebreak",
	file = filePath("firebreak_lin.shp", "terralib")
}

cover = Layer{
	project = project,
	name = "cover",
	file = filePath("accumulation_Nov94May00.tif", "terralib")
}

river = Layer{
	project = project,
	name = "river",
	file = filePath("River_lin.shp", "terralib")
}

limit = Layer{
	project = project,
	name = "limit",
	file = filePath("Limit_pol.shp", "terralib")
}

if isFile("emas.shp") then rmFile("emas.shp") end
if isFile("firebreak2.shp") then rmFile("firebreak2.shp") end
if isFile("cover2.shp") then rmFile("cover2.shp") end
if isFile("river2.shp") then rmFile("river2.shp") end

cl = Layer{
	project = project,
	file = "emas.shp",
	input = "limit",
	name = "cells",
	resolution = 500
}

cl:fill{
	operation = "presence",
	attribute = "firebreak",
	layer = "firebreak",
	output = "firebreak2"
}

cl:fill{
	operation = "presence",
	attribute = "river",
	layer = "river",
	output = "river2"
}

cl:fill{
	operation = "average",
	attribute = "cover",
	layer = "cover",
	output = "cover2"
}

cs = CellularSpace{
	project = project,
	layer = "cover2"
}

Map{
	target = cs,
	select = "firebreak",
	value = {0, 1},
	grid = true,
	color = {"white", "black"}
}

Map{
	target = cs,
	grid = true,
	select = "river",
	value = {0, 1},
	color = {"white", "black"}
}

Map{
	target = cs,
	grid = true,
	select = "cover",
	min = 0,
	max = 300,
	slices = 6,
	color = "Greens"
}

