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

-- @example Creates a database that can be used by the example deforestation of base package.

import("terralib")

project = Project{
	file = "amazonia.tview",
	clean = true,
	author = "Andrade, P.",
	title = "Amazonia database",
	portos = filePath("PORTOS_AMZ_pt.shp", "terralib"),
	roads = filePath("RODOVIAS_AMZ_lin.shp", "terralib"),
	protected = filePath("TI_AMZ_pol.shp", "terralib"),
	limite = filePath("LIMITE_AMZ_pol.shp", "terralib")
}

Layer{
	project = project,
	name = "prodes",
	file = filePath("PRODES_5KM.tif", "terralib"),
	srid = 29191
}

cl = Layer{
	project = project,
	file = "amazonia.shp",
	clean = true,
	input = "limite",
	name = "cells",
	resolution = 40000
}

cl:fill{
	operation = "distance",
	layer = "roads",
	attribute = "distroads"
}

cl:fill{
	operation = "distance",
	layer = "portos",
	attribute = "distports"
}

-- TODO(#815)
--[[
cl:fill{
	operation = "area",
	layer = "protected",
	attribute = "marea"
}
--]]

cl:fill{
	operation = "coverage",
	layer = "prodes",
	attribute = "prodes"
}

cl:fill{
	operation = "average",
	layer = "prodes",
	input = prodes,
	attribute = "mheight"
}

cs = CellularSpace{
	project = project,
	layer = "cells"
}

Map{
	target = cs,
	select = "distroads",
	slices = 10,
	invert = true,
	color = "YlGn"
}

Map{
	target = cs,
	select = "distports",
	slices = 10,
	invert = true,
	color = "YlGn"
}

--[[
Map{
	target = cs,
	select = "protected",
	min = 0,
	max = 1,
	slices = 10,
	invert = true,
	color = "YlGn"
}
--]]

Map{
	target = cs,
	select = "mheight",
	slices = 10,
	invert = true,
	color = "YlGn"
}
