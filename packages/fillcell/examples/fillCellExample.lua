
import("fillcell")

local exts = {".dbf", ".prj", ".shp", ".shx"}
		
for i = 1, #exts do
	local f = "setores_cells"..exts[i]
	if isFile(f) then
		os.execute("rm -f "..f)
	end
end	

if isFile("fillcell_example.tview") then
	os.execute("rm -f fillcell_example.tview")
end

local project = Project{
	file = "fillcell_example",
	create = true,
	author = "Avancini",
	title = "FillCell Example"
}

local polygons = "Setores_Censitarios_2000"
project:addLayer {
	layer = polygons,
	file = file("Setores_Censitarios_2000_pol.shp", "fillcell")
}
	
local points = "Localidades"
project:addLayer {
	layer = points,
	file = file("Localidades_pt.shp", "fillcell")	
}

local lines = "Rodovias"
project:addLayer {
	layer = lines,
	file = file("Rodovias_lin.shp", "fillcell")	
}

local cellLayerName = "Setores_Cells"
local exDir = _Gtme.makePathCompatibleToAllOS(currentDir())
local exFile = exDir.."/".."setores_cells.shp"

project:addCellularLayer {
	input = polygons,
	layer = cellLayerName,
	resolution = 2e3, -- 5x5km
	file = exFile
}

local cl = CellularLayer{
	project = project,
	layer = cellLayerName
}

-- cl:fillCells{
	-- operation = "area",
	-- layer = points,
	-- attribute = "distpoints"
-- }

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

local test = "Sampa"
project:addLayer {
	layer = test,
	file = file("sampa.shp", "fillcell")	
}

terralib = TerraLib{}

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

terralib:finalize()

