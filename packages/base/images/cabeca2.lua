
local cs = CellularSpace{
	file = filePath("cabecadeboi900.shp")
}

m = Map{
	target = cs,
	select = "height_",
	min = 0,
	max = 255,
	slices = 10,
	color = "Grays"
}

m:save("cabeca2.bmp")

clean()

