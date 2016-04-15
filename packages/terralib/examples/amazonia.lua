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

import("fillcell")

local projName = "amazonia.tview"

if isFile(projName) then
	rmFile(projName)
end

local project = Project{
	file = projName,
	create = true,
	author = "Andrade, P.",
	title = "Amazonia database"
}

portos = project:addLayer {
	layer = "portos",
	file = filePath("PORTOS_AMZ_pt.shp", "fillcell")
}

roads = project:addLayer {
	layer = "roads",
	file = filePath("RODOVIAS_AMZ_lin.shp", "fillcell")
}

protected = project:addLayer {
	layer = "protected",
	file = filePath("TI_AMZ_pol.shp", "fillcell")
}

prodes = project:addLayer {
	layer = "prodes",
	file = filePath("PRODES_5KM.tif", "fillcell")
}

limite = project:addLayer {
	layer = "limite",
	file = filePath("LIMITE_AMZ_pol.shp", "fillcell")
}

--[[
-- bug. o sistema nao pode enctonrar o caminho especificado
project:addCellularLayer {
	file = "mycells.shp",
	input = "limite",
	layer = "cells",
	output = "cells",
	resolution = 100000000
}
--]]

project:addCellularLayer {
	file = "c:/mycells.shp", -- test also without c:
	input = "limite",
	layer = "cells",
	resolution = 10000000
}

--[[
local cl = CellularLayer{
	project = project,
	layer = "cells"
}

cl:fillCells{
	operation = "average",
	layer = altimetria,
	attribute = "height"
}

if isFile(projName) then
	rmFile(projName)
end

terralib:finalize()
--]]

