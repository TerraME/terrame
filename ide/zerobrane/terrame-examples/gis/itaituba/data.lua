--[[ [previous](../08-document.lua) | [contents](../00-contents.lua) | [next](data/itaituba.lua)

This script cannot be run by itself. It contains the description of Itaituba data
to be shown in the documentation. You can edit it to see that the content of the
created webpage will also change. A sketch of this script can be automatically
created (see the last script of the tutorial). A complete description of each
attribute of this file is described [here](https://github.com/TerraME/terrame/wiki/Packages#DataFiles).

]]

data{
	file = {"itaituba-census.shp"},
	summary = "Census data for Itaituba in the year 2000.",
	source = "IBGE, 2007",
	attributes = {
		population = "Total population of the tract.",
		dens_pop = "Total population divided by the tract's area.",
	}
}

data{
	file = {"itaituba-deforestation.tif", "itaituba-deforestation.xml"},
	summary = "Deforestation in Itaituba.",
	source = "PRODES/INPE",
	attributes = {
		["0"] ="Data with values 8 (forest), 87 (clear-cut deforestation), 167 (river), and 256 (no data)."
	}
}

data{
	file = {"itaituba-elevation.tif", "itaituba-elevation.xml"},
	summary = "SRTM data within Itaituba.",
	source = "HAND (derived from SRTM/NASA)",
	attributes = {
		["0"] = "A number with the elevation in each pixel."
	}
}

data{
	file = "itaituba-localities.shp",
	summary = "Main localities in Itaituba.",
	source = "IBAMA, 2007",
	attributes = {
		name = "Name of the locality."
	}
}

data{
	file = "itaituba-roads.shp",
	summary = "Roads of Itaituba.",
	source = "IBGE, 2007"
}

