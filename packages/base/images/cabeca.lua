
local cs = CellularSpace{
	file = filePath("cabecadeboi.shp")
}

m = Map{
	target = cs,
	select = "height",
	min = 0,
	max = 255,
	slices = 10,
	color = "Grays"
}

m:save("cabeca.png")

clean()

