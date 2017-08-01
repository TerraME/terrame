
-- Amazonia

data{
	file = "amazonia-indigenous.shp",
	summary = "Indigenous lands within Brazilian Amazonia. This is a simplified version of the original data and must be used only for educational purposes.",
	source = "http://www.funai.gov.br/index.php/shape",
	attributes = {
		TERRA_IND = "Name of the Indigenous land.",
		GRUPO = "Name of the Indigenous people the land belongs to.",
	}
}

data{
	file = "amazonia-limit.shp",
	summary = "Limit of the Brazilian Amazonia. This is a simplified and old version of the data and must be used only for educational purposes.",
	source = "http://www.ibge.gov.br"
}

data{
	file = "amazonia-ports.shp",
	summary = "Main ports within Brazilian Amazonia. This is a simplified and old version of the data and must be used only for educational purposes.",
	source = "http://www.antaq.gov.br/portal/PNIH.asp",
	attributes = {
		NOME_PORTO = "Name of the port.",
		TIPO = "Type of the port: \"MARITMO\" (sea) or \"FLUVIAL\" (river).",
	}
}

data{
	file = {"amazonia-prodes.tif", "amazonia-prodes.jgw", "amazonia-prodes.xml", "amazonia-prodes.tif.aux.xml"},
	summary = "PRODES data with resolution of 5km. This is a simplified version of the data and must be used only for educational purposes.",
	source = "http://www.obt.inpe.br/prodes",
	attributes = {
		["0"] = "Clear-cut deforestation (10) or pristine forest (208).",
	}
}

data{
	file = "amazonia-roads.shp",
	summary = "Main roads in Brazilian Amazonia. This is a simplified and old version of the data and must be used only for educational purposes.",
	source = "http://www.dnit.gov.br/mapas-multimodais/shapefiles",
	attributes = {
		RODOVIA = "Name of the road."
	}
}

-- Cabeca de Boi

data{
	file = {"cabecadeboi-elevation.tif", "cabecadeboi-elevation.xml"},
	summary = "Elevation data for the Cabeca de Boi region, in Minas Gerais state, Brazil.",
	source = "",
	attributes = {
		["0"] = "Elevation value based on SRTM data."
	}
}

data{
	file = "cabecadeboi-box.shp",
	summary = "A polygon with a bounding box for the Cabeca de Boi region.",
	source = "TerraME team"
}

-- Emas

data{
	file = {"emas-accumulation.tif", "emas-accumulation.xml"},
	summary = "Land cover accumulation from November 94 to May 2000.",
	source = "Rodolfo Almeida (see Reference)",
	reference = "Almeida et al. (2008). Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil. In: X Simposio Brasileiro de Geoinformatica, Rio de Janeiro, Brazil",
	attributes = {
		["0"] = "A value between 0 and 5 describing the land cover accumulation."
	}
}

data{
	file = "emas-firebreak.shp",
	summary = "Firebreaks in Emas National Park.",
	source = "Rodolfo Almeida",
	reference = "Almeida et al. (2008). Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil. In: X Simposio Brasileiro de Geoinformatica, Rio de Janeiro, Brazil"
}

data{
	file = "emas-limit.shp",
	source = "Rodolfo Almeida (see Reference)",
	summary = "Limit of Emas National Park. For more information about it visit https://en.wikipedia.org/wiki/Emas_National_Park.",
	reference = "Almeida et al. (2008). Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil. In: X Simposio Brasileiro de Geoinformatica, Rio de Janeiro, Brazil"
}

data{
	file = "emas-river.shp",
	source = "Rodolfo Almeida (see Reference)",
	summary = "Rivers within Emas National Park.",
	reference = "Almeida et al. (2008). Simulando padroes de incendios no Parque Nacional das Emas, Estado de Goias, Brasil. In: X Simposio Brasileiro de Geoinformatica, Rio de Janeiro, Brazil"
}

-- Itaituba

data{
	file = {"itaituba-census.shp"},
	summary = "Census data for Itaituba in the year 2000.",
	source = "IBGE",
	attributes = {
		population = "Total population of the tract.",
		dens_pop = "Total population divided by the tract's area.",
	}
}

data{
	file = {"itaituba-deforestation.tif", "itaituba-deforestation.xml"},
	summary = "Deforestation in Itaituba.",
	source = "http://www.obt.inpe.br/prodes",
	attributes = {
		["0"] ="Data with values 8 (forest), 87 (clear-cut deforestation), 167 (river), and 256 (no data)."
	}
}

data{
	file = {"itaituba-elevation.tif", "itaituba-elevation.xml"},
	summary = "SRTM data within Itaituba.",
	source = "",
	attributes = {
		["0"] = "A number with the elevation in each pixel."
	}
}

data{
	file = "itaituba-localities.shp",
	summary = "Main localities in Itaituba.",
	source = "",
	attributes = {
		name = "Name of the locality."
	}
}

data{
	file = "itaituba-roads.shp",
	summary = "Roads of Itaituba.",
	source = ""
}

directory{
	name = "test",
	summary = "Directory with files used only for internal tests. This directory is not available within TerraME installer, but it can be downloaded from GitHub.",
	source = "TerraME team"
}

