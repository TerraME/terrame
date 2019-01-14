
import("gis")

proj = Project{
	file = "myproject.tview",
	clean = true,
	setores = filePath("itaituba-census.shp", "gis")
}

cl1 = Layer{
	project = proj,
	name = "cells",
	clean = true,
	file = "itaituba.shp",
	input = "setores",
	resolution = 40000,
	progress = false
}

