--[[ [previous](03-brazil-color.lua) | [contents](../00-contents.lua) | [next](05-brazil-report.lua)

Now we are going to add the Brazilian states to the application. As they are
already declared in the project as layer states, we only need to add a View
named states to the applcation. In this code, we paint all states with yellow.

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
		description = "Brazilian Biomes. Source: IBGE.", -- Anything different here?
	},
	states = View{
		color = "yellow",
		description = "Brazilian States.",
	}
}

