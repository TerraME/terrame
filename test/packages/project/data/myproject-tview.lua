
import("terralib")

if isFile("myproject2.tview") then
	File("myproject2.tview"):delete()
end

proj = Project{
	file = "myproject2.tview",
	clean = true,
	setores = filePath("Setores_Censitarios_2000_pol.shp", "terralib")
}

cl1 = Layer{
	project = proj,
	name = "cells",
	clean = true,
	file = "itaituba.shp",
	input = "setores",
	resolution = 40000
}

