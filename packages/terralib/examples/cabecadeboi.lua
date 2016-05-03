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

-- @example Creates a database that can be used by the example runoff of base package.

import("terralib")

local projName = "cabecadeboi.tview"

local project = Project{
	file = projName,
	clean = true,
	author = "Carneiro, T.",
	title = "Cabeca de Boi database"
}

box = Layer{
	project = project,
	name = "box",
	file = filePath("elevation_box.shp", "terralib")
}

altimetria = Layer{
	project = project,
	name = "altimetria",
	file = filePath("elevation.tif", "terralib") -- se usar "altimetria.tif" da erro
}

if isFile("mycells.shp")     then rmFile("mycells.shp")     end
if isFile("mycells-avg.shp") then rmFile("mycells-avg.shp") end

cl = Layer{
	project = project,
	file = "mycells.shp",
	input = "box",
	name = "cells",
	resolution = 200,
}

cl:fill{
	operation = "average",
	select = 0,
	name = "altimetria",
	output = "mycells-avg",
	attribute = "height"
}

cs = CellularSpace{
	project = project,
	layer = "mycells-avg"
}

Map{
	target = cs,
	select = "height",
	min = 0,
	max = 255,
	color = "RdPu",
	slices = 7
}

if isFile(projName)          then rmFile(projName)          end
if isFile("mycells.shp")     then rmFile("mycells.shp")     end
if isFile("mycells-avg.shp") then rmFile("mycells-avg.shp") end

