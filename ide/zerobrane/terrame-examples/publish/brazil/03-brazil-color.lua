--[[ [previous](02-brazil-biomes.lua) | [contents](../00-contents.lua) | [next](04-brazil-states.lua)

The previous application paints the biomes using black color. It is possible
to set the colors of the biomes using [ColorBrewer](http://www.colorbrewer2.org/) names, as well as setting
one color to each of the polygons. The code below uses the colors named Set2.

]]

import("gis")
import("publish")

Project{
	file = "brazil.tview",
	clean = true,
	biomes = "br_biomes.shp",
	states = "br_states.shp"
}

Application{
	project = "brazil.tview",
	title = "Brazil Application",
	description = "Small application with some data related to Brazil.",
	biomes = View{
		select = "name",
		color = "Set2",
		description = "Brazilian Biomes, from IBGE.",
	}
}

