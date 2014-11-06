
data{
	file = {"EstadosBrasil.dbf", "EstadosBrasil.shp", "EstadosBrasil.shx"},
	summary = "A shapefile desribing the 27 Brazilian states.",
	source = "IBGE (www.ibge.br)",
	attributes =  {},
	types = {},
	
}

data{
	file = "agents.csv",
	summary = "A simple set of four agents",
	attributes = {"name", "age", "wealth", "vision", "metabolism", "immune"},
	types = {"string", "number", "number", "number", "number", "boolean"},
	description = {"Name of the agents", "Age of the agent", "Amount of sugar the agent startw with", "Distance in cells the agent can see", "Energy consumed by time step", "Whether the agent is immune"}
}

data{
	file = {"cabecaDeBoi.mdb", "cabecaDeBoi.sql"}

}

data{
	file = {"db_emas.mdb", "db_emas.sql"},
	reference = "Almeida, Rodolfo M., et al. 'Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil.' X Simposio Brasileiro de Geoinfoamatica (2008)",
	summary = "Land cover data on Parque Nacional das Emas, Brazil"
}

