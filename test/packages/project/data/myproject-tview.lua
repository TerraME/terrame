
import("terralib")

proj = Project{
	file = "myproject2.tview",
	clean = true,
	setores = filePath("itaituba-census.shp", "terralib")
}

cl1 = Layer{
	project = proj,
	name = "cells",
	clean = true,
	file = "itaituba.shp",
	input = "setores",
	resolution = 40000
}

