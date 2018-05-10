--[[ [previous](../wms/12-wms-data.lua) | [contents](../00-contents.lua) | [next](../00-contents.lua)

Finally, it is possible to use an argument 'time = "snapshot"' to indicate
that the layer is in fact composed by several layers, each one representing
a different time stamp. Note that the name of the View is now the name
of the layer without the time.

]]

import("gis")
import("publish")

p = Project{
	file = "wms.tview",
	clean = true,
	amazon = "limiteAML.shp",
	biome = "BiomaAmazonia.shp"
}

service = "http://35.198.39.192/geoserver/wms"

Layer{project = p, service = service, name = "prodes_2000", map = "amazon:prodes_2000"}
Layer{project = p, service = service, name = "prodes_2005", map = "amazon:prodes_2005"}
Layer{project = p, service = service, name = "prodes_2010", map = "amazon:prodes_2010"}
Layer{project = p, service = service, name = "prodes_2015", map = "amazon:prodes_2015"}

Layer{project = p, service = service, name = "conservationUnits_2000", map = "amazon:conservationUnits_2000"}
Layer{project = p, service = service, name = "conservationUnits_2005", map = "amazon:conservationUnits_2005"}
Layer{project = p, service = service, name = "conservationUnits_2010", map = "amazon:conservationUnits_2010"}
Layer{project = p, service = service, name = "conservationUnits_2015", map = "amazon:conservationUnits_2015"}

Application{
	title = "Brazilian Amazon",
	project = p,
	description = "Example of Brazilian Amazon.",
	base = "terrain",
	template = {navbar = "#32884D", title = "white"},
	amazon = View{
		description = "Legal Amazon area.",
		title = "Legal Amazon",
		color = "white",
		transparency = 1,
		visible = false
	},
	biome = View{
		description = "Brazilian Amazon biome.",
		title = "Amazon Biome",
		color = "green",
		transparency = 0.6,
		visible = false
	},
	conservationUnits = View{
		title = "Conservation units",
		description = "Federal and state conservation units.",
		color = {"#D3FFBE", "#E9FFBE"},
		label = {"Federal", "State"},
		time = "snapshot",
		transparency = 0.2,
	},
	prodes = View{
		title = "Deforestation",
		description = "Clear-cut deforestation.",
		color = "#FF0000",
		label = "Deforestation",
		transparency = 0.3,
		visible = false,
		time = "snapshot"
	},
}

