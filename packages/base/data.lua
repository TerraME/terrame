
data{
	file = {"brazilstates.dbf", "brazilstates.shp", "brazilstates.shx"},
	summary = "A shapefile describing the 27 Brazilian states.",
	source = "IBGE (http://www.ibge.gov.br)"
}

data{
	file = "agents.csv",
	summary = "A simple set of four Agents.",
	source = "TerraME team",
	attributes = {"name", "age", "wealth", "vision", "metabolism", "immune"},
	types = {"string", "number", "number", "number", "number", "boolean"},
	description = {"Name of the agents", "Age of the agent", "Amount of sugar the agent starts with", "Distance in cells the agent can see", "Energy consumed by time step", "Whether the agent is immune"}
}

data{
	file = {"cabecadeboi.shp", "cabecadeboi.shx", "cabecadeboi.dbf"},
	image = "cabeca.bmp",
	source = "TerraME team",
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil."
}

data{
	file = {"Limit_pol.dbf", "Limit_pol.shp", "Limit_pol.shx"},
	summary = "A polygons describing Emas National Park, in Goias, Brazil.",
	source = "Rodolfo Almeida"
}

data{
	file = {"River_lin.dbf", "River_lin.shp", "River_lin.shx"},
	summary = "A line describing a river within Emas National Park, in Goias, Brazil.",
	source = "Rodolfo Almeida"
}

data{
	file = {"cabecadeboi900.shp", "cabecadeboi900.shx", "cabecadeboi900.dbf"},
	image = "cabeca2.bmp",
	source = "TerraME team",
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil, with a larger resolution."
}

data{
	file = {"brazil.gal"},
	summary = "A small Neighborhood file for brazilstates.shp.",
	source = "TerraME team"
}

data{
	file = {"emas-distance.gal", "emas-distance.gwt", "emas-distance.gpm", "emas-pollin.gpm", "gpmdistanceDbEmasCells.gpm", "gpmlinesDbEmas.gpm"},
	summary = "Neighborhood files to be used with emas database.",
	source = "TerraME team"
}

data{
	file = {"cabecadeboi-neigh.gal", "cabecadeboi-neigh.gpm", "cabecadeboi-neigh.gwt", "gpmAreaCellsPols.gpm"},
	summary = "Neighborhood files to be used with cabecadeboi database.",
	source = "TerraME team"
}

data{
	file = {"simple.map"},
	image = "simple.bmp",
	summary = "A simple CellularSpace with one attribute for sugarscape model.",
	source = "TerraME team"
}

data{
	file = {"simple-cs.csv"},
	image = "simple-cs.bmp",
	summary = "A simple CellularSpace with an attribute called maxSugar (number).",
	source = "TerraME team"
}

data{
	file = {"amazonia.shp", "amazonia.shx", "amazonia.dbf"},
	image = "amazonia.bmp",
	source = "TerraME team",
	summary = "Database with some data for the Amazonia region, in Brazil."
}

data{
	file = {"emas.shp", "emas.shx", "emas.dbf"},
	image = "emas.bmp",
	source = "TerraME team",
	reference = "Almeida, Rodolfo M., et al. 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de Geoinfoamatica (2008)",
	summary = "Land cover data on Parque Nacional das Emas, Brazil."
}

