
data{
	file = "brazilstates.shp",
	summary = "A shapefile describing the 27 Brazilian states.",
	source = "IBGE (http://www.ibge.gov.br)",
	attributes = {
		NOME_UF = "Name of the state.",
		SIGLA = "State's initials.", 
		CAPITAL = "Name of the state's capital.", 
	}
}

data{
	file = "agents.csv",
	summary = "A simple set of four Agents.",
	source = "TerraME team",
	separator = ",",
	attributes = {
		name = "Name of the agents.", 
		age = "Age of the agent.", 
		wealth = "Amount of sugar the agent starts with.",
		vision = "Distance in cells the agent can see.",
		metabolism = "Energy consumed by time step.",
		immune = "Whether the agent is immune."
	}
}

data{
	file = "cabecadeboi.shp",
	attributes = {
		object_id0 = "Unique identifier of the Cell.",
		Col = "The x location.",
		Lin = "The y location.",
		height_ = "Height of the Cell, measured in values between 0 and 255.",
		soilWater = "Amount of water in the soil."
	},
	image = "cabeca.bmp",
	source = "TerraME team",
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil."
}

data{
	file = "river.shp",
	summary = "A line describing a river within Emas National Park, in Goias, Brazil.",
	source = "Rodolfo Almeida"
}

data{
	file = "cabecadeboi900.shp",
	image = "cabeca2.bmp",
	source = "TerraME team",
	attributes = {
		object_id0 = "Unique identifier of the Cell", 
		Col = "The x location.", 
		Lin = "The y location.", 
		height_ = "Height of the Cell, measured in values between 0 and 255.",
		soilWater = "Amount of water in the soil."
	},
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
	file = "simple.pgm",
	image = "simple.bmp",
	summary = "A simple CellularSpace with one attribute for sugarscape model.",
	source = "TerraME team"
}

data{
	file = "amazonia.shp",
	image = "amazonia.bmp",
	source = "TerraME team",
	summary = "Database with some data for the Amazonia region, in Brazil. The biomass was taken from Sassan Saatchi. It is represented in Ton/ha and contains three values: [minimum, average, maximum]. The original data was degradated, and therefore the biomass might be underestimated.",
	attributes = {
		FID = "Unique identifier (internal value).",
		object_id0 = "Unique identifier.",
		Col = "Column of the Cell.",
		Lin = "Line of the Cell.",
		areadigena = "Percentage of indigenous area.",
		distportos = "Distance to ports.",
		distdovias = "Distance to roads.", 
		defor_255 = "Column with only zeros.",
		defor_208 = "Percentage of non-forest and non-deforestation area.",
		defor_10 = "Percentage of forest area.",
		bioma_255 = "Biomass [350, 375, 400].",
		bioma_224 = "Biomass [250, 275, 300].",
		bioma_191 = "Biomass [200, 225, 250].",
		bioma_160 = "Biomass [150, 175, 200].", 
		bioma_127 = "Biomass [100, 125, 150].",
		biomssa_95 = "Biomass [75, 87.5, 100].",
		biomssa_63 = "Biomass [50, 62.5, 75].",
		biomssa_31 = "Biomass [25, 37.5, 50].",
		biomassa_0 = "Biomass [0, 12.5, 25]."
	}
}

data{
	file = "emas.shp",
	image = "emas.bmp",
	source = "Rodolfo Almeida (see Reference)",
	summary = "Land cover data on Parque Nacional das Emas, Brazil.",
	attributes = {
		FID = "Unique identifier (internal value).",
		object_id_ = "Unique identifier for the Cell.",
		Col = "Column of the Cell.",
		Lin = "Line of the Cell.",
		river = ".",
		firebreak = ".",
		accuation = ".",
		fire = ".",
		state = ".",
	},
	reference = "Almeida, Rodolfo M., et al. 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de Geoinfoamatica (2008)"
}

