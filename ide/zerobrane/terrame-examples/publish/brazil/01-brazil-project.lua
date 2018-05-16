--[[ [previous](../00-contents.lua) | [contents](../00-contents.lua) | [next](02-brazil-biomes.lua)

This example shows how to create a Google Maps application using polygon
data, as described in the tutorial available [here](https://github.com/TerraME/terrame/wiki/Publish). It includes two data
related to Brazil: biomes and states. The first step to create an
application is to define a [Project](http://www.terrame.org/packages/doc/gis/doc/files/Project.html) with these two data. The code
below creates a project stored in file "brazil.tview". It also defines
two layers, biomes and states, that point to the files br_biomes.shp and
br_states, respectively, which are stored in the current directory.

]]

import("gis")

Project{
	file = "brazil.tview",
	clean = true,
	biomes = "br_biomes.shp",
	states = "br_states.shp"
}

