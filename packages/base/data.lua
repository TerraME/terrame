
data{
	file = "brazilstates.shp",
	summary = "A shapefile describing the 27 Brazilian states.",
	source = "IBGE (http://www.ibge.gov.br)",
	attributes = {
		NOME_UF = "Name of the state.",
		SIGLA = "State's initials.",
		CAPITAL = "Name of the state's capital.",
		POPUL = "Population of the state."
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
		height = "Height of the Cell, measured in values between 0 and 255."
	},
	image = "cabeca.png",
	source = "This data is a copy of the file with the same name created by terralib package.",
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil, with 100x100m of resolution."
}

data{
	file = "river.shp",
	summary = "A line describing a river within Emas National Park, in Goias, Brazil.",
	source = "Rodolfo Almeida"
}

data{
	file = "cabecadeboi800.shp",
	image = "cabeca2.png",
	source = "This data is a copy of cabecadeboi created by terralib package, using a resolution of 800m.",
	attributes = {
		height = "Height of the Cell, measured in values between 0 and 255."
	},
	summary = "Topography data from Cabeca de Boi mountain, Minas Gerais, Brazil, with 800x800m of resolution."
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
	image = "simple.png",
	summary = "A simple CellularSpace with one attribute for sugarscape model.",
	source = "TerraME team"
}

data{
	file = "amazonia.shp",
	image = "amazonia.png",
	source = "This data is a copy of the file with the same name created by terralib package.",
	summary = "Cellular data representing the Amazonia region, in Brazil. It has 50x50km of resolution.",
	attributes = {
		protected = "Percentage of indigenous area.",
		distports = "Distance to ports.",
		distroads = "Distance to roads.",
		prodes_208 = "Percentage of forest area.",
		prodes_10 = "Percentage of clear-cut area.",
	}
}

data{
	file = "emas.shp",
	image = "emas.png",
	source = "This data is a copy of the file with the same name created by terralib package.",
	summary = "Cellular data representing Emas National Park, Brazil. It has 500x500m of resolution.",
	attributes = {
		river = "Cell has a river (1) or not (0).",
		firebreak = "Cell has a firebreak (1) or not (0).",
		maxcover = "A value between 1 and 5 with the maximum value for the forest cover according to the original data with lower resolution.",
		mincover = "A value between 1 and 5 with the minimum value for the forest cover according to the original data with lower resolution."
	},
	reference = "Almeida, Rodolfo M., et al. 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de Geoinformatica (2008)"
}

directory{
	name = "test",
	summary = "Directory with files used only for internal tests. This directory is not available within TerraME installer, but it can be downloaded from GitHub.",
	source = "TerraME team"
}

