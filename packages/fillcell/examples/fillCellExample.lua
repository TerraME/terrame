
import("fillcell")

local exts = {".dbf", ".prj", ".shp", ".shx"}

local cellsShp = "sampa_cells"
		
for i = 1, #exts do
	local f = cellsShp..exts[i]
	if isFile(f) then
		os.execute("rm -f "..f)
	end
end	

local projName = "fillcell_example.tview"

if isFile(projName) then
	os.execute("rm -f "..projName)
end

local project = Project{
	file = projName,
	create = true,
	author = "Avancini",
	title = "FillCell Example"
}

local polygons = "Sampa"
project:addLayer {
	layer = polygons,
	file = file("sampa.shp", "fillcell")
}
	
-- local points = "Localidades"
-- project:addLayer {
	-- layer = points,
	-- file = file("Localidades_pt.shp", "fillcell")	
-- }

-- local lines = "Rodovias"
-- project:addLayer {
	-- layer = lines,
	-- file = file("Rodovias_lin.shp", "fillcell")	
-- }

-- local cellLayerName = "Sampa_Cells"
-- local exDir = _Gtme.makePathCompatibleToAllOS(currentDir())
-- local exFile = exDir.."/"..cellsShp..".shp"

-- project:addCellularLayer {
	-- input = polygons,
	-- layer = cellLayerName,
	-- resolution = 0.3, -- 5x5km
	-- file = exFile
-- }

local host = "localhost"
local port = "5432"
local user = "postgres"
local password = "postgres"
local database = "postgis_22_sample"
local encoding = "CP1252"
local tableName = "sampa_cells"

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

local cellDbLayerName = "Sampa_Cells_DB"

project:addCellularLayer {
	input = polygons,
	layer = cellDbLayerName,
	resolution = 0.9,
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

-- TODO: PROBLEMS WITH TERRALIB (REVIEW)
-- cl:fillCells{
	-- operation = "area",
	-- layer = polygons,
	-- attribute = "distpoints"
	-- select = "FID"
	-- output = tableName.."_area"
-- }

local presenceLayerName = cellDbLayerName.."_Presence"

pgData.table = presenceLayerName
terralib:dropPgTable(pgData)

cl:fillCells{
	operation = "presence",
	layer = polygons,
	attribute = "presence",
	output = presenceLayerName
}

-- cl:fillCells{
	-- strategy = "distance",
	-- layer = "points",
	-- attribute = "distpoints"
-- }

-- cl:fillCells{
	-- strategy = "lenght",
	-- layer = "lines",
	-- attribute = "llenght"
-- }

-- cl:fillCells{
	-- layer = "polygons",
	-- strategy = "sum",
	-- attribute = "population",
	-- area = true
-- }

-- cl:fillCells{
	-- layer = "polygons",
	-- strategy = "average",
	-- attribute = "income",
	-- area = true
-- }

-- local test = "Sampa"
-- project:addLayer {
	-- layer = test,
	-- file = file("sampa.shp", "fillcell")	
-- }

-- local toLayer = {
	-- type = "POSTGIS",
	-- host = "localhost",
	-- port = "5432",
	-- user = "postgres",
	-- password = "postgres",
	-- database = "postgis_22_sample",
	-- table = "sampa",
	-- encoding = "CP1252"
-- }

-- terralib:copyLayer(project, test, toLayer)
-- terralib:dropPgTable(toLayer)

-- local toLayer = {
	-- type = "POSTGIS",
	-- host = "localhost",
	-- port = "5432",
	-- user = "postgres",
	-- password = "postgres",
	-- database = "postgis_22_sample",
	-- table = "Setores_Censitarios_2000_pol",
	-- encoding = "CP1252"
-- }

-- terralib:copyLayer(project, polygons, toLayer)
-- terralib:dropPgTable(toLayer)
terralib:dropPgTable(pgData)

for i = 1, #exts do
	local f = cellsShp..exts[i]
	if isFile(f) then
		os.execute("rm -f "..f)
	end
end	

if isFile(projName) then
	os.execute("rm -f "..projName)
end

terralib:finalize()

