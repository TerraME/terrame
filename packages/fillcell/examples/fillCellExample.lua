import("fillcell")

-- HUNK USED ONLY TO TEST
local projName = "fillcell_example.tview"

if isFile(projName) then
	os.execute("rm -f "..projName)
end
-- END HUNK

local project = Project{
	file = projName,
	create = true,
	author = "Avancini",
	title = "FillCell Example"
}

local polygons = "Setores"
project:addLayer {
	layer = polygons,
	file = file("Setores_Censitarios_2000_pol.shp", "terralib")
}
	
local points = "Localidades"
project:addLayer {
	layer = points,
	file = file("Localidades_pt.shp", "terralib")	
}

local lines = "Rodovias"
project:addLayer {
	layer = lines,
	file = file("Rodovias_lin.shp", "terralib")	
}

local tif = "Desmatamento"
project:addLayer {
	layer = tif,
	file = file("Desmatamento_2000.tif", "terralib")		
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
project:addCellularLayer {
	input = polygons,
	layer = cellDbLayerName,
	resolution = 2e4, -- 50x50km
	source = "postgis",
	user = user,
	password = password,
	database = database,
	table = tableName
}

local cl = CellularLayer{
	project = project,
	layer = cellDbLayerName
}

local distLayer = cellDbLayerName.."_Distance"

-- HUNK USED ONLY TO TEST
pgData.table = distLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fillCells{
	operation = "distance",
	layer = points,
	attribute = "distpoints",
	output = distLayer
}

-- TODO: OPERATION NOT IMPLEMENTED YET
-- cl:fillCells{
	-- strategy = "lenght",
	-- layer = "lines",
	-- attribute = "llenght"
-- }

local sumLayer = cellDbLayerName.."_Sum"

-- HUNK USED ONLY TO TEST
pgData.table = sumLayer
terralib:dropPgTable(pgData)
-- END HUNK

cl:fillCells{
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

cl:fillCells{
	layer = polygons,
	operation = "average",
	attribute = "income",
	select = "Populacao",
	output = averageLayer,
	area = true
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

if isFile(projName) then
	os.execute("rm -f "..projName)
end

terralib:finalize()
