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

-- @example Creates a database in a PostGIS database.

import("terralib")

local projName = "fillCellExample.tview"

local project = Project{
	file = projName,
	clean = true,
	author = "Avancini",
	title = "FillCell Example"
}

local polygons = "Setores"
Layer{
	project = project,
	name = polygons,
	file = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
}
	
local points = "Localidades"
Layer{
	project = project,
	name = points,
	file = filePath("Localidades_pt.shp", "terralib")	
}

local lines = "Rodovias"
Layer{
	project = project,
	name = lines,
	file = filePath("Rodovias_lin.shp", "terralib")	
}

local tif = "Desmatamento"
Layer{
	project = project,
	name = tif,
	file = filePath("Desmatamento_2000.tif", "terralib")		
}

local host = "localhost"
local port = "5432"
local user = "postgres"
local password = "postgres"
local database = "postgis_22_sample"
local encoding = "CP1252"
local tableName = "setores_cells"

-- HUNK USED ONLY TO TEST
local pgData = {
	type = "POSTGIS",
	host = host,
	port = port,
	user = user,
	password = password,
	database = database,
	table = tableName, 
	encoding = encoding
}

local terralib = TerraLib{}
terralib:dropPgTable(pgData)
-- END HUNK

local cellDbLayerName = "Setores_Cells_DB"
cl = Layer{
	project = project,
	input = polygons,
	name = cellDbLayerName,
	resolution = 2e4, -- 50x50km
	source = "postgis",
	user = user,
	password = password,
	database = database,
	table = tableName
}

local distLayer = cellDbLayerName.."_Distance"

-- HUNK USED ONLY TO TEST
pgData.table = distLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fill{
	operation = "distance",
	layer = points,
	attribute = "distpoints",
	output = distLayer
}

-- TODO: OPERATION NOT IMPLEMENTED YET
-- cl:fill{
	-- strategy = "lenght",
	-- name = "lines",
	-- attribute = "llenght"
-- }

local sumLayer = cellDbLayerName.."_Sum"

-- HUNK USED ONLY TO TEST
pgData.table = sumLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fill{
	operation = "sum",
	layer = polygons,
	attribute = "sum_population",
	select = "Populacao",
	output = sumLayer,
	area = true
}

local averageLayer = cellDbLayerName.."_Average"

-- HUNK USED ONLY TO TEST
pgData.table = averageLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fill{
	layer = polygons,
	operation = "average",
	attribute = "income",
	select = "Populacao",
	output = averageLayer,
	area = true
}

local rasterLayer = cellDbLayerName.."_Dematamento_Average"

-- HUNK USED ONLY TO TEST
pgData.table = rasterLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fill{
	operation = "average",
	layer = tif,
	attribute = "raverage",
	output = rasterLayer,
}

-- USED ONLY TO TEST
pgData.table = tableName
terralib:dropPgTable(pgData)

pgData.table = distLayer
terralib:dropPgTable(pgData)

pgData.table = sumLayer
terralib:dropPgTable(pgData)

pgData.table = averageLayer
terralib:dropPgTable(pgData)

pgData.table = rasterLayer
terralib:dropPgTable(pgData)

