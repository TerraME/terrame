
data{
	file = "brazilstates.shp",
	attributes = {
		"SPRAREA", 
		"SPRPERIMET", 
		"SPRROTULO", 
		"SPRNOME", 
		"NOME_UF", 
		"SIGLA", 
		"CAPITAL", 
		"CODIGO", 
		"REGIAO", 
		"POPUL"
	},
	description = {
		"Polygon area", 
		"Polygon perimeter", 
		"A name for the state", 
		"A name for the state", 
		"Name of the state",
		"A name for the state", 
		"Name of the state's capital", 
		"A code for the state", 
		"Name of the region the state belongs", 
		"Population of the state"
	},
	summary = "A shapefile describing the 27 Brazilian states.",
	source = "IBGE (http://www.ibge.gov.br)"
}

data{
	file = "agents.csv",
	summary = "A simple set of four Agents.",
	source = "TerraME team",
	separator = ",",
	attributes = {"name", "age", "wealth", "vision", "metabolism", "immune"},
	description = {"Name of the agents", "Age of the agent", "Amount of sugar the agent starts with", "Distance in cells the agent can see", "Energy consumed by time step", "Whether the agent is immune"}
}

data{
	file = "cabecadeboi.shp",
	attributes = {"object_id0", "Col", "Lin", "height_", "soilWater"},
	description = {"Unique identifier of the Cell", "The x location.", "The y location.", "Height of the Cell, measured in values between 0 and 255.", "Amount of water in the soil."},
	image = "cabeca.bmp",
	source = "TerraME team",
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil."
}

data{
	file = "river.shp",
	attributes = {
		"SPRPERIMET", 
		"SPRCLASSE", 
		"objet_id_9"
	},
	description = {
		"Polygon perimeter", 
		"A string with the class of the polygon", 
		"Unique identifier"
	},
	summary = "A line describing a river within Emas National Park, in Goias, Brazil.",
	source = "Rodolfo Almeida"
}

data{
	file = "cabecadeboi900.shp",
	image = "cabeca2.bmp",
	source = "TerraME team",
	attributes = {"object_id0", "Col", "Lin", "height_", "soilWater"},
	description = {"Unique identifier of the Cell", "The x location.", "The y location.", "Height of the Cell, measured in values between 0 and 255.", "Amount of water in the soil."},
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil, with a larger resolution."
}


data{
	file = "cabecadeboi-neigh.gpm",
	summary = "Neighborhood files to be used with cabecadeboi database.",
	source = "TerraME team"
}


data{
	file = "gpmlinesDbEmas.gpm",
	summary = "Neighborhood files to be used with emas database.",
	source = "TerraME team"
}

data{
	file = "simple.map",
	image = "simple.bmp",
	summary = "A simple CellularSpace with one attribute for sugarscape model.",
	source = "TerraME team"
}

data{
	file = "amazonia.shp",
	image = "amazonia.bmp",
	source = "TerraME team",
	attributes = {"object_id0", "Col", "Lin", "areadigena", "distportos", "distdovias", "defor_255", "defor_208", "defor_10", "bioma_255", "bioma_224", "bioma_191", "bioma_160", "bioma_127", "biomssa_95", "biomssa_63", "biomssa_31", "biomassa_0"},
	description = {"Unique identifier", "Column of the Cell", "Line of the Cell", "Percentage of indigenous area", "Distance to ports", "Distance to roads", "Column with only zeros", "Percentage of non-forest and non-deforestation area", "Percentage of forest area", "Biomass [350, 375, 400]", "Biomass [250, 275, 300]", "Biomass [200, 225, 250]", "Biomass [150, 175, 200]", "Biomass [100, 125, 150]", "Biomass [75, 87.5, 100]", "Biomass [50, 62.5, 75]", "Biomass [25, 37.5, 50]", "Biomass [0, 12.5, 25]"},
	summary = "Database with some data for the Amazonia region, in Brazil. The biomass was taken from Sassan Saatchi. It is represented in Ton/ha and contains three values: [minimum, average, maximum]. The original data was degradated, and therefore the biomass might be underestimated."
}

data{
	file = "emas.shp",
	image = "emas.bmp",
	attributes = {"object_id_", "Col", "Lin", "river", "firebreak", "accuation", "fire", "state"},
	description = {"Unique identifier for the Cell", "Column of the Cell", "Line of the Cell", "" , "", "", "", ""},
	source = "TerraME team",
	reference = "Almeida, Rodolfo M., et al. 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de Geoinfoamatica (2008)",
	summary = "Land cover data on Parque Nacional das Emas, Brazil."
}
