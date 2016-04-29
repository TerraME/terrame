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

-- @example Creates a database that can be used by the example deforestation of base package.

import("terralib")

local projName = "amazonia.tview"

if isFile(projName) then
	rmFile(projName)
end

local project = Project{
	file = projName,
	clean = true,
	author = "Andrade, P.",
	title = "Amazonia database"
}

portos = Layer{
	project = project,
	name = "portos",
	file = filePath("PORTOS_AMZ_pt.shp", "terralib")
}

roads = Layer{
	project = project,
	name = "roads",
	file = filePath("RODOVIAS_AMZ_lin.shp", "terralib")
}

protected = Layer{
	project = project,
	name = "protected",
	file = filePath("TI_AMZ_pol.shp", "terralib")
}

prodes = Layer{
	project = project,
	name = "prodes",
	file = filePath("PRODES_5KM.tif", "terralib")
}

limite = Layer{
	project = project,
	name = "limite",
	file = filePath("LIMITE_AMZ_pol.shp", "terralib")
}

cellsFile = "amazonia.shp"

if isFile(cellsFile) then rmFile(cellsFile) end

cl = Layer{
	project = project,
	file = cellsFile,
	input = "limite",
	name = "cells",
	resolution = 100000
}

cl:fill{
	operation = "distance",
	name = "roads",
	attribute = "distroads",
	output = "amazonia-dist.shp"
}

cs = CellularSpace{
	project = project,
	layer = "cells"
}

Map{
	target = cs,
	select = "distroads",
	min = 0,
	max = 200000,
	slices = 10,
	color = {"red", "green"}
}

--[[
cl:fill{
	operation = "average",
	name = "prodes",
	select = 1,
	input = prodes,
	attribute = "height",
	output = "amazonia-height.shp"
}
--]]

if isFile(projName) then
	rmFile(projName)
end

