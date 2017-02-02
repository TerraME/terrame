
amazonia = CellularSpace{
	file = filePath("amazonia.shp")
}

map = Map{
	target = amazonia,
	select = "prodes_10",
	slices = 10,
	min = 0,
	max = 100,
	color = "RdYlGn",
	invert = true
}

map:save("amazonia.bmp")

clean()
