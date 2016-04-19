
amazonia = CellularSpace{
	file = filePath("amazonia.shp")
}

map = Map{
	target = amazonia,
	select = "defor_10",
	slices = 10,
	min = 0,
	max = 1,
	color = {"green", "red"}
}

map:save("amazonia.bmp")

clean()
