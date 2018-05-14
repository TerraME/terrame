--[[ [previous](../wms/11-wms-project.lua) | [contents](../00-contents.lua) | [next](13-wms-temporal.lua)

First we will create the application using the functionalities presented
previously. We need to create each layer explicitly. As they are
stored in a server, the colors are already defined in the server,
and need to be filled here just to show the legend properly.

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
	conservationUnits_2000 = View{
		title = "Conservation units in 2000",
		description = "Federal and state conservation units.",
		color = {"#D3FFBE", "#E9FFBE"},
		label = {"Federal", "State"},
		transparency = 0.2,
	},
	conservationUnits_2010 = View{
		title = "Conservation units in 2010",
		description = "Federal and state conservation units.",
		color = {"#D3FFBE", "#E9FFBE"},
		label = {"Federal", "State"},
		visible = false,
		transparency = 0.2,
	},
	prodes_2000 = View{
		title = "Deforestation in 2000",
		description = "Clear-cut deforestation.",
		color = "#FF0000",
		label = "Deforestation",
		transparency = 0.3,
		visible = false
	},
	prodes_2010 = View{
		title = "Deforestation in 2010",
		description = "Clear-cut deforestation.",
		color = "#FF0000",
		label = "Deforestation",
		transparency = 0.3,
		visible = false
	}
}

